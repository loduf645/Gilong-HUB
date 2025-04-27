```lua
local screenGui = Instance.new("ScreenGui")
local startButton = Instance.new("TextButton")

startButton.Size = UDim2.new(0, 200, 0, 50)
startButton.Position = UDim2.new(0.5, -100, 0.5, -25)
startButton.Text = "Start Auto Farm"

startButton.Parent = screenGui
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local function startAutoFarm()
    print("Auto Farm Dimulai!")
    
    while true do
        print("Mengambil bond...")
        wait(5)
    end
end

startButton.MouseButton1Click:Connect(function()
    startAutoFarm()
    startButton.Text = "Auto Farm Running"
    startButton.TextColor3 = Color3.fromRGB(0, 255, 0)
end)
```
