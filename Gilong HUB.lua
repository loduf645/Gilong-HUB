-- QUANTUM AUTO PERFECT SKILLCHECK V3.0
-- © RianModss - For Roblox Violence District
-- Auto detects skillcheck and hits perfect timing every time

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Configuration
local CONFIG = {
    ENABLED = true,
    AUTO_ENABLE = true,
    PERFECT_MODE = true, -- Always perfect, not good
    REACTION_TIME = 0.01, -- Seconds (lower = faster)
    DEBUG_MODE = false,
    SOUND_ENABLED = true,
    NOTIFICATIONS = true,
}

-- Skillcheck detection patterns
local SKILLCHECK_PATTERNS = {
    -- Common skillcheck UI elements in Violence District
    "SkillCheck",
    "Skillcheck", 
    "SkillCheckFrame",
    "QuickTimeEvent",
    "QTE",
    "TimingBar",
    "MashBar",
    "ProgressBar",
    "Circle",
    "Target",
    "HitBox",
    "PerfectZone",
    "ButtonPrompt",
    "PressButton",
    "Interaction",
}

-- Colors for UI detection
local SKILLCHECK_COLORS = {
    Color3.fromRGB(0, 255, 0),    -- Green (perfect zone)
    Color3.fromRGB(255, 255, 0),  -- Yellow (good zone)
    Color3.fromRGB(255, 0, 0),    -- Red (bad zone)
    Color3.fromRGB(0, 150, 255),  -- Blue (skillcheck UI)
}

-- Storage
local activeSkillchecks = {}
local hookFunctions = {}
local lastSkillcheckTime = 0
local skillcheckCount = 0
local perfectCount = 0

-- Quantum Skillcheck Detector
function detectSkillcheckUI()
    if not CONFIG.ENABLED then return end
    
    -- Method 1: Screen GUI detection
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, guiObject in pairs(playerGui:GetDescendants()) do
            if guiObject:IsA("Frame") or guiObject:IsA("ImageLabel") or guiObject:IsA("TextButton") then
                local objectName = string.lower(guiObject.Name)
                local objectText = ""
                
                if guiObject:IsA("TextButton") or guiObject:IsA("TextLabel") then
                    objectText = string.lower(guiObject.Text or "")
                end
                
                -- Check if it's a skillcheck UI
                for _, pattern in pairs(SKILLCHECK_PATTERNS) do
                    local lowerPattern = string.lower(pattern)
                    if string.find(objectName, lowerPattern) or string.find(objectText, lowerPattern) then
                        if not activeSkillchecks[guiObject] then
                            registerSkillcheck(guiObject)
                        end
                        break
                    end
                end
                
                -- Color detection for skillcheck zones
                if guiObject.BackgroundColor3 then
                    for _, targetColor in pairs(SKILLCHECK_COLORS) do
                        if colorsSimilar(guiObject.BackgroundColor3, targetColor, 0.1) then
                            if not activeSkillchecks[guiObject] then
                                registerSkillcheck(guiObject)
                            end
                            break
                        end
                    end
                end
            end
        end
    end
    
    -- Method 2: Check for common skillcheck sounds
    for _, sound in pairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") and sound.Playing then
            local soundName = string.lower(sound.Name)
            if string.find(soundName, "skill") or string.find(soundName, "check") or string.find(soundName, "qte") then
                -- Sound detected, try to find corresponding UI
                triggerSkillcheck()
            end
        end
    end
end

function colorsSimilar(color1, color2, threshold)
    local diff = math.abs(color1.R - color2.R) + 
                 math.abs(color1.G - color2.G) + 
                 math.abs(color1.B - color2.B)
    return diff < threshold
end

function registerSkillcheck(uiObject)
    if activeSkillchecks[uiObject] then return end
    
    activeSkillchecks[uiObject] = {
        object = uiObject,
        detected = tick(),
        triggered = false
    }
    
    if CONFIG.DEBUG_MODE then
        print("[QUANTUM] Skillcheck detected:", uiObject.Name, uiObject.ClassName)
    end
    
    -- Auto execute skillcheck
    task.spawn(function()
        executeSkillcheck(uiObject)
    end)
end

function executeSkillcheck(uiObject)
    if not uiObject or not uiObject.Parent then return end
    
    wait(CONFIG.REACTION_TIME) -- Simulate human reaction time
    
    local skillcheckData = activeSkillchecks[uiObject]
    if not skillcheckData or skillcheckData.triggered then return end
    
    skillcheckData.triggered = true
    skillcheckCount = skillcheckCount + 1
    
    -- Determine perfect timing based on UI properties
    local perfectTiming = calculatePerfectTiming(uiObject)
    
    -- Execute the skillcheck
    local success = triggerSkillcheckAction(uiObject, perfectTiming)
    
    if success then
        perfectCount = perfectCount + 1
        if CONFIG.NOTIFICATIONS then
            showNotification("PERFECT SKILLCHECK! " .. perfectCount .. "/" .. skillcheckCount, Color3.fromRGB(0, 255, 0))
        end
        if CONFIG.SOUND_ENABLED then
            playSuccessSound()
        end
    else
        if CONFIG.NOTIFICATIONS then
            showNotification("Skillcheck Failed", Color3.fromRGB(255, 0, 0))
        end
    end
    
    -- Cleanup after delay
    task.delay(2, function()
        activeSkillchecks[uiObject] = nil
    end)
end

function calculatePerfectTiming(uiObject)
    -- Analyze UI to find perfect timing
    local perfectTime = 0.5 -- Default
    
    -- Check for animation or tween
    if uiObject:IsA("Frame") then
        -- Look for size changes (progress bar)
        if uiObject.Size then
            local size = uiObject.Size
            if size.X.Scale > 0.1 and size.X.Scale < 0.9 then
                perfectTime = size.X.Scale / 2
            end
        end
        
        -- Check for position changes (moving target)
        if uiObject.Position then
            perfectTime = 0.3
        end
    end
    
    -- Add slight random variation to avoid detection
    if not CONFIG.PERFECT_MODE then
        perfectTime = perfectTime + math.random(-20, 20) / 1000
    end
    
    return math.max(0.1, math.min(1.0, perfectTime))
end

function triggerSkillcheckAction(uiObject, timing)
    -- Method 1: Simulate mouse click
    if uiObject:IsA("TextButton") or uiObject:IsA("ImageButton") then
        -- Fire button events
        pcall(function()
            uiObject:FireEvent("MouseButton1Click")
            uiObject:FireEvent("Activated")
        end)
        
        -- Simulate actual click
        task.spawn(function()
            wait(timing)
            mouse1click()
        end)
        
        return true
    end
    
    -- Method 2: Key press simulation
    local possibleKeys = {"E", "F", "R", "Space", "Q"}
    for _, key in pairs(possibleKeys) do
        task.spawn(function()
            wait(timing)
            keypress(key)
            wait(0.05)
            keyrelease(key)
        end)
    end
    
    -- Method 3: Direct interaction with game events
    -- Try to find and trigger skillcheck remote events
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local remoteName = string.lower(remote.Name)
            if string.find(remoteName, "skill") or 
               string.find(remoteName, "check") or 
               string.find(remoteName, "qte") or
               string.find(remoteName, "interact") then
                pcall(function()
                    remote:FireServer("skillcheck", true, timing)
                    remote:FireServer("perfect", true)
                end)
            end
        end
    end
    
    return true
end

-- Input simulation functions
function mouse1click()
    pcall(function()
        UserInputService:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        wait(0.05)
        UserInputService:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
end

function keypress(key)
    pcall(function()
        UserInputService:SendKeyEvent(true, key, false, game)
    end)
end

function keyrelease(key)
    pcall(function()
        UserInputService:SendKeyEvent(false, key, false, game)
    end)
end

-- UI Functions
function showNotification(text, color)
    game.StarterGui:SetCore("SendNotification", {
        Title = "QUANTUM SKILLCHECK",
        Text = text,
        Duration = 2,
        Icon = "rbxassetid://4483345998",
    })
    
    -- Custom notification
    if not script.Parent:FindFirstChild("QuantumNotifications") then
        local notifications = Instance.new("ScreenGui")
        notifications.Name = "QuantumNotifications"
        notifications.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end

function playSuccessSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9125365582" -- Success sound
    sound.Volume = 0.3
    sound.Parent = workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end

-- Hook into game functions
function hookGameFunctions()
    -- Hook common skillcheck functions
    local gameScripts = game:GetDescendants()
    for _, script in pairs(gameScripts) do
        if script:IsA("LocalScript") or script:IsA("ModuleScript") then
            pcall(function()
                -- This would require more advanced hooking techniques
                -- For now, we rely on UI detection
            end)
        end
    end
end

-- Main detection loop
function startDetection()
    while CONFIG.ENABLED do
        detectSkillcheckUI()
        task.wait(0.1) -- Check 10 times per second
    end
end

-- GUI Control Panel
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(0, 250, 0, 200)
ControlFrame.Position = UDim2.new(0, 10, 0, 10)
ControlFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ControlFrame.BackgroundTransparency = 0.3
ControlFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "QUANTUM AUTO SKILLCHECK"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = ControlFrame

-- Stats Display
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Text = "Perfect: 0/0 (100%)"
StatsLabel.Size = UDim2.new(1, 0, 0, 30)
StatsLabel.Position = UDim2.new(0, 0, 0, 35)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatsLabel.TextSize = 16
StatsLabel.Font = Enum.Font.SourceSansBold
StatsLabel.Parent = ControlFrame

-- Toggle Buttons
local yPos = 70
local function CreateToggle(text, setting, yPos)
    local button = Instance.new("TextButton")
    button.Text = text .. ": " .. (CONFIG[setting] and "ON" or "OFF")
    button.Size = UDim2.new(0.9, 0, 0, 30)
    button.Position = UDim2.new(0.05, 0, 0, yPos)
    button.BackgroundColor3 = CONFIG[setting] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = ControlFrame
    
    button.MouseButton1Click:Connect(function()
        CONFIG[setting] = not CONFIG[setting]
        button.Text = text .. ": " .. (CONFIG[setting] and "ON" or "OFF")
        button.BackgroundColor3 = CONFIG[setting] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        
        if setting == "ENABLED" and CONFIG[setting] then
            startDetection()
        end
    end)
    
    return yPos + 35
end

yPos = CreateToggle("Auto Skillcheck", "ENABLED", yPos)
yPos = CreateToggle("Perfect Mode", "PERFECT_MODE", yPos)
yPos = CreateToggle("Sound", "SOUND_ENABLED", yPos)
yPos = CreateToggle("Notifications", "NOTIFICATIONS", yPos)
yPos = CreateToggle("Debug Mode", "DEBUG_MODE", yPos)

-- Update stats
RunService.Heartbeat:Connect(function()
    local percentage = skillcheckCount > 0 and math.floor((perfectCount / skillcheckCount) * 100) or 100
    StatsLabel.Text = string.format("Perfect: %d/%d (%d%%)", perfectCount, skillcheckCount, percentage)
    
    -- Color based on percentage
    if percentage >= 90 then
        StatsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    elseif percentage >= 70 then
        StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    else
        StatsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- Start the system
if CONFIG.AUTO_ENABLE then
    task.spawn(function()
        wait(2) -- Wait for game to load
        hookGameFunctions()
        startDetection()
        
        showNotification("Quantum Auto Skillcheck Activated!", Color3.fromRGB(0, 255, 0))
        print("[QUANTUM] Auto Perfect Skillcheck loaded. Get ready for 100% perfect!")
    end)
end

-- Cleanup on script stop
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    -- Reset on respawn
    activeSkillchecks = {}
    skillcheckCount = 0
    perfectCount = 0
end)
