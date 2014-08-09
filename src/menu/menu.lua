--[[
    
    A Menu represents a list of items displayed to the player.
    The unified interface allows the menuHandler to treat all
    menus the same.
    
]]--

-- load all visual components required for a menu

local scrollUpper = nil
local scrollMiddle = nil
local scrollLower = nil
local menuFont = love.graphics.newFont("ressource/ui/alagard.ttf", 40)

local function loadImages()
    local source = love.image.newImageData( "ressource/ui/ui.png" )
    
    local imgData = love.image.newImageData(tilesize * 6, tilesize * 2)
    imgData:paste(source, 0, 0, 11 * tilesize, 4 * tilesize, tilesize * 6, tilesize * 2)
    scrollUpper = love.graphics.newImage( imgData )
    
    imgData:paste(source, 0, 0, 11 * tilesize, 6 * tilesize, tilesize * 6, tilesize * 2)
    scrollMiddle = love.graphics.newImage( imgData )
    
    imgData:paste(source, 0, 0, 11 * tilesize, 8 * tilesize, tilesize * 6, tilesize * 2)
    scrollLower = love.graphics.newImage( imgData )
end

loadImages() -- we only need to load these once

-- Menu class definitions

Menu = class()

Menu.__name = "menu"

function Menu:__init()
    self.dtacc = 0 -- accumulates dt values
    self.cursor = 1
    self.items = {}
end


-- execute currently selected item.
function Menu:fire()
    local item = self.items[self.cursor]
    if item then
        self:handle(item)
    end
end


-- Go up one menu entry. Loops.
function Menu:up()
    self.cursor = self.cursor - 1
    if self.cursor < 1 then self.cursor = #self.items end
end


-- Go down one menu entry. Loops.
function Menu:down()
    self.cursor = self.cursor + 1
    if self.cursor > #self.items then self.cursor = 1 end
end


-- Used for things like pulsing labels
function Menu:update(dt)
    self.dtacc = self.dtacc + dt * 3
end


-- Draws the menu to screen.
function Menu:draw()
    -- menu scroll
    local size = #self.items + 2
    local xshift = 75
    
    for i=1,size do
        
        local y = 100 + i * (32 * 2)
        love.graphics.setColor( 255, 255, 255, 255 )
        
        if i == 1 then love.graphics.draw(scrollUpper, xshift, y) end
        if self.items[i-1] then 
            love.graphics.draw(scrollMiddle, xshift, y)
            love.graphics.setColor( 0, 0, 0, 255 )
            local scale = 1
            if self.cursor == i-1 then 
                love.graphics.setColor( 100, 0, 0, 255) 
                scale = 1.1 + math.sin(self.dtacc) * 0.02
            end
            love.graphics.setFont(menuFont)
            love.graphics.print( self.items[i-1], xshift + scrollMiddle:getWidth() / 2, y + 20 - i * 5, 0, scale, scale, menuFont:getWidth(self.items[i-1]) / 2 )
        end
        if i == size then love.graphics.draw(scrollLower, xshift, y) end
        
    end    
end

---------- Specific menu definitions -----
MainMenu = Menu:extends()

MainMenu.__name = "mainmenu"

function MainMenu:__init()
    MainMenu.super.__init(self)
    self.items = { 
                "Local",
                "Online",
                "Options",
                "Exit"
              }
end

function MainMenu:handle(item)
    
    if not (state == "ingame") then
        
            if item == "Local" then
                gameCreator.createDefaultLocalGame()
                state = "ingame"
            end
            
            if item == "Online" then
                menuHandler.switchToMenu("online")
            end
            
        end
        
    if item == "Exit" then love.event.push("quit") end
end

OnlineMenu = Menu:extends()
OnlineMenu.__name = "onlinemenu"

function OnlineMenu:__init()
    MainMenu.super.__init(self)
    self.items = { 
                "Create",
                "Connect",
                "Back"
              }
end

function OnlineMenu:handle(item)
    if item == "Create" then
        gameCreator.createOnlineGame()
        state = "lobby"
    end
    if item == "connect" then
        
    end
    if item == "Back" then
        menuHandler.switchToMenu("main")
    end
end
