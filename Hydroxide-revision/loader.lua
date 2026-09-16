local owner = "lvtg764"
local repo = "crispy-invention"
local branch = "main"
local folder = "Hydroxide-revision"

local function webImport(file)
    return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/%s/%s/%s/%s.lua"):format(owner, repo, branch, folder, file)), file .. '.lua')()
end

webImport("init")
webImport("ui/main")
