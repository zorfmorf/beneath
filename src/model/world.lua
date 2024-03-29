--[[
    
    
    
]]--

world = {}

local MAX_OBJECT_SIZE = 5 --needed to correctly select objects on click
WORLD_SIZE = 5 -- size 1 is one 16x16 grid

local tiles = nil -- the floor
local objects = nil -- objects can be placed on tiles
local objectDrawOrder = nil -- draw order for objects
local characters = nil -- villagers, monsters, etc
local charDrawOrder = nil -- draw order for chars
local worldCanvas = nil


function world.init()
    
    chunks = {}
    
    objects = {}
    objectDrawOrder = {}
    
    characters = {}
    charDrawOrder = {}
    
    for i=1,CHUNK_HEIGHT do
        objects[i] = {}
        objectDrawOrder[i] = {}
        characters[i] = {}
        charDrawOrder[i] = {}
    end

end


-- generates a new world. should be done on server
function world.generate()
    
    -- generate chunks
    for i=1,WORLD_SIZE do
        chunks[i] = {}
        for j=1,WORLD_SIZE do
            chunks[i][j] = Chunk:new()
            
             --generate default 16x16 tiles
            for layer = 1,CHUNK_HEIGHT do
                local tiles = {}
                for k=0,CHUNK_WIDTH - 1 do   
                    tiles[k] = {}
                    for l=0,CHUNK_WIDTH - 1 do
                        if layer == CHUNK_HEIGHT then
                            tiles[k][l] = { texture = "g"..math.random(1,3), overlays = nil, object = nil, clear=true }
                            if math.random(1, 14) == 10 then tiles[k][l].texture = "g"..math.random(4,6) end
                        else
                            tiles[k][l] = { texture = "dm", overlays = {}, object = nil, clear=false }
                        end
                    end   
                end
                
                chunks[i][j]:setTiles(layer, tiles)
            end
        end
    end
    
    --world.addObject(Ressource:new(1, 15, 15, {planks=6}))
    --world.addObject(Ressource:new(1, 15, 16, {planks=6}))
    world.addObject(Ressource:new(CHUNK_HEIGHT, 16, 15, {stone=6}))
    world.addObject(Ressource:new(CHUNK_HEIGHT, 16, 16, {stone=6}))
    
    for i=1,1000 do
        local x = math.random() * (WORLD_SIZE * CHUNK_WIDTH)
        local y = math.random() * (WORLD_SIZE * CHUNK_WIDTH)
        world.addObject(Tree:new(CHUNK_HEIGHT, x, y))
    end
    
    for i=1,2 do
        local x = 20 + math.random() * CHUNK_WIDTH
        local y = 20 + math.random() * CHUNK_WIDTH
        local tile = world.getTile(CHUNK_HEIGHT, x, y)
        if tile then
            local char = Char:new(CHUNK_HEIGHT, x, y)
            world.addChar(char)
        end
    end
end


function world.updateChunk(x, y, chunk)
    
    if not chunks[y] then chunks[y] = {} end
    chunk.x = x
    chunk.y = y
    chunks[y][x] = chunk
    
end


-- returns a specfic chunk or nil if not existent
function world.getChunk(x, y)
    if chunks[y] and chunks[y][x] then 
        return chunks[y][x]
    end
    return nil
end


-- converts coordinates to chunk coordinates
function world.getChunkByCoordinates(x, y)
    local cx = math.floor(x / CHUNK_WIDTH) + 1
    local cy = math.floor(y / CHUNK_WIDTH) + 1
    if chunks[cy] and chunks[cy][cx] then return chunks[cy][cx] end
    return nil
end


-- returns all existing chunks
function world.getChunks()
    return chunks
end


-- returns all chars for given layer only
function world.getChars(layer)
    return characters[layer]
end


-- returns list of ids for chars and objects in the order they need to be drawn
function world.getDrawOrders(layer)
    return objectDrawOrder[layer], charDrawOrder[layer]
end


-- add char to char list and update draw order
function world.addChar(char)
    characters[char.l][char.id] = char
    table.insert(charDrawOrder[char.l], char.id)
end


-- chars need to be removed when dying or when taking up a profession
function world.removeChar(char)
    characters[char.l][char.id] = nil
    local i = #charDrawOrder
    while i > 0 do
        if charDrawOrder[char.l][i] == char.id then
            table.remove(charDrawOrder[char.l], i)
        end
        i = i - 1
    end
end


-- returns a tileselection or nil
function world.isPlacable(object)
    local tileselection = {}
    
    local x = math.floor(object.x)
    local y = math.floor(object.y)
    
    local xmod = object.xsize - 1
    
    -- first validate that object can be placed
    for i=x, x + xmod do
        for j=y, y - (object.ysize - 1),-1 do
            local tile = world.getTile(object.l, i, j)
            if tile == nil or tile.object then return nil end
            table.insert(tileselection, tile)
        end
    end
    return tileselection
end

-- mark tiles as "built on", change texture if necessary
function world.markTiles(tileselection, object)
    
    for i,tile in pairs(tileselection) do
        tile.object = object.id
    end
    
    if not server then
    
        -- draw dirt on ground around new buildings
        if object:is(Building) then
            local chunksToUpdate = overlayGenerator.generateDirt(object)
            
            for i,chunk in pairs(chunksToUpdate) do
                chunk:update(object.l)
            end 
        end
    
    end
end


-- add object to world. marks tiles as built and calculates draw order
function world.addObject(object)
    
    if objects[object.l][object.id] then
        print( "Error: duplicate object id: ", object.id, object.__name)
        return false
    end
    
    -- check if placeable
    local tileselection = world.isPlacable(object)
    if tileselection == nil then 
        if not server then 
            -- server objects should always be placable!
            print("Recieved unplacable object!", object.__name, object.l, object.x, object.y)
        end
        return false 
    end
    
    -- check and track holes. only one per layer
    if object:is(Hole) and not logicHandler.buildHole(object.l) then
        return false
    end
    
    -- actually place object
    object.x = math.floor(object.x)
    object.y = math.floor(object.y)
    objects[object.l][object.id] = object
    
    -- mark tiles as used so that no other building can be placed there
    world.markTiles(tileselection, object)
    
    -- add object to draw order
    if not server then
        table.insert(objectDrawOrder[object.l], object.id)
        table.sort(objectDrawOrder[object.l], 
            function(a, b) return objects[object.l][a].y < objects[object.l][b].y end )
    end
        
    -- if we are server, track ressources and inform clients
    if server then
        if object.ressources then ressourceHandler.addRessources(object) end
        server.sendAddObject(object)
    end
    
    return true
end


-- update elements in world
function world.update(dt)
    
    for layer=1,CHUNK_HEIGHT do
    
        for i,char in pairs(characters[layer]) do
            char:update(dt)
        end
        
        for i,object in pairs(objects[layer]) do
            if object.workleft < 0 and object:is(Building) then
                if server then object:serverupdate(dt) end
                if not server then object:clientupdate(dt) end
            end
        end
        
        if not server then
            table.sort(charDrawOrder[layer], 
                function(a, b) return characters[layer][a].y < characters[layer][b].y end )
        end
    end
end


-- returns object with given id
function world.getObject(id)
    for layer=1,CHUNK_HEIGHT do
        if objects[layer][id] then
            return objects[layer][id]
        end
    end
    return nil
end


-- returns all objects. used for networking
function world.getObjects(layer)
    return objects[layer]
end


-- returns char with given id
function world.getChar(id)
    for layer=1,CHUNK_HEIGHT do
        if characters[layer][id] then
            return characters[layer][id]
        end
    end
    return nil
end

function world.removeObject(id)
    
    local obj = world.getObject(id)
    
    if obj then
        
        -- free up tiles so that other things can be placed there
        for y=obj.y,obj.y-(obj.ysize-1),-1 do
            for x=obj.x,obj.x+(obj.xsize-1) do
                local tile = world.getTile(obj.l, x, y)
                if tile and tile.object == obj.id then tile.object = nil end
            end
        end
        
        -- remove object from draworder
        local i = #objectDrawOrder[obj.l]
        while i > 0 do
            if objectDrawOrder[obj.l][i] == id then
                table.remove(objectDrawOrder[obj.l], i)
            end
            i = i - 1
        end
        
        -- make sure that no chars keep on working on this
        objects[obj.l][id].workleft = -1
        
        -- actually delete object
        objects[obj.l][id] = nil
        if server then server.sendRemoveObject(id) end
        return true
    end
    return false
end


-- Get object based on clicked tile
function world.getClickedObject(l, x, y)
    
    local candidate = nil
    
    for i = 0,MAX_OBJECT_SIZE do
        for j = 0,MAX_OBJECT_SIZE do
            
            local xc = math.floor(x-j)
            local yc = math.floor(y+i)
            local tile = world.getTile(l, xc, yc)
            
            if tile and tile.object then
                
                local object = objects[l][tile.object]
                
                if object and
                   object.x + object.xsize >= x and
                   object.y - (object.ysize + 1) <= y then
                    
                    candidate = object
                    
                end
                
            end
        end
    end
    
    return candidate
end


-- return tile at given layer and position
-- automatically handles chunks so that we never have to worry about them
function world.getTile(tl, tx, ty)
    
    local chunkx = math.floor(tx / CHUNK_WIDTH)
    local chunky = math.floor(ty / CHUNK_WIDTH)
    
    if chunks[chunky + 1] and chunks[chunky + 1][chunkx + 1] then
        local x = math.floor(tx) - chunkx * CHUNK_WIDTH
        local y = math.floor(ty) - chunky * CHUNK_WIDTH
        return chunks[chunky + 1][chunkx + 1]:getTile(tl, x, y)
    end
    return nil
    
end
