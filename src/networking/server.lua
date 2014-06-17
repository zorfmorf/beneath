-- server.lua
require "enet"

server = {}

local host = nil
local insult = false -- TODO REMOVE

function server.init()
    host = enet.host_create"localhost:44631"
    print("host state:", host)
end


function server.service()
    local event = host:service(0)
    while event do
        if event.type == "receive" then
            print("Got message: ", event.data, event.peer)
            event.peer:send(event.data)
            if insult then
                event.peer:send("U WOT M8")
                insult = false
            end
        end
        event = host:service(0)
    end
end


function server.insult()
    insult = true
end