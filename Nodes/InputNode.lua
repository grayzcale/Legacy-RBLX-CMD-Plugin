--[[By: @V3N0M_Z]]
local inheritance = require(script.Parent.Node)
local node = {}
node.__index = node
setmetatable(node, inheritance)

function node.new(plugin, pluginDisplay, id)
	local self = setmetatable(inheritance.new("InputNode", plugin, pluginDisplay, id), node)
	
	self._settings = {
		title = function(txt) self._frame.Title.Text = txt end;
		placeholder = function(txt) self._input.PlaceholderText = txt end;
		ignoreCase = function(enabled)
			if not enabled then
				self._frame.IgnoreCase:Destroy()
				self._frame.IgnoreCaseLabel:Destroy()
				self._frame.Size = self._frame.Size + UDim2.new(0, 0, 0, -33)
				self._ignoreCase = nil
			end
		end;
		default = function(txt)
			task.delay(0.1, function()
				self._input.Text = txt
				self._input.CursorPosition = string.len(txt) + 1
			end)				
		end;
	}
	self:Transition(1, true, nil, true)
	self._frame.Parent = pluginDisplay
	self:Forge({})
	
	return self
end

local selectionService = game:GetService("Selection")
function node:ParseInput(enterPressed)
	if enterPressed then
		return {self._input.Text, (self._ignoreCase and self._ignoreCase.Visible)}
	end
	return {}
end

return node