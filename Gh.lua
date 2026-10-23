
-- PLAYER CONTROL MENU
-- Fly + NoClip + Highlight + WalkSpeed
-- ใส่ใน StarterPlayer > StarterPlayerScripts > LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

local flyEnabled = false
local noclipEnabled = false
local highlightEnabled = true
local walkSpeedEnabled = false

local flySpeed = 80
local walkSpeedValue = 100

local character, humanoid, root
local flyVelocity, flyGyro
local highlights = {}
local savedCollisions = {}
local noclipConnection
local flyConnection

local function getCharacter(char)
    character = char or player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")
end

getCharacter()

local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("PlayerControlMenu")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "PlayerControlMenu"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(280, 355)
frame.Position = UDim2.new(0, 20, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
title.Text = "PLAYER CONTROL"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = frame

local dragging = false
local dragStart, startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = frame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local function makeButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(65, 65, 90)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.Parent = frame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
    return button
end

local function setState(button, label, enabled)
    button.Text = label .. (enabled and "ON" or "OFF")
    button.BackgroundColor3 = enabled
        and Color3.fromRGB(0, 140, 80)
        or Color3.fromRGB(65, 65, 90)
end

local function makeSlider(text, y, minValue, maxValue, defaultValue, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, y)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text .. ": " .. defaultValue
    label.Parent = frame

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, -20, 0, 14)
    bar.Position = UDim2.new(0, 10, 0, y + 20)
    bar.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
    bar.Text = ""
    bar.Parent = frame

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(
        (defaultValue - minValue) / (maxValue - minValue), 0, 1, 0
    )
    fill.Parent = bar

    local sliding = false

    local function update(x)
        local width = bar.AbsoluteSize.X
        if width <= 0 then return end

        local percent = math.clamp(
            (x - bar.AbsolutePosition.X) / width, 0, 1
        )
        local value = math.floor(
            minValue + (maxValue - minValue) * percent + 0.5
        )

        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = text .. ": " .. value
        callback(value)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            update(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if sliding and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            update(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

local flyButton = makeButton("Fly: OFF", 42)
local noclipButton = makeButton("NoClip: OFF", 78)

makeSlider("ความเร็วบิน", 112, 1, 300, flySpeed, function(value)
    flySpeed = value
end)

local highlightButton = makeButton("Highlight ผู้เล่น: ON", 156)
local walkButton = makeButton("วิ่งเร็ว: OFF", 192)

makeSlider("ความเร็ววิ่ง", 226, 1, 500, walkSpeedValue, function(value)
    walkSpeedValue = value
    if walkSpeedEnabled and humanoid then
        humanoid.WalkSpeed = value
    end
end)

local hideButton = makeButton("ซ่อนเมนู", 280)

local showButton = Instance.new("TextButton")
showButton.Size = UDim2.fromOffset(100, 35)
showButton.Position = UDim2.new(0, 20, 0, 20)
showButton.BackgroundColor3 = Color3.fromRGB(40, 100, 160)
showButton.Text = "เปิดเมนู"
showButton.TextColor3 = Color3.new(1, 1, 1)
showButton.Visible = false
showButton.Parent = gui

Instance.new("UICorner", showButton).CornerRadius = UDim.new(0, 6)

hideButton.Activated:Connect(function()
    frame.Visible = false
    showButton.Visible = true
end)

showButton.Activated:Connect(function()
    frame.Visible = true
    showButton.Visible = false
end)

-- Highlight ผู้เล่น
local function addHighlight(other)
    if other == player or highlights[other] then return end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.8
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = highlightEnabled
    highlight.Parent = workspace
    highlights[other] = highlight

    local function update(char)
        if highlights[other] then
            highlights[other].Adornee = char
        end
    end

    if other.Character then update(other.Character) end
    other.CharacterAdded:Connect(update)
end

local function removeHighlight(other)
    if highlights[other] then
        highlights[other]:Destroy()
        highlights[other] = nil
    end
end

for _, other in ipairs(Players:GetPlayers()) do
    addHighlight(other)
end

Players.PlayerAdded:Connect(addHighlight)
Players.PlayerRemoving:Connect(removeHighlight)

highlightButton.Activated:Connect(function()
    highlightEnabled = not highlightEnabled
    highlightButton.Text = "Highlight ผู้เล่น: "
        .. (highlightEnabled and "ON" or "OFF")

    for _, highlight in pairs(highlights) do
        highlight.Enabled = highlightEnabled
    end
end)

-- Fly
local function stopFly()
    flyEnabled = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end

    if flyGyro then
        flyGyro:Destroy()
        flyGyro = nil
    end

    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function startFly()
    if not root or not humanoid or humanoid.Health <= 0 then return end
    if flyEnabled then return end

    flyEnabled = true
    humanoid.PlatformStand = true

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.Parent = root

    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyGyro.P = 10000
    flyGyro.Parent = root

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled or not root or not flyVelocity or not flyGyro then
            return
        end

        local camera = workspace.CurrentCamera
        if not camera then return end

        local move = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            move += camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            move -= camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            move += camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            move -= camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            move += Vector3.yAxis
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            move -= Vector3.yAxis
        end

        flyVelocity.Velocity = move.Magnitude > 0
            and move.Unit * flySpeed or Vector3.zero

        flyGyro.CFrame = camera.CFrame
    end)
end

flyButton.Activated:Connect(function()
    if flyEnabled then
        stopFly()
    else
        startFly()
    end

    setState(flyButton, "Fly: ", flyEnabled)
end)

-- NoClip
local function restoreCollisions()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    for part, value in pairs(savedCollisions) do
        if part and part.Parent then
            part.CanCollide = value
        end
    end

    table.clear(savedCollisions)
end

local function applyNoClip()
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if savedCollisions[part] == nil then
                savedCollisions[part] = part.CanCollide
            end
            part.CanCollide = false
        end
    end
end

noclipButton.Activated:Connect(function()
    noclipEnabled = not noclipEnabled

    if noclipEnabled then
        applyNoClip()
        noclipConnection = RunService.Stepped:Connect(applyNoClip)
    else
        restoreCollisions()
    end

    setState(noclipButton, "NoClip: ", noclipEnabled)
end)

-- วิ่งเร็ว
walkButton.Activated:Connect(function()
    walkSpeedEnabled = not walkSpeedEnabled

    if humanoid then
        humanoid.WalkSpeed = walkSpeedEnabled and walkSpeedValue or 16
    end

    setState(walkButton, "วิ่งเร็ว: ", walkSpeedEnabled)
end)

-- เกิดใหม่
player.CharacterAdded:Connect(function(newCharacter)
    stopFly()
    restoreCollisions()

    noclipEnabled = false
    getCharacter(newCharacter)

    humanoid.WalkSpeed = walkSpeedEnabled and walkSpeedValue or 16

    setState(flyButton, "Fly: ", false)
    setState(noclipButton, "NoClip: ", false)
end)

print("Player Control Menu loaded!")
