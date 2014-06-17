-- client.lua
require "enet"

client = {}

local host = nil
local server = nil

function client.init()
    host = enet.host_create()
    server = host:connect("localhost:44631")
end

function client.service()
    local event = host:service(100)
    if event then
        if event.type == "connect" then
            print("Connected to", event.peer)
            event.peer:send("hello world")
        elseif event.type == "receive" then
            print("Got message: ", event.data, event.peer)
        end
    end
end

function client.disconnect()
    server:disconnect()
    host:flush()
    server = nil
    host = nil
    print(" Client shut down" )
end