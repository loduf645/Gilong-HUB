-- Fishy Hub v4.6 – Ultimate Fisch Script
-- Compatible with Codex Executor
-- Last Updated: March 2026
-- No Key System

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "Fishy Hub | Fisch",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FishyHub"
})

local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local fishing = false
local autoSell = false
local autoTotem = false

-- Functions
local function castRod()
    local args = {
        [1] = "CastRod"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("FishingService"):WaitForChild("RE_Fish"):FireServer(unpack(args))
end

local function reelIn()
    local args = {
        [1] = "ReelIn"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("FishingService"):WaitForChild("RE_Fish"):FireServer(unpack(args))
end

local function stopReel()
    local args = {
        [1] = "StopReeling"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("FishingService"):WaitForChild("RE_Fish"):FireServer(unpack(args))
end

local function shake()
    local args = {
        [1] = "Shake"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("FishingService"):WaitForChild("RE_Fish"):FireServer(unpack(args))
end

-- Instant catch (silent)
local function instantCatch()
    for i = 1, 10 do
        shake()
        wait(0.01)
    end
    wait(0.05)
    reelIn()
end

-- Auto Fish Loop
local function startFishing()
    fishing = true
    while fishing do
        local rod = LocalPlayer.Character:FindFirstChild("Rod")
        if rod and rod:FindFirstChild("Handle") then
            local isFishing = rod:GetAttribute("Fishing")
            if not isFishing then
                castRod()
                wait(0.5)
            else
                -- In fishing minigame
                local progress = rod:GetAttribute("FishingProgress")
                if progress and progress > 0 then
                    -- Auto shake and reel
                    instantCatch()
                    wait(0.2)
                end
            end
        end
        wait(0.1)
    end
end

-- Auto Sell
local function sellFish()
    local args = {
        [1] = "SellInventory"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ShopService"):WaitForChild("RE_Sell"):FireServer(unpack(args))
end

local function startAutoSell()
    autoSell = true
    while autoSell do
        sellFish()
        wait(60) -- sell every minute
    end
end

-- Auto Totem (if you have totems in inventory)
local function useTotem()
    local args = {
        [1] = "UseTotem"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("TotemService"):WaitForChild("RE_UseTotem"):FireServer(unpack(args))
end

local function startAutoTotem()
    autoTotem = true
    while autoTotem do
        useTotem()
        wait(300) -- every 5 minutes
    end
end

-- UI
FarmTab:AddToggle({
    Name = "Auto Fish (Instant Catch)",
    Default = false,
    Callback = function(Value)
        if Value then
            startFishing()
        else
            fishing = false
        end
    end
})

FarmTab:AddToggle({
    Name = "Auto Sell Fish",
    Default = false,
    Callback = function(Value)
        if Value then
            startAutoSell()
        else
            autoSell = false
        end
    end
})

FarmTab:AddToggle({
    Name = "Auto Use Totem (if available)",
    Default = false,
    Callback = function(Value)
        if Value then
            startAutoTotem()
        else
            autoTotem = false
        end
    end
})

FarmTab:AddButton({
    Name = "Sell All Fish Now",
    Callback = function()
        sellFish()
    end
})

SettingsTab:AddButton({
    Name = "Destroy GUI",
    Callback = function()
        OrionLib:Destroy()
    end
})

OrionLib:Init()
