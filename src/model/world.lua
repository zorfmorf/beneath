world = {}

local MAX_OBJECT_SIZE = 5 --needed to correctly select objects on click
local WORLD_SIZE = 30

local tiles = nil -- the floor
local objects = nil -- objects can be placed on tiles
local objectDrawOrder = nil -- draw order for objects
local charDrawOrder = nil -- draw order for chars
local worldCanvas = nil


function world.init()
    
    tiles = {}
    if love.graphics then
        worldCanvas = love.graphics.newCanvas(tilesize, tilesize)
        love.graphics.setCanvas(worldCanvas)
        love.graphics.setColor(200,100,100,255)
        love.graphics.rectangle("fill", 0, 0, tilesize, tilesize)
        love.graphics.setCanvas()
    end
    
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
            tiles[i][j] = { texture = "g"..math.random(1,3), object = nil }
        end
    end
    
    for i=1,100 do
        local x = math.random() * (WORLD_SIZE + 1)
        local y = math.random() * (WORLD_SIZE + 1)
        world.addObject(Tree:new(x, y))
    end
    
    for i=1,10 do
        local char = Char:new(math.random() * (WORLD_SIZE + 1), math.random() * (WORLD_SIZE + 1))
        world.addChar(char)
    end
end


function world.updateTiles(newTiles)
    tiles = {}
    for row in string.gmatch(newTiles, '[^;]+') do
        tiles[#tiles + 1] = {}
        for tile in string.gmatch(row, '[^,]+') do
            tiles[#tiles][#tiles[#tiles] + 1] = { texture = tile, object = nil }
        end
    end
    world.updateCanvas()
end


-- should be called whenever the terrain changes
function world.updateCanvas()
    if love.graphics then
        worldCanvas = love.graphics.newCanvas(WORLD_SIZE * tilesize, WORLD_SIZE * tilesize)
        love.graphics.setCanvas(worldCanvas)
        for y,row in pairs(tiles) do
            for x,tile in pairs(row) do
                love.graphics.draw(terrain[tile.texture], (y - 1) * tilesize, (x - 1) * tilesize)
            end
        end
        love.graphics.setCanvas()
    end 
end


function world.getTerrainCanvas()
    return worldCanvas
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
    for i,tile in pairs(tileselection) do
        tile.object = object.id
    end
    
    -- add object to draw order
    if not server then
        table.insert(objectDrawOrder, object.id)
        table.sort(objectDrawOrder, 
            function(a, b) return objects[a].y < objects[b].y end )
    end
    
    if server then server.sendAddObject(object) end
    
    return true
end


function world.update(dt)
    for i,char in pairs(characters) do
        char:update(dt)
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
        for y,row in pairs(tiles) do
            for x,tile in pairs(row) do
                if tile.object == id then tile.object = nil end
            end
        end
        local i = #objectDrawOrder
        while i > 0 do
            if objectDrawOrder[i] == id then
                table.remove(objectDrawOrder, i)
            end
            i = i - 1
        end
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