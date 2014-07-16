--[[
    
    Handles creation of singleplayer game.
    
    Will be later used to load scenarios and campaigns
    
]]--


gameCreator = {}

-- current development game
function gameCreator.createDefaultLocalGame()
    ONLINE_GAME = false
    
    if not ONLINE_GAME then
        main_server = love.thread.newThread( "main_server.lua" )
        main_server:start()
    end
    
    math.randomseed(os.time())
    
    console = false -- while true display debug information
    
    tilesetParser.loadTerrain()
    tilesetParser.parseIcons()
    charsetParser.parseCharset()
    cameraHandler.init()
    hudHandler.init()
    logicHandler.init()
    drawHandler.init()
    world.init()
    
    client.init()
end