-- Violence District - GILONG Hub Script (Updated)
-- Fitur: Anti-Fail, Auto Perfect, Auto Heal, ESP, Speed, Teleport, Auto Vault, Auto Pallet, Killer ESP, dll.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "GILONG Hub",
   Icon = 0,
   LoadingTitle = "Violence District Script",
   LoadingSubtitle = "by GILONG Hub",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "GILONGHub_ViolenceDistrict"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "GILONG Hub | Key",
      Subtitle = "Key System",
      Note = "https://link-hub.net/1392772/AfVHcFNYkLMx",
      FileName = "GILONGHubKey",
      SaveKey = false,
      GrabKeyFromSite = true,
      Key = {"AyamGoreng!"}
   }
})

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
    return plr.Character
end

local function getHumanoid(plr)
    local char = getCharacter(plr)
    return char and char:FindFirstChild("Humanoid")
end

local function getRootPart(plr)
    local char = getCharacter(plr)
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Scan Remote Events
local function scanRemotes()
    local remotes = {}
    local function scan(folder, path)
        for _, obj in pairs(folder:GetChildren()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                remotes[path .. "." .. obj.Name] = obj
            elseif obj:IsA("Folder") then
                scan(obj, path .. "." .. obj.Name)
            end
        end
    end
    if ReplicatedStorage:FindFirstChild("Remotes") then
        scan(ReplicatedStorage.Remotes, "ReplicatedStorage.Remotes")
    end
    return remotes
end

remoteEvents = scanRemotes()

-- Fungsi untuk mengirim remote dengan aman
local function fireRemote(name, ...)
    local remote = remoteEvents[name]
    if remote and remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer(...)
        end)
    end
end

-- Fungsi untuk mendapatkan remote
local function getRemote(name)
    return remoteEvents[name]
end

-- Anti-Fail Generator (memblokir pengiriman fail event)
local function setupAntiFail()
    if not _G.antiFail then return end
    
    -- Daftar remote fail yang mungkin
    local failRemotes = {
        "ReplicatedStorage.Remotes.Generator.SkillCheckFailEvent",
        "ReplicatedStorage.Remotes.Healing.SkillCheckFailEvent"
    }
    
    for _, name in ipairs(failRemotes) do
        local remote = getRemote(name)
        if remote then
            -- Simpan fungsi asli
            if not remote._oldFire then
                remote._oldFire = remote.FireServer
                remote.FireServer = function(self, ...)
                    if _G.antiFail then
                        -- Abaikan pengiriman fail
                        return
                    else
                        return remote._oldFire(self, ...)
                    end
                end
            end
        end
    end
end

-- Auto Perfect Skill Check
local function autoPerfectSkillCheck()
    if not _G.autoPerfect then return end
    
    -- Cari GUI skill check
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    -- Remote untuk hasil skill check
    local resultRemoteGen = getRemote("ReplicatedStorage.Remotes.Generator.SkillCheckResultEvent")
    local resultRemoteHeal = getRemote("ReplicatedStorage.Remotes.Healing.SkillCheckResultEvent")
    
    -- Deteksi skill check muncul (bisa dengan mendeteksi event dari server)
    -- Atau langsung cari elemen GUI
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("Frame") and (gui.Name:lower():find("skill") or gui.Name:lower():find("check")) then
            -- Cari indikator
            for _, child in pairs(gui:GetDescendants()) do
                if (child:IsA("ImageLabel") or child:IsA("Frame")) and (child.Name:lower():find("needle") or child.Name:lower():find("indicator")) then
                    if child.Rotation then
                        -- Jika jarum dekat zona sempurna, kirim hasil sempurna
                        if child.Rotation >= 85 and child.Rotation <= 95 then
                            if resultRemoteGen then
                                fireRemote("ReplicatedStorage.Remotes.Generator.SkillCheckResultEvent", true) -- asumsi parameter boolean sukses
                            end
                            if resultRemoteHeal then
                                fireRemote("ReplicatedStorage.Remotes.Healing.SkillCheckResultEvent", true)
                            end
                            -- Juga tekan tombol untuk jaga-jaga
                            UserInputService:SimulateKeyPress(Enum.KeyCode.Space)
                        end
                    end
                end
            end
        end
    end
end

-- Auto Heal Player
local function autoHeal()
    if not _G.autoHeal then return end
    
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if humanoid.Health < humanoid.MaxHealth then
        -- Gunakan remote heal
        fireRemote("ReplicatedStorage.Remotes.Healing.HealEvent", player) -- asumsi parameter target
        fireRemote("ReplicatedStorage.Remotes.Healing.HealAnim")
        
        -- Coba gunakan item di backpack
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("medkit") or tool.Name:lower():find("bandage")) then
                pcall(function()
                    tool.Parent = char
                    wait(0.2)
                    tool:Activate()
                end)
                break
            end
        end
    end
end

-- Generator ESP
local function updateGeneratorESP()
    if not _G.generatorESP then
        -- Hapus ESP generator
        for i = #espObjects, 1, -1 do
            local obj = espObjects[i]
            if obj and (obj.Name == "GeneratorESP" or obj.Name == "GenLabel") then
                pcall(function() obj:Destroy() end)
                table.remove(espObjects, i)
            end
        end
        return
    end
    
    -- Cari generator (berdasarkan nama atau model)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("generator") or obj.Name:lower():find("gen") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if part and not part:FindFirstChild("GeneratorESP") then
                -- Highlight
                local highlight = Instance.new("Highlight")
                highlight.Name = "GeneratorESP"
                highlight.Parent = part
                highlight.FillColor = Color3.new(0, 1, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.5
                table.insert(espObjects, highlight)
                
                -- Billboard
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "GenLabel"
                billboard.Parent = part
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                table.insert(espObjects, billboard)
                
                local label = Instance.new("TextLabel")
                label.Parent = billboard
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = "GENERATOR"
                label.TextColor3 = Color3.new(0, 1, 0)
                label.TextScaled = true
                label.Font = Enum.Font.GothamBold
                table.insert(espObjects, label)
                
                -- Update jarak
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
                -- Highlight
                local highlight = Instance.new("Highlight")
                highlight.Name = "PlayerESP"
                highlight.Parent = char
                highlight.FillColor = Color3.new(0, 0.5, 1)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.7
                table.insert(espObjects, highlight)
                
                -- Billboard
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "PlayerName"
                billboard.Parent = root
                billboard.Size = UDim2.new(0, 100, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                table.insert(espObjects, billboard)
                
                local label = Instance.new("TextLabel")
                label.Parent = billboard
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = plr.Name
                label.TextColor3 = Color3.new(0, 0.5, 1)
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
    
    -- Asumsi killer adalah player dengan karakter tertentu (misalnya model Jason)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            -- Deteksi killer berdasarkan nama atau attribute
            local isKiller = false
            if char:FindFirstChild("Killer") or char.Name:lower():find("jason") then
                isKiller = true
            end
            if isKiller then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root and not char:FindFirstChild("KillerESP") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "KillerESP"
                    highlight.Parent = char
                    highlight.FillColor = Color3.new(1, 0, 0)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.FillTransparency = 0.3
                    table.insert(espObjects, highlight)
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "KillerName"
                    billboard.Parent = root
                    billboard.Size = UDim2.new(0, 100, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    table.insert(espObjects, billboard)
                    
                    local label = Instance.new("TextLabel")
                    label.Parent = billboard
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = "KILLER\n" .. plr.Name
                    label.TextColor3 = Color3.new(1, 0, 0)
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
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Cari jendela/vault terdekat
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

-- Auto Pallet (jatuhkan pallet jika killer dekat)
local function autoPallet()
    if not _G.autoPallet then return end
    
    local char = player.Character
    if not char then return end
    
    local root = getRootPart(player)
    if not root then return end
    
    -- Cari pallet terdekat
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("pallet") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if part and root then
                local dist = (root.Position - part.Position).Magnitude
                if dist < 8 then
                    -- Cek apakah ada killer di dekat
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

-- Anti Stun (memblokir stun dari pallet)
local function setupAntiStun()
    if not _G.antiStun then return end
    
    local stunRemote = getRemote("ReplicatedStorage.Remotes.Pallet.Jason.Stun")
    if stunRemote then
        if not stunRemote._oldFire then
            stunRemote._oldFire = stunRemote.FireServer
            stunRemote.FireServer = function(self, ...)
                if _G.antiStun then
                    -- Abaikan stun
                    return
                else
                    return stunRemote._oldFire(self, ...)
                end
            end
        end
    end
end

-- Auto Flashlight (aktifkan senter)
local function autoFlashlight()
    if not _G.autoFlashlight then return end
    
    -- Cek apakah ada senter di tangan
    local char = player.Character
    if not char then return end
    
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("flashlight") then
            fireRemote("ReplicatedStorage.Remotes.Items.Flashlight.Activate", tool)
            break
        end
    end
end

-- Infinite Stamina (mengubah nilai stamina atau mencegah pengurangan)
local function infiniteStamina()
    if not _G.infiniteStamina then return end
    
    -- Coba cari nilai stamina di karakter
    local char = player.Character
    if char then
        local stamina = char:FindFirstChild("Stamina")
        if stamina then
            stamina.Value = stamina.MaxValue or 100
        end
        -- Alternatif: cari attribute
        if char:GetAttribute("Stamina") then
            char:SetAttribute("Stamina", char:GetAttribute("MaxStamina") or 100)
        end
    end
end

-- Instant Repair (kirim repair event berulang)
local function instantRepair()
    if not _G.instantRepair then return end
    
    local char = player.Character
    if not char then return end
    
    local root = getRootPart(player)
    if not root then return end
    
    -- Cari generator terdekat
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
    -- Hapus koneksi sebelumnya
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
    
    local conn = RunService.Heartbeat:Connect(function()
        pcall(function()
            setupAntiFail()
            setupAntiStun()
            autoPerfectSkillCheck()
            autoHeal()
            updateGeneratorESP()
            updatePlayerESP()
            updateKillerESP()
            autoVault()
            autoPallet()
            autoFlashlight()
            infiniteStamina()
            instantRepair()
            updateSpeed()
        end)
    end)
    table.insert(connections, conn)
end

-- GUI Elements

-- Generator Tab
local genTab = Window:CreateTab("Generator", nil)

genTab:CreateToggle({
   Name = "Anti-Fail Generator",
   CurrentValue = false,
   Flag = "AntiFailToggle",
   Callback = function(Value)
       _G.antiFail = Value
       Rayfield:Notify({ Title = "Anti-Fail", Content = Value and "Enabled" or "Disabled", Duration = 2 })
   end,
})

genTab:CreateToggle({
   Name = "Auto Perfect Skill Check",
   CurrentValue = false,
   Flag = "AutoPerfectToggle",
   Callback = function(Value)
       _G.autoPerfect = Value
       Rayfield:Notify({ Title = "Auto Perfect", Content = Value and "Enabled" or "Disabled", Duration = 2 })
   end,
})

genTab:CreateToggle({
   Name = "Generator ESP",
   CurrentValue = false,
   Flag = "GenESPToggle",
   Callback = function(Value)
       _G.generatorESP = Value
   end,
})

genTab:CreateToggle({
   Name = "Instant Repair (Spam)",
   CurrentValue = false,
   Flag = "InstantRepairToggle",
   Callback = function(Value)
       _G.instantRepair = Value
   end,
})

-- Survivor Tab
local survivorTab = Window:CreateTab("Survivor", nil)

survivorTab:CreateToggle({
   Name = "Auto Heal",
   CurrentValue = false,
   Flag = "AutoHealToggle",
   Callback = function(Value)
       _G.autoHeal = Value
   end,
})

survivorTab:CreateToggle({
   Name = "Auto Vault",
   CurrentValue = false,
   Flag = "AutoVaultToggle",
   Callback = function(Value)
       _G.autoVault = Value
   end,
})

survivorTab:CreateToggle({
   Name = "Auto Pallet Drop",
   CurrentValue = false,
   Flag = "AutoPalletToggle",
   Callback = function(Value)
       _G.autoPallet = Value
   end,
})

survivorTab:CreateToggle({
   Name = "Auto Flashlight",
   CurrentValue = false,
   Flag = "AutoFlashlightToggle",
   Callback = function(Value)
       _G.autoFlashlight = Value
   end,
})

survivorTab:CreateToggle({
   Name = "Infinite Stamina",
   CurrentValue = false,
   Flag = "InfiniteStaminaToggle",
   Callback = function(Value)
       _G.infiniteStamina = Value
   end,
})

-- Killer Tab (untuk yang main killer)
local killerTab = Window:CreateTab("Killer", nil)

killerTab:CreateToggle({
   Name = "Anti Stun (Pallet)",
   CurrentValue = false,
   Flag = "AntiStunToggle",
   Callback = function(Value)
       _G.antiStun = Value
   end,
})

-- Visuals Tab
local visualTab = Window:CreateTab("Visuals", nil)

visualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerESPToggle",
   Callback = function(Value)
       _G.playerESP = Value
   end,
})

visualTab:CreateToggle({
   Name = "Killer ESP",
   CurrentValue = false,
   Flag = "KillerESPToggle",
   Callback = function(Value)
       _G.killerESP = Value
   end,
})

-- Utility Tab
local utilityTab = Window:CreateTab("Utility", nil)

utilityTab:CreateToggle({
   Name = "Speed Boost",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
       _G.speedBoost = Value
       if not Value then
           local char = player.Character
           if char then
               local humanoid = char:FindFirstChild("Humanoid")
               if humanoid then humanoid.WalkSpeed = 16 end
           end
       end
   end,
})

utilityTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 100},
    Increment = 2,
    Suffix = " Speed",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        _G.speedValue = Value
    end,
})

utilityTab:CreateButton({
   Name = "Teleport to Nearest Generator",
   Callback = function()
       local generators = {}
       for _, obj in pairs(Workspace:GetDescendants()) do
           if obj.Name:lower():find("generator") then
               local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
               if part then table.insert(generators, part) end
           end
       end
       
       local nearest = nil
       local shortest = math.huge
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
               Rayfield:Notify({ Title = "Teleported", Content = "To nearest generator", Duration = 2 })
           else
               Rayfield:Notify({ Title = "Error", Content = "No generator found", Duration = 2 })
           end
       end
   end,
})

utilityTab:CreateToggle({
   Name = "Anti-AFK",
   CurrentValue = false,
   Flag = "AFKToggle",
   Callback = function(Value)
       if Value then
           _G.afkConnection = RunService.Heartbeat:Connect(function()
               VirtualUser:CaptureController()
               VirtualUser:ClickButton2(Vector2.new())
           end)
           table.insert(connections, _G.afkConnection)
       else
           if _G.afkConnection then
               _G.afkConnection:Disconnect()
               _G.afkConnection = nil
           end
       end
   end,
})

-- Start main loop
mainLoop()

-- Handle character respawn
player.CharacterAdded:Connect(function(newChar)
    wait(1)
    if _G.speedBoost then
        local humanoid = newChar:WaitForChild("Humanoid")
        humanoid.WalkSpeed = _G.speedValue
    end
end)

Rayfield:Notify({
   Title = "GILONG Hub Loaded!",
   Content = "Violence District script ready",
   Duration = 5,
})
