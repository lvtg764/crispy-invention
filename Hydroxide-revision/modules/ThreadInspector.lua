local ThreadInspector = {}

local requiredMethods = {
    getthreadidentity = true,
    getscriptfromthread = true,
    getrunningscripts = true,
}

local function getAllThreads()
    local threads = {}
    
    if getrunningscripts then
        for _, script in pairs(getrunningscripts()) do
            if getscriptthread then
                local success, thread = pcall(getscriptthread, script)
                if success and thread then
                    table.insert(threads, {
                        Thread = thread,
                        Script = script,
                        Identity = getthreadidentity and pcall(getthreadidentity) or "Unknown"
                    })
                end
            end
        end
    end
    
    return threads
end

local function getThreadInfo(thread)
    local info = {
        Script = nil,
        Identity = 0,
        Status = "unknown"
    }
    
    if getscriptfromthread then
        local success, script = pcall(getscriptfromthread, thread)
        if success then
            info.Script = script
        end
    end
    
    if getthreadidentity then
        local success, identity = pcall(getthreadidentity)
        if success then
            info.Identity = identity
        end
    end
    
    local success, status = pcall(function() return coroutine.status(thread) end)
    if success then
        info.Status = status
    end
    
    return info
end

local function getScriptThreads(script)
    local threads = {}
    
    if getscriptthread then
        local success, thread = pcall(getscriptthread, script)
        if success and thread then
            table.insert(threads, thread)
        end
    end
    
    return threads
end

ThreadInspector.RequiredMethods = requiredMethods
ThreadInspector.GetAllThreads = getAllThreads
ThreadInspector.GetThreadInfo = getThreadInfo
ThreadInspector.GetScriptThreads = getScriptThreads
return ThreadInspector
