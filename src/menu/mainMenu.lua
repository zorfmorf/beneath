--[[
    
    Main Menu
    
]]--

local items = { 
                "Local",
                "Online",
                "Options",
                "Exit"
              }

local cursor = 1

mainMenu = {}

local scrollUpper = nil
local scrollMiddle = nil
local scrollLower = nil
local menuFont = love.graphics.newFont("ressource/ui/alagard.ttf", 40)
local titleFont = love.graphics.newFont("ressource/ui/romulus.ttf", 100)
local dtacc = 0

function mainMenu.init()
    local source = love.image.newImageData( "ressource/ui/ui.png" )
    
    local imgData = love.image.newImageData(tilesize * 6, tilesize * 2)
    imgData:paste(source, 0, 0, 11 * tilesize, 4 * tilesize, tilesize * 6, tilesize * 2)
    scrollUpper = love.graphics.newImage( imgData )
    
    imgData:paste(source, 0, 0, 11 * tilesize, 6 * tilesize, tilesize * 6, tilesize * 2)
    scrollMiddle = love.graphics.newImage( imgData )
    
    imgData:paste(source, 0, 0, 11 * tilesize, 8 * tilesize, tilesize * 6, tilesize * 2)
    scrollLower = love.graphics.newImage( imgData )
end

function mainMenu.goDown()
    dtacc = 0
    cursor = cursor + 1
    if cursor > #items then cursor = 1 end
end

function mainMenu.goUp()
    dtacc = 0
    cursor = cursor - 1
    if cursor < 1 then cursor = #items end
end

function mainMenu.fire()
    if cursor == 1 and not (state == "ingame") then
        gameCreator.createDefaultLocalGame()
        state = "ingame"
    end
    if cursor == 4 then love.event.push("quit") end
end


function mainMenu.update(dt)
    dtacc = dtacc + dt * 3
end


function mainMenu.draw()
    
    -- benath title
    local title = love.window.getTitle()
    love.graphics.setFont(titleFont)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(title, love.graphics:getWidth() / 2, titleFont:getHeight(), 0, 1, 1, titleFont:getWidth(title) / 2, titleFont:getHeight() / 2 )
    
    
    -- menu scroll
    local size = #items + 2
    local xshift = 75
    
    for i=1,size do
        
        local y = 100 + i * (32 * 2)
        love.graphics.setColor( 255, 255, 255, 255 )
        
        if i == 1 then love.graphics.draw(scrollUpper, xshift, y) end
        if i > 1 and i < size then 
            love.graphics.draw(scrollMiddle, xshift, y)
            love.graphics.setColor( 0, 0, 0, 255 )
            local scale = 1
            if cursor == i-1 then 
                love.graphics.setColor( 100, 0, 0, 255) 
                scale = 1.1 + math.sin(dtacc) * 0.02
            end
            love.graphics.setFont(menuFont)
            love.graphics.print( items[i-1], xshift + scrollMiddle:getWidth() / 2, y + 20 - i * 5, 0, scale, scale, menuFont:getWidth(items[i-1]) / 2 )
        end
        if i == size then love.graphics.draw(scrollLower, xshift, y) end
        
    end    
    
end
