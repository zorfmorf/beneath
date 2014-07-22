--[[
    
    Handles creation of singleplayer games.
    
    Will be later used to load scenarios and campaigns
    
]]--


gameCreator = {}

-- current development game
function gameCreator.createDefaultLocalGame()
    
    main_server = love.thread.newThread( "main_server.lua" )
    main_server:start( "offline" )
    
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

-- create a online game. should display as a lobby
function gameCreator.createOnlineGame()
    
    main_server = love.thread.newThread( "main_server.lua" )
    main_server:start( "online" )
    
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
