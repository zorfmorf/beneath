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
    
end
