--[[
    
    RessourceHandler keeps track of all available
    ressources.
    
    Server: Used to keep track of where which ressources
    are and which are available to use.
    
    Client: only keeps track of overall ressources, gets
    informed by server
    
]]--

ressourceHandler = {}

local ressources = nil -- table of ressources

function ressourceHandler.init()
    
    ressources = {}
    
    if server then
        ressources = { 
                wood = {},
                stone = {},
                planks = {}
            }
    end
    
end


-- take not of all ressources
function ressourceHandler.addRessources(object)
    if object.ressources then
        for res,amount in pairs(object.ressources) do
            for i = 1,amount do
                table.insert( ressources[res], object.id)
            end
        end
    end
end


-- when buildings create ressources, we need to take note of them
-- individually
function ressourceHandler.addSingleRessource(objectid, res)
    table.insert( ressources[res], objectid )
end


function ressourceHandler.hasRessource(res)
    return #ressources[res] > 0
end


function ressourceHandler.withdraw(res)
    if #ressources[res] <= 0 then return nil end
    return table.remove(ressources[res])
end


-- Get ressource table list
function ressourceHandler.getRessources()
    return ressources
end
