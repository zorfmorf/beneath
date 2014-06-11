
OBJECT_ID = 1

Object = class()

Object.__name = "object"

function Object:__init(x, y)
    self.x = x
    self.y = y
    self.image = "default"
    self.selected = false
    self.ressources = nil
    self.workleft = -1
    self.xsize = 2
    self.ysize = 1.5
    self.xshift = 0
    self.yshift = 0
    self.id = OBJECT_ID
    OBJECT_ID = OBJECT_ID + 1
end

-- called whenever a worker worked a little bit on this object
function Object:work(dt)
    -- do nothing
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


----------- BUILDINGS

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

----------- TENT

Tent = Object:extends()

function Tent:__init(x, y)
    Tent.super.__init(self, x, y)
    self.__name = "tent"
    self.image = "tent"
    self.xsize = 4
    self.ysize = 3
    self.mesh = generateMesh(objects[self.image])
    self.workMax = 10
    self.workleft = 10
end

function Tent:work(dt)
    self.workleft = self.workleft - dt
    updateMesh(self.mesh, self.workleft / self.workMax)
end

----------- TREE

Tree = Object:extends()

Tree.__name = "tree"

function Tree:__init(x, y, tree_type)
    Tree.super.__init(self, x, y)
    
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
    
    local wnew = self.workleft - dt
    
    if self.__name == "tree_small" and self.workleft > 0 and wnew <= 0 then
        self.image = nil
        self.ressources = { wood=2 }
    end
    
    if not (self.__name == "tree_small") then
        
        if math.floor(self.workleft) % 2 == 0 and
            not (math.floor(wnew) == math.floor(self.workleft)) then
            if self.ressources == nil then self.ressources = { wood=0 } end
            self.ressources.wood = self.ressources.wood + 1
        end
        
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
        
        if self.workleft > 0 and wnew <= 0 then
            self.image = nil
            world.removeObject(self.id)
            world.addObject(Ressource:new(self.x, self.y, self.ressources))
        end
    end
    
    self.workleft = wnew
end


