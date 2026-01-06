-- @ScriptType: LocalScript
local player = game.Players.LocalPlayer

local serverReadyFunc = game.ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("ServerReady")
local playButtonEventR = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PlayButtonPressed")
local playButtonEventB = game.ReplicatedStorage:WaitForChild("BindableEvents"):WaitForChild("PlayButtonPressed")
local loadingBaseEvent = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("LoadingBase")

local screenGui = script.Parent
local playButton = screenGui:WaitForChild("PlayButton")
local loadingText = screenGui:WaitForChild("LoadingText")

local camPart = game.Workspace:WaitForChild("Maps"):WaitForChild("PlayerBase"):WaitForChild("StarterScreenCam")
local cam = game.Workspace.CurrentCamera

playButton.Visible = false
loadingText.Visible = false
screenGui.Enabled = true

local counter = 0
local camConnection = game:GetService("RunService").RenderStepped:Connect(function()
	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = camPart.CFrame * CFrame.Angles(0, -math.rad(20*counter/60), 0) * CFrame.Angles(-math.rad(20), 0, 0)
	counter += 1
	if counter >= 1080 then counter = 0 end
end)

local baseLoading = true
loadingBaseEvent.OnClientEvent:Connect(function(isLoading)
	baseLoading = isLoading
end)

while not serverReadyFunc:InvokeServer() do
	print("Waiting for server to be ready...")
	task.wait(0.25)
end

playButton.MouseButton1Up:Connect(function()
	-- Hide Play Button
	playButton.Visible = false
	playButtonEventR:FireServer()
	playButtonEventB:Fire()
	
	-- Disable Starter Screen Camera
	camConnection:Disconnect()
	cam.CameraType = Enum.CameraType.Custom
	local char = player.Character or player.CharacterAdded:Wait()
	cam.CameraSubject = char:WaitForChild("Humanoid")
	
	-- Wait for Base to Load
	loadingText.Visible = true
	while baseLoading do
		task.wait(1)
	end
	loadingText.Visible = false
	
	-- Enable Player Gui buttons and menus
	player:WaitForChild("PlayerGui"):WaitForChild("PlayerStatsGui").Enabled = true
	player:WaitForChild("PlayerGui"):WaitForChild("BuildGui").Enabled = true
	player:WaitForChild("PlayerGui"):WaitForChild("ResearchGui").Enabled = true
	
	
end)

playButton.Visible = true