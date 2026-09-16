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
            if success and source and #source > 50 then
                return source
            else
                return "-- Decompilation Failed\n-- Error: " .. tostring(source) .. "\n-- Module: " .. instance:GetFullName()
            end
        end
        return "-- Decompiler not available\n-- Your executor needs a decompile() function\n-- Module: " .. instance:GetFullName()
    end

    return moduleScript
end

return ModuleScript
