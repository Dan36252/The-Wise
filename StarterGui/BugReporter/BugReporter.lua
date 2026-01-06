-- @ScriptType: LocalScript
-- SETTINGS
local COOLDOWN = 30 -- How many seconds to wait before user can send another bug report

-- Services
local TweenService = game:GetService("TweenService")
local Info = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Modules
local guiEdgeM = require(game.ReplicatedStorage:WaitForChild("GUIModules"):WaitForChild("GuiEdgeAlignment"))

-- Events
local reportBugE = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ReportBug")

-- GUI Variables
local screenGui = script.Parent
local canvasGroup = screenGui:WaitForChild("CanvasGroup")
local textBox = canvasGroup:WaitForChild("TextFrame"):WaitForChild("TextBox")
local sendButton = canvasGroup:WaitForChild("SendButton")
local toggleMenuB = screenGui:WaitForChild("ToggleMenu")
local closeButton = canvasGroup:WaitForChild("Title"):WaitForChild("Close")

-- Flags
local canSend = true
local guiOpen = false
local openCanvasPos = canvasGroup.Position
local closedCanvasPos = guiEdgeM.ClosedLeft(canvasGroup, 5)

local sendSuccess = false
local sendErr = ""

-- Setup
screenGui.Enabled = true
canvasGroup.Visible = true
canvasGroup.Position = closedCanvasPos
reportBugE.OnClientEvent:Connect(function(success, err)
	sendSuccess = success
	sendErr = err
end)

-- Send a request to report a bug to the server
local function sendBug()
	-- Manage cooldown
	if not canSend then return end
	canSend = false
	sendButton.TextLabel.Text = "Sending..."
	
	-- Send bug report event
	local bug = textBox.Text
	reportBugE:FireServer(bug)
	
	-- Await server response
	reportBugE.OnClientEvent:Wait()
	task.wait(1)
	
	-- Display button text based on success/failure
	if sendSuccess then
		
		sendButton.TextLabel.Text = "Sent!"
		
		task.wait(1)
		for i = COOLDOWN, 1, -1 do
			sendButton.TextLabel.Text = "Cooldown (" .. i .. ")"
			task.wait(1)
		end
		
	else
		sendButton.TextLabel.Text = "ERROR: "..tostring(sendErr)
		task.wait(15)
	end
	
	canSend = true
end

-- Open the Report a Bug menu
local function openMenu()
	local tween = TweenService:Create(canvasGroup, Info, {Position = openCanvasPos})
	tween:Play()
end

-- Close the Report a Bug menu
local function closeMenu()
	local tween = TweenService:Create(canvasGroup, Info, {Position = closedCanvasPos})
	tween:Play()
end

-- Connect events
toggleMenuB.MouseButton1Up:Connect(openMenu)
closeButton.MouseButton1Up:Connect(closeMenu)
sendButton.MouseButton1Up:Connect(sendBug)