
World = class()

World.__name = "world"

function World:__init()
    self.tiles = {}
    for i=1,20 do
        self.tiles[i] = {}
        for j=1,20 do
            self.tiles[i][j] = { texture = "grass"..math.random(1,3), object = nil }
        end
    end
    self.objects = {}
end

function World:getTile(tx, ty)
    
    local x = math.floor(tx)
    local y = math.floor(ty)
    
    if self.tiles[y] ~= nil and self.tiles[y][x] ~= nil then
        return self.tiles[y][x]
    end
    return nil
    
end