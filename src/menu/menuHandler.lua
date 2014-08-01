--[[
    
    The MenuHandler keeps track of all available
    menus and decides when to switch between them?
    
]]--

local titleFont = love.graphics.newFont("ressource/ui/romulus.ttf", 100)
local menus = nil
local current = nil

menuHandler = {}

function menuHandler.init()
    menus = {}
    menus.main = MainMenu:new()
    menus.online = OnlineMenu:new()
    current = "main"
end


function menuHandler.switchToMenu(name)
    if menus[name] then
        current = name
    else
        print( "Can not find menu:", name)
    end
end


function menuHandler.update(dt)
    menus[current]:update(dt)
end


-- currently only draws game title
function menuHandler.draw()
    local title = love.window.getTitle()
    love.graphics.setFont(titleFont)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(title, love.graphics:getWidth() / 2, titleFont:getHeight(), 0, 1, 1, titleFont:getWidth(title) / 2, titleFont:getHeight() / 2 )
    
    menus[current]:draw()
end


-- keypress callback
function menuHandler.keypressed(key, isRepeat)
    if key == "return" then
        menus[current]:fire()
    end
    if key == "up" then
        menus[current]:up()
    end
    if key == "down" then
        menus[current]:down()
    end
    if key == "escape" then
        if displayMenu then 
            displayMenu = false
        else
            love.event.push("quit")
        end
    end
end


function menuHandler.keyreleased(key, isRepeat)
    
end


function menuHandler.mousereleased(x, y, button)
    
end


function menuHandler.mousepressed(x, y, button)
    
end
