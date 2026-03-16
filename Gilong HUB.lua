-- Simple Aimlock Script with GUI + ESP
-- Target Selection & Camera Lock System + ESP (Nama, Darah, Jarak)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Variables dengan validasi
_G.aimlockEnabled = false
_G.selectedTarget = nil
_G.aimSmoothness = 0.2
_G.lockKey = Enum.KeyCode.Q
_G.aimPart = "Head" -- Bisa diganti: Head, HumanoidRootPart, UpperTorso
_G.espEnabled = false -- Fitur ESP

-- Validasi target
local function isValidTarget(target)
    return target and target.Character and target.Character:FindFirstChild(_G.aimPart) and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0
end

-- Create GUI dengan perlindungan
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimlockGUI"
ScreenGui.Parent = game:FindFirstChild("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 520) -- Ditambah tinggi untuk tombol ESP
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

-- Shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = MainFrame
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)

-- Add corner radius
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Title with gradient
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
Title.Text = "🎯 AIMLOCK + ESP SYSTEM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Gradient for title
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 200))
})
Gradient.Parent = Title

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Toggle Button Aimlock
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0, 55)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
ToggleButton.Text = "⚡ AIMLOCK: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = MainFrame
ToggleButton.AutoButtonColor = false

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

-- Toggle Button ESP
local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(0.9, 0, 0, 40)
ESPButton.Position = UDim2.new(0.05, 0, 0, 100)
ESPButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ESPButton.Text = "👁️ ESP: OFF"
ESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPButton.TextSize = 16
ESPButton.Font = Enum.Font.GothamBold
ESPButton.Parent = MainFrame
ESPButton.AutoButtonColor = false

local ESPCorner = Instance.new("UICorner")
ESPCorner.CornerRadius = UDim.new(0, 8)
ESPCorner.Parent = ESPButton

-- Smoothness Control
local SmoothnessFrame = Instance.new("Frame")
SmoothnessFrame.Size = UDim2.new(0.9, 0, 0, 70)
SmoothnessFrame.Position = UDim2.new(0.05, 0, 0, 145)
SmoothnessFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
SmoothnessFrame.Parent = MainFrame

local SmoothnessCorner = Instance.new("UICorner")
SmoothnessCorner.CornerRadius = UDim.new(0, 8)
SmoothnessCorner.Parent = SmoothnessFrame

-- Smoothness Slider Label
local SmoothnessLabel = Instance.new("TextLabel")
SmoothnessLabel.Size = UDim2.new(1, -10, 0, 25)
SmoothnessLabel.Position = UDim2.new(0, 5, 0, 5)
SmoothnessLabel.BackgroundTransparency = 1
SmoothnessLabel.Text = "Smoothness: 0.2"
SmoothnessLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
SmoothnessLabel.TextSize = 14
SmoothnessLabel.TextXAlignment = Enum.TextXAlignment.Left
SmoothnessLabel.Font = Enum.Font.GothamBold
SmoothnessLabel.Parent = SmoothnessFrame

-- Smoothness Slider
local SmoothnessSlider = Instance.new("TextBox")
SmoothnessSlider.Size = UDim2.new(0.8, 0, 0, 30)
SmoothnessSlider.Position = UDim2.new(0.1, 0, 0, 30)
SmoothnessSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
SmoothnessSlider.Text = "0.2"
SmoothnessSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothnessSlider.PlaceholderText = "Smoothness (0.05 - 1.0)"
SmoothnessSlider.Font = Enum.Font.Gotham
SmoothnessSlider.TextSize = 14
SmoothnessSlider.ClearTextOnFocus = false
SmoothnessSlider.Parent = SmoothnessFrame

local SmoothnessSliderCorner = Instance.new("UICorner")
SmoothnessSliderCorner.CornerRadius = UDim.new(0, 6)
SmoothnessSliderCorner.Parent = SmoothnessSlider

-- Player List Label
local ListLabel = Instance.new("TextLabel")
ListLabel.Size = UDim2.new(1, -20, 0, 25)
ListLabel.Position = UDim2.new(0, 10, 0, 225)
ListLabel.BackgroundTransparency = 1
ListLabel.Text = "👥 SELECT TARGET:"
ListLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
ListLabel.TextSize = 14
ListLabel.TextXAlignment = Enum.TextXAlignment.Left
ListLabel.Font = Enum.Font.GothamBold
ListLabel.Parent = MainFrame

-- Scroll Frame for Player List
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0.9, 0, 0, 160)
ScrollFrame.Position = UDim2.new(0.05, 0, 0, 255)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255)
ScrollFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = ScrollFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Parent = ScrollFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingBottom = UDim.new(0, 5)
UIPadding.Parent = ScrollFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 40)
StatusLabel.Position = UDim2.new(0.05, 0, 0, 425)
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
StatusLabel.Text = "⏳ Status: No target selected"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusLabel

-- ESP Status Label (kecil di bawah status)
local ESPStatusLabel = Instance.new("TextLabel")
ESPStatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
ESPStatusLabel.Position = UDim2.new(0.05, 0, 0, 470)
ESPStatusLabel.BackgroundTransparency = 1
ESPStatusLabel.Text = "ESP: OFF"
ESPStatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
ESPStatusLabel.TextSize = 11
ESPStatusLabel.Font = Enum.Font.Gotham
ESPStatusLabel.Parent = MainFrame

-- ================== ESP SYSTEM ==================
local ESPHolder = Instance.new("Folder")
ESPHolder.Name = "ESPHolder"
ESPHolder.Parent = ScreenGui

local function createESP(player)
    if player == LocalPlayer then return end
    
    -- Hapus ESP lama jika ada
    local existing = ESPHolder:FindFirstChild(player.Name)
    if existing then existing:Destroy() end
    
    -- Buat BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name
    billboard.Adornee = player.Character and player.Character:FindFirstChild("Head") or nil
    billboard.Size = UDim2.new(0, 200, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = _G.espEnabled
    billboard.Parent = ESPHolder
    
    -- Background
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.3
    bg.BorderSizePixel = 0
    bg.Parent = billboard
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 5)
    bgCorner.Parent = bg
    
    -- Nama player
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 25)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = bg
    
    -- Health bar background
    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(0.9, 0, 0, 10)
    healthBg.Position = UDim2.new(0.05, 0, 0, 30)
    healthBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = bg
    
    local healthBgCorner = Instance.new("UICorner")
    healthBgCorner.CornerRadius = UDim.new(0, 3)
    healthBgCorner.Parent = healthBg
    
    -- Health bar fill
    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBg
    
    local healthBarCorner = Instance.new("UICorner")
    healthBarCorner.CornerRadius = UDim.new(0, 3)
    healthBarCorner.Parent = healthBar
    
    -- Health text
    local healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.Size = UDim2.new(1, 0, 0, 15)
    healthText.Position = UDim2.new(0, 0, 0, 45)
    healthText.BackgroundTransparency = 1
    healthText.Text = "100/100"
    healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthText.TextSize = 12
    healthText.Font = Enum.Font.Gotham
    healthText.Parent = bg
    
    -- Jarak (studs)
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0, 15)
    distanceLabel.Position = UDim2.new(0, 0, 0, 60)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0 studs"
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 0)
    distanceLabel.TextSize = 11
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.Parent = bg
    
    -- Update fungsi untuk ESP
    local function updateESP()
        if not _G.espEnabled or not player.Character or not player.Character:FindFirstChild("Head") then
            billboard.Enabled = false
            return
        end
        
        billboard.Enabled = true
        billboard.Adornee = player.Character.Head
        
        -- Update health
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            local health = humanoid.Health
            local maxHealth = humanoid.MaxHealth
            local percent = math.clamp(health / maxHealth, 0, 1)
            healthBar.Size = UDim2.new(percent, 0, 1, 0)
            
            -- Warna health bar berdasarkan persentase
            if percent > 0.6 then
                healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            elseif percent > 0.3 then
                healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
            else
                healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
            
            healthText.Text = string.format("%.0f/%.0f", health, maxHealth)
        end
        
        -- Update jarak
        local localChar = LocalPlayer.Character
        if localChar and localChar:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (localChar.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            distanceLabel.Text = string.format("%.1f studs", dist)
        end
    end
    
    -- Hubungkan update ke RenderStepped (akan dilakukan secara terpusat nanti)
    -- Simpan fungsi update di billboard untuk dipanggil nanti
    billboard.UpdateESP = updateESP
end

-- Fungsi untuk menghapus ESP player
local function removeESP(player)
    local esp = ESPHolder:FindFirstChild(player.Name)
    if esp then
        esp:Destroy()
    end
end

-- Update semua ESP (dipanggil setiap frame)
local function updateAllESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local esp = ESPHolder:FindFirstChild(player.Name)
            if esp then
                if _G.espEnabled and player.Character then
                    esp.UpdateESP()
                else
                    esp.Enabled = false
                end
            elseif _G.espEnabled and player.Character then
                -- Buat ESP jika belum ada
                createESP(player)
            end
        end
    end
end

-- Toggle ESP
ESPButton.MouseButton1Click:Connect(function()
    _G.espEnabled = not _G.espEnabled
    
    if _G.espEnabled then
        ESPButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        ESPButton.Text = "👁️ ESP: ON"
        ESPStatusLabel.Text = "ESP: ON"
        ESPStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        -- Buat ESP untuk semua player yang sudah ada
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESP(player)
            end
        end
    else
        ESPButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        ESPButton.Text = "👁️ ESP: OFF"
        ESPStatusLabel.Text = "ESP: OFF"
        ESPStatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        
        -- Hapus semua ESP
        for _, child in pairs(ESPHolder:GetChildren()) do
            child:Destroy()
        end
    end
end)

-- Smoothness input handler
SmoothnessSlider.FocusLost:Connect(function(enterPressed)
    local value = tonumber(SmoothnessSlider.Text)
    if value then
        _G.aimSmoothness = math.clamp(value, 0.05, 1)
        SmoothnessSlider.Text = string.format("%.2f", _G.aimSmoothness)
        SmoothnessLabel.Text = "Smoothness: " .. string.format("%.2f", _G.aimSmoothness)
    else
        SmoothnessSlider.Text = string.format("%.2f", _G.aimSmoothness)
    end
end)

-- Toggle Aimlock
ToggleButton.MouseButton1Click:Connect(function()
    _G.aimlockEnabled = not _G.aimlockEnabled
    
    if _G.aimlockEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 255, 70)
        ToggleButton.Text = "⚡ AIMLOCK: ON"
        
        if not _G.selectedTarget then
            StatusLabel.Text = "⚠️ Warning: No target selected!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        elseif not isValidTarget(_G.selectedTarget) then
            StatusLabel.Text = "⚠️ Target invalid! Select new target"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            _G.selectedTarget = nil
            updatePlayerList()
        end
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        ToggleButton.Text = "⚡ AIMLOCK: OFF"
        StatusLabel.Text = "⏸️ Aimlock disabled"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- Fungsi update player list (sama seperti sebelumnya, tapi sekarang dengan informasi ESP)
local function updatePlayerList()
    -- Clear existing buttons
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local playerCount = 0
    
    -- Create button for each player
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            playerCount = playerCount + 1
            local isValid = isValidTarget(player)
            local status = isValid and "✅" or "❌"
            local healthText = ""
            
            if isValid and player.Character and player.Character:FindFirstChild("Humanoid") then
                local health = math.floor(player.Character.Humanoid.Health)
                local maxHealth = player.Character.Humanoid.MaxHealth
                healthText = string.format(" [%d/%d]", health, maxHealth)
            end
            
            local PlayerButton = Instance.new("TextButton")
            PlayerButton.Size = UDim2.new(1, -10, 0, 40)
            PlayerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            PlayerButton.Text = status .. " " .. player.Name .. healthText
            PlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            PlayerButton.TextSize = 14
            PlayerButton.Font = Enum.Font.Gotham
            PlayerButton.Parent = ScrollFrame
            PlayerButton.AutoButtonColor = false
            PlayerButton.ClipsDescendants = true
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = PlayerButton
            
            -- Hover effect
            PlayerButton.MouseEnter:Connect(function()
                if PlayerButton.BackgroundColor3 ~= Color3.fromRGB(0, 200, 0) then
                    PlayerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                end
            end)
            
            PlayerButton.MouseLeave:Connect(function()
                if PlayerButton.BackgroundColor3 ~= Color3.fromRGB(0, 200, 0) then
                    PlayerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                end
            end)
            
            -- Click to select
            PlayerButton.MouseButton1Click:Connect(function()
                if isValidTarget(player) then
                    _G.selectedTarget = player
                    
                    -- Update all buttons colors
                    for _, btn in pairs(ScrollFrame:GetChildren()) do
                        if btn:IsA("TextButton") then
                            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                        end
                    end
                    
                    -- Highlight selected
                    PlayerButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    
                    StatusLabel.Text = "✅ Target: " .. player.Name .. healthText
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    
                    -- Auto-enable aimlock jika dimatikan
                    if not _G.aimlockEnabled then
                        _G.aimlockEnabled = true
                        ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 255, 70)
                        ToggleButton.Text = "⚡ AIMLOCK: ON"
                    end
                else
                    StatusLabel.Text = "❌ Invalid target: " .. player.Name
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                    
                    -- Temporary red flash
                    PlayerButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    task.wait(0.2)
                    PlayerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                end
            end)
        end
    end
    
    if playerCount == 0 then
        local NoPlayersLabel = Instance.new("TextLabel")
        NoPlayersLabel.Size = UDim2.new(1, -10, 0, 40)
        NoPlayersLabel.BackgroundTransparency = 1
        NoPlayersLabel.Text = "No other players found"
        NoPlayersLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        NoPlayersLabel.TextSize = 14
        NoPlayersLabel.Font = Enum.Font.Gotham
        NoPlayersLabel.Parent = ScrollFrame
    end
    
    -- Update canvas size
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 15)
end

-- Aimlock Logic dengan optimasi
local aimlockConnection
aimlockConnection = RunService.RenderStepped:Connect(function()
    -- Validasi kamera
    if not Camera then
        Camera = workspace.CurrentCamera
        return
    end
    
    -- Aimlock
    if _G.aimlockEnabled and _G.selectedTarget then
        local target = _G.selectedTarget
        
        if isValidTarget(target) then
            local targetPart = target.Character[_G.aimPart]
            local targetPosition = targetPart.Position
            local cameraCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(cameraCFrame.Position, targetPosition)
            
            Camera.CFrame = cameraCFrame:Lerp(targetCFrame, _G.aimSmoothness)
        else
            StatusLabel.Text = "❌ Target lost! Select new target"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            _G.selectedTarget = nil
            updatePlayerList()
            
            if _G.aimlockEnabled then
                _G.aimlockEnabled = false
                ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
                ToggleButton.Text = "⚡ AIMLOCK: OFF"
            end
        end
    end
    
    -- Update ESP setiap frame
    updateAllESP()
end)

-- Hotkey to toggle (Q key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == _G.lockKey then
        ToggleButton.MouseButton1Click:Fire()
    end
end)

-- Update player list when players join/leave
Players.PlayerAdded:Connect(function(player)
    task.wait(0.5)
    updatePlayerList()
    if _G.espEnabled then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if _G.selectedTarget == player then
        _G.selectedTarget = nil
        StatusLabel.Text = "👋 Target left! Select new target"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    end
    removeESP(player)
    updatePlayerList()
end)

-- Character added/removed
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    updatePlayerList()
end)

LocalPlayer.CharacterRemoving:Connect(function()
    _G.selectedTarget = nil
    StatusLabel.Text = "⚠️ Character died!"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    
    if _G.aimlockEnabled then
        _G.aimlockEnabled = false
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        ToggleButton.Text = "⚡ AIMLOCK: OFF"
    end
end)

-- Health monitoring untuk target
local function monitorTargetHealth()
    while true do
        task.wait(0.5)
        if _G.selectedTarget and isValidTarget(_G.selectedTarget) then
            local health = _G.selectedTarget.Character.Humanoid.Health
            if health <= 0 then
                StatusLabel.Text = "💀 Target died!"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                _G.selectedTarget = nil
                updatePlayerList()
            end
        end
    end
end

task.spawn(monitorTargetHealth)

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -42, 0, 6)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame
CloseButton.AutoButtonColor = false

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
end)

CloseButton.MouseLeave:Connect(function()
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if aimlockConnection then
        aimlockConnection:Disconnect()
    end
end)

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 32, 0, 32)
MinimizeButton.Position = UDim2.new(1, -84, 0, 6)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = MainFrame
MinimizeButton.AutoButtonColor = false

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(1, 0)
MinCorner.Parent = MinimizeButton

MinimizeButton.MouseEnter:Connect(function()
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 185, 0)
end)

MinimizeButton.MouseLeave:Connect(function()
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
end)

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        -- Hide all content except title and buttons
        ToggleButton.Visible = false
        ESPButton.Visible = false
        SmoothnessFrame.Visible = false
        ListLabel.Visible = false
        ScrollFrame.Visible = false
        StatusLabel.Visible = false
        ESPStatusLabel.Visible = false
        
        MainFrame.Size = UDim2.new(0, 320, 0, 45)
        MinimizeButton.Text = "+"
        CloseButton.Position = UDim2.new(1, -42, 0, 6)
        MinimizeButton.Position = UDim2.new(1, -84, 0, 6)
    else
        -- Show all content
        ToggleButton.Visible = true
        ESPButton.Visible = true
        SmoothnessFrame.Visible = true
        ListLabel.Visible = true
        ScrollFrame.Visible = true
        StatusLabel.Visible = true
        ESPStatusLabel.Visible = true
        
        MainFrame.Size = UDim2.new(0, 320, 0, 520)
        MinimizeButton.Text = "—"
        CloseButton.Position = UDim2.new(1, -42, 0, 6)
        MinimizeButton.Position = UDim2.new(1, -84, 0, 6)
    end
end)

-- Initialize
updatePlayerList()

-- Notification function
local function notify(text, duration, icon)
    duration = duration or 3
    game.StarterGui:SetCore("SendNotification", {
        Title = "🎯 AIMLOCK + ESP",
        Text = text,
        Icon = icon or "rbxassetid://7734057515",
        Duration = duration
    })
end

-- Welcome notifications
task.wait(0.5)
notify("Aimlock + ESP loaded! Press Q to toggle aimlock", 2)
task.wait(0.5)
notify("ESP button to see names, health, distance", 2)
task.wait(0.5)
notify("Select target from list", 2)

-- Auto-refresh player list setiap 5 detik
task.spawn(function()
    while true do
        task.wait(5)
        updatePlayerList()
    end
end)
