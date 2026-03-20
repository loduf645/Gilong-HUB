-- Violence District - GILONG Hub (Venyx UI dengan penanganan error loadstring)

-- ========== LOAD VENYX DENGAN PENGECEKAN ==========
local Venyx
local loadSuccess, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ethan5o/venyx/main/source"))()
end)

if loadSuccess and result then
    Venyx = result
else
    warn("GILONG Hub: Gagal memuat Venyx UI. Mencoba URL cadangan...")
    -- Coba URL cadangan (misalnya dari GitHub mirror)
    loadSuccess, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/venyx-ui/venyx/main/source.lua"))()
    end)
    if loadSuccess and result then
        Venyx = result
    else
        warn("GILONG Hub: Tidak dapat memuat Venyx UI. Script tidak dapat berjalan.")
        -- Tampilkan notifikasi sederhana jika gagal
        game.StarterGui:SetCore("SendNotification", {
            Title = "GILONG Hub Error",
            Text = "Gagal memuat UI library. Cek koneksi internet atau coba lagi.",
            Duration = 5
        })
        return
    end
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Global Variables
_G.antiFail = false
_G.autoPerfect = false
_G.autoHeal = false
_G.generatorESP = false
_G.playerESP = false
_G.killerESP = false
_G.itemESP = false
_G.speedBoost = false
_G.speedValue = 16
_G.autoVault = false
_G.autoPallet = false
_G.autoFlashlight = false
_G.infiniteStamina = false
_G.instantRepair = false
_G.antiStun = false

-- Connections & Objects
local connections = {}
local espObjects = {}
local remoteEvents = {}

-- Utility Functions
local function getCharacter(plr)
    return plr and plr.Character
end

local function getHumanoid(plr)
    local char = getCharacter(plr)
    return char and char:FindFirstChild("Humanoid")
end

local function getRootPart(plr)
    local char = getCharacter(plr)
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Safe function
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        -- Hanya tampilkan jika debug
    end
    return result
end

-- Scan Remote Events
local function scanRemotes()
    local remotes = {}
    local function scanFolder(folder, path)
        if not folder then return end
        for _, obj in pairs(folder:GetChildren()) do
            local fullPath = path .. "." .. obj.Name
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                remotes[fullPath] = obj
            elseif obj:IsA("Folder") then
                scanFolder(obj, fullPath)
            end
        end
    end
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if remotesFolder then
        scanFolder(remotesFolder, "ReplicatedStorage.Remotes")
    else
        warn("Remotes folder not found!")
    end
    return remotes
end

remoteEvents = scanRemotes()

local function fireRemote(name, ...)
    local remote = remoteEvents[name]
    if remote and remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer(...)
        end)
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
        if remote and remote:IsA("RemoteEvent") and not remote._oldFire then
            remote._oldFire = remote.FireServer
            remote.FireServer = function(self, ...)
                if _G.antiFail then return else return remote._oldFire(self, ...) end
            end
        end
    end
end

-- Anti Stun
local function setupAntiStun()
    if not _G.antiStun then return end
    local stunRemote = remoteEvents["ReplicatedStorage.Remotes.Pallet.Jason.Stun"]
    if stunRemote and stunRemote:IsA("RemoteEvent") and not stunRemote._oldFire then
        stunRemote._oldFire = stunRemote.FireServer
        stunRemote.FireServer = function(self, ...)
            if _G.antiStun then return else return stunRemote._oldFire(self, ...) end
        end
    end
end

-- Auto Perfect Skill Check
local function autoPerfectSkillCheck()
    if not _G.autoPerfect then return end
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local resultRemoteGen = remoteEvents["ReplicatedStorage.Remotes.Generator.SkillCheckResultEvent"]
    local resultRemoteHeal = remoteEvents["ReplicatedStorage.Remotes.Healing.SkillCheckResultEvent"]
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("Frame") and (gui.Name:lower():find("skill") or gui.Name:lower():find("check")) then
            for _, child in pairs(gui:GetDescendants()) do
                if (child:IsA("ImageLabel") or child:IsA("Frame")) and (child.Name:lower():find("needle") or child.Name:lower():find("indicator")) then
                    if child.Rotation and child.Rotation >= 85 and child.Rotation <= 95 then
                        if resultRemoteGen then fireRemote("ReplicatedStorage.Remotes.Generator.SkillCheckResultEvent", true) end
                        if resultRemoteHeal then fireRemote("ReplicatedStorage.Remotes.Healing.SkillCheckResultEvent", true) end
                        UserInputService:SimulateKeyPress(Enum.KeyCode.Space)
                    end
                end
            end
        end
    end
end

-- Auto Heal
local function autoHeal()
    if not _G.autoHeal then return end
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    if humanoid.Health < humanoid.MaxHealth then
        fireRemote("ReplicatedStorage.Remotes.Healing.HealEvent", player)
        fireRemote("ReplicatedStorage.Remotes.Healing.HealAnim")
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("medkit") or tool.Name:lower():find("bandage")) then
                pcall(function() tool.Parent = char wait(0.2) tool:Activate() end)
                break
            end
        end
    end
end

-- Generator ESP
local function updateGeneratorESP()
    if not _G.generatorESP then
        for i = #espObjects, 1, -1 do
            local obj = espObjects[i]
            if obj and (obj.Name == "GeneratorESP" or obj.Name == "GenLabel") then
                pcall(function() obj:Destroy() end)
                table.remove(espObjects, i)
            end
        end
        return
    end
    for _, obj in pairs(Workspace:GetDescendants()) do
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
                    if not part or not part.Parent or not _G.generatorESP then
                        conn:Disconnect()
                        return
                    end
                    local root = getRootPart(player)
                    if root then
                        local dist = math.floor((root.Position - part.Position).Magnitude)
                        label.Text = "GENERATOR\n" .. dist .. "m"
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
        for i = #espObjects, 1, -1 do
            local obj = espObjects[i]
            if obj and (obj.Name == "PlayerESP" or obj.Name == "PlayerName") then
                pcall(function() obj:Destroy() end)
                table.remove(espObjects, i)
            end
        end
        return
    end
    for _, plr in pairs(Players:GetPlayers()) do
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
        for i = #espObjects, 1, -1 do
            local obj = espObjects[i]
            if obj and (obj.Name == "KillerESP" or obj.Name == "KillerName") then
                pcall(function() obj:Destroy() end)
                table.remove(espObjects, i)
            end
        end
        return
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local isKiller = false
            if char:FindFirstChild("Killer") or char.Name:lower():find("jason") or char.Name:lower():find("masked") or char.Name:lower():find("stalker") then
                isKiller = true
            end
            if isKiller then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root and not char:FindFirstChild("KillerESP") then
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

-- Auto Vault
local function autoVault()
    if not _G.autoVault then return end
    local char = player.Character
    if not char then return end
    local root = getRootPart(player)
    if not root then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("window") or obj.Name:lower():find("vault") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if part and root then
                local dist = (root.Position - part.Position).Magnitude
                if dist < 5 then
                    fireRemote("ReplicatedStorage.Remotes.Window.VaultEvent", part)
                    fireRemote("ReplicatedStorage.Remotes.Window.VaultAnim")
                    break
                end
            end
        end
    end
end

-- Auto Pallet
local function autoPallet()
    if not _G.autoPallet then return end
    local char = player.Character
    if not char then return end
    local root = getRootPart(player)
    if not root then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("pallet") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if part and root then
                local dist = (root.Position - part.Position).Magnitude
                if dist < 8 then
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= player and plr.Character then
                            local killerRoot = getRootPart(plr)
                            if killerRoot then
                                local killerDist = (root.Position - killerRoot.Position).Magnitude
                                if killerDist < 15 then
                                    fireRemote("ReplicatedStorage.Remotes.Pallet.PalletDropEvent", part)
                                    fireRemote("ReplicatedStorage.Remotes.Pallet.PalletDropAnim")
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Auto Flashlight
local function autoFlashlight()
    if not _G.autoFlashlight then return end
    local char = player.Character
    if not char then return end
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("flashlight") then
            fireRemote("ReplicatedStorage.Remotes.Items.Flashlight.Activate", tool)
            break
        end
    end
end

-- Infinite Stamina
local function infiniteStamina()
    if not _G.infiniteStamina then return end
    local char = player.Character
    if char then
        local stamina = char:FindFirstChild("Stamina")
        if stamina and stamina:IsA("NumberValue") then
            stamina.Value = stamina:GetAttribute("MaxValue") or 100
        end
        if char:GetAttribute("Stamina") then
            char:SetAttribute("Stamina", char:GetAttribute("MaxStamina") or 100)
        end
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            pcall(function() humanoid:SetAttribute("Stamina", 100) end)
        end
    end
end

-- Instant Repair
local function instantRepair()
    if not _G.instantRepair then return end
    local char = player.Character
    if not char then return end
    local root = getRootPart(player)
    if not root then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("generator") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if part and root then
                local dist = (root.Position - part.Position).Magnitude
                if dist < 10 then
                    fireRemote("ReplicatedStorage.Remotes.Generator.RepairEvent", part)
                    break
                end
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
            if humanoid and humanoid.WalkSpeed ~= _G.speedValue then
                humanoid.WalkSpeed = _G.speedValue
            end
        end
    else
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.WalkSpeed ~= 16 then
                humanoid.WalkSpeed = 16
            end
        end
    end
end

-- Main Loop
local function mainLoop()
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
    
    local conn = RunService.Heartbeat:Connect(function()
        safeCall(setupAntiFail)
        safeCall(setupAntiStun)
        safeCall(autoPerfectSkillCheck)
        safeCall(autoHeal)
        safeCall(updateGeneratorESP)
        safeCall(updatePlayerESP)
        safeCall(updateKillerESP)
        safeCall(autoVault)
        safeCall(autoPallet)
        safeCall(autoFlashlight)
        safeCall(infiniteStamina)
        safeCall(instantRepair)
        safeCall(updateSpeed)
    end)
    table.insert(connections, conn)
end

-- ========== VENYX UI ==========
local window = Venyx.new({
    Title = "GILONG Hub",
    Subtitle = "Violence District",
    Theme = "Dark",
    TabPadding = 8,
    Size = UDim2.fromOffset(600, 500)
})

-- Generator Tab
local genTab = window:addPage("Generator", "rbxassetid://4483345998")
local genSection = genTab:addSection("Generator Settings")

genSection:addToggle("Anti-Fail", false, function(v) _G.antiFail = v end)
genSection:addToggle("Auto Perfect Skill Check", false, function(v) _G.autoPerfect = v end)
genSection:addToggle("Generator ESP", false, function(v) _G.generatorESP = v end)
genSection:addToggle("Instant Repair (Spam)", false, function(v) _G.instantRepair = v end)

-- Survivor Tab
local survivorTab = window:addPage("Survivor", "rbxassetid://4483345998")
local survivorSection = survivorTab:addSection("Survivor Settings")

survivorSection:addToggle("Auto Heal", false, function(v) _G.autoHeal = v end)
survivorSection:addToggle("Auto Vault", false, function(v) _G.autoVault = v end)
survivorSection:addToggle("Auto Pallet Drop", false, function(v) _G.autoPallet = v end)
survivorSection:addToggle("Auto Flashlight", false, function(v) _G.autoFlashlight = v end)
survivorSection:addToggle("Infinite Stamina", false, function(v) _G.infiniteStamina = v end)

-- Killer Tab
local killerTab = window:addPage("Killer", "rbxassetid://4483345998")
local killerSection = killerTab:addSection("Killer Settings")

killerSection:addToggle("Anti Stun (Pallet)", false, function(v) _G.antiStun = v end)

-- Visuals Tab
local visualTab = window:addPage("Visuals", "rbxassetid://4483345998")
local visualSection = visualTab:addSection("ESP Settings")

visualSection:addToggle("Player ESP", false, function(v) _G.playerESP = v end)
visualSection:addToggle("Killer ESP", false, function(v) _G.killerESP = v end)

-- Utility Tab
local utilityTab = window:addPage("Utility", "rbxassetid://4483345998")
local utilitySection = utilityTab:addSection("Utility Settings")

utilitySection:addToggle("Speed Boost", false, function(v)
    _G.speedBoost = v
    if not v then
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 end
        end
    end
end)

utilitySection:addSlider("Speed Value", 16, 100, 16, 2, function(v) _G.speedValue = v end)

utilitySection:addButton("Teleport to Nearest Generator", function()
    local generators = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("generator") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if part then table.insert(generators, part) end
        end
    end
    local nearest, shortest = nil, math.huge
    local root = getRootPart(player)
    if root then
        for _, gen in ipairs(generators) do
            local dist = (root.Position - gen.Position).Magnitude
            if dist < shortest then
                shortest = dist
                nearest = gen
            end
        end
        if nearest then
            player.Character:SetPrimaryPartCFrame(CFrame.new(nearest.Position + Vector3.new(0, 5, 0)))
            window:Notify("Teleported", "To nearest generator")
        else
            window:Notify("Error", "No generator found")
        end
    end
end)

utilitySection:addToggle("Anti-AFK", false, function(v)
    if v then
        _G.afkConnection = RunService.Heartbeat:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        table.insert(connections, _G.afkConnection)
    elseif _G.afkConnection then
        _G.afkConnection:Disconnect()
        _G.afkConnection = nil
    end
end)

-- Finalize
window:SelectPage(1) -- Pilih tab pertama
window:Notify("GILONG Hub", "Script loaded successfully!")

-- Start main loop
mainLoop()

-- Handle respawn
player.CharacterAdded:Connect(function(newChar)
    wait(1)
    if _G.speedBoost then
        local humanoid = newChar:WaitForChild("Humanoid")
        humanoid.WalkSpeed = _G.speedValue
    end
end)
