local ModuleScript = {}

function ModuleScript.new(instance)
    local moduleScript = {}
    local closure = getScriptClosure(instance)

    moduleScript.Instance = instance
    moduleScript.Constants = getConstants(closure)
    moduleScript.Protos = getProtos(closure)
    
    moduleScript.GetSource = function()
        if decompile then
            local success, source = pcall(decompile, instance)
            if success and source then
                if source:find("Decompilation failed") or source:find("Failed to decompile") or #source < 50 then
                    return "-- Decompilation Failed\n-- This module may be protected or obfuscated\n-- Try using a different decompiler or check Dex++\n\n-- Module: " .. instance:GetFullName()
                end
                return source
            else
                return "-- Decompiler Error: " .. tostring(source) .. "\n-- Module: " .. instance:GetFullName()
            end
        end
        return "-- Decompiler not available\n-- Your executor needs a decompile() function\n-- Module: " .. instance:GetFullName()
    end

    return moduleScript
end

return ModuleScript
