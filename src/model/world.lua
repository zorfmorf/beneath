
world = {}

local tiles = nil -- the floor
local objects = nil -- objects can be placed on tiles
local drawOrder = nil -- draw order for objects


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
end


function world.getTiles()
    return tiles
end


function world.getDrawOrder()
    return drawOrder
end

function world.addObject(object)
    objects[object.id] = object
    
    -- mark tiles as used so that no other building can be placed there
    for i=0,object.xsize do
        for j=0,object.ysize do
            tiles[math.floor(object.y + j)][math.floor(object.x + i)].object = object
        end
    end
    
    -- add object to draw order
    local i = 1
    while drawOrder[i] ~= nil and objects[drawOrder[i]].y < object.y do
        i = i + 1       
    end
    table.insert(drawOrder, i, object.id)
end

function world.getObject(id)
    return objects[id]
end

function world.getTile(tx, ty)
    
    local x = math.floor(tx)
    local y = math.floor(ty)
    
    if tiles[y] ~= nil and tiles[y][x] ~= nil then
        return tiles[y][x]
    end
    return nil
    
end