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