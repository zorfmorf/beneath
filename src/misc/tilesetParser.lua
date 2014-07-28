tilesize = 32

tilesetParser = {}


local function parseTile(image, x, y)
    local imgData = love.image.newImageData(tilesize, tilesize)
    imgData:paste(image, 0, 0, x * tilesize, y * tilesize, tilesize, tilesize)
    return love.graphics.newImage(imgData)
end


function tilesetParser.loadTerrain()
        
    terrain = {}
    local source = love.image.newImageData("ressource/terrain_atlas.png")
    
    -- grass textures
    terrain["g1"] = parseTile(source, 21, 5)
    terrain["g2"] = parseTile(source, 22, 5)
    terrain["g3"] = parseTile(source, 23, 5)
    terrain["g4"] = parseTile(source, 21, 11)
    terrain["g5"] = parseTile(source, 22, 11)
    terrain["g6"] = parseTile(source, 23, 11)
    
    -- dirt textures
    terrain["dul"] = parseTile(source, 3, 28)
    terrain["du"] = parseTile(source, 4, 28)
    terrain["dur"] = parseTile(source, 5, 28)
    terrain["dml"] = parseTile(source, 3, 29)
    terrain["dm"] = parseTile(source, 4, 29)
    terrain["dmr"] = parseTile(source, 5, 29)
    terrain["ddl"] = parseTile(source, 3, 30)
    terrain["dd"] = parseTile(source, 4, 30)
    terrain["ddr"] = parseTile(source, 5, 30)
    
    -- stone overlay textures
    terrain["o"] = parseTile(source, 1, 1)
    terrain["o_u"] = parseTile(source, 1, 2)
    terrain["o_ul"] = parseTile(source, 4, 1)
    terrain["o_ur"] = parseTile(source, 3, 1)
    terrain["o_l"] = parseTile(source, 0, 1)
    terrain["o_r"] = parseTile(source, 2, 1)
    terrain["o_d"] = parseTile(source, 1, 0)
    terrain["o_dl"] = parseTile(source, 4, 0)
    terrain["o_dr"] = parseTile(source, 3, 0)
    terrain["o_bkg_mid"] = parseTile(source, 1, 3)
    terrain["o_bkg_low"] = parseTile(source, 1, 4)
    
    -- field textures
    terrain["ful"] = parseTile(source, 5, 17)
    terrain["fu"] = parseTile(source, 6, 17)
    terrain["fur"] = parseTile(source, 7, 17)
    terrain["fml"] = parseTile(source, 5, 18)
    terrain["fm"] = parseTile(source, 6, 18)
    terrain["fmr"] = parseTile(source, 7, 18)
    terrain["fdl"] = parseTile(source, 5, 19)
    terrain["fd"] = parseTile(source, 6, 19)
    terrain["fdr"] = parseTile(source, 7, 19)
    
    -- columns
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
    
    -- field
    objects["field"] = terrain["fm"]
    
    -- buildings
    source = love.image.newImageData("ressource/terrain_atlas2.png")
    
    -- tent
    imgData = love.image.newImageData(tilesize * 4, tilesize * 5)
    imgData:paste(source, 0, 0, 13 * tilesize, 16 * tilesize, tilesize * 4, tilesize * 5)
    objects["tent"] = love.graphics.newImage(imgData)
    
    -- prepared buildings
    objects["smith"] = love.graphics.newImage("ressource/smith1.png")
    objects["farm"] = love.graphics.newImage("ressource/farm1.png")
    objects["warehouse"] = love.graphics.newImage("ressource/warehouse.png")
    objects["carpenter"] = love.graphics.newImage("ressource/carpenter.png")
    objects["hole"] = love.graphics.newImage("ressource/hole.png")
    
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
    
    source = love.image.newImageData("ressource/stone.png")
    imgData = love.image.newImageData(tilesize * 1, tilesize * 1)
    
    imgData:paste(source, 0, 0, 0 * tilesize, 0 * tilesize, tilesize * 1, tilesize * 1)
    objects["stone1"] = love.graphics.newImage(imgData)
    imgData:paste(source, 0, 0, 0 * tilesize, 1 * tilesize, tilesize * 1, tilesize * 1)
    objects["stone2"] = love.graphics.newImage(imgData)
    imgData:paste(source, 0, 0, 0 * tilesize, 2 * tilesize, tilesize * 1, tilesize * 1)
    objects["stone3"] = love.graphics.newImage(imgData)
    
    imgData = love.image.newImageData(tilesize * 1, tilesize * 2)
    imgData:paste(source, 0, 0, 0 * tilesize, 3 * tilesize, tilesize * 1, tilesize * 2)
    objects["stone4"] = love.graphics.newImage(imgData)
    imgData:paste(source, 0, 0, 0 * tilesize, 5 * tilesize, tilesize * 1, tilesize * 2)
    objects["stone5"] = love.graphics.newImage(imgData)
    imgData:paste(source, 0, 0, 0 * tilesize, 7 * tilesize, tilesize * 1, tilesize * 2)
    objects["stone6"] = love.graphics.newImage(imgData)
    
    
    source = love.image.newImageData("ressource/planks.png")
    imgData = love.image.newImageData(tilesize * 1, tilesize * 1)
    
    imgData:paste(source, 0, 0, 0 * tilesize, 0 * tilesize, tilesize * 1, tilesize * 1)
    objects["planks1"] = love.graphics.newImage(imgData)
    imgData:paste(source, 0, 0, 0 * tilesize, 1 * tilesize, tilesize * 1, tilesize * 1)
    objects["planks2"] = love.graphics.newImage(imgData)
    imgData:paste(source, 0, 0, 0 * tilesize, 2 * tilesize, tilesize * 1, tilesize * 1)
    objects["planks3"] = love.graphics.newImage(imgData)
    
    imgData = love.image.newImageData(tilesize * 1, tilesize * 2)
    imgData:paste(source, 0, 0, 0 * tilesize, 3 * tilesize, tilesize * 1, tilesize * 2)
    objects["planks4"] = love.graphics.newImage(imgData)
    imgData:paste(source, 0, 0, 0 * tilesize, 5 * tilesize, tilesize * 1, tilesize * 2)
    objects["planks5"] = love.graphics.newImage(imgData)
    imgData:paste(source, 0, 0, 0 * tilesize, 7 * tilesize, tilesize * 1, tilesize * 2)
    objects["planks6"] = love.graphics.newImage(imgData)
    
end

function tilesetParser.parseIcons()
    icons = {}
    icons["axe"] = love.graphics.newImage("ressource/icons/axe-in-stump.png")
end
