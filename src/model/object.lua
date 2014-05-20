
Object = class()

Object.__name = "object"

function Object:__init(x, y)
    self.x = x
    self.y = y
    self.image = "default"
end