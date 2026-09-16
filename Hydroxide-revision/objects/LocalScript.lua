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
            print("[LocalScript] Attempting decompilation for:", instance:GetFullName())
            
            -- Try decompiling the closure first
            local closureSuccess, closureSource = pcall(decompile, closure)
            print("[LocalScript] Closure decompile - Success:", closureSuccess, "Type:", type(closureSource))
            if closureSuccess and closureSource then
                print("[LocalScript] Closure source length:", #closureSource)
                print("[LocalScript] First 100 chars:", closureSource:sub(1, 100))
            end
            
            -- Try decompiling the instance
            local instanceSuccess, instanceSource = pcall(decompile, instance)
            print("[LocalScript] Instance decompile - Success:", instanceSuccess, "Type:", type(instanceSource))
            if instanceSuccess and instanceSource then
                print("[LocalScript] Instance source length:", #instanceSource)
                print("[LocalScript] First 100 chars:", instanceSource:sub(1, 100))
            end
            
            -- Choose best result
            local source = nil
            if closureSuccess and closureSource and not closureSource:find("Decompilation failed") then
                source = closureSource
                print("[LocalScript] Using closure decompilation")
            elseif instanceSuccess and instanceSource and not instanceSource:find("Decompilation failed") then
                source = instanceSource
                print("[LocalScript] Using instance decompilation")
            end
            
            if source then
                -- Strip Potassium header
                source = source:gsub("^%-%- Decompiled with Potassium's decompiler%.%s*", "")
                return source
            else
                local errorMsg = "-- Decompilation Failed\n"
                errorMsg = errorMsg .. "-- Closure result: " .. tostring(closureSource) .. "\n"
                errorMsg = errorMsg .. "-- Instance result: " .. tostring(instanceSource) .. "\n\n"
                errorMsg = errorMsg .. "-- Script: " .. instance:GetFullName()
                return errorMsg
            end
        end
        return "-- Decompiler not available\n\n-- Script: " .. instance:GetFullName()
    end

    return localScript
end

return LocalScript
