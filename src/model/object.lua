
OBJECT_ID = 1

Object = class()

Object.__name = "object"

function Object:__init(x, y)
    self.x = x
    self.y = y
    self.image = "default"
    
    self.xsize = 1.5
    self.ysize = 1.5
    
    self.id = OBJECT_ID
    OBJECT_ID = OBJECT_ID + 1
end

Tree = Object:extends()

Tree.__name = "name"

function Tree:__init(x, y)
    Tree.super.__init(self, x, y)
    
    local tree_type = math.random(1, 3)
    if tree_type == 3 then
        self.image = "tree_small"
        self.ysize = 0.5
        self.xsize = 0.5
    end
    if tree_type == 2 then
        self.image = "tree_large"
        self.ysize = 0.7
        self.xsize = 1
    end
    if tree_type == 1 then
        self.image = "tree_leaf"
        self.ysize = 1
        self.xsize = 2
    end
end


