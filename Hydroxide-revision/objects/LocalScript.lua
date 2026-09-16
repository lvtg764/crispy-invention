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
                if source:find("Decompilation failed") or source:find("Failed to decompile") or #source < 50 then
                    return "-- Decompilation Failed\n-- This script may be protected or obfuscated\n-- Try using a different decompiler or check Dex++\n\n-- Script: " .. instance:GetFullName()
                end
                return source
            else
                return "-- Decompiler Error: " .. tostring(source) .. "\n-- Script: " .. instance:GetFullName()
            end
        end
        return "-- Decompiler not available\n-- Your executor needs a decompile() function\n-- Script: " .. instance:GetFullName()
    end

    return localScript
end

return LocalScript