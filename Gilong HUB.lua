-- Simple Aimlock Script with GUI
-- Target Selection & Camera Lock System

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
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
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
Title.Text = "🎯 AIMLOCK SYSTEM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
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

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 45)
ToggleButton.Position = UDim2.new(0.05, 0, 0, 55)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
ToggleButton.Text = "⚡ AIMLOCK: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = MainFrame
ToggleButton.AutoButtonColor = false

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

-- Smoothness Control
local SmoothnessFrame = Instance.new("Frame")
SmoothnessFrame.Size = UDim2.new(0.9, 0, 0, 70)
SmoothnessFrame.Position = UDim2.new(0.05, 0, 0, 105)
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
ListLabel.Position = UDim2.new(0, 10, 0, 185)
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
ScrollFrame.Position = UDim2.new(0.05, 0, 0, 215)
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
StatusLabel.Position = UDim2.new(0.05, 0, 0, 385)
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
StatusLabel.Text = "⏳ Status: No target selected"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusLabel

-- Functions
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

-- Aimlock Logic dengan optimasi
local aimlockConnection
aimlockConnection = RunService.RenderStepped:Connect(function()
    -- Validasi kamera
    if not Camera then
        Camera = workspace.CurrentCamera
        return
    end
    
    if _G.aimlockEnabled and _G.selectedTarget then
        local target = _G.selectedTarget
        
        -- Validasi target
        if isValidTarget(target) then
            local targetPart = target.Character[_G.aimPart]
            local targetPosition = targetPart.Position
            local cameraCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(cameraCFrame.Position, targetPosition)
            
            -- Smooth camera movement dengan lerp
            Camera.CFrame = cameraCFrame:Lerp(targetCFrame, _G.aimSmoothness)
        else
            StatusLabel.Text = "❌ Target lost! Select new target"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            _G.selectedTarget = nil
            updatePlayerList()
            
            -- Auto-disable aimlock jika target hilang
            if _G.aimlockEnabled then
                _G.aimlockEnabled = false
                ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
                ToggleButton.Text = "⚡ AIMLOCK: OFF"
            end
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

-- Hover effect for close button
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

-- Hover effect for minimize button
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
        SmoothnessFrame.Visible = false
        ListLabel.Visible = false
        ScrollFrame.Visible = false
        StatusLabel.Visible = false
        
        MainFrame.Size = UDim2.new(0, 320, 0, 45)
        MinimizeButton.Text = "+"
        CloseButton.Position = UDim2.new(1, -42, 0, 6)
        MinimizeButton.Position = UDim2.new(1, -84, 0, 6)
    else
        -- Show all content
        ToggleButton.Visible = true
        SmoothnessFrame.Visible = true
        ListLabel.Visible = true
        ScrollFrame.Visible = true
        StatusLabel.Visible = true
        
        MainFrame.Size = UDim2.new(0, 320, 0, 450)
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
        Title = "🎯 AIMLOCK SYSTEM",
        Text = text,
        Icon = icon or "rbxassetid://7734057515",
        Duration = duration
    })
end

-- Welcome notifications
task.wait(0.5)
notify("Aimlock GUI loaded! Press Q to toggle aimlock", 2)
task.wait(0.5)
notify("Select a target from the list", 2)
task.wait(0.5)
notify("Adjust smoothness with slider", 2)

-- Auto-refresh player list setiap 5 detik
task.spawn(function()
    while true do
        task.wait(5)
        updatePlayerList()
    end
end)
