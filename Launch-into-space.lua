local replicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local monetisationService = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.6.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("MonetisationService"):WaitForChild("RF"):WaitForChild("PurchaseWithGems")
local petsService = replicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.6.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("PetsService"):WaitForChild("RF"):WaitForChild("HatchEgg")

local isSpamming = false
local isHatching = false
local spamLoop = nil
local hatchLoop = nil
local isMenuVisible = true

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 200)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.Parent = screenGui

-- Add "MADE BY SEMODGE" Label
local madeByLabel = Instance.new("TextLabel")
madeByLabel.Size = UDim2.new(0, 200, 0, 20)
madeByLabel.Position = UDim2.new(0, 5, 0, 5)
madeByLabel.Text = "MADE BY SEMODGE"
madeByLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
madeByLabel.TextSize = 17 -- Reduced size
madeByLabel.Font = Enum.Font.LuckiestGuy
madeByLabel.BackgroundTransparency = 1
madeByLabel.Parent = mainFrame

-- UI Stroke (Animated RGB Gradient)
local uiStroke = Instance.new("UIStroke")
uiStroke.Parent = mainFrame
uiStroke.Thickness = 5
uiStroke.Color = Color3.fromRGB(0, 255, 255) -- Initial color (cyan)
uiStroke.Transparency = 0
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.LineJoinMode = Enum.LineJoinMode.Round

-- UI Gradient
local uiGradient = Instance.new("UIGradient")
uiGradient.Parent = mainFrame
uiGradient.Rotation = 45
uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
})

-- UI Corner
local uiCorner = Instance.new("UICorner")
uiCorner.Parent = mainFrame
uiCorner.CornerRadius = UDim.new(0, 10)

-- Spamming Button
local spamButton = Instance.new("TextButton")
spamButton.Size = UDim2.new(0, 200, 0, 50)
spamButton.Position = UDim2.new(0.5, -100, 0.5, -75)
spamButton.Text = "Start Spamming"
spamButton.TextColor3 = Color3.fromRGB(0, 255, 255)
spamButton.TextSize = 23
spamButton.Font = Enum.Font.LuckiestGuy
spamButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80) 
spamButton.Parent = mainFrame

-- UI Corner for Spamming Button
local spamButtonCorner = Instance.new("UICorner")
spamButtonCorner.Parent = spamButton

-- Hatching Button
local hatchButton = Instance.new("TextButton")
hatchButton.Size = UDim2.new(0, 200, 0, 50)
hatchButton.Position = UDim2.new(0.5, -100, 0.5, 25)
hatchButton.Text = "Start Hatching"
hatchButton.TextColor3 = Color3.fromRGB(0, 255, 255) -- Cyan text
hatchButton.TextSize = 23
hatchButton.Font = Enum.Font.LuckiestGuy
hatchButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
hatchButton.Parent = mainFrame

-- UI Corner for Hatching Button
local hatchButtonCorner = Instance.new("UICorner")
hatchButtonCorner.Parent = hatchButton

-- Hide Button
local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.new(0, 40, 0, 40)
hideButton.Position = UDim2.new(1, -50, 0, 0)
hideButton.Text = "HIDE"
hideButton.TextColor3 = Color3.fromRGB(0, 255, 255)
hideButton.TextSize = 23
hideButton.Font = Enum.Font.LuckiestGuy
hideButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80) 
hideButton.Parent = mainFrame

-- UI Corner for Hide Button
local hideButtonCorner = Instance.new("UICorner")
hideButtonCorner.Parent = hideButton

-- Functions

-- Start/Stop Spamming
local function startSpamming()
    if not isSpamming then
        isSpamming = true
        spamButton.Text = "Stop Spamming"
        spamLoop = game:GetService("RunService").Heartbeat:Connect(function()
            local args = {"SuperSkipRebirth3", false}
            monetisationService:InvokeServer(unpack(args))
        end)
    else
        isSpamming = false
        spamButton.Text = "Start Spamming"
        if spamLoop then
            spamLoop:Disconnect()
            spamLoop = nil
        end
    end
end

-- Start/Stop Hatching
local function startHatching()
    if not isHatching then
        isHatching = true
        hatchButton.Text = "Stop Hatching"
        hatchLoop = game:GetService("RunService").Heartbeat:Connect(function()
            local args = {"GalaxyEggSolar", 4}
            petsService:InvokeServer(unpack(args))
        end)
    else
        isHatching = false
        hatchButton.Text = "Start Hatching"
        if hatchLoop then
            hatchLoop:Disconnect()
            hatchLoop = nil
        end
    end
end

-- Button Connections
spamButton.MouseButton1Click:Connect(startSpamming)
hatchButton.MouseButton1Click:Connect(startHatching)

-- Hide the window
hideButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    isMenuVisible = false
end)

-- Toggle visibility with Left Ctrl key
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.LeftControl then
            isMenuVisible = not isMenuVisible
            mainFrame.Visible = isMenuVisible
        end
    end
end)

-- Smooth RGB Animation for Stroke and Gradient
local function animateRGB()
    local t = 0
    while true do
        -- Calculate smooth RGB values using sine functions
        local r = math.sin(t) * 127 + 128  -- Red
        local g = math.sin(t + math.pi / 3) * 127 + 128  -- Green
        local b = math.sin(t + math.pi * 2 / 3) * 127 + 128  -- Blue

        -- Ensure the RGB values are always bright (clamping to avoid dark colors)
        r = math.clamp(r, 100, 255)
        g = math.clamp(g, 100, 255)
        b = math.clamp(b, 100, 255)

        -- Update UIStroke color with RGB values
        uiStroke.Color = Color3.fromRGB(r, g, b)

        -- Update UIGradient colors with RGB values
        uiGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(r, g, b)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(b, r, g))
        })

        -- Increment time for smooth transition (make it faster by decreasing the increment)
        t = t + 0.1  -- Increased speed
        task.wait(0.05)  -- Adjust to control animation smoothness
    end
end

-- Start the RGB animation
task.spawn(animateRGB)

-- Draggable Menu Logic
local dragging, dragInput, dragStart, startPos

-- Function to start dragging
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

-- Function to handle dragging
mainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Stop dragging
mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
