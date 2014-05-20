
World = class()

World.__name = "world"

function World:__init()
    self.tiles = {}
    for i=1,20 do
        self.tiles[i] = {}
        for j=1,20 do
            self.tiles[i][j] = { texture = "grass"..math.random(1,4), object = nil }
        end
    end
    self.objects = {}
    table.insert(self.objects, Object:new())
end