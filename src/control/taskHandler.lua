--[[--
    
    Only used on server
    
    Creates and manages tasks
    
    Tasks are created based on player actions
    
--]]--

taskHandler = {}

local tasklist = {} -- available tasks to be claimed
local qeuedTasks = {} -- tasks that need some kind of prerequesite

function taskHandler.init()
    
end


function taskHandler.update(dt)
    
    for i,target in ipairs(queuedTasks) do
        
        if target.costleft then
            
            local paid = true
        
            for res,amount in ipairs(target.costleft) do
                if amount > 0 and ressourceHandler.hasRessource(res) then
                    paid = false
                    local from = ressourceHandler.withdraw(res)
                    if from then
                        target.costleft[res] = target.costleft[res] - 1
                        table.insert(tasklist, CarryTask:new(from.id, target.id, res))
                    else
                        print("RessourceHandler returned empty ressource wtf")
                    end
                end
            end
            
            if paid then target.costleft = nil end
        
        else
            local ready = true
            for res,amount in ipairs(target.ressources) do
                if amount < target.cost[res] then
                    ready = false
                end
            end
            if ready then
                WorkTask:new(target.id)
                table.remove(queuedTasks, i)
            end
        end
    end
    
end


-- Returns a task if available
-- TODO: Consider layers/distance
function taskHandler.getTask()
    return table.remove(tasklist, 1)
end


-- Creates a task based on the target
function taskHandler.createTask(target)
    if target.cost then
        table.insert(qeuedTasks, target)
    else
        table.insert(tasklist, WorkTask:new(target.id))
    end
end
