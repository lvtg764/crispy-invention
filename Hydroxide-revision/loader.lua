--[[
    Hydroxide (Modernized) - Loader Script
    GitHub: https://github.com/lvtg764/crispy-invention/tree/main/Hydroxide-revision
    
    Execute this script in your executor to load the modernized Hydroxide
]]

local owner = "lvtg764"
local repo = "crispy-invention"
local branch = "main"
local folder = "Hydroxide-revision"

local function webImport(file)
    local url = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s/%s.lua", owner, repo, branch, folder, file)
    local success, result = pcall(game.HttpGetAsync, game, url)
    
    if not success then
        error("Failed to load " .. file .. ": " .. tostring(result))
    end
    
    return loadstring(result, file .. '.lua')()
end

print("[Hydroxide] Loading modernized version...")
print("[Hydroxide] Repository: " .. owner .. "/" .. repo)

-- Only load init.lua - it will handle loading ui/main and everything else
webImport("init")

print("[Hydroxide] Loaded successfully! Press RightShift to toggle UI.")
