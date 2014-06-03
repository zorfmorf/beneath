
local mouseState = "free"
local buildCandidate = nil

local builditems = {}

logicHandler = {}

function logicHandler.init()
    table.insert(builditems, "default")
    table.insert(builditems, "tree_small")
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
    
    if mouseState ~= "free" then
        
        local tile = world.getTile(x, y)
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
