
OBJECT_ID = 1

Object = class()

Object.__name = "object"

function Object:__init(x, y)
    self.x = x
    self.y = y
    self.image = "default"
    
    self.xsize = 2
    self.ysize = 2
    
    self.id = OBJECT_ID
    OBJECT_ID = OBJECT_ID + 1
end