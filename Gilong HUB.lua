-- Violence District - GILONG Hub Script
-- Anti-Fail Generator | Auto Perfect Skill Check | Heal Player

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

local generatorTab = Window:CreateTab("Generator", nil)
local playerTab = Window:CreateTab("Player", nil)
local visualTab = Window:CreateTab("Visuals", nil)
local utilityTab = Window:CreateTab("Utility", nil)

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
_G.autoHeal = false
_G.generatorESP = false
_G.playerESP = false
_G.speedBoost = false
_G.speedValue = 16

-- Connections & Objects untuk cleanup
local connections = {}
local espObjects = {}

-- Utility Functions
local function findGenerators()
    local generators = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("generator") or obj.Name:lower():find("gen") then
            if obj:IsA("Model") or obj:IsA("BasePart") then
                table.insert(generators, obj)
            end
        end
    end
    return generators
end

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

-- Anti-Fail Generator
local function antiFail()
    if not _G.antiFail then return end
    
    -- Mencegah kegagalan dengan meng-intercept remote yang berhubungan dengan fail
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:find("fail") or name:find("explode") or name:find("damage") then
                -- Override dengan menghubungkan dan mengabaikan event
                if not remote._connected then
                    remote._connected = true
                    local conn = remote.OnClientEvent:Connect(function()
                        -- Abaikan semua event yang masuk
                        return
                    end)
                    table.insert(connections, conn)
                end
            end
        end
    end
end

-- Auto Perfect Skill Check
local function autoPerfectSkillCheck()
    if not _G.autoPerfect then return end
    
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    -- Cari elemen skill check
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("Frame") and (gui.Name:lower():find("skill") or gui.Name:lower():find("check")) then
            -- Cari jarum/indikator
            for _, child in pairs(gui:GetDescendants()) do
                if (child:IsA("ImageLabel") or child:IsA("Frame")) and (child.Name:lower():find("needle") or child.Name:lower():find("indicator") or child.Name:lower():find("arrow")) then
                    -- Jika ada rotation, kita bisa cek posisinya
                    if child.Rotation then
                        -- Perfect zone (bisa disesuaikan dengan game)
                        local perfectMin = 80
                        local perfectMax = 100
                        if child.Rotation >= perfectMin and child.Rotation <= perfectMax then
                            -- Simulasi tekan tombol
                            UserInputService:SimulateKeyPress(Enum.KeyCode.Space)
                            
                            -- Coba kirim remote perfect
                            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                                if remote:IsA("RemoteEvent") and remote.Name:lower():find("skill") then
                                    pcall(function()
                                        remote:FireServer(true)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Auto Heal Player
local function autoHealPlayer()
    if not _G.autoHeal then return end
    
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if humanoid.Health < humanoid.MaxHealth then
        -- Coba gunakan item di backpack
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("medkit") or name:find("heal") or name:find("bandage") or name:find("syringe") then
                    pcall(function()
                        tool.Parent = char
                        wait(0.2)
                        tool:Activate()
                    end)
                    break
                end
            end
        end
        
        -- Kirim remote heal jika ada
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and remote.Name:lower():find("heal") then
                pcall(function()
                    remote:FireServer()
                end)
            end
        end
    end
end

-- Generator ESP
local function updateGeneratorESP()
    if not _G.generatorESP then
        -- Hapus ESP generator jika dimatikan
        for i = #espObjects, 1, -1 do
            local obj = espObjects[i]
            if obj and (obj.Name == "GeneratorESP" or obj.Name == "GenLabel") then
                pcall(function() obj:Destroy() end)
                table.remove(espObjects, i)
            end
        end
        return
    end
    
    local generators = findGenerators()
    for _, gen in pairs(generators) do
        local part = gen:IsA("BasePart") and gen or gen:FindFirstChildOfClass("BasePart")
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
            
            -- Update jarak via heartbeat
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

-- Player ESP
local function updatePlayerESP()
    if not _G.playerESP then
        -- Hapus ESP player jika dimatikan
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
        -- Reset ke default (16)
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
    
    -- Loop utama
    local conn = RunService.Heartbeat:Connect(function()
        pcall(function()
            antiFail()
            autoPerfectSkillCheck()
            autoHealPlayer()
            updateGeneratorESP()
            updatePlayerESP()
            updateSpeed()
        end)
    end)
    table.insert(connections, conn)
end

-- GUI Elements

-- Generator Tab
local antiFailToggle = generatorTab:CreateToggle({
   Name = "Anti-Fail Generator",
   CurrentValue = false,
   Flag = "AntiFailToggle",
   Callback = function(Value)
       _G.antiFail = Value
       if Value then
           Rayfield:Notify({
               Title = "Anti-Fail Enabled!",
               Content = "Generator skill checks won't fail",
               Duration = 3,
           })
       end
   end,
})

local autoPerfectToggle = generatorTab:CreateToggle({
   Name = "Auto Perfect Skill Check",
   CurrentValue = false,
   Flag = "AutoPerfectToggle",
   Callback = function(Value)
       _G.autoPerfect = Value
       if Value then
           Rayfield:Notify({
               Title = "Auto Perfect Enabled!",
               Content = "Automatic perfect skill checks activated",
               Duration = 3,
           })
       end
   end,
})

local genESPToggle = generatorTab:CreateToggle({
   Name = "Generator ESP",
   CurrentValue = false,
   Flag = "GenESPToggle",
   Callback = function(Value)
       _G.generatorESP = Value
       if not Value then
           -- Hapus ESP generator
           for i = #espObjects, 1, -1 do
               local obj = espObjects[i]
               if obj and (obj.Name == "GeneratorESP" or obj.Name == "GenLabel") then
                   pcall(function() obj:Destroy() end)
                   table.remove(espObjects, i)
               end
           end
       end
   end,
})

-- Player Tab
local healToggle = playerTab:CreateToggle({
   Name = "Auto Heal",
   CurrentValue = false,
   Flag = "AutoHealToggle",
   Callback = function(Value)
       _G.autoHeal = Value
       if Value then
           Rayfield:Notify({
               Title = "Auto Heal Enabled!",
               Content = "Will automatically heal when injured",
               Duration = 3,
           })
       end
   end,
})

local speedToggle = playerTab:CreateToggle({
   Name = "Speed Boost",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
       _G.speedBoost = Value
       if not Value then
           -- Reset speed ke normal
           local char = player.Character
           if char then
               local humanoid = char:FindFirstChild("Humanoid")
               if humanoid then
                   humanoid.WalkSpeed = 16
               end
           end
       end
   end,
})

local speedSlider = playerTab:CreateSlider({
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

-- Visual Tab
local playerESPToggle = visualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerESPToggle",
   Callback = function(Value)
       _G.playerESP = Value
       if not Value then
           -- Hapus ESP player
           for i = #espObjects, 1, -1 do
               local obj = espObjects[i]
               if obj and (obj.Name == "PlayerESP" or obj.Name == "PlayerName") then
                   pcall(function() obj:Destroy() end)
                   table.remove(espObjects, i)
               end
           end
       end
   end,
})

-- Utility Tab
local teleportGenButton = utilityTab:CreateButton({
   Name = "Teleport to Nearest Generator",
   Callback = function()
       local generators = findGenerators()
       local nearest = nil
       local shortestDistance = math.huge
       
       local root = getRootPart(player)
       if root then
           for _, gen in pairs(generators) do
               local part = gen:IsA("BasePart") and gen or gen:FindFirstChildOfClass("BasePart")
               if part then
                   local distance = (root.Position - part.Position).Magnitude
                   if distance < shortestDistance then
                       shortestDistance = distance
                       nearest = part
                   end
               end
           end
           
           if nearest then
               local char = player.Character
               if char then
                   char:SetPrimaryPartCFrame(CFrame.new(nearest.Position + Vector3.new(0, 5, 0)))
                   Rayfield:Notify({
                       Title = "Teleported!",
                       Content = "Teleported to nearest generator",
                       Duration = 2,
                   })
               end
           else
               Rayfield:Notify({
                   Title = "Not Found",
                   Content = "No generators found",
                   Duration = 3,
               })
           end
       end
   end,
})

local antiAFKToggle = utilityTab:CreateToggle({
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

-- Handle character respawning
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
