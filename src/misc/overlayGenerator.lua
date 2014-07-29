--[[
    
    A set of helper method that generates overlays for chunks
    
]]--

overlayGenerator = {}

function overlayGenerator.generateDirt(object)
    
    local chunksToUpdate = {}
    
    for l=1,object.xsize+2 do
        for m=1,object.ysize do
            local tile = world.getTile(object.l, object.x + l - 2, object.y - m + 1)
                    
            local toadd = nil
            
            if l == 1 then
                if m == 1 then toadd = "ddl" end
                if m > 1 and m < object.ysize then toadd = "dml" end
                if m == object.ysize then toadd = "dul" end
            end
            
            if l > 1 and l < object.xsize+2 then
                if m == 1 then toadd = "dd" end
                if m > 1 and m < object.ysize then toadd = "dm" end
                if m == object.ysize then toadd = "du" end
            end
            
            if l == object.xsize+2 then
                if m == 1 then toadd = "ddr" end
                if m > 1 and m < object.ysize then toadd = "dmr" end
                if m == object.ysize then toadd = "dur" end
            end
            
            if toadd then
                if not tile.overlays then tile.overlays = { } end
                table.insert(tile.overlays, toadd)
                
                local chunk = world.getChunkByCoordinates(object.x + l - 2, object.y - m + 1)
                if chunk then chunksToUpdate[chunk.id] = chunk end
            end
        end
    end   
    
    return chunksToUpdate
end

local function generateBorderTexture(l, x, y)
    
    local tile = world.getTile(l, x, y-1)
    if tile and not tile.clear then
        tile = world.getTile(l, x-1, y)
        if tile and not tile.clear then return "o_ul" end
        tile = world.getTile(l, x+1, y)
        if tile and not tile.clear then return "o_ur" end
        return "o_u" 
    end
    
    tile = world.getTile(l, x, y+1)
    if tile and not tile.clear then
        tile = world.getTile(l, x-1, y)
        if tile and not tile.clear then return "o_dl" end
        tile = world.getTile(l, x+1, y)
        if tile and not tile.clear then return "o_dr" end
        return "o_d"
    end
    
    tile = world.getTile(l, x+1, y)
    if tile and tile.clear then
        tile = world.getTile(l, x+1, y+1)
        if tile and not tile.clear then return "o_e_dr" end
        tile = world.getTile(l, x+1, y-1)
        if tile and not tile.clear then return "o_e_or" end
    end
    
    tile = world.getTile(l, x-1, y)
    if tile and tile.clear then
        tile = world.getTile(l, x-1, y+1)
        if tile and not tile.clear then return "o_e_dl" end
        tile = world.getTile(l, x-1, y-1)
        if tile and not tile.clear then return "o_e_ol" end
    end
        
    tile = world.getTile(l, x-1, y)
    if tile and not tile.clear then return "o_l" end
    
    tile = world.getTile(l, x+1, y)
    if tile and not tile.clear then return "o_r" end
        
    return nil
end

function overlayGenerator.generateOverlay(chunk, layer)
    if layer < CHUNK_HEIGHT then
        for y=0,CHUNK_WIDTH-1 do
            for x=0,CHUNK_WIDTH-1 do
                local texture = "o"
                
                if chunk.x and chunk.y then
                    
                    local cx = (chunk.x - 1) * CHUNK_WIDTH + x
                    local cy = (chunk.y - 1) * CHUNK_WIDTH + y
                    
                    if chunk.layers[layer].tiles[y][x].clear then 
                        texture = nil
                        
                        local result = generateBorderTexture(layer, cx, cy)
                        if result then 
                            texture = result
                        else
                            local tile = world.getTile(layer, cx, cy-1)
                            if tile then
                                if not tile.clear then
                                    --texture = "o_bkg_mid"
                                else
                                    tile = world.getTile(layer, cx, cy-2)
                                    if tile and not tile.clear then
                                        --texture = "o_bkg_low"
                                    end
                                end
                            end
                        end
                    end
                    
                end
                
                chunk.layers[layer].tiles[y][x].overlays = { texture }
            end
        end
    end
end