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
            if success and source then
                -- Just return whatever decompile gives us, no filtering
                return source
            else
                return "-- Decompiler Error\n-- " .. tostring(source) .. "\n\n-- Script: " .. instance:GetFullName()
            end
        end
        return "-- Decompiler not available\n-- Your executor needs a decompile() function\n\n-- Script: " .. instance:GetFullName()
    end

    return localScript
end

return LocalScript
