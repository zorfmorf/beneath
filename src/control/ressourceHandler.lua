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
        
    else
        
    end
    
end


-- take not of all ressources
function ressourceHandler.addRessources(object)
    
end


-- Get ressource table list
function ressourceHandler.getRessources()
    return ressources
end