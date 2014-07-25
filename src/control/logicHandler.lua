
local mouseState = "free"
local buildCandidate = nil

local builditems = {}

logicHandler = {}

function logicHandler.init()
    --table.insert(builditems, Farm:new(0, 0))
    --table.insert(builditems, Smith:new(0, 0))
    table.insert(builditems, Field:new(0, 0))
    table.insert(builditems, Carpenter:new(0, 0))
    table.insert(builditems, Warehouse:new(0, 0))
end

function logicHandler.getBuildItems()
    return builditems
end

function logicHandler.switchToBuildMode(object)
    if object:is(Field) then
        mouseState = "buildfarm1"
        buildCandidate = object
        return
    end
    mouseState = "build"
    buildCandidate = object
end

function logicHandler.isInFreeMode()
    return mouseState == "free"
end

function logicHandler.getMouseState()
    return mouseState
end

function logicHandler.getBuildCandidate()
    return buildCandidate
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
        
        local object = world.getClickedObject(1, x, y)
        
        if object and object.selectable and object.workleft >= 0 then
            object.selected = "axe"
            client.sendTask(object)
        end
        
    else
        
        if mouseState == "build" then
            local tile = world.getTile(1, x, y)
            
            if tile then
                buildCandidate.x = x
                buildCandidate.y = y
                local result = world.isPlacable(buildCandidate)
                if result then
                    mouseState = "free"
                    hudHandler.activate()
                    client.sendBuild(buildCandidate)
                end
            end
            
        else
            -- field build mode
            if mouseState == "buildfarm2" then
                local result = world.isPlacable(buildCandidate)
                if result then
                    mouseState = "free"
                    hudHandler.activate()
                    client.sendBuild(buildCandidate)
                end
            end
            
            if mouseState == "buildfarm1" then
                local tile = world.getTile(1, x, y)
                
                if tile then
                    buildCandidate.x = math.floor(x)
                    buildCandidate.y = math.floor(y)
                    buildCandidate:generateImage()
                    mouseState = "buildfarm2"
                end
            end
        end
        
    end
    
end
