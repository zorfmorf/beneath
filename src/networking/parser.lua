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
        string = string..object.__name..","..object.id..","..object.l..","..object.x..","..object.y..","..object.xsize..","..object.ysize
        if object.ressources then
            for res,amount in pairs(object.ressources) do
                string = string..","..res.."="..amount
            end
        end
        string = string..";"
    end
    return string
end


-- parses objects from given string message
-- TODO: add checks
function parser.parseObjects(string)
    
    local objectList = {}
    
    for object in string.gmatch(string, '[^;]+') do
        local i = 1
        local newobj = Object:new(0, 0, 0)
        for value in string.gmatch(object, '[^,]+') do
            
            if i == 1 then 
                if value == "tent" then newobj = Tent:new(0, 0, 0) end
                if value == "farm" then newobj = Farm:new(0, 0, 0) end
                if value == "smith" then newobj = Smith:new(0, 0, 0) end
                if value == "warehouse" then newobj = Warehouse:new(0, 0, 0) end
                if value == "field" then newobj = Field:new(0, 0, 0) end
                if value == "carpenter" then newobj = Carpenter:new(0, 0, 0) end
                if value == "hole" then newobj = Hole:new(0, 0, 0) end
                if value == "ressource" then newobj = Ressource:new(0, 0, 0) end
                if value == "tree_small" then newobj = Tree:new(0, 0, 0, 3) end
                if value == "tree_leaf" then newobj = Tree:new(0, 0, 0, 2) end
                if value == "tree_needle" then newobj = Tree:new(0, 0, 0, 1) end
            end
            
            if i == 2 and not server then newobj.id = tonumber(value) end
            if i == 3 then newobj.l = tonumber(value) end
            if i == 4 then newobj.x = tonumber(value) end
            if i == 5 then newobj.y = tonumber(value) end
            if i == 6 then newobj.xsize = tonumber(value) end
            if i == 7 then newobj.ysize = tonumber(value) end
            
            -- rest of the string should be ressources
            if i >= 8 then 
                local res,amount = parser.parseRessource(value)
                if res and amount then
                    if not newobj.ressources then 
                        newobj.ressources = {} 
                    end
                    newobj.ressources[res] = amount
                end
            end
            
            i = i + 1
        end
        
        print ( "Parsed new object", newobj.__name, newobj.id)
        table.insert(objectList, newobj)
    end
    
    return objectList
end


-- parse ressource from a string in the form 'wood=2'
function parser.parseRessource(string)
    local res = nil
    local amount = nil
    local i = 1
    for value in string.gmatch(string, '[^=]+') do
        if i == 1 then res = value end
        if i == 2 then amount = tonumber(value) end
        i = i + 1
    end
    if not res or not amount then return nil end
    return res, amount
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
            if i == 3 then newchar.l = tonumber(value) end
            if i == 4 then newchar.x = tonumber(value) end
            if i == 5 then newchar.y = tonumber(value) end
            i = i + 1
        end
        table.insert(chars, newchar)
    end
    
    return chars
end


-- parse task
function parser.parseTask(string)
    local i = 1
    local charid = -1
    local task = nil
    local taskname = nil
    local params = {}
    for value in string.gmatch(string, '[^,]+') do
        if i == 1 then charid = tonumber(value) end
        if i == 2 then taskname = value end
        if i >= 3 then table.insert(params, value) end
        i = i + 1
    end
    
    if taskname == WorkTask.__name then
        task = WorkTask:new(tonumber(params[1]))
    end
    
    if taskname == Task.__name then
        task = Task:new( tonumber(params[1]), tonumber(params[2]) )
    end
    
    if taskname == CarryTask.__name then
        task = CarryTask:new( tonumber(params[1]), tonumber(params[2]), params[3] )
    end
    
    if taskname == ProfessionTask.__name then
        task = ProfessionTask:new( tonumber(params[1]) )
    end
    
    return charid, task
end


-- chunk parsing
function parser.parseChunkToString(x, y, chunk)
    
    local string = x..","..y..","..chunk.id.."#"
    
    for i=1,chunk:getHeight() do
        string = string..i..":"
        for y,row in pairs(chunk:getTiles(i)) do
            for x,tile in pairs(row) do
                string = string..tile.texture
                if tile.clear then string = string..".1" end
                if x < #row then string = string .. "," end
            end
            string = string..";"
        end
        string = string.." "
    end
    
    return string
end


function parser.parseLobbyInformation(string)
    local players = {}
    for value in string.gmatch(string, '[^,]+') do
        table.insert(players, value) 
    end
    return players
end


function parser.parseChunk(string)
    
    local chunk = Chunk:new()
    local x = nil
    local y = nil
    
    local i = 1
    for substring in string.gmatch(string, '[^#]+') do
        
        if i == 1 then
            i = i + 1
            
            for number in string.gmatch(substring, '[^,]+') do
                if not x then 
                    x = tonumber(number)
                elseif not y then
                    y = tonumber(number)
                else
                    chunk.id = tonumber(number)
                end
            end
        else
        
            for layer in string.gmatch(substring, '[^ ]+') do
                
                local layerindex = tonumber(layer:sub(1, 1))
                local tiles = {}
                local y = 0
                local x = 0
                
                for row in string.gmatch(layer:sub(3), '[^;]+') do
                    tiles[y] = {}
                    for tile in string.gmatch(row, '[^,]+') do
                        tiles[y][x] = { texture = nil, overlays = nil, object = nil, clear=false }
                        for texture in string.gmatch(tile, '[^.]+') do
                            if tiles[y][x].texture then
                                tiles[y][x].clear = true
                            else
                                tiles[y][x].texture = texture
                            end
                        end
                        x = x + 1
                    end
                    x = 0
                    y = y + 1
                end
                
                chunk:setTiles(layerindex, tiles)
            end
        end
    end
    return x, y, chunk
end
