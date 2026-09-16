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
            -- Try decompiling the closure first, then fall back to instance
            local success, source = pcall(decompile, closure)
            if not success or not source or source:find("Decompilation failed") then
                success, source = pcall(decompile, instance)
            end
            
            if success and source and not source:find("Decompilation failed") then
                source = source:gsub("^%-%- Decompiled with Potassium's decompiler%.%s*", "")
                return source
            else
                return "-- Decompilation Failed\n-- Potassium returned: " .. tostring(source) .. "\n\n-- Script: " .. instance:GetFullName() .. "\n-- Try right-click ? Copy Bytecode instead"
            end
        end
        return "-- Decompiler not available\n\n-- Script: " .. instance:GetFullName()
    end

    return localScript
end

return LocalScript
