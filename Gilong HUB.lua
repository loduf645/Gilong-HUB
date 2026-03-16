-- Simple Aimlock Script with GUI
-- Target Selection & Camera Lock System

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- Global Variables dengan validasi
_G.aimlockEnabled = false
_G.aimlockNearest = false
_G.selectedTarget = nil
_G.aimSmoothness = 0.2
_G.lockKey = Enum.KeyCode.Q
_G.nearestRange = 50
_G.aimPart = "Head" -- Bisa diganti: Head, HumanoidRootPart, dll

-- Validasi karakter dan part
local function isValidTarget(target)
    return target and target.Character and target.Character:FindFirstChild(_G.aimPart) and target.Character:FindFirstChild("Humanoid")
end

-- Create GUI dengan perlindungan
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimlockGUI"
ScreenGui.Parent = game:FindFirstChild("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 450)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

-- Add shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = MainFrame
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)

-- Add corner radius
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Title with gradient
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
Title.Text = "⚡ AIMLOCK SYSTEM ⚡"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Gradient for title
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 50, 255))
})
Gradient.Parent = Title

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 45)
ToggleButton.Position = UDim2.new(0.05, 0, 0, 55)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
ToggleButton.Text = "AIMLOCK: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = MainFrame
ToggleButton.AutoButtonColor = false

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

-- Nearest Toggle Button
local NearestToggle = Instance.new("TextButton")
NearestToggle.Size = UDim2.new(0.9, 0, 0, 45)
NearestToggle.Position = UDim2.new(0.05, 0, 0, 105)
NearestToggle.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
NearestToggle.Text = "NEAREST MODE: OFF"
NearestToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
NearestToggle.TextSize = 16
NearestToggle.Font = Enum.Font.GothamBold
NearestToggle.Parent = MainFrame
NearestToggle.AutoButtonColor = false

local NearestCorner = Instance.new("UICorner")
NearestCorner.CornerRadius = UDim.new(0, 8)
NearestCorner.Parent = NearestToggle

-- Settings Frame
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0.9, 0, 0, 100)
SettingsFrame.Position = UDim2.new(0.05, 0, 0, 155)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SettingsFrame.Parent = MainFrame

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 8)
SettingsCorner.Parent = SettingsFrame

-- Range Slider
local RangeLabel = Instance.new("TextLabel")
RangeLabel.Size = UDim2.new(1, -20, 0, 25)
RangeLabel.Position = UDim2.new(0, 10, 0, 5)
RangeLabel.BackgroundTransparency = 1
RangeLabel.Text = "Range: 50 studs"
RangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RangeLabel.TextSize = 14
RangeLabel.TextXAlignment = Enum.TextXAlignment.Left
RangeLabel.Font = Enum.Font.Gotham
RangeLabel.Parent = SettingsFrame

local RangeSlider = Instance.new("TextBox")
RangeSlider.Size = UDim2.new(0.8, 0, 0, 25)
RangeSlider.Position = UDim2.new(0.1, 0, 0, 30)
RangeSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
RangeSlider.Text = "50"
RangeSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
RangeSlider.PlaceholderText = "Range (10-200)"
RangeSlider.Font = Enum.Font.Gotham
RangeSlider.TextSize = 14
RangeSlider.Parent = SettingsFrame

local RangeSliderCorner = Instance.new("UICorner")
RangeSliderCorner.CornerRadius = UDim.new(0, 5)
RangeSliderCorner.Parent = RangeSlider

-- Smoothness Slider
local SmoothnessLabel = Instance.new("TextLabel")
SmoothnessLabel.Size = UDim2.new(1, -20, 0, 25)
SmoothnessLabel.Position = UDim2.new(0, 10, 0, 60)
SmoothnessLabel.BackgroundTransparency = 1
SmoothnessLabel.Text = "Smoothness: 0.2"
SmoothnessLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothnessLabel.TextSize = 14
SmoothnessLabel.TextXAlignment = Enum.TextXAlignment.Left
SmoothnessLabel.Font = Enum.Font.Gotham
SmoothnessLabel.Parent = SettingsFrame

local SmoothnessSlider = Instance.new("TextBox")
SmoothnessSlider.Size = UDim2.new(0.8, 0, 0, 25)
SmoothnessSlider.Position = UDim2.new(0.1, 0, 0, 85)
SmoothnessSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
SmoothnessSlider.Text = "0.2"
SmoothnessSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothnessSlider.PlaceholderText = "Smoothness (0.1-1.0)"
SmoothnessSlider.Font = Enum.Font.Gotham
SmoothnessSlider.TextSize = 14
SmoothnessSlider.Parent = SettingsFrame

local SmoothnessSliderCorner = Instance.new("UICorner")
SmoothnessSliderCorner.CornerRadius = UDim.new(0, 5)
SmoothnessSliderCorner.Parent = SmoothnessSlider

-- Player List Label
local ListLabel = Instance.new("TextLabel")
ListLabel.Size = UDim2.new(1, 0, 0, 25)
ListLabel.Position = UDim2.new(0, 10, 0, 260)
ListLabel.BackgroundTransparency = 1
ListLabel.Text = "🎯 SELECT TARGET:"
ListLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
ListLabel.TextSize = 14
ListLabel.TextXAlignment = Enum.TextXAlignment.Left
ListLabel.Font = Enum.Font.GothamBold
ListLabel.Parent = MainFrame

-- Scroll Frame for Player List
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0.9, 0, 0, 100)
ScrollFrame.Position = UDim2.new(0.05, 0, 0, 285)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
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
StatusLabel.Size = UDim2.new(1, -20, 0, 35)
StatusLabel.Position = UDim2.new(0, 10, 0, 395)
StatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
StatusLabel.Text = "Status: No target selected"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 5)
StatusCorner.Parent = StatusLabel

-- Functions
local function getNearestPlayers()
    local nearbyPlayers = {}
    local character = LocalPlayer.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nearbyPlayers
    end
    
    local playerPos = character.HumanoidRootPart.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isValidTarget(player) then
            local targetPos = player.Character[_G.aimPart].Position
            local distance = (playerPos - targetPos).Magnitude
            
            if distance <= _G.nearestRange then
                table.insert(nearbyPlayers, {player = player, distance = distance})
            end
        end
    end
    
    -- Sort by distance
    table.sort(nearbyPlayers, function(a, b)
        return a.distance < b.distance
    end)
    
    return nearbyPlayers
end

local function getRandomNearestTarget()
    local nearbyPlayers = getNearestPlayers()
    
    if #nearbyPlayers > 0 then
        local randomIndex = math.random(1, #nearbyPlayers)
        return nearbyPlayers[randomIndex].player
    end
    
    return nil
end

local function getClosestTarget()
    local nearbyPlayers = getNearestPlayers()
    
    if #nearbyPlayers > 0 then
        return nearbyPlayers[1].player
    end
    
    return nil
end

local function updatePlayerList()
    -- Clear existing buttons
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Create button for each player
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PlayerButton = Instance.new("TextButton")
            PlayerButton.Size = UDim2.new(1, -10, 0, 35)
            PlayerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            PlayerButton.Text = player.Name .. "  |  " .. (isValidTarget(player) and "✅" or "❌")
            PlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            PlayerButton.TextSize = 14
            PlayerButton.Font = Enum.Font.Gotham
            PlayerButton.Parent = ScrollFrame
            PlayerButton.AutoButtonColor = false
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = PlayerButton
            
            -- Click to select
            PlayerButton.MouseButton1Click:Connect(function()
                if isValidTarget(player) then
                    _G.selectedTarget = player
                    
                    -- Update all buttons colors
                    for _, btn in pairs(ScrollFrame:GetChildren()) do
                        if btn:IsA("TextButton") then
                            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                        end
                    end
                    
                    -- Highlight selected
                    PlayerButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    
                    StatusLabel.Text = "✅ Target: " .. player.Name
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                else
                    StatusLabel.Text = "❌ Invalid target: " .. player.Name
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end)
        end
    end
    
    -- Update canvas size
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 15)
end

-- Input handlers
RangeSlider.FocusLost:Connect(function()
    local value = tonumber(RangeSlider.Text)
    if value then
        _G.nearestRange = math.clamp(value, 10, 200)
        RangeSlider.Text = tostring(_G.nearestRange)
        RangeLabel.Text = "Range: " .. _G.nearestRange .. " studs"
    else
        RangeSlider.Text = tostring(_G.nearestRange)
    end
end)

SmoothnessSlider.FocusLost:Connect(function()
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
        ToggleButton.Text = "✅ AIMLOCK: ON"
        
        if _G.aimlockNearest then
            _G.aimlockNearest = false
            NearestToggle.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
            NearestToggle.Text = "NEAREST MODE: OFF"
        end
        
        if not _G.selectedTarget then
            StatusLabel.Text = "⚠️ No target selected!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        end
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        ToggleButton.Text = "❌ AIMLOCK: OFF"
        StatusLabel.Text = "Aimlock disabled"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- Toggle Nearest Mode
NearestToggle.MouseButton1Click:Connect(function()
    _G.aimlockNearest = not _G.aimlockNearest
    
    if _G.aimlockNearest then
        NearestToggle.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        NearestToggle.Text = "⚡ NEAREST MODE: ON"
        
        if _G.aimlockEnabled then
            _G.aimlockEnabled = false
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
            ToggleButton.Text = "❌ AIMLOCK: OFF"
        end
        
        StatusLabel.Text = "Nearest mode: Auto-targeting"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
    else
        NearestToggle.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        NearestToggle.Text = "NEAREST MODE: OFF"
        StatusLabel.Text = "Nearest mode disabled"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        _G.selectedTarget = nil
    end
end)

-- Aimlock Logic
local aimlockConnection
local nearestUpdateTimer = 0
aimlockConnection = RunService.RenderStepped:Connect(function(deltaTime)
    -- Validasi kamera
    if not Camera then
        Camera = workspace.CurrentCamera
        return
    end
    
    -- Manual Aimlock Mode
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
        end
    end
    
    -- Nearest Aimlock Mode
    if _G.aimlockNearest then
        nearestUpdateTimer = nearestUpdateTimer + deltaTime
        
        if nearestUpdateTimer >= 0.3 then
            nearestUpdateTimer = 0
            _G.selectedTarget = getClosestTarget()
        end
        
        if _G.selectedTarget and isValidTarget(_G.selectedTarget) then
            local target = _G.selectedTarget
            local targetPart = target.Character[_G.aimPart]
            local targetPosition = targetPart.Position
            local cameraCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(cameraCFrame.Position, targetPosition)
            
            Camera.CFrame = cameraCFrame:Lerp(targetCFrame, _G.aimSmoothness)
            
            StatusLabel.Text = "🎯 Locked: " .. target.Name
            StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        else
            StatusLabel.Text = "🔍 Searching for targets... (" .. #getNearestPlayers() .. " nearby)"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        end
    end
end)

-- Hotkey to toggle (Q key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == _G.lockKey then
        ToggleButton.MouseButton1Click:Fire()
    end
end)

-- Update player list when players join/leave
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    updatePlayerList()
end)

Players.PlayerRemoving:Connect(function(player)
    if _G.selectedTarget == player then
        _G.selectedTarget = nil
        StatusLabel.Text = "👋 Target left! Select new target"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    end
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
end)

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 8)
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

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if aimlockConnection then
        aimlockConnection:Disconnect()
    end
end)

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -80, 0, 8)
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

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        -- Hide all content except title and buttons
        ToggleButton.Visible = false
        NearestToggle.Visible = false
        SettingsFrame.Visible = false
        ListLabel.Visible = false
        ScrollFrame.Visible = false
        StatusLabel.Visible = false
        
        MainFrame.Size = UDim2.new(0, 300, 0, 45)
        MinimizeButton.Text = "+"
        CloseButton.Position = UDim2.new(1, -40, 0, 8)
        MinimizeButton.Position = UDim2.new(1, -80, 0, 8)
    else
        -- Show all content
        ToggleButton.Visible = true
        NearestToggle.Visible = true
        SettingsFrame.Visible = true
        ListLabel.Visible = true
        ScrollFrame.Visible = true
        StatusLabel.Visible = true
        
        MainFrame.Size = UDim2.new(0, 300, 0, 450)
        MinimizeButton.Text = "—"
        CloseButton.Position = UDim2.new(1, -40, 0, 8)
        MinimizeButton.Position = UDim2.new(1, -80, 0, 8)
    end
end)

-- Initialize
updatePlayerList()

-- Notification function yang lebih baik
local function notify(text, duration)
    duration = duration or 3
    game.StarterGui:SetCore("SendNotification", {
        Title = "⚡ AIMLOCK SYSTEM",
        Text = text,
        Icon = "rbxassetid://7734057515",
        Duration = duration
    })
end

-- Welcome notifications
task.wait(0.5)
notify("Aimlock GUI loaded! Press Q to toggle aimlock", 2)
task.wait(0.5)
notify("Select a target from the list", 2)
task.wait(0.5)
notify("Use range slider to adjust distance", 2)
