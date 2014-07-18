--[[
    
    Buildings can be placed and build. Each building usually
    produces ressources from other ressources.
    
]]--

Building = Object:extends()
Building.__name = "building"

function Building:__init(x, y)
    Building.super.__init(self, x, y)
    self.char = nil
    self.charrequested = true -- don't request chars by default
end

-- all buildings work when having a worker, otherwise request one
function Building:serverupdate(dt)
    if self.char then
        self:cycle(dt)
    else
        if not self.charrequested then
            self.charrequested = true
            taskHandler.requestchar(self.id)
        end
    end
end

function Building:clientupdate(dt)
    if self.char then
        self:clientcycle(dt)
    end
end


-- only called when server side building has a worker
-- tasked with handling ressource production and informing clients
function Building:cycle(dt)
    -- do nothing for default building
end


-- only called when the client building has a worker
-- handles animation cycles (worker working on building) which
-- is not necessary for server and does not need to be synced
function Building:receiveChar(villager)
    -- do nothing for default building
end

----------- TENT

Tent = Building:extends()
Tent.__name = "tent"

function Tent:__init(x, y)
    Tent.super.__init(self, x, y)
    self.image = "tent"
    self.xsize = 4
    self.ysize = 3
    self.workMax = 10
    self.workleft = self.workMax
    self.buildable = true
    if love.graphics then
       self.mesh = generateMesh(objects[self.image]) 
    end
end
----------- SMITH

Smith = Building:extends()
Smith.__name = "smith"

function Smith:__init(x, y)
    Smith.super.__init(self, x, y)
    self.image = "smith"
    self.xsize = 4
    self.ysize = 3
    self.workMax = 10
    self.workleft = self.workMax
    self.buildable = true
    if love.graphics then
       self.mesh = generateMesh(objects[self.image]) 
    end
end

----------- Farm

Farm = Building:extends()
Farm.__name = "farm"

function Farm:__init(x, y)
    Farm.super.__init(self, x, y)
    self.image = "farm"
    self.xsize = 4
    self.ysize = 3
    self.workMax = 10
    self.workleft = self.workMax
    self.buildable = true
    if love.graphics then
       self.mesh = generateMesh(objects[self.image]) 
    end
end

-- Warehouse

Warehouse = Building:extends()
Warehouse.__name = "warehouse"

function Warehouse:__init(x, y)
    Warehouse.super.__init(self, x, y)
    self.image = "warehouse"
    self.xsize = 4
    self.ysize = 3
    self.workMax = 10
    self.workleft = self.workMax
    self.buildable = true
    self.resShift = { stone=1 } -- purely visual
    self.cost = { planks=6, stone=3 }
    self.costleft = { planks=6, stone=3 }
    self.resUsage = 1 -- 1 res / second
    self.resUsageDt = 0 -- timer value
    if love.graphics then
       self.mesh = generateMesh(objects[self.image]) 
    end
end

-- Carpenter
Carpenter = Building:extends()
Carpenter.__name = "carpenter"

function Carpenter:__init(x, y)
    Carpenter.super.__init(self, x, y)
    self.image = "carpenter"
    self.xsize = 4
    self.ysize = 3
    self.workMax = 10
    self.workleft = self.workMax
    self.buildable = true
    self.resShift = { planks=1 } -- purely visual
    self.cost = { wood=3 }
    self.costleft = { wood=3 }
    self.resUsage = 1 -- 1 res / second
    self.resUsageDt = 0 -- timer value
    self.charrequested = false -- we want a char for this one
    
    -- carpenter specific attributes
    self.dt = 0
    self.transmutetime = 15
    self.woodslots = 6
    self.workpos = { x = 2.4, y = -0.5 }
    self.entrance = { x = 2, y = 0.5 }
    
    if love.graphics then
       self.mesh = generateMesh(objects[self.image]) 
    end
end


function Carpenter:cycle(dt)
    if self.woodslots > 0 then 
        local result = taskHandler.requestRessource(self, "wood")
        if result then self.woodslots = self.woodslots - 1 end
    end
    
    if self:getRessourceAmount("wood") > 0 and self:getRessourceAmount("planks") < 6 then
        self.dt = self.dt + dt
        if self.dt >= self.transmutetime then
            self.dt = 0
            self:removeRessource("wood")
            self:addRessource("planks")
            ressourceHandler.addSingleRessource(self.id, "planks")
            self.woodslots = self.woodslots + 1
            server.updateObject(self)
        end
    else
        self.dt = 0
    end
end


function Carpenter:clientcycle(dt)
    if self:getRessourceAmount("wood") > 0 and self:getRessourceAmount("planks") < 6 then
        self.char:gotoWork( { x = self.x + self.workpos.x, y = self.y - self.workpos.y }, dt)
    else
        self.char:goHome( { x = self.x + self.entrance.x, y = self.y - self.entrance.y }, dt)
    end
end


function Carpenter:receiveChar(villager)
    self.char = Charpenter:new(villager)
    world.removeChar(self.char)
    self.char:addTask(nil) --reset animations
    self.char.visible = true
end