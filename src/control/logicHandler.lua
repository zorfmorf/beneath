
local mouseState = "free"
local buildCandidate = nil

logicHandler = {}

function logicHandler.init()
    
end

function logicHandler.placeObject(object)
    
    local tiles = {}
    
    -- first validate that object can be placed
    for i=0,object.xsize do
        for j=0,object.ysize do
            local tile = world:getTile(object.x + i, object.y + j)
            if tile == nil or tile.object ~= nil then
                return false
            end
            table.insert(tiles, tile)
        end
    end
    
    -- place object
    world.objects[object.id] = object
    for i=0,object.xsize do
        for j=0,object.ysize do
            world:getTile(object.x + i, object.y + j).object = object
        end
    end
    return true
end

function logicHandler.switchToBuildMode(object)
    mouseState = "build"
    buildCandidate = object
end

function logicHandler.deselect()
    mouseState = "free"
    hudHandler.activate()
end

function logicHandler.tileSelect(x, y)
    
    if mouseState ~= "free" then
        
        local tile = world:getTile(x, y)
        if tile ~= nil then
            buildCandidate.x = x
            buildCandidate.y = y
            local result = logicHandler.placeObject(buildCandidate)
            if result then
                mouseState = "free"
                hudHandler.activate()
            end
        end
        
    end
    
end
