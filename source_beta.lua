--[[
Improved ArrayField Interface Suite
Enhanced version with better performance and organization
]]

local ArrayField = {
    Flags = {},
    Theme = {
        Default = {
            TextFont = "Default",
            TextColor = Color3.fromRGB(240, 240, 240),
            Background = Color3.fromRGB(25, 25, 25),
            Topbar = Color3.fromRGB(34, 34, 34),
            Shadow = Color3.fromRGB(20, 20, 20),
            NotificationBackground = Color3.fromRGB(20, 20, 20),
            NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
            TabBackground = Color3.fromRGB(80, 80, 80),
            TabStroke = Color3.fromRGB(85, 85, 85),
            TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
            TabTextColor = Color3.fromRGB(240, 240, 240),
            SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
            ElementBackground = Color3.fromRGB(35, 35, 35),
            ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
            SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
            ElementStroke = Color3.fromRGB(50, 50, 50),
            SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
            SliderBackground = Color3.fromRGB(43, 105, 159),
            SliderProgress = Color3.fromRGB(43, 105, 159),
            SliderStroke = Color3.fromRGB(48, 119, 177),
            ToggleBackground = Color3.fromRGB(30, 30, 30),
            ToggleEnabled = Color3.fromRGB(0, 146, 214),
            ToggleDisabled = Color3.fromRGB(100, 100, 100),
            ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
            ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
            ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
            ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),
            InputBackground = Color3.fromRGB(30, 30, 30),
            InputStroke = Color3.fromRGB(65, 65, 65),
            PlaceholderColor = Color3.fromRGB(178, 178, 178)
        }
    },
    Config = {
        Release = "Release 1C",
        NotificationDuration = 6.5,
        Folder = "ArrayField",
        ConfigurationFolder = "ArrayField/Configurations",
        ConfigurationExtension = ".afld"
    }
}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer

-- Cache frequently used functions
local spawn = task.spawn
local delay = task.delay
local wait = task.wait

-- Load main UI
local MainUI = game:GetObjects("rbxassetid://11637506633")[1]
MainUI.Enabled = false

-- Parent the UI safely
local function ParentUI(Gui)
    local success, result = pcall(function()
        if (syn and syn.protect_gui) then
            syn.protect_gui(Gui)
            Gui.Parent = CoreGui
        elseif gethui then
            Gui.Parent = gethui()
        else
            Gui.Parent = CoreGui
        end
    end)
    
    if not success then
        Gui.Parent = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
    end
end

ParentUI(MainUI)

-- Cache UI elements
local Main = MainUI.Main
local Topbar = Main.Topbar
local Elements = Main.Elements
local TabsList = Main.TabList
local Notifications = MainUI.Notifications

-- State management
local State = {
    Minimized = false,
    Hidden = false,
    Debounce = false,
    CurrentTheme = ArrayField.Theme.Default,
    ConfigurationEnabled = false,
    ConfigurationFileName = nil
}

-- Utility functions
local function CreateTween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quint, easingDirection or Enum.EasingDirection.Out)
    return TweenService:Create(object, tweenInfo, properties)
end

local function SafeCallback(callback, elementName, onError)
    local success, result = pcall(callback)
    if not success then
        if onError then
            onError(result)
        else
            warn("ArrayField | " .. elementName .. " Callback Error: " .. tostring(result))
        end
        return false
    end
    return true
end

-- Improved notification system
function ArrayField:Notify(notificationSettings)
    spawn(function()
        local notification = Notifications.Template:Clone()
        notification.Parent = Notifications
        notification.Name = notificationSettings.Title or "Notification"
        notification.Visible = true

        -- Setup notification
        notification.BackgroundColor3 = State.CurrentTheme.NotificationBackground
        notification.Title.Text = notificationSettings.Title or "Notification"
        notification.Description.Text = notificationSettings.Content or ""
        notification.Icon.Image = notificationSettings.Image and "rbxassetid://" .. tostring(notificationSettings.Image) or "rbxassetid://3944680095"

        -- Animation
        notification.Size = UDim2.new(0, 260, 0, 80)
        notification.BackgroundTransparency = 1

        local showTween = CreateTween(notification, {Size = UDim2.new(0, 295, 0, 91), BackgroundTransparency = 0.1}, 0.7)
        showTween:Play()

        notification:TweenPosition(UDim2.new(0.5, 0, 0.915, 0), 'Out', 'Quint', 0.8, true)

        wait(0.3)
        
        -- Fade in content
        CreateTween(notification.Icon, {ImageTransparency = 0}, 0.6):Play()
        CreateTween(notification.Title, {TextTransparency = 0}, 0.7):Play()
        CreateTween(notification.Description, {TextTransparency = 0.2}, 0.6):Play()

        -- Wait for duration
        wait(notificationSettings.Duration or ArrayField.Config.NotificationDuration)

        -- Fade out
        CreateTween(notification, {Size = UDim2.new(0, 280, 0, 83), BackgroundTransparency = 0.6}, 0.6):Play()
        CreateTween(notification.Icon, {ImageTransparency = 1}, 0.4):Play()
        
        wait(0.3)
        
        CreateTween(notification.Title, {TextTransparency = 0.4}, 0.6):Play()
        CreateTween(notification.Description, {TextTransparency = 0.5}, 0.6):Play()
        
        wait(0.4)
        
        CreateTween(notification, {Size = UDim2.new(0, 260, 0, 0), BackgroundTransparency = 1}, 0.9):Play()
        CreateTween(notification.Title, {TextTransparency = 1}, 0.6):Play()
        CreateTween(notification.Description, {TextTransparency = 1}, 0.6):Play()
        
        wait(0.9)
        notification:Destroy()
    end)
end

-- Improved window creation
function ArrayField:CreateWindow(settings)
    -- Validate settings
    settings = settings or {}
    settings.Name = settings.Name or "ArrayField Interface"
    settings.ConfigurationSaving = settings.ConfigurationSaving or {}
    settings.ConfigurationSaving.Enabled = settings.ConfigurationSaving.Enabled or false
    settings.ConfigurationSaving.FileName = settings.ConfigurationSaving.FileName or tostring(game.PlaceId)

    -- Setup configuration
    State.ConfigurationEnabled = settings.ConfigurationSaving.Enabled
    State.ConfigurationFileName = settings.ConfigurationSaving.FileName

    -- Initialize UI
    Topbar.Title.Text = settings.Name
    Main.Visible = true
    
    -- Add dragging functionality
    local dragging, dragInput, mousePos, framePos = false
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            CreateTween(Main, {
                Position = UDim2.new(
                    framePos.X.Scale, framePos.X.Offset + delta.X,
                    framePos.Y.Scale, framePos.Y.Offset + delta.Y
                )
            }, 0.45):Play()
        end
    end)

    -- Window methods
    local window = {
        Tabs = {}
    }

    function window:CreateTab(name, icon)
        local tab = {
            Name = name,
            Elements = {}
        }

        -- Create tab button and page
        local tabButton = TabsList.Template:Clone()
        local tabPage = Elements.Template:Clone()

        tabButton.Name = name
        tabButton.Title.Text = name
        tabButton.Parent = TabsList
        tabButton.Visible = true

        tabPage.Name = name
        tabPage.Visible = true
        tabPage.Parent = Elements

        if icon then
            tabButton.Image.Image = "rbxassetid://" .. icon
            tabButton.Image.Visible = true
            tabButton.Title.Position = UDim2.new(0, 37, 0.5, 0)
            tabButton.Title.TextXAlignment = Enum.TextXAlignment.Left
        end

        -- Tab methods
        function tab:CreateButton(buttonSettings)
            local button = Elements.Template.Button:Clone()
            button.Name = buttonSettings.Name
            button.Title.Text = buttonSettings.Name
            button.Visible = true
            button.Parent = tabPage

            local buttonValue = {
                Locked = false,
                Element = button
            }

            button.Interact.MouseButton1Click:Connect(function()
                if buttonValue.Locked then return end
                
                SafeCallback(function()
                    buttonSettings.Callback()
                end, buttonSettings.Name, function(err)
                    -- Visual error feedback
                    CreateTween(button, {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}, 0.6):Play()
                    button.Title.Text = "Callback Error"
                    delay(0.5, function()
                        button.Title.Text = buttonSettings.Name
                        CreateTween(button, {BackgroundColor3 = State.CurrentTheme.ElementBackground}, 0.6):Play()
                    end)
                end)
            end)

            function buttonValue:Set(newText)
                button.Title.Text = newText
                button.Name = newText
            end

            function buttonValue:Lock(reason)
                buttonValue.Locked = true
                -- Implement lock visual
            end

            function buttonValue:Unlock()
                buttonValue.Locked = false
                -- Implement unlock visual
            end

            return buttonValue
        end

        function tab:CreateToggle(toggleSettings)
            local toggle = Elements.Template.Toggle:Clone()
            toggle.Name = toggleSettings.Name
            toggle.Title.Text = toggleSettings.Name
            toggle.Visible = true
            toggle.Parent = tabPage

            local toggleValue = {
                CurrentValue = toggleSettings.CurrentValue or false,
                Locked = false,
                Element = toggle
            }

            local function updateToggleVisual()
                if toggleValue.CurrentValue then
                    CreateTween(toggle.Switch.Indicator, {
                        Position = UDim2.new(1, -20, 0.5, 0),
                        BackgroundColor3 = State.CurrentTheme.ToggleEnabled
                    }, 0.3):Play()
                else
                    CreateTween(toggle.Switch.Indicator, {
                        Position = UDim2.new(1, -40, 0.5, 0),
                        BackgroundColor3 = State.CurrentTheme.ToggleDisabled
                    }, 0.3):Play()
                end
            end

            toggle.Interact.MouseButton1Click:Connect(function()
                if toggleValue.Locked then return end
                
                toggleValue.CurrentValue = not toggleValue.CurrentValue
                updateToggleVisual()
                
                SafeCallback(function()
                    toggleSettings.Callback(toggleValue.CurrentValue)
                end, toggleSettings.Name)
            end)

            function toggleValue:Set(value)
                toggleValue.CurrentValue = value
                updateToggleVisual()
                SafeCallback(function()
                    toggleSettings.Callback(value)
                end, toggleSettings.Name)
            end

            -- Initialize
            updateToggleVisual()

            return toggleValue
        end

        function tab:CreateSlider(sliderSettings)
            local slider = Elements.Template.Slider:Clone()
            slider.Name = sliderSettings.Name
            slider.Title.Text = sliderSettings.Name
            slider.Visible = true
            slider.Parent = tabPage

            local sliderValue = {
                CurrentValue = sliderSettings.CurrentValue or sliderSettings.Range[1],
                Locked = false,
                Element = slider
            }

            local function updateSliderVisual()
                local range = sliderSettings.Range[2] - sliderSettings.Range[1]
                local progress = ((sliderValue.CurrentValue - sliderSettings.Range[1]) / range)
                CreateTween(slider.Main.Progress, {
                    Size = UDim2.new(progress, 0, 1, 0)
                }, 0.2):Play()
                
                if sliderSettings.Suffix then
                    slider.Main.Information.Text = tostring(sliderValue.CurrentValue) .. " " .. sliderSettings.Suffix
                else
                    slider.Main.Information.Text = tostring(sliderValue.CurrentValue)
                end
            end

            local dragging = false
            slider.Main.Interact.MouseButton1Down:Connect(function()
                if sliderValue.Locked then return end
                dragging = true
            end)

            slider.Main.Interact.MouseButton1Up:Connect(function()
                dragging = false
            end)

            slider.Main.Interact.MouseMoved:Connect(function()
                if dragging and not sliderValue.Locked then
                    local mousePos = UserInputService:GetMouseLocation()
                    local sliderPos = slider.Main.AbsolutePosition.X
                    local sliderSize = slider.Main.AbsoluteSize.X
                    
                    local relativePos = math.clamp(mousePos.X - sliderPos, 0, sliderSize)
                    local progress = relativePos / sliderSize
                    
                    local value = sliderSettings.Range[1] + (progress * (sliderSettings.Range[2] - sliderSettings.Range[1]))
                    value = math.floor(value / sliderSettings.Increment + 0.5) * sliderSettings.Increment
                    
                    sliderValue.CurrentValue = value
                    updateSliderVisual()
                    
                    SafeCallback(function()
                        sliderSettings.Callback(value)
                    end, sliderSettings.Name)
                end
            end)

            function sliderValue:Set(value)
                sliderValue.CurrentValue = math.clamp(value, sliderSettings.Range[1], sliderSettings.Range[2])
                updateSliderVisual()
                SafeCallback(function()
                    sliderSettings.Callback(sliderValue.CurrentValue)
                end, sliderSettings.Name)
            end

            -- Initialize
            updateSliderVisual()

            return sliderValue
        end

        function tab:CreateDropdown(dropdownSettings)
            local dropdown = Elements.Template.Dropdown:Clone()
            dropdown.Name = dropdownSettings.Name
            dropdown.Title.Text = dropdownSettings.Name
            dropdown.Visible = true
            dropdown.Parent = tabPage

            local dropdownValue = {
                CurrentOption = dropdownSettings.CurrentOption or dropdownSettings.Options[1],
                Options = dropdownSettings.Options or {},
                Locked = false,
                Element = dropdown
            }

            dropdown.Selected.Text = dropdownValue.CurrentOption

            -- Populate dropdown
            for _, option in ipairs(dropdownValue.Options) do
                local optionFrame = Elements.Template.Dropdown.List.Template:Clone()
                optionFrame.Name = option
                optionFrame.Title.Text = option
                optionFrame.Parent = dropdown.List
                optionFrame.Visible = true

                optionFrame.Interact.MouseButton1Click:Connect(function()
                    if dropdownValue.Locked then return end
                    
                    dropdownValue.CurrentOption = option
                    dropdown.Selected.Text = option
                    
                    SafeCallback(function()
                        dropdownSettings.Callback(option)
                    end, dropdownSettings.Name)
                    
                    -- Close dropdown
                    CreateTween(dropdown, {Size = UDim2.new(1, -10, 0, 45)}, 0.5):Play()
                    dropdown.List.Visible = false
                end)
            end

            dropdown.Interact.MouseButton1Click:Connect(function()
                if dropdownValue.Locked then return end
                
                if dropdown.List.Visible then
                    CreateTween(dropdown, {Size = UDim2.new(1, -10, 0, 45)}, 0.5):Play()
                    dropdown.List.Visible = false
                else
                    CreateTween(dropdown, {Size = UDim2.new(1, -10, 0, 180)}, 0.5):Play()
                    dropdown.List.Visible = true
                end
            end)

            function dropdownValue:Set(option)
                if table.find(dropdownValue.Options, option) then
                    dropdownValue.CurrentOption = option
                    dropdown.Selected.Text = option
                    SafeCallback(function()
                        dropdownSettings.Callback(option)
                    end, dropdownSettings.Name)
                end
            end

            return dropdownValue
        end

        window.Tabs[name] = tab
        return tab
    end

    -- Add window controls
    Topbar.ChangeSize.MouseButton1Click:Connect(function()
        if State.Debounce then return end
        State.Debounce = true
        
        if State.Minimized then
            -- Maximize
            CreateTween(Main, {Size = UDim2.new(0, 500, 0, 475)}, 0.5):Play()
            State.Minimized = false
        else
            -- Minimize
            CreateTween(Main, {Size = UDim2.new(0, 495, 0, 45)}, 0.5):Play()
            State.Minimized = true
        end
        
        delay(0.5, function()
            State.Debounce = false
        end)
    end)

    Topbar.Hide.MouseButton1Click:Connect(function()
        if State.Debounce then return end
        State.Debounce = true
        
        if State.Hidden then
            -- Show
            Main.Visible = true
            CreateTween(Main, {Size = UDim2.new(0, 500, 0, 475)}, 0.5):Play()
            State.Hidden = false
        else
            -- Hide
            CreateTween(Main, {Size = UDim2.new(0, 470, 0, 400)}, 0.5):Play()
            delay(0.5, function()
                Main.Visible = false
                State.Hidden = true
            end)
        end
        
        delay(0.5, function()
            State.Debounce = false
        end)
    end)

    -- Hide/show with RightShift
    UserInputService.InputBegan:Connect(function(input, processed)
        if input.KeyCode == Enum.KeyCode.RightShift and not processed then
            if State.Debounce then return end
            
            if State.Hidden then
                Main.Visible = true
                CreateTween(Main, {Size = UDim2.new(0, 500, 0, 475)}, 0.5):Play()
                State.Hidden = false
            else
                CreateTween(Main, {Size = UDim2.new(0, 470, 0, 400)}, 0.5):Play()
                delay(0.5, function()
                    Main.Visible = false
                    State.Hidden = true
                end)
            end
        end
    end)

    return window
end

-- Theme management
function ArrayField:SetTheme(themeName)
    if self.Theme[themeName] then
        State.CurrentTheme = self.Theme[themeName]
        -- Apply theme to all elements (implementation depends on your needs)
        self:Notify({
            Title = "Theme Changed",
            Content = "Theme has been changed to " .. themeName
        })
    end
end

-- Cleanup function
function ArrayField:Destroy()
    if MainUI then
        MainUI:Destroy()
    end
end

return ArrayField
