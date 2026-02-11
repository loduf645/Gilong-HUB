-- QUANTUM VARIABLE HITBOX V6.0
-- © RianModss - Hitbox with distance control (up to 100+ studs)
-- UI dengan slider buat atur ukuran hitbox

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Configuration dengan distance control
local CONFIG = {
    ENABLED = true,
    AUTO_ATTACH = true,
    HITBOX_SIZE = 50, -- Default size (bisa diubah pake slider)
    MAX_DISTANCE = 100, -- Maximum hit distance
    MIN_DISTANCE = 10, -- Minimum hit distance
    CURRENT_DISTANCE = 50, -- Current hit distance
    AUTO_HIT = true, -- Auto hit targets dalam range
    SHOW_VISUAL = true, -- Tampilkan visual hitbox
    TEAM_CHECK = false, -- True = hanya musuh
    DAMAGE_MULTIPLIER = 2.0, -- Damage multiplier
    KNOCKBACK_POWER = 50, -- Power knockback
    UPDATE_RATE = 0.1, -- Update rate in seconds
}

-- Storage
local hitboxInstances = {}
local activeHitboxes = {}
local targetList = {}
local hitboxVisuals = {}

-- Quantum Hitbox Creator dengan distance control
function createVariableHitbox(tool)
    if not tool or not tool:IsA("Tool") then return end
    if hitboxInstances[tool] then return end
    
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    
    -- Hitbox part utama
    local hitbox = Instance.new("Part")
    hitbox.Name = "QuantumHitbox_" .. tool.Name
    hitbox.Size = Vector3.new(CONFIG.CURRENT_DISTANCE, CONFIG.CURRENT_DISTANCE, CONFIG.CURRENT_DISTANCE)
    hitbox.Transparency = CONFIG.SHOW_VISUAL and 0.3 or 1
    hitbox.Color = Color3.fromRGB(255, 0, 0)
    hitbox.CanCollide = false
    hitbox.Anchored = false
    hitbox.Massless = true
    hitbox.Parent = tool
    
    -- Weld ke handle tool
    local weld = Instance.new("Weld")
    weld.Part0 = handle
    weld.Part1 = hitbox
    weld.C0 = CFrame.new(0, 0, 0)
    weld.Parent = hitbox
    
    -- Touch detection dengan distance check
    hitbox.Touched:Connect(function(hit)
        if not CONFIG.ENABLED then return end
        
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        local rootPart = hit.Parent:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart and hit.Parent ~= LocalPlayer.Character then
            -- Distance check
            local playerRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if playerRoot then
                local distance = (rootPart.Position - playerRoot.Position).Magnitude
                
                if distance <= CONFIG.CURRENT_DISTANCE then
                    -- Team check
                    if CONFIG.TEAM_CHECK then
                        local targetPlayer = Players:GetPlayerFromCharacter(hit.Parent)
                        if targetPlayer and LocalPlayer.Team and targetPlayer.Team then
                            if LocalPlayer.Team == targetPlayer.Team then
                                return -- Skip teammate
                            end
                        end
                    end
                    
                    -- Apply damage dengan multiplier
                    local damage = humanoid.MaxHealth * 0.1 * CONFIG.DAMAGE_MULTIPLIER
                    humanoid:TakeDamage(damage)
                    
                    -- Apply knockback
                    if CONFIG.KNOCKBACK_POWER > 0 then
                        local knockback = Instance.new("BodyVelocity")
                        knockback.Velocity = (rootPart.Position - playerRoot.Position).Unit * CONFIG.KNOCKBACK_POWER
                        knockback.MaxForce = Vector3.new(10000, 10000, 10000)
                        knockback.P = 10000
                        knockback.Parent = rootPart
                        game:GetService("Debris"):AddItem(knockback, 0.2)
                    end
                    
                    -- Add to target list
                    targetList[hit.Parent] = {
                        lastHit = tick(),
                        hitCount = (targetList[hit.Parent] and targetList[hit.Parent].hitCount or 0) + 1
                    }
                    
                    -- Visual feedback
                    createHitEffect(rootPart.Position)
                end
            end
        end
    end)
    
    hitboxInstances[tool] = {
        hitbox = hitbox,
        weld = weld,
        tool = tool
    }
    
    -- Visual hitbox sphere (jika enabled)
    if CONFIG.SHOW_VISUAL then
        createHitboxVisual(tool, hitbox)
    end
    
    return hitbox
end

-- Buat visual hitbox sphere
function createHitboxVisual(tool, hitboxPart)
    if hitboxVisuals[tool] then
        hitboxVisuals[tool]:Destroy()
    end
    
    local visual = Instance.new("Part")
    visual.Name = "HitboxVisual"
    visual.Shape = Enum.PartType.Ball
    visual.Size = Vector3.new(CONFIG.CURRENT_DISTANCE, CONFIG.CURRENT_DISTANCE, CONFIG.CURRENT_DISTANCE)
    visual.Transparency = 0.7
    visual.Color = Color3.fromRGB(255, 50, 50)
    visual.Material = Enum.Material.Neon
    visual.CanCollide = false
    visual.Anchored = false
    visual.Parent = hitboxPart
    
    local weld = Instance.new("Weld")
    weld.Part0 = hitboxPart
    weld.Part1 = visual
    weld.C0 = CFrame.new(0, 0, 0)
    weld.Parent = visual
    
    hitboxVisuals[tool] = visual
    
    return visual
end

-- Update hitbox size berdasarkan distance setting
function updateHitboxSize()
    for tool, data in pairs(hitboxInstances) do
        if data.hitbox and data.hitbox.Parent then
            -- Update size
            data.hitbox.Size = Vector3.new(
                CONFIG.CURRENT_DISTANCE,
                CONFIG.CURRENT_DISTANCE,
                CONFIG.CURRENT_DISTANCE
            )
            
            -- Update visual
            if CONFIG.SHOW_VISUAL and hitboxVisuals[tool] then
                hitboxVisuals[tool].Size = Vector3.new(
                    CONFIG.CURRENT_DISTANCE,
                    CONFIG.CURRENT_DISTANCE,
                    CONFIG.CURRENT_DISTANCE
                )
                
                -- Update color berdasarkan size
                local sizePercent = (CONFIG.CURRENT_DISTANCE - CONFIG.MIN_DISTANCE) / 
                                   (CONFIG.MAX_DISTANCE - CONFIG.MIN_DISTANCE)
                local color = Color3.fromRGB(
                    255,
                    255 - (sizePercent * 200),
                    50
                )
                hitboxVisuals[tool].Color = color
            end
        end
    end
end

-- Auto attack targets dalam range
function autoAttackInRange()
    if not CONFIG.AUTO_HIT or not LocalPlayer.Character then return end
    
    local playerRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if targetRoot and humanoid and humanoid.Health > 0 then
                local distance = (targetRoot.Position - playerRoot.Position).Magnitude
                
                if distance <= CONFIG.CURRENT_DISTANCE then
                    -- Team check
                    if CONFIG.TEAM_CHECK and LocalPlayer.Team and player.Team then
                        if LocalPlayer.Team == player.Team then
                            goto continue
                        end
                    end
                    
                    -- Auto hit
                    local args = {
                        [1] = targetRoot.Position,
                        [2] = player.Character
                    }
                    
                    -- Try different remote events
                    local remotes = {
                        game:GetService("ReplicatedStorage"):FindFirstChild("HitEvent"),
                        game:GetService("ReplicatedStorage"):FindFirstChild("DamageEvent"),
                        game:GetService("ReplicatedStorage"):FindFirstChild("AttackEvent")
                    }
                    
                    for _, remote in pairs(remotes) do
                        if remote then
                            pcall(function()
                                remote:FireServer(unpack(args))
                            end)
                        end
                    end
                    
                    -- Direct damage
                    humanoid:TakeDamage(25 * CONFIG.DAMAGE_MULTIPLIER)
                    
                    -- Visual effect
                    createHitEffect(targetRoot.Position)
                end
            end
        end
        ::continue::
    end
end

-- Buat efek visual saat hit
function createHitEffect(position)
    local effect = Instance.new("Part")
    effect.Size = Vector3.new(2, 2, 2)
    effect.Position = position
    effect.Anchored = true
    effect.CanCollide = false
    effect.Material = Enum.Material.Neon
    effect.Color = Color3.fromRGB(255, 0, 0)
    effect.Transparency = 0.5
    effect.Parent = workspace
    
    -- Tween untuk efek meledak
    local tween = TweenService:Create(
        effect,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = Vector3.new(0, 0, 0), Transparency = 1}
    )
    
    tween:Play()
    tween.Completed:Connect(function()
        effect:Destroy()
    end)
end

-- Attach hitbox ke semua tools
function attachHitboxes()
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            createVariableHitbox(tool)
        end
    end
    
    -- Juga cek tools yang sedang dipegang
    if LocalPlayer.Character then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                createVariableHitbox(tool)
            end
        end
    end
end

-- DRAGGABLE UI DENGAN SLIDER
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumHitboxUI"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 250)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.Parent = ScreenGui

-- Drag handle
local DragHandle = Instance.new("Frame")
DragHandle.Name = "DragHandle"
DragHandle.Size = UDim2.new(1, 0, 0, 25)
DragHandle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
DragHandle.BorderSizePixel = 0
DragHandle.Parent = MainFrame

local DragText = Instance.new("TextLabel")
DragText.Name = "DragText"
DragText.Text = "🔥 QUANTUM HITBOX V6 (Drag Me)"
DragText.Size = UDim2.new(1, 0, 1, 0)
DragText.BackgroundTransparency = 1
DragText.TextColor3 = Color3.fromRGB(255, 255, 255)
DragText.TextSize = 14
DragText.Font = Enum.Font.SourceSansBold
DragText.Parent = DragHandle

-- Make draggable
local isDragging = false
local dragStartPos = nil

DragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStartPos = input.Position
        MainFrame.BorderColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        MainFrame.Position = MainFrame.Position + UDim2.new(0, delta.X, 0, delta.Y)
        dragStartPos = input.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
        MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "⚡ VARIABLE HITBOX CONTROLS ⚡"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- Distance Slider
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0.9, 0, 0, 50)
SliderFrame.Position = UDim2.new(0.05, 0, 0, 70)
SliderFrame.BackgroundTransparency = 1
SliderFrame.Parent = MainFrame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Text = "HITBOX DISTANCE: " .. CONFIG.CURRENT_DISTANCE .. " studs"
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.BackgroundTransparency = 1
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.TextSize = 14
SliderLabel.Font = Enum.Font.SourceSansBold
SliderLabel.Parent = SliderFrame

local SliderTrack = Instance.new("Frame")
SliderTrack.Name = "SliderTrack"
SliderTrack.Size = UDim2.new(1, 0, 0, 10)
SliderTrack.Position = UDim2.new(0, 0, 0, 25)
SliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderTrack.BorderSizePixel = 0
SliderTrack.Parent = SliderFrame

local SliderFill = Instance.new("Frame")
SliderFill.Name = "SliderFill"
SliderFill.Size = UDim2.new(
    (CONFIG.CURRENT_DISTANCE - CONFIG.MIN_DISTANCE) / 
    (CONFIG.MAX_DISTANCE - CONFIG.MIN_DISTANCE), 
    0, 1, 0
)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack

local SliderButton = Instance.new("TextButton")
SliderButton.Name = "SliderButton"
SliderButton.Size = UDim2.new(0, 20, 0, 20)
SliderButton.Position = UDim2.new(SliderFill.Size.X.Scale, -10, 0, -5)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderButton.Text = ""
SliderButton.Parent = SliderFrame

-- Slider functionality
local sliding = false
SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliding = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = input.Position.X
        local framePos = SliderTrack.AbsolutePosition.X
        local frameSize = SliderTrack.AbsoluteSize.X
        
        local relativePos = math.clamp((mousePos - framePos) / frameSize, 0, 1)
        
        -- Update slider visual
        SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
        SliderButton.Position = UDim2.new(relativePos, -10, 0, -5)
        
        -- Update distance value
        local newDistance = math.floor(
            CONFIG.MIN_DISTANCE + 
            (relativePos * (CONFIG.MAX_DISTANCE - CONFIG.MIN_DISTANCE))
        )
        
        CONFIG.CURRENT_DISTANCE = newDistance
        SliderLabel.Text = "HITBOX DISTANCE: " .. newDistance .. " studs"
        
        -- Update color based on distance
        local colorValue = math.clamp(relativePos * 255, 0, 255)
        SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255 - colorValue, 50)
        
        -- Update hitbox size
        updateHitboxSize()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliding = false
    end
end)

-- Toggle buttons grid
local toggleGrid = Instance.new("Frame")
toggleGrid.Size = UDim2.new(1, -20, 0, 90)
toggleGrid.Position = UDim2.new(0, 10, 0, 130)
toggleGrid.BackgroundTransparency = 1
toggleGrid.Parent = MainFrame

local function CreateToggleBtn(text, setting, position)
    local btn = Instance.new("TextButton")
    btn.Text = text .. "\n" .. (CONFIG[setting] and "ON" or "OFF")
    btn.Size = UDim2.new(0.3, 0, 0, 40)
    btn.Position = position
    btn.BackgroundColor3 = CONFIG[setting] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSans
    btn.Parent = toggleGrid
    
    btn.MouseButton1Click:Connect(function()
        CONFIG[setting] = not CONFIG[setting]
        btn.Text = text .. "\n" .. (CONFIG[setting] and "ON" or "OFF")
        btn.BackgroundColor3 = CONFIG[setting] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        
        if setting == "SHOW_VISUAL" then
            updateHitboxSize()
        end
    end)
end

-- Create toggle buttons
CreateToggleBtn("Hitbox", "ENABLED", UDim2.new(0, 0, 0, 0))
CreateToggleBtn("Auto Hit", "AUTO_HIT", UDim2.new(0.35, 0, 0, 0))
CreateToggleBtn("Visual", "SHOW_VISUAL", UDim2.new(0.7, 0, 0, 0))
CreateToggleBtn("Team Check", "TEAM_CHECK", UDim2.new(0, 0, 0, 45))
CreateToggleBtn("Auto Attach", "AUTO_ATTACH", UDim2.new(0.35, 0, 0, 45))

-- Damage multiplier slider
local damageSlider = Instance.new("Frame")
damageSlider.Size = UDim2.new(0.9, 0, 0, 30)
damageSlider.Position = UDim2.new(0.05, 0, 0, 230)
damageSlider.BackgroundTransparency = 1
damageSlider.Parent = MainFrame

local damageLabel = Instance.new("TextLabel")
damageLabel.Text = "Damage Multiplier: " .. CONFIG.DAMAGE_MULTIPLIER .. "x"
damageLabel.Size = UDim2.new(1, 0, 0, 15)
damageLabel.BackgroundTransparency = 1
damageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
damageLabel.TextSize = 12
damageLabel.Parent = damageSlider

local damageValue = Instance.new("TextButton")
damageValue.Text = "▲ " .. CONFIG.DAMAGE_MULTIPLIER .. "x ▼"
damageValue.Size = UDim2.new(1, 0, 0, 20)
damageValue.Position = UDim2.new(0, 0, 0, 15)
damageValue.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
damageValue.TextColor3 = Color3.fromRGB(255, 255, 255)
damageValue.Parent = damageSlider

damageValue.MouseButton1Click:Connect(function()
    CONFIG.DAMAGE_MULTIPLIER = CONFIG.DAMAGE_MULTIPLIER + 0.5
    if CONFIG.DAMAGE_MULTIPLIER > 5 then
        CONFIG.DAMAGE_MULTIPLIER = 1.0
    end
    damageValue.Text = "▲ " .. CONFIG.DAMAGE_MULTIPLIER .. "x ▼"
    damageLabel.Text = "Damage Multiplier: " .. CONFIG.DAMAGE_MULTIPLIER .. "x"
end)

-- Status display
local statusText = Instance.new("TextLabel")
statusText.Text = "Targets Hit: 0 | Range: " .. CONFIG.CURRENT_DISTANCE .. " studs"
statusText.Size = UDim2.new(1, 0, 0, 20)
statusText.Position = UDim2.new(0, 0, 1, -25)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
statusText.TextSize = 12
statusText.Font = Enum.Font.SourceSansBold
statusText.Parent = MainFrame

-- Auto attach hitboxes
if CONFIG.AUTO_ATTACH then
    task.spawn(function()
        wait(2)
        attachHitboxes()
        
        -- Auto attach when tool added
        LocalPlayer.Backpack.ChildAdded:Connect(function(child)
            wait(0.5)
            if child:IsA("Tool") then
                createVariableHitbox(child)
            end
        end)
        
        -- Auto attach when tool equipped
        if LocalPlayer.Character then
            LocalPlayer.Character.ChildAdded:Connect(function(child)
                if child:IsA("Tool") then
                    createVariableHitbox(child)
                end
            end)
        end
    end)
end

-- Main loop
RunService.Heartbeat:Connect(function(deltaTime)
    if CONFIG.ENABLED then
        -- Auto attack jika enabled
        if CONFIG.AUTO_HIT then
            autoAttackInRange()
        end
        
        -- Update status
        local targetCount = 0
        for _ in pairs(targetList) do
            targetCount = targetCount + 1
        end
        
        statusText.Text = string.format(
            "Targets Hit: %d | Range: %d studs | Damage: %dx",
            targetCount,
            CONFIG.CURRENT_DISTANCE,
            CONFIG.DAMAGE_MULTIPLIER
        )
    end
end)

-- Cleanup old targets
task.spawn(function()
    while true do
        wait(5)
        local currentTime = tick()
        for target, data in pairs(targetList) do
            if currentTime - data.lastHit > 30 then -- Clean setelah 30 detik
                targetList[target] = nil
            end
        end
    end
end)

-- Notification
game.StarterGui:SetCore("SendNotification", {
    Title = "QUANTUM VARIABLE HITBOX V6",
    Text = "Loaded! Drag UI to move. Slider controls distance (10-100 studs)",
    Duration = 5,
})

print("[QUANTUM] Variable Hitbox V6 loaded! Distance control: " .. CONFIG.MIN_DISTANCE .. "-" .. CONFIG.MAX_DISTANCE .. " studs")
