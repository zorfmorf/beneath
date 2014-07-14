--[[
    
    Buildings can be placed and build. Each building usually
    produces ressources from other ressources.
    
]]--

Building = Object:extends()
Building.__name = "building"

function Building:update(dt)
    
end

----------- TENT

Tent = Building:extends()

function Tent:__init(x, y)
    Tent.super.__init(self, x, y)
    self.__name = "tent"
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

function Smith:__init(x, y)
    Smith.super.__init(self, x, y)
    self.__name = "smith"
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

function Farm:__init(x, y)
    Farm.super.__init(self, x, y)
    self.__name = "farm"
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

function Warehouse:__init(x, y)
    Warehouse.super.__init(self, x, y)
    self.__name = "warehouse"
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

--- Carpenter

Carpenter = Building:extends()

function Carpenter:__init(x, y)
    Carpenter.super.__init(self, x, y)
    self.__name = "carpenter"
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
    
    -- carpenter specific attributes
    self.dt = 0
    self.transmutetime = 15
    self.woodslots = 6
    
    if love.graphics then
       self.mesh = generateMesh(objects[self.image]) 
    end
end

function Carpenter:update(dt)
    if server then
        
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
        end
        
    end
end