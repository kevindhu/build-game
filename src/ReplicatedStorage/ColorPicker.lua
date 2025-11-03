-- Color Picker Module

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Common = require(game.ReplicatedStorage:WaitForChild("Common"))

local Color = {}
Color.__index = Color

local DefaultColorWindow = game.ReplicatedStorage:WaitForChild("ColorWindow")

export type ParameterStyle = {
	Color: Color3?,
	Transparency: number?,
}

export type Parameters = {
	Position: UDim2?,
	RoundedCorners: number?,
	Draggable: boolean?,
	ZIndex: number?,
	Size: number?,

	Primary: ParameterStyle?,
	Secondary: ParameterStyle?,
	Topbar: ParameterStyle?,
	Text: ParameterStyle?,
}

-- Convert vector to polar coordinates
function toPolar(v)
	return math.atan2(v.Y, v.X), v.Magnitude
end

-- Convert radians to degrees (normalized to 0-360 range)
function radToDeg(x)
	return ((x + math.pi) / (2 * math.pi)) * 360
end

-- Get position and normal vector for a SurfaceGui
function getScreenGuiWorldDetails(gui)
	local part = gui.Parent
	local position = part.Position
	local size = part.Size
	local cframe = part.CFrame
	local lookVector = cframe.LookVector
	local rightVector = cframe.RightVector
	local upVector = cframe.UpVector

	-- Map each face to its corresponding vector and offset calculation
	local faceMap = {
		[Enum.NormalId.Front] = { vector = lookVector, offsetMult = size.Z / 2, sign = 1 },
		[Enum.NormalId.Back] = { vector = lookVector, offsetMult = size.Z / 2, sign = -1 },
		[Enum.NormalId.Right] = { vector = rightVector, offsetMult = size.X / 2, sign = 1 },
		[Enum.NormalId.Left] = { vector = rightVector, offsetMult = size.X / 2, sign = -1 },
		[Enum.NormalId.Top] = { vector = upVector, offsetMult = size.Y / 2, sign = 1 },
		[Enum.NormalId.Bottom] = { vector = upVector, offsetMult = size.Y / 2, sign = -1 },
	}

	local faceData = faceMap[gui.Face]
	if faceData then
		local offset = faceData.vector * (faceData.offsetMult * faceData.sign)
		return position + offset, faceData.vector * faceData.sign
	end
end

-- Apply template values to a table, with nested table support
function template(tab, t)
	tab = (tab and (typeof(tab) == "table")) and tab or {}
	for i, v in pairs(t) do
		if tab[i] == nil or (typeof(v) == "table") then
			tab[i] = (typeof(v) == "table") and template(tab[i] or {}, v) or v
		end
	end

	return tab
end

-- Round a number to two decimal places
function roundToHundredths(num)
	return math.round(num * 100) / 100
end

-- Create a new color picker
function Color.New(gui: LayerCollector, params: Parameters?)
	if gui:IsA("SurfaceGui") then
		assert(
			gui.Face == Enum.NormalId.Front,
			"Color Picker - SurfaceGui must have its Face property set to 'Front' to work properly"
		)
	end

	params = template(params, {
		Position = UDim2.fromScale(0.2, 0.3),
		RoundedCorners = true,
		Draggable = true,
		ZIndex = 1,
		Size = 0.4,

		Primary = { Color = Color3.fromRGB(26, 26, 36), Transparency = 0 },
		Secondary = { Color = Color3.fromRGB(36, 36, 46), Transparency = 0 },
		Topbar = { Color = Color3.fromRGB(21, 21, 31), Transparency = 0 },
		Text = { Color = Color3.fromRGB(255, 255, 255), Transparency = 0 },
	})

	local self = setmetatable({}, Color)
	self.Params = params
	self.Gui = gui
	self.Connections = {}

	self:Create()
	self:SetColor(Color3.fromRGB(255, 255, 255))

	return self
end

function Color:Create()
	-- Create sample
	local sample = DefaultColorWindow:Clone()
	sample.Position = self.Params.Position
	sample.Size = UDim2.fromScale(self.Params.Size, self.Params.Size)
	sample.ZIndex = self.Params.ZIndex
	sample.Parent = self.Gui
	sample.Visible = true

	-- Setup drag functionality
	if self.Params.Draggable then
		sample.Topbar.Button.MouseButton1Down:Connect(function()
			local startMousePos = self:GetMousePos() or Vector2.zero
			local startWindowPos = self.Instance.Position
			self._dragFunc = RunService.Heartbeat:Connect(function()
				local pos = ((self:GetMousePos() or Vector2.zero) - startMousePos)
				self.Instance.Position = startWindowPos + UDim2.fromOffset(pos.X, pos.Y)
			end)
		end)
	end

	-- Events
	self.Updated = sample.UpdateEvent.Event
	self.Finished = sample.FinishedEvent.Event
	self.Canceled = sample.CanceledEvent.Event
	self.Cancelled = sample.CanceledEvent.Event -- Alternative spelling

	-- Update visual color and transparency
	local function _updateVisual(tab, params)
		for i, v in pairs(tab) do
			for q, e in pairs(params) do
				v[q] = e
			end
		end
	end

	_updateVisual(
		{ sample.Content.Background.Top, sample.Content.Background.Bottom.Frame, sample.Properties },
		{ BackgroundColor3 = self.Params.Primary.Color, BackgroundTransparency = self.Params.Primary.Transparency }
	)

	_updateVisual(
		{ sample.Properties.Line, sample.Content.Bottom.Hex.Frame },
		{ BackgroundColor3 = self.Params.Secondary.Color, BackgroundTransparency = self.Params.Secondary.Transparency }
	)

	_updateVisual(
		{ sample.Topbar.Frame, sample.Topbar.Top.Frame },
		{ BackgroundColor3 = self.Params.Topbar.Color, BackgroundTransparency = self.Params.Topbar.Transparency }
	)

	-- Update property fields
	for i, v in pairs({ sample.Properties.HSV, sample.Properties.RGB }) do
		for q, e in pairs(v:GetChildren()) do
			if e:IsA("Frame") then
				e.Frame.BackgroundColor3 = self.Params.Secondary.Color
				e.Frame.BackgroundTransparency = self.Params.Secondary.Transparency
			end
		end
	end

	-- Handle rounded corners and text colors
	for i, v in pairs(sample:GetDescendants()) do
		if not self.Params.RoundedCorners and v:IsA("UICorner") and v.Parent.Name ~= "Select" then
			v:Destroy()
		end

		if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("ImageButton") then
			v[(v:IsA("TextLabel") or v:IsA("TextBox")) and "TextColor3" or "ImageColor3"] = self.Params.Text.Color
			v[(v:IsA("TextLabel") or v:IsA("TextBox")) and "TextTransparency" or "ImageTransparency"] =
				self.Params.Text.Transparency
		end
	end

	-- Track which control is currently active
	self.activeControl = nil

	-- Setup color wheel interaction
	local wheel = sample.Content.Wheel
	self.Connections.wheelMainUpdate = wheel.Button.InputBegan:Connect(function(input)
		if Common.listContains(Common.clickInputTypes, input.UserInputType) then
			-- If another control is active, ignore this input
			if self.activeControl and self.activeControl ~= "wheel" then
				return
			end

			self.activeControl = "wheel"

			if self.Gui:IsA("PluginGui") then
				sample.Button.Visible = true
			end

			self.Connections.wheelReposition = RunService.Heartbeat:Connect(function()
				local mousePos = self:GetMousePos()
				if mousePos and wheel and wheel:FindFirstChild("Image") and wheel.Image:FindFirstChild("Select") then
					local wheelMid = wheel.Image.AbsolutePosition + wheel.Image.AbsoluteSize / 2
					local toWheelMid = (mousePos - wheelMid) / wheel.Image.AbsoluteSize
					if toWheelMid.Magnitude > 0.5 then
						toWheelMid = toWheelMid.Unit / 2
					end

					wheel.Image.Select.Position = UDim2.fromScale(0.5 + toWheelMid.X, 0.5 + toWheelMid.Y)

					local phi, len = toPolar(toWheelMid * Vector2.new(1, -1))
					local hue, saturation = math.clamp(radToDeg(phi) / 360, 0, 1), math.clamp(len * 2, 0, 1)

					self.Saturation = saturation
					self.Hue = hue

					self:UpdateColorVisual()
				end
			end)
		end
	end)

	-- Setup value slider interaction
	local valueSlider = sample.Content.Right.Value
	self.Connections.valueMainUpdate = valueSlider.Button.InputBegan:Connect(function(input)
		if Common.listContains(Common.clickInputTypes, input.UserInputType) then
			-- If another control is active, ignore this input
			if self.activeControl and self.activeControl ~= "value" then
				return
			end

			self.activeControl = "value"

			if self.Gui:IsA("PluginGui") then
				sample.Button.Visible = true
			end

			self.Connections.valueReposition = RunService.Heartbeat:Connect(function()
				local mousePos = self:GetMousePos()
				if mousePos and valueSlider and valueSlider:FindFirstChild("Select") then
					local valueTop = valueSlider.AbsolutePosition

					local v = 1 - math.clamp((mousePos.Y - valueTop.Y) / valueSlider.AbsoluteSize.Y, 0, 1)
					self.Value = v

					valueSlider.Select.Position = UDim2.fromScale(0, 1 - v)
					self:UpdateColorVisual()
				end
			end)
		end
	end)

	-- Handle mouse up events
	local function _mouseUpEvent()
		sample.Button.Visible = false

		-- Reset active control
		self.activeControl = nil

		if self.Connections.wheelReposition then
			self.Connections.wheelReposition:Disconnect()
			self.Connections.wheelReposition = nil
		end

		if self.Connections.valueReposition then
			self.Connections.valueReposition:Disconnect()
			self.Connections.valueReposition = nil
		end

		if self._dragFunc then
			self._dragFunc:Disconnect()
			self._dragFunc = nil
		end
	end

	if not self.Gui:IsA("PluginGui") then
		self.Connections.inputEnded = UserInputService.InputEnded:Connect(function(input)
			if Common.listContains(Common.clickInputTypes, input.UserInputType) then
				_mouseUpEvent()
			end
		end)
	else
		self.Connections.inputEnded = sample.Button.MouseButton1Up:Connect(_mouseUpEvent)
		self.Connections.inputEnded2 = self.Gui.WindowFocusReleased:Connect(_mouseUpEvent)
	end

	-- Handle hex input
	sample.Content.Bottom.Hex.Frame.TextBox.FocusLost:Connect(function()
		local hexText = sample.Content.Bottom.Hex.Frame.TextBox.Text
		local success, color = pcall(function()
			return Color3.fromHex(hexText)
		end)
		sample.Content.Bottom.Hex.Frame.InvalidStroke.Enabled = not success

		if not success then
			warn(string.format("%s is not a valid hex color.", hexText))
			return
		end

		self:SetColor(color)
	end)

	-- Handle RGB input
	local rgbProperties = sample.Properties.RGB
	for _, frame in pairs(rgbProperties:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		frame.Frame.TextBox.FocusLost:Connect(function()
			-- Cache text box references
			local rTextBox = rgbProperties.R.Frame.TextBox
			local gTextBox = rgbProperties.G.Frame.TextBox
			local bTextBox = rgbProperties.B.Frame.TextBox

			-- Parse and clamp RGB values
			local r = math.clamp(tonumber(rTextBox.Text) or 255, 0, 255)
			local g = math.clamp(tonumber(gTextBox.Text) or 255, 0, 255)
			local b = math.clamp(tonumber(bTextBox.Text) or 255, 0, 255)

			self:SetColor(Color3.fromRGB(r, g, b))
		end)
	end

	-- Handle HSV input
	local hsvProperties = sample.Properties.HSV
	for _, frame in pairs(hsvProperties:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		frame.Frame.TextBox.FocusLost:Connect(function()
			-- Cache text box references
			local hTextBox = hsvProperties.H.Frame.TextBox
			local sTextBox = hsvProperties.S.Frame.TextBox
			local vTextBox = hsvProperties.V.Frame.TextBox

			-- Parse and clamp HSV values
			local h = math.clamp(tonumber(hTextBox.Text) or 0, 0, 360) / 360
			local s = math.clamp(tonumber(sTextBox.Text) or 1, 0, 1)
			local v = math.clamp(tonumber(vTextBox.Text) or 1, 0, 1)

			self:SetColor(Color3.fromHSV(h, s, v))
		end)
	end

	-- Setup confirm and cancel buttons
	sample.Content.Bottom.Buttons.Confirm.InputBegan:Connect(function(input)
		if Common.listContains(Common.clickInputTypes, input.UserInputType) then
			sample.FinishedEvent:Fire(Color3.fromHSV(self.Hue, self.Saturation, self.Value))
			self:Destroy()
		end
	end)

	sample.Content.Bottom.Buttons.Cancel.InputBegan:Connect(function(input)
		if Common.listContains(Common.clickInputTypes, input.UserInputType) then
			sample.CanceledEvent:Fire()
			self:Destroy()
		end
	end)

	self.Instance = sample
	return sample
end

-- Return the mouse position of the player relative to the parent GUI
function Color:GetMousePos()
	local mousePos = UserInputService:GetMouseLocation()
	if self.Gui:IsA("ScreenGui") then
		local topbarSize = GuiService.TopbarInset.Height
		return mousePos - Vector2.new(0, topbarSize)
	elseif self.Gui:IsA("PluginGui") then
		return self.Gui:GetRelativeMousePosition()
	else
		-- Find the intersection point of the mouse ray and SurfaceGui plane
		local ray = game.Workspace.CurrentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)
		local planePoint, planeNormal = getScreenGuiWorldDetails(self.Gui)

		local p = -((ray.Origin - planePoint):Dot(planeNormal)) / (ray.Direction:Dot(planeNormal))
		local mouseHit = ray.Origin + ray.Direction * p

		local relative = (-self.Gui.Parent.CFrame:PointToObjectSpace(mouseHit) + self.Gui.Parent.Size / 2)
			* self.Gui.PixelsPerStud
		return Vector2.new(relative.X, relative.Y)
	end
end

-- Updates the properties and color preview
function Color:UpdateColorVisual()
	if not self.Instance then
		return
	end

	local instance = self.Instance
	local color = Color3.fromHSV(self.Hue, self.Saturation, self.Value)

	-- Fire update event
	instance.UpdateEvent:Fire(color)

	-- Cache frequently accessed paths
	local content = instance.Content
	local properties = instance.Properties

	-- Update gradient
	content.Right.Value.UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(self.Hue, self.Saturation, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
	})

	-- Update color preview and hex input
	content.Bottom.Color.Frame.BackgroundColor3 = color
	content.Bottom.Hex.Frame.TextBox.Text = string.format("#%s", color:ToHex())
	content.Bottom.Hex.Frame.InvalidStroke.Enabled = false

	-- Update RGB values
	local rgbValues = {
		R = math.floor(color.R * 255),
		G = math.floor(color.G * 255),
		B = math.floor(color.B * 255),
	}

	for channel, value in pairs(rgbValues) do
		properties.RGB[channel].Frame.TextBox.Text = value
	end

	-- Update HSV values
	local hsvValues = {
		H = math.floor(self.Hue * 360),
		S = roundToHundredths(self.Saturation),
		V = roundToHundredths(self.Value),
	}

	for channel, value in pairs(hsvValues) do
		properties.HSV[channel].Frame.TextBox.Text = value
	end
end

-- Sets the color and repositions the wheel and value sliders
function Color:SetColor(c: Color3)
	if self.Instance then
		local h, s, v = c:ToHSV()
		self.Saturation = s
		self.Value = v
		self.Hue = h

		local h2 = h * math.pi * 2
		local wv = Vector2.new(-math.cos(h2) / 2 * s, math.sin(h2) / 2 * s)
		self.Instance.Content.Wheel.Image.Select.Position = UDim2.fromScale(0.5 + wv.X, 0.5 + wv.Y)
		self.Instance.Content.Right.Value.Select.Position = UDim2.fromScale(0, 1 - v)

		self:UpdateColorVisual()
	end
end

-- Disconnects all current connections and destroys the window
function Color:Destroy()
	for _, v in pairs(self.Connections) do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
		end
	end

	if self._dragFunc then
		self._dragFunc:Disconnect()
		self._dragFunc = nil
	end

	if self.Instance then
		self.Instance:Destroy()
		self.Instance = nil
	end
end

return Color
