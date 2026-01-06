-- @ScriptType: ModuleScript
local module = {}

-- Window Animation Variables
local TweenService = game:GetService("TweenService")
local Info = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Events
local events = script.Parent:WaitForChild("Bindables")
local bindables = script.Parent:WaitForChild("Bindables")
local changedZone = events:WaitForChild("PlayerChangedZone")
local refreshRequestE = bindables:WaitForChild("RefreshCreateBaseGui")

-- Window Variables
local guiNames = {"CreateBase", "JoinBase"}
local windows = {}

function module.Initialize()
	-- Fill windows table
	local guis = script.Parent:WaitForChild("GUIs")
	for _, guiName in ipairs(guiNames) do
		windows[guiName] = guis:WaitForChild(guiName)
		windows[guiName].Enabled = false
		windows[guiName]:WaitForChild("CanvasGroup").GroupTransparency = 1
	end
	
	-- Close all windows
	module.CloseAll(false)
	
	-- Setup zone event to open/close windows
	changedZone.Event:Connect(function(zone, present)
		--print("Event received: "..zone)
		if present == false then
			module.CloseAll(true)
		else
			module.Open(zone)
		end
	end)
	
end

function module.Open(guiName)
	module.CloseAll(false)
	windows[guiName].Enabled = true
	refreshRequestE:Fire()
	
	local tween = TweenService:Create(windows[guiName]:WaitForChild("CanvasGroup"), Info, {["GroupTransparency"] = 0})
	tween:Play()
	tween.Completed:Wait()
	
	windows[guiName]:WaitForChild("CanvasGroup").GroupTransparency = 0
end

function module.CloseAll(fadeOut)
	for guiName, gui in pairs(windows) do
		if gui.Enabled then
			if fadeOut then
				local tween = TweenService:Create(gui:WaitForChild("CanvasGroup"), Info, {["GroupTransparency"] = 1})
				tween:Play()
				tween.Completed:Wait()
			end
			gui:WaitForChild("CanvasGroup").GroupTransparency = 1
			gui.Enabled = false
		end
	end
end

return module
