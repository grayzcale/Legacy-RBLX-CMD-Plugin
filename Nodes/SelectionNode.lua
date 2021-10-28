--[[By: @V3N0M_Z]]
local inheritance = require(script.Parent.Node)
local node = {}
node.__index = node
setmetatable(node, inheritance)

function node.new(plugin, pluginDisplay, id)
	local self = setmetatable(inheritance.new("SelectionNode", plugin, pluginDisplay, id), node)
	
	self._settings = {
		title = function(txt) self._frame.Title.Text = txt end;
		placeholder = function(txt) self._input.PlaceholderText = txt end;
		ignoreCase = function(enabled)
			if not enabled then
				self._frame.IgnoreCase:Destroy()
				self._frame.IgnoreCaseLabel:Destroy()
				self._frame.Size = self._frame.Size + UDim2.new(0, 0, 0, -25)
				self._ignoreCase = nil
			end
		end;
	}
	self:SetSelectionComponents()
	self:Transition(1, true, nil, true)
	self._frame.Parent = pluginDisplay
	self:Forge({
		self._input:GetPropertyChangedSignal("Text"):Connect(function()
			self._selectionIndex = nil
			self:UpdateSelection()
		end)
	})
	
	return self
end

function node:UpdateSelection()
	if not self._selectionIndex then
		self._currentSelection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	else
		self._currentSelection.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
	end
end

local selectionService = game:GetService("Selection")
function node:ParseInput(enterPressed)
	if enterPressed and not self._selectionIndex then
		local children = {}
		for _, obj in ipairs(game:GetDescendants()) do
			if obj.Name == self._input.Text or (self._ignoreCase and self._ignoreCase.Visible and string.lower(obj.Name) == string.lower(self._input.Text)) then
				table.insert(children, obj)
			end
		end
		selectionService:Set(children)
		local selection = selectionService:Get()
		return {selectionService:Get(), (self._ignoreCase and self._ignoreCase.Visible)}
	elseif enterPressed and self._selectionIndex then
		return {selectionService:Get(), (self._ignoreCase and self._ignoreCase.Visible)}
	end
	return {}
end

function node:SetSelectionComponents()
	self._selection = true
	self._currentSelection = self._frame.FromSelection
	self._frame.FromSelection.MouseButton1Click:Connect(function()
		self._selectionIndex = 1
		self:Destroy(true)
	end)
end

return node