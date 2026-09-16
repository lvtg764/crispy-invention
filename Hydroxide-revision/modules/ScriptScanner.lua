local ScriptScanner = {}
local LocalScript = import("objects/LocalScript")

local requiredMethods = {
    getGc = true,
    getSenv = true,
    getProtos = true,
    getConstants = true,
    getScriptClosure = true,
    isXClosure = true
}

local function scan(query)
    local scripts = {}
    query = query and query:lower() or ""

    for _, v in pairs(getGc()) do
        if type(v) == "function" and not isXClosure(v) then
            local success, env = pcall(getfenv, v)
            if not success then
                continue
            end
            
            local script = rawget(env, "script")

            if typeof(script) == "Instance" and 
                not scripts[script] and 
                script:IsA("LocalScript") and 
                script.Name:lower():find(query)
            then
                local hasClosureSuccess = pcall(getScriptClosure, script)
                local hasSenvSuccess = pcall(getSenv, script)
                
                if hasClosureSuccess and hasSenvSuccess then
                    scripts[script] = LocalScript.new(script)
                end
            end
        end
    end

    return scripts
end

ScriptScanner.RequiredMethods = requiredMethods
ScriptScanner.Scan = scan
return ScriptScanner