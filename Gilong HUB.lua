-- Violence District - GILONG Hub (WindUI dengan fallback dan error handling)
-- Fitur: Generator, Killer, Visuals, Utility (tanpa Survivor & tanpa notifikasi)

-- ========== FUNGSI LOAD LIBRARY DENGAN PENGECEKAN KETAT ==========
local WindUI = nil
local loadSuccess = false

-- Coba beberapa URL
local urls = {
    "https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/main.client.lua",
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/main.client.lua",
    "https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/source.lua",
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/source.lua"
}

for _, url in ipairs(urls) do
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success and result then
        WindUI = result
        loadSuccess = true
        break
    end
end

-- Jika semua gagal, buat UI sederhana
if not loadSuccess then
    warn("GILONG Hub: Gagal memuat WindUI. Membuat UI sederhana...")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GILONGHub_SimpleUI"
    screenGui.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    title.Text = "GILONG Hub (Simple)"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local notice = Instance.new("TextLabel")
    notice.Size = UDim2.new(1, -20, 0, 60)
    notice.Position = UDim2.new(0, 10, 0, 50)
    notice.BackgroundTransparency = 1
    notice.Text = "WindUI gagal dimuat.\nScript tetap berjalan dengan UI minimal."
    notice.TextColor3 = Color3.fromRGB(255, 255, 0)
    notice.TextSize = 14
    notice.TextWrapped = true
    notice.Font = Enum.Font.Gotham
    notice.Parent = frame
    
    local function createToggle(y, name, var)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 35)
        btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        btn.Text = name .. ": OFF"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = frame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            _G[var] = not _G[var]
            btn.Text = name .. ": " .. (_G[var] and "ON" or "OFF")
            btn.BackgroundColor3 = _G[var] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(80, 80, 80)
        end)
    end
    
    createToggle(120, "Anti-Fail", "antiFail")
    createToggle(160, "Auto Perfect", "autoPerfect")
    createToggle(200, "Generator ESP", "generatorESP")
    createToggle(240, "Instant Repair", "instantRepair")
    createToggle(280, "Player ESP", "playerESP")
    createToggle(320, "Killer ESP", "killerESP")
    createToggle(360, "Speed Boost", "speedBoost")
    
    -- Fallback UI tidak memiliki slider speed, tapi speed bisa diatur manual via _G.speedValue default 16
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- Global Variables
_G.antiFail = false
_G.autoPerfect = false
_G.generatorESP = false
_G.playerESP = false
_G.killerESP = false
_G.speedBoost = false
_G.speedValue = 16
_G.instantRepair = false
_G.antiStun = false

-- Connections & Objects
local connections = {}
local espObjects = {}
local remoteEvents = {}

-- Utility Functions
local function getRootPart(plr)
    return plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
end

local function safeCall(func, ...)
    pcall(func, ...)
end

-- Scan Remote Events
local function scanRemotes()
    local remotes = {}
    local function scan(folder, path)
        if not folder then return end
        for _, obj in ipairs(folder:GetChildren()) do
            local fullPath = path .. "." .. obj.Name
            if obj:IsA("RemoteEvent") then
                remotes[fullPath] = obj
            elseif obj:IsA("Folder") then
                scan(obj, fullPath)
            end
        end
    end
    scan(ReplicatedStorage:FindFirstChild("Remotes"), "ReplicatedStorage.Remotes")
    return remotes
end

remoteEvents = scanRemotes()

local function fireRemote(name, ...)
    local remote = remoteEvents[name]
    if remote then
        pcall(function() remote:FireServer(...) end)
    end
end

-- Anti-Fail
local function setupAntiFail()
    if not _G.antiFail then return end
    local failRemotes = {
        "ReplicatedStorage.Remotes.Generator.SkillCheckFailEvent",
        "ReplicatedStorage.Remotes.Healing.SkillCheckFailEvent"
    }
    for _, name in ipairs(failRemotes) do
        local remote = remoteEvents[name]
        if remote and not remote._oldFire then
            remote._oldFire = remote.FireServer
            remote.FireServer = function(self, ...)
                if _G.antiFail then return end
                return remote._oldFire(self, ...)
            end
        end
    end
end

-- Anti Stun
local function setupAntiStun()
    if not _G.antiStun then return end
    local stunRemote = remoteEvents["ReplicatedStorage.Remotes.Pallet.Jason.Stun"]
    if stunRemote and not stunRemote._oldFire then
        stunRemote._oldFire = stunRemote.FireServer
        stunRemote.FireServer = function(self, ...)
            if _G.antiStun then return end
            return stunRemote._oldFire(self, ...)
        end
    end
end

-- Auto Perfect Skill Check
local function autoPerfectSkillCheck()
    if not _G.autoPerfect then return end
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local genRemote = remoteEvents["ReplicatedStorage.Remotes.Generator.SkillCheckResultEvent"]
    local healRemote = remoteEvents["ReplicatedStorage.Remotes.Healing.SkillCheckResultEvent"]
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("Frame") and (gui.Name:lower():find("skill") or gui.Name:lower():find("check")) then
            for _, child in ipairs(gui:GetDescendants()) do
                if child:IsA("ImageLabel") and (child.Name:lower():find("needle") or child.Name:lower():find("indicator")) then
                    if child.Rotation and child.Rotation >= 85 and child.Rotation <= 95 then
                        if genRemote then fireRemote("ReplicatedStorage.Remotes.Generator.SkillCheckResultEvent", true) end
                        if healRemote then fireRemote("ReplicatedStorage.Remotes.Healing.SkillCheckResultEvent", true) end
                        UserInputService:SimulateKeyPress(Enum.KeyCode.Space)
                    end
                end
            end
        end
    end
end

-- Generator ESP
local function updateGeneratorESP()
    if not _G.generatorESP then
        for _, obj in ipairs(espObjects) do pcall(function() obj:Destroy() end) end
        espObjects = {}
        return
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("generator") or obj.Name:lower():find("gen") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if part and not part:FindFirstChild("GeneratorESP") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "GeneratorESP"
                highlight.Parent = part
                highlight.FillColor = Color3.new(0,1,0)
                highlight.OutlineColor = Color3.new(1,1,1)
                highlight.FillTransparency = 0.5
                table.insert(espObjects, highlight)
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "GenLabel"
                billboard.Parent = part
                billboard.Size = UDim2.new(0,100,0,50)
                billboard.StudsOffset = Vector3.new(0,3,0)
                billboard.AlwaysOnTop = true
                table.insert(espObjects, billboard)
                
                local label = Instance.new("TextLabel")
                label.Parent = billboard
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.Text = "GENERATOR"
                label.TextColor3 = Color3.new(0,1,0)
                label.TextScaled = true
                label.Font = Enum.Font.GothamBold
                table.insert(espObjects, label)
                
                local conn
                conn = RunService.Heartbeat:Connect(function()
                    if not part or not part.Parent or not _G.generatorESP then conn:Disconnect() return end
                    local root = getRootPart(player)
                    if root then
                        label.Text = "GENERATOR\n" .. math.floor((root.Position - part.Position).Magnitude) .. "m"
                    end
                end)
                table.insert(connections, conn)
            end
        end
    end
end

-- Player ESP
local function updatePlayerESP()
    if not _G.playerESP then
        for _, obj in ipairs(espObjects) do if obj.Name == "PlayerESP" or obj.Name == "PlayerName" then pcall(function() obj:Destroy() end) end end
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and not char:FindFirstChild("PlayerESP") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "PlayerESP"
                highlight.Parent = char
                highlight.FillColor = Color3.new(0,0.5,1)
                highlight.OutlineColor = Color3.new(1,1,1)
                highlight.FillTransparency = 0.7
                table.insert(espObjects, highlight)
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "PlayerName"
                billboard.Parent = root
                billboard.Size = UDim2.new(0,100,0,30)
                billboard.StudsOffset = Vector3.new(0,3,0)
                billboard.AlwaysOnTop = true
                table.insert(espObjects, billboard)
                
                local label = Instance.new("TextLabel")
                label.Parent = billboard
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.Text = plr.Name
                label.TextColor3 = Color3.new(0,0.5,1)
                label.TextScaled = true
                label.Font = Enum.Font.Gotham
                table.insert(espObjects, label)
            end
        end
    end
end

-- Killer ESP
local function updateKillerESP()
    if not _G.killerESP then
        for _, obj in ipairs(espObjects) do if obj.Name == "KillerESP" or obj.Name == "KillerName" then pcall(function() obj:Destroy() end) end end
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and (char.Name:lower():find("jason") or char:FindFirstChild("Killer")) then
                if not char:FindFirstChild("KillerESP") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "KillerESP"
                    highlight.Parent = char
                    highlight.FillColor = Color3.new(1,0,0)
                    highlight.OutlineColor = Color3.new(1,1,1)
                    highlight.FillTransparency = 0.3
                    table.insert(espObjects, highlight)
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "KillerName"
                    billboard.Parent = root
                    billboard.Size = UDim2.new(0,100,0,30)
                    billboard.StudsOffset = Vector3.new(0,3,0)
                    billboard.AlwaysOnTop = true
                    table.insert(espObjects, billboard)
                    
                    local label = Instance.new("TextLabel")
                    label.Parent = billboard
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.Text = "KILLER\n" .. plr.Name
                    label.TextColor3 = Color3.new(1,0,0)
                    label.TextScaled = true
                    label.Font = Enum.Font.GothamBold
                    table.insert(espObjects, label)
                end
            end
        end
    end
end

-- Instant Repair
local function instantRepair()
    if not _G.instantRepair then return end
    local root = getRootPart(player)
    if not root then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("generator") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if part and (root.Position - part.Position).Magnitude < 10 then
                fireRemote("ReplicatedStorage.Remotes.Generator.RepairEvent", part)
                break
            end
        end
    end
end

-- Speed Boost
local function updateSpeed()
    if _G.speedBoost then
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = _G.speedValue end
        end
    else
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 end
        end
    end
end

-- Main Loop
local function mainLoop()
    for _, conn in ipairs(connections) do pcall(function() conn:Disconnect() end) end
    connections = {}
    local conn = RunService.Heartbeat:Connect(function()
        safeCall(setupAntiFail)
        safeCall(setupAntiStun)
        safeCall(autoPerfectSkillCheck)
        safeCall(updateGeneratorESP)
        safeCall(updatePlayerESP)
        safeCall(updateKillerESP)
        safeCall(instantRepair)
        safeCall(updateSpeed)
    end)
    table.insert(connections, conn)
end

-- Hanya buat window WindUI jika library berhasil dimuat
if loadSuccess and WindUI then
    local Window = WindUI:CreateWindow({
        Title = "GILONG Hub - Violence District",
        Icon = "skull",
        Author = "GILONG",
        Folder = "GILONGHub",
        Size = UDim2.fromOffset(600, 500),
        Theme = "Dark",
        Acrylic = false,
        HideSearchBar = true,
        SideBarWidth = 180,
    })

    Window:Tag({ Title = "v1.0", Color = Color3.fromHex("#30ff6a") })

    local GeneratorTab = Window:Tab({ Title = "Generator", Icon = "zap" })
    local GenSection = GeneratorTab:Section({ Title = "Generator Settings", Opened = true })
    GenSection:Toggle({ Title = "Anti-Fail Generator", Value = false, Callback = function(v) _G.antiFail = v end })
    GenSection:Toggle({ Title = "Auto Perfect Skill Check", Value = false, Callback = function(v) _G.autoPerfect = v end })
    GenSection:Toggle({ Title = "Generator ESP", Value = false, Callback = function(v) _G.generatorESP = v end })
    GenSection:Toggle({ Title = "Instant Repair (Spam)", Value = false, Callback = function(v) _G.instantRepair = v end })

    local KillerTab = Window:Tab({ Title = "Killer", Icon = "sword" })
    local KillerSection = KillerTab:Section({ Title = "Killer Settings", Opened = true })
    KillerSection:Toggle({ Title = "Anti Stun (Pallet)", Value = false, Callback = function(v) _G.antiStun = v end })

    local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
    local VisualSection = VisualsTab:Section({ Title = "ESP Settings", Opened = true })
    VisualSection:Toggle({ Title = "Player ESP", Value = false, Callback = function(v) _G.playerESP = v end })
    VisualSection:Toggle({ Title = "Killer ESP", Value = false, Callback = function(v) _G.killerESP = v end })

    local UtilityTab = Window:Tab({ Title = "Utility", Icon = "settings" })
    local UtilSection = UtilityTab:Section({ Title = "Utility Settings", Opened = true })
    UtilSection:Toggle({ Title = "Speed Boost", Value = false, Callback = function(v)
        _G.speedBoost = v
        if not v then
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
        end
    end})
    UtilSection:Slider({ Title = "Speed Value", Value = { Min = 16, Max = 100, Default = 16 }, Callback = function(v) _G.speedValue = v end })
    UtilSection:Button({ Title = "Teleport to Nearest Generator", Callback = function()
        local gens = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("generator") then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
                if part then table.insert(gens, part) end
            end
        end
        local nearest, distMin = nil, math.huge
        local root = getRootPart(player)
        if root then
            for _, g in ipairs(gens) do
                local d = (root.Position - g.Position).Magnitude
                if d < distMin then
                    distMin = d
                    nearest = g
                end
            end
            if nearest then
                player.Character:SetPrimaryPartCFrame(CFrame.new(nearest.Position + Vector3.new(0,5,0)))
            end
        end
    end})
    UtilSection:Toggle({ Title = "Anti-AFK", Value = false, Callback = function(v)
        if v then
            _G.afkConn = RunService.Heartbeat:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            table.insert(connections, _G.afkConn)
        elseif _G.afkConn then
            _G.afkConn:Disconnect()
            _G.afkConn = nil
        end
    end})
end

-- Mulai loop utama
mainLoop()

-- Handle respawn
player.CharacterAdded:Connect(function()
    wait(1)
    if _G.speedBoost then
        local hum = player.Character and player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = _G.speedValue end
    end
end)
