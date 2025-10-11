local ModernNotification = {
    NotificationIcons = {
        ["Info"] = "http://www.roblox.com/asset/?id=8800441559",
        ["Error"] = "http://www.roblox.com/asset/?id=8800303348",
        ["Warning"] = "http://www.roblox.com/asset/?id=8800428538",
        ["Success"] = "http://www.roblox.com/asset/?id=8800441559"
    },
    
    Positions = {
        ["TopRight"] = UDim2.new(1, -20, 0, 20),
        ["TopLeft"] = UDim2.new(0, 20, 0, 20),
        ["BottomRight"] = UDim2.new(1, -20, 1, -20),
        ["BottomLeft"] = UDim2.new(0, 20, 1, -20)
    }
}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create notification container
local function CreateNotificationContainer()
    if game.CoreGui:FindFirstChild("ModernNotifications") then
        return game.CoreGui:FindFirstChild("ModernNotifications")
    end
    
    local container = Instance.new("ScreenGui")
    container.Name = "ModernNotifications"
    container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    container.Parent = game.CoreGui
    
    -- Create layout for top-right positioning
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 20)
    padding.PaddingRight = UDim.new(0, 20)
    padding.Parent = container
    
    return container
end

local function CreateRoundedFrame(parent, size, position)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.Size = size or UDim2.new(0, 350, 0, 0)
    frame.Position = position or UDim2.new(1, -370, 0, 20)
    frame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1
    stroke.Parent = frame
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://5554236805"
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.ZIndex = -1
    shadow.Parent = frame
    
    frame.Parent = parent
    return frame
end

local function Tween(object, properties, duration, easingStyle, easingDirection)
    local info = TweenInfo.new(duration or 0.2, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

function ModernNotification.Show(options)
    options = typeof(options) == "table" and options or {}
    
    local title = tostring(options.Title) or "Notification"
    local message = tostring(options.Message) or "This is a notification"
    local icon = tostring(options.Icon) or "Info"
    local duration = tonumber(options.Duration) or 5
    local position = options.Position or "TopRight"
    local buttons = options.Buttons or {"OK"}
    local callback = typeof(options.Callback) == "function" and options.Callback or function() end
    local accentColor = options.AccentColor or Color3.fromRGB(0, 120, 215)
    
    local container = CreateNotificationContainer()
    local notification = CreateRoundedFrame(container)
    
    -- Notification layout
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 0)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = notification
    
    -- Accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.BackgroundColor3 = accentColor
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.BorderSizePixel = 0
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = accentBar
    accentBar.Parent = notification
    
    -- Content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, -20, 1, 0)
    content.Parent = notification
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.Parent = content
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 24)
    header.Parent = content
    
    local headerLayout = Instance.new("UIListLayout")
    headerLayout.Padding = UDim.new(0, 8)
    headerLayout.FillDirection = Enum.FillDirection.Horizontal
    headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    headerLayout.Parent = header
    
    -- Icon
    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "Icon"
    iconImage.BackgroundTransparency = 1
    iconImage.Size = UDim2.new(0, 16, 0, 16)
    iconImage.Image = ModernNotification.NotificationIcons[icon]
    iconImage.ImageColor3 = accentColor
    iconImage.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -24, 1, 0)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = header
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "Close"
    closeButton.BackgroundTransparency = 1
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    closeButton.TextSize = 16
    closeButton.Parent = header
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.BackgroundTransparency = 1
    messageLabel.Size = UDim2.new(1, 0, 0, 0)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 12
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Parent = content
    
    -- Buttons container
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "Buttons"
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Size = UDim2.new(1, 0, 0, 30)
    buttonsFrame.Parent = content
    
    local buttonsLayout = Instance.new("UIListLayout")
    buttonsLayout.Padding = UDim.new(0, 8)
    buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    buttonsLayout.Parent = buttonsFrame
    
    -- Progress bar (for auto-dismiss)
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.BackgroundColor3 = accentColor
    progressBar.Size = UDim2.new(1, 0, 0, 2)
    progressBar.Position = UDim2.new(0, 0, 1, -2)
    progressBar.BorderSizePixel = 0
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 1)
    progressCorner.Parent = progressBar
    progressBar.Parent = notification
    
    -- Create buttons
    for i, buttonText in ipairs(buttons) do
        local button = Instance.new("TextButton")
        button.Name = buttonText
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.Size = UDim2.new(0, 70, 0, 24)
        button.Font = Enum.Font.Gotham
        button.Text = buttonText
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 12
        button.AutoButtonColor = false
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = button
        
        -- Hover effects
        button.MouseEnter:Connect(function()
            Tween(button, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)})
        end)
        
        button.MouseLeave:Connect(function()
            Tween(button, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)})
        end)
        
        button.MouseButton1Click:Connect(function()
            callback(buttonText)
            DismissNotification(notification)
        end)
        
        button.Parent = buttonsFrame
    end
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        DismissNotification(notification)
    end)
    
    closeButton.MouseEnter:Connect(function()
        Tween(closeButton, {TextColor3 = Color3.fromRGB(255, 255, 255)})
    end)
    
    closeButton.MouseLeave:Connect(function()
        Tween(closeButton, {TextColor3 = Color3.fromRGB(150, 150, 150)})
    end)
    
    -- Calculate sizes
    local function UpdateSizes()
        local messageHeight = math.min(messageLabel.TextBounds.Y, 100) -- Limit max height
        messageLabel.Size = UDim2.new(1, 0, 0, messageHeight)
        
        local totalHeight = 24 + 8 + messageHeight + 8 + 30 + 16
        notification.Size = UDim2.new(0, 350, 0, totalHeight)
        
        contentLayout:ApplyLayout()
    end
    
    messageLabel:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSizes)
    UpdateSizes()
    
    -- Animation in
    notification.Position = ModernNotification.Positions[position] + UDim2.new(0, 400, 0, 0)
    notification.BackgroundTransparency = 1
    
    Tween(notification, {
        Position = ModernNotification.Positions[position],
        BackgroundTransparency = 0
    })
    
    -- Auto-dismiss functionality
    local progressTween
    if duration > 0 then
        progressBar.Size = UDim2.new(1, 0, 0, 2)
        progressTween = Tween(progressBar, {
            Size = UDim2.new(0, 0, 0, 2)
        }, duration, Enum.EasingStyle.Linear)
        
        task.delay(duration, function()
            if notification and notification.Parent then
                DismissNotification(notification)
            end
        end)
    end
    
    -- Hover to pause
    local hoverConnection
    hoverConnection = notification.MouseEnter:Connect(function()
        if progressTween then
            progressTween:Pause()
        end
    end)
    
    notification.MouseLeave:Connect(function()
        if progressTween then
            progressTween:Play()
        end
    end)
end

function DismissNotification(notification)
    if notification and notification.Parent then
        Tween(notification, {
            Position = notification.Position + UDim2.new(0, 400, 0, 0),
            BackgroundTransparency = 1
        }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        
        wait(0.2)
        notification:Destroy()
    end
end

-- Enhanced show function with multiple notification types
function ModernNotification.Info(title, message, duration)
    ModernNotification.Show({
        Title = title,
        Message = message,
        Icon = "Info",
        Duration = duration or 5,
        AccentColor = Color3.fromRGB(0, 120, 215)
    })
end

function ModernNotification.Success(title, message, duration)
    ModernNotification.Show({
        Title = title,
        Message = message,
        Icon = "Success",
        Duration = duration or 3,
        AccentColor = Color3.fromRGB(35, 150, 60)
    })
end

function ModernNotification.Warning(title, message, duration)
    ModernNotification.Show({
        Title = title,
        Message = message,
        Icon = "Warning",
        Duration = duration or 7,
        AccentColor = Color3.fromRGB(225, 150, 0)
    })
end

function ModernNotification.Error(title, message, duration)
    ModernNotification.Show({
        Title = title,
        Message = message,
        Icon = "Error",
        Duration = duration or 10,
        AccentColor = Color3.fromRGB(215, 60, 40)
    })
end

return ModernNotification
