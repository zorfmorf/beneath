--[[
    
    Handles network communcation to local or remote server
    
]]--

require "enet"

client = {}

local host = nil
local server = nil
local host_id = "localhost:44631"

function client.init()
    if ONLINE_GAME then
        host_id = "192.168.178.50:44631"
    end
    
    host = enet.host_create()
    server = host:connect(host_id)
end

function client.service()
    local event = host:service(0)
    while event do
        
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
                
            elseif event.data:sub(1, 6) == "taskc " then
                
                print( "Received new char task", event.data:sub(7) )
                client.parseTask( event.data:sub(7) )
                
            elseif event.data:sub(1, 6) == "remob " then
                
                print( "Received remove object", event.data:sub(7) )
                client.parseRemoveObject( event.data:sub(7) )
                
            elseif event.data:sub(1, 6) == "built " then
                
                print( "Received build finished object", event.data:sub(7)  )
                client.parseFinishBuild( event.data:sub(7) )
                
            else
                
                print("Got message: ", event.data, event.peer)
                
            end
            
        end
        
        event = host:service(0)
        
    end
end


-- send build wish
function client.sendBuild(build)
    server:send("build "..build.__name..","..(-1)..","..build.x..","..build.y..","..build.xsize..","..build.ysize)
end


-- try to remove given object
function client.parseRemoveObject(string)
    local id = tonumber(string)
    if id and world.getObject(id) then
        world.removeObject(id)
    end
end


-- try to finish given building/object
function client.parseFinishBuild(string)
    local id = tonumber(string)
    if id and world.getObject(id) then
        local build = world.getObject(id)
        build.workleft = 0
        build:work(0.1)
        return
    end
    print( "Error: No building with id", id)
end


-- send task wish
function client.sendTask(object)
    server:send("taskw "..object.id)
end


-- Parse all chars received by server. TODO: catch errors
function client.parseChars(string)
    for i,char in pairs(parser.parseChars(string)) do
        world.addChar(char)
    end
end


-- Parse a new task for a char
function client.parseTask(string)
    local charid, task = parser.parseTask(string)
    local char = world.getChar(charid)
    if char then
        char:addTask(task)
    end
end


-- Parse all received objects. TODO: catch errors
function client.parseObjects(string)
    for i,object in pairs(parser.parseObjects(string)) do
        world.addObject(object)
        if object:is(Field) then object:generateImage() end
    end
end

function client.disconnect()
    server:disconnect()
    host:flush()
    server = nil
    host = nil
    print(" Client shut down" )
end