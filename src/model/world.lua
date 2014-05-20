
World = class()

World.__name = "world"

function World:__init()
    self.tiles = {}
    for i=1,20 do
        self.tiles[i] = {}
        for j=1,20 do
            self.tiles[i][j] = "grass"..math.random(1,4)
        end
    end
    self.objects = {}
    table.insert(self.objects, hut)
end