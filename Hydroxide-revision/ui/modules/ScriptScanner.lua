local TextService = game:GetService("TextService")

local ScriptScanner = {}
local Methods = import("modules/ScriptScanner")

if not hasMethods(Methods.RequiredMethods) then
    return ScriptScanner
end

local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://11389137937").Base.Body.Pages.ScriptScanner
local Assets = import("rbxassetid://5042114982").ScriptScanner

local ScriptList = Page.List
local ScriptInfo = Page.Info

local ListQuery = ScriptList.Query
local ListSearch = ListQuery.Search
local ListRefresh = ListQuery.Refresh
local ListResults = ScriptList.Results.Clip.Content

local InfoScript = ScriptInfo.ScriptObject
local InfoBack = ScriptInfo.Back
local InfoOptions = ScriptInfo.Options.Clip.Content
local InfoSections = ScriptInfo.Sections

local InfoSource = InfoSections.Source
local InfoEnvironment = InfoSections.Environment
local InfoProtos = InfoSections.Protos
local InfoConstants = InfoSections.Constants

local EnvironmentQuery = InfoEnvironment.Query
local EnvironmentResultsClip = InfoEnvironment.Results.Clip
local EnvironmentResultsStatus = EnvironmentResultsClip.ResultStatus
local EnvironmentResults = EnvironmentResultsClip.Content

local ConstantsQuery = InfoConstants.Query
local ConstantsResultsClip = InfoConstants.Results.Clip
local ConstantsResultsStatus = ConstantsResultsClip.ResultStatus
local ConstantsResults = ConstantsResultsClip.Content

local ProtosQuery = InfoProtos.Query
local ProtosResultsClip = InfoProtos.Results.Clip
local ProtosResultsStatus = ProtosResultsClip.ResultStatus
local ProtosResults = ProtosResultsClip.Content

local scriptList = List.new(ListResults)
local protosList = List.new(ProtosResults)
local constantsList = List.new(ConstantsResults)

local scriptLogs = {}
local selected = {}
local icons = {
    LocalScript = "rbxassetid://4800244808"
}

local constants = {
    fadeLength = TweenInfo.new(0.15),
    textWidth = Vector2.new(133742069, 20)
}

local pathContext = ContextMenuButton.new("rbxassetid://4891705738", "Get Script Path")
local decompileContext = ContextMenuButton.new("rbxassetid://4800244808", "Copy Decompiled Source")
local viewSourceContext = ContextMenuButton.new("rbxassetid://4666593447", "View Source")
local viewHiddenPropsContext = ContextMenuButton.new("rbxassetid://4891633802", "View Hidden Properties")
local viewBytecodeContext = ContextMenuButton.new("rbxassetid://4702850565", "Copy Bytecode")
local viewHashContext = ContextMenuButton.new("rbxassetid://4909102841", "Get Script Hash")
local viewThreadsContext = ContextMenuButton.new("rbxassetid://4907151581", "View Threads")
scriptList:BindContextMenu(ContextMenu.new({ pathContext, decompileContext, viewSourceContext, viewHiddenPropsContext, viewBytecodeContext, viewHashContext, viewThreadsContext }))

pathContext:SetCallback(function()
    local selectedInstance = selected.logContext.LocalScript.Instance
    setClipboard(getInstancePath(selectedInstance))
    MessageBox.Show("Success", ("%s's path was copied to your clipboard."):format(selectedInstance.Name), MessageType.OK)
end)

decompileContext:SetCallback(function()
    local localScript = selected.logContext.LocalScript
    MessageBox.Show("Decompiling...", "Please wait, decompiling script source...", MessageType.OK)
    task.spawn(function()
        local source = localScript.GetSource()
        setClipboard(source)
        task.wait(0.1)
        MessageBox.Show("Success", "Decompiled source copied to clipboard.", MessageType.OK)
    end)
end)

viewSourceContext:SetCallback(function()
    if selected.scriptLog ~= selected.logContext then
        selected.scriptLog = selected.logContext
        
        local log = selected.logContext
        local localScript = log.LocalScript
        local scriptInstance = localScript.Instance
        local scriptName = scriptInstance.Name
        
        protosList:Clear()
        constantsList:Clear()
        
        ScriptList.Visible = false
        ScriptInfo.Visible = true

        local nameLength = game:GetService("TextService"):GetTextSize(scriptName, 18, "SourceSans", constants.textWidth).X + 20
        
        InfoScript.Icon.Image = icons.LocalScript
        InfoScript.Label.Text = scriptName
        InfoScript.Label.Size = UDim2.new(0, nameLength, 0, 20)
        InfoScript.Position = UDim2.new(1, -nameLength, 0, 0)

        for i,v in pairs(localScript.Protos) do
            createProto(i, v)
        end 

        for i,v in pairs(localScript.Constants) do
            createConstant(i, v)
        end

        local sourceDisplayed = false
        if InfoSource then
            local sourceBox = InfoSource:FindFirstChild("SourceBox")
            if sourceBox then
                local sourceText = sourceBox:FindFirstChild("Source")
                if sourceText and sourceText:IsA("TextLabel") or sourceText:IsA("TextBox") then
                    task.spawn(function()
                        local source = localScript.GetSource()
                        sourceText.Text = source
                        sourceDisplayed = true
                    end)
                end
            end
        end
        
        if not sourceDisplayed then
            warn("[Hydroxide] Source display UI not found. Use 'Copy Decompiled Source' from context menu instead.")
        end
    end
end)

viewHiddenPropsContext:SetCallback(function()
    if not gethiddenproperties then
        MessageBox.Show("Not Supported", "Your executor doesn't support gethiddenproperties().\n\nThis is a Potassium-specific feature.", MessageType.OK)
        return
    end
    
    local scriptInstance = selected.logContext.LocalScript.Instance
    local hiddenProps = gethiddenproperties(scriptInstance)
    
    if not hiddenProps or (type(hiddenProps) == "table" and next(hiddenProps) == nil) then
        MessageBox.Show("No Hidden Properties", scriptInstance.Name .. " has no hidden properties.", MessageType.OK)
        return
    end
    
    local propsInfo = string.format("Script: %s\nHidden Properties:\n\n", scriptInstance:GetFullName())
    local count = 0
    
    for propName, propValue in pairs(hiddenProps) do
        count = count + 1
        local valueStr = tostring(propValue)
        if type(propValue) == "table" then
            valueStr = tableToString(propValue)
        elseif typeof(propValue) == "Instance" then
            valueStr = getInstancePath(propValue)
        end
        
        propsInfo = propsInfo .. string.format("[%s] = %s\n", propName, valueStr:sub(1, 100))
    end
    
    propsInfo = propsInfo .. string.format("\nTotal: %d hidden properties", count)
    
    setClipboard(propsInfo)
    MessageBox.Show("Hidden Properties", propsInfo:sub(1, 500) .. "\n\n[Full list copied to clipboard]", MessageType.OK)
end)

viewBytecodeContext:SetCallback(function()
    if not getscriptbytecode then
        MessageBox.Show("Not Supported", "Your executor doesn't support getscriptbytecode().\n\nThis is a Potassium-specific feature.", MessageType.OK)
        return
    end
    
    local scriptInstance = selected.logContext.LocalScript.Instance
    oh.setStatus("Dumping bytecode for " .. scriptInstance.Name .. "...")
    
    task.spawn(function()
        local success, bytecode = pcall(getscriptbytecode, scriptInstance)
        
        if success and bytecode then
            setClipboard(bytecode)
            MessageBox.Show("Success", string.format("Bytecode dumped!\n\nSize: %d bytes\nCopied to clipboard as raw data.", #bytecode), MessageType.OK)
        else
            MessageBox.Show("Error", "Failed to dump bytecode:\n\n" .. tostring(bytecode), MessageType.OK)
        end
        
        oh.setStatus("Ready")
    end)
end)

viewHashContext:SetCallback(function()
    if not getscripthash then
        MessageBox.Show("Not Supported", "Your executor doesn't support getscripthash().\n\nThis is a Potassium-specific feature.", MessageType.OK)
        return
    end
    
    local scriptInstance = selected.logContext.LocalScript.Instance
    local success, hash = pcall(getscripthash, scriptInstance)
    
    if success and hash then
        setClipboard(hash)
        MessageBox.Show("Script Hash", string.format("Script: %s\n\nHash (SHA384):\n%s\n\nCopied to clipboard!", scriptInstance.Name, hash), MessageType.OK)
    else
        MessageBox.Show("Error", "Failed to get script hash:\n\n" .. tostring(hash), MessageType.OK)
    end
end)

viewThreadsContext:SetCallback(function()
    local scriptInstance = selected.logContext.LocalScript.Instance
    local threadInfo = string.format("Script: %s\n\n", scriptInstance:GetFullName())
    
    if getscriptthread then
        local success, thread = pcall(getscriptthread, scriptInstance)
        if success and thread then
            threadInfo = threadInfo .. "Main Thread: " .. tostring(thread) .. "\n"
            threadInfo = threadInfo .. "Status: " .. coroutine.status(thread) .. "\n\n"
            
            if getscriptfromthread then
                local success2, verifyScript = pcall(getscriptfromthread, thread)
                if success2 and verifyScript == scriptInstance then
                    threadInfo = threadInfo .. "✅ Thread verified\n"
                end
            end
        else
            threadInfo = threadInfo .. "❌ No main thread found\n"
        end
    else
        threadInfo = threadInfo .. "getscriptthread() not supported\n"
    end
    
    if getthreadidentity then
        local success, identity = pcall(getthreadidentity)
        if success then
            threadInfo = threadInfo .. "\nCurrent Thread Identity: " .. tostring(identity) .. "\n"
        end
    end
    
    setClipboard(threadInfo)
    MessageBox.Show("Thread Info", threadInfo .. "\n[Copied to clipboard]", MessageType.OK)
end)

local function createProto(index, value)
    local instance = Assets.ProtoPod:Clone()
    local information = instance.Information
    local functionName = getInfo(value).name or ''
    local indexWidth = TextService:GetTextSize(index, 18, "SourceSans", constants.textWidth).X + 8

    if functionName == '' then
        functionName = "Unnamed function"
        information.Label.TextColor3 = oh.Constants.Syntax["unnamed_function"]
    end
    
    information.Index.Text = index
    information.Label.Text = functionName

    information.Index.Size = UDim2.new(0, indexWidth, 0, 20)
    information.Label.Size = UDim2.new(1, -(indexWidth + 20), 1, 0)
    information.Icon.Position = UDim2.new(0, indexWidth, 0, 2)
    information.Label.Position = UDim2.new(0, indexWidth + 20, 0, 0)

    ListButton.new(instance, protosList)
end

local function createConstant(index, value)
    local instance = Assets.ConstantPod:Clone()
    local information = instance.Information
    local valueType = type(value)
    local indexWidth = TextService:GetTextSize(index, 18, "SourceSans", constants.textWidth).X + 8    

    information.Index.Text = index

    information.Index.Size = UDim2.new(0, indexWidth, 0, 20)
    information.Label.Size = UDim2.new(1, -(indexWidth + 20), 1, 0)
    information.Icon.Position = UDim2.new(0, indexWidth, 0, 2)
    information.Label.Position = UDim2.new(0, indexWidth + 20, 0, 0)

    if valueType == "function" then
        local functionName = getInfo(value).name or ''

        if functionName == '' then
            functionName = "Unnamed function"
            information.Label.TextColor3 = oh.Constants.Syntax["unnamed_function"]
        end
        
        information.Label.Text = functionName
    else
        information.Label.Text = toString(value)
    end
    
    ListButton.new(instance, constantsList)
end

-- Log Object
local Log = {}

function Log.new(localScript)
    local log = {}
    local scriptInstance = localScript.Instance
    local button = Assets.ScriptLog:Clone()
    local listButton = ListButton.new(button, scriptList)
    local scriptName = scriptInstance.Name

    button.Name = scriptName
    button:FindFirstChild("Name").Text = scriptName
    button.Protos.Text = #localScript.Protos
    button.Constants.Text = #localScript.Constants

    listButton:SetCallback(function()
        if selected.scriptLog ~= log then
            protosList:Clear()
            constantsList:Clear()
            
            ScriptList.Visible = false
            ScriptInfo.Visible = true

            local nameLength = TextService:GetTextSize(scriptName, 18, "SourceSans", constants.textWidth).X + 20
            
            InfoScript.Icon.Image = icons.LocalScript
            InfoScript.Label.Text = scriptName
            InfoScript.Label.Size = UDim2.new(0, nameLength, 0, 20)
            InfoScript.Position = UDim2.new(1, -nameLength, 0, 0)

            for i,v in pairs(localScript.Protos) do
                createProto(i, v)
            end 

            for i,v in pairs(localScript.Constants) do
                createConstant(i, v)
            end

            local sourceDisplayed = false
            if InfoSource then
                local sourceBox = InfoSource:FindFirstChild("SourceBox")
                if sourceBox then
                    local sourceText = sourceBox:FindFirstChild("Source")
                    if sourceText and (sourceText:IsA("TextLabel") or sourceText:IsA("TextBox")) then
                        task.spawn(function()
                            oh.setStatus("Decompiling " .. scriptName .. "...")
                            local source = localScript.GetSource()
                            sourceText.Text = source
                            sourceDisplayed = true
                            oh.setStatus("Ready")
                        end)
                    end
                end
            end
            
            if not sourceDisplayed then
                print("[Hydroxide] Source display UI not found. Use right-click → 'Copy Decompiled Source' instead.")
            end

            selected.scriptLog = log
        end
    end)

    listButton:SetRightCallback(function()
        selected.logContext = log
    end)

    scriptLogs[scriptInstance] = log

    log.LocalScript = localScript
    log.Button = listButton
    return log
end

-- UI Functionality

local function addScripts(query)
    scriptList:Clear()
    scriptLogs = {}

    for _instance, localScript in pairs(Methods.Scan(query)) do
        Log.new(localScript)
    end

    scriptList:Recalculate()
end

ListSearch.FocusLost:Connect(function(returned)
    if returned then
        addScripts(ListSearch.Text)
        ListSearch.Text = ""
    end
end)

ListRefresh.MouseButton1Click:Connect(function()
    addScripts()
end)

addScripts()

InfoBack.MouseButton1Click:Connect(function()
    ScriptInfo.Visible = false
    ScriptList.Visible = true
end)

local selectedSection = InfoProtos
local selectedSectionButton = InfoOptions.Protos
local animationCache = {}

for _i, sectionButton in pairs(InfoOptions:GetChildren()) do
    if sectionButton:IsA("TextButton") then
        local label = sectionButton.Label
        local enterAnimation = TweenService:Create(label, constants.fadeLength, { TextTransparency = 0 })
        local leaveAnimation = TweenService:Create(label, constants.fadeLength, { TextTransparency = 0.2 })

        sectionButton.MouseButton1Click:Connect(function()
            local section = InfoSections:FindFirstChild(sectionButton.Name)
            animationCache[selectedSectionButton].leave:Play()
            
            selectedSection.Visible = false
            section.Visible = true
            
            selectedSection = section
            selectedSectionButton = sectionButton

        end)

        sectionButton.MouseEnter:Connect(function()
            if selectedSectionButton ~= sectionButton then
                enterAnimation:Play()
            end
        end)

        sectionButton.MouseLeave:Connect(function()
            if selectedSectionButton ~= sectionButton then
                leaveAnimation:Play()
            end
        end)

        animationCache[sectionButton] = {
            enter = enterAnimation,
            leave = leaveAnimation
        }
    end
end

return ScriptScanner