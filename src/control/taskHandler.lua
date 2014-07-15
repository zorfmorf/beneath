--[[--
    
    Only used on server
    
    Creates and manages tasks
    
    Tasks are created based on player actions
    
--]]--

taskHandler = {}

local tasklist = {} -- available tasks to be claimed
local queuedTasks = {} -- tasks that need some kind of prerequesite
local dtacc = 0

function taskHandler.init()
    
end


function taskHandler.update(dt)
    
    dtacc = dtacc + dt
    
    if dtacc >= 1 then
        
        dtacc = 0
    
        for i,target in ipairs(queuedTasks) do
            
            if target.costleft then
                
                local paid = true
            
                for res,amount in pairs(target.costleft) do
                    if amount > 0 then
                        paid = false
                        if ressourceHandler.hasRessource(res) then
                        
                            local from = ressourceHandler.withdraw(res)
                            if from then
                                target.costleft[res] = target.costleft[res] - 1
                                table.insert(tasklist, CarryTask:new(from, target.id, res))
                            else
                                print("RessourceHandler returned empty ressource wtf")
                            end
                        end
                    end
                end
                
                if paid then
                    print( "Sent all required ressources to ", target.__name )
                    target.costleft = nil 
                end
            
            else
                local ready = true
                if target.ressources == nil then
                    ready = false
                else
                    for res,amount in pairs(target.ressources) do
                        if amount < target.cost[res] then
                            ready = false
                        end
                    end
                end
                if ready then
                    table.insert(tasklist, WorkTask:new(target.id))
                    table.remove(queuedTasks, i)
                end
            end
        end
        
    end
    
end


-- Returns a task if available
-- TODO: Consider layers/distance
function taskHandler.getTask()
    return table.remove(tasklist, 1)
end


-- giving back tasks that could not be fulfilled for some reason
function taskHandler.giveBackTask(task)
    table.insert(tasklist, task)
end


-- Creates a task based on the target
function taskHandler.createTask(target)
    if target.cost then
        table.insert(queuedTasks, target)
    else
        table.insert(tasklist, WorkTask:new(target.id))
    end
end


-- buildings can request ressources here
function taskHandler.requestRessource(object, res)
    if ressourceHandler.hasRessource(res) then
        local source = ressourceHandler.withdraw(res)
        if source then
            table.insert(tasklist, CarryTask:new(source, object.id, res))
            return true
        end
    end
    return false
end


-- buildings may request chars to take up a profession
function taskHandler.requestchar(buildingId)
    table.insert(tasklist, ProfessionTask:new(buildingId))
end