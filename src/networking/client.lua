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
            event.peer:send("hello world")
            
        elseif event.type == "receive" then
            
            if event.data:sub(1, 6) == "tiles " then
                
                print( "Received tile data" )
                world.updateTiles(event.data:sub(7,event.data:len()))
                
            elseif event.data:sub(1, 6) == "plobj " then
                
                print( "Received object data" )
                client.parseObjects(event.data:sub(7,event.data:len()))
                
            elseif event.data:sub(1, 6) == "chars " then
                
                print( "Received char data" )
                client.parseChars(event.data:sub(7,event.data:len()))
                
            else
                
                print("Got message: ", event.data, event.peer)
                
            end
            
        end
    end
end


-- Parse all chars received by server. TODO: catch errors
function client.parseChars(string)
    for char in string.gmatch(string, '[^;]+') do
        local i = 1
        local newchar = Char:new(0, 0)
        for value in string.gmatch(char, '[^,]+') do
            if i == 1 then newchar.name = value end
            if i == 2 then newchar.id = tonumber(value) end
            if i == 3 then newchar.x = tonumber(value) end
            if i == 4 then newchar.y = tonumber(value) end
            i = i + 1
        end
        world.addChar(newchar)
    end
end


-- Parse all received objects. TODO: catch errors
function client.parseObjects(string)
    for object in string.gmatch(string, '[^;]+') do
        local i = 1
        local newobj = nil
        for value in string.gmatch(object, '[^,]+') do
            
            if i == 1 then 
                if value == "tent" then newobj = Tent:new(0, 0) end
                if value == "object" then newobj = Object:new(0, 0) end
                if value == "ressource" then newobj = Ressource:new(0, 0) end
                if value == "tree_small" then newobj = Tree:new(0, 0, 3) end
                if value == "tree_leaf" then newobj = Tree:new(0, 0, 2) end
                if value == "tree_needle" then newobj = Tree:new(0, 0, 1) end
            end
            
            if i == 2 then newobj.id = tonumber(value) end
            if i == 3 then newobj.x = tonumber(value) end
            if i == 4 then newobj.y = tonumber(value) end
            
            i = i + 1
        end
        
        world.addObject(newobj)
    end
end

function client.disconnect()
    server:disconnect()
    host:flush()
    server = nil
    host = nil
    print(" Client shut down" )
end