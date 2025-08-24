local VERSION = "v4.06"
local rainbowvalue = 0
local cam = game:GetService("Workspace").CurrentCamera
local getasset = getsynasset or getcustomasset
local request = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request
local mouse = game:GetService("Players").LocalPlayer:GetMouse()
local api = {
	["Settings"] = {["GUIObject"] = {["Type"] = "Custom", ["GUIKeybind"] = "RightShift", ["Color"] = 0.44}, ["SearchObject"] = {["Type"] = "Custom", ["List"] = {}}},
	["Profiles"] = {
		["default"] = {["Keybind"] = "", ["Selected"] = true}
	},
	["CurrentProfile"] = "default",
	["KeybindCaptured"] = false,
	["PressedKeybindKey"] = "",
 	["ToggleNotifications"] = false,
	["ToggleTooltips"] = false,
	["ObjectsThatCanBeSaved"] = {},
}

local function GetURL(scripturl)
	if shared.VapeDeveloper then
		return readfile("vape/"..scripturl)
	else
		return game:HttpGet("https://raw.githubusercontent.com/0W0Pumpkin/VapeV4ForRoblox/main/"..scripturl, true)
	end
end

local function getprofile()
	for i,v in pairs(api["Profiles"]) do
		if v["Selected"] then
			api["CurrentProfile"] = i
		end
	end
end

coroutine.resume(coroutine.create(function()
	repeat
		for i = 0, 1, 0.01 do
			wait(0.01)
			rainbowvalue = i
		end
	until true == false
end))

local holdingshift = false
local capturedslider = nil
local clickgui = {["Visible"] = true}

local function randomString()
	local randomlength = math.random(10,100)
	local array = {}

	for i = 1, randomlength do
		array[i] = string.char(math.random(32, 126))
	end

	return table.concat(array)
end

api["findObjectInTable"] = function(temp, object)
    for i,v in pairs(temp) do
        if i == object or v == object then
            return true
        end
    end
    return false
end

local function RelativeXY(GuiObject, location)
	local x, y = location.X - GuiObject.AbsolutePosition.X, location.Y - GuiObject.AbsolutePosition.Y
	local x2 = 0
	local xm, ym = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
	x2 = math.clamp(x, 4, xm - 6)
	x = math.clamp(x, 0, xm)
	y = math.clamp(y, 0, ym)
	return x, y, x/xm, y/ym, x2/xm
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not is_sirhurt_closure and syn and syn.protect_gui then
    local gui = Instance.new("ScreenGui")
    gui.Name = randomString()
    gui.DisplayOrder = 999
    syn.protect_gui(gui)
    gui.Parent = game:GetService("CoreGui")
    api["MainGui"] = gui
elseif gethui then
    local gui = Instance.new("ScreenGui")
    gui.Name = randomString()
    gui.DisplayOrder = 999
    gui.Parent = gethui()
    api["MainGui"] = gui
elseif game:GetService("CoreGui"):FindFirstChild('RobloxGui') then
    api["MainGui"] = game:GetService("CoreGui").RobloxGui
end

local function getcustomassetfunc(path)
	if not isfile(path) then
		local req = request({
			Url = "https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/"..path:gsub("vape/assets", "assets"),
			Method = "GET"
		})
		writefile(path, req.Body)
	end
	if not isfile(path) then
		local textlabel = Instance.new("TextLabel")
		textlabel.Size = UDim2.new(1, 0, 0, 36)
		textlabel.Text = "Downloading "..path
		textlabel.BackgroundTransparency = 1
		textlabel.TextStrokeTransparency = 0
		textlabel.TextSize = 30
		textlabel.TextColor3 = Color3.new(1, 1, 1)
		textlabel.Position = UDim2.new(0, 0, 0, -36)
		textlabel.Parent = api["MainGui"]
		repeat wait() until isfile(path)
		textlabel:Remove()
	end
	return getasset(path) 
end

api["UpdateHudEvent"] = Instance.new("BindableEvent")

local clickgui = Instance.new("Frame")
clickgui.Name = "ClickGui"
clickgui.Size = UDim2.new(1, 0, 1, 0)
clickgui.BackgroundTransparency = 1
clickgui.BorderSizePixel = 0
clickgui.BackgroundColor3 = Color3.fromRGB(79, 83, 166)
clickgui.Visible = false
clickgui.Parent = api["MainGui"]
local notificationwindow = Instance.new("Frame")
notificationwindow.BackgroundTransparency = 1
notificationwindow.Active = false
notificationwindow.Size = UDim2.new(1, 0, 1, 0)
notificationwindow.Parent = api["MainGui"]
local hoverbox = Instance.new("TextLabel")
hoverbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
hoverbox.Active = false
hoverbox.Text = "Placeholder"
hoverbox.ZIndex = 5
hoverbox.TextColor3 = Color3.fromRGB(200, 200, 200)
hoverbox.Font = Enum.Font.SourceSans
hoverbox.TextSize = 16
hoverbox.Visible = false
hoverbox.Parent = clickgui
local hoverround = Instance.new("UICorner")
hoverround.CornerRadius = UDim.new(0, 4)
hoverround.Parent = hoverbox
local vertext = Instance.new("TextLabel")
vertext.Name = "Version"
vertext.Size = UDim2.new(0, 45, 0, 20)
vertext.Font = Enum.Font.SourceSans
vertext.TextColor3 = Color3.new(1, 1, 1)
vertext.Active = false
vertext.TextSize = 25
vertext.BackgroundTransparency = 1
vertext.Text = VERSION
vertext.TextXAlignment = Enum.TextXAlignment.Left
vertext.TextYAlignment = Enum.TextYAlignment.Top
vertext.Position = UDim2.new(1, -72, 1, -25)
vertext.Parent = clickgui
local vertext2 = vertext:Clone()
vertext2.Position = UDim2.new(0, 1, 0, 1)
vertext2.TextColor3 = Color3.new(0.42, 0.42, 0.42)
vertext2.ZIndex = 0
vertext2.Parent = vertext
local modal = Instance.new("TextButton")
modal.Size = UDim2.new(0, 0, 0, 0)
modal.BorderSizePixel = 0
modal.Text = ""
modal.Modal = true
modal.Parent = clickgui
local hudgui = Instance.new("Frame")
hudgui.Name = "HudGui"
hudgui.Size = UDim2.new(1, 0, 1, 0)
hudgui.BackgroundTransparency = 1
hudgui.Visible = true
hudgui.Parent = api["MainGui"]
api["MainBlur"] = Instance.new("BlurEffect")
api["MainBlur"].Size = 25
api["MainBlur"].Parent = game:GetService("Lighting")
api["MainBlur"].Enabled = false
api["MainRescale"] = Instance.new("UIScale")
api["MainRescale"].Parent = api["MainGui"]

local function dragGUI(gui, tab)
	spawn(function()
		local dragging
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local function update(input)
			local delta = input.Position - dragStart
			local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (delta.X * (1 / api["MainRescale"].Scale)), startPos.Y.Scale, startPos.Y.Offset + (delta.Y * (1 / api["MainRescale"].Scale)))
			game:GetService("TweenService"):Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
		end
		gui.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch and dragging == false then
					dragging = clickgui.Visible
					dragStart = input.Position
					startPos = gui.Position
					
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
		end)
		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		game:GetService("UserInputService").InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)
end

api["SaveSettings"] = function()
	writefile("vape/Profiles/"..game.PlaceId..".vapeprofiles", game:GetService("HttpService"):JSONEncode(api["Profiles"]))
	for i,v in pairs(api["ObjectsThatCanBeSaved"]) do
		if v["Type"] == "Window" then
			api["Settings"][i] = {["Type"] = "Window", ["Visible"] = v["Object"].Visible, ["Expanded"] = v["ChildrenObject"].Visible, ["Position"] = {v["Object"].Position.X.Scale, v["Object"].Position.X.Offset, v["Object"].Position.Y.Scale, v["Object"].Position.Y.Offset}}
		end
		if v["Type"] == "CustomWindow" then
			api["Settings"][i] = {["Type"] = "CustomWindow", ["Visible"] = v["Object"].Visible, ["Pinned"] = v["Api"]["Pinned"], ["Position"] = {v["Object"].Position.X.Scale, v["Object"].Position.X.Offset, v["Object"].Position.Y.Scale, v["Object"].Position.Y.Offset}}
		end
		if (v["Type"] == "Button" or v["Type"] == "Toggle" or v["Type"] == "ExtrasButton") then
			api["Settings"][i] = {["Type"] = "Button", ["Enabled"] = v["Api"]["Enabled"], ["Keybind"] = v["Api"]["Keybind"]}
		end
		if (v["Type"] == "OptionsButton" or v["Type"] == "ExtrasButton") then
			api["Settings"][i] = {["Type"] = "OptionsButton", ["Enabled"] = v["Api"]["Enabled"], ["Keybind"] = v["Api"]["Keybind"]}
		end
		if v["Type"] == "TextList" then
			api["Settings"][i] = {["Type"] = "TextList", ["ObjectTable"] = v["Api"]["ObjectList"]}
		end
		if v["Type"] == "Dropdown" then
			api["Settings"][i] = {["Type"] = "Dropdown", ["Value"] = v["Api"]["Value"]}
		end
		if v["Type"] == "Slider" then
			api["Settings"][i] = {["Type"] = "Slider", ["Value"] = v["Api"]["Value"]}
		end
		if v["Type"] == "TwoSlider" then
			api["Settings"][i] = {["Type"] = "TwoSlider", ["Value"] = v["Api"]["Value"], ["Value2"] = v["Api"]["Value2"], ["SliderPos1"] = v["Object"].Slider.ButtonSlider.Position.X.Scale, ["SliderPos2"] = v["Object"].Slider.ButtonSlider2.Position.X.Scale}
		end
		if v["Type"] == "ColorSlider" then
			api["Settings"][i] = {["Type"] = "ColorSlider", ["Value"] = v["Api"]["Value"], ["RainbowValue"] = v["Api"]["RainbowValue"]}
		end
	end
	writefile("vape/Profiles/"..(api["CurrentProfile"] == "default" and "" or api["CurrentProfile"])..game.PlaceId..".vapeprofile", game:GetService("HttpService"):JSONEncode(api["Settings"]))
end

api["LoadSettings"] = function()
	local success2, result2 = pcall(function()
		return game:GetService("HttpService"):JSONDecode(readfile("vape/Profiles/"..game.PlaceId..".vapeprofiles"))
	end)
	if success2 and type(result2) == "table" then
		api["Profiles"] = result2
	end
	getprofile()
	local success, result = pcall(function()
		return game:GetService("HttpService"):JSONDecode(readfile("vape/Profiles/"..(api["CurrentProfile"] == "default" and "" or api["CurrentProfile"])..game.PlaceId..".vapeprofile"))
	end)
	if success and type(result) == "table" then
		for i,v in pairs(result) do
			if v["Type"] == "Window" and api["findObjectInTable"](api["ObjectsThatCanBeSaved"], i) then
				api["ObjectsThatCanBeSaved"][i]["Object"].Position = UDim2.new(v["Position"][1], v["Position"][2], v["Position"][3], v["Position"][4])
				api["ObjectsThatCanBeSaved"][i]["Object"].Visible = v["Visible"]
				if v["Expanded"] then
					api["ObjectsThatCanBeSaved"][i]["Api"]["ExpandToggle"]()
				end
			end
			if v["Type"] == "CustomWindow" and api["findObjectInTable"](api["ObjectsThatCanBeSaved"], i) then
				api["ObjectsThatCanBeSaved"][i]["Object"].Position = UDim2.new(v["Position"][1], v["Position"][2], v["Position"][3], v["Position"][4])
				api["ObjectsThatCanBeSaved"][i]["Object"].Visible = v["Visible"]
				if v["Pinned"] then
					api["ObjectsThatCanBeSaved"][i]["Api"]["PinnedToggle"]()
				end
				api["ObjectsThatCanBeSaved"][i]["Api"]["CheckVis"]()
			end
			if v["Type"] == "Custom" and api["findObjectInTable"](api["Settings"], i) then
				api["Settings"][i] = v
			end
			if v["Type"] == "Dropdown" and api["findObjectInTable"](api["ObjectsThatCanBeSaved"], i) then
				api["ObjectsThatCanBeSaved"][i]["Api"]["SetValue"](v["Value"])
			end
			if v["Type"] == "Button" and api["findObjectInTable"](api["ObjectsThatCanBeSaved"], i) then
				if api["ObjectsThatCanBeSaved"][i]["Type"] == "Toggle" then
					api["ObjectsThatCanBeSaved"][i]["Api"]["ToggleButton"](v["Enabled"], true)
					if v["Keybind"] ~= "" then
						api["ObjectsThatCanBeSaved"][i]["Api"]["Keybind"] = v["Keybind"]
					end
				else
					if v["Enabled"] then
						api["ObjectsThatCanBeSaved"][i]["Api"]["ToggleButton"](false)
						if v["Keybind"] ~= "" then
							api["ObjectsThatCanBeSaved"][i]["Api"]["SetKeybind"](v["Keybind"])
						end
					end
				end
			end
			if v["Type"] == "NewToggle" and api["findObjectInTable"](api["ObjectsThatCanBeSaved"], i) then
				api["ObjectsThatCanBeSaved"][i]["Api"]["ToggleButton"](v["Enabled"], true)
				if v["Keybind"] ~= "" then
					api["ObjectsThatCanBeSaved"][i]["Api"]["Keybind"] = v["Keybind"]
				end
			end
			if v["Type"] == "Slider" and api["findObjectInTable"](api["ObjectsThatCanBeSaved"], i) then
				api["ObjectsThatCanBeSaved"][i]["Api"]["SetValue"](v["Value"] < api["ObjectsThatCanBeSaved"][i]["Api"]["Max"] and v["Value"] or api["ObjectsThatCanBeSaved"][i]["Api"]["Max"])
				--api["ObjectsThatCanBeSaved"][i]["Object"].Slider.FillSlider.Size = UDim2.new((v["Value"] < api["ObjectsThatCanBeSaved"][i]["Api"]["Max"] and v["Value"] or api["ObjectsThatCanBeSaved"][i]["Api"]["Max"]) / api["ObjectsThatCanBeSaved"][i]["Api"]["Max"], 0, 1, 0)
			end
			if v["Type"] == "TextList" and api["findObjectInTable"](api["ObjectsThatCanBeSaved"], i) then
				api["ObjectsThatCanBeSaved"][i]["Api"]["RefreshValues"]((v["ObjectTable"] or {}))
			end
			if v["Type"] == "TwoSlider" and api["findObjectInTable"](api["ObjectsThatCanBeSaved"], i) then
				api["ObjectsThatCanBeSaved"][i]["Api"]["SetValue"](v["Value"] == api["ObjectsThatCanBeSaved"][i]["Api"]["Min"] and 0 or v["Value"])
				api["ObjectsThatCanBeSaved"][i]["Api"]["SetValue2"](v["Value2"])
				api["ObjectsThatCanBeSaved"][i]["Object"].Slider.ButtonSlider.Position = UDim2.new(v["SliderPos1"], -8, 1, -9)
				api["ObjectsThatCanBeSaved"][i]["Object"].Slider.ButtonSlider2.Position = UDim2.new(v["SliderPos2"], -8, 1, -9)
				api["ObjectsThatCanBeSaved"][i]["Object"].Slider.FillSlider.Size = UDim2.new(0, api["ObjectsThatCanBeSaved"][i]["Object"].Slider.ButtonSlider2.AbsolutePosition.X - api["ObjectsThatCanBeSaved"][i]["Object"].Slider.ButtonSlider.AbsolutePosition.X, 1, 0)
				api["ObjectsThatCanBeSaved"][i]["Object"].Slider.FillSlider.Position = UDim2.new(v["SliderPos1"], 0, 0, 0)
				--api["ObjectsThatCanBeSaved"][i]["Object"].Slider.FillSlider.Size = UDim2.new((v["Value"] < api["ObjectsThatCanBeSaved"][i]["Api"]["Max"] and v["Value"] or api["ObjectsThatCanBeSaved"][i]["Api"]["Max"]) / api["ObjectsThatCanBeSaved"][i]["Api"]["Max"], 0, 1, 0)
			end
			if v["Type"] == "ColorSlider" and api["findObjectInTable"](api["ObjectsThatCanBeSaved"], i) then
				api["ObjectsThatCanBeSaved"][i]["Api"]["SetValue"](v["Value"])
				api["ObjectsThatCanBeSaved"][i]["Api"]["SetRainbow"](v["RainbowValue"])
				api["ObjectsThatCanBeSaved"][i]["Object"].Slider.ButtonSlider.Position = UDim2.new(math.clamp(v["Value"], 0.02, 0.95), -7, 0, -7)
			end
			if v["Type"] == "OptionsButton" and api["findObjectInTable"](api["ObjectsThatCanBeSaved"], i) then
				if v["Enabled"] then
					api["ObjectsThatCanBeSaved"][i]["Api"]["ToggleButton"](false)
				end
				if v["Keybind"] ~= "" then
					api["ObjectsThatCanBeSaved"][i]["Api"]["SetKeybind"](v["Keybind"])
				end
			end
		end
	end
end

api["SwitchProfile"] = function(profilename)
	api["Profiles"][api["CurrentProfile"]]["Selected"] = false
	api["Profiles"][profilename]["Selected"] = true
	if (not isfile("vape/Profiles/"..(profilename == "default" and "" or profilename)..game.PlaceId..".vapeprofile")) then
		local realprofile = api["CurrentProfile"]
		api["CurrentProfile"] = profilename
		api["SaveSettings"]()
		api["CurrentProfile"] = realprofile
	end
	api["ObjectsThatCanBeSaved"]["SelfDestructOptionsButton"]["Api"]["ToggleButton"](false)
	shared.VapeSwitchServers = true
	shared.VapeOpenGui = (clickgui.Visible)
	loadstring(GetURL("NewMainScript.lua"))()
end

api["RemoveObject"] = function(objname)
	api["ObjectsThatCanBeSaved"][objname]["Object"]:Remove()
	api["ObjectsThatCanBeSaved"][objname] = nil
end

api["CreateMainWindow"] = function()
	local windowapi = {}
	local windowtitle = Instance.new("Frame")
	windowtitle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	windowtitle.Size = UDim2.new(0, 220, 0, 45)
	windowtitle.Position = UDim2.new(0, 6, 0, 6)
	windowtitle.Name = "MainWindow"
	windowtitle.Parent = clickgui
	local windowlogo1 = Instance.new("ImageLabel")
	windowlogo1.Size = UDim2.new(0, 62, 0, 18)
	windowlogo1.Active = false
	windowlogo1.Position = UDim2.new(0, 11, 0, 12)
	windowlogo1.BackgroundTransparency = 1
	windowlogo1.Image = getcustomassetfunc("vape/assets/VapeLogo1.png")
	windowlogo1.Name = "Logo1"
	windowlogo1.Parent = windowtitle
	local windowlogo2 = Instance.new("ImageLabel")
	windowlogo2.Size = UDim2.new(0, 27, 0, 16)
	windowlogo2.Active = false
	windowlogo2.Position = UDim2.new(1, 1, 0, 1)
	windowlogo2.BackgroundTransparency = 1
	windowlogo2.ImageColor3 = Color3.fromHSV(0.44, 1, 1)
	windowlogo2.Image = getcustomassetfunc("vape/assets/VapeLogo2.png")
	windowlogo2.Name = "Logo2"
	windowlogo2.Parent = windowlogo1
	local settingsicon = Instance.new("ImageLabel")
	settingsicon.Name = "SettingsWindowIcon"
	settingsicon.Size = UDim2.new(0, 16, 0, 16)
	settingsicon.Visible = false
	settingsicon.Image = getcustomassetfunc("vape/assets/SettingsWheel2.png")
	settingsicon.BackgroundTransparency = 1
	settingsicon.Position = UDim2.new(0, 10, 0, 13)
	settingsicon.Parent = windowtitle
	local settingstext = Instance.new("TextLabel")
	settingstext.Size = UDim2.new(0, 155, 0, 41)
	settingstext.BackgroundTransparency = 1
	settingstext.Name = "SettingsTitle"
	settingstext.Position = UDim2.new(0, 36, 0, 0)
	settingstext.TextXAlignment = Enum.TextXAlignment.Left
	settingstext.Font = Enum.Font.SourceSans
	settingstext.TextSize = 17
	settingstext.Text = "Settings"
	settingstext.Visible = false
	settingstext.TextColor3 = Color3.fromRGB(201, 201, 201)
	settingstext.Parent = windowtitle
	local settingswheel = Instance.new("ImageButton")
	settingswheel.Name = "SettingsWheel"
	settingswheel.Size = UDim2.new(0, 14, 0, 14)
	settingswheel.Image = getcustomassetfunc("vape/assets/SettingsWheel1.png")
	settingswheel.Position = UDim2.new(1, -25, 0, 14)
	settingswheel.BackgroundTransparency = 1
	settingswheel.Parent = windowtitle
	local discordbutton = settingswheel:Clone()
	discordbutton.Size = UDim2.new(0, 16, 0, 16)
	discordbutton.Image = getcustomassetfunc("vape/assets/DiscordIcon.png")
	discordbutton.Position = UDim2.new(1, -52, 0, 13)
	discordbutton.Parent = windowtitle
	discordbutton.MouseButton1Click:connect(function()
		spawn(function()
			for i = 1, 14 do
				spawn(function()
					local reqbody = {
						["nonce"] = game:GetService("HttpService"):GenerateGUID(false),
						["args"] = {
							["invite"] = {["code"] = "robloxvape"},
							["code"] = "robloxvape",
						},
						["cmd"] = "INVITE_BROWSER"
					}
					local newreq = game:GetService("HttpService"):JSONEncode(reqbody)
					syn.request({
						Headers = {
							["Content-Type"] = "application/json",
							["Origin"] = "https://discord.com"
						},
						Url = "http://127.0.0.1:64"..(53 + i).."/rpc?v=1",
						Method = "POST",
						Body = newreq
					})
				end)
			end
		end)
		spawn(function()
			local hover3textsize = game:GetService("TextService"):GetTextSize("Discord set to clipboard!", 16, Enum.Font.SourceSans, Vector2.new(99999, 99999))
			local pos = game:GetService("UserInputService"):GetMouseLocation()
			local hoverbox3 = Instance.new("TextLabel")
			hoverbox3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			hoverbox3.Active = false
			hoverbox3.Text = "Discord set to clipboard!"
			hoverbox3.ZIndex = 5
			hoverbox3.Size = UDim2.new(0, 13 + hover3textsize.X, 0, hover3textsize.Y + 5)
			hoverbox3.TextColor3 = Color3.fromRGB(200, 200, 200)
			hoverbox3.Position = UDim2.new(0, pos.X + 16, 0, pos.Y - (hoverbox3.Size.Y.Offset / 2) - 26)
			hoverbox3.Font = Enum.Font.SourceSans
			hoverbox3.TextSize = 16
			hoverbox3.Visible = true
			hoverbox3.Parent = clickgui
			local hoverround3 = Instance.new("UICorner")
			hoverround3.CornerRadius = UDim.new(0, 4)
			hoverround3.Parent = hoverbox3
			setclipboard("https://discord.com/invite/robloxvape")
			wait(1)
			hoverbox3:Remove()
		end)
	end)
	local settingsexit = Instance.new("ImageButton")
	settingsexit.Name = "SettingsExit"
	settingsexit.ImageColor3 = Color3.fromRGB(121, 121, 121)
	settingsexit.Size = UDim2.new(0, 24, 0, 24)
	settingsexit.AutoButtonColor = false
	settingsexit.Image = getcustomassetfunc("vape/assets/ExitIcon1.png")
	settingsexit.Visible = false
	settingsexit.Position = UDim2.new(1, -32, 0, 9)
	settingsexit.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	settingsexit.Parent = windowtitle
	local settingsexitround = Instance.new("UICorner")
	settingsexitround.CornerRadius = UDim.new(0, 16)
	settingsexitround.Parent = settingsexit
	settingsexit.MouseEnter:connect(function()
		game:GetService("TweenService"):Create(settingsexit, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(60, 60, 60), ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)
	settingsexit.MouseLeave:connect(function()
		game:GetService("TweenService"):Create(settingsexit, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(20, 20, 20), ImageColor3 = Color3.fromRGB(121, 121, 121)}):Play()
	end)
	local children = Instance.new("Frame")
	children.BackgroundTransparency = 1
	children.Name = "Children"
	children.Size = UDim2.new(1, 0, 1, -4)
	children.Position = UDim2.new(0, 0, 0, 41)
	children.Parent = windowtitle
	local extraframe = Instance.new("Frame")
	extraframe.Size = UDim2.new(0, 220, 0, 40)
	extraframe.BorderSizePixel = 0
	extraframe.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	extraframe.LayoutOrder = 99999
	extraframe.Name = "Extras"
	extraframe.Parent = children
	local overlaysicons = Instance.new("Frame")
	overlaysicons.Size = UDim2.new(0, 145, 0, 18)
	overlaysicons.Position = UDim2.new(0, 33, 0, 11)
	overlaysicons.BackgroundTransparency = 1
	overlaysicons.Parent = extraframe
	local overlaysbkg = Instance.new("Frame")
	overlaysbkg.BackgroundTransparency = 0.5
	overlaysbkg.BackgroundColor3 = Color3.new(0, 0, 0)
	overlaysbkg.BorderSizePixel = 0
	overlaysbkg.Visible = false
	overlaysbkg.Parent = windowtitle
	local overlaystitle = Instance.new("Frame")
	overlaystitle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlaystitle.Size = UDim2.new(0, 220, 0, 45)
	overlaystitle.Position = UDim2.new(0, 0, 1, -45)
	overlaystitle.Parent = overlaysbkg
	local overlaysicon = Instance.new("ImageLabel")
	overlaysicon.Name = "OverlaysWindowIcon"
	overlaysicon.Size = UDim2.new(0, 14, 0, 12)
	overlaysicon.Visible = true
	overlaysicon.Image = getcustomassetfunc("vape/assets/TextGUIIcon4.png")
	overlaysicon.BackgroundTransparency = 1
	overlaysicon.Position = UDim2.new(0, 10, 0, 15)
	overlaysicon.Parent = overlaystitle
	local overlaysexit = Instance.new("ImageButton")
	overlaysexit.Name = "OverlaysExit"
	overlaysexit.ImageColor3 = Color3.fromRGB(121, 121, 121)
	overlaysexit.Size = UDim2.new(0, 24, 0, 24)
	overlaysexit.AutoButtonColor = false
	overlaysexit.Image = getcustomassetfunc("vape/assets/ExitIcon1.png")
	overlaysexit.Position = UDim2.new(1, -32, 0, 9)
	overlaysexit.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlaysexit.Parent = overlaystitle
	local overlaysexitround = Instance.new("UICorner")
	overlaysexitround.CornerRadius = UDim.new(0, 16)
	overlaysexitround.Parent = overlaysexit
	overlaysexit.MouseEnter:connect(function()
		game:GetService("TweenService"):Create(overlaysexit, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(60, 60, 60), ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)
	overlaysexit.MouseLeave:connect(function()
		game:GetService("TweenService"):Create(overlaysexit, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(20, 20, 20), ImageColor3 = Color3.fromRGB(121, 121, 121)}):Play()
	end)
	local overlaysbutton = Instance.new("ImageButton")
	overlaysbutton.Size = UDim2.new(0, 14, 0, 14)
	overlaysbutton.Name = "MainButton"
	overlaysbutton.Position = UDim2.new(1, -23, 0, 15)
	overlaysbutton.BackgroundTransparency = 1
	overlaysbutton.AutoButtonColor = false
	overlaysbutton.Image = getcustomassetfunc("vape/assets/TextGUIIcon2.png")
	overlaysbutton.Parent = extraframe
	local overlaystext = Instance.new("TextLabel")
	overlaystext.Size = UDim2.new(0, 155, 0, 39)
	overlaystext.BackgroundTransparency = 1
	overlaystext.Name = "OverlaysTitle"
	overlaystext.Position = UDim2.new(0, 36, 0, 0)
	overlaystext.TextXAlignment = Enum.TextXAlignment.Left
	overlaystext.Font = Enum.Font.SourceSans
	overlaystext.TextSize = 17
	overlaystext.Text = "Overlays"
	overlaystext.TextColor3 = Color3.fromRGB(201, 201, 201)
	overlaystext.Parent = overlaystitle
	local overlayschildren = Instance.new("Frame")
	overlayschildren.BackgroundTransparency = 1
	overlayschildren.Size = UDim2.new(0, 220, 1, -4)
	overlayschildren.Name = "OverlaysChildren"
	overlayschildren.Position = UDim2.new(0, 0, 0, 41)
	overlayschildren.Parent = overlaystitle
	overlayschildren.Visible = true
	local children2 = Instance.new("Frame")
	children2.BackgroundTransparency = 1
	children2.Size = UDim2.new(0, 220, 1, -4)
	children2.Name = "SettingsChildren"
	children2.Position = UDim2.new(0, 0, 0, 41)
	children2.Parent = windowtitle
	children2.Visible = false
	local windowcorner = Instance.new("UICorner")
	windowcorner.CornerRadius = UDim.new(0, 4)
	windowcorner.Parent = windowtitle
	local overlayscorner = Instance.new("UICorner")
	overlayscorner.CornerRadius = UDim.new(0, 4)
	overlayscorner.Parent = overlaystitle
	local overlayscorner2 = Instance.new("UICorner")
	overlayscorner2.CornerRadius = UDim.new(0, 4)
	overlayscorner2.Parent = overlaysbkg
	local uilistlayout = Instance.new("UIListLayout")
	uilistlayout.SortOrder = Enum.SortOrder.LayoutOrder
	uilistlayout.Parent = children
	local uilistlayout2 = Instance.new("UIListLayout")
	uilistlayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uilistlayout2.Parent = children2
	uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):connect(function()
		windowtitle.Size = UDim2.new(0, 220, 0, 45 + uilistlayout.AbsoluteContentSize.Y * (1 / api["MainRescale"].Scale))
		overlaysbkg.Size = UDim2.new(0, 220, 0, 45 + uilistlayout.AbsoluteContentSize.Y * (1 / api["MainRescale"].Scale))
	end)
	local uilistlayout3 = Instance.new("UIListLayout")
	uilistlayout3.SortOrder = Enum.SortOrder.LayoutOrder
	uilistlayout3.Parent = overlayschildren
	uilistlayout3:GetPropertyChangedSignal("AbsoluteContentSize"):connect(function()
		overlaystitle.Size = UDim2.new(0, 220, 0, 45 + uilistlayout3.AbsoluteContentSize.Y * (1 / api["MainRescale"].Scale))
		overlaystitle.Position = UDim2.new(0, 0, 1, -(45 + (uilistlayout3.AbsoluteContentSize.Y * (1 / api["MainRescale"].Scale))))
	end)
	local uilistlayout4 = Instance.new("UIListLayout")
	uilistlayout4.SortOrder = Enum.SortOrder.LayoutOrder
	uilistlayout4.FillDirection = Enum.FillDirection.Horizontal
	uilistlayout4.Padding = UDim.new(0, 5)
	uilistlayout4.VerticalAlignment = Enum.VerticalAlignment.Center
	uilistlayout4.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uilistlayout4.Parent = overlaysicons
	dragGUI(windowtitle)
	windowapi["ExpandToggle"] = function() end
	api["ObjectsThatCanBeSaved"]["GUIWindow"] = {["Object"] = windowtitle, ["ChildrenObject"] = children, ["Type"] = "Window", ["Api"] = windowapi}
	settingswheel.MouseButton1Click:connect(function()
		windowlogo1.Visible = false
		settingswheel.Visible = false
		children.Visible = false
		children2.Visible = true
		settingsicon.Visible = true
		settingstext.Visible = true
		settingsexit.Visible = true
		windowtitle.Size = UDim2.new(0, 220, 0, 45 + uilistlayout2.AbsoluteContentSize.Y * (1 / api["MainRescale"].Scale))
	end)
	settingsexit.MouseButton1Click:connect(function()
		windowlogo1.Visible = true
		settingswheel.Visible = true
		children.Visible = true
		children2.Visible = false
		settingsicon.Visible = false
		settingstext.Visible = false
		settingsexit.Visible = false
		windowtitle.Size = UDim2.new(0, 220, 0, 45 + uilistlayout.AbsoluteContentSize.Y * (1 / api["MainRescale"].Scale))
	end)
	overlaysbutton.MouseButton1Click:connect(function()
		overlaysbkg.Visible = true
	end)
	overlaysexit.MouseButton1Click:connect(function()
		overlaysbkg.Visible = false
	end)
	windowapi["GetVisibleIcons"] = function()
		local currenticons = overlaysicons:GetChildren()
		local visibleicons = 0
		for i = 1, #currenticons do
			if currenticons[i]:IsA("ImageLabel") and currenticons[i].Visible == true then
				visibleicons = visibleicons + 1
			end
		end
		return visibleicons
	end
	windowapi["CreateCustomToggle"] = function(name, icon, temporaryfunction, temporaryfunction2, default, compatability, priority)
		local buttonapi = {}
		local amount = #overlayschildren:GetChildren()
		local buttontext = Instance.new("TextLabel")
		buttontext.BackgroundTransparency = 1
		buttontext.Name = "ButtonText"
		buttontext.Text = " "..name
		buttontext.Name = name
		buttontext.LayoutOrder = amount
		buttontext.Size = UDim2.new(1, 0, 0, 40)
		buttontext.Active = false
		buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
		buttontext.TextSize = 17
		buttontext.Font = Enum.Font.SourceSans
		buttontext.TextXAlignment = Enum.TextXAlignment.Left
		buttontext.Parent = overlayschildren
		local button = Instance.new("Frame")
		button.Size = UDim2.new(0, 16, 0, 16)
		button.BackgroundTransparency = 1
		button.Active = true
		button.Position = UDim2.new(0, 5, 0, 5)
		button.Parent = buttontext
		local buttoncorner = Instance.new("UICorner")
		buttoncorner.CornerRadius = UDim.new(0, 4)
		buttoncorner.Parent = button
		local buttonfill = Instance.new("Frame")
		buttonfill.Size = UDim2.new(1, -2, 1, -2)
		buttonfill.Position = UDim2.new(0, 1, 0, 1)
		buttonfill.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		buttonfill.Parent = button
		local buttonfillcorner = Instance.new("UICorner")
		buttonfillcorner.CornerRadius = UDim.new(0, 4)
		buttonfillcorner.Parent = buttonfill
		local buttonimage = Instance.new("ImageLabel")
		buttonimage.Size = UDim2.new(0, 14, 0, 14)
		buttonimage.Position = UDim2.new(0, 1, 0, 1)
		buttonimage.BackgroundTransparency = 1
		buttonimage.Image = getcustomassetfunc(icon)
		buttonimage.Parent = button
		local buttonfill2 = Instance.new("Frame")
		buttonfill2.Size = UDim2.new(0, 14, 0, 14)
		buttonfill2.Position = UDim2.new(0, 1, 0, 1)
		buttonfill2.BackgroundTransparency = 1
		buttonfill2.BackgroundColor3 = Color3.fromRGB(14, 15, 14)
		buttonfill2.Parent = button
		local buttonfill2corner = Instance.new("UICorner")
		buttonfill2corner.CornerRadius = UDim.new(0, 4)
		buttonfill2corner.Parent = buttonfill2
		local buttonstroke = Instance.new("UIStroke")
		buttonstroke.Thickness = 1
		buttonstroke.Color = Color3.fromRGB(121, 121, 121)
		buttonstroke.Parent = buttonfill2
		local buttonapi = {
			["Enabled"] = default or false,
			["Icon"] = buttonimage,
			["Fill"] = buttonfill2,
			["Name"] = name
		}
		local function setcolor(enabled)
			if enabled then
				game:GetService("TweenService"):Create(buttonfill2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromHSV(rainbowvalue, 1, 1), ImageColor3 = Color3.fromHSV(rainbowvalue, 1, 1)}):Play()
				game:GetService("TweenService"):Create(buttonstroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Color = Color3.fromHSV(rainbowvalue, 1, 1)}):Play()
			else
				game:GetService("TweenService"):Create(buttonfill2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(14, 15, 14), ImageColor3 = Color3.fromRGB(162, 162, 162)}):Play()
				game:GetService("TweenService"):Create(buttonstroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(121, 121, 121)}):Play()
			end
		end
		setcolor(buttonapi["Enabled"])
		buttonapi["ToggleButton"] = function()
			buttonapi["Enabled"] = not buttonapi["Enabled"]
			setcolor(buttonapi["Enabled"])
			if buttonapi["Enabled"] then
				if temporaryfunction then temporaryfunction() end
			else
				if temporaryfunction2 then temporaryfunction2() end
			end
		end
		button.MouseButton1Click:connect(function()
			buttonapi["ToggleButton"]()
		end)
		api["ObjectsThatCanBeSaved"][name] = {["Object"] = buttontext, ["Type"] = "NewToggle", ["Api"] = buttonapi}
		return buttonapi
	end
	api["CreateDropdown"] = function(window, name, list, defaultvalue)
		local dropdownapi = {}
		local dropdowntext = Instance.new("TextLabel")
		dropdowntext.BackgroundTransparency = 1
		dropdowntext.Name = "Dropdown"
		dropdowntext.Text = name
		dropdowntext.LayoutOrder = 1
		dropdowntext.Size = UDim2.new(1, 0, 0, 20)
		dropdowntext.Active = false
		dropdowntext.TextColor3 = Color3.fromRGB(162, 162, 162)
		dropdowntext.TextSize = 17
		dropdowntext.Font = Enum.Font.SourceSans
		dropdowntext.TextXAlignment = Enum.TextXAlignment.Left
		dropdowntext.Parent = window
		local dropdownmainbutton = Instance.new("Frame")
		dropdownmainbutton.Size = UDim2.new(1, -12, 0, 25)
		dropdownmainbutton.Position = UDim2.new(0, 6, 0, 20)
		dropdownmainbutton.BackgroundColor3 = Color3.fromRGB(36, 35, 36)
		dropdownmainbutton.Parent = dropdowntext
		local dropdownbuttoncorner = Instance.new("UICorner")
		dropdownbuttoncorner.CornerRadius = UDim.new(0, 4)
		dropdownbuttoncorner.Parent = dropdownmainbutton
		local dropdownmainbuttonstroke = Instance.new("UIStroke")
		dropdownmainbuttonstroke.Thickness = 1
		dropdownmainbuttonstroke.Color = Color3.fromRGB(60, 60, 60)
		dropdownmainbuttonstroke.Parent = dropdownmainbutton
		local dropdownselectedtext = Instance.new("TextLabel")
		dropdownselectedtext.BackgroundTransparency = 1
		dropdownselectedtext.Name = "SelectedText"
		dropdownselectedtext.Text = defaultvalue
		dropdownselectedtext.LayoutOrder = 1
		dropdownselectedtext.Size = UDim2.new(1, 0, 1, 0)
		dropdownselectedtext.Active = false
		dropdownselectedtext.TextColor3 = Color3.fromRGB(162, 162, 162)
		dropdownselectedtext.TextSize = 16
		dropdownselectedtext.Font = Enum.Font.SourceSans
		dropdownselectedtext.TextXAlignment = Enum.TextXAlignment.Left
		dropdownselectedtext.TextYAlignment = Enum.TextYAlignment.Center
		dropdownselectedtext.TextXAlignment = Enum.TextXAlignment.Right
		dropdownselectedtext.Parent = dropdownmainbutton
		dropdownselectedtext.Text = "  " .. defaultvalue .. " "
		local dropdownarrow = Instance.new("ImageLabel")
		dropdownarrow.BackgroundTransparency = 1
		dropdownarrow.Image = getcustomassetfunc("vape/assets/DropdownArrow2.png")
		dropdownarrow.Position = UDim2.new(1, -20, 0, 5)
		dropdownarrow.Size = UDim2.new(0, 14, 0, 14)
		dropdownarrow.Parent = dropdownmainbutton
		local dropdownlistframe = Instance.new("Frame")
		dropdownlistframe.Size = UDim2.new(1, 0, 0, 120)
		dropdownlistframe.BackgroundTransparency = 1
		dropdownlistframe.Position = UDim2.new(0, 6, 1, 6)
		dropdownlistframe.Parent = dropdowntext
		dropdownlistframe.Visible = false
		local dropdownlistui = Instance.new("UIListLayout")
		dropdownlistui.SortOrder = Enum.SortOrder.LayoutOrder
		dropdownlistui.Parent = dropdownlistframe
		local dropdownlistbkg = Instance.new("Frame")
		dropdownlistbkg.Size = UDim2.new(1, -12, 1, 0)
		dropdownlistbkg.Position = UDim2.new(0, 6, 0, 0)
		dropdownlistbkg.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
		dropdownlistbkg.Parent = dropdownlistframe
		local dropdownlistcorner = Instance.new("UICorner")
		dropdownlistcorner.CornerRadius = UDim.new(0, 4)
		dropdownlistcorner.Parent = dropdownlistbkg
		local dropdownlistbkgstroke = Instance.new("UIStroke")
		dropdownlistbkgstroke.Thickness = 1
		dropdownlistbkgstroke.Color = Color3.fromRGB(60, 60, 60)
		dropdownlistbkgstroke.Parent = dropdownlistbkg
		local dropdownscrollingframe = Instance.new("ScrollingFrame")
		dropdownscrollingframe.Size = UDim2.new(1, 0, 1, 0)
		dropdownscrollingframe.BackgroundTransparency = 1
		dropdownscrollingframe.BorderSizePixel = 0
		dropdownscrollingframe.CanvasSize = UDim2.new(0, 0, 0, 0)
		dropdownscrollingframe.ScrollBarImageColor3 = Color3.fromRGB(121, 121, 121)
		dropdownscrollingframe.ScrollBarBackgroundColor3 = Color3.fromRGB(40, 40, 40)
		dropdownscrollingframe.Parent = dropdownlistbkg
		local dropdownlistui2 = Instance.new("UIListLayout")
		dropdownlistui2.SortOrder = Enum.SortOrder.LayoutOrder
		dropdownlistui2.Parent = dropdownscrollingframe
		dropdownlistui2.Padding = UDim.new(0, 1)
		dropdownlistui2:GetPropertyChangedSignal("AbsoluteContentSize"):connect(function()
			dropdownscrollingframe.CanvasSize = UDim2.new(0, 0, 0, dropdownlistui2.AbsoluteContentSize.Y)
		end)
		dropdownapi["RefreshValues"] = function()
			dropdownscrollingframe:ClearAllChildren()
			for i,v in pairs(list) do
				local newdropdownbutton = Instance.new("TextButton")
				newdropdownbutton.BackgroundTransparency = 1
				newdropdownbutton.Name = v
				newdropdownbutton.Text = " "..v
				newdropdownbutton.LayoutOrder = 1
				newdropdownbutton.Size = UDim2.new(1, 0, 0, 20)
				newdropdownbutton.Active = true
				newdropdownbutton.TextColor3 = Color3.fromRGB(162, 162, 162)
				newdropdownbutton.TextSize = 16
				newdropdownbutton.Font = Enum.Font.SourceSans
				newdropdownbutton.TextXAlignment = Enum.TextXAlignment.Left
				newdropdownbutton.TextYAlignment = Enum.TextYAlignment.Center
				newdropdownbutton.Parent = dropdownscrollingframe
				newdropdownbutton.MouseButton1Click:connect(function()
					dropdownselectedtext.Text = "  " .. v .. " "
					dropdownapi["Value"] = v
					dropdownlistframe.Visible = false
				end)
			end
		end
		dropdownapi["RefreshValues"]()
		dropdownapi["Value"] = defaultvalue or ""
		dropdownapi["SetValue"] = function(val)
			dropdownselectedtext.Text = "  " .. val .. " "
			dropdownapi["Value"] = val
		end
		dropdownmainbutton.MouseButton1Click:connect(function()
			dropdownlistframe.Visible = not dropdownlistframe.Visible
			if dropdownlistframe.Visible then
				game:GetService("TweenService"):Create(dropdowntext, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(1, 0, 0, 25 + dropdownlistui2.AbsoluteContentSize.Y + 12)}):Play()
			else
				game:GetService("TweenService"):Create(dropdowntext, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(1, 0, 0, 25)}):Play()
			end
		end)
		api["ObjectsThatCanBeSaved"][name] = {["Object"] = dropdowntext, ["Type"] = "Dropdown", ["Api"] = dropdownapi}
		return dropdownapi
	end
	api["CreateSlider"] = function(window, name, min, max, default)
		local sliderapi = {}
		local slidertext = Instance.new("TextLabel")
		slidertext.BackgroundTransparency = 1
		slidertext.Name = "Slider"
		slidertext.Text = name
		slidertext.LayoutOrder = 1
		slidertext.Size = UDim2.new(1, 0, 0, 20)
		slidertext.Active = false
		slidertext.TextColor3 = Color3.fromRGB(162, 162, 162)
		slidertext.TextSize = 17
		slidertext.Font = Enum.Font.SourceSans
		slidertext.TextXAlignment = Enum.TextXAlignment.Left
		slidertext.Parent = window
		local slider = Instance.new("Frame")
		slider.Size = UDim2.new(1, -12, 0, 25)
		slider.Position = UDim2.new(0, 6, 0, 20)
		slider.BackgroundColor3 = Color3.fromRGB(36, 35, 36)
		slider.Parent = slidertext
		local slidercorner = Instance.new("UICorner")
		slidercorner.CornerRadius = UDim.new(0, 4)
		slidercorner.Parent = slider
		local sliderstroke = Instance.new("UIStroke")
		sliderstroke.Thickness = 1
		sliderstroke.Color = Color3.fromRGB(60, 60, 60)
		sliderstroke.Parent = slider
		local sliderfill = Instance.new("Frame")
		sliderfill.Name = "FillSlider"
		sliderfill.Size = UDim2.new(0, 0, 1, 0)
		sliderfill.BackgroundColor3 = Color3.fromHSV(0.44, 1, 1)
		sliderfill.Parent = slider
		local button = Instance.new("Frame")
		button.Size = UDim2.new(0, 16, 0, 16)
		button.Name = "ButtonSlider"
		button.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
		button.Position = UDim2.new(0, -8, 1, -8)
		button.Parent = slider
		local buttoncorner = Instance.new("UICorner")
		buttoncorner.CornerRadius = UDim.new(0, 4)
		buttoncorner.Parent = button
		local slidertextlabel = Instance.new("TextLabel")
		slidertextlabel.Name = "Value"
		slidertextlabel.Size = UDim2.new(1, 0, 0, 20)
		slidertextlabel.Position = UDim2.new(0, 0, 0, -20)
		slidertextlabel.Text = ""
		slidertextlabel.BackgroundTransparency = 1
		slidertextlabel.TextColor3 = Color3.fromRGB(162, 162, 162)
		slidertextlabel.TextSize = 17
		slidertextlabel.Font = Enum.Font.SourceSans
		slidertextlabel.TextXAlignment = Enum.TextXAlignment.Right
		slidertextlabel.Parent = slider
		local dragging = false
		local function update()
			local pos = RelativeXY(slider, game:GetService("UserInputService"):GetMouseLocation())
			if pos and pos < slider.AbsoluteSize.X then
				button.Position = UDim2.new(pos/slider.AbsoluteSize.X, -8, 1, -8)
				sliderfill.Size = UDim2.new(pos/slider.AbsoluteSize.X, 0, 1, 0)
				local value = math.floor((min + (pos/slider.AbsoluteSize.X) * (max - min)) * 100) / 100
				sliderapi["Value"] = value
				slidertextlabel.Text = value
			end
		end
		local function setvalue(val)
			sliderapi["Value"] = val
			local percentage = (val - min) / (max - min)
			sliderfill.Size = UDim2.new(percentage, 0, 1, 0)
			button.Position = UDim2.new(percentage, -8, 1, -8)
			slidertextlabel.Text = val
		end
		setvalue(default or min)
		button.MouseButton1Down:connect(function()
			dragging = true
		end)
		game:GetService("UserInputService").InputEnded:connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		game:GetService("UserInputService").InputChanged:connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				if dragging and not processed then
					update()
				end
			end
		end)
		sliderapi["SetValue"] = setvalue
		api["ObjectsThatCanBeSaved"][name] = {["Type"] = "Slider", ["Object"] = slidertext, ["Api"] = sliderapi}
		return sliderapi
	end
	api["CreateTwoSlider"] = function(window, name, min, max, default, default2)
		local sliderapi = {}
		local slidertext = Instance.new("TextLabel")
		slidertext.BackgroundTransparency = 1
		slidertext.Name = "TwoSlider"
		slidertext.Text = name
		slidertext.LayoutOrder = 1
		slidertext.Size = UDim2.new(1, 0, 0, 20)
		slidertext.Active = false
		slidertext.TextColor3 = Color3.fromRGB(162, 162, 162)
		slidertext.TextSize = 17
		slidertext.Font = Enum.Font.SourceSans
		slidertext.TextXAlignment = Enum.TextXAlignment.Left
		slidertext.Parent = window
		local slider = Instance.new("Frame")
		slider.Name = "Slider"
		slider.Size = UDim2.new(1, -12, 0, 25)
		slider.Position = UDim2.new(0, 6, 0, 20)
		slider.BackgroundColor3 = Color3.fromRGB(36, 35, 36)
		slider.Parent = slidertext
		local slidercorner = Instance.new("UICorner")
		slidercorner.CornerRadius = UDim.new(0, 4)
		slidercorner.Parent = slider
		local sliderstroke = Instance.new("UIStroke")
		sliderstroke.Thickness = 1
		sliderstroke.Color = Color3.fromRGB(60, 60, 60)
		sliderstroke.Parent = slider
		local sliderfill = Instance.new("Frame")
		sliderfill.Name = "FillSlider"
		sliderfill.Size = UDim2.new(0, 0, 1, 0)
		sliderfill.BackgroundColor3 = Color3.fromHSV(0.44, 1, 1)
		sliderfill.Parent = slider
		local button = Instance.new("Frame")
		button.Size = UDim2.new(0, 16, 0, 16)
		button.Name = "ButtonSlider"
		button.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
		button.Position = UDim2.new(0, -8, 1, -8)
		button.Parent = slider
		local buttoncorner = Instance.new("UICorner")
		buttoncorner.CornerRadius = UDim.new(0, 4)
		buttoncorner.Parent = button
		local button2 = Instance.new("Frame")
		button2.Size = UDim2.new(0, 16, 0, 16)
		button2.Name = "ButtonSlider2"
		button2.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
		button2.Position = UDim2.new(0.5, -8, 1, -8)
		button2.Parent = slider
		local buttoncorner2 = Instance.new("UICorner")
		buttoncorner2.CornerRadius = UDim.new(0, 4)
		buttoncorner2.Parent = button2
		local slidertextlabel = Instance.new("TextLabel")
		slidertextlabel.Name = "Value"
		slidertextlabel.Size = UDim2.new(1, 0, 0, 20)
		slidertextlabel.Position = UDim2.new(0, 0, 0, -20)
		slidertextlabel.Text = ""
		slidertextlabel.BackgroundTransparency = 1
		slidertextlabel.TextColor3 = Color3.fromRGB(162, 162, 162)
		slidertextlabel.TextSize = 17
		slidertextlabel.Font = Enum.Font.SourceSans
		slidertextlabel.TextXAlignment = Enum.TextXAlignment.Right
		slidertextlabel.Parent = slider
		local dragging = nil
		local function update()
			local pos = RelativeXY(slider, game:GetService("UserInputService"):GetMouseLocation())
			if pos and pos < slider.AbsoluteSize.X then
				local button1x = button.AbsolutePosition.X
				local button2x = button2.AbsolutePosition.X
				if dragging == 1 then
					button.Position = UDim2.new(pos/slider.AbsoluteSize.X, -8, 1, -8)
					if button.AbsolutePosition.X > button2x then
						button.Position = UDim2.new((button2x/slider.AbsoluteSize.X) - (16/slider.AbsoluteSize.X), -8, 1, -8)
					end
				else
					button2.Position = UDim2.new(pos/slider.AbsoluteSize.X, -8, 1, -8)
					if button2.AbsolutePosition.X < button1x then
						button2.Position = UDim2.new((button1x/slider.AbsoluteSize.X) + (16/slider.AbsoluteSize.X), -8, 1, -8)
					end
				end
				local button1x = button.AbsolutePosition.X
				local button2x = button2.AbsolutePosition.X
				local fillsize = button2x - button1x
				local fillpos = button1x
				sliderfill.Size = UDim2.new(0, fillsize, 1, 0)
				sliderfill.Position = UDim2.new(0, fillpos - slider.AbsolutePosition.X, 0, 0)
				local value = math.floor((min + (button.Position.X.Scale) * (max - min)) * 100) / 100
				local value2 = math.floor((min + (button2.Position.X.Scale) * (max - min)) * 100) / 100
				if value == min then value = 0 end
				if value2 == min then value2 = 0 end
				sliderapi["Value"] = value
				sliderapi["Value2"] = value2
				slidertextlabel.Text = value.." "..value2
			end
		end
		local function setvalue(val)
			local percentage = (val - min) / (max - min)
			button.Position = UDim2.new(percentage, -8, 1, -8)
			update()
		end
		local function setvalue2(val)
			local percentage = (val - min) / (max - min)
			button2.Position = UDim2.new(percentage, -8, 1, -8)
			update()
		end
		setvalue(default or min)
		setvalue2(default2 or min)
		button.MouseButton1Down:connect(function()
			dragging = 1
		end)
		button2.MouseButton1Down:connect(function()
			dragging = 2
		end)
		game:GetService("UserInputService").InputEnded:connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = nil
			end
		end)
		game:GetService("UserInputService").InputChanged:connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				if dragging and not processed then
					update()
				end
			end
		end)
		sliderapi["SetValue"] = setvalue
		sliderapi["SetValue2"] = setvalue2
		api["ObjectsThatCanBeSaved"][name] = {["Type"] = "TwoSlider", ["Object"] = slidertext, ["Api"] = sliderapi}
		return sliderapi
	end
	api["CreateColorSlider"] = function(window, name, default)
		local sliderapi = {}
		local slidertext = Instance.new("TextLabel")
		slidertext.BackgroundTransparency = 1
		slidertext.Name = "ColorSlider"
		slidertext.Text = name
		slidertext.LayoutOrder = 1
		slidertext.Size = UDim2.new(1, 0, 0, 20)
		slidertext.Active = false
		slidertext.TextColor3 = Color3.fromRGB(162, 162, 162)
		slidertext.TextSize = 17
		slidertext.Font = Enum.Font.SourceSans
		slidertext.TextXAlignment = Enum.TextXAlignment.Left
		slidertext.Parent = window
		local slider = Instance.new("Frame")
		slider.Size = UDim2.new(1, -12, 0, 25)
		slider.Position = UDim2.new(0, 6, 0, 20)
		slider.BackgroundColor3 = Color3.fromRGB(36, 35, 36)
		slider.Parent = slidertext
		local slidercorner = Instance.new("UICorner")
		slidercorner.CornerRadius = UDim.new(0, 4)
		slidercorner.Parent = slider
		local sliderstroke = Instance.new("UIStroke")
		sliderstroke.Thickness = 1
		sliderstroke.Color = Color3.fromRGB(60, 60, 60)
		sliderstroke.Parent = slider
		local sliderfill = Instance.new("Frame")
		sliderfill.Name = "FillSlider"
		sliderfill.Size = UDim2.new(1, 0, 1, 0)
		sliderfill.BackgroundTransparency = 1
		sliderfill.Parent = slider
		local button = Instance.new("Frame")
		button.Size = UDim2.new(0, 14, 0, 14)
		button.Name = "ButtonSlider"
		button.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
		button.Position = UDim2.new(0.5, -7, 0, -7)
		button.Parent = slider
		local buttoncorner = Instance.new("UICorner")
		buttoncorner.CornerRadius = UDim.new(0, 4)
		buttoncorner.Parent = button
		local buttonstroke = Instance.new("UIStroke")
		buttonstroke.Thickness = 1
		buttonstroke.Color = Color3.fromHSV(rainbowvalue, 1, 1)
		buttonstroke.Parent = button
		local slidertextlabel = Instance.new("TextLabel")
		slidertextlabel.Name = "Value"
		slidertextlabel.Size = UDim2.new(1, 0, 0, 20)
		slidertextlabel.Position = UDim2.new(0, 0, 0, -20)
		slidertextlabel.Text = ""
		slidertextlabel.BackgroundTransparency = 1
		slidertextlabel.TextColor3 = Color3.fromRGB(162, 162, 162)
		slidertextlabel.TextSize = 17
		slidertextlabel.Font = Enum.Font.SourceSans
		slidertextlabel.TextXAlignment = Enum.TextXAlignment.Right
		slidertextlabel.Parent = slider
		local dragging = false
		local function update()
			local pos = RelativeXY(slider, game:GetService("UserInputService"):GetMouseLocation())
			if pos and pos < slider.AbsoluteSize.X then
				local pos2 = math.clamp(pos/slider.AbsoluteSize.X, 0.02, 0.95)
				button.Position = UDim2.new(pos2, -7, 0, -7)
				local value = math.floor((pos/slider.AbsoluteSize.X) * 100) / 100
				if value == 0 then value = 0.01 end
				sliderapi["Value"] = value
				slidertextlabel.Text = value
			end
		end
		local function setvalue(val)
			sliderapi["Value"] = val
			local percentage = val
			if percentage == 0 then percentage = 0.01 end
			button.Position = UDim2.new(math.clamp(percentage, 0.02, 0.95), -7, 0, -7)
			slidertextlabel.Text = val
		end
		local function setrainbow(val)
			if not val then val = 0 end
			local newcolor = Color3.fromHSV(val, 1, 1)
			buttonstroke.Color = newcolor
		end
		setvalue(default or 0.5)
		setrainbow(0.44)
		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
		})
		gradient.Parent = sliderfill
		button.MouseButton1Down:connect(function()
			dragging = true
		end)
		game:GetService("UserInputService").InputEnded:connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		game:GetService("UserInputService").InputChanged:connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				if dragging and not processed then
					update()
				end
			end
		end)
		RunService.RenderStepped:connect(function()
			if sliderapi["RainbowValue"] then
				if dragging == false then
					buttonstroke.Color = Color3.fromHSV(rainbowvalue, 1, 1)
				end
			end
		end)
		sliderapi["SetValue"] = setvalue
		sliderapi["SetRainbow"] = setrainbow
		api["ObjectsThatCanBeSaved"][name] = {["Type"] = "ColorSlider", ["Object"] = slidertext, ["Api"] = sliderapi}
		return sliderapi
	end
	api["CreateToggle"] = function(window, name, temporaryfunction, temporaryfunction2, default)
		local toggleapi = {}
		local buttontext = Instance.new("TextButton")
		buttontext.BackgroundTransparency = 1
		buttontext.Name = name
		buttontext.Text = " "..name
		buttontext.LayoutOrder = 1
		buttontext.Size = UDim2.new(1, 0, 0, 40)
		buttontext.Active = true
		buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
		buttontext.TextSize = 17
		buttontext.Font = Enum.Font.SourceSans
		buttontext.TextXAlignment = Enum.TextXAlignment.Left
		buttontext.Parent = window
		local button = Instance.new("Frame")
		button.Size = UDim2.new(0, 16, 0, 16)
		button.Active = true
		button.Position = UDim2.new(1, -21, 0, 12)
		button.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
		button.Parent = buttontext
		local buttoncorner = Instance.new("UICorner")
		buttoncorner.CornerRadius = UDim.new(0, 4)
		buttoncorner.Parent = button
		local buttonfill = Instance.new("Frame")
		buttonfill.Size = UDim2.new(0.5, 0, 1, 0)
		buttonfill.BackgroundColor3 = Color3.fromHSV(0.44, 1, 1)
		buttonfill.Parent = button
		local circle = Instance.new("Frame")
		circle.Size = UDim2.new(0, 14, 0, 14)
		circle.Position = UDim2.new(0, 1, 0, 1)
		circle.BackgroundColor3 = Color3.fromRGB(14, 15, 14)
		circle.Parent = button
		local circlecorner = Instance.new("UICorner")
		circlecorner.CornerRadius = UDim.new(1, 0)
		circlecorner.Parent = circle
		local toggleapi = {
			["Enabled"] = default,
			["Name"] = name
		}
		local function setcolor(enabled)
			if enabled then
				game:GetService("TweenService"):Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromHSV(rainbowvalue, 1, 1)}):Play()
				game:GetService("TweenService"):Create(buttonfill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(1, 0, 1, 0)}):Play()
				game:GetService("TweenService"):Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(1, -15, 0, 1)}):Play()
			else
				game:GetService("TweenService"):Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(26, 25, 26)}):Play()
				game:GetService("TweenService"):Create(buttonfill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0.5, 0, 1, 0)}):Play()
				game:GetService("TweenService"):Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 1, 0, 1)}):Play()
			end
		end
		setcolor(toggleapi["Enabled"])
		toggleapi["ToggleButton"] = function(state)
			toggleapi["Enabled"] = not toggleapi["Enabled"]
			setcolor(toggleapi["Enabled"])
			if toggleapi["Enabled"] then
				if temporaryfunction then temporaryfunction() end
			else
				if temporaryfunction2 then temporaryfunction2() end
			end
		end
		buttontext.MouseButton1Click:connect(function()
			toggleapi["ToggleButton"]()
		end)
		api["ObjectsThatCanBeSaved"][name] = {["Object"] = buttontext, ["Type"] = "Toggle", ["Api"] = toggleapi}
		return toggleapi
	end
	api["CreateKeybind"] = function(window, name, temporaryfunction, default)
		local keybindapi = {}
		local buttontext = Instance.new("TextButton")
		buttontext.BackgroundTransparency = 1
		buttontext.Name = name
		buttontext.Text = " "..name
		buttontext.LayoutOrder = 1
		buttontext.Size = UDim2.new(1, 0, 0, 40)
		buttontext.Active = true
		buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
		buttontext.TextSize = 17
		buttontext.Font = Enum.Font.SourceSans
		buttontext.TextXAlignment = Enum.TextXAlignment.Left
		buttontext.Parent = window
		local bindbkg = Instance.new("Frame")
		bindbkg.Size = UDim2.new(0, 40, 0, 20)
		bindbkg.Position = UDim2.new(1, -45, 0, 10)
		bindbkg.BackgroundColor3 = Color3.fromRGB(36, 35, 36)
		bindbkg.Parent = buttontext
		local bindcorner = Instance.new("UICorner")
		bindcorner.CornerRadius = UDim.new(0, 4)
		bindcorner.Parent = bindbkg
		local bindstroke = Instance.new("UIStroke")
		bindstroke.Thickness = 1
		bindstroke.Color = Color3.fromRGB(60, 60, 60)
		bindstroke.Parent = bindbkg
		local bindtext = Instance.new("TextLabel")
		bindtext.BackgroundTransparency = 1
		bindtext.Text = "None"
		bindtext.Size = UDim2.new(1, 0, 1, 0)
		bindtext.TextColor3 = Color3.fromRGB(162, 162, 162)
		bindtext.TextSize = 16
		bindtext.Font = Enum.Font.SourceSans
		bindtext.Parent = bindbkg
		local bindtext2 = Instance.new("TextLabel")
		bindtext2.BackgroundTransparency = 1
		bindtext2.Text = "..."
		bindtext2.Size = UDim2.new(1, 0, 1, 0)
		bindtext2.TextColor3 = Color3.fromHSV(rainbowvalue, 1, 1)
		bindtext2.Font = Enum.Font.SourceSans
		bindtext2.TextSize = 20
		bindtext2.Visible = false
		bindtext2.Parent = bindbkg
		local keybindapi = {
			["Keybind"] = "None",
			["Enabled"] = false
		}
		keybindapi["SetKeybind"] = function(key)
			keybindapi["Keybind"] = key
			bindtext.Text = key
			api["SaveSettings"]()
		end
		if default then keybindapi["SetKeybind"](default) end
		bindbkg.MouseButton1Click:connect(function()
			if api["KeybindCaptured"] == false then
				api["KeybindCaptured"] = true
				bindtext2.Visible = true
				local inputcon
				inputcon = game:GetService("UserInputService").InputBegan:connect(function(i)
					if i.KeyCode.Name ~= "Unknown" then
						keybindapi["SetKeybind"](i.KeyCode.Name)
						bindtext2.Visible = false
						api["KeybindCaptured"] = false
						inputcon:Disconnect()
					end
				end)
			end
		end)
		api["ObjectsThatCanBeSaved"][name] = {["Object"] = buttontext, ["Type"] = "Keybind", ["Api"] = keybindapi}
		return keybindapi
	end
	api["CreateCustomWindow"] = function(name, size, position, temporaryfunction, temporaryfunction2)
		local customwindowapi = {}
		local mainwindow = Instance.new("Frame")
		mainwindow.Name = name
		mainwindow.Size = UDim2.new(0, size.X.Offset, 0, size.Y.Offset)
		mainwindow.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset)
		mainwindow.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
		mainwindow.Parent = hudgui
		local mainwindowstroke = Instance.new("UIStroke")
		mainwindowstroke.Thickness = 1
		mainwindowstroke.Color = Color3.fromRGB(60, 60, 60)
		mainwindowstroke.Parent = mainwindow
		local mainwindowcorner = Instance.new("UICorner")
		mainwindowcorner.CornerRadius = UDim.new(0, 4)
		mainwindowcorner.Parent = mainwindow
		local titlebar = Instance.new("TextButton")
		titlebar.Size = UDim2.new(1, 0, 0, 15)
		titlebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		titlebar.Text = " "..name
		titlebar.TextColor3 = Color3.fromRGB(162, 162, 162)
		titlebar.Font = Enum.Font.SourceSans
		titlebar.TextSize = 17
		titlebar.TextXAlignment = Enum.TextXAlignment.Left
		titlebar.Parent = mainwindow
		local titlebarcorner = Instance.new("UICorner")
		titlebarcorner.CornerRadius = UDim.new(0, 4)
		titlebarcorner.Parent = titlebar
		local exitbutton = Instance.new("TextButton")
		exitbutton.Size = UDim2.new(0, 10, 0, 10)
		exitbutton.BackgroundTransparency = 1
		exitbutton.Text = "X"
		exitbutton.TextColor3 = Color3.fromRGB(162, 162, 162)
		exitbutton.Font = Enum.Font.SourceSans
		exitbutton.TextSize = 17
		exitbutton.Position = UDim2.new(1, -12, 0, 2)
		exitbutton.Parent = titlebar
		local pinbutton = exitbutton:Clone()
		pinbutton.Text = "P"
		pinbutton.Position = UDim2.new(1, -22, 0, 2)
		pinbutton.Parent = titlebar
		local children = Instance.new("Frame")
		children.Size = UDim2.new(1, -2, 1, -17)
		children.Position = UDim2.new(0, 1, 0, 16)
		children.BackgroundTransparency = 1
		children.Parent = mainwindow
		local uilistlayout = Instance.new("UIListLayout")
		uilistlayout.SortOrder = Enum.SortOrder.LayoutOrder
		uilistlayout.Parent = children
		local dragging = false
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local function update(input)
			local delta = input.Position - dragStart
			local pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			mainwindow.Position = pos
		end
		titlebar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = mainwindow.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						if temporaryfunction2 then temporaryfunction2(mainwindow.Position) end
					end
				end)
			end
		end)
		titlebar.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		game:GetService("UserInputService").InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
		exitbutton.MouseButton1Click:connect(function()
			mainwindow.Visible = false
			if temporaryfunction then temporaryfunction() end
		end)
		customwindowapi["Pinned"] = false
		customwindowapi["PinnedToggle"] = function()
			customwindowapi["Pinned"] = not customwindowapi["Pinned"]
			if customwindowapi["Pinned"] then
				mainwindow.Parent = clickgui
			else
				mainwindow.Parent = hudgui
			end
		end
		pinbutton.MouseButton1Click:connect(function()
			customwindowapi["PinnedToggle"]()
		end)
		customwindowapi["AddLabel"] = function(name)
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, -2, 0, 20)
			textlabel.Position = UDim2.new(0, 1, 0, 0)
			textlabel.BackgroundTransparency = 1
			textlabel.Name = name
			textlabel.TextColor3 = Color3.fromRGB(162, 162, 162)
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextSize = 17
			textlabel.Parent = children
			return textlabel
		end
		customwindowapi["CheckVis"] = function()
			if mainwindow.Visible and customwindowapi["Pinned"] == false and clickgui.Visible then
				mainwindow.Visible = false
			end
			if mainwindow.Visible == false and customwindowapi["Pinned"] == true and not clickgui.Visible then
				mainwindow.Visible = true
			end
		end
		api["ObjectsThatCanBeSaved"][name] = {["Object"] = mainwindow, ["Type"] = "CustomWindow", ["Api"] = customwindowapi}
		return customwindowapi
	end
	api["CreateNotification"] = function(title, text, time)
		local notif = Instance.new("Frame")
		notif.Size = UDim2.new(0, 200, 0, 70)
		notif.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
		notif.Position = UDim2.new(1, -200, 1, 70)
		notif.Parent = notificationwindow
		local notifcorner = Instance.new("UICorner")
		notifcorner.CornerRadius = UDim.new(0, 4)
		notifcorner.Parent = notif
		local notifstroke = Instance.new("UIStroke")
		notifstroke.Thickness = 1
		notifstroke.Color = Color3.fromRGB(60, 60, 60)
		notifstroke.Parent = notif
		local notiftitle = Instance.new("TextLabel")
		notiftitle.Size = UDim2.new(1, 0, 0, 20)
		notiftitle.Position = UDim2.new(0, 0, 0, 5)
		notiftitle.BackgroundTransparency = 1
		notiftitle.Text = title
		notiftitle.TextColor3 = Color3.fromRGB(162, 162, 162)
		notiftitle.Font = Enum.Font.SourceSans
		notiftitle.TextSize = 17
		notiftitle.Parent = notif
		local notiftext = Instance.new("TextLabel")
		notiftext.Size = UDim2.new(1, -20, 0, 50)
		notiftext.Position = UDim2.new(0, 10, 0, 20)
		notiftext.BackgroundTransparency = 1
		notiftext.RichText = true
		notiftext.Text = text
		notiftext.TextColor3 = Color3.fromRGB(162, 162, 162)
		notiftext.Font = Enum.Font.SourceSans
		notiftext.TextSize = 17
		notiftext.TextWrapped = true
		notiftext.TextXAlignment = Enum.TextXAlignment.Left
		notiftext.TextYAlignment = Enum.TextYAlignment.Top
		notiftext.Parent = notif
		game:GetService("TweenService"):Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -200, 1, -75)}):Play()
		game:GetService("Debris"):AddItem(notif, time or 2)
	end
	api["CreateTab"] = function(window, name, icon)
		local tabapi = {}
		local button = Instance.new("ImageButton")
		button.Name = name
		button.Image = icon
		button.LayoutOrder = 1
		button.Size = UDim2.new(0, 22, 0, 22)
		button.BackgroundTransparency = 1
		button.Position = UDim2.new(0, 1, 0, 1)
		button.ImageColor3 = Color3.fromRGB(162, 162, 162)
		button.Parent = window
		local tabcontents = Instance.new("Frame")
		tabcontents.BackgroundTransparency = 1
		tabcontents.Size = UDim2.new(1, 0, 1, 0)
		tabcontents.Position = UDim2.new(0, 0, 0, 0)
		tabcontents.Visible = false
		tabcontents.Parent = window.Parent.Children
		local uilistlayout = Instance.new("UIListLayout")
		uilistlayout.SortOrder = Enum.SortOrder.LayoutOrder
		uilistlayout.Parent = tabcontents
		tabapi["CreateButton"] = function(name, temporaryfunction)
			local buttonapi = {}
			local button = Instance.new("TextButton")
			button.Name = name
			button.LayoutOrder = 1
			button.Size = UDim2.new(1, -12, 0, 40)
			button.Position = UDim2.new(0, 6, 0, 0)
			button.Text = " "..name
			button.BackgroundTransparency = 1
			button.TextColor3 = Color3.fromRGB(162, 162, 162)
			button.TextSize = 17
			button.Font = Enum.Font.SourceSans
			button.TextXAlignment = Enum.TextXAlignment.Left
			button.Parent = tabcontents
			local buttonbkg = Instance.new("Frame")
			buttonbkg.BackgroundTransparency = 0.5
			buttonbkg.BackgroundColor3 = Color3.new(0, 0, 0)
			buttonbkg.Size = UDim2.new(1, 0, 1, 0)
			buttonbkg.Parent = button
			local buttonround = Instance.new("UICorner")
			buttonround.CornerRadius = UDim.new(0, 4)
			buttonround.Parent = buttonbkg
			local buttonstroke = Instance.new("UIStroke")
			buttonstroke.Thickness = 1
			buttonstroke.Color = Color3.fromRGB(60, 60, 60)
			buttonstroke.Parent = buttonbkg
			button.MouseEnter:connect(function()
				game:GetService("TweenService"):Create(buttonbkg, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(162, 162, 162)}):Play()
				game:GetService("TweenService"):Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(14, 15, 14)}):Play()
			end)
			button.MouseLeave:connect(function()
				game:GetService("TweenService"):Create(buttonbkg, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.new(0, 0, 0)}):Play()
				game:GetService("TweenService"):Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(162, 162, 162)}):Play()
			end)
			button.MouseButton1Click:connect(function()
				if temporaryfunction then temporaryfunction() end
				if api["ToggleNotifications"] then api["CreateNotification"]("Module Toggled", name..' <font color="#FFFFFF">has been</font> <font color="#32CD32">Enabled</font><font color="#FFFFFF">!', 1) end
			end)
			api["ObjectsThatCanBeSaved"][name] = {["Type"] = "Button", ["Object"] = button, ["Api"] = buttonapi}
			return buttonapi
		end
		tabapi["CreateToggle"] = function(name, temporaryfunction, temporaryfunction2, default)
			local toggleapi = {
				["Enabled"] = default or false,
				["Name"] = name
			}
			local buttontext = Instance.new("TextButton")
			buttontext.BackgroundTransparency = 1
			buttontext.Name = name
			buttontext.Text = " "..name
			buttontext.LayoutOrder = 1
			buttontext.Size = UDim2.new(1, -12, 0, 40)
			buttontext.Position = UDim2.new(0, 6, 0, 0)
			buttontext.Active = true
			buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
			buttontext.TextSize = 17
			buttontext.Font = Enum.Font.SourceSans
			buttontext.TextXAlignment = Enum.TextXAlignment.Left
			buttontext.Parent = tabcontents
			local buttonbkg = Instance.new("Frame")
			buttonbkg.BackgroundTransparency = 0.5
			buttonbkg.BackgroundColor3 = Color3.new(0, 0, 0)
			buttonbkg.Size = UDim2.new(1, 0, 1, 0)
			buttonbkg.Parent = buttontext
			local buttonround = Instance.new("UICorner")
			buttonround.CornerRadius = UDim.new(0, 4)
			buttonround.Parent = buttonbkg
			local buttonstroke = Instance.new("UIStroke")
			buttonstroke.Thickness = 1
			buttonstroke.Color = Color3.fromRGB(60, 60, 60)
			buttonstroke.Parent = buttonbkg
			local button = Instance.new("Frame")
			button.Size = UDim2.new(0, 16, 0, 16)
			button.Active = true
			button.Position = UDim2.new(1, -22, 0, 12)
			button.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
			button.Parent = buttontext
			local buttoncorner = Instance.new("UICorner")
			buttoncorner.CornerRadius = UDim.new(0, 4)
			buttoncorner.Parent = button
			local buttonfill = Instance.new("Frame")
			buttonfill.Size = UDim2.new(0.5, 0, 1, 0)
			buttonfill.BackgroundColor3 = Color3.fromHSV(0.44, 1, 1)
			buttonfill.Parent = button
			local circle = Instance.new("Frame")
			circle.Size = UDim2.new(0, 14, 0, 14)
			circle.Position = UDim2.new(0, 1, 0, 1)
			circle.BackgroundColor3 = Color3.fromRGB(14, 15, 14)
			circle.Parent = button
			local circlecorner = Instance.new("UICorner")
			circlecorner.CornerRadius = UDim.new(1, 0)
			circlecorner.Parent = circle
			local function setcolor(enabled)
				if enabled then
					game:GetService("TweenService"):Create(buttonfill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(1, 0, 1, 0)}):Play()
					game:GetService("TweenService"):Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(1, -15, 0, 1)}):Play()
					game:GetService("TweenService"):Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromHSV(rainbowvalue, 1, 1)}):Play()
					game:GetService("TweenService"):Create(buttontext, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromHSV(rainbowvalue, 1, 1)}):Play()
				else
					game:GetService("TweenService"):Create(buttonfill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0.5, 0, 1, 0)}):Play()
					game:GetService("TweenService"):Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 1, 0, 1)}):Play()
					game:GetService("TweenService"):Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(26, 25, 26)}):Play()
					game:GetService("TweenService"):Create(buttontext, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(162, 162, 162)}):Play()
				end
			end
			setcolor(toggleapi["Enabled"])
			toggleapi["ToggleButton"] = function(state, bypass)
				if not bypass then toggleapi["Enabled"] = not toggleapi["Enabled"] end
				if state ~= nil then toggleapi["Enabled"] = state end
				setcolor(toggleapi["Enabled"])
				if toggleapi["Enabled"] then
					if temporaryfunction then temporaryfunction() end
				else
					if temporaryfunction2 then temporaryfunction2() end
				end
				api["SaveSettings"]()
			end
			buttontext.MouseButton1Click:connect(function()
				toggleapi["ToggleButton"]()
				if api["ToggleNotifications"] then
					api["CreateNotification"]("Module Toggled", name..' <font color="#FFFFFF">has been</font> <font color="'..(toggleapi["Enabled"] and '#32CD32' or '#E60000')..'">'..(toggleapi["Enabled"] and "Enabled" or "Disabled")..'</font><font color="#FFFFFF">!', 1)
				end
			end)
			api["ObjectsThatCanBeSaved"][name] = {["Object"] = buttontext, ["Type"] = "Toggle", ["Api"] = toggleapi}
			return toggleapi
		end
		tabapi["CreateOptionsButton"] = function(name, temporaryfunction)
			local buttonapi = {
				["Enabled"] = false,
				["Name"] = name
			}
			local buttontext = Instance.new("TextButton")
			buttontext.BackgroundTransparency = 1
			buttontext.Name = name
			buttontext.Text = " "..name
			buttontext.LayoutOrder = 1
			buttontext.Size = UDim2.new(1, -12, 0, 40)
			buttontext.Position = UDim2.new(0, 6, 0, 0)
			buttontext.Active = true
			buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
			buttontext.TextSize = 17
			buttontext.Font = Enum.Font.SourceSans
			buttontext.TextXAlignment = Enum.TextXAlignment.Left
			buttontext.Parent = tabcontents
			local buttonbkg = Instance.new("Frame")
			buttonbkg.BackgroundTransparency = 0.5
			buttonbkg.BackgroundColor3 = Color3.new(0, 0, 0)
			buttonbkg.Size = UDim2.new(1, 0, 1, 0)
			buttonbkg.Parent = buttontext
			local buttonround = Instance.new("UICorner")
			buttonround.CornerRadius = UDim.new(0, 4)
			buttonround.Parent = buttonbkg
			local buttonstroke = Instance.new("UIStroke")
			buttonstroke.Thickness = 1
			buttonstroke.Color = Color3.fromRGB(60, 60, 60)
			buttonstroke.Parent = buttonbkg
			local button = Instance.new("Frame")
			button.Size = UDim2.new(0, 16, 0, 16)
			button.Active = true
			button.Position = UDim2.new(1, -22, 0, 12)
			button.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
			button.Parent = buttontext
			local buttoncorner = Instance.new("UICorner")
			buttoncorner.CornerRadius = UDim.new(0, 4)
			buttoncorner.Parent = button
			local buttonfill = Instance.new("Frame")
			buttonfill.Size = UDim2.new(0.5, 0, 1, 0)
			buttonfill.BackgroundColor3 = Color3.fromHSV(0.44, 1, 1)
			buttonfill.Parent = button
			local circle = Instance.new("Frame")
			circle.Size = UDim2.new(0, 14, 0, 14)
			circle.Position = UDim2.new(0, 1, 0, 1)
			circle.BackgroundColor3 = Color3.fromRGB(14, 15, 14)
			circle.Parent = button
			local circlecorner = Instance.new("UICorner")
			circlecorner.CornerRadius = UDim.new(1, 0)
			circlecorner.Parent = circle
			local bindbkg = Instance.new("Frame")
			bindbkg.Size = UDim2.new(0, 40, 0, 20)
			bindbkg.Position = UDim2.new(1, -66, 0, 10)
			bindbkg.BackgroundColor3 = Color3.fromRGB(36, 35, 36)
			bindbkg.Parent = buttontext
			local bindcorner = Instance.new("UICorner")
			bindcorner.CornerRadius = UDim.new(0, 4)
			bindcorner.Parent = bindbkg
			local bindstroke = Instance.new("UIStroke")
			bindstroke.Thickness = 1
			bindstroke.Color = Color3.fromRGB(60, 60, 60)
			bindstroke.Parent = bindbkg
			local bindtext = Instance.new("TextLabel")
			bindtext.BackgroundTransparency = 1
			bindtext.Text = "None"
			bindtext.Size = UDim2.new(1, 0, 1, 0)
			bindtext.TextColor3 = Color3.fromRGB(162, 162, 162)
			bindtext.TextSize = 16
			bindtext.Font = Enum.Font.SourceSans
			bindtext.Parent = bindbkg
			local bindtext2 = Instance.new("TextLabel")
			bindtext2.BackgroundTransparency = 1
			bindtext2.Text = "..."
			bindtext2.Size = UDim2.new(1, 0, 1, 0)
			bindtext2.TextColor3 = Color3.fromHSV(rainbowvalue, 1, 1)
			bindtext2.Font = Enum.Font.SourceSans
			bindtext2.TextSize = 20
			bindtext2.Visible = false
			bindtext2.Parent = bindbkg
			buttonapi["Keybind"] = "None"
			local function setcolor(enabled)
				if enabled then
					game:GetService("TweenService"):Create(buttonfill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(1, 0, 1, 0)}):Play()
					game:GetService("TweenService"):Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(1, -15, 0, 1)}):Play()
					game:GetService("TweenService"):Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromHSV(rainbowvalue, 1, 1)}):Play()
					game:GetService("TweenService"):Create(buttontext, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromHSV(rainbowvalue, 1, 1)}):Play()
				else
					game:GetService("TweenService"):Create(buttonfill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0.5, 0, 1, 0)}):Play()
					game:GetService("TweenService"):Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 1, 0, 1)}):Play()
					game:GetService("TweenService"):Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(26, 25, 26)}):Play()
					game:GetService("TweenService"):Create(buttontext, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(162, 162, 162)}):Play()
				end
			end
			setcolor(buttonapi["Enabled"])
			buttonapi["SetKeybind"] = function(key)
				buttonapi["Keybind"] = key
				bindtext.Text = key
				api["SaveSettings"]()
			end
			buttonapi["ToggleButton"] = function(state)
				buttonapi["Enabled"] = not buttonapi["Enabled"]
				if state ~= nil then buttonapi["Enabled"] = state end
				setcolor(buttonapi["Enabled"])
				if buttonapi["Enabled"] then
					if temporaryfunction then temporaryfunction() end
				end
				api["SaveSettings"]()
			end
			buttontext.MouseButton1Click:connect(function()
				buttonapi["ToggleButton"]()
				if api["ToggleNotifications"] then
					api["CreateNotification"]("Module Toggled", name..' <font color="#FFFFFF">has been</font> <font color="'..(buttonapi["Enabled"] and '#32CD32' or '#E60000')..'">'..(buttonapi["Enabled"] and "Enabled" or "Disabled")..'</font><font color="#FFFFFF">!', 1)
				end
			end)
			bindbkg.MouseButton1Click:connect(function()
				if api["KeybindCaptured"] == false then
					api["KeybindCaptured"] = true
					bindtext2.Visible = true
					local inputcon
					inputcon = game:GetService("UserInputService").InputBegan:connect(function(i)
						if i.KeyCode.Name ~= "Unknown" then
							buttonapi["SetKeybind"](i.KeyCode.Name)
							bindtext2.Visible = false
							api["KeybindCaptured"] = false
							inputcon:Disconnect()
						end
					end)
				end
			end)
			api["ObjectsThatCanBeSaved"][name] = {["Object"] = buttontext, ["Type"] = "OptionsButton", ["Api"] = buttonapi}
			return buttonapi
		end
		tabapi["CreateSlider"] = function(name, min, max, default)
			local sliderapi = {}
			local slidertext = Instance.new("TextLabel")
			slidertext.BackgroundTransparency = 1
			slidertext.Name = name
			slidertext.Text = " "..name
			slidertext.LayoutOrder = 1
			slidertext.Size = UDim2.new(1, -12, 0, 20)
			slidertext.Position = UDim2.new(0, 6, 0, 0)
			slidertext.Active = false
			slidertext.TextColor3 = Color3.fromRGB(162, 162, 162)
			slidertext.TextSize = 17
			slidertext.Font = Enum.Font.SourceSans
			slidertext.TextXAlignment = Enum.TextXAlignment.Left
			slidertext.Parent = tabcontents
			local slider = Instance.new("Frame")
			slider.Size = UDim2.new(1, -12, 0, 25)
			slider.Position = UDim2.new(0, 6, 0, 20)
			slider.BackgroundColor3 = Color3.fromRGB(36, 35, 36)
			slider.Parent = slidertext
			local slidercorner = Instance.new("UICorner")
			slidercorner.CornerRadius = UDim.new(0, 4)
			slidercorner.Parent = slider
			local sliderstroke = Instance.new("UIStroke")
			sliderstroke.Thickness = 1
			sliderstroke.Color = Color3.fromRGB(60, 60, 60)
			sliderstroke.Parent = slider
			local sliderfill = Instance.new("Frame")
			sliderfill.Name = "FillSlider"
			sliderfill.Size = UDim2.new(0, 0, 1, 0)
			sliderfill.BackgroundColor3 = Color3.fromHSV(0.44, 1, 1)
			sliderfill.Parent = slider
			local button = Instance.new("Frame")
			button.Size = UDim2.new(0, 16, 0, 16)
			button.Name = "ButtonSlider"
			button.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
			button.Position = UDim2.new(0, -8, 1, -8)
			button.Parent = slider
			local buttoncorner = Instance.new("UICorner")
			buttoncorner.CornerRadius = UDim.new(0, 4)
			buttoncorner.Parent = button
			local slidertextlabel = Instance.new("TextLabel")
			slidertextlabel.Name = "Value"
			slidertextlabel.Size = UDim2.new(1, 0, 0, 20)
			slidertextlabel.Position = UDim2.new(0, 0, 0, -20)
			slidertextlabel.Text = ""
			slidertextlabel.BackgroundTransparency = 1
			slidertextlabel.TextColor3 = Color3.fromRGB(162, 162, 162)
			slidertextlabel.TextSize = 17
			slidertextlabel.Font = Enum.Font.SourceSans
			slidertextlabel.TextXAlignment = Enum.TextXAlignment.Right
			slidertextlabel.Parent = slider
			local dragging = false
			local function update()
				local pos = RelativeXY(slider, game:GetService("UserInputService"):GetMouseLocation())
				if pos and pos < slider.AbsoluteSize.X then
					button.Position = UDim2.new(pos/slider.AbsoluteSize.X, -8, 1, -8)
					sliderfill.Size = UDim2.new(pos/slider.AbsoluteSize.X, 0, 1, 0)
					local value = math.floor((min + (pos/slider.AbsoluteSize.X) * (max - min)) * 100) / 100
					sliderapi["Value"] = value
					slidertextlabel.Text = value
				end
			end
			local function setvalue(val)
				sliderapi["Value"] = val
				local percentage = (val - min) / (max - min)
				sliderfill.Size = UDim2.new(percentage, 0, 1, 0)
				button.Position = UDim2.new(percentage, -8, 1, -8)
				slidertextlabel.Text = val
			end
			setvalue(default or min)
			button.MouseButton1Down:connect(function()
				dragging = true
			end)
			game:GetService("UserInputService").InputEnded:connect(function(input, processed)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			game:GetService("UserInputService").InputChanged:connect(function(input, processed)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					if dragging and not processed then
						update()
					end
				end
			end)
			sliderapi["SetValue"] = setvalue
			api["ObjectsThatCanBeSaved"][name] = {["Type"] = "Slider", ["Object"] = slidertext, [
			return sliderapi
		end

		button.MouseButton1Click:connect(function() buttonapi["ToggleButton"](true) end)
		button2.MouseButton1Click:connect(function() buttonapi["ExpandToggle"]() end)
		button.MouseEnter:connect(function() 
			if not buttonapi["Enabled"] then
				game:GetService("TweenService"):Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(31, 30, 31)}):Play()
			end
		end)
		button.MouseLeave:connect(function() 
			if not buttonapi["Enabled"] then
				game:GetService("TweenService"):Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(26, 25, 26)}):Play()
			end
		end)
		bindbkg.MouseButton1Click:connect(function()
			if api["KeybindCaptured"] == false then
				api["KeybindCaptured"] = true
				bindtext2.Visible = true
				local inputcon
				inputcon = game:GetService("UserInputService").InputBegan:connect(function(i)
					if i.KeyCode.Name ~= "Unknown" then
						buttonapi["SetKeybind"](i.KeyCode.Name)
						bindtext2.Visible = false
						api["KeybindCaptured"] = false
						inputcon:Disconnect()
					end
				end)
			end
		end)
		bindbkg.MouseButton2Click:connect(function()
			buttonapi["SetKeybind"]("")
		end)
		api["ObjectsThatCanBeSaved"][naame.."OptionsButton"] = {["Type"] = "OptionsButton", ["Object"] = button, ["Api"] = buttonapi}
		return buttonapi
	end

	return windowapi
end

return api
