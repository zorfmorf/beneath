
OBJECT_ID = 1

Object = class()

Object.__name = "object"

function Object:__init(x, y)
    self.x = x
    self.y = y
    self.image = "default"
    self.selected = false
    self.workleft = 0
    self.xsize = 2
    self.ysize = 1.5
    self.xshift = 0
    self.yshift = 0
    self.id = OBJECT_ID
    OBJECT_ID = OBJECT_ID + 1
end

-- called whenever a worker worked a little bit on this object
function Object:work()
    -- do nothing
end


----------- TENT

Tent = Object:extends()

function Tent:__init(x, y)
    Tent.super.__init(self, x, y)
    self.__name = "tent"
    self.image = "tent"
    self.xsize = 4
    self.ysize = 3
end

----------- TREE

Tree = Object:extends()

Tree.__name = "tree"

function Tree:__init(x, y, tree_type)
    Tree.super.__init(self, x, y)
    self.workleft = 5
    
    if not tree_type then tree_type = math.random(1, 3) end
    if tree_type == 3 then 
        self.__name = "tree_small"
        self.image = "tree_small"
        self.ysize = 1
        self.xsize = 1
        self.xshift = 0.5
        self.yshift = 0.3
    end
    if tree_type == 2 then
        self.__name = "tree_large"
        self.image = "tree_large"
        self.ysize = 1
        self.xsize = 2
    end
    if tree_type == 1 then
        self.__name = "tree_leaf"
        self.image = "tree_leaf"
        self.ysize = 1
        self.xsize = 2
        self.xshift = 0.5
        self.yshift = 0
    end
end

function Tree:work()
    if self.workleft < 0 then
        world.removeObject(self.id)
    end
end


