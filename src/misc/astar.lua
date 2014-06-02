--[[
    
    Implementation of the A* pathfinding algorithm
    Based on the wikipedia article on A*
    http://en.wikipedia.org/wiki/A*

]]--

astar = {}


-- Estimates cost between two nodes
local function cost_estimate(from, target)
    return math.sqrt(math.pow(from.x - target.x, 2) + math.pow(from.y - target.y, 2))
end


-- Returns a path by retracing visited nodes from goal
local function retracePath(path, node)
    if node.parent then retracePath(path, node.parent) end
    return table.insert(path, node)
end


-- Returns a path or nil if none exists
function astar.calculate(map, start, goal)
    
    print( "Running A*")
    
    if not map or not start or not goal then return nil end
    
    print( "From:", start.x, start.y, "To:", goal.x, goal.y)
    
    local openset = {}
    local nodes = {}
    local path = {}
    
    -- close neighbors
    for y,row in pairs(map) do
        nodes[y] = {}
        for x,entry in pairs(row) do
            nodes[y][x] = { visited=(not entry.object == nil), x=x, y=y }
        end
    end
    
    start.gcost = 0
    start.fcost = cost_estimate(start, goal)
    table.insert(openset, start)
    
    while #openset > 0 do
        
        local checkIndex = 1
        for i = 1,#openset do
            if openset[i].fcost < openset[checkIndex].fcost then
                checkIndex = i
            end
        end
        local current = table.remove(openset, checkIndex)
        
        if current.x == goal.x and current.y == goal.y then
            print( "Found a path!" )
            return retracePath(path, current)
        end
        
        for k = -1,1,2 do
            for l = -1,1,2 do
                if nodes[current.y + k]
                   and nodes[current.y + k][current.x + l]
                   and not nodes[current.y + k][current.x + l].visited then
                    
                    local node = nodes[current.y + k][current.x + l]
                    node.visited = true
                    node.parent = current
                    node.gcost = current.gcost + 1
                    node.fcost = node.gcost + cost_estimate(node, goal)
                    table.insert(openset, node)
                end
            end
        end
    end
    
    print( "Astar could not find a path" )
    return nil
end