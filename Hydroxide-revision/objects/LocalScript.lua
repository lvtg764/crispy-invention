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
                -- Strip Potassium's header
                source = source:gsub("^%-%- Decompiled with Potassium's decompiler%.%s*", "")
                return source
            else
                return "-- Decompiler Error\n-- " .. tostring(source) .. "\n\n-- Module: " .. instance:GetFullName()
            end
        end
        return "-- Decompiler not available\n-- Your executor needs a decompile() function\n\n-- Module: " .. instance:GetFullName()
    end

    return moduleScript
end

return ModuleScript
