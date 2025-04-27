```lua
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GilongHUB"
screenGui.Parent = playerGui

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 200, 0, 50)
startButton.Position = UDim2.new(0.5, -100, 0.5, -25)
startButton.Text = "Start Auto Farm"
startButton.Parent = screenGui

local farming = false

local function startAutoFarm()
    farming = true
    while farming do
        print("Mengambil bond...")
        wait(5)
    end
end

startButton.MouseButton1Click:Connect(function()
    if not farming then
        startAutoFarm()
        startButton.Text = "Auto Farm Running"
        startButton.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Gilong HUB Loaded!",
    Text = "Script berhasil dijalankan!",
    Duration = 5
})
```
