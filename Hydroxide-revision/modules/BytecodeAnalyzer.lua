local BytecodeAnalyzer = {}

local requiredMethods = {
    getscriptbytecode = true,
    getscripthash = true,
    dumpbytecode = true,
}

local scriptHashes = {}

local function analyzeScript(script)
    local analysis = {
        Bytecode = nil,
        Hash = nil,
        BytecodeSize = 0,
        HasClosure = false,
        Closure = nil
    }
    
    if getscriptbytecode then
        local success, bytecode = pcall(getscriptbytecode, script)
        if success and bytecode then
            analysis.Bytecode = bytecode
            analysis.BytecodeSize = #bytecode
        end
    end
    
    if getscripthash then
        local success, hash = pcall(getscripthash, script)
        if success and hash then
            analysis.Hash = hash
            scriptHashes[script] = hash
        end
    end
    
    if getscriptclosure then
        local success, closure = pcall(getscriptclosure, script)
        if success and closure then
            analysis.HasClosure = true
            analysis.Closure = closure
        end
    end
    
    return analysis
end

local function dumpFunction(func)
    if dumpbytecode then
        local success, bytecode = pcall(dumpbytecode, func)
        if success and bytecode then
            return bytecode
        end
    end
    return nil
end

local function compareScripts(script1, script2)
    local hash1 = scriptHashes[script1]
    local hash2 = scriptHashes[script2]
    
    if not hash1 and getscripthash then
        local success, hash = pcall(getscripthash, script1)
        if success then hash1 = hash end
    end
    
    if not hash2 and getscripthash then
        local success, hash = pcall(getscripthash, script2)
        if success then hash2 = hash end
    end
    
    return hash1 == hash2
end

local function getAllScriptHashes()
    local hashes = {}
    
    if getscripts and getscripthash then
        for _, script in pairs(getscripts()) do
            local success, hash = pcall(getscripthash, script)
            if success and hash then
                hashes[script] = hash
            end
        end
    end
    
    return hashes
end

BytecodeAnalyzer.RequiredMethods = requiredMethods
BytecodeAnalyzer.AnalyzeScript = analyzeScript
BytecodeAnalyzer.DumpFunction = dumpFunction
BytecodeAnalyzer.CompareScripts = compareScripts
BytecodeAnalyzer.GetAllScriptHashes = getAllScriptHashes
return BytecodeAnalyzer
