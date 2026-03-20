local loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.client.lua"))
    if loader then
        loader() -- Jalankan loader untuk mendefinisikan variabel global WindUI
        return getfenv().WindUI -- Ambil variabel WindUI dari environment setelah loader dijalankan
    end
    return nil
end)

if not loadSuccess or not WindUI then
    warn("GILONG Hub: Gagal memuat WindUI. Script tidak dapat berjalan.")
    return
end

-- ========== SERVICES ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ========== GLOBAL VARIABLES ==========
_G.antiFail = false
_G.autoPerfect = false
_G.generatorESP = false
_G.instantRepair = false

-- ========== CONNECTIONS & OBJECTS ==========
local connections = {}
local espObjects = {}
local remoteEvents = {}

-- ========== UTILITY FUNCTIONS ==========
local function getRootPart(plr)
    return plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
end

local function safeCall(func, ...)
    pcall(func, ...)
end

-- ========== SCAN REMOTE EVENTS ==========
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

-- ========== ANTI-FAIL GENERATOR ==========
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

-- ========== AUTO PERFECT SKILL CHECK ==========
local function autoPerfectSkillCheck()
    if not _G.autoPerfect then return end
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local genRemote = remoteEvents["ReplicatedStorage.Remotes.Generator.SkillCheckResultEvent"]
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("Frame") and (gui.Name:lower():find("skill") or gui.Name:lower():find("check")) then
            for _, child in ipairs(gui:GetDescendants()) do
                if child:IsA("ImageLabel") and (child.Name:lower():find("needle") or child.Name:lower():find("indicator")) then
                    if child.Rotation and child.Rotation >= 85 and child.Rotation <= 95 then
                        if genRemote then fireRemote("ReplicatedStorage.Remotes.Generator.SkillCheckResultEvent", true) end
                        UserInputService:SimulateKeyPress(Enum.KeyCode.Space)
                    end
                end
            end
        end
    end
end

-- ========== GENERATOR ESP ==========
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

-- ========== INSTANT REPAIR ==========
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

-- ========== MAIN LOOP ==========
local function mainLoop()
    for _, conn in ipairs(connections) do pcall(function() conn:Disconnect() end) end
    connections = {}
    local conn = RunService.Heartbeat:Connect(function()
        safeCall(setupAntiFail)
        safeCall(autoPerfectSkillCheck)
        safeCall(updateGeneratorESP)
        safeCall(instantRepair)
    end)
    table.insert(connections, conn)
end

-- ========== WINDOW UI ==========
local Window = WindUI:CreateWindow({
    Title = "GILONG Hub - Generator Only",
    Icon = "zap",
    Author = "GILONG",
    Folder = "GILONGHub_Generator",
    Size = UDim2.fromOffset(500, 250),
    Theme = "Dark",
    Acrylic = false,
    HideSearchBar = true,
    SideBarWidth = 0, -- Tidak perlu sidebar karena hanya satu tab
})

Window:Tag({ Title = "v1.0", Color = Color3.fromHex("#30ff6a") })

local GenTab = Window:Tab({ Title = "Generator", Icon = "zap" })
local GenSection = GenTab:Section({ Title = "Generator Settings", Opened = true })

GenSection:Toggle({
    Title = "Anti-Fail Generator",
    Value = false,
    Callback = function(v) _G.antiFail = v end
})
GenSection:Toggle({
    Title = "Auto Perfect Skill Check",
    Value = false,
    Callback = function(v) _G.autoPerfect = v end
})
GenSection:Toggle({
    Title = "Generator ESP",
    Value = false,
    Callback = function(v) _G.generatorESP = v end
})
GenSection:Toggle({
    Title = "Instant Repair (Spam)",
    Value = false,
    Callback = function(v) _G.instantRepair = v end
})

-- ========== START ==========
mainLoop()

-- ========== CLEANUP ON CHARACTER RESPAWN ==========
player.CharacterAdded:Connect(function()
    wait(1)
    -- Tidak ada yang perlu di-reset selain koneksi (sudah di-handle mainLoop)
end)
