--[[
    
    Objects are things that are placed on the terrain
    
    Ressources, trees, buildings, etc
    
]]--


------------ HELPER FUNCTIONS --------

-- we need to calculate different if on client
local function calculateWork(workleft, dt)
    local wnew = workleft - dt
    --if not server and wnew < 0 then return 0 end
    return wnew
end

local function generateMesh(image)
    local xs = image:getWidth()
    local ys = image:getHeight()
    local vertices = {
        {0, ys, 0, 1, 255, 255, 255},
        {xs, ys, 1, 1, 255, 255, 255},
        {xs, ys, 1, 1, 255, 255, 255},
        {0, ys, 0, 1, 255, 255, 255},
    }
    return love.graphics.newMesh(vertices, image, "fan")
end

-- dt needs to be value from 0 (started) to 1 (finished)
local function updateMesh(mesh, dt)
    local xs = mesh:getImage():getWidth()
    local ys = mesh:getImage():getHeight()
    local ts = ys * dt
    local vertices = {
        {0, ts, 0, dt, 255, 255, 255},
        {xs, ts, 1, dt, 255, 255, 255},
        {xs, ys, 1, 1, 255, 255, 255},
        {0, ys, 0, 1, 255, 255, 255},
    }
    mesh:setVertices(vertices)
end

---------------- OBJECTS --------------

OBJECT_ID = 1

Object = class()

Object.__name = "object"

function Object:__init(x, y)
    self.x = x
    self.y = y
    self.image = "default"
    self.icon = nil
    self.selectable = false
    self.ressources = nil
    self.resUsage = 0 -- res / second
    self.resUsageDt = 0 -- timer value for resUsage
    self.resShift = { } -- can be used to shift stockpile placement for individual ressources
    self.costleft = nil
    self.cost = nil
    self.workleft = -1
    self.xsize = 1
    self.ysize = 1
    self.xshift = 0
    self.yshift = 0
    self.id = OBJECT_ID
    OBJECT_ID = OBJECT_ID + 1
end

-- called whenever a worker worked a little bit on this object
function Object:work(dt)
    if self.workleft >= 0 then
        self.workleft = calculateWork(self.workleft, dt)
        
        -- use up res
        if self.resUsage > 0 then
            self.resUsageDt = self.resUsageDt + dt
            if self.resUsageDt >= self.resUsage then
                self.resUsageDt = 0
                if self.ressources then
                    if self.ressources.stone then 
                        self:removeRessource("stone")
                    elseif self.ressources.wood then
                        self:removeRessource("wood")
                    elseif self.ressources.planks then
                        self:removeRessource("planks")
                    end
                end
            end
        end
        
        if self.workleft < 0  then
            self.ressources = nil
            if server then server.sendBuildFinished(self) end
        end
        if love.graphics then
            updateMesh(self.mesh, math.max(0, self.workleft / self.workMax) )
        end
    end
end

function Object:removeRessource(res)
    if self.ressources and self.ressources[res] then
        self.ressources[res] = self.ressources[res] - 1
        if self.ressources[res] <= 0 then
            self.ressources[res] = nil
            if not (self.ressources.wood or self.ressources.stone or self.ressources.planks) then 
                self.ressources = nil
                if self:is(Ressource) and server then world.removeObject(self.id) end
            end
        end
    end
end

function Object:addRessource(res)
    if self.ressources == nil then self.ressources = {} end
    if self.ressources[res] == nil then
        self.ressources[res] = 0
    end
    self.ressources[res] = self.ressources[res] + 1
end

----------- Ressource

Ressource = Object:extends()

function Ressource:__init(x, y, restable)
    Ressource.super.__init(self, x, y)
    self.__name = "ressource"
    self.ressources = restable
    self.image = nil
    self.xsize = 1
    self.ysize = 1
end


------------ Placeables

-- a lonely barrel 
Chest = Object:extends()

function Chest:__init(x, y, bounty)
    Chest.super.__init(self, x, y)
    self.__name = "chest"
    self.bounty = bounty
    self.image = nil
    self.xsize = 1
    self.ysize = 1
end

-- field
Field = Object:extends()

function Field:__init(x, y)
    Field.super.__init(self, x, y)
    self.__name = "field"
    self.image = "field"
    self.xsize = 2
    self.ysize = 2
end

-- update field image
function Field:generateImage()
    local canvas = love.graphics.newCanvas(self.xsize * tilesize, self.ysize * tilesize)
    love.graphics.setCanvas(canvas)
    for i=1,self.xsize do
        for j=1,self.ysize do
            
            local nextImage = "fm"
            
            if i == 1 then
                if j == 1 then nextImage = "ful" end
                if j > 1 and i < self.ysize then nextImage = "fml" end
                if j == self.ysize then nextImage = "fdl" end
            end
            
            if i > 1 and i < self.xsize then
                if j == 1 then nextImage = "fu" end
                if j == self.ysize then nextImage = "fd" end
            end
            
            if i == self.xsize then
                if j == 1 then nextImage = "fur" end
                if j > 1 and j < self.ysize then nextImage = "fmr" end
                if j == self.ysize then nextImage = "fdr" end
            end
            
            love.graphics.draw(terrain[nextImage], (i - 1) * tilesize, (j - 1) * tilesize)
        end
    end
    love.graphics.setCanvas()
    self.image = canvas
end

----------- BUILDINGS

----------- TENT

Tent = Object:extends()

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

Smith = Object:extends()

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

Farm = Object:extends()

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

Warehouse = Object:extends()

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
----------- TREE

Tree = Object:extends()

Tree.__name = "tree"

function Tree:__init(x, y, tree_type)
    Tree.super.__init(self, x, y)
    self.selectable = true
    
    if not tree_type then tree_type = math.random(1, 3) end
    if tree_type == 3 then 
        self.__name = "tree_small"
        self.image = "tree_small"
        self.workleft = 5
        self.ysize = 1
        self.xsize = 1
        self.xshift = 0.5
        self.yshift = 0.3
    end
    if tree_type == 2 then
        self.__name = "tree_leaf"
        self.image = "tree_large1"
        self.workleft = 11
        self.ysize = 2
        self.xsize = 2
        self.xshift = 0.5
        self.yshift = -0.2
    end
    if tree_type == 1 then
        self.__name = "tree_needle"
        self.image = "tree_large2"
        self.workleft = 11
        self.ysize = 2
        self.xsize = 2
        self.xshift = 0.5
        self.yshift = -0.2
    end
end

function Tree:work(dt)
    
    local wnew = calculateWork(self.workleft, dt)
    
    if self.__name == "tree_small" and self.workleft >= 0 and wnew < 0 then
        self.image = nil
        if server then
            world.removeObject(self.id)
            world.addObject(Ressource:new(self.x, self.y, { wood=2 }))
        end
    end
    
    if not (self.__name == "tree_small") then
                
        if self.workleft > 6 and wnew <= 6 then
            
            self.image = "tree_stump1"
            self.xshift = -0.5
            self.yshift = 0.5
        end
        
        if self.workleft > 3 and wnew <= 3 then
            
            self.image = "tree_stump2"
            self.xshift = -0.5
            self.yshift = 0.5
        end

        if math.floor(self.workleft) % 2 == 0 and
                not (math.floor(wnew) == math.floor(self.workleft)) then
            if self.ressources == nil then self.ressources = { wood=0 } end
            self.ressources.wood = self.ressources.wood + 1
        end
        
        if self.workleft >= 0 and wnew < 0 then
            self.image = nil
            if server then
                world.removeObject(self.id)
                world.addObject(Ressource:new(self.x, self.y, {wood=6}))
            end
        end
        
    end
    
    self.workleft = wnew
end


