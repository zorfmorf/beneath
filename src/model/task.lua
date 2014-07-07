--[[
  
  Villager AI became really complex/unwieldy when I started adding different task types. Therefore I decided to create a task wrapper (I wanted to avoid this initially) so that the villager AI works the same way no matter what task is assigned.
  
  Each individual task needs to implement and fill the methods defined by abstract task. 
  
  The abstract task can be used as a task as well, but it will only lead to the villager walking to the indicated target. Could be potentially useful
  
]]--

Task = class()
Task.__name = "abstracttask"

function Task:__init(x, y)
    self.target = { x=x, y=y } -- target is an object id
end

-- So the villager can check if there is something left to do
function Task:isCompleted()
    return true
end


-- Gets The current task target. nil if task is finished
function Task:getTarget()
    return self.target
end


-- Called by the villager when working on the task
-- Villager doesn't have to worry about task type
function Task:doWork(villager, dt)
    
end

-- needed for server/client messages
function Task:toString()
    return self.__name..","..self.target.x..","..self.target.y
end

------ Work Task -----
WorkTask = Task:extends()
WorkTask.__name = "worktask"

function WorkTask:__init(target)
    self.object = world.getObject(target)
    self.target = { x=self.object.x, y=self.object.y}
    if not self.object then
        print( "WorkTask: Got empty target" )
    end
end

function WorkTask:isCompleted()
    return self.object.workleft < 0
end

function WorkTask:getTarget()
    return self.target
end

function WorkTask:doWork(villager, dt)
    self.object:work(dt)
end

function WorkTask:toString()
    return self.__name..","..self.object.id
end
    