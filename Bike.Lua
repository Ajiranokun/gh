
-- W + A AUTO HOLD V3
-- XENO EXECUTOR | PC

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

local W = 0x57
local A = 0x41

local enabled = false
local minimized = false

-- CLEAN OLD GUI
pcall(function()
    local old = CoreGui:FindFirstChild("WAAutoHold")
    if old then old:Destroy() end
end)

-- KEY FUNCTIONS
local function pressKeys()
    if type(keypress) ~= "function" then
        return false
    end

    local ok = pcall(function()
        keypress(W)
        keypress(A)
    end)

    return ok
end

local function releaseKeys()
    pcall(function()
        if type(keyrelease) == "function" then
            keyrelease(W)
            keyrelease(A)
        end
    end)
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "WAAutoHold"
gui.ResetOnSpawn = false

local ok = pcall(function()
    gui.Parent = CoreGui
end)

if not ok or not gui.Parent then
    gui.Parent = player:WaitForChild("PlayerGui")
end

-- MAIN FRAME
local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(280, 160)
frame.Position = UDim2.new(0.5, -140, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 10)

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 47)
header.BorderSizePixel = 0
header.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -85, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "W + A AUTO HOLD"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- MINIMIZE BUTTON
local mini = Instance.new("TextButton")
mini.Size = UDim2.fromOffset(35, 30)
mini.Position = UDim2.new(1, -75, 0, 4)
mini.Text = "-"
mini.Font = Enum.Font.GothamBold
mini.TextSize = 20
mini.TextColor3 = Color3.new(1, 1, 1)
mini.BackgroundColor3 = Color3.fromRGB(75, 75, 90)
mini.Parent = header

-- CLOSE BUTTON
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35, 30)
close.Position = UDim2.new(1, -38, 0, 4)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(170, 45, 55)
close.Parent = header

-- CONTENT
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -38)
content.Position = UDim2.fromOffset(0, 38)
content.BackgroundTransparency = 1
content.Parent = frame

-- STATUS
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 35)
status.Position = UDim2.fromOffset(0, 8)
status.BackgroundTransparency = 1
status.Text = "STATUS: OFF"
status.TextColor3 = Color3.fromRGB(210, 210, 210)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.Parent = content

-- TOGGLE
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 220, 0, 48)
toggle.Position = UDim2.new(0.5, -110, 0, 52)
toggle.Text = "OFF"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 16
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.BackgroundColor3 = Color3.fromRGB(170, 45, 55)
toggle.Parent = content

Instance.new("UICorner", toggle).CornerRadius =
    UDim.new(0, 8)

-- TOGGLE FUNCTION
toggle.MouseButton1Click:Connect(function()

    enabled = not enabled

    if enabled then
        local success = pressKeys()

        if success then
            toggle.Text = "ON"
            toggle.BackgroundColor3 =
                Color3.fromRGB(35, 160, 85)
            status.Text = "STATUS: W + A ACTIVE"
        else
            enabled = false
            status.Text = "KEY API ERROR"
        end

    else
        releaseKeys()

        toggle.Text = "OFF"
        toggle.BackgroundColor3 =
            Color3.fromRGB(170, 45, 55)
        status.Text = "STATUS: OFF"
    end
end)

-- MINIMIZE / RESTORE
mini.MouseButton1Click:Connect(function()

    minimized = not minimized

    content.Visible = not minimized

    frame.Size = minimized
        and UDim2.fromOffset(280, 38)
        or UDim2.fromOffset(280, 160)

    mini.Text = minimized and "+" or "-"
end)

-- CLOSE
close.MouseButton1Click:Connect(function()
    enabled = false
    releaseKeys()
    gui:Destroy()
end)

-- DRAG WINDOW
local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UIS.InputChanged:Connect(function(input)

    if dragging and input.UserInputType ==
        Enum.UserInputType.MouseMovement then

        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        dragging = false
    end
end)

-- CLEANUP
gui.Destroying:Connect(function()
    enabled = false
    releaseKeys()
end)

print("W + A AUTO HOLD V3 LOADED")
