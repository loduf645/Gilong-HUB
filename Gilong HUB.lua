-- Simple Aimlock Script with GUI
-- Target Selection & Camera Lock System

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Variables
_G.aimlockEnabled = false
_G.selectedTarget = nil
_G.aimSmoothness = 0.2
_G.lockKey = Enum.KeyCode.Q

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimlockGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

-- Add corner radius
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Title.Text = "AIMLOCK SYSTEM"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0, 60)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleButton.Text = "AIMLOCK: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

-- Player List Label
local ListLabel = Instance.new("TextLabel")
ListLabel.Size = UDim2.new(1, 0, 0, 30)
ListLabel.Position = UDim2.new(0, 0, 0, 120)
ListLabel.BackgroundTransparency = 1
ListLabel.Text = "SELECT TARGET PLAYER:"
ListLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ListLabel.TextSize = 14
ListLabel.Font = Enum.Font.Gotham
ListLabel.Parent = MainFrame

-- Scroll Frame for Player List
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0.9, 0, 0, 180)
ScrollFrame.Position = UDim2.new(0.05, 0, 0, 155)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ScrollFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = ScrollFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 40)
StatusLabel.Position = UDim2.new(0, 0, 0, 345)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: No target selected"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- Smoothness Slider Label
local SmoothnessLabel = Instance.new("TextLabel")
SmoothnessLabel.Size = UDim2.new(0.5, 0, 0, 20)
SmoothnessLabel.Position = UDim2.new(0.05, 0, 0, 370)
SmoothnessLabel.BackgroundTransparency = 1
SmoothnessLabel.Text = "Smoothness: 0.2"
SmoothnessLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothnessLabel.TextSize = 10
SmoothnessLabel.Font = Enum.Font.Gotham
SmoothnessLabel.Parent = MainFrame

-- Functions
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
            PlayerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            PlayerButton.Text = player.Name
            PlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            PlayerButton.TextSize = 14
            PlayerButton.Font = Enum.Font.Gotham
            PlayerButton.Parent = ScrollFrame
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = PlayerButton
            
            -- Click to select
            PlayerButton.MouseButton1Click:Connect(function()
                _G.selectedTarget = player
                
                -- Update all buttons colors
                for _, btn in pairs(ScrollFrame:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    end
                end
                
                -- Highlight selected
                PlayerButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                
                StatusLabel.Text = "Target: " .. player.Name
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            end)
        end
    end
    
    -- Update canvas size
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

-- Toggle Aimlock
ToggleButton.MouseButton1Click:Connect(function()
    _G.aimlockEnabled = not _G.aimlockEnabled
    
    if _G.aimlockEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        ToggleButton.Text = "AIMLOCK: ON"
        
        if not _G.selectedTarget then
            StatusLabel.Text = "Warning: No target selected!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        ToggleButton.Text = "AIMLOCK: OFF"
        StatusLabel.Text = "Aimlock disabled"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    end
end)

-- Aimlock Logic
local aimlockConnection
aimlockConnection = RunService.RenderStepped:Connect(function()
    if _G.aimlockEnabled and _G.selectedTarget then
        local target = _G.selectedTarget
        
        -- Check if target still exists and has character
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetHead = target.Character.Head
            
            -- Calculate camera position
            local targetPosition = targetHead.Position
            local cameraCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(cameraCFrame.Position, targetPosition)
            
            -- Smooth camera movement
            Camera.CFrame = cameraCFrame:Lerp(targetCFrame, _G.aimSmoothness)
        else
            StatusLabel.Text = "Target lost! Select new target"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            _G.selectedTarget = nil
            updatePlayerList()
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
    wait(1)
    updatePlayerList()
end)

Players.PlayerRemoving:Connect(function(player)
    if _G.selectedTarget == player then
        _G.selectedTarget = nil
        StatusLabel.Text = "Target left! Select new target"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
    updatePlayerList()
end)

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

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
MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(1, 0)
MinCorner.Parent = MinimizeButton

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 300, 0, 40)
        MinimizeButton.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 300, 0, 400)
        MinimizeButton.Text = "_"
    end
end)

-- Initialize
updatePlayerList()

-- Notification
local function notify(text)
    game.StarterGui:SetCore("SendNotification", {
        Title = "AIMLOCK SYSTEM",
        Text = text,
        Duration = 3
    })
end

notify("Aimlock GUI loaded! Press Q to toggle aimlock")
notify("Select a target from the list and enable aimlock")
