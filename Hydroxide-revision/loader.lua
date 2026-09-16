--[[
    Hydroxide (Modernized) - Loader Script
    GitHub: https://github.com/lverniz388829/vigilant-octo-waddle/tree/main/Hydroxide-revision
    
    Execute this script in your executor to load the modernized Hydroxide
]]

local owner = "lverniz388829"
local repo = "vigilant-octo-waddle"
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

webImport("init")
webImport("ui/main")

print("[Hydroxide] Loaded successfully! Press RightShift to toggle UI.")
