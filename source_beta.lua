local DiscordLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-- Enhanced configuration system
local Config = {
    DefaultPfp = "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png",
    DefaultUsername = LocalPlayer.Name,
    DefaultTag = tostring(math.random(1000, 9999)),
    ConfigFile = "discordlib_config.json",
    Version = "2.0.0"
}

-- Improved data management
local UserData = {
    pfp = Config.DefaultPfp,
    user = Config.DefaultUsername,
    tag = Config.DefaultTag
}

-- Load saved data with better error handling
local function LoadUserData()
    local success, data = pcall(function()
        if readfile and isfile and isfile(Config.ConfigFile) then
            return HttpService:JSONDecode(readfile(Config.ConfigFile))
        end
    end)
    if success and data then
        UserData.pfp = data.pfp or Config.DefaultPfp
        UserData.user = data.user or Config.DefaultUsername
        UserData.tag = data.tag or Config.DefaultTag
    end
end

local function SaveUserData()
    if writefile then
        pcall(function()
            writefile(Config.ConfigFile, HttpService:JSONEncode(UserData))
        end)
    end
end

-- Enhanced draggable function
local function MakeDraggable(topbarObject, object)
    local dragging = false
    local dragInput, dragStart, startPos

    local function Update(input)
        local delta = input.Position - dragStart
        object.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    topbarObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbarObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
end

-- Utility functions
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 4)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

-- Initialize user data
LoadUserData()

-- Create main UI
local Discord = Instance.new("ScreenGui")
Discord.Name = "DiscordUI"
Discord.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
Discord.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Discord.ResetOnSpawn = false

function DiscordLib:Window(title, options)
    options = options or {}
    local size = options.size or UDim2.new(0, 700, 0, 450)
    local position = options.position or UDim2.new(0.5, 0, 0.5, 0)
    
    local currentServer = ""
    local minimized = false
    local firstServer = true
    local settingsOpen = false

    -- Main Container
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Discord
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Position = position
    MainFrame.Size = size
    CreateCorner(MainFrame, 8)

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    CreateCorner(TitleBar, 8, 8, 0, 0)

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = title or "Discord UI"
    Title.TextColor3 = Color3.fromRGB(220, 221, 222)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Control Buttons
    local ControlContainer = Instance.new("Frame")
    ControlContainer.Name = "ControlContainer"
    ControlContainer.Parent = TitleBar
    ControlContainer.BackgroundTransparency = 1
    ControlContainer.Position = UDim2.new(1, -70, 0, 0)
    ControlContainer.Size = UDim2.new(0, 70, 1, 0)

    local MinimizeBtn = CreateControlButton(ControlContainer, "Minimize", UDim2.new(0, 0, 0, 0), "rbxassetid://6035067836")
    local CloseBtn = CreateControlButton(ControlContainer, "Close", UDim2.new(0, 35, 0, 0), "rbxassetid://6035047409")

    -- Server Sidebar
    local ServerSidebar = Instance.new("Frame")
    ServerSidebar.Name = "ServerSidebar"
    ServerSidebar.Parent = MainFrame
    ServerSidebar.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
    ServerSidebar.BorderSizePixel = 0
    ServerSidebar.Position = UDim2.new(0, 0, 0, 30)
    ServerSidebar.Size = UDim2.new(0, 70, 1, -30)

    local ServerList = Instance.new("ScrollingFrame")
    ServerList.Name = "ServerList"
    ServerList.Parent = ServerSidebar
    ServerList.BackgroundTransparency = 1
    ServerList.BorderSizePixel = 0
    ServerList.Position = UDim2.new(0, 0, 0, 10)
    ServerList.Size = UDim2.new(1, 0, 1, -80)
    ServerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    ServerList.ScrollBarThickness = 0

    local ServerListLayout = Instance.new("UIListLayout")
    ServerListLayout.Parent = ServerList
    ServerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ServerListLayout.Padding = UDim.new(0, 8)

    -- User Panel
    local UserPanel = CreateUserPanel(ServerSidebar, UserData)

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
    ContentArea.BorderSizePixel = 0
    ContentArea.Position = UDim2.new(0, 70, 0, 30)
    ContentArea.Size = UDim2.new(1, -70, 1, -30)
    CreateCorner(ContentArea, 0, 0, 8, 8)

    -- Settings System
    local SettingsSystem = CreateSettingsSystem(MainFrame, UserData, SaveUserData)

    -- Control Button Handlers
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quart", 0.3, true)
        wait(0.3)
        MainFrame:Destroy()
    end)

    MinimizeBtn.MouseButton1Click:Connect(function()
        if minimized then
            MainFrame:TweenSize(size, "Out", "Quart", 0.3, true)
        else
            MainFrame:TweenSize(UDim2.new(size.X.Scale, size.X.Offset, 0, 30), "Out", "Quart", 0.3, true)
        end
        minimized = not minimized
    end)

    -- Make draggable
    MakeDraggable(TitleBar, MainFrame)

    -- Server Management
    local Servers = {}
    local CurrentServer = nil

    function Servers:Server(name, icon)
        local server = CreateServer(ServerList, ContentArea, name, icon, firstServer)
        
        if firstServer then
            firstServer = false
            CurrentServer = server
        end

        return server
    end

    -- Notification System
    function DiscordLib:Notification(title, message, duration)
        duration = duration or 5
        CreateNotification(MainFrame, title, message, duration)
    end

    return Servers
end

-- Component Creation Functions
function CreateControlButton(parent, name, position, icon)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    button.BorderSizePixel = 0
    button.Position = position
    button.Size = UDim2.new(0, 30, 1, 0)
    button.Text = ""
    button.AutoButtonColor = false

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Parent = button
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.Image = icon
    icon.ImageColor3 = Color3.fromRGB(220, 221, 222)

    -- Hover effects
    button.MouseEnter:Connect(function()
        if name == "Close" then
            button.BackgroundColor3 = Color3.fromRGB(240, 71, 71)
        else
            button.BackgroundColor3 = Color3.fromRGB(40, 43, 46)
        end
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    end)

    return button
end

function CreateUserPanel(parent, userData)
    local panel = Instance.new("Frame")
    panel.Name = "UserPanel"
    panel.Parent = parent
    panel.BackgroundColor3 = Color3.fromRGB(41, 43, 47)
    panel.BorderSizePixel = 0
    panel.Position = UDim2.new(0, 0, 1, -60)
    panel.Size = UDim2.new(1, 0, 0, 60)
    CreateCorner(panel, 8)

    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Parent = panel
    avatar.BackgroundColor3 = Color3.fromRGB(31, 33, 36)
    avatar.BorderSizePixel = 0
    avatar.Position = UDim2.new(0, 10, 0, 10)
    avatar.Size = UDim2.new(0, 40, 0, 40)
    avatar.Image = userData.pfp
    CreateCorner(avatar, 20)

    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.Parent = panel
    username.BackgroundTransparency = 1
    username.Position = UDim2.new(0, 60, 0, 12)
    username.Size = UDim2.new(1, -70, 0, 18)
    username.Font = Enum.Font.GothamSemibold
    username.Text = userData.user
    username.TextColor3 = Color3.fromRGB(255, 255, 255)
    username.TextSize = 14
    username.TextXAlignment = Enum.TextXAlignment.Left

    local tag = Instance.new("TextLabel")
    tag.Name = "Tag"
    tag.Parent = panel
    tag.BackgroundTransparency = 1
    tag.Position = UDim2.new(0, 60, 0, 30)
    tag.Size = UDim2.new(1, -70, 0, 16)
    tag.Font = Enum.Font.Gotham
    tag.Text = "#" .. userData.tag
    tag.TextColor3 = Color3.fromRGB(150, 152, 157)
    tag.TextSize = 12
    tag.TextXAlignment = Enum.TextXAlignment.Left

    return panel
end

function CreateServer(parent, contentArea, name, icon, isFirst)
    local serverButton = Instance.new("TextButton")
    serverButton.Name = name .. "Server"
    serverButton.Parent = parent
    serverButton.BackgroundColor3 = isFirst and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(47, 49, 54)
    serverButton.BorderSizePixel = 0
    serverButton.Size = UDim2.new(0, 50, 0, 50)
    serverButton.Text = ""
    serverButton.AutoButtonColor = false
    CreateCorner(serverButton, 25)

    local serverIcon = Instance.new(icon and "ImageLabel" or "TextLabel")
    serverIcon.Name = "Icon"
    serverIcon.Parent = serverButton
    serverIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    serverIcon.BackgroundTransparency = 1
    serverIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    serverIcon.Size = UDim2.new(0, 24, 0, 24)
    
    if icon then
        serverIcon.Image = icon
    else
        serverIcon.Text = string.sub(name, 1, 1):upper()
        serverIcon.Font = Enum.Font.GothamBold
        serverIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        serverIcon.TextSize = 14
    end

    -- Server content frame
    local serverFrame = Instance.new("Frame")
    serverFrame.Name = name .. "Frame"
    serverFrame.Parent = contentArea
    serverFrame.BackgroundTransparency = 1
    serverFrame.Size = UDim2.new(1, 0, 1, 0)
    serverFrame.Visible = isFirst

    -- Server management
    local channels = {}
    
    function channels:Channel(name)
        return CreateChannel(serverFrame, name)
    end

    -- Server button interactions
    serverButton.MouseButton1Click:Connect(function()
        -- Hide all server frames
        for _, child in ipairs(contentArea:GetChildren()) do
            if child:IsA("Frame") and child.Name:find("Frame") then
                child.Visible = false
            end
        end
        
        -- Reset all server buttons
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
            end
        end
        
        -- Show this server
        serverFrame.Visible = true
        serverButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    end)

    -- Update server list size
    parent.CanvasSize = UDim2.new(0, 0, 0, #parent:GetChildren() * 58)

    return channels
end

function CreateChannel(parent, name)
    local channel = {}
    local channelFrame = Instance.new("ScrollingFrame")
    channelFrame.Name = name .. "Channel"
    channelFrame.Parent = parent
    channelFrame.BackgroundTransparency = 1
    channelFrame.BorderSizePixel = 0
    channelFrame.Size = UDim2.new(1, 0, 1, 0)
    channelFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    channelFrame.ScrollBarThickness = 4
    channelFrame.ScrollBarImageColor3 = Color3.fromRGB(64, 68, 75)

    local layout = Instance.new("UIListLayout")
    layout.Parent = channelFrame
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)

    local padding = Instance.new("UIPadding")
    padding.Parent = channelFrame
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingTop = UDim.new(0, 15)

    function channel:Button(text, callback)
        local button = Instance.new("TextButton")
        button.Name = text .. "Button"
        button.Parent = channelFrame
        button.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
        button.BorderSizePixel = 0
        button.Size = UDim2.new(1, -30, 0, 40)
        button.Font = Enum.Font.Gotham
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.AutoButtonColor = false
        CreateCorner(button, 6)

        -- Hover effects
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(78, 82, 90)}):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(64, 68, 75)}):Play()
        end)

        button.MouseButton1Click:Connect(function()
            if callback then
                pcall(callback)
            end
        end)

        -- Update canvas size
        channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        
        return button
    end

    function channel:Toggle(text, defaultValue, callback)
        local toggle = {}
        local toggled = defaultValue or false
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = text .. "Toggle"
        toggleFrame.Parent = channelFrame
        toggleFrame.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Size = UDim2.new(1, -30, 0, 40)
        CreateCorner(toggleFrame, 6)

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Parent = toggleFrame
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 15, 0, 0)
        label.Size = UDim2.new(0, 200, 1, 0)
        label.Font = Enum.Font.Gotham
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left

        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "Toggle"
        toggleButton.Parent = toggleFrame
        toggleButton.AnchorPoint = Vector2.new(1, 0.5)
        toggleButton.BackgroundColor3 = toggled and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(114, 118, 125)
        toggleButton.BorderSizePixel = 0
        toggleButton.Position = UDim2.new(1, -15, 0.5, 0)
        toggleButton.Size = UDim2.new(0, 40, 0, 20)
        toggleButton.Text = ""
        toggleButton.AutoButtonColor = false
        CreateCorner(toggleButton, 10)

        local toggleKnob = Instance.new("Frame")
        toggleKnob.Name = "Knob"
        toggleKnob.Parent = toggleButton
        toggleKnob.AnchorPoint = Vector2.new(0.5, 0.5)
        toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleKnob.BorderSizePixel = 0
        toggleKnob.Position = toggled and UDim2.new(0.75, 0, 0.5, 0) or UDim2.new(0.25, 0, 0.5, 0)
        toggleKnob.Size = UDim2.new(0, 16, 0, 16)
        CreateCorner(toggleKnob, 8)

        toggleButton.MouseButton1Click:Connect(function()
            toggled = not toggled
            if toggled then
                TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
                TweenService:Create(toggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0.75, 0, 0.5, 0)}):Play()
            else
                TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(114, 118, 125)}):Play()
                TweenService:Create(toggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0.25, 0, 0.5, 0)}):Play()
            end
            
            if callback then
                pcall(callback, toggled)
            end
        end)

        function toggle:Set(value)
            toggled = value
            if toggled then
                toggleButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
                toggleKnob.Position = UDim2.new(0.75, 0, 0.5, 0)
            else
                toggleButton.BackgroundColor3 = Color3.fromRGB(114, 118, 125)
                toggleKnob.Position = UDim2.new(0.25, 0, 0.5, 0)
            end
        end

        channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        
        return toggle
    end

    function channel:Slider(text, min, max, defaultValue, callback)
        local slider = {}
        local value = defaultValue or min
        
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = text .. "Slider"
        sliderFrame.Parent = channelFrame
        sliderFrame.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.Size = UDim2.new(1, -30, 0, 60)
        CreateCorner(sliderFrame, 6)

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Parent = sliderFrame
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 15, 0, 5)
        label.Size = UDim2.new(1, -30, 0, 20)
        label.Font = Enum.Font.Gotham
        label.Text = text .. ": " .. tostring(value)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left

        local track = Instance.new("Frame")
        track.Name = "Track"
        track.Parent = sliderFrame
        track.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
        track.BorderSizePixel = 0
        track.Position = UDim2.new(0, 15, 0, 35)
        track.Size = UDim2.new(1, -30, 0, 6)
        CreateCorner(track, 3)

        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Parent = track
        fill.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        fill.BorderSizePixel = 0
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        CreateCorner(fill, 3)

        local knob = Instance.new("TextButton")
        knob.Name = "Knob"
        knob.Parent = track
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Text = ""
        knob.AutoButtonColor = false
        CreateCorner(knob, 8)

        local dragging = false

        local function updateValue(input)
            local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            value = math.floor(min + (max - min) * relativeX)
            
            label.Text = text .. ": " .. tostring(value)
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
            knob.Position = UDim2.new(relativeX, 0, 0.5, 0)
            
            if callback then
                pcall(callback, value)
            end
        end

        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)

        knob.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateValue(input)
            end
        end)

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateValue(input)
            end
        end)

        function slider:Set(newValue)
            value = math.clamp(newValue, min, max)
            local relativeX = (value - min) / (max - min)
            
            label.Text = text .. ": " .. tostring(value)
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
            knob.Position = UDim2.new(relativeX, 0, 0.5, 0)
        end

        channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        
        return slider
    end

    function channel:Label(text)
        local labelFrame = Instance.new("Frame")
        labelFrame.Name = text .. "Label"
        labelFrame.Parent = channelFrame
        labelFrame.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
        labelFrame.BorderSizePixel = 0
        labelFrame.Size = UDim2.new(1, -30, 0, 30)
        CreateCorner(labelFrame, 6)

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Parent = labelFrame
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.Gotham
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Center

        channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end

    function channel:Dropdown(text, options, defaultValue, callback)
        local dropdown = {}
        local selected = defaultValue or options[1]
        local open = false
        
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Name = text .. "Dropdown"
        dropdownFrame.Parent = channelFrame
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.Size = UDim2.new(1, -30, 0, 40)
        CreateCorner(dropdownFrame, 6)
        dropdownFrame.ClipsDescendants = true

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Parent = dropdownFrame
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 15, 0, 0)
        label.Size = UDim2.new(0, 200, 1, 0)
        label.Font = Enum.Font.Gotham
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left

        local current = Instance.new("TextLabel")
        current.Name = "Current"
        current.Parent = dropdownFrame
        current.AnchorPoint = Vector2.new(1, 0)
        current.BackgroundTransparency = 1
        current.Position = UDim2.new(1, -35, 0, 0)
        current.Size = UDim2.new(0, 150, 1, 0)
        current.Font = Enum.Font.Gotham
        current.Text = selected
        current.TextColor3 = Color3.fromRGB(200, 200, 200)
        current.TextSize = 14
        current.TextXAlignment = Enum.TextXAlignment.Right

        local arrow = Instance.new("ImageLabel")
        arrow.Name = "Arrow"
        arrow.Parent = dropdownFrame
        arrow.AnchorPoint = Vector2.new(1, 0.5)
        arrow.BackgroundTransparency = 1
        arrow.Position = UDim2.new(1, -15, 0.5, 0)
        arrow.Size = UDim2.new(0, 16, 0, 16)
        arrow.Image = "rbxassetid://6031091004"
        arrow.ImageColor3 = Color3.fromRGB(200, 200, 200)

        local optionsFrame = Instance.new("Frame")
        optionsFrame.Name = "Options"
        optionsFrame.Parent = dropdownFrame
        optionsFrame.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
        optionsFrame.BorderSizePixel = 0
        optionsFrame.Position = UDim2.new(0, 0, 1, 5)
        optionsFrame.Size = UDim2.new(1, 0, 0, 0)
        optionsFrame.Visible = false
        CreateCorner(optionsFrame, 6)

        local optionsLayout = Instance.new("UIListLayout")
        optionsLayout.Parent = optionsFrame
        optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder

        -- Create option buttons
        for i, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Name = option
            optionButton.Parent = optionsFrame
            optionButton.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
            optionButton.BorderSizePixel = 0
            optionButton.Size = UDim2.new(1, 0, 0, 30)
            optionButton.Font = Enum.Font.Gotham
            optionButton.Text = option
            optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            optionButton.TextSize = 14
            optionButton.AutoButtonColor = false

            optionButton.MouseEnter:Connect(function()
                optionButton.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
            end)

            optionButton.MouseLeave:Connect(function()
                optionButton.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
            end)

            optionButton.MouseButton1Click:Connect(function()
                selected = option
                current.Text = selected
                dropdownFrame.Size = UDim2.new(1, -30, 0, 40)
                optionsFrame.Visible = false
                open = false
                
                if callback then
                    pcall(callback, selected)
                end
            end)
        end

        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "Toggle"
        toggleButton.Parent = dropdownFrame
        toggleButton.BackgroundTransparency = 1
        toggleButton.Size = UDim2.new(1, 0, 1, 0)
        toggleButton.Text = ""
        toggleButton.AutoButtonColor = false

        toggleButton.MouseButton1Click:Connect(function()
            open = not open
            if open then
                dropdownFrame.Size = UDim2.new(1, -30, 0, 40 + (#options * 30) + 5)
                optionsFrame.Size = UDim2.new(1, 0, 0, #options * 30)
                optionsFrame.Visible = true
                TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
            else
                dropdownFrame.Size = UDim2.new(1, -30, 0, 40)
                optionsFrame.Visible = false
                TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
            end
        end)

        function dropdown:Set(value)
            if table.find(options, value) then
                selected = value
                current.Text = selected
            end
        end

        channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        
        return dropdown
    end

    return channel
end

function CreateSettingsSystem(parent, userData, saveCallback)
    -- Settings implementation would go here
    -- This is a simplified version - you can expand it based on your needs
    return {
        Open = function() end,
        Close = function() end
    }
end

function CreateNotification(parent, title, message, duration)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Parent = parent
    notification.AnchorPoint = Vector2.new(1, 0)
    notification.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
    notification.BorderSizePixel = 0
    notification.Position = UDim2.new(1, -10, 0, 10)
    notification.Size = UDim2.new(0, 300, 0, 0)
    notification.ClipsDescendants = true
    CreateCorner(notification, 8)
    CreateStroke(notification, Color3.fromRGB(60, 63, 70), 1)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Parent = notification
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.Size = UDim2.new(1, -30, 0, 20)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Parent = notification
    messageLabel.BackgroundTransparency = 1
    messageLabel.Position = UDim2.new(0, 15, 0, 35)
    messageLabel.Size = UDim2.new(1, -30, 0, 40)
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 14
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Animate in
    notification:TweenSize(UDim2.new(0, 300, 0, 85), "Out", "Quart", 0.3)

    -- Auto-remove after duration
    delay(duration, function()
        notification:TweenSize(UDim2.new(0, 300, 0, 0), "Out", "Quart", 0.3)
        wait(0.3)
        notification:Destroy()
    end)
end

-- Initialize the library
LoadUserData()

return DiscordLib
