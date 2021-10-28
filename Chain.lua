--[[By: @V3N0M_Z]]
local serverStorage = game:GetService("ServerStorage")
local chain = {}
chain.__index = chain

local function addCommands(self, source)
	for _, commandModule in ipairs(source:GetChildren()) do
		local commandData 
		local success,err = pcall(function() commandData = require(commandModule) end)
		if err then 
			warn("[CMD]: "..commandModule.Name.." errored")
			task.spawn(function()
				error(err)
			end)
			continue
		end
		if type(commandData) == "table" then
			if type(commandData.metadata) == "table" then
				if type(commandData.metadata.id) ~= "string" then
					warn("[CMD+]: "..commandModule.Name..".metadata.id must be a string, got "..type(commandData.metadata.id))
					continue
				end
				if type(commandData.metadata.display) ~= "string" then
					warn("[CMD+]: "..commandModule.Name..".metadata.display must be a string, got "..type(commandData.metadata.display))
					continue
				end
				if type(commandData.metadata.inputRequired) ~= "boolean" then
					warn("[CMD+]: "..commandModule.Name..".metadata.inputRequired must be a boolean, got "..type(commandData.metadata.inputRequired))
					continue
				end
			else
				warn("[CMD+]: "..commandModule.Name..".metadata must be a table, got "..type(commandData.metadata))
				continue
			end
		else
			warn("[CMD+]: "..commandModule.Name.." must return a table, got "..type(commandData))
			continue
		end
		self._commands[commandData.metadata.id] = commandData
	end
	return self
end

function chain:Node(type)
	if self._node or (self._restricted and type == "CommandNode") then return end
	
	self._node = require(script.Parent.Nodes[type]).new(self._plugin, self._display, (self._id and "Node"..tostring(self._count).."Of"..self._id))
	self._node:Reveal()
	
	self._node._provocations.Destroyed.OnInvoke = function(nodeType, input)
		self._node = nil
		if input then
			if nodeType == "CommandNode" then
				self._id = self._commands[input].metadata.id
				self._count += 1
				local success, err = pcall(function() self._commands[input].execute(self) end)
				self:Dispose()
				if not success then
					error(err)
				end
			end
		elseif not input and nodeType == "CommandNode" then
			self:Dispose()
		end
	end
	
	return self._node
end

function chain:Dispose()
	if self._disposed then return end
	self._disposed = true	
	
	if self._node then
		self._node:Destroy()
	end
	
	self._provocations.Destroyed:Invoke()
	for _, provocation in ipairs(self._provocations) do
		provocation:Destroy()
	end
	for _, key in ipairs(self) do
		self[key] = nil
	end
end

function chain.new(plugin, display)
	local self = setmetatable({
		_plugin = plugin;
		_display = display;
		_commands = {};
		_count = 0;
		_provocations = {
			Destroyed = Instance.new("BindableFunction");
		};
	}, chain)
	
	self = addCommands(self, script.Parent.Commands)
	if serverStorage:FindFirstChild("CMD+") then
		self = addCommands(self, serverStorage["CMD+"])
	end
	
	self:Node("CommandNode")
	self._restricted = true
	
	return self
end

return chain