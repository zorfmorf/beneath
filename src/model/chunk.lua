--[[
    
    Each chunk represents a stack of rectangular layers.
    
]]--

CHUNK_WIDTH = 16 -- tile width of the rectangular area
CHUNK_HEIGHT = 1 -- the amount of possible layers for each chunk
CHUNK_ID = 1 -- unique for every chunk

Chunk = class()
Chunk.__name = "chunk"

function Chunk:__init()
    
    self.canvas = {}
    self.layers = {}
    self.id = CHUNK_ID
    CHUNK_ID = CHUNK_ID + 1
    
    for i=1,CHUNK_HEIGHT do
        self.layers[i] = {}
        self.layers[i].tiles = nil
    end
    
end

function Chunk:setTiles(layer, tiles)
    if layer > 9 then print("Error: Invalid layer height: ", layer) end
    self.layers[layer].tiles = tiles
    self:update(layer)
end


-- generate canvas for specified layer
function Chunk:update(layer)
    
    if not server then
        
        local canvas = love.graphics.newCanvas(CHUNK_WIDTH * tilesize, CHUNK_WIDTH * tilesize)
        love.graphics.setCanvas(canvas)
        
        for y,row in pairs(self.layers[layer].tiles) do
            
            for x,tile in pairs(row) do
                
                love.graphics.draw(terrain[tile.texture], x * tilesize, y * tilesize)
                
                if tile.overlays then
                    for i,texture in ipairs(tile.overlays) do
                        love.graphics.draw(terrain[texture], x * tilesize, y * tilesize)
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
    if self.layers[l] and self.layers[l].tiles 
                          and self.layers[l].tiles[y]
                          and self.layers[l].tiles[y][x] then
        return self.layers[l].tiles[y][x]
    end
    return nil
end


function Chunk:getTiles(layer)
    if self.layers[layer] and self.layers[layer].tiles then
        return self.layers[layer].tiles
    end
    return nil
end


function Chunk:getHeight()
    return #self.layers
end


function Chunk:freeTile()
    
end
