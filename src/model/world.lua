--[[
    
    
    
]]--

world = {}

local MAX_OBJECT_SIZE = 5 --needed to correctly select objects on click
local WORLD_SIZE = 5 -- size 1 is one 16x16 grid

local tiles = nil -- the floor
local objects = nil -- objects can be placed on tiles
local objectDrawOrder = nil -- draw order for objects
local characters = nil -- villagers, monsters, etc
local charDrawOrder = nil -- draw order for chars
local worldCanvas = nil


function world.init()
    
    chunks = {}
    
    objects = {}
    objectDrawOrder = {}
    
    characters = {}
    charDrawOrder = {}
    
end


-- generates a new world. should be done on server
function world.generate()
    
    --generate default 16x16 tiles
    local tiles = {}
    for j=0,CHUNK_WIDTH - 1 do   
        tiles[j] = {}
        for k=0,CHUNK_WIDTH - 1 do
            tiles[j][k] = { texture = "g"..math.random(1,3), overlays = nil, object = nil }
            if math.random(1, 14) == 10 then tiles[j][k].texture = "g"..math.random(4,6) end
        end   
    end
    
    -- generate chunks
    for i=1,WORLD_SIZE do
        chunks[i] = {}
        for j=1,WORLD_SIZE do
            chunks[i][j] = Chunk:new()
            chunks[i][j]:setTiles(1, tiles)
        end
    end
    
    --world.addObject(Ressource:new(1, 15, 15, {planks=6}))
    --world.addObject(Ressource:new(1, 15, 16, {planks=6}))
    world.addObject(Ressource:new(1, 16, 15, {stone=6}))
    world.addObject(Ressource:new(1, 16, 16, {stone=6}))
    
    for i=1,20 do
        local x = math.random() * (WORLD_SIZE + 1)
        local y = math.random() * (WORLD_SIZE + 1)
        world.addObject(Tree:new(1, x, y))
    end
    
    for i=1,3 do
        local x = math.random() * (WORLD_SIZE - 5) + 1
        local y = math.random() * (WORLD_SIZE - 5) + 1
        local tile = world.getTile(1, x, y)
        if tile then
            local char = Char:new(1, x, y)
            world.addChar(char)
        end
    end
end


function world.updateChunk(x, y, chunk)
    
    if not chunks[y] then chunks[y] = {} end
    
    chunks[y][x] = chunk
    
end


-- returns a specfic chunk or nil if not existent
function world.getChunk(x, y)
    if chunks[y] and chunks[y][x] then 
        return chunks[y][x]
    end
    return nil
end


-- returns all existing chunks
function world.getChunks()
    return chunks
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


-- chars need to be removed when dying or when taking up a profession
function world.removeChar(char)
    characters[char.id] = nil
    local i = #charDrawOrder
    while i > 0 do
        if charDrawOrder[i] == char.id then
            table.remove(charDrawOrder, i)
        end
        i = i - 1
    end
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
            local tile = world.getTile(object.l, i, j)
            if tile == nil or tile.object then return nil end
            table.insert(tileselection, tile)
        end
    end
    return tileselection
end

-- mark tiles as "built on", change texture if necessary
function world.markTiles(tileselection, object)
    
    for i,tile in pairs(tileselection) do
        tile.object = object.id
    end
    
    if object:is(Building) then
        for l=1,object.xsize+2 do
            for m=1,object.ysize do
                local tile = world.getTile(object.l, object.x + l - 2, object.y - m + 1)
                
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
    
    if tileselection == nil then 
        if not server then 
            -- server objects should always be placable!
            
        end
        return false 
    end
    
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
    
    for i,object in pairs(objects) do
        if object.workleft < 0 and object:is(Building) then
            if server then object:serverupdate(dt) end
            if not server then object:clientupdate(dt) end
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
function world.getClickedObject(l, x, y)
    
    local candidate = nil
    
    for i = 0,MAX_OBJECT_SIZE do
        for j = 0,MAX_OBJECT_SIZE do
            
            local xc = math.floor(x-j)
            local yc = math.floor(y+i)
            local tile = world.getTile(l, xc, yc)
            
            if tile and tile.object then
                
                local object = objects[tile.object]
                
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


-- return tile at given layer and position
-- automatically handles chunks so that we never have to worry about them
function world.getTile(tl, tx, ty)
    
    local chunkx = math.floor(tx / CHUNK_WIDTH)
    local chunky = math.floor(ty / CHUNK_WIDTH)
    
    if chunks[chunky + 1] and chunks[chunky + 1][chunkx + 1] then
        local x = math.floor(tx) - chunkx * CHUNK_WIDTH
        local y = math.floor(ty) - chunky * CHUNK_WIDTH
        return chunks[chunkx + 1][chunky + 1]:getTile(tl, x, y)
    end
    return nil
    
end
