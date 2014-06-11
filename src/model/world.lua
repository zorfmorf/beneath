world = {}

local MAX_OBJECT_SIZE = 5 --needed to correctly select objects on click
local WORLD_SIZE = 30

local tiles = nil -- the floor
local objects = nil -- objects can be placed on tiles
local objectDrawOrder = nil -- draw order for objects
local charDrawOrder = nil -- draw order for chars
local worldCanvas = nil

-- creates a new world. placeholder
function world.init()
    tiles = {}
    
    for i=1,WORLD_SIZE do
        tiles[i] = {}
        for j=1,WORLD_SIZE do
            tiles[i][j] = { texture = "grass"..math.random(1,3), object = nil }
        end
    end
    
    -- draw terrain to canvas to improve fps
    worldCanvas = love.graphics.newCanvas(WORLD_SIZE * tilesize, WORLD_SIZE * tilesize)
    love.graphics.setCanvas(worldCanvas)
    for y,row in pairs(tiles) do
        for x,tile in pairs(row) do
            love.graphics.draw(terrain[tile.texture], (y - 1) * tilesize, (x - 1) * tilesize)
        end
    end
    love.graphics.setCanvas()
    
    -- now create objects
    objects = {}
    objectDrawOrder = {}
    
    for i=1,100 do
        local x = math.random() * (WORLD_SIZE + 1)
        local y = math.random() * (WORLD_SIZE + 1)
        world.addObject(Tree:new(x, y))
    end
    
    characters = {}
    charDrawOrder = {}
    
    for i=1,10 do
        local char = Char:new(math.random() * (WORLD_SIZE + 1), math.random() * (WORLD_SIZE + 1))
        world.addChar(char)
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
    local i = 1
    while charDrawOrder[i] ~= nil and characters[charDrawOrder[i]].y < char.y do
        i = i + 1       
    end
    table.insert(charDrawOrder, i, char.id)
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
    local i = 1
    while objectDrawOrder[i] ~= nil and objects[objectDrawOrder[i]].y < object.y do
        i = i + 1       
    end
    table.insert(objectDrawOrder, i, object.id)
    return true
end


function world.update(dt)
    for i,char in pairs(characters) do
        char:update(dt)
    end
end


-- returns object with given id
function world.getObject(id)
    if id == nil then return nil end
    return objects[id]
end

-- returns char with given id
function world.getChar(id)
    if id == nil then return nil end
    return characters[id]
end

function world.removeObject(id)
    for y,row in pairs(tiles) do
        for x,tile in pairs(row) do
            if tile.object == id then tile.object = nil end
        end
    end
    objects[id] = nil
    local i = 1
    while i <= #objectDrawOrder do
        if objectDrawOrder[i] == id then
            table.remove(objectDrawOrder, i)
            return
        end
        i = i + 1
    end
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