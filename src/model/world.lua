
world = {}

local tiles = nil -- the floor
local objects = nil -- objects can be placed on tiles
local drawOrder = nil -- draw order for objects


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
    drawOrder = {}
    
    for i=1,400 do
        local x = math.random() * 20
        local y = math.random() * 20
        world.addObject(Tree:new(x, y))
    end
    
    char = Char:new(5.5, 20.5)
end


-- returns all tiles
function world.getTiles()
    return tiles
end


-- returns list of object ids that determines order in which objects need to
-- be drawn
function world.getDrawOrder()
    return drawOrder
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
    while drawOrder[i] ~= nil and objects[drawOrder[i]].y < object.y do
        i = i + 1       
    end
    table.insert(drawOrder, i, object.id)
    return true
end


-- returns object with given id
function world.getObject(id)
    return objects[id]
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