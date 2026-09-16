local ModuleScanner = {}
local Methods = import("modules/ModuleScanner")

if not hasMethods(Methods.RequiredMethods) then
    return ModuleScanner
end

local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://11389137937").Base.Body.Pages.ModuleScanner
local Assets = import("rbxassetid://5042114982").ModuleScanner

local Query = Page.Query
local Search = Query.Search
local Refresh = Query.Refresh
local Results = Page.Results.Clip.Content

local moduleList = List.new(Results)
local moduleLogs = {}
local selectedLog

local pathContext = ContextMenuButton.new("rbxassetid://4891705738", "Get Module Path")
local decompileContext = ContextMenuButton.new("rbxassetid://4800244808", "Copy Decompiled Source")
local viewHiddenPropsContext = ContextMenuButton.new("rbxassetid://4891633802", "View Hidden Properties")
moduleList:BindContextMenu(ContextMenu.new({ pathContext, decompileContext, viewHiddenPropsContext }))

pathContext:SetCallback(function()
    local selectedInstance = selectedLog.ModuleScript.Instance
    setClipboard(getInstancePath(selectedInstance))
    MessageBox.Show("Success", ("%s's path was copied to your clipboard."):format(selectedInstance.Name), MessageType.OK)
end)

decompileContext:SetCallback(function()
    local moduleScript = selectedLog.ModuleScript
    MessageBox.Show("Decompiling...", "Please wait, decompiling module source...", MessageType.OK)
    task.spawn(function()
        local source = moduleScript.GetSource()
        setClipboard(source)
        task.wait(0.1)
        MessageBox.Show("Success", "Decompiled source copied to clipboard.\n\nPaste it in a text editor to view.", MessageType.OK)
    end)
end)

viewHiddenPropsContext:SetCallback(function()
    if not gethiddenproperties then
        MessageBox.Show("Not Supported", "Your executor doesn't support gethiddenproperties().\n\nThis is a Potassium-specific feature.", MessageType.OK)
        return
    end
    
    local moduleInstance = selectedLog.ModuleScript.Instance
    local hiddenProps = gethiddenproperties(moduleInstance)
    
    if not hiddenProps or (type(hiddenProps) == "table" and next(hiddenProps) == nil) then
        MessageBox.Show("No Hidden Properties", moduleInstance.Name .. " has no hidden properties.", MessageType.OK)
        return
    end
    
    local propsInfo = string.format("Module: %s\nHidden Properties:\n\n", moduleInstance:GetFullName())
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

-- Log Object

local Log = {}

function Log.new(moduleScript)
    local log = {}
    local moduleInstance = moduleScript.Instance
    local button = Assets.ModuleLog:Clone()
    local listButton = ListButton.new(button, moduleList)
    
    button.Name = moduleInstance.Name
    button:FindFirstChild("Name").Text = moduleInstance.Name
    button.Protos.Text = #moduleScript.Protos
    button.Constants.Text = #moduleScript.Constants

    listButton:SetRightCallback(function()
        selectedLog = log
    end)

    moduleLogs[moduleInstance] = log

    log.ModuleScript = moduleScript
    log.Button = listButton
    return log
end

-- UI Functionality

local function addModules(query)
    moduleList:Clear()
    moduleLogs = {}

    for _moduleInstance, moduleScript in pairs(Methods.Scan(query)) do
        Log.new(moduleScript)
    end

    moduleList:Recalculate()
end

Search.FocusLost:Connect(function(returned)
    if returned then
        addModules(Search.Text)
        Search.Text = ""
    end
end)

Refresh.MouseButton1Click:Connect(function()
    addModules()
end)

addModules()

return ModuleScanner