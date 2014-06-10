tilesize = 32

tilesetParser = {}


local function parseTile(image, x, y)
    local imgData = love.image.newImageData(tilesize, tilesize)
    imgData:paste(image, 0, 0, x * tilesize, y * tilesize, tilesize, tilesize)
    return love.graphics.newImage(imgData)
end


function tilesetParser.loadTerrain()
        
    terrain = {}
    local source = love.image.newImageData("ressource/terrain.png")
    terrain["grass1"] = parseTile(source, 0, 11)
    terrain["grass2"] = parseTile(source, 1, 11)
    terrain["grass3"] = parseTile(source, 2, 11)
    terrain["grass4"] = parseTile(source, 3, 11)
    
    source = love.image.newImageData("ressource/terrain_atlas.png")
    terrain["col_bot1"] = parseTile(source, 14, 14)
    terrain["col_bot2"] = parseTile(source, 20, 14)
    terrain["col_bot3"] = parseTile(source, 19, 17)
    terrain["col_top1"] = parseTile(source, 14, 12)
    terrain["col_mid1"] = parseTile(source, 14, 13)
    terrain["col_mid2"] = parseTile(source, 17, 14)
    terrain["col_mid3"] = parseTile(source, 19, 16)
    terrain["col_mid4"] = parseTile(source, 20, 16)
    terrain["col_mid5"] = parseTile(source, 20, 13)
    terrain["stone1"] = parseTile(source, 25, 9)
    terrain["stone2"] = parseTile(source, 24, 11)
    terrain["stone3"] = parseTile(source, 25, 11)
    terrain["stone4"] = parseTile(source, 26, 11)
    
    objects = {}
    local imgData = love.image.newImageData(tilesize * 2, tilesize * 3)
    imgData:paste(source, 0, 0, 15 * tilesize, 12 * tilesize, tilesize * 3, tilesize * 3)
    objects["default"] = love.graphics.newImage(imgData)
    
    -- large tree
    imgData = love.image.newImageData(tilesize * 2, tilesize * 5)
    imgData:paste(source, 0, 0, 30 * tilesize, 0 * tilesize, tilesize * 2, tilesize * 5)
    objects["tree_large"] = love.graphics.newImage(imgData)
    
    -- small tree
    imgData = love.image.newImageData(tilesize * 2, tilesize * 3)
    imgData:paste(source, 0, 0, 27 * tilesize, 29 * tilesize, tilesize * 2, tilesize * 3)
    objects["tree_small"] = love.graphics.newImage(imgData)
    
    -- large tree leaf
    imgData = love.image.newImageData(tilesize * 3, tilesize * 4)
    imgData:paste(source, 0, 0, 24 * tilesize, 12 * tilesize, tilesize * 3, tilesize * 4)
    objects["tree_large1"] = love.graphics.newImage(imgData)
    
    -- large tree needle
    imgData = love.image.newImageData(tilesize * 3, tilesize * 5)
    imgData:paste(source, 0, 0, 27 * tilesize, 15 * tilesize, tilesize * 3, tilesize * 5)
    objects["tree_large2"] = love.graphics.newImage(imgData)
    
    -- large tree stump
    imgData = love.image.newImageData(tilesize * 1, tilesize * 2)
    imgData:paste(source, 0, 0, 25 * tilesize, 17 * tilesize, tilesize * 1, tilesize * 2)
    objects["tree_stump1"] = love.graphics.newImage(imgData)
    
    -- small tree stump
    imgData = love.image.newImageData(tilesize * 1, tilesize * 1)
    imgData:paste(source, 0, 0, 23 * tilesize, 18 * tilesize, tilesize * 1, tilesize * 1)
    objects["tree_stump2"] = love.graphics.newImage(imgData)
    
    -- buildings
    source = love.image.newImageData("ressource/terrain_atlas2.png")
    
    -- tent
    imgData = love.image.newImageData(tilesize * 4, tilesize * 5)
    imgData:paste(source, 0, 0, 13 * tilesize, 16 * tilesize, tilesize * 4, tilesize * 5)
    objects["tent"] = love.graphics.newImage(imgData)
    
    
    -- ressources
    source = love.image.newImageData("ressource/terrain_atlas3.png")
    imgData = love.image.newImageData(tilesize * 1, tilesize * 1)
    
    imgData:paste(source, 0, 0, 5 * tilesize, 11 * tilesize, tilesize * 1, tilesize * 1)
    objects["wood1"] = love.graphics.newImage(imgData)
    imgData:paste(source, 0, 0, 4 * tilesize, 11 * tilesize, tilesize * 1, tilesize * 1)
    objects["wood2"] = love.graphics.newImage(imgData)
    imgData:paste(source, 0, 0, 5 * tilesize, 12 * tilesize, tilesize * 1, tilesize * 1)
    objects["wood3"] = love.graphics.newImage(imgData)
    imgData:paste(source, 0, 0, 4 * tilesize, 12 * tilesize, tilesize * 1, tilesize * 1)
    objects["wood4"] = love.graphics.newImage(imgData)
    imgData:paste(source, 0, 0, 3 * tilesize, 12 * tilesize, tilesize * 1, tilesize * 1)
    objects["wood5"] = love.graphics.newImage(imgData)
    imgData:paste(source, 0, 0, 3 * tilesize, 11 * tilesize, tilesize * 1, tilesize * 1)
    objects["wood6"] = love.graphics.newImage(imgData)
    
end
