--[[By: @V3N0M_Z]]
local tweenService = game:GetService("TweenService")
local inheritance = require(script.Parent.Node)
local node = {}
node.__index = node
setmetatable(node, inheritance)

function node.new(plugin, pluginDisplay, id)
	local self = setmetatable(inheritance.new("ListNode", plugin, pluginDisplay, id), node)
	
	self._settings = {
		title = function(txt) self._frame.Title.Text = txt end;
		list = function(list) self._list = list end;
		placeholder = function(txt) self._input.PlaceholderText = txt end;
	}
	self:Transition(1, true, nil, true)
	self._frame.Parent = pluginDisplay
	self:Forge({
		self._input:GetPropertyChangedSignal("Text"):Connect(function()
			for _, selection in ipairs(self._selection) do
				selection.Parent = nil
			end
			local results = self._search:Search(self._input.Text)
			if self._input.Text ~= "" then
				for _, result in ipairs(results) do
					self._selection[table.find(self._selection, result)].Parent = self._frame.List
				end
			else
				for _, selection in ipairs(self._selection) do
					selection.Parent = self._frame.List
				end
			end
			self._selectionIndex = 1
			self:UpdateSelection()
		end)
	})
	
	return self
end

function node:Set(data)
	for key, value in pairs(data) do
		self._settings[key](value)
	end
	self:SetSelectionComponents()
	self:Transition(0)
	return self
end

function node:ParseInput(enterPressed)
	if enterPressed and self._selectionIndex and #self._frame.List:GetChildren() > 1 then
		return {self._frame.List:GetChildren()[self._selectionIndex + 1].Name}
	end
	return {}
end

function node:UpdateSelection()
	if self._currentSelection then
		self._currentSelection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		self._currentSelection = nil
	end
	if #self._frame.List:GetChildren() > 1 then
		self._selectionIndex = math.clamp(self._selectionIndex, 1, #self._frame.List:GetChildren() - 1)
		self._currentSelection = self._frame.List:GetChildren()[self._selectionIndex + 1]
		self._currentSelection.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
		
		if self._currentSelection.AbsolutePosition.Y + self._currentSelection.AbsoluteSize.Y > self._frame.List.AbsolutePosition.Y + self._frame.List.AbsoluteSize.Y then
			tweenService:Create(self._frame.List, TweenInfo.new(.3), {CanvasPosition = Vector2.new(0, (23 * self._selectionIndex) - 150)}):Play()
		elseif self._currentSelection.AbsolutePosition.Y < self._frame.List.AbsolutePosition.Y then
			tweenService:Create(self._frame.List, TweenInfo.new(.3), {CanvasPosition = Vector2.new(0, (23 * (self._selectionIndex + 5)) - 150)}):Play()
		end
	end
end

function node:SetSelectionComponents()
	local frame = self._frame
	self._selection = {}
	for _, list in ipairs(self._list) do
		local value, icon, iconColor = table.unpack(list)
		local clone = frame.Template:Clone()
		clone.Name = value
		clone.Display.Text = value
		clone.Parent = frame.List
		clone.Visible = true
		if icon == true then
			clone.Icon.Visible = true
			if iconColor then
				clone.Icon.ImageColor3 = iconColor
			end
		end
		self._search:Include(clone)
		table.insert(self._selection, clone)
		clone.MouseButton1Down:Connect(function()
			self._selectionIndex = table.find(self._frame.List:GetChildren(), clone) - 1
			self:Destroy(true)
		end)
	end
end

return node