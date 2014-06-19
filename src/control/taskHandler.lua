--[[--
    
    Only used on server
    
    Creates and manages tasks
    
    Tasks are created based on player actions
    
--]]--

taskHandler = {}

local tasklist = {}

function taskHandler.init()
    
end


function taskHandler.update(dt)
    
end


-- Returns a task if available
-- TODO: Consider layers/distance
function taskHandler.getTask()
    return table.remove(tasklist, 1)
end


-- Creates a task based on the target
function taskHandler.createTask(target)
    table.insert(tasklist, target)
end
