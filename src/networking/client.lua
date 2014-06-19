-- client.lua
require "enet"

client = {}

local host = nil
local server = nil

function client.init()
    host = enet.host_create()
    server = host:connect("localhost:44631")
    print(" Client connected:", server )
end

function client.service()
    local event = host:service(0)
    if event then
        
        if event.type == "connect" then
            
            print("Connected to", event.peer)
            
        elseif event.type == "receive" then
            
            if event.data:sub(1, 6) == "tiles " then
                
                print( "Received tile data" )
                world.updateTiles( event.data:sub(7) )
                
            elseif event.data:sub(1, 6) == "plobj " then
                
                print( "Received object data" )
                client.parseObjects( event.data:sub(7) )
                
            elseif event.data:sub(1, 6) == "chars " then
                
                print( "Received char data" )
                client.parseChars( event.data:sub(7) )
                
            else
                
                print("Got message: ", event.data, event.peer)
                
            end
            
        end
    end
end


-- send build wish
function client.sendBuild(build)
    server:send("build "..build.__name..","..(-1)..","..build.x..","..build.y)
end


-- Parse all chars received by server. TODO: catch errors
function client.parseChars(string)
    for i,char in pairs(parser.parseChars(string)) do
        world.addChar(char)
    end
end


-- Parse all received objects. TODO: catch errors
function client.parseObjects(string)
    for i,object in pairs(parser.parseObjects(string)) do
        world.addObject(object)
    end
end

function client.disconnect()
    server:disconnect()
    host:flush()
    server = nil
    host = nil
    print(" Client shut down" )
end