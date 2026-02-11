-- QUANTUM GENERATOR SKILLCHECK V4.0
-- © RianModss - Specifically for Violence District Generators
-- UI bisa digeser + auto perfect untuk generator skillcheck

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Configuration
local CONFIG = {
    ENABLED = true,
    AUTO_ENABLE = true,
    GENERATOR_MODE = true, -- Fokus khusus generator
    PERFECT_MODE = true,
    REACTION_TIME = 0.01,
    DEBUG_MODE = false,
    SOUND_ENABLED = true,
    NOTIFICATIONS = true,
    UI_DRAGGABLE = true, -- UI bisa digeser
}

-- Generator skillcheck specific patterns
local GENERATOR_PATTERNS = {
    "Generator",
    "Gen",
    "Power",
    "Engine",
    "Repair",
    "Fix",
    "Start",
    "Activate",
    "Charge",
    "Energy",
    "Progress",
    "BarFill",
    "Meter",
    "Gauge",
}

-- Colors khusus generator UI
local GENERATOR_COLORS = {
    Color3.fromRGB(0, 255, 0),    -- Green (zone perfect)
    Color3.fromRGB(255, 200, 0),  -- Orange (generator color)
    Color3.fromRGB(100, 200, 255),-- Blue (generator UI)
    Color3.fromRGB(255, 100, 100),-- Red (danger zone)
}

-- Storage
local activeSkillchecks = {}
local generatorObjects = {}
local isUIdragging = false
local dragStartPosition = nil
local UI_OFFSET = UDim2.new(0, 10, 0, 10)
local skillcheckCount = 0
local perfectCount = 0

-- Quantum Generator Detector
function detectGeneratorSkillcheck()
    if not CONFIG.ENABLED then return end
    
    -- Cari generator di workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        local objName = string.lower(obj.Name)
        for _, pattern in pairs(GENERATOR_PATTERNS) do
            if string.find(objName, string.lower(pattern)) then
                if not generatorObjects[obj] then
                    registerGenerator(obj)
                end
            end
        end
        
        -- Cek kalo ada part generator (biasanya warna orange/merah)
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            if obj.Color then
                for _, genColor in pairs(GENERATOR_COLORS) do
                    if colorsSimilar(obj.Color, genColor, 0.2) then
                        if not generatorObjects[obj] then
                            registerGenerator(obj)
                        end
                    end
                end
            end
        end
    end
    
    -- Deteksi UI generator skillcheck
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, guiObject in pairs(playerGui:GetDescendants()) do
            if guiObject:IsA("Frame") or guiObject:IsA("ImageLabel") then
                local objName = string.lower(guiObject.Name)
                local objText = guiObject:FindFirstChild("TextLabel") and 
                               string.lower(guiObject.TextLabel.Text or "") or ""
                
                -- Cari UI generator
                for _, pattern in pairs(GENERATOR_PATTERNS) do
                    if string.find(objName, string.lower(pattern)) or 
                       string.find(objText, string.lower(pattern)) then
                        if not activeSkillchecks[guiObject] then
                            registerSkillcheck(guiObject, "GENERATOR_UI")
                        end
                    end
                end
                
                -- Deteksi progress bar generator
                if guiObject:IsA("Frame") and guiObject.Name == "ProgressBar" then
                    if guiObject.Parent and (
                       string.find(string.lower(guiObject.Parent.Name), "gen") or
                       string.find(string.lower(guiObject.Parent.Name), "power")) then
                        registerSkillcheck(guiObject, "GENERATOR_PROGRESS")
                    end
                end
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

function registerGenerator(generatorObj)
    if generatorObjects[generatorObj] then return end
    
    generatorObjects[generatorObj] = {
        object = generatorObj,
        position = generatorObj.Position,
        lastChecked = tick()
    }
    
    if CONFIG.DEBUG_MODE then
        print("[QUANTUM] Generator detected:", generatorObj.Name, generatorObj.ClassName)
    end
    
    -- Cek proximity setiap 2 detik
    task.spawn(function()
        while generatorObjects[generatorObj] do
            wait(2)
            checkGeneratorProximity(generatorObj)
        end
    end)
end

function checkGeneratorProximity(generatorObj)
    if not LocalPlayer.Character then return end
    
    local charRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not charRoot then return end
    
    local distance = (charRoot.Position - generatorObj.Position).Magnitude
    if distance < 15 then -- Dalam range generator
        triggerGeneratorSkillcheck()
    end
end

function registerSkillcheck(uiObject, skillcheckType)
    if activeSkillchecks[uiObject] then return end
    
    activeSkillchecks[uiObject] = {
        object = uiObject,
        type = skillcheckType,
        detected = tick(),
        triggered = false
    }
    
    if CONFIG.DEBUG_MODE then
        print("[QUANTUM]", skillcheckType, "detected:", uiObject.Name)
    end
    
    -- Auto execute generator skillcheck
    task.spawn(function()
        executeGeneratorSkillcheck(uiObject, skillcheckType)
    end)
end

function executeGeneratorSkillcheck(uiObject, skillcheckType)
    if not uiObject or not uiObject.Parent then return end
    
    wait(CONFIG.REACTION_TIME)
    
    local skillcheckData = activeSkillchecks[uiObject]
    if not skillcheckData or skillcheckData.triggered then return end
    
    skillcheckData.triggered = true
    skillcheckCount = skillcheckCount + 1
    
    -- Generator skillcheck biasanya pakai:
    -- 1. Progress bar yang harus di-stop di zona hijau
    -- 2. Tombol yang harus ditekan berulang
    -- 3. Timing tertentu
    
    local success = false
    
    if skillcheckType == "GENERATOR_UI" then
        success = handleGeneratorUI(uiObject)
    elseif skillcheckType == "GENERATOR_PROGRESS" then
        success = handleProgressBar(uiObject)
    end
    
    if success then
        perfectCount = perfectCount + 1
        if CONFIG.NOTIFICATIONS then
            showNotification("GENERATOR PERFECT! " .. perfectCount .. "/" .. skillcheckCount, Color3.fromRGB(0, 255, 0))
        end
        if CONFIG.SOUND_ENABLED then
            playGeneratorSound()
        end
    end
    
    -- Cleanup
    task.delay(3, function()
        activeSkillchecks[uiObject] = nil
    end)
end

function handleGeneratorUI(uiObject)
    -- Generator biasanya E atau F
    local generatorKey = "E"
    
    -- Coba detect key dari text di UI
    for _, child in pairs(uiObject:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            local text = string.upper(child.Text or "")
            if string.find(text, "E") or string.find(text, "F") or string.find(text, "INTERACT") then
                if string.find(text, "F") then generatorKey = "F" end
            end
        end
    end
    
    -- Tekan key untuk generator
    keypress(generatorKey)
    wait(0.1)
    keyrelease(generatorKey)
    
    -- Untuk generator yang butuh hold, tekan lebih lama
    if uiObject.Name:find("Hold") or uiObject.Name:find("Charge") then
        wait(0.5)
        keyrelease(generatorKey)
    end
    
    return true
end

function handleProgressBar(uiObject)
    -- Progress bar generator - perlu di-stop di zona tertentu
    if not uiObject:FindFirstChild("Fill") then return false end
    
    local fill = uiObject.Fill
    local perfectZone = 0.7 -- Biasanya di 70% untuk generator
    
    -- Tunggu sampe fill mencapai perfect zone
    local startTime = tick()
    while tick() - startTime < 3 do -- Timeout 3 detik
        if fill.Size.X.Scale >= perfectZone - 0.05 and 
           fill.Size.X.Scale <= perfectZone + 0.05 then
            -- Perfect zone! Klik
            mouse1click()
            return true
        end
        wait(0.01)
    end
    
    return false
end

function triggerGeneratorSkillcheck()
    -- Coba trigger skillcheck untuk generator
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local remoteName = string.lower(remote.Name)
            if string.find(remoteName, "gen") or 
               string.find(remoteName, "interact") or
               string.find(remoteName, "repair") then
                pcall(function()
                    remote:FireServer("generator")
                    remote:FireServer("repair")
                    remote:FireServer("start")
                end)
            end
        end
    end
    
    -- Juga coba klik E
    keypress("E")
    wait(0.05)
    keyrelease("E")
end

-- Input functions
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

-- DRAGGABLE UI SYSTEM
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumGeneratorHack"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 180)
MainFrame.Position = UI_OFFSET
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0) -- Orange generator theme
MainFrame.Parent = ScreenGui

-- Drag handle
local DragHandle = Instance.new("Frame")
DragHandle.Name = "DragHandle"
DragHandle.Size = UDim2.new(1, 0, 0, 30)
DragHandle.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
DragHandle.BorderSizePixel = 0
DragHandle.Parent = MainFrame

local DragText = Instance.new("TextLabel")
DragText.Name = "DragText"
DragText.Text = "⚡ GENERATOR HACK V4.0 (Drag Here)"
DragText.Size = UDim2.new(1, 0, 1, 0)
DragText.BackgroundTransparency = 1
DragText.TextColor3 = Color3.fromRGB(255, 255, 255)
DragText.TextSize = 16
DragText.Font = Enum.Font.SourceSansBold
DragText.Parent = DragHandle

-- Make draggable
if CONFIG.UI_DRAGGABLE then
    DragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isUIdragging = true
            dragStartPosition = input.Position
            MainFrame.BorderColor3 = Color3.fromRGB(255, 200, 0)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isUIdragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStartPosition
            MainFrame.Position = MainFrame.Position + UDim2.new(0, delta.X, 0, delta.Y)
            dragStartPosition = input.Position
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isUIdragging = false
            MainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
            UI_OFFSET = MainFrame.Position -- Save position
        end
    end)
end

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "⚡ QUANTUM GENERATOR HACK ⚡"
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 200, 0)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Stats Display
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Name = "StatsLabel"
StatsLabel.Text = "Generator Perfect: 0/0 (100%)"
StatsLabel.Size = UDim2.new(1, 0, 0, 25)
StatsLabel.Position = UDim2.new(0, 0, 0, 65)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatsLabel.TextSize = 16
StatsLabel.Font = Enum.Font.SourceSansBold
StatsLabel.Parent = MainFrame

-- Toggle Buttons Grid
local buttonGrid = Instance.new("Frame")
buttonGrid.Name = "ButtonGrid"
buttonGrid.Size = UDim2.new(1, -20, 0, 80)
buttonGrid.Position = UDim2.new(0, 10, 0, 95)
buttonGrid.BackgroundTransparency = 1
buttonGrid.Parent = MainFrame

local function CreateToggle(text, setting, position)
    local button = Instance.new("TextButton")
    button.Text = text .. "\n" .. (CONFIG[setting] and "[ON]" or "[OFF]")
    button.Size = UDim2.new(0.45, 0, 0, 35)
    button.Position = position
    button.BackgroundColor3 = CONFIG[setting] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Font = Enum.Font.SourceSans
    button.Parent = buttonGrid
    
    button.MouseButton1Click:Connect(function()
        CONFIG[setting] = not CONFIG[setting]
        button.Text = text .. "\n" .. (CONFIG[setting] and "[ON]" or "[OFF]")
        button.BackgroundColor3 = CONFIG[setting] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
        
        if setting == "ENABLED" and CONFIG[setting] then
            startGeneratorDetection()
        end
    end)
end

-- Create toggle buttons
CreateToggle("Auto Skillcheck", "ENABLED", UDim2.new(0, 0, 0, 0))
CreateToggle("Perfect Mode", "PERFECT_MODE", UDim2.new(0.55, 0, 0, 0))
CreateToggle("Generator Mode", "GENERATOR_MODE", UDim2.new(0, 0, 0, 40))
CreateToggle("Draggable UI", "UI_DRAGGABLE", UDim2.new(0.55, 0, 0, 40))

-- Status indicator
local statusLight = Instance.new("Frame")
statusLight.Name = "StatusLight"
statusLight.Size = UDim2.new(0, 10, 0, 10)
statusLight.Position = UDim2.new(1, -15, 0, 5)
statusLight.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
statusLight.BorderSizePixel = 0
statusLight.Parent = MainFrame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Text = "X"
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -25, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = MainFrame

closeButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    CONFIG.ENABLED = false
end)

-- Update functions
function updateStats()
    local percentage = skillcheckCount > 0 and math.floor((perfectCount / skillcheckCount) * 100) or 100
    StatsLabel.Text = string.format("Generator Perfect: %d/%d (%d%%)", perfectCount, skillcheckCount, percentage)
    
    -- Update color
    if percentage >= 90 then
        StatsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        statusLight.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    elseif percentage >= 70 then
        StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        statusLight.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    else
        StatsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        statusLight.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end

function showNotification(text, color)
    game.StarterGui:SetCore("SendNotification", {
        Title = "⚡ GENERATOR HACK",
        Text = text,
        Duration = 2,
        Icon = "rbxassetid://9998632201",
    })
end

function playGeneratorSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://3570572155" -- Generator/engine sound
    sound.Volume = 0.2
    sound.Parent = workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end

-- Main detection loop
function startGeneratorDetection()
    task.spawn(function()
        while CONFIG.ENABLED and CONFIG.GENERATOR_MODE do
            detectGeneratorSkillcheck()
            updateStats()
            task.wait(0.2) -- Check 5 times per second
        end
    end)
end

-- Auto-start
if CONFIG.AUTO_ENABLE then
    task.spawn(function()
        wait(3) -- Tunggu game load
        showNotification("Quantum Generator Hack Loaded!\nDrag the orange bar to move UI.", Color3.fromRGB(255, 150, 0))
        startGeneratorDetection()
        print("[QUANTUM] Generator skillcheck hack activated. UI is draggable!")
    end)
end

-- Cleanup
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    generatorObjects = {}
    activeSkillchecks = {}
    skillcheckCount = 0
    perfectCount = 0
end)
