-- @ScriptType: LocalScript
local screenGui = script.Parent
local background = screenGui:WaitForChild("Background")
local buildMenu = background:WaitForChild("BuildMenu")
local buildButton = screenGui:WaitForChild("BuildButton")

background.Visible = false
screenGui.Enabled = false

local playButtonEvent = game.ReplicatedStorage:WaitForChild("BindableEvents"):WaitForChild("PlayButtonPressed")
playButtonEvent.Event:Wait()

print("Build Script Running!!!")

local placement = require(script:WaitForChild("Placement"))
local buildMenuM = require(script:WaitForChild("BuildMenu"))

buildMenuM.Initialize()

buildButton.MouseButton1Up:Connect(buildMenuM.ToggleGui)