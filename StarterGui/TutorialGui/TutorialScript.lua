-- @ScriptType: LocalScript
local TweenService = game:GetService("TweenService")
local Info = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

local guiEdge = require(game.ReplicatedStorage:WaitForChild("GUIModules"):WaitForChild("GuiEdgeAlignment"))
local blackout = require(game.ReplicatedStorage:WaitForChild("GUIModules"):WaitForChild("Blackout"))

local startNewTutorialE = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StartNewTutorial")
local hasDoneTutorialF = game.ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("HasDoneTutorial")

local screenGui = script.Parent
local prommptFrame = screenGui:WaitForChild("PromptFrame")
local close = prommptFrame:WaitForChild("Close")
local startTutorialB = prommptFrame:WaitForChild("StartTutorial")

------ SET UP GUI ------

local openPos = prommptFrame.Position
local closePos = guiEdge.ClosedBottom(prommptFrame) + UDim2.new(0, 0, 0, 20)

prommptFrame.Position = closePos

prommptFrame.Visible = true
screenGui.Enabled = true

-- Open and Close Prompt Frame
local function openPrompt()
	local tween = TweenService:Create(prommptFrame, Info, {Position = openPos})
	tween:Play()
end

local function closePrompt()
	local tween = TweenService:Create(prommptFrame, Info, {Position = closePos})
	tween:Play()
end

-- Set up Close Button event
close.MouseButton1Up:Connect(closePrompt)

-- Set up Start New Tutorial event
startTutorialB.MouseButton1Up:Connect(function()
	startNewTutorialE:FireServer()
	blackout.On(1)
end)


------ SET UP TUTORIAL LOGIC ------

-- Check if player has completed tutorial
task.wait(1)
local hasDoneTutorial = hasDoneTutorialF:InvokeServer()
local tries = 0
while hasDoneTutorial == nil and tries < 5 do
	tries += 1
	task.wait(1)
	hasDoneTutorial = hasDoneTutorialF:InvokeServer()
end

-- If player has not done tutorial, prompt them to
if not hasDoneTutorial then
	print("Player has not done tutorial!")
	task.wait(1)
	openPrompt()
end