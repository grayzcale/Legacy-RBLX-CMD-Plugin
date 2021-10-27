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

local function createChain()
	if activeChain then return end
	activeChain = true
	
	plugin:Activate(true)
	primaryButton:SetActive(true)
	
	activeChain = chain.new(plugin, pluginDisplay)
	
	activeChain._provocations.Destroyed.OnInvoke = function()
		plugin:Deactivate()
		primaryButton:SetActive(false)
		activeChain = nil
	end
	
end

--Events
pluginAction.Triggered:Connect(createChain)
primaryButton.Click:Connect(createChain)