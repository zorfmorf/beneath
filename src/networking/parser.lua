--[[
    
    The parser is used for parsing things into
    network messages and back
    
]]--

parser = {}


-- create a string from a object list
function parser.parseObjectsToString(objectlist)
    local string = ""
    for i,object in pairs(objectlist) do
        local id = object.id
        string = string..object.__name..","..object.id..","..object.x..","..object.y..";"
    end
    return string
end


-- parses objects from given string message
-- TODO: add checks
function parser.parseObjects(string)
    
    local objectList = {}
    
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
            
            if i == 2 and tonumber(value) > 0 then newobj.id = tonumber(value) end
            if i == 3 then newobj.x = tonumber(value) end
            if i == 4 then newobj.y = tonumber(value) end
            
            i = i + 1
        end
        
        table.insert(objectList, newobj)
    end
    
    return objectList
end


-- parses chars from given string message
-- TODO: add checks
function parser.parseChars(string)
    
    local chars = {}
    
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
        table.insert(chars, newchar)
    end
    
    return chars
end