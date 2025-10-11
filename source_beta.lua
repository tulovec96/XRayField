local DiscordLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
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
    local size = UDim2.new(0, 681, 0, 396)
    local position = UDim2.new(0.5, 0, 0.5, 0)
    
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

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 22)

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.01, 0, 0, 0)
    Title.Size = UDim2.new(0, 192, 0, 22)
    Title.Font = Enum.Font.Gotham
    Title.Text = title or "Discord Library"
    Title.TextColor3 = Color3.fromRGB(99, 102, 109)
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Control Buttons
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Parent = TitleBar
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Position = UDim2.new(0.918, 0, 0, 0)
    MinimizeBtn.Size = UDim2.new(0, 28, 0, 22)
    MinimizeBtn.Text = ""
    MinimizeBtn.AutoButtonColor = false

    local MinimizeIcon = Instance.new("ImageLabel")
    MinimizeIcon.Name = "MinimizeIcon"
    MinimizeIcon.Parent = MinimizeBtn
    MinimizeIcon.BackgroundTransparency = 1
    MinimizeIcon.Position = UDim2.new(0.189, 0, 0.129, 0)
    MinimizeIcon.Size = UDim2.new(0, 17, 0, 17)
    MinimizeIcon.Image = "http://www.roblox.com/asset/?id=6035067836"
    MinimizeIcon.ImageColor3 = Color3.fromRGB(220, 221, 222)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(0.959, 0, 0, 0)
    CloseBtn.Size = UDim2.new(0, 28, 0, 22)
    CloseBtn.Text = ""
    CloseBtn.AutoButtonColor = false

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Name = "CloseIcon"
    CloseIcon.Parent = CloseBtn
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Position = UDim2.new(0.189, 0, 0.129, 0)
    CloseIcon.Size = UDim2.new(0, 17, 0, 17)
    CloseIcon.Image = "http://www.roblox.com/asset/?id=6035047409"
    CloseIcon.ImageColor3 = Color3.fromRGB(220, 221, 222)

    -- Server Sidebar
    local ServerSidebar = Instance.new("Frame")
    ServerSidebar.Name = "ServerSidebar"
    ServerSidebar.Parent = MainFrame
    ServerSidebar.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
    ServerSidebar.BorderSizePixel = 0
    ServerSidebar.Position = UDim2.new(0, 0, 0, 22)
    ServerSidebar.Size = UDim2.new(0, 71, 1, -22)

    local ServerList = Instance.new("ScrollingFrame")
    ServerList.Name = "ServerList"
    ServerList.Parent = ServerSidebar
    ServerList.BackgroundTransparency = 1
    ServerList.BorderSizePixel = 0
    ServerList.Position = UDim2.new(0, 0, 0, 0)
    ServerList.Size = UDim2.new(1, 0, 1, -43)
    ServerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    ServerList.ScrollBarThickness = 0

    local ServerListLayout = Instance.new("UIListLayout")
    ServerListLayout.Parent = ServerList
    ServerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ServerListLayout.Padding = UDim.new(0, 7)

    -- User Panel
    local UserPanel = Instance.new("Frame")
    UserPanel.Name = "UserPanel"
    UserPanel.Parent = ServerSidebar
    UserPanel.BackgroundColor3 = Color3.fromRGB(41, 43, 47)
    UserPanel.BorderSizePixel = 0
    UserPanel.Position = UDim2.new(0, 0, 1, -43)
    UserPanel.Size = UDim2.new(1, 0, 0, 43)

    local UserIcon = Instance.new("Frame")
    UserIcon.Name = "UserIcon"
    UserIcon.Parent = UserPanel
    UserIcon.BackgroundColor3 = Color3.fromRGB(31, 33, 36)
    UserIcon.BorderSizePixel = 0
    UserIcon.Position = UDim2.new(0.034, 0, 0.124, 0)
    UserIcon.Size = UDim2.new(0, 32, 0, 32)
    CreateCorner(UserIcon, 16)

    local UserImage = Instance.new("ImageLabel")
    UserImage.Name = "UserImage"
    UserImage.Parent = UserIcon
    UserImage.BackgroundTransparency = 1
    UserImage.Size = UDim2.new(1, 0, 1, 0)
    UserImage.Image = UserData.pfp
    CreateCorner(UserImage, 16)

    local UserName = Instance.new("TextLabel")
    UserName.Name = "UserName"
    UserName.Parent = UserPanel
    UserName.BackgroundTransparency = 1
    UserName.Position = UDim2.new(0.23, 0, 0.116, 0)
    UserName.Size = UDim2.new(0, 98, 0, 17)
    UserName.Font = Enum.Font.GothamSemibold
    UserName.Text = UserData.user
    UserName.TextColor3 = Color3.fromRGB(255, 255, 255)
    UserName.TextSize = 13
    UserName.TextXAlignment = Enum.TextXAlignment.Left

    local UserTag = Instance.new("TextLabel")
    UserTag.Name = "UserTag"
    UserTag.Parent = UserPanel
    UserTag.BackgroundTransparency = 1
    UserTag.Position = UDim2.new(0.23, 0, 0.455, 0)
    UserTag.Size = UDim2.new(0, 95, 0, 17)
    UserTag.Font = Enum.Font.Gotham
    UserTag.Text = "#" .. UserData.tag
    UserTag.TextColor3 = Color3.fromRGB(255, 255, 255)
    UserTag.TextSize = 13
    UserTag.TextTransparency = 0.3
    UserTag.TextXAlignment = Enum.TextXAlignment.Left

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
    ContentArea.BorderSizePixel = 0
    ContentArea.Position = UDim2.new(0, 71, 0, 22)
    ContentArea.Size = UDim2.new(1, -71, 1, -22)

    -- Control Button Handlers
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quart", 0.3, true)
    end)

    CloseBtn.MouseEnter:Connect(function()
        CloseBtn.BackgroundColor3 = Color3.fromRGB(240, 71, 71)
    end)

    CloseBtn.MouseLeave:Connect(function()
        CloseBtn.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    end)

    MinimizeBtn.MouseButton1Click:Connect(function()
        if minimized then
            MainFrame:TweenSize(size, "Out", "Quart", 0.3, true)
        else
            MainFrame:TweenSize(UDim2.new(size.X.Scale, size.X.Offset, 0, 22), "Out", "Quart", 0.3, true)
        end
        minimized = not minimized
    end)

    MinimizeBtn.MouseEnter:Connect(function()
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 43, 46)
    end)

    MinimizeBtn.MouseLeave:Connect(function()
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    end)

    -- Make draggable
    MakeDraggable(TitleBar, MainFrame)

    -- Server Management
    local Servers = {}
    local ServerFrames = {}

    function Servers:Server(name, icon)
        local server = {}
        
        -- Server Button
        local serverButton = Instance.new("TextButton")
        serverButton.Name = name .. "Server"
        serverButton.Parent = ServerList
        serverButton.BackgroundColor3 = firstServer and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(47, 49, 54)
        serverButton.BorderSizePixel = 0
        serverButton.Size = UDim2.new(0, 47, 0, 47)
        serverButton.Text = ""
        serverButton.AutoButtonColor = false
        CreateCorner(serverButton, 24)

        local serverIcon
        if icon and icon ~= "" then
            serverIcon = Instance.new("ImageLabel")
            serverIcon.Name = "Icon"
            serverIcon.Parent = serverButton
            serverIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            serverIcon.BackgroundTransparency = 1
            serverIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
            serverIcon.Size = UDim2.new(0, 26, 0, 26)
            serverIcon.Image = icon
        else
            serverIcon = Instance.new("TextLabel")
            serverIcon.Name = "Icon"
            serverIcon.Parent = serverButton
            serverIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            serverIcon.BackgroundTransparency = 1
            serverIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
            serverIcon.Size = UDim2.new(1, 0, 1, 0)
            serverIcon.Font = Enum.Font.GothamBold
            serverIcon.Text = string.sub(name, 1, 1):upper()
            serverIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
            serverIcon.TextSize = 14
        end

        -- Server Content Frame
        local serverFrame = Instance.new("Frame")
        serverFrame.Name = name .. "Frame"
        serverFrame.Parent = ContentArea
        serverFrame.BackgroundTransparency = 1
        serverFrame.Size = UDim2.new(1, 0, 1, 0)
        serverFrame.Visible = firstServer

        ServerFrames[name] = serverFrame

        -- Channel Management
        local Channels = {}
        local ChannelFrames = {}
        local firstChannel = true

        function Channels:Channel(channelName)
            local channel = {}
            
            -- Channel Content Frame
            local channelFrame = Instance.new("ScrollingFrame")
            channelFrame.Name = channelName .. "Channel"
            channelFrame.Parent = serverFrame
            channelFrame.BackgroundTransparency = 1
            channelFrame.BorderSizePixel = 0
            channelFrame.Size = UDim2.new(1, 0, 1, 0)
            channelFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            channelFrame.ScrollBarThickness = 4
            channelFrame.ScrollBarImageColor3 = Color3.fromRGB(64, 68, 75)
            channelFrame.Visible = firstChannel

            local layout = Instance.new("UIListLayout")
            layout.Parent = channelFrame
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 5)

            local padding = Instance.new("UIPadding")
            padding.Parent = channelFrame
            padding.PaddingLeft = UDim.new(0, 15)
            padding.PaddingTop = UDim.new(0, 15)

            ChannelFrames[channelName] = {frame = channelFrame, first = firstChannel}
            if firstChannel then firstChannel = false end

            -- Button Function
            function channel:Button(text, callback)
                local button = Instance.new("TextButton")
                button.Name = text .. "Button"
                button.Parent = channelFrame
                button.BackgroundColor3 = Color3.fromRGB(114, 137, 228)
                button.BorderSizePixel = 0
                button.Size = UDim2.new(0, 401, 0, 30)
                button.Font = Enum.Font.Gotham
                button.Text = text
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                button.AutoButtonColor = false
                CreateCorner(button, 4)

                -- Hover effects
                button.MouseEnter:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(103, 123, 196)}):Play()
                end)

                button.MouseLeave:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(114, 137, 228)}):Play()
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

            -- Toggle Function
            function channel:Toggle(text, defaultValue, callback)
                local toggle = {}
                local toggled = defaultValue or false
                
                local toggleFrame = Instance.new("TextButton")
                toggleFrame.Name = text .. "Toggle"
                toggleFrame.Parent = channelFrame
                toggleFrame.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
                toggleFrame.BorderSizePixel = 0
                toggleFrame.Size = UDim2.new(0, 401, 0, 30)
                toggleFrame.Text = ""
                toggleFrame.AutoButtonColor = false

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Parent = toggleFrame
                label.BackgroundTransparency = 1
                label.Position = UDim2.new(0, 5, 0, 0)
                label.Size = UDim2.new(0, 200, 1, 0)
                label.Font = Enum.Font.Gotham
                label.Text = text
                label.TextColor3 = Color3.fromRGB(127, 131, 137)
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left

                local toggleOuter = Instance.new("Frame")
                toggleOuter.Name = "ToggleOuter"
                toggleOuter.Parent = toggleFrame
                toggleOuter.AnchorPoint = Vector2.new(1, 0.5)
                toggleOuter.BackgroundColor3 = toggled and Color3.fromRGB(67, 181, 129) or Color3.fromRGB(114, 118, 125)
                toggleOuter.BorderSizePixel = 0
                toggleOuter.Position = UDim2.new(1, -15, 0.5, 0)
                toggleOuter.Size = UDim2.new(0, 40, 0, 21)
                CreateCorner(toggleOuter, 10)

                local toggleInner = Instance.new("Frame")
                toggleInner.Name = "ToggleInner"
                toggleInner.Parent = toggleOuter
                toggleInner.AnchorPoint = Vector2.new(0.5, 0.5)
                toggleInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleInner.BorderSizePixel = 0
                toggleInner.Position = toggled and UDim2.new(0.75, 0, 0.5, 0) or UDim2.new(0.25, 0, 0.5, 0)
                toggleInner.Size = UDim2.new(0, 15, 0, 15)
                CreateCorner(toggleInner, 7)

                local icon = Instance.new("ImageLabel")
                icon.Name = "Icon"
                icon.Parent = toggleInner
                icon.AnchorPoint = Vector2.new(0.5, 0.5)
                icon.BackgroundTransparency = 1
                icon.Position = UDim2.new(0.5, 0, 0.5, 0)
                icon.Size = UDim2.new(0, 13, 0, 13)
                icon.Image = toggled and "http://www.roblox.com/asset/?id=6023426926" or "http://www.roblox.com/asset/?id=6035047409"
                icon.ImageColor3 = toggled and Color3.fromRGB(67, 181, 129) or Color3.fromRGB(114, 118, 125)

                toggleFrame.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    if toggled then
                        TweenService:Create(toggleOuter, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(67, 181, 129)}):Play()
                        TweenService:Create(toggleInner, TweenInfo.new(0.2), {Position = UDim2.new(0.75, 0, 0.5, 0)}):Play()
                        TweenService:Create(icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(67, 181, 129)}):Play()
                        icon.Image = "http://www.roblox.com/asset/?id=6023426926"
                    else
                        TweenService:Create(toggleOuter, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(114, 118, 125)}):Play()
                        TweenService:Create(toggleInner, TweenInfo.new(0.2), {Position = UDim2.new(0.25, 0, 0.5, 0)}):Play()
                        TweenService:Create(icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(114, 118, 125)}):Play()
                        icon.Image = "http://www.roblox.com/asset/?id=6035047409"
                    end
                    
                    if callback then
                        pcall(callback, toggled)
                    end
                end)

                function toggle:Change(state)
                    toggled = state
                    if toggled then
                        toggleOuter.BackgroundColor3 = Color3.fromRGB(67, 181, 129)
                        toggleInner.Position = UDim2.new(0.75, 0, 0.5, 0)
                        icon.ImageColor3 = Color3.fromRGB(67, 181, 129)
                        icon.Image = "http://www.roblox.com/asset/?id=6023426926"
                    else
                        toggleOuter.BackgroundColor3 = Color3.fromRGB(114, 118, 125)
                        toggleInner.Position = UDim2.new(0.25, 0, 0.5, 0)
                        icon.ImageColor3 = Color3.fromRGB(114, 118, 125)
                        icon.Image = "http://www.roblox.com/asset/?id=6035047409"
                    end
                end

                channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
                
                return toggle
            end

            -- Slider Function
            function channel:Slider(text, min, max, defaultValue, callback)
                local slider = {}
                local value = defaultValue or min
                
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = text .. "Slider"
                sliderFrame.Parent = channelFrame
                sliderFrame.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
                sliderFrame.BorderSizePixel = 0
                sliderFrame.Size = UDim2.new(0, 401, 0, 38)

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Parent = sliderFrame
                label.BackgroundTransparency = 1
                label.Position = UDim2.new(0, 5, 0, -4)
                label.Size = UDim2.new(0, 200, 0, 27)
                label.Font = Enum.Font.Gotham
                label.Text = text
                label.TextColor3 = Color3.fromRGB(127, 131, 137)
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left

                local track = Instance.new("Frame")
                track.Name = "Track"
                track.Parent = sliderFrame
                track.BackgroundColor3 = Color3.fromRGB(79, 84, 92)
                track.BorderSizePixel = 0
                track.Position = UDim2.new(0.5, -192.5, 1, -15)
                track.Size = UDim2.new(0, 385, 0, 8)
                CreateCorner(track, 4)

                local fill = Instance.new("Frame")
                fill.Name = "Fill"
                fill.Parent = track
                fill.BackgroundColor3 = Color3.fromRGB(114, 137, 228)
                fill.BorderSizePixel = 0
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                CreateCorner(fill, 4)

                local knob = Instance.new("TextButton")
                knob.Name = "Knob"
                knob.Parent = track
                knob.AnchorPoint = Vector2.new(0.5, 0.5)
                knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                knob.BorderSizePixel = 0
                knob.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
                knob.Size = UDim2.new(0, 10, 0, 18)
                knob.Text = ""
                knob.AutoButtonColor = false
                CreateCorner(knob, 3)

                local valueBubble = Instance.new("Frame")
                valueBubble.Name = "ValueBubble"
                valueBubble.Parent = knob
                valueBubble.AnchorPoint = Vector2.new(0.5, 0.5)
                valueBubble.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
                valueBubble.Position = UDim2.new(0.5, 0, -1, 0)
                valueBubble.Size = UDim2.new(0, 36, 0, 21)
                valueBubble.Visible = false
                CreateCorner(valueBubble, 3)

                local valueLabel = Instance.new("TextLabel")
                valueLabel.Name = "ValueLabel"
                valueLabel.Parent = valueBubble
                valueLabel.BackgroundTransparency = 1
                valueLabel.Size = UDim2.new(1, 0, 1, 0)
                valueLabel.Font = Enum.Font.Gotham
                valueLabel.Text = tostring(value)
                valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                valueLabel.TextSize = 10

                local dragging = false

                local function updateValue(input)
                    local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                    relativeX = math.clamp(relativeX, 0, 1)
                    value = math.floor(min + (max - min) * relativeX)
                    
                    valueLabel.Text = tostring(value)
                    fill.Size = UDim2.new(relativeX, 0, 1, 0)
                    knob.Position = UDim2.new(relativeX, 0, 0.5, 0)
                    
                    if callback then
                        pcall(callback, value)
                    end
                end

                knob.MouseEnter:Connect(function()
                    if not dragging then
                        valueBubble.Visible = true
                    end
                end)

                knob.MouseLeave:Connect(function()
                    if not dragging then
                        valueBubble.Visible = false
                    end
                end)

                knob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        valueBubble.Visible = true
                    end
                end)

                knob.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        valueBubble.Visible = false
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

                function slider:Change(newValue)
                    value = math.clamp(newValue, min, max)
                    local relativeX = (value - min) / (max - min)
                    
                    valueLabel.Text = tostring(value)
                    fill.Size = UDim2.new(relativeX, 0, 1, 0)
                    knob.Position = UDim2.new(relativeX, 0, 0.5, 0)
                end

                channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
                
                return slider
            end

            -- Separator Function
            function channel:Seperator()
                local separator = Instance.new("Frame")
                separator.Name = "Separator"
                separator.Parent = channelFrame
                separator.BackgroundColor3 = Color3.fromRGB(66, 69, 74)
                separator.BorderSizePixel = 0
                separator.Size = UDim2.new(0, 401, 0, 1)
                separator.Position = UDim2.new(0, 0, 0, 0)

                channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            end

            -- Dropdown Function
            function channel:Dropdown(text, options, callback)
                local dropdown = {}
                local selected = options[1] or "..."
                local open = false
                
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = text .. "Dropdown"
                dropdownFrame.Parent = channelFrame
                dropdownFrame.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
                dropdownFrame.BorderSizePixel = 0
                dropdownFrame.Size = UDim2.new(0, 403, 0, 73)
                dropdownFrame.ClipsDescendants = true

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Parent = dropdownFrame
                label.BackgroundTransparency = 1
                label.Position = UDim2.new(0, 5, 0, 0)
                label.Size = UDim2.new(0, 200, 0, 29)
                label.Font = Enum.Font.Gotham
                label.Text = text
                label.TextColor3 = Color3.fromRGB(127, 131, 137)
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left

                local outline = Instance.new("Frame")
                outline.Name = "Outline"
                outline.Parent = dropdownFrame
                outline.BackgroundColor3 = Color3.fromRGB(37, 40, 43)
                outline.BorderSizePixel = 0
                outline.Position = UDim2.new(0, 0, 1, -36)
                outline.Size = UDim2.new(0, 396, 0, 36)
                CreateCorner(outline, 3)

                local inner = Instance.new("Frame")
                inner.Name = "Inner"
                inner.Parent = outline
                inner.BackgroundColor3 = Color3.fromRGB(48, 51, 57)
                inner.BorderSizePixel = 0
                inner.Position = UDim2.new(0.01, 0, 0.056, 0)
                inner.Size = UDim2.new(0, 392, 0, 32)
                CreateCorner(inner, 3)

                local current = Instance.new("TextLabel")
                current.Name = "Current"
                current.Parent = inner
                current.BackgroundTransparency = 1
                current.Position = UDim2.new(0.018, 0, 0, 0)
                current.Size = UDim2.new(0, 193, 1, 0)
                current.Font = Enum.Font.Gotham
                current.Text = selected
                current.TextColor3 = Color3.fromRGB(212, 212, 212)
                current.TextSize = 14
                current.TextXAlignment = Enum.TextXAlignment.Left

                local arrow = Instance.new("ImageLabel")
                arrow.Name = "Arrow"
                arrow.Parent = inner
                arrow.AnchorPoint = Vector2.new(1, 0.5)
                arrow.BackgroundTransparency = 1
                arrow.Position = UDim2.new(1, -10, 0.5, 0)
                arrow.Size = UDim2.new(0, 22, 0, 22)
                arrow.Image = "http://www.roblox.com/asset/?id=6034818372"
                arrow.ImageColor3 = Color3.fromRGB(212, 212, 212)

                local optionsFrame = Instance.new("Frame")
                optionsFrame.Name = "Options"
                optionsFrame.Parent = dropdownFrame
                optionsFrame.BackgroundColor3 = Color3.fromRGB(37, 40, 43)
                optionsFrame.BorderSizePixel = 0
                optionsFrame.Position = UDim2.new(0, 0, 1, 0)
                optionsFrame.Size = UDim2.new(0, 396, 0, 0)
                optionsFrame.Visible = false
                CreateCorner(optionsFrame, 3)

                local optionsInner = Instance.new("Frame")
                optionsInner.Name = "OptionsInner"
                optionsInner.Parent = optionsFrame
                optionsInner.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
                optionsInner.BorderSizePixel = 0
                optionsInner.Position = UDim2.new(0.01, 0, 0.028, 0)
                optionsInner.Size = UDim2.new(0, 392, 0, 0)
                optionsInner.ClipsDescendants = true
                CreateCorner(optionsInner, 3)

                local optionsLayout = Instance.new("UIListLayout")
                optionsLayout.Parent = optionsInner
                optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder

                local toggleBtn = Instance.new("TextButton")
                toggleBtn.Name = "ToggleBtn"
                toggleBtn.Parent = inner
                toggleBtn.BackgroundTransparency = 1
                toggleBtn.Size = UDim2.new(1, 0, 1, 0)
                toggleBtn.Text = ""
                toggleBtn.AutoButtonColor = false

                -- Create option buttons
                for i, option in ipairs(options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = option
                    optionButton.Parent = optionsInner
                    optionButton.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
                    optionButton.BorderSizePixel = 0
                    optionButton.Size = UDim2.new(1, 0, 0, 32)
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.Text = option
                    optionButton.TextColor3 = Color3.fromRGB(212, 212, 212)
                    optionButton.TextSize = 14
                    optionButton.AutoButtonColor = false

                    optionButton.MouseEnter:Connect(function()
                        optionButton.BackgroundColor3 = Color3.fromRGB(57, 60, 67)
                    end)

                    optionButton.MouseLeave:Connect(function()
                        optionButton.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
                    end)

                    optionButton.MouseButton1Click:Connect(function()
                        selected = option
                        current.Text = selected
                        dropdownFrame.Size = UDim2.new(0, 403, 0, 73)
                        optionsFrame.Visible = false
                        open = false
                        
                        if callback then
                            pcall(callback, selected)
                        end
                    end)
                end

                toggleBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        local optionCount = #options
                        local newHeight = math.min(optionCount * 32 + 10, 150)
                        dropdownFrame.Size = UDim2.new(0, 403, 0, 73 + newHeight)
                        optionsFrame.Size = UDim2.new(0, 396, 0, newHeight)
                        optionsInner.Size = UDim2.new(0, 392, 0, optionCount * 32)
                        optionsFrame.Visible = true
                        TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
                    else
                        dropdownFrame.Size = UDim2.new(0, 403, 0, 73)
                        optionsFrame.Visible = false
                        TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                    end
                end)

                function dropdown:Clear()
                    for i, child in ipairs(optionsInner:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    selected = "..."
                    current.Text = selected
                    dropdownFrame.Size = UDim2.new(0, 403, 0, 73)
                    optionsFrame.Visible = false
                    open = false
                end

                function dropdown:Add(option)
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = option
                    optionButton.Parent = optionsInner
                    optionButton.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
                    optionButton.BorderSizePixel = 0
                    optionButton.Size = UDim2.new(1, 0, 0, 32)
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.Text = option
                    optionButton.TextColor3 = Color3.fromRGB(212, 212, 212)
                    optionButton.TextSize = 14
                    optionButton.AutoButtonColor = false

                    optionButton.MouseEnter:Connect(function()
                        optionButton.BackgroundColor3 = Color3.fromRGB(57, 60, 67)
                    end)

                    optionButton.MouseLeave:Connect(function()
                        optionButton.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
                    end)

                    optionButton.MouseButton1Click:Connect(function()
                        selected = option
                        current.Text = selected
                        dropdownFrame.Size = UDim2.new(0, 403, 0, 73)
                        optionsFrame.Visible = false
                        open = false
                        
                        if callback then
                            pcall(callback, selected)
                        end
                    end)

                    optionsInner.Size = UDim2.new(0, 392, 0, #optionsInner:GetChildren() * 32)
                end

                channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
                
                return dropdown
            end

            -- Colorpicker Function
            function channel:Colorpicker(text, defaultColor, callback)
                local colorpicker = Instance.new("Frame")
                colorpicker.Name = text .. "Colorpicker"
                colorpicker.Parent = channelFrame
                colorpicker.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
                colorpicker.BorderSizePixel = 0
                colorpicker.Size = UDim2.new(0, 401, 0, 30)

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Parent = colorpicker
                label.BackgroundTransparency = 1
                label.Position = UDim2.new(0, 5, 0, 0)
                label.Size = UDim2.new(0, 200, 1, 0)
                label.Font = Enum.Font.Gotham
                label.Text = text
                label.TextColor3 = Color3.fromRGB(127, 131, 137)
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left

                local colorBox = Instance.new("TextButton")
                colorBox.Name = "ColorBox"
                colorBox.Parent = colorpicker
                colorBox.AnchorPoint = Vector2.new(1, 0.5)
                colorBox.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255)
                colorBox.BorderSizePixel = 0
                colorBox.Position = UDim2.new(1, -15, 0.5, 0)
                colorBox.Size = UDim2.new(0, 25, 0, 25)
                colorBox.Text = ""
                colorBox.AutoButtonColor = false
                CreateCorner(colorBox, 4)

                colorBox.MouseButton1Click:Connect(function()
                    -- Simple color picker implementation
                    if callback then
                        pcall(callback, colorBox.BackgroundColor3)
                    end
                end)

                channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            end

            -- Textbox Function
            function channel:Textbox(text, placeholder, clearOnFocus, callback)
                local textboxFrame = Instance.new("Frame")
                textboxFrame.Name = text .. "Textbox"
                textboxFrame.Parent = channelFrame
                textboxFrame.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
                textboxFrame.BorderSizePixel = 0
                textboxFrame.Size = UDim2.new(0, 403, 0, 73)

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Parent = textboxFrame
                label.BackgroundTransparency = 1
                label.Position = UDim2.new(0, 5, 0, 0)
                label.Size = UDim2.new(0, 200, 0, 29)
                label.Font = Enum.Font.Gotham
                label.Text = text
                label.TextColor3 = Color3.fromRGB(127, 131, 137)
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left

                local outline = Instance.new("Frame")
                outline.Name = "Outline"
                outline.Parent = textboxFrame
                outline.BackgroundColor3 = Color3.fromRGB(37, 40, 43)
                outline.BorderSizePixel = 0
                outline.Position = UDim2.new(0, 0, 1, -36)
                outline.Size = UDim2.new(0, 396, 0, 36)
                CreateCorner(outline, 3)

                local inner = Instance.new("Frame")
                inner.Name = "Inner"
                inner.Parent = outline
                inner.BackgroundColor3 = Color3.fromRGB(48, 51, 57)
                inner.BorderSizePixel = 0
                inner.Position = UDim2.new(0.01, 0, 0.056, 0)
                inner.Size = UDim2.new(0, 392, 0, 32)
                CreateCorner(inner, 3)

                local textBox = Instance.new("TextBox")
                textBox.Name = "TextBox"
                textBox.Parent = inner
                textBox.BackgroundTransparency = 1
                textBox.Position = UDim2.new(0.018, 0, 0, 0)
                textBox.Size = UDim2.new(0, 377, 1, 0)
                textBox.Font = Enum.Font.Gotham
                textBox.PlaceholderText = placeholder or "Type here..."
                textBox.PlaceholderColor3 = Color3.fromRGB(91, 95, 101)
                textBox.Text = ""
                textBox.TextColor3 = Color3.fromRGB(193, 195, 197)
                textBox.TextSize = 14
                textBox.TextXAlignment = Enum.TextXAlignment.Left

                textBox.Focused:Connect(function()
                    TweenService:Create(outline, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(114, 137, 228)}):Play()
                    if clearOnFocus then
                        textBox.Text = ""
                    end
                end)

                textBox.FocusLost:Connect(function(enterPressed)
                    TweenService:Create(outline, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(37, 40, 43)}):Play()
                    if enterPressed and callback then
                        pcall(callback, textBox.Text)
                    end
                end)

                channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            end

            -- Label Function
            function channel:Label(text)
                local labelFrame = Instance.new("TextButton")
                labelFrame.Name = text .. "Label"
                labelFrame.Parent = channelFrame
                labelFrame.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
                labelFrame.BorderSizePixel = 0
                labelFrame.Size = UDim2.new(0, 401, 0, 30)
                labelFrame.Text = ""
                labelFrame.AutoButtonColor = false

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Parent = labelFrame
                label.BackgroundTransparency = 1
                label.Position = UDim2.new(0, 5, 0, 0)
                label.Size = UDim2.new(0, 200, 1, 0)
                label.Font = Enum.Font.Gotham
                label.Text = text
                label.TextColor3 = Color3.fromRGB(127, 131, 137)
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left

                channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            end

            -- Bind Function
            function channel:Bind(text, defaultKey, callback)
                local key = defaultKey.Name
                local bindFrame = Instance.new("TextButton")
                bindFrame.Name = text .. "Bind"
                bindFrame.Parent = channelFrame
                bindFrame.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
                bindFrame.BorderSizePixel = 0
                bindFrame.Size = UDim2.new(0, 401, 0, 30)
                bindFrame.Text = ""
                bindFrame.AutoButtonColor = false

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Parent = bindFrame
                label.BackgroundTransparency = 1
                label.Position = UDim2.new(0, 5, 0, 0)
                label.Size = UDim2.new(0, 200, 1, 0)
                label.Font = Enum.Font.Gotham
                label.Text = text
                label.TextColor3 = Color3.fromRGB(127, 131, 137)
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left

                local keyLabel = Instance.new("TextLabel")
                keyLabel.Name = "KeyLabel"
                keyLabel.Parent = bindFrame
                keyLabel.AnchorPoint = Vector2.new(1, 0)
                keyLabel.BackgroundTransparency = 1
                keyLabel.Position = UDim2.new(1, -15, 0, 0)
                keyLabel.Size = UDim2.new(0, 85, 1, 0)
                keyLabel.Font = Enum.Font.Gotham
                keyLabel.Text = key
                keyLabel.TextColor3 = Color3.fromRGB(127, 131, 137)
                keyLabel.TextSize = 14
                keyLabel.TextXAlignment = Enum.TextXAlignment.Right

                bindFrame.MouseButton1Click:Connect(function()
                    keyLabel.Text = "..."
                    local inputWait = UserInputService.InputBegan:Wait()
                    if inputWait.KeyCode.Name ~= "Unknown" then
                        key = inputWait.KeyCode.Name
                        keyLabel.Text = key
                    end
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.KeyCode.Name == key then
                        if callback then
                            pcall(callback)
                        end
                    end
                end)

                channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            end

            channelFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            return channel
        end

        -- Server button interactions
        serverButton.MouseButton1Click:Connect(function()
            -- Hide all server frames
            for _, frame in pairs(ServerFrames) do
                frame.Visible = false
            end
            
            -- Reset all server buttons
            for _, btn in ipairs(ServerList:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
                end
            end
            
            -- Show this server
            serverFrame.Visible = true
            serverButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        end)

        -- Update server list size
        ServerList.CanvasSize = UDim2.new(0, 0, 0, #ServerList:GetChildren() * 54)

        if firstServer then
            firstServer = false
            serverButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        end

        return Channels
    end

    -- Notification System (compatible with original)
    function DiscordLib:Notification(title, message, buttonText)
        local notification = Instance.new("Frame")
        notification.Name = "Notification"
        notification.Parent = MainFrame
        notification.AnchorPoint = Vector2.new(0.5, 0.5)
        notification.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
        notification.BorderSizePixel = 0
        notification.Position = UDim2.new(0.5, 0, 0.5, 0)
        notification.Size = UDim2.new(0, 346, 0, 0)
        notification.ClipsDescendants = true
        CreateCorner(notification, 5)

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Parent = notification
        titleLabel.BackgroundTransparency = 1
        titleLabel.Position = UDim2.new(0, 0, 0, 0)
        titleLabel.Size = UDim2.new(1, 0, 0, 68)
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = 20

        local messageLabel = Instance.new("TextLabel")
        messageLabel.Name = "Message"
        messageLabel.Parent = notification
        messageLabel.BackgroundTransparency = 1
        messageLabel.Position = UDim2.new(0.106, 0, 0.318, 0)
        messageLabel.Size = UDim2.new(0, 272, 0, 63)
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.Text = message
        messageLabel.TextColor3 = Color3.fromRGB(171, 172, 176)
        messageLabel.TextSize = 14
        messageLabel.TextWrapped = true

        local button = Instance.new("TextButton")
        button.Name = "Button"
        button.Parent = notification
        button.BackgroundColor3 = Color3.fromRGB(114, 137, 228)
        button.BorderSizePixel = 0
        button.Position = UDim2.new(0.033, 0, 0.789, 0)
        button.Size = UDim2.new(0, 322, 0, 27)
        button.Font = Enum.Font.Gotham
        button.Text = buttonText or "Okay"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 13
        button.AutoButtonColor = false
        CreateCorner(button, 4)

        -- Animate in
        notification:TweenSize(UDim2.new(0, 346, 0, 176), "Out", "Quart", 0.3)

        button.MouseButton1Click:Connect(function()
            notification:TweenSize(UDim2.new(0, 346, 0, 0), "Out", "Quart", 0.3)
            wait(0.3)
            notification:Destroy()
        end)

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(103, 123, 196)}):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(114, 137, 228)}):Play()
        end)
    end

    return Servers
end

-- Initialize the library
LoadUserData()

return DiscordLib
