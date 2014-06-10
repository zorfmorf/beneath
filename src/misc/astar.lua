--[[
    
    Implementation of the A* pathfinding algorithm
    Based on the wikipedia article on A*
    http://en.wikipedia.org/wiki/A*
    
    Not a general solution but optimized towards beneath

]]--

astar = {}


-- Estimates cost between two nodes
local function cost_estimate(from, target)
    return math.sqrt(math.pow(from.x - target.x, 2) + math.pow(from.y - target.y, 2))
end


-- Returns a path by retracing visited nodes from goal
local function retracePath(path, node)
    if node.parent then retracePath(path, node.parent) end
    node.x = node.x + 0.5
    node.y = node.y + 0.5
    table.insert(path, node)
    return path
end


-- Returns a path or nil if none exists
function astar.calculate(map, start, goal)
    
    if not map or not start or not goal then return nil end
    
    local openset = {}
    local nodes = {}
    local path = {}
    
    -- close neighbors
    for y,row in pairs(map) do
        nodes[y] = {}
        for x,entry in pairs(row) do
            nodes[y][x] = { visited=false, x=x, y=y, walkable=(map[y][x].object == nil)  }
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
            return retracePath(path, current)
        end
        
        for k = -1,1 do
            for l = -1,1 do
                if not (k == l) -- sady there is no xor in lua
                   and (k == 0 or l == 0)
                   and nodes[current.y + k]
                   and nodes[current.y + k][current.x + l]
                   and not nodes[current.y + k][current.x + l].visited then
                    
                    local node = nodes[current.y + k][current.x + l]
                    
                    if (k == -1 or l == 1) and node.x == goal.x and node.y == goal.y then
                        node.visited = true
                        return retracePath(path, current)
                    end
                    
                    if node.walkable then
                        node.visited = true
                        node.parent = current
                        node.gcost = current.gcost + 1
                        node.fcost = node.gcost + cost_estimate(node, goal)
                        table.insert(openset, node)
                    end
                end
            end
        end
    end
    
    return nil
end