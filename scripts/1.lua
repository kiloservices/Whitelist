-- Laser Hub Red/Black Animated GUI with Linear Velocity Movement
-- Execute this in a LocalScript (e.g., inside StarterGui or StarterPlayerScripts)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LaserHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame (Red/Black Theme)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1) -- Black
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Red Animated Gradient
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(0.8, 0, 0)),    -- Red
    ColorSequenceKeypoint.new(0.5, Color3.new(0.4, 0, 0)),  -- Dark Red
    ColorSequenceKeypoint.new(1, Color3.new(0.8, 0, 0))     -- Red
})
gradient.Rotation = 45
gradient.Parent = mainFrame

-- Animate Gradient Rotation
coroutine.wrap(function()
    while screenGui and screenGui.Parent do
        for i = 45, 405, 1 do
            gradient.Rotation = i
            RunService.Heartbeat:Wait()
        end
    end
end)()

-- Top Bar (Draggable)
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.new(0.8, 0, 0) -- Red
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Laser Hub"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = topBar

-- Minimize Button
local minimizeButton = Instance.new("ImageButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(1, -55, 0.5, -12.5)
minimizeButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
minimizeButton.AutoButtonColor = false
minimizeButton.Image = "rbxassetid://3926305904" -- Minus icon
minimizeButton.ImageColor3 = Color3.new(1, 1, 1)
minimizeButton.Parent = topBar

-- Close Button
local closeButton = Instance.new("ImageButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -25, 0.5, -12.5)
closeButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
closeButton.AutoButtonColor = false
closeButton.Image = "rbxassetid://3926307971" -- X icon
closeButton.ImageColor3 = Color3.new(1, 1, 1)
closeButton.Parent = topBar

-- Content Frame (for buttons, sliders)
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -40)
contentFrame.Position = UDim2.new(0, 10, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 50"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 16
speedLabel.Parent = contentFrame

-- Speed Slider
local sliderFrame = Instance.new("Frame")
sliderFrame.Name = "SliderFrame"
sliderFrame.Size = UDim2.new(1, 0, 0, 30)
sliderFrame.Position = UDim2.new(0, 0, 0, 30)
sliderFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
sliderFrame.BorderSizePixel = 0
sliderFrame.Parent = contentFrame

local sliderButton = Instance.new("TextButton")
sliderButton.Name = "SliderButton"
sliderButton.Size = UDim2.new(0, 20, 1, 0)
sliderButton.Position = UDim2.new(0, 0, 0, 0)
sliderButton.BackgroundColor3 = Color3.new(0.8, 0, 0) -- Red
sliderButton.Text = ""
sliderButton.AutoButtonColor = false
sliderButton.Parent = sliderFrame

local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.new(0.8, 0, 0)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderFrame

local speed = 50
local minSpeed = 10
local maxSpeed = 200

-- Instructions
local instructions = Instance.new("TextLabel")
instructions.Name = "Instructions"
instructions.Size = UDim2.new(1, 0, 0, 50)
instructions.Position = UDim2.new(0, 0, 0, 80)
instructions.BackgroundTransparency = 1
instructions.Text = "WASD to move\nLinear Velocity | No Gravity"
instructions.TextColor3 = Color3.new(1, 1, 1)
instructions.Font = Enum.Font.Gotham
instructions.TextSize = 14
instructions.TextWrapped = true
instructions.Parent = contentFrame

-- Drag Functionality
local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Minimize/Maximize
local minimized = false
local originalSize = mainFrame.Size
local originalContentVisible = true

minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        originalSize = mainFrame.Size
        mainFrame.Size = UDim2.new(originalSize.X, UDim2.new(0, 400, 0, 30))
        contentFrame.Visible = false
        minimizeButton.Image = "rbxassetid://3926305904" -- Keep minus (could change to plus if desired)
    else
        mainFrame.Size = originalSize
        contentFrame.Visible = true
    end
end)

-- Close Button
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    -- Also clean up linear velocity if needed (but GUI destroyed will handle children)
end)

-- Slider Logic
local sliderActive = false

sliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderActive = true
    end
end)

sliderButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderActive = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderActive and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = sliderFrame.AbsolutePosition
        local sliderSize = sliderFrame.AbsoluteSize.X
        local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize)
        local percent = relativeX / sliderSize
        
        speed = math.floor(minSpeed + (maxSpeed - minSpeed) * percent)
        speedLabel.Text = "Speed: " .. speed
        
        sliderButton.Position = UDim2.new(0, relativeX - sliderButton.AbsoluteSize.X/2, 0, 0)
        sliderFill.Size = UDim2.new(0, relativeX, 1, 0)
    end
end)

-- Initialize slider position to 50 speed (approx 20% of range)
local initialPercent = (speed - minSpeed) / (maxSpeed - minSpeed)
local initialX = initialPercent * sliderFrame.AbsoluteSize.X
sliderButton.Position = UDim2.new(0, initialX - sliderButton.AbsoluteSize.X/2, 0, 0)
sliderFill.Size = UDim2.new(0, initialX, 1, 0)

-- Linear Velocity Setup
local linearVelocity = Instance.new("LinearVelocity")
linearVelocity.Name = "LaserHub_Velocity"
linearVelocity.Parent = humanoidRootPart
linearVelocity.MaxForce = 4000
linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)

-- No gravity: we set LinearVelocity to counteract gravity if needed, but simpler: disable gravity on humanoid?
-- Actually we just don't apply vertical velocity, and ensure no gravity affects movement.
-- We'll also set humanoid to platform stand to prevent fall?
local humanoid = character:WaitForChild("Humanoid")
humanoid.PlatformStand = true -- Prevents falling due to gravity

-- Movement Variables
local moveDirection = Vector3.new(0, 0, 0)

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then
        moveDirection = moveDirection + Vector3.new(0, 0, -1)
    elseif input.KeyCode == Enum.KeyCode.A then
        moveDirection = moveDirection + Vector3.new(-1, 0, 0)
    elseif input.KeyCode == Enum.KeyCode.S then
        moveDirection = moveDirection + Vector3.new(0, 0, 1)
    elseif input.KeyCode == Enum.KeyCode.D then
        moveDirection = moveDirection + Vector3.new(1, 0, 0)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then
        moveDirection = moveDirection - Vector3.new(0, 0, -1)
    elseif input.KeyCode == Enum.KeyCode.A then
        moveDirection = moveDirection - Vector3.new(-1, 0, 0)
    elseif input.KeyCode == Enum.KeyCode.S then
        moveDirection = moveDirection - Vector3.new(0, 0, 1)
    elseif input.KeyCode == Enum.KeyCode.D then
        moveDirection = moveDirection - Vector3.new(1, 0, 0)
    end
end)

-- Update velocity each frame
RunService.Heartbeat:Connect(function()
    if linearVelocity and linearVelocity.Parent then
        -- Normalize diagonal movement and apply speed
        local dir = moveDirection
        if dir.Magnitude > 0 then
            dir = dir.Unit * speed
        end
        linearVelocity.VectorVelocity = Vector3.new(dir.X, 0, dir.Z) -- No vertical movement
    end
end)

-- Character Respawn Handling
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    humanoid.PlatformStand = true
    
    -- Recreate LinearVelocity
    linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.Name = "LaserHub_Velocity"
    linearVelocity.Parent = humanoidRootPart
    linearVelocity.MaxForce = 4000
    linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
end)

-- Cleanup on GUI close
screenGui.Destroying:Connect(function()
    if linearVelocity and linearVelocity.Parent then
        linearVelocity:Destroy()
    end
    if humanoid then
        humanoid.PlatformStand = false
    end
end)
