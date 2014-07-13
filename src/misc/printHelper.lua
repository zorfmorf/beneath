--[[
    
    When printing we want to distinguish between server and client messages
    AND we want to print server messages to log as well
    
]]--

_print = print

function print(...)
    
    local args = {...}
    
    if server then
        logfile:write(unpack(args), "\n")
        _print( "Server:", unpack(args) )
        return
    end
    _print( "Client:", unpack(args))
end
