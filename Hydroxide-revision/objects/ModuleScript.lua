local ModuleScript = {}

function ModuleScript.new(instance)
    local moduleScript = {}

    moduleScript.Instance = instance
    moduleScript.Module = require(instance)
    moduleScript.Environment = getgenv()

    moduleScript.GetSource = function()
        if decompile then
            print("[ModuleScript] Attempting decompilation for:", instance:GetFullName())
            
            -- Try decompiling the instance directly
            local instanceSuccess, instanceSource = pcall(decompile, instance)
            print("[ModuleScript] Instance decompile - Success:", instanceSuccess, "Type:", type(instanceSource))
            if instanceSuccess and instanceSource then
                print("[ModuleScript] Instance source length:", #instanceSource)
                print("[ModuleScript] First 100 chars:", instanceSource:sub(1, 100))
            end
            
            if instanceSuccess and instanceSource and not instanceSource:find("Decompilation failed") then
                -- Strip Potassium header
                local source = instanceSource:gsub("^%-%- Decompiled with Potassium's decompiler%.%s*", "")
                return source
            else
                local errorMsg = "-- Decompilation Failed\n"
                errorMsg = errorMsg .. "-- Instance result: " .. tostring(instanceSource) .. "\n\n"
                errorMsg = errorMsg .. "-- Script: " .. instance:GetFullName()
                return errorMsg
            end
        end
        return "-- Decompiler not available\n\n-- Script: " .. instance:GetFullName()
    end

    return moduleScript
end

return ModuleScript
