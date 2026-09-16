local aux = {}

local getGc = getgc
local getInfo = debug.getinfo or getinfo
local getUpvalue = debug.getupvalue or getupvalue
local getConstants = debug.getconstants or getconstants
local isXClosure = iscclosure or checkclosure
local isLClosure = islclosure or (iscclosure and function(f) return not iscclosure(f) end)

assert(getGc and getInfo and getConstants and isXClosure, "Your executor is not supported")

local placeholderUserdataConstant = newproxy(false)

local function matchConstants(closure, list)
    if not list then
        return true
    end
    
    local success, constants = pcall(getConstants, closure)
    if not success then
        return false
    end
    
    for index, value in pairs(list) do
        if constants[index] ~= value and value ~= placeholderUserdataConstant then
            return false
        end
    end
    
    return true
end

local function searchClosure(script, name, upvalueIndex, constants)
    for _, v in pairs(getGc()) do
        if type(v) == "function" and isLClosure(v) and not isXClosure(v) then
            local success, env = pcall(getfenv, v)
            if not success then
                continue
            end
            
            local parentScript = rawget(env, "script")
            
            if (script == nil and parentScript and parentScript.Parent == nil) or script == parentScript then
                local hasUpvalue = upvalueIndex and pcall(getUpvalue, v, upvalueIndex)
                
                if hasUpvalue or not upvalueIndex then
                    local info = getInfo(v)
                    if ((name and name ~= "Unnamed function") and info.name == name) and matchConstants(v, constants) then
                        return v
                    elseif (not name or name == "Unnamed function") and matchConstants(v, constants) then
                        return v
                    end
                end
            end
        end
    end
end

aux.placeholderUserdataConstant = placeholderUserdataConstant
aux.searchClosure = searchClosure

return aux
