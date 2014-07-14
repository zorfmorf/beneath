world = {}

local MAX_OBJECT_SIZE = 5 --needed to correctly select objects on click
local WORLD_SIZE = 30

local tiles = nil -- the floor
local objects = nil -- objects can be placed on tiles
local objectDrawOrder = nil -- draw order for objects
local characters = nil -- villagers, monsters, etc
local charDrawOrder = nil -- draw order for chars
local worldCanvas = nil


function world.init()
    
    tiles = {}
    
    objects = {}
    objectDrawOrder = {}
    
    characters = {}
    charDrawOrder = {}
    
end


-- generates a new world. should be done on server
function world.generate()
    
    for i=1,WORLD_SIZE do
        tiles[i] = {}
        for j=1,WORLD_SIZE do
            tiles[i][j] = { texture = "g"..math.random(1,3), overlays = nil, object = nil }
            if math.random(1, 14) == 10 then tiles[i][j].texture = "g"..math.random(4,6) end
        end
    end
    
    --world.addObject(Ressource:new(15, 15, {planks=6}))
    --world.addObject(Ressource:new(15, 16, {planks=6}))
    world.addObject(Ressource:new(16, 15, {stone=6}))
    world.addObject(Ressource:new(16, 16, {stone=6}))
    
    for i=1,20 do
        local x = math.random() * (WORLD_SIZE + 1)
        local y = math.random() * (WORLD_SIZE + 1)
        world.addObject(Tree:new(x, y))
    end
    
    for i=1,3 do
        local x = math.random() * (WORLD_SIZE - 5) + 1
        local y = math.random() * (WORLD_SIZE - 5) + 1
        local tile = world.getTile(x, y)
        if tile then
            local char = Char:new(x, y)
            world.addChar(char)
        end
    end
end

-- TODO: clean up and move string parsing to parser
function world.updateTiles(newTiles)
    tiles = {}
    for row in string.gmatch(newTiles, '[^;]+') do
        tiles[#tiles + 1] = {}
        for tile in string.gmatch(row, '[^,]+') do
            tiles[#tiles][#tiles[#tiles] + 1] = { texture = tile, overlays = nil, object = nil }
        end
    end
    drawHandler.updateCanvas()
end


-- returns all tiles
function world.getTiles()
    return tiles
end


-- returns all chars
function world.getChars()
    return characters
end


-- returns list of ids for chars and objects in the order they need to be drawn
function world.getDrawOrders()
    return objectDrawOrder, charDrawOrder
end


-- add char to char list and update draw order
function world.addChar(char)
    characters[char.id] = char
    table.insert(charDrawOrder, char.id)
end


-- returns a tileselection or nil
function world.isPlacable(object)
    local tileselection = {}
    
    local x = math.floor(object.x)
    local y = math.floor(object.y)
    
    local xmod = object.xsize - 1
    
    -- first validate that object can be placed
    for i=x, x + xmod do
        for j=y, y - (object.ysize - 1),-1 do
            local tile = world.getTile(i, j)
            if tile == nil or tile.object ~= nil then
                return nil
            else
                table.insert(tileselection, tile)
            end
        end
    end
    return tileselection
end

-- mark tiles as "built on", change texture if necessary
function world.markTiles(tileselection, object)
    
    for i,tile in pairs(tileselection) do
        tile.object = object.id
    end
    
    -- todo find solution to easily identify buildings
    if object:is(Warehouse) or object:is(Carpenter) then
        for l=1,object.xsize+2 do
            for m=1,object.ysize do
                local tile = world.getTile(object.x + l - 2, object.y - m + 1)
                
                local toadd = nil
                
                if l == 1 then
                    if m == 1 then toadd = "ddl" end
                    if m > 1 and m < object.ysize then toadd = "dml" end
                    if m == object.ysize then toadd = "dul" end
                end
                
                if l > 1 and l < object.xsize+2 then
                    if m == 1 then toadd = "dd" end
                    if m > 1 and m < object.ysize then toadd = "dm" end
                    if m == object.ysize then toadd = "du" end
                end
                
                if l == object.xsize+2 then
                    if m == 1 then toadd = "ddr" end
                    if m > 1 and m < object.ysize then toadd = "dmr" end
                    if m == object.ysize then toadd = "dur" end
                end
                
                if toadd then
                    if not tile.overlays then tile.overlays = { } end
                    table.insert(tile.overlays, toadd)
                end

            end
        end
        if not server then drawHandler.updateCanvas() end
    end
end


-- add object to world. marks tiles as built and calculates draw order
function world.addObject(object)
    
    if objects[object.id] then
        print( "Error: duplicate object id: ", object.id, object.__name)
        return false
    end
    
    local tileselection = world.isPlacable(object)
    
    if tileselection == nil then return false end
    
    object.x = math.floor(object.x)
    object.y = math.floor(object.y)
    
    objects[object.id] = object
    
    -- mark tiles as used so that no other building can be placed there
    world.markTiles(tileselection, object)
    
    -- add object to draw order
    if not server then
        table.insert(objectDrawOrder, object.id)
        table.sort(objectDrawOrder, 
            function(a, b) return objects[a].y < objects[b].y end )
    end
        
    -- if we are server, track ressources and inform clients
    if server then
        if object.ressources then ressourceHandler.addRessources(object) end
        server.sendAddObject(object)
    end
    
    return true
end


-- update elements in world
function world.update(dt)
    for i,char in pairs(characters) do
        char:update(dt)
    end
    
    if server then
        for i,object in pairs(objects) do
            if object.workleft < 0 and object:is(Building) then
                object:update(dt)
            end
        end
    end
    
    if not server then
        table.sort(charDrawOrder, 
            function(a, b) return characters[a].y < characters[b].y end )
    end
end


-- returns object with given id
function world.getObject(id)
    if id == nil then return nil end
    return objects[id]
end


-- returns all objects. used for networking
function world.getObjects()
    return objects
end


-- returns char with given id
function world.getChar(id)
    if id == nil then return nil end
    return characters[id]
end

function world.removeObject(id)
    if objects[id] then
        
        -- free up tiles so that other things can be placed there
        for y,row in pairs(tiles) do
            for x,tile in pairs(row) do
                if tile.object == id then tile.object = nil end
            end
        end
        
        -- remove object from draworder
        local i = #objectDrawOrder
        while i > 0 do
            if objectDrawOrder[i] == id then
                table.remove(objectDrawOrder, i)
            end
            i = i - 1
        end
        
        -- make sure that no chars keep on working on this
        objects[id].workleft = -1
        
        -- actually delete object
        objects[id] = nil
        if server then server.sendRemoveObject(id) end
        return true
    end
    return false
end


-- Get object based on clicked tile
function world.getClickedObject(x, y)
    
    local candidate = nil
    
    for i = 0,MAX_OBJECT_SIZE do
        for j = 0,MAX_OBJECT_SIZE do
            
            local xc = math.floor(x-j)
            local yc = math.floor(y+i)
            
            if tiles[yc] and tiles[yc][xc] and tiles[yc][xc].object then
                
                local object = objects[tiles[yc][xc].object]
                
                if object and
                   object.x + object.xsize >= x and
                   object.y - (object.ysize + 1) <= y then
                    
                    candidate = object
                    
                end
                
            end
        end
    end
    
    return candidate
end


-- return tile at given position or nil
function world.getTile(tx, ty)
    
    local x = math.floor(tx)
    local y = math.floor(ty)
    
    if tiles[y] ~= nil and tiles[y][x] ~= nil then
        return tiles[y][x]
    end
    return nil
    
end