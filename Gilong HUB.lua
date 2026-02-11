-- QUANTUM ESP WALLHACK V5.0
-- © RianModss - Works on 99% Roblox games
-- Inject dengan executor (Synapse X, KRNL, Script-Ware, dll)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Quantum ESP Configuration
local ESP_SETTINGS = {
    ENABLED = true,
    SHOW_NAMES = true,
    SHOW_DISTANCE = true,
    SHOW_HEALTH = true,
    SHOW_BOX = true,
    SHOW_TRACERS = true,
    SHOW_WEAPONS = true,
    MAX_DISTANCE = 1000, -- studs
    UPDATE_RATE = 0.1, -- seconds
    TEAM_CHECK = false, -- true = hanya musuh, false = semua
}

-- Colors
local COLORS = {
    ENEMY = Color3.fromRGB(255, 50, 50),    -- Merah
    TEAMMATE = Color3.fromRGB(50, 255, 50), -- Hijau
    NEUTRAL = Color3.fromRGB(255, 255, 50), -- Kuning
    TEXT = Color3.fromRGB(255, 255, 255),   -- Putih
}

-- Storage for ESP objects
local ESP_Objects = {}

-- Quantum ESP Functions
function CreateESP(player)
    if not player.Character then return end
    if ESP_Objects[player] then return end
    
    local character = player.Character
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Create ESP Container
    local espContainer = Instance.new("Folder")
    espContainer.Name = "QuantumESP_" .. player.Name
    espContainer.Parent = Camera
    
    ESP_Objects[player] = {
        Container = espContainer,
        Character = character,
        Player = player
    }
    
    -- Box ESP
    if ESP_SETTINGS.SHOW_BOX then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "Box"
        box.Adornee = humanoidRootPart
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Size = Vector3.new(4, 6, 2)
        box.Transparency = 0.7
        box.Color3 = GetPlayerColor(player)
        box.Parent = espContainer
    end
    
    -- Tracer Line
    if ESP_SETTINGS.SHOW_TRACERS then
        local tracer = Instance.new("Frame")
        tracer.Name = "Tracer"
        tracer.Size = UDim2.new(0, 2, 0, 2000)
        tracer.BackgroundColor3 = GetPlayerColor(player)
        tracer.BorderSizePixel = 0
        tracer.BackgroundTransparency = 0.5
        tracer.Parent = espContainer
    end
    
    -- Billboard GUI for Info
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Info"
    billboard.Size = UDim2.new(0, 200, 0, 150)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = humanoidRootPart
    billboard.Parent = espContainer
    
    -- Player Name
    if ESP_SETTINGS.SHOW_NAMES then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = COLORS.TEXT
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.TextSize = 16
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Text = player.Name
        nameLabel.Parent = billboard
    end
    
    -- Distance
    if ESP_SETTINGS.SHOW_DISTANCE then
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "Distance"
        distanceLabel.Size = UDim2.new(1, 0, 0, 20)
        distanceLabel.Position = UDim2.new(0, 0, 0, 20)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = COLORS.TEXT
        distanceLabel.TextStrokeTransparency = 0
        distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        distanceLabel.TextSize = 14
        distanceLabel.Font = Enum.Font.SourceSans
        distanceLabel.Parent = billboard
    end
    
    -- Health Bar
    if ESP_SETTINGS.SHOW_HEALTH then
        local healthBar = Instance.new("Frame")
        healthBar.Name = "HealthBar"
        healthBar.Size = UDim2.new(1, 0, 0, 5)
        healthBar.Position = UDim2.new(0, 0, 0, 40)
        healthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = billboard
        
        local healthFill = Instance.new("Frame")
        healthFill.Name = "HealthFill"
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthFill.BorderSizePixel = 0
        healthFill.Parent = healthBar
    end
    
    -- Weapon Info
    if ESP_SETTINGS.SHOW_WEAPONS then
        local weaponLabel = Instance.new("TextLabel")
        weaponLabel.Name = "Weapon"
        weaponLabel.Size = UDim2.new(1, 0, 0, 20)
        weaponLabel.Position = UDim2.new(0, 0, 0, 50)
        weaponLabel.BackgroundTransparency = 1
        weaponLabel.TextColor3 = COLORS.TEXT
        weaponLabel.TextStrokeTransparency = 0
        weaponLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        weaponLabel.TextSize = 12
        weaponLabel.Font = Enum.Font.SourceSans
        weaponLabel.Text = "Weapon: None"
        weaponLabel.Parent = billboard
    end
end

function GetPlayerColor(player)
    if ESP_SETTINGS.TEAM_CHECK then
        if LocalPlayer.Team and player.Team then
            if LocalPlayer.Team == player.Team then
                return COLORS.TEAMMATE
            else
                return COLORS.ENEMY
            end
        end
    end
    return COLORS.NEUTRAL
end

function UpdateESP()
    for player, espData in pairs(ESP_Objects) do
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            -- Cleanup jika player mati atau keluar
            if espData.Container then
                espData.Container:Destroy()
            end
            ESP_Objects[player] = nil
            goto continue
        end
        
        local character = player.Character
        local humanoidRootPart = character.HumanoidRootPart
        local humanoid = character:FindFirstChild("Humanoid")
        
        -- Update position
        local screenPosition, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        
        if espData.Container and onScreen and ESP_SETTINGS.ENABLED then
            -- Update distance
            if ESP_SETTINGS.SHOW_DISTANCE then
                local distance = (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                local distanceLabel = espData.Container.Info:FindFirstChild("Distance")
                if distanceLabel then
                    distanceLabel.Text = string.format("Distance: %d studs", math.floor(distance))
                    
                    -- Red jika terlalu dekat
                    if distance < 50 then
                        distanceLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                    else
                        distanceLabel.TextColor3 = COLORS.TEXT
                    end
                end
            end
            
            -- Update health
            if ESP_SETTINGS.SHOW_HEALTH and humanoid then
                local healthBar = espData.Container.Info:FindFirstChild("HealthBar")
                if healthBar then
                    local healthFill = healthBar:FindFirstChild("HealthFill")
                    if healthFill then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                        
                        -- Color based on health
                        if healthPercent > 0.5 then
                            healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green
                        elseif healthPercent > 0.25 then
                            healthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
                        else
                            healthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red
                        end
                    end
                end
            end
            
            -- Update weapon
            if ESP_SETTINGS.SHOW_WEAPONS then
                local weaponLabel = espData.Container.Info:FindFirstChild("Weapon")
                if weaponLabel then
                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then
                        weaponLabel.Text = "Weapon: " .. tool.Name
                    else
                        weaponLabel.Text = "Weapon: None"
                    end
                end
            end
            
            -- Update tracer
            if ESP_SETTINGS.SHOW_TRACERS then
                local tracer = espData.Container:FindFirstChild("Tracer")
                if tracer then
                    local screenPos = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                    tracer.Position = UDim2.new(0.5, 0, 1, 0)
                    tracer.Rotation = math.deg(math.atan2(
                        screenPos.Y - Camera.ViewportSize.Y,
                        screenPos.X - Camera.ViewportSize.X/2
                    )) + 90
                end
            end
            
            -- Update colors based on team
            local color = GetPlayerColor(player)
            local box = espData.Container:FindFirstChild("Box")
            if box then box.Color3 = color end
            
            local tracer = espData.Container:FindFirstChild("Tracer")
            if tracer then tracer.BackgroundColor3 = color end
        else
            -- Hide if not on screen
            if espData.Container then
                espData.Container.Enabled = false
            end
        end
        
        ::continue::
    end
end

-- Initialize ESP for all players
function InitializeESP()
    -- Add ESP for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    
    -- Add ESP for new players
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            wait(1)
            CreateESP(player)
        end)
    end)
    
    -- Remove ESP when player leaves
    Players.PlayerRemoving:Connect(function(player)
        if ESP_Objects[player] then
            ESP_Objects[player].Container:Destroy()
            ESP_Objects[player] = nil
        end
    end)
    
    -- Update ESP continuously
    RunService.Heartbeat:Connect(function()
        UpdateESP()
    end)
end

-- GUI Controls
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(0, 200, 0, 250)
ControlFrame.Position = UDim2.new(0, 10, 0, 10)
ControlFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ControlFrame.BackgroundTransparency = 0.3
ControlFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "QUANTUM ESP V5.0"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = ControlFrame

-- Toggle Buttons
local yPos = 40
local function CreateToggle(text, setting, yPos)
    local button = Instance.new("TextButton")
    button.Text = text .. ": " .. (ESP_SETTINGS[setting] and "ON" or "OFF")
    button.Size = UDim2.new(0.9, 0, 0, 30)
    button.Position = UDim2.new(0.05, 0, 0, yPos)
    button.BackgroundColor3 = ESP_SETTINGS[setting] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = ControlFrame
    
    button.MouseButton1Click:Connect(function()
        ESP_SETTINGS[setting] = not ESP_SETTINGS[setting]
        button.Text = text .. ": " .. (ESP_SETTINGS[setting] and "ON" or "OFF")
        button.BackgroundColor3 = ESP_SETTINGS[setting] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
    
    return yPos + 35
end

yPos = CreateToggle("ESP", "ENABLED", yPos)
yPos = CreateToggle("Names", "SHOW_NAMES", yPos)
yPos = CreateToggle("Distance", "SHOW_DISTANCE", yPos)
yPos = CreateToggle("Health", "SHOW_HEALTH", yPos)
yPos = CreateToggle("Box", "SHOW_BOX", yPos)
yPos = CreateToggle("Tracers", "SHOW_TRACERS", yPos)
yPos = CreateToggle("Weapons", "SHOW_WEAPONS", yPos)
yPos = CreateToggle("Team Check", "TEAM_CHECK", yPos)

-- Start ESP
InitializeESP()

-- Notification
game.StarterGui:SetCore("SendNotification", {
    Title = "QUANTUM ESP LOADED",
    Text = "Wallhack activated! Use controls on top-left.",
    Duration = 5
})

print("[QUANTUM] ESP V5.0 injected successfully. See through walls enabled!")
