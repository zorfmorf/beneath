
local mouseState = "free"
local buildCandidate = nil

local builditems = {}

logicHandler = {}

function logicHandler.init()
    table.insert(builditems, "default")
    table.insert(builditems, "tree")
end

function logicHandler.getBuildItems()
    return builditems
end

function logicHandler.placeObject(object)
    
    -- first validate that object can be placed
    for i=0,object.xsize-1 do
        for j=0,object.ysize-1 do
            local tile = world.getTile(object.x + i, object.y + j)
            if tile == nil or tile.object ~= nil then
                return false
            end
        end
    end
    
    -- place object
    world.addObject(object)
    return true
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
            end
        end
        
    end
    
end
