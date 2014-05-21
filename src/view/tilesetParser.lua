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
    
end
