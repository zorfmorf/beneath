--[[
  
  Villager AI became really complex/unwieldy when I started adding different task types. Therefore I decided to create a task wrapper (I wanted to avoid this initially) so that the villager AI works the same way no matter what task is assigned.
  
  Each individual task needs to implement and fill the methods defined by abstract task. 
  
  The abstract task can be used as a task as well, but it will only lead to the villager walking to the indicated target. Could be potentially useful
  
]]--

Task = class()
Task.__name = "abstracttask"

function Task:__init(l, x, y)
    self.target = { l=l, x=x, y=y } -- target is an object id
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
    return false -- returning true means that the task is not yet finished and we have to go to another place
end

-- needed for server/client messages
function Task:toString()
    return self.__name..","..self.target.x..","..self.target.y
end

-- finish client task to sync with server
function Task:clientFinish(villager)
    -- do nothing
end

------ Work Task -----
WorkTask = Task:extends()
WorkTask.__name = "worktask"

function WorkTask:__init(target)
    self.object = world.getObject(target)
    self.target = { l=self.object.l, x=self.object.x, y=self.object.y }
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
    return false
end

function WorkTask:toString()
    return self.__name..","..self.object.id
end

------- Carry Task -----
CarryTask = Task:extends()
CarryTask.__name = "carrytask"

function CarryTask:__init(from, to, ressource)
    self.from = world.getObject(from)
    self.to = world.getObject(to)
    self.ressource = ressource
end

function CarryTask:isCompleted()
    return self.to == nil
end

function CarryTask:getTarget()
    if self.from then return self.from end
    return self.to
end

function CarryTask:doWork(villager, dt)
    if self.from then
        self.from:removeRessource(self.ressource)
        self.from = nil
        return true
    end
    self.to:addRessource(self.ressource)
    self.to = nil
    return false
end

function CarryTask:toString()
    return self.__name..","..self.from.id..","..self.to.id..","..self.ressource
end

function CarryTask:clientFinish(villager)
    if self.from then 
        self.from:removeRessource(self.ressource)
        self.from = nil
    end
    if self.to then
        self.to:addRessource(self.ressource)
        self.to = nil
    end
end

------- Profession Task -----
ProfessionTask = Task:extends()
ProfessionTask.__name = "professiontask"

function ProfessionTask:__init(targetid)
    self.target = world.getObject(targetid)
end

function ProfessionTask:isCompleted()
    return false
end

function ProfessionTask:getTarget()
    return self.target
end

function ProfessionTask:doWork(villager, dt)
    self.target:receiveChar(villager)
    return false
end

function ProfessionTask:toString()
    return self.__name..","..self.target.id
end

function ProfessionTask:clientFinish(villager)
    self:doWork(villager, 0)
end
