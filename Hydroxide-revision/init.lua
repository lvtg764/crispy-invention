local environment = assert(getgenv, "<OH> ~ Your executor is not supported")()

if oh then
    oh.Exit()
end

local web = true
local user = "lvtg764"
local repo = "crispy-invention"
local branch = "main"
local folder = "Hydroxide-revision"
local importCache = {}

local function hasMethods(methods)
    for name in pairs(methods) do
        if not environment[name] then
            return false
        end
    end
    return true
end

local function useMethods(module)
    for name, method in pairs(module) do
        if method then
            environment[name] = method
        end
    end
end

local mt = getrawmetatable(game)
local oldIndex = mt.__index
local oldNamecall = mt.__namecall
setreadonly(mt, false)

local globalMethods = {
    checkCaller = checkcaller,
    newCClosure = newcclosure,
    hookFunction = hookfunction or replaceclosure,
    getGc = getgc,
    getInfo = debug.getinfo or getinfo,
    getSenv = getsenv or getscriptenvs,
    getMenv = getmenv or getsenv,
    getContext = getthreadidentity or getidentity or getthreadcontext,
    setContext = setthreadidentity or setidentity or setthreadcontext,
    getConnections = getconnections,
    getScriptClosure = getscriptclosure,
    getNamecallMethod = getnamecallmethod,
    getCallingScript = getcallingscript,
    getLoadedModules = getloadedmodules,
    getConstants = debug.getconstants or getconstants,
    getUpvalues = debug.getupvalues or getupvalues,
    getProtos = debug.getprotos or getprotos,
    getStack = debug.getstack or getstack,
    getConstant = debug.getconstant or getconstant,
    getUpvalue = debug.getupvalue or getupvalue,
    getProto = debug.getproto or getproto,
    setConstant = debug.setconstant or setconstant,
    setUpvalue = debug.setupvalue or setupvalue,
    setStack = debug.setstack or setstack,
    getMetatable = getrawmetatable,
    getHui = gethui or get_hidden_gui,
    setClipboard = setclipboard or toclipboard or writeclipboard or setrbxclipboard,
    setReadOnly = setreadonly,
    isReadOnly = isreadonly,
    isLClosure = islclosure or (iscclosure and function(closure) return not iscclosure(closure) end),
    isXClosure = iscclosure or checkclosure,
    hookMetaMethod = hookmetamethod or function(object, method, hook)
        local mt = getrawmetatable(object)
        setreadonly(mt, false)
        local old = mt[method]
        mt[method] = hook
        setreadonly(mt, true)
        return old
    end,
    decompile = decompile,
    readFile = readfile,
    writeFile = writefile,
    makeFolder = makefolder,
    isFolder = isfolder,
    isFile = isfile,
}

if globalMethods.getUpvalue then
    local oldGetUpvalue = globalMethods.getUpvalue
    local oldGetUpvalues = globalMethods.getUpvalues

    globalMethods.getUpvalue = function(closure, index)
        if type(closure) == "table" then
            return oldGetUpvalue(closure.Data, index)
        end
        return oldGetUpvalue(closure, index)
    end

    globalMethods.getUpvalues = function(closure)
        if type(closure) == "table" then
            return oldGetUpvalues(closure.Data)
        end
        return oldGetUpvalues(closure)
    end
end

environment.hasMethods = hasMethods
environment.oh = {
    Events = {},
    Hooks = {},
    Cache = importCache,
    Methods = globalMethods,
    Constants = {
        Types = {
            ["nil"] = "rbxassetid://4800232219",
            table = "rbxassetid://4666594276",
            string = "rbxassetid://4666593882",
            number = "rbxassetid://4666593882",
            boolean = "rbxassetid://4666593882",
            userdata = "rbxassetid://4666594723",
            vector = "rbxassetid://4666594723",
            ["function"] = "rbxassetid://4666593447",
            thread = "rbxassetid://4666593447",
            integral = "rbxassetid://4666593882"
        },
        Syntax = {
            ["nil"] = Color3.fromRGB(244, 135, 113),
            table = Color3.fromRGB(225, 225, 225),
            string = Color3.fromRGB(225, 150, 85),
            number = Color3.fromRGB(170, 225, 127),
            boolean = Color3.fromRGB(127, 200, 255),
            userdata = Color3.fromRGB(225, 225, 225),
            vector = Color3.fromRGB(225, 225, 225),
            ["function"] = Color3.fromRGB(225, 225, 225),
            thread = Color3.fromRGB(225, 225, 225),
            unnamed_function = Color3.fromRGB(175, 175, 175)
        }
    },
    Exit = function()
        for _, event in pairs(oh.Events) do
            event:Disconnect()
        end

        for original, hook in pairs(oh.Hooks) do
            local hookType = type(hook)
            if hookType == "function" then
                hookFunction(hook, original)
            elseif hookType == "table" then
                hookFunction(hook.Closure.Data, hook.Original)
            end
        end

        local ui = importCache["rbxassetid://11389137937"]
        local assets = importCache["rbxassetid://5042114982"]

        if ui then
            unpack(ui):Destroy()
        end

        if assets then
            unpack(assets):Destroy()
        end
        
        setreadonly(mt, true)
    end
}

if getConnections then
    task.spawn(function()
        for _, connection in pairs(getConnections(game:GetService("ScriptContext").Error)) do
            local conn = getrawmetatable(connection)
            local old = conn and conn.__index
            
            if old then
                setreadonly(conn, false)
                conn.__index = newcclosure(function(t, k)
                    if k == "Connected" then
                        return true
                    end
                    return old(t, k)
                end)
                setreadonly(conn, true)
                
                pcall(function()
                    connection:Disable()
                end)
            end
        end
    end)
end

useMethods(globalMethods)

local HttpService = game:GetService("HttpService")
local releaseInfo

pcall(function()
    releaseInfo = HttpService:JSONDecode(game:HttpGetAsync("https://api.github.com/repos/" .. user .. "/" .. repo .. "/releases"))[1]
end)

if readFile and writeFile then
    print("[Hydroxide DEBUG] Using file-cached import")
    local hasFolderFunctions = (isFolder and makeFolder) ~= nil
    local ran, result = pcall(readFile, "__oh_version.txt")

    if not ran or not releaseInfo or (releaseInfo and releaseInfo.tag_name ~= result) then
        if hasFolderFunctions then
            local function createFolder(path)
                if not isFolder(path) then
                    makeFolder(path)
                end
            end

            createFolder("hydroxide")
            createFolder("hydroxide/" .. user)
            createFolder("hydroxide/" .. user .. "/" .. repo)
            createFolder("hydroxide/" .. user .. "/" .. repo .. "/methods")
            createFolder("hydroxide/" .. user .. "/" .. repo .. "/modules")
            createFolder("hydroxide/" .. user .. "/" .. repo .. "/objects")
            createFolder("hydroxide/" .. user .. "/" .. repo .. "/ui")
            createFolder("hydroxide/" .. user .. "/" .. repo .. "/ui/controls")
            createFolder("hydroxide/" .. user .. "/" .. repo .. "/ui/modules")
        end

        function environment.import(asset)
            if importCache[asset] then
                return unpack(importCache[asset])
            end

            local assets

            if asset:find("rbxassetid://") then
                local success, result = pcall(game.GetObjects, game, asset)
                if success and result and result[1] then
                    assets = { result[1] }
                else
                    warn("[OH ERROR] Failed to load asset:", asset, "Error:", result)
                    return nil
                end
            elseif web then
                if readFile and writeFile then
                    local file = (hasFolderFunctions and "hydroxide/" .. user .. "/" .. repo .. "/" .. asset .. ".lua") or ("hydroxide-" .. user .. "-" .. repo .. "-" .. asset:gsub('/', '-') .. ".lua")
                    local content

                    if (isFile and not isFile(file)) or not importCache[asset] then
                        local success, response = pcall(game.HttpGetAsync, game, "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/" .. branch .. "/" .. folder .. "/" .. asset .. ".lua")
                        if success then
                            content = response
                            writeFile(file, content)
                        else
                            warn("[OH ERROR] Failed to fetch:", asset, "Error:", response)
                            return nil
                        end
                    else
                        local ran, fileContent = pcall(readFile, file)

                        if (not ran) or not importCache[asset] then
                            local success, response = pcall(game.HttpGetAsync, game, "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/" .. branch .. "/" .. folder .. "/" .. asset .. ".lua")
                            if success then
                                content = response
                                writeFile(file, content)
                            else
                                warn("[OH ERROR] Failed to fetch:", asset, "Error:", response)
                                return nil
                            end
                        else
                            content = fileContent
                        end
                    end

                    if not content then
                        warn("[OH ERROR] No content for:", asset)
                        return nil
                    end

                    local loadSuccess, loadedFunc = pcall(loadstring, content, asset .. '.lua')
                    if not loadSuccess or not loadedFunc then
                        warn("[OH ERROR] Failed to loadstring:", asset, "Error:", loadedFunc)
                        return nil
                    end

                    local execSuccess, execResult = pcall(loadedFunc)
                    if not execSuccess then
                        warn("[OH ERROR] Failed to execute:", asset, "Error:", execResult)
                        return nil
                    end

                    assets = { execResult }
                else
                    local success, response = pcall(game.HttpGetAsync, game, "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/" .. branch .. "/" .. folder .. "/" .. asset .. ".lua")
                    if success then
                        local loadSuccess, loadedFunc = pcall(loadstring, response, asset .. '.lua')
                        if not loadSuccess or not loadedFunc then
                            warn("[OH ERROR] Failed to loadstring:", asset, "Error:", loadedFunc)
                            return nil
                        end

                        local execSuccess, execResult = pcall(loadedFunc)
                        if not execSuccess then
                            warn("[OH ERROR] Failed to execute:", asset, "Error:", execResult)
                            return nil
                        end

                        assets = { execResult }
                    else
                        warn("[OH ERROR] Failed to fetch:", asset, "Error:", response)
                        return nil
                    end
                end
            else
                local fileContent = readFile("hydroxide/" .. asset .. ".lua")
                if not fileContent then
                    warn("[OH ERROR] Failed to read local file:", "hydroxide/" .. asset .. ".lua")
                    return nil
                end

                local loadSuccess, loadedFunc = pcall(loadstring, fileContent, asset .. '.lua')
                if not loadSuccess or not loadedFunc then
                    warn("[OH ERROR] Failed to loadstring:", asset, "Error:", loadedFunc)
                    return nil
                end

                local execSuccess, execResult = pcall(loadedFunc)
                if not execSuccess then
                    warn("[OH ERROR] Failed to execute:", asset, "Error:", execResult)
                    return nil
                end

                assets = { execResult }
            end

            if not assets then
                warn("[OH ERROR] No assets created for:", asset)
                return nil
            end

            importCache[asset] = assets
            return unpack(assets)
        end

        if releaseInfo then
            writeFile("__oh_version.txt", releaseInfo.tag_name)
        end
    elseif ran and releaseInfo and releaseInfo.tag_name == result then
        function environment.import(asset)
            if importCache[asset] then
                return unpack(importCache[asset])
            end

            local assets

            if asset:find("rbxassetid://") then
                local success, result = pcall(game.GetObjects, game, asset)
                if success and result and result[1] then
                    assets = { result[1] }
                else
                    warn("[OH ERROR] Failed to load asset:", asset, "Error:", result)
                    return nil
                end
            elseif web then
                local file = (hasFolderFunctions and "hydroxide/" .. user .. "/" .. repo .. "/" .. asset .. ".lua") or ("hydroxide-" .. user .. "-" .. repo .. "-" .. asset:gsub('/', '-') .. ".lua")
                local ran, fileContent = pcall(readFile, file)
                local content

                if not ran then
                    local success, response = pcall(game.HttpGetAsync, game, "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/" .. branch .. "/" .. folder .. "/" .. asset .. ".lua")
                    if success then
                        content = response
                        writeFile(file, content)
                    else
                        warn("[OH ERROR] Failed to fetch (cached):", asset, "Error:", response)
                        return nil
                    end
                else
                    content = fileContent
                end

                if not content then
                    warn("[OH ERROR] No content for (cached):", asset)
                    return nil
                end

                local loadSuccess, loadedFunc = pcall(loadstring, content, asset .. '.lua')
                if not loadSuccess or not loadedFunc then
                    warn("[OH ERROR] Failed to loadstring (cached):", asset, "Error:", loadedFunc)
                    return nil
                end

                local execSuccess, execResult = pcall(loadedFunc)
                if not execSuccess then
                    warn("[OH ERROR] Failed to execute (cached):", asset, "Error:", execResult)
                    return nil
                end

                assets = { execResult }
            else
                local fileContent = readFile("hydroxide/" .. asset .. ".lua")
                if not fileContent then
                    warn("[OH ERROR] Failed to read local file (cached):", "hydroxide/" .. asset .. ".lua")
                    return nil
                end

                local loadSuccess, loadedFunc = pcall(loadstring, fileContent, asset .. '.lua')
                if not loadSuccess or not loadedFunc then
                    warn("[OH ERROR] Failed to loadstring (cached):", asset, "Error:", loadedFunc)
                    return nil
                end

                local execSuccess, execResult = pcall(loadedFunc)
                if not execSuccess then
                    warn("[OH ERROR] Failed to execute (cached):", asset, "Error:", execResult)
                    return nil
                end

                assets = { execResult }
            end

            if not assets then
                warn("[OH ERROR] No assets created for (cached):", asset)
                return nil
            end

            importCache[asset] = assets
            return unpack(assets)
        end
    else
        -- THIS IS THE FIX: ran == true but releaseInfo == nil
        print("[Hydroxide DEBUG] Using cached import (API unavailable)")
        function environment.import(asset)
            if importCache[asset] then
                return unpack(importCache[asset])
            end

            local assets

            if asset:find("rbxassetid://") then
                local success, result = pcall(game.GetObjects, game, asset)
                if success and result and result[1] then
                    assets = { result[1] }
                else
                    warn("[OH ERROR] Failed to load asset:", asset, "Error:", result)
                    return nil
                end
            elseif web then
                local file = (hasFolderFunctions and "hydroxide/" .. user .. "/" .. repo .. "/" .. asset .. ".lua") or ("hydroxide-" .. user .. "-" .. repo .. "-" .. asset:gsub('/', '-') .. ".lua")
                local ran, fileContent = pcall(readFile, file)
                local content

                if not ran then
                    local success, response = pcall(game.HttpGetAsync, game, "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/" .. branch .. "/" .. folder .. "/" .. asset .. ".lua")
                    if success then
                        content = response
                        writeFile(file, content)
                    else
                        warn("[OH ERROR] Failed to fetch (fallback):", asset, "Error:", response)
                        return nil
                    end
                else
                    content = fileContent
                end

                if not content then
                    warn("[OH ERROR] No content for (fallback):", asset)
                    return nil
                end

                local loadSuccess, loadedFunc = pcall(loadstring, content, asset .. '.lua')
                if not loadSuccess or not loadedFunc then
                    warn("[OH ERROR] Failed to loadstring (fallback):", asset, "Error:", loadedFunc)
                    return nil
                end

                local execSuccess, execResult = pcall(loadedFunc)
                if not execSuccess then
                    warn("[OH ERROR] Failed to execute (fallback):", asset, "Error:", execResult)
                    return nil
                end

                assets = { execResult }
            else
                local fileContent = readFile("hydroxide/" .. asset .. ".lua")
                if not fileContent then
                    warn("[OH ERROR] Failed to read local file (fallback):", "hydroxide/" .. asset .. ".lua")
                    return nil
                end

                local loadSuccess, loadedFunc = pcall(loadstring, fileContent, asset .. '.lua')
                if not loadSuccess or not loadedFunc then
                    warn("[OH ERROR] Failed to loadstring (fallback):", asset, "Error:", loadedFunc)
                    return nil
                end

                local execSuccess, execResult = pcall(loadedFunc)
                if not execSuccess then
                    warn("[OH ERROR] Failed to execute (fallback):", asset, "Error:", execResult)
                    return nil
                end

                assets = { execResult }
            end

            if not assets then
                warn("[OH ERROR] No assets created for (fallback):", asset)
                return nil
            end

            importCache[asset] = assets
            return unpack(assets)
        end
    end

    useMethods({ import = environment.import })
else
    print("[Hydroxide DEBUG] Using web-only import (no file functions)")
    function environment.import(asset)
        if importCache[asset] then
            return unpack(importCache[asset])
        end

        local assets

        if asset:find("rbxassetid://") then
                local success, result = pcall(game.GetObjects, game, asset)
                if success and result and result[1] then
                    assets = { result[1] }
                else
                    warn("[OH ERROR] Failed to load asset:", asset, "Error:", result)
                    return nil
                end
        else
            local success, response = pcall(game.HttpGetAsync, game, "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/" .. branch .. "/" .. folder .. "/" .. asset .. ".lua")
            if success then
                local loadSuccess, loadedFunc = pcall(loadstring, response, asset .. '.lua')
                if not loadSuccess or not loadedFunc then
                    warn("[OH ERROR] Failed to loadstring (web):", asset, "Error:", loadedFunc)
                    return nil
                end

                local execSuccess, execResult = pcall(loadedFunc)
                if not execSuccess then
                    warn("[OH ERROR] Failed to execute (web):", asset, "Error:", execResult)
                    return nil
                end

                assets = { execResult }
            else
                warn("[OH ERROR] Failed to fetch (web):", asset, "Error:", response)
                return nil
            end
        end

        if not assets then
            warn("[OH ERROR] No assets created for (web):", asset)
            return nil
        end

        importCache[asset] = assets
        return unpack(assets)
    end
    useMethods({ import = environment.import })
end

useMethods(environment.import("methods/environment"))
useMethods(environment.import("methods/string"))
useMethods(environment.import("methods/userdata"))
useMethods(environment.import("methods/table"))

--import("ui/main")
