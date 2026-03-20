-- Violence District - GILONG Hub (UI Sederhana)
-- Fitur: Generator, Killer, Visuals, Utility (tanpa notifikasi, tanpa library eksternal)

-- ========== UI SEDERHANA ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GILONGHub_UI"
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
title.Text = "GILONG Hub - Violence District"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
end)

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -80, 0, 8)
minBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
minBtn.Text = "_"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 18
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(1, 0)
minCorner.Parent = minBtn

local minimized = false
local function toggleMinimize()
    minimized = not minimized
    if minimized then
        mainFrame.Size = UDim2.new(0, 350, 0, 45)
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child:IsA("TextButton") and child ~= closeBtn and child ~= minBtn then
                child.Visible = false
            elseif child:IsA("TextLabel") and child ~= title then
                child.Visible = false
            elseif child:IsA("ScrollingFrame") then
                child.Visible = false
            end
        end
        minBtn.Text = "+"
    else
        mainFrame.Size = UDim2.new(0, 350, 0, 500)
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child:IsA("TextButton") and child ~= closeBtn and child ~= minBtn then
                child.Visible = true
            elseif child:IsA("TextLabel") and child ~= title then
                child.Visible = true
            elseif child:IsA("ScrollingFrame") then
                child.Visible = true
            end
        end
        minBtn.Text = "_"
    end
end
minBtn.MouseButton1Click:Connect(toggleMinimize)

-- Tab buttons
local tabButtons = {}
local tabs = {}

local function createTab(name, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, -5, 0, 35)
    btn.Position = UDim2.new(0.02 + (y-1)*0.34, 0, 0, 55)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    return btn
end

local genTabBtn = createTab("Generator", 1)
local killerTabBtn = createTab("Killer", 2)
local visualTabBtn = createTab("Visuals", 3)
local utilTabBtn = createTab("Utility", 4)

-- Content frame for toggles
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(0.96, 0, 0, 350)
contentFrame.Position = UDim2.new(0.02, 0, 0, 100)
contentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = contentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Parent = contentFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.Parent = contentFrame

-- Function to create toggle button inside content frame
local function createToggle(text, var)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Parent = contentFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        _G[var] = not _G[var]
        btn.Text = text .. ": " .. (_G[var] and "ON" or "OFF")
        btn.BackgroundColor3 = _G[var] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 70)
    end)
    
    return btn
end

local function createSlider(text, var, min, max, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = contentFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 15)
    sliderBg.Position = UDim2.new(0, 0, 0, 25)
    sliderBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    sliderBg.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local dragging = false
    local function updateSlider(input)
        local pos = input.Position.X - sliderBg.AbsolutePosition.X
        local width = sliderBg.AbsoluteSize.X
        local percent = math.clamp(pos / width, 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        local value = math.floor(min + (max-min) * percent)
        _G[var] = value
        label.Text = text .. ": " .. value
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    sliderBg.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return frame
end

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Parent = contentFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
end

-- Function to clear content frame and show toggles for selected tab
local function showTab(tabName)
    for _, child in ipairs(contentFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if tabName == "Generator" then
        createToggle("Anti-Fail", "antiFail")
        createToggle("Auto Perfect", "autoPerfect")
        createToggle("Generator ESP", "generatorESP")
        createToggle("Instant Repair", "instantRepair")
    elseif tabName == "Killer" then
        createToggle("Anti Stun", "antiStun")
    elseif tabName == "Visuals" then
        createToggle("Player ESP", "playerESP")
        createToggle("Killer ESP", "killerESP")
    elseif tabName == "Utility" then
        createToggle("Speed Boost", "speedBoost")
        createSlider("Speed Value", "speedValue", 16, 100, 16)
        createButton("Teleport to Nearest Generator", function()
            local gens = {}
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("generator") or obj.Name:lower():find("gen") then
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
        end)
        createToggle("Anti-AFK", "antiAFK")
    end
end

-- Tab button events
genTabBtn.MouseButton1Click:Connect(function() showTab("Generator") end)
killerTabBtn.MouseButton1Click:Connect(function() showTab("Killer") end)
visualTabBtn.MouseButton1Click:Connect(function() showTab("Visuals") end)
utilTabBtn.MouseButton1Click:Connect(function() showTab("Utility") end)

-- Default tab
showTab("Generator")

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
_G.antiAFK = false

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

-- Anti-AFK
local function setupAntiAFK()
    if _G.antiAFK then
        if not _G.afkConn then
            _G.afkConn = RunService.Heartbeat:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            table.insert(connections, _G.afkConn)
        end
    else
        if _G.afkConn then
            _G.afkConn:Disconnect()
            _G.afkConn = nil
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
        safeCall(setupAntiAFK)
    end)
    table.insert(connections, conn)
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

-- Notifikasi sederhana (opsional)
-- Tidak menggunakan notifikasi bawaan untuk menghindari error
