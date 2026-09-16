local LocalScript = {}

function LocalScript.new(instance)
    local localScript = {}
    local closure = getScriptClosure(instance)

    localScript.Instance = instance
    localScript.Environment = getSenv(instance)
    localScript.Constants = getConstants(closure)
    localScript.Protos = getProtos(closure)
    
    localScript.GetSource = function()
        if decompile then
            local success, source = pcall(decompile, instance)
            if success and source and #source > 50 then
                return source
            else
                return "-- Decompilation Failed\n-- Error: " .. tostring(source) .. "\n-- Script: " .. instance:GetFullName()
            end
        end
        return "-- Decompiler not available\n-- Your executor needs a decompile() function\n-- Script: " .. instance:GetFullName()
    end

    return localScript
end

return LocalScript
