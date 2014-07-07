
local mouseState = "free"
local buildCandidate = nil

local builditems = {}

logicHandler = {}

function logicHandler.init()
    table.insert(builditems, Farm:new(0, 0))
    table.insert(builditems, Smith:new(0, 0))
end

function logicHandler.getBuildItems()
    return builditems
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

function logicHandler.tileClick(x, y)
    
    if mouseState == "free" then
        
        local object = world.getClickedObject(x, y)
        
        if object and object.selectable and object.workleft >= 0 then
            object.selected = "axe"
            client.sendTask(object)
        end
        
    else
        
        local tile = world.getTile(x, y)
        
        if tile ~= nil then
            buildCandidate.x = x
            buildCandidate.y = y
            local result = world.isPlacable(buildCandidate)
            if result then
                mouseState = "free"
                hudHandler.activate()
                client.sendBuild(buildCandidate)
            end
        end
        
    end
    
end
