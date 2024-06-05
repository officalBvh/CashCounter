local Drop = game.Workspace.Ignored:WaitForChild("Drop")

local totalCash = 0

function setgui()

    -- Instances:

    local HermesGUI = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local TextLabel = Instance.new("TextLabel")


    HermesGUI.Name = "HermesGUI"
    HermesGUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    HermesGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = HermesGUI
    MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.156437129, 0, 0.0736714974, 0)
    MainFrame.Size = UDim2.new(0, 207, 0, 69)

    UICorner.Parent = MainFrame

    TextLabel.Name = "CashLabel"
    TextLabel.Parent = MainFrame
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Position = UDim2.new(0.0144927539, 0, 0.130434781, 0)
    TextLabel.Size = UDim2.new(0, 200, 0, 50)
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.Text = "0$"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14.000
    TextLabel.TextWrapped = true

    makeFrameDraggable(MainFrame)

    return TextLabel
end

function makeFrameDraggable(frame)
    local UserInputService = game:GetService("UserInputService")

    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

local function createGuiIfNeeded()
    local player = game.Players.LocalPlayer
    if not player:FindFirstChild("PlayerGui"):FindFirstChild("HermesGUI") then
        return setgui()
    end
end

local CashLabel = createGuiIfNeeded()

local function updateCashLabel()
    CashLabel.Text = tostring(totalCash) .. "$"
end

local function extractCashAmount(text)
    local amount = string.match(text, "%$%d+[,%.]?%d*")
    if amount then
        local number = amount:match("%d+[,%.]?%d*"):gsub(",", "")
        return tonumber(number)
    else
        return 0
    end
end

local function updateTotalCash()
    totalCash = 0
    for i, v in ipairs(Drop:GetChildren()) do
        if v:IsA("Part") and v.Name == "MoneyDrop" then
            local billboardGui = v:FindFirstChild("BillboardGui")
            if billboardGui then
                local text = billboardGui.TextLabel.Text
                local cashAmount = extractCashAmount(text)
                totalCash = totalCash + cashAmount
            end
        end
    end
    updateCashLabel()
end

Drop.ChildAdded:Connect(function(child)
    if child:IsA("Part") and child.Name == "MoneyDrop" then
        local billboardGui = child:WaitForChild("BillboardGui")
        if billboardGui then
            local text = billboardGui.TextLabel.Text
            local cashAmount = extractCashAmount(text)
            totalCash = totalCash + cashAmount
            updateCashLabel()
        end
    end
end)

Drop.ChildRemoved:Connect(function(child)
    if child:IsA("Part") and child.Name == "MoneyDrop" then
        local billboardGui = child:FindFirstChild("BillboardGui")
        if billboardGui then
            local text = billboardGui.TextLabel.Text
            local cashAmount = extractCashAmount(text)
            totalCash = totalCash - cashAmount
            updateCashLabel()
        end
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1) 
    CashLabel = createGuiIfNeeded()
    updateCashLabel() 
end)


updateTotalCash()

