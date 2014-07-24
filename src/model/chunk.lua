--[[
    
    Each chunk represents a stack of rectangular layers.
    
]]--

CHUNK_WIDTH = 16 -- tile width of the rectangular area
CHUNK_HEIGHT = 1 -- the amount of possible layers for each chunk

Chunk = class()
Chunk.__name = "chunk"

function Chunk:__init()
    self.canvas = {}
    self.layers = {}
    for i=1,CHUNK_HEIGHT do
        
        self.layers[i] = {}
        self.layers[i].tiles = {}
        
        for j=1,CHUNK_WIDTH do
            
            self.layers[i].tiles[j] = {}
            
            for k=1,CHUNK_WIDTH do
                
                self.layers[i].tiles[j][k] = { texture = "g"..math.random(1,3), overlays = nil, object = nil }
                if math.random(1, 14) == 10 then self.layers[i].tiles[i][j].texture = "g"..math.random(4,6) end
                
            end
            
        end
        
        self:update(i)
        
    end
end


-- generate canvas for specified layer
function Chunk:update(layer)
    
    if not server then
        
        local canvas = love.graphics.newCanvas(CHUNK_WIDTH * tilesize, CHUNK_WIDTH * tilesize)
        love.graphics.setCanvas(canvas)
        
        for y,row in pairs(self.layers[layer].tiles) do
            
            for x,tile in pairs(row) do
                
                love.graphics.draw(terrain[tile.texture], (x - 1) * tilesize, (y - 1) * tilesize)
                
                if tile.overlays then
                    for i,texture in ipairs(tile.overlays) do
                        love.graphics.draw(terrain[texture], (x - 1) * tilesize, (y - 1) * tilesize)
                    end
                end
                
            end
            
        end
        
        love.graphics.setCanvas()
        self.canvas[layer] = canvas
        
    end
    
end


function Chunk:getCanvas(layer)
    return self.canvas[layer]
end


function Chunk:getTile(l, x, y)
    if self.layers[layer] and self.layers[layer].tiles 
                          and self.layers[layer].tiles[y]
                          and self.layers[layer].tiles[y][x] then
        return self.layers[layer].tiles[y][x]
    end
    return nil
end


function Chunk:getTiles(layer)
    if self.layers[layer] and self.layers[layer].tiles then
        return self.layers[layer].tiles
    end
    return nil
end


function Chunk:freeTile()
    
end
