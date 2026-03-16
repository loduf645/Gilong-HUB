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
_G.nearestMode = false
_G.nearestRange = 50
_G.lastRandomTime = 0
_G.randomInterval = 3

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimlockGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 480)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -240)
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
ScrollFrame.Size = UDim2.new(0.9, 0, 0, 140)
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

-- Nearest Mode Toggle
local NearestToggle = Instance.new("TextButton")
NearestToggle.Size = UDim2.new(0.9, 0, 0, 45)
NearestToggle.Position = UDim2.new(0.05, 0, 0, 305)
NearestToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
NearestToggle.Text = "NEAREST MODE: OFF"
NearestToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
NearestToggle.TextSize = 16
NearestToggle.Font = Enum.Font.GothamBold
NearestToggle.Parent = MainFrame

local NearestCorner = Instance.new("UICorner")
NearestCorner.CornerRadius = UDim.new(0, 8)
NearestCorner.Parent = NearestToggle

-- Range Slider Label
local RangeLabel = Instance.new("TextLabel")
RangeLabel.Size = UDim2.new(0.9, 0, 0, 20)
RangeLabel.Position = UDim2.new(0.05, 0, 0, 360)
RangeLabel.BackgroundTransparency = 1
RangeLabel.Text = "Detection Range: 50 studs"
RangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RangeLabel.TextSize = 12
RangeLabel.Font = Enum.Font.Gotham
RangeLabel.Parent = MainFrame

-- Range Slider
local RangeSlider = Instance.new("Frame")
RangeSlider.Size = UDim2.new(0.9, 0, 0, 25)
RangeSlider.Position = UDim2.new(0.05, 0, 0, 385)
RangeSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
RangeSlider.BorderSizePixel = 0
RangeSlider.Parent = MainFrame

local RangeSliderCorner = Instance.new("UICorner")
RangeSliderCorner.CornerRadius = UDim.new(0, 5)
RangeSliderCorner.Parent = RangeSlider

local RangeFill = Instance.new("Frame")
RangeFill.Size = UDim2.new(0.5, 0, 1, 0)
RangeFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
RangeFill.BorderSizePixel = 0
RangeFill.Parent = RangeSlider

local RangeFillCorner = Instance.new("UICorner")
RangeFillCorner.CornerRadius = UDim.new(0, 5)
RangeFillCorner.Parent = RangeFill

local RangeButton = Instance.new("TextButton")
RangeButton.Size = UDim2.new(0, 20, 0, 20)
RangeButton.Position = UDim2.new(0.5, -10, 0.5, -10)
RangeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RangeButton.Text = ""
RangeButton.Parent = RangeSlider

local RangeButtonCorner = Instance.new("UICorner")
RangeButtonCorner.CornerRadius = UDim.new(1, 0)
RangeButtonCorner.Parent = RangeButton

-- Slider Logic
local dragging = false
RangeButton.MouseButton1Down:Connect(function()
    dragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging then
        local mouse = LocalPlayer:GetMouse()
        local relativeX = math.clamp((mouse.X - RangeSlider.AbsolutePosition.X) / RangeSlider.AbsoluteSize.X, 0, 1)
        
        RangeFill.Size = UDim2.new(relativeX, 0, 1, 0)
        RangeButton.Position = UDim2.new(relativeX, -10, 0.5, -10)
        
        _G.nearestRange = math.floor(10 + (relativeX * 190)) -- Range 10-200
        RangeLabel.Text = "Detection Range: " .. _G.nearestRange .. " studs"
    end
end)

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 40)
StatusLabel.Position = UDim2.new(0, 0, 0, 420)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: No target selected"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- Smoothness Slider Label
local SmoothnessLabel = Instance.new("TextLabel")
SmoothnessLabel.Size = UDim2.new(0.5, 0, 0, 20)
SmoothnessLabel.Position = UDim2.new(0.05, 0, 0, 455)
SmoothnessLabel.BackgroundTransparency = 1
SmoothnessLabel.Text = "Smoothness: 0.2"
SmoothnessLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothnessLabel.TextSize = 10
SmoothnessLabel.Font = Enum.Font.Gotham
SmoothnessLabel.Parent = MainFrame

-- Functions
local function getNearestPlayers()
    local nearPlayers = {}
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nearPlayers end
    
    local playerPos = character.HumanoidRootPart.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = player.Character.HumanoidRootPart.Position
            local distance = (playerPos - targetPos).Magnitude
            
            if distance <= _G.nearestRange then
                table.insert(nearPlayers, {player = player, distance = distance})
            end
        end
    end
    
    return nearPlayers
end

local function selectRandomNearestTarget()
    local nearPlayers = getNearestPlayers()
    
    if #nearPlayers > 0 then
        -- Random selection from nearby players
        local randomIndex = math.random(1, #nearPlayers)
        return nearPlayers[randomIndex].player
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

-- Toggle Nearest Mode
NearestToggle.MouseButton1Click:Connect(function()
    _G.nearestMode = not _G.nearestMode
    
    if _G.nearestMode then
        NearestToggle.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        NearestToggle.Text = "NEAREST MODE: ON"
        
        -- Disable manual selection when nearest mode is on
        ScrollFrame.Visible = false
        ListLabel.Text = "NEAREST MODE ACTIVE"
        
        StatusLabel.Text = "Mode: Auto-targeting nearest players"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        NearestToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
        NearestToggle.Text = "NEAREST MODE: OFF"
        
        ScrollFrame.Visible = true
        ListLabel.Text = "SELECT TARGET PLAYER:"
        
        StatusLabel.Text = "Mode: Manual target selection"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    end
end)

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
    if _G.aimlockEnabled then
        local target = nil
        
        -- Check mode
        if _G.nearestMode then
            -- Nearest mode - random selection every few seconds
            local currentTime = tick()
            if currentTime - _G.lastRandomTime >= _G.randomInterval or not _G.selectedTarget then
                target = selectRandomNearestTarget()
                _G.selectedTarget = target
                _G.lastRandomTime = currentTime
                
                if target then
                    StatusLabel.Text = "Locked: " .. target.Name .. " (Auto)"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
                else
                    StatusLabel.Text = "No players in range (" .. _G.nearestRange .. " studs)"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            else
                target = _G.selectedTarget
            end
        else
            -- Manual mode
            target = _G.selectedTarget
        end
        
        -- Lock camera to target
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetHead = target.Character.Head
            
            -- Calculate camera position
            local targetPosition = targetHead.Position
            local cameraCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(cameraCFrame.Position, targetPosition)
            
            -- Smooth camera movement
            Camera.CFrame = cameraCFrame:Lerp(targetCFrame, _G.aimSmoothness)
        else
            if not _G.nearestMode then
                StatusLabel.Text = "Target lost! Select new target"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                _G.selectedTarget = nil
                updatePlayerList()
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
        -- Hide all content except title and buttons
        ToggleButton.Visible = false
        ListLabel.Visible = false
        ScrollFrame.Visible = false
        StatusLabel.Visible = false
        SmoothnessLabel.Visible = false
        NearestToggle.Visible = false
        RangeLabel.Visible = false
        RangeSlider.Visible = false
        
        MainFrame.Size = UDim2.new(0, 300, 0, 40)
        MinimizeButton.Text = "+"
    else
        -- Show all content
        ToggleButton.Visible = true
        ListLabel.Visible = true
        ScrollFrame.Visible = not _G.nearestMode -- Hide if nearest mode is on
        StatusLabel.Visible = true
        SmoothnessLabel.Visible = true
        NearestToggle.Visible = true
        RangeLabel.Visible = true
        RangeSlider.Visible = true
        
        MainFrame.Size = UDim2.new(0, 300, 0, 480)
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
