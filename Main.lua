--[[By: @V3N0M_Z]]

--Variables initialization
local userInputService = game:GetService("UserInputService")
local chain = require(script.Parent:WaitForChild("Chain"))
local mouse = plugin:GetMouse()
local activeChain

--Display initialization
local coreGui = game:GetService("CoreGui")
if coreGui:FindFirstChild("CMD+") then
	coreGui:FindFirstChild("CMD+"):Destroy()
end
local pluginDisplay = coreGui:FindFirstChild("CMD+") or Instance.new("ScreenGui")
pluginDisplay.Parent = coreGui
pluginDisplay.Name = "CMD+"

local imposterFrame = pluginDisplay:FindFirstChild("Imposter") or Instance.new("Frame")
imposterFrame.Parent = pluginDisplay
imposterFrame.Name = "Imposter"
imposterFrame.BackgroundTransparency = 1
imposterFrame.Size = UDim2.new(1, 0, 1, 0)

--Toolbar initialization
local pluginToolbar = plugin:CreateToolbar("CMD+")
local primaryButton = pluginToolbar:CreateButton("CMD+", " ", "rbxassetid://7737708078", "")

--Plugin action initialization
local pluginAction = plugin:CreatePluginAction("CMD+", "CMD+", "Open CMD+", "rbxassetid://7737708078", true)

local function createChain(cmd)
	if activeChain then
		activeChain:Dispose()
		return
	end 
	
	if activeChain then return end
	activeChain = true
	
	plugin:Activate(true)
	primaryButton:SetActive(true)
	
	activeChain = chain.new(plugin, pluginDisplay, cmd)
	activeChain._provocations.Destroyed.OnInvoke = function()
		plugin:Deactivate()
		primaryButton:SetActive(false)
		activeChain = nil
	end
	
end

--Events
pluginAction.Triggered:Connect(createChain)
primaryButton.Click:Connect(createChain)

--Key shorcuts
local commands = {}
local function getCommands()
	for _, command in ipairs(script.Parent:WaitForChild("Commands"):GetChildren()) do
		command = require(command)
		if command.metadata.shortcut then
			commands[command.metadata.id] = command
		end
	end
	if game:GetService("ServerStorage"):FindFirstChild("CMD+") then
		for _, command in ipairs(game:GetService("ServerStorage")["CMD+"]:GetChildren()) do
			command = require(command)
			if command.metadata.shortcut then
				commands[command.metadata.id] = command
			end
		end
	end
end
getCommands()

userInputService.InputBegan:Connect(function(input)
	local keysPressed = userInputService:GetKeysPressed()
	if not activeChain and keysPressed then
		for command, data in pairs(commands) do
			if #keysPressed == #data.metadata.shortcut then
				local equal = true
				for _, key in ipairs(keysPressed) do
					if not table.find(data.metadata.shortcut, key.KeyCode) then
						equal = false
					end
				end
				if equal then
					return createChain(command)
				end
			end
		end
	end
end)

local refreshButton = pluginToolbar:CreateButton("CMD+:Refresh", " ", "rbxassetid://7974159081", "")
refreshButton.Click:Connect(function()
	commands = {}
	getCommands()
end)