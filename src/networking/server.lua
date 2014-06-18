-- server.lua
require "enet"

server = {}

local host = nil
local clients = nil

function server.init()
    host = enet.host_create"localhost:44631"
    clients = {}
end


function server.service()
    local event = host:service(0)
    while event do
        
        if event.type == "connect" then
            logfile:write( "Client connected:", event.peer:index(), event.peer:connect_id(), "\n" )
            server.sendInitialGameState(event.peer)
        end
        
        if event.type == "receive" then
            event.peer:send(event.data)
        end
        event = host:service(0)
    end
end


function server.insult()
    for i=1,host:peer_count() do
        local peer = host:get_peer(i)
        if peer and peer:state() == "connected" then
            peer:send("U WOT M8")
            logfile:write("Insult deployed\n")
        end
    end
end


function server.sendInitialGameState(peer)
    local tiles = ""
    for i,row in pairs(world.getTiles()) do
        for j,tile in pairs(row) do
            tiles = tiles..tile.texture
            if j < #row then tiles = tiles .. "," end
        end
        tiles = tiles..";"
    end
    peer:send("tiles "..tiles)
end