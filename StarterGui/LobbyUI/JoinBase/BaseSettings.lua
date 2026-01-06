-- @ScriptType: ModuleScript
local module = {}

-- Events
local LEAVEBASEE = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("LEAVEBASE")

-- GUI Variables
local screenGui = script.Parent.Parent:WaitForChild("GUIs"):WaitForChild("JoinBase")
local settingsTemplate = screenGui:WaitForChild("CanvasGroup"):WaitForChild("SettingsFrame")

-- Setup
settingsTemplate.Visible = false
settingsTemplate.Parent = game.ReplicatedStorage:WaitForChild("Templates")

-- Flags
local currentWindow = nil
local canLeave = false

function module.OpenSettingsForBase(privateServerId, baseData)
	if currentWindow then currentWindow:Destroy() end
	local newF = settingsTemplate:Clone()
	currentWindow = newF
	newF.Parent = screenGui:WaitForChild("CanvasGroup")
	
	newF:WaitForChild("BaseName").Text = baseData["BaseName"]
	newF:WaitForChild("BaseName"):WaitForChild("Close").MouseButton1Up:Connect(function()
		newF:Destroy()
		currentWindow = nil
	end)
	
	newF:WaitForChild("LEAVEBASE").MouseButton1Up:Connect(function()
		if not canLeave then
			canLeave = true
			newF:WaitForChild("LEAVEBASE"):WaitForChild("TextLabel").Text = "Click to Confirm."
			task.spawn(function()
				task.wait(3)
				canLeave = false
				newF:WaitForChild("LEAVEBASE"):WaitForChild("TextLabel").Text = "LEAVE BASE"
			end)
		else
			LEAVEBASEE:FireServer(privateServerId)
		end
	end)
	
	newF.Visible = true
	
end

return module
