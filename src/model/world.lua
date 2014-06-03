world = {}

local tiles = nil -- the floor
local objects = nil -- objects can be placed on tiles
local objectDrawOrder = nil -- draw order for objects
local charDrawOrder = nil -- draw order for chars


-- creates a new world. placeholder
function world.init()
    tiles = {}
    for i=1,20 do
        tiles[i] = {}
        for j=1,20 do
            tiles[i][j] = { texture = "grass"..math.random(1,3), object = nil }
        end
    end
    
    objects = {}
    objectDrawOrder = {}
    
    for i=1,50 do
        local x = math.random() * 21
        local y = math.random() * 21
        world.addObject(Tree:new(x, y))
    end
    
    characters = {}
    charDrawOrder = {}
    
    for i=1,1 do
        local char = Char:new(9, 20.5)
        char.animcycle = math.random() * 5 + 1
        world.addChar(char)
    end
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


-- add object to world. marks tiles as built and calculates draw order
function world.addObject(object)
    
    local tileselection = {}
    
    -- first validate that object can be placed
    for i=object.x - object.xsize / 2, object.x + object.xsize / 2, 0.5 do
        for j=object.y - object.ysize, object.y, 0.5 do
            local tile = world.getTile(i, j)
            if tile == nil or tile.object ~= nil then
                return false
            else
                table.insert(tileselection, tile)
            end
        end
    end
    
    objects[object.id] = object
    
    -- mark tiles as used so that no other building can be placed there
    for i,tile in pairs(tileselection) do
        tile.object = object
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


-- return tile at given position or nil
function world.getTile(tx, ty)
    
    local x = math.floor(tx)
    local y = math.floor(ty)
    
    if tiles[y] ~= nil and tiles[y][x] ~= nil then
        return tiles[y][x]
    end
    return nil
    
end