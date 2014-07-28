--[[
    
    Each chunk represents a stack of rectangular layers.
    
]]--

CHUNK_WIDTH = 16 -- tile width of the rectangular area
CHUNK_HEIGHT = 9 -- the amount of possible layers for each chunk
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


local function generateBorderTexture(l, x, y)
    
    local tile = world.getTile(l, x, y+1)
    if tile and tile.clear then return "o_u" end
    
    tile = world.getTile(l, x+1, y+1)
    if tile and tile.clear then return "o_ul" end
    
    tile = world.getTile(l, x-1, y+1)
    if tile and tile.clear then return "o_ur" end
    
    tile = world.getTile(l, x-1, y)
    if tile and tile.clear then return "o_l" end
    
    tile = world.getTile(l, x+1, y)
    if tile and tile.clear then return "o_r" end
    
    tile = world.getTile(l, x, y-1)
    if tile and tile.clear then return "o_d" end
    
    tile = world.getTile(l, x+1, y-1)
    if tile and tile.clear then return "o_dl" end
    
    tile = world.getTile(l, x-1, y-1)
    if tile and tile.clear then return "o_dr" end
        
    return nil
end


-- generate canvas for specified layer
function Chunk:update(layer)
    
    if not server then
        
        local canvas = love.graphics.newCanvas(CHUNK_WIDTH * tilesize, (CHUNK_WIDTH + 2) * tilesize)
        love.graphics.setCanvas(canvas)
        
        -- first pass: draw tiles
        for y,row in pairs(self.layers[layer].tiles) do
            for x,tile in pairs(row) do
                
                love.graphics.draw(terrain[tile.texture], x * tilesize, (y+2) * tilesize)
                
                if tile.overlays then
                    for i,texture in ipairs(tile.overlays) do
                        love.graphics.draw(terrain[texture], x * tilesize, (y+2) * tilesize)
                    end
                end
                
            end
        end
        
        -- second pass: draw stone overlay for lower levels
        if layer < CHUNK_HEIGHT then
            for y=0,CHUNK_WIDTH-1 do
                for x=0,CHUNK_WIDTH-1 do
                    local texture = "o"
                    
                    if self.x and self.y then
                        
                        local cx = (self.x - 1) * CHUNK_WIDTH + x
                        local cy = (self.y - 1) * CHUNK_WIDTH + y
                        
                        if self.layers[layer].tiles[y][x].clear then 
                            texture = nil
                            
                            local tile = world.getTile(layer, cx, cy-1)
                            if tile then
                                if not tile.clear then
                                    texture = "o_bkg_mid"
                                else
                                    tile = world.getTile(layer, cx, cy-2)
                                    if tile and not tile.clear then
                                        texture = "o_bkg_low"
                                    end
                                end
                            end
                        else
                            local result = generateBorderTexture(layer, cx, cy)
                            if result then texture = result end
                        end
                        
                    end
                    
                    if texture then love.graphics.draw(terrain[texture], x * tilesize, y * tilesize) end
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
