local client = game:GetService("Players").LocalPlayer
local methods = {}

local function secureCall(closure, ...)
    if not closure then
        return
    end
    
    local oldContext = getContext()
    setContext(2)
    
    local results = {pcall(closure, ...)}
    
    setContext(oldContext)
    
    if results[1] then
        return unpack(results, 2)
    else
        warn("secureCall error:", results[2])
    end
end

methods.secureCall = secureCall
return methods
