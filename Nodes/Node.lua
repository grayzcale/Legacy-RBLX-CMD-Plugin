--[[By: @V3N0M_Z]]
local userInputService = game:GetService("UserInputService")
local coreGui = game:GetService("CoreGui")
local tweenService = game:GetService("TweenService")
local search = require(script.Parent.Parent.Search)
local node = {}
node.__index = node

local inputKeys = {
	"LeftShift";
	"RightShift";
	"Up";
	"Down";
}

local function adjust(frame)
	local mouseLocation = userInputService:GetMouseLocation()
	local mouseX, mouseY = mouseLocation.X, mouseLocation.Y
	local viewportX, viewportY = workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y
	local sizeX, sizeY = frame.AbsoluteSize.X, frame.AbsoluteSize.Y
	local hFactor, vFactor = 0, 0
	local offsetX, offsetY = 30, 0
	if mouseX + sizeX + offsetX > viewportX then
		hFactor = 1
		offsetX *= -1
	elseif mouseX <= viewportX / 2 and mouseX - sizeX - offsetX >= 0 then
		hFactor = 1
		offsetX *= -1
	end
	if mouseY + sizeY + offsetY > viewportY then
		vFactor = 1	
		offsetY *= -1
	end
	frame.Position = UDim2.new(0, mouseX - (sizeX * hFactor) + offsetX, 0, mouseY - (sizeY * vFactor) + offsetY)
end

function node:Get()
	while self._parsedInput == nil do
		task.wait()
	end
	return table.unpack(self._parsedInput)
end

function node:Set(data)
	for key, value in pairs(data) do
		self._settings[key](value)
	end
	return self
end

function node:Destroy(enterPressed, checkUI)
	if self._destroyed or os.clock() - self._birth < 0.1 then return end
	self._destroyed = true

	if checkUI then
		for _, guiObj in ipairs(coreGui:GetGuiObjectsAtPosition(userInputService:GetMouseLocation().X, userInputService:GetMouseLocation().Y)) do
			if guiObj:FindFirstAncestor(self._frame.Name) or guiObj.Name == self._frame.Name then
				self._destroyed = false
				return
			end
		end
	end
	
	local input, nodeType = self:ParseInput(enterPressed), self._frame.Name
	
	for i = 1, #self._connections do
		if self._connections[i] and self._connections[i].Connected then
			self._connections[i]:Disconnect()
		end
	end
	self:Transition(1, nil, true, nil)
	self._frame:Destroy()
	for _, key in ipairs(self) do
		self[key] = (key == "_provocations" and self[key]) or nil
	end
	self._provocations.Destroyed:Invoke(nodeType, table.unpack(input))
	for _, provocation in ipairs(self._provocations) do
		provocation:Destroy()
	end
	self._provocations = nil
	self._parsedInput = input
end

function node:Reveal(parent)
	adjust(self._frame)
	if self._frame.Name ~= "ListNode" then self:Transition(0) end
end

local function validateChar(input)
	local code = input.KeyCode.Value
	return (code >= 32 and code <= 126) or (code >= 145 and code <= 152)
end

function node.new(type, plugin, pluginDisplay, id)
	
	local self = setmetatable({
		_id = id;
		_plugin = plugin;
		_frame = script.Parent.Parent.Interface[type]:Clone();
		_search = search.new();
		_pluginDisplay = pluginDisplay;
		_birth = os.clock();
		_provocations = {
			Destroyed = Instance.new("BindableFunction");
		};
	}, node)
	
	self._input = self._frame:FindFirstChildWhichIsA("TextBox", true)	
	self._ignoreCase = self._frame:FindFirstChild("IgnoreCase") and self._frame:FindFirstChild("IgnoreCase").Dot
	if self._ignoreCase then
		self._ignoreCase.Visible = plugin:GetSetting(id)
	end
	
	return self
end

function node:Forge(events)
	self._connections = {		
		(self._input and self._input.FocusLost:Connect(function(enterPressed)
			self:Destroy(enterPressed, not enterPressed)
		end));

		self._pluginDisplay.Imposter.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then
				self._inputCaptured = false
			end
		end);

		--self._pluginDisplay.Imposter.MouseLeave:Connect(function()
		--	self:Destroy()
		--end);
		
		(self._ignoreCase and self._frame.IgnoreCase.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self._ignoreCase.Visible = not self._ignoreCase.Visible
				self._plugin:SetSetting(self._id, self._ignoreCase.Visible)
				if self._input then
					self._input:CaptureFocus()
				end
			end
		end));
		
		(self._ignoreCase and self._frame.IgnoreCaseLabel.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				self._ignoreCase.Visible = not self._ignoreCase.Visible
				self._plugin:SetSetting(self._id, self._ignoreCase.Visible)
				if self._input then
					self._input:CaptureFocus()
				end
			end
		end));

		--self._pluginDisplay.Imposter.MouseMoved:Connect(function()
		--	if self._destroyed then return end
		--	local nodePosX, nodePosY = self._frame.AbsolutePosition.X, self._frame.AbsolutePosition.Y
		--	local nodeSizeX, nodeSizeY = self._frame.AbsoluteSize.X, self._frame.AbsoluteSize.Y
		--	local mouseLocation = userInputService:GetMouseLocation()
		--	local mouseX, mouseY = mouseLocation.X, mouseLocation.Y
		--	local magnitude = (Vector2.new(nodePosX + (nodeSizeX / 2), nodePosY + (nodeSizeY / 2)) - Vector2.new(mouseX, mouseY)).Magnitude
		--	if magnitude > (math.sqrt(nodeSizeX^2 + nodeSizeY^2) / 2) + 75 then
		--		self:Destroy()
		--	end
		--end);

		userInputService.InputBegan:Connect(function(input, GPE)
			if self._destroyed then return end
			
			if self._selection and (input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down) then
				if not self._selectionIndex then
					self._selectionIndex = 1
				else
					self._selectionIndex += (input.KeyCode == Enum.KeyCode.Up and -1) or 1
				end
				self:UpdateSelection()
			end

			if self._input and (validateChar(input) or table.find(inputKeys, input.KeyCode.Name)) then
				self._inputCaptured = true
				self._input:CaptureFocus()
			elseif self._imposter and table.find({"Up", "Down"}, input.KeyCode.Name) then
				self._inputCaptured = true
				self._imposter:CaptureFocus()
			elseif not self._inputCaptured and input.UserInputType ~= Enum.UserInputType.MouseMovement then
				self:Destroy(nil, true)
			end
		end);
	}
	
	for _, event in ipairs(events) do table.insert(self._connections, event) end
	
	if self._input then
		self._input:CaptureFocus()
		self._inputCaptured = true
	end
end

function node:CreateImposter()
	self._imposter = Instance.new("TextBox")
	self._imposter.Size = UDim2.new(0, 0, 0, 0)
	self._imposter.Text = ''
	self._imposter.BackgroundTransparency = 1
	self._imposter.Parent = self._frame
	table.insert(self._connections, self._imposter.FocusLost:Connect(function(enterPressed)
		self:Destroy(enterPressed, not enterPressed)
	end))
end

function node:Transition(transparency, noWait, waitUntil, noTween)
	local function tween(obj, ...)
		if noTween then
			for property, value in pairs(...) do
				obj[property] = value
			end
			return
		end
		local tweenBase = tweenService:Create(obj, TweenInfo.new((noWait and 0) or (transparency == 1 and 0.1) or 0.3), ...)
		tweenBase:Play()
		return tweenBase
	end
	for _, guiObj in ipairs(self._frame:GetDescendants()) do
		if guiObj:IsA("GuiObject") and guiObj:GetAttribute("Exclusion") ~= "BackgroundTransparency" then
			tween(guiObj, {BackgroundTransparency = transparency})
		end
		if (guiObj:IsA("TextLabel") or guiObj:IsA("TextBox") or guiObj:IsA("TextButton")) and guiObj:GetAttribute("Exclusion") ~= "TextTransparency" then
			tween(guiObj, {TextTransparency = transparency})
		elseif (guiObj:IsA("ImageLabel") or guiObj:IsA("ImageButton")) and guiObj:GetAttribute("Exclusion") ~= "ImageTransparency" then
			tween(guiObj, {ImageTransparency = transparency})
		elseif guiObj:IsA("UIStroke") then
			tween(guiObj, {Transparency = transparency})
		elseif guiObj:IsA("ScrollingFrame") then
			tween(guiObj, {ScrollBarImageTransparency = transparency, BorderSizePixel = (transparency == 1 and 0) or 5})
		end
	end
	local tweenBase = tween(self._frame, {BackgroundTransparency = transparency})
	if waitUntil then
		tweenBase.Completed:Wait()
	end
end

return node