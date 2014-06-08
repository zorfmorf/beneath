
local mouseState = "free"
local buildCandidate = nil

local builditems = {}

logicHandler = {}

function logicHandler.init()
    table.insert(builditems, Object:new(0, 0))
    table.insert(builditems, Tree:new(0, 0, 3))
    table.insert(builditems, Tent:new(0, 0))
end

function logicHandler.getBuildItems()
    return builditems
end

function logicHandler.placeObject(object)    
    return world.addObject(object)
end

function logicHandler.switchToBuildMode(object)
    mouseState = "build"
    buildCandidate = object
end

function logicHandler.isInFreeMode()
    return mouseState == "free"
end

function logicHandler.deselect()
    mouseState = "free"
    hudHandler.activate()
end

function logicHandler.recalculatePaths()
    for i,char in pairs(world.getChars()) do
        char.path = nil
    end
end

function logicHandler.tileSelect(x, y)
    
    local tile = world.getTile(x, y)
    
    if mouseState == "free" then
        
        if tile.object then
            taskHandler.createTask(tile.object)
        end
        
    else
        
        if tile ~= nil then
            buildCandidate.x = x
            buildCandidate.y = y
            local result = logicHandler.placeObject(buildCandidate)
            if result then
                mouseState = "free"
                hudHandler.activate()
                logicHandler.recalculatePaths()
            end
        end
        
    end
    
end
