--[[By: @V3N0M_Z]]
local inheritance = require(script.Parent.Node)
local node = {}
node.__index = node
setmetatable(node, inheritance)

function node.new(plugin, pluginDisplay, id)
	local self = setmetatable(inheritance.new("ChoiceNode", plugin, pluginDisplay, id), node)
	
	self._settings = {
		title = function(txt) self._frame.Title.Text = txt end;
		text = function(txt) self._frame.Display.Text = txt end;
		choices = function(choices)
			self._frame.Option1.TextLabel.Text = choices[1][2]
			self._frame.Option1.TextLabel.Name = choices[1][1]
			self._frame.Option2.TextLabel.Text = choices[2][2]
			self._frame.Option2.TextLabel.Name = choices[2][1]
		end;
	}
	self:SetSelectionComponents()
	self:Transition(1, true, nil, true)
	self._frame.Parent = pluginDisplay
	self:Forge({})
	self:CreateImposter()
	
	return self
end

local selectionService = game:GetService("Selection")
function node:ParseInput(enterPressed)
	if enterPressed then
		return {self._frame["Option"..tostring(self._selectionIndex)]:FindFirstChildOfClass("TextLabel").Name}
	end
	return {}
end

function node:UpdateSelection()
	if self._currentSelection then
		self._currentSelection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		self._currentSelection = nil
	end
	self._selectionIndex = math.clamp(self._selectionIndex, 1, 2)
	self._currentSelection = self._frame["Option"..tostring(self._selectionIndex)]
	self._currentSelection.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
end

function node:SetSelectionComponents()
	local frame = self._frame
	self._selection = {self._frame.Option1, self._frame.Option2}
	for _, obj in ipairs(self._selection) do
		obj.MouseButton1Click:Connect(function()
			self._selectionIndex = tonumber(string.sub(obj.Name, 7, 7))
			self:Destroy(true)
		end)
	end
end

return node