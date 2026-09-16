local SignalSpy = {}

local requiredMethods = {
    getconnections = true,
    firesignal = true,
}

local function scanSignals()
    local signals = {}
    
    for _, instance in pairs(game:GetDescendants()) do
        pcall(function()
            for _, property in pairs({"Changed", "ChildAdded", "ChildRemoved", "Destroying"}) do
                local success, signal = pcall(function() return instance[property] end)
                if success and typeof(signal) == "RBXScriptSignal" then
                    if not signals[instance] then
                        signals[instance] = {}
                    end
                    table.insert(signals[instance], {
                        Name = property,
                        Signal = signal,
                        Instance = instance
                    })
                end
            end
        end)
    end
    
    return signals
end

local function getSignalInfo(signal)
    local info = {
        Connections = {},
        Arguments = {},
        ArgumentsInfo = {},
        CanReplicate = false,
        ConnectionCount = 0
    }
    
    if getconnections then
        local success, connections = pcall(getconnections, signal)
        if success and connections then
            info.Connections = connections
            info.ConnectionCount = #connections
        end
    end
    
    if getsignalarguments then
        local success, args = pcall(getsignalarguments, signal)
        if success and args then
            info.Arguments = args
        end
    end
    
    if getsignalargumentsinfo then
        local success, argsInfo = pcall(getsignalargumentsinfo, signal)
        if success and argsInfo then
            info.ArgumentsInfo = argsInfo
        end
    end
    
    if cansignalreplicate then
        local success, canReplicate = pcall(cansignalreplicate, signal)
        if success then
            info.CanReplicate = canReplicate
        end
    end
    
    return info
end

local function getWhitelist()
    if getsignalwhitelist then
        local success, whitelist = pcall(getsignalwhitelist)
        if success and whitelist then
            return whitelist
        end
    end
    return {}
end

SignalSpy.RequiredMethods = requiredMethods
SignalSpy.ScanSignals = scanSignals
SignalSpy.GetSignalInfo = getSignalInfo
SignalSpy.GetWhitelist = getWhitelist
return SignalSpy
