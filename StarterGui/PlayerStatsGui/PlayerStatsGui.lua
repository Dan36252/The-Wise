-- @ScriptType: LocalScript
local rs = game:GetService("RunService")

local screenGui = script.Parent
local energyPoints = screenGui:WaitForChild("EnergyPoints")
local baseLevel = screenGui:WaitForChild("BaseLevel")
local knowledgeLevel = screenGui:WaitForChild("Knowledge")
screenGui.Enabled = false

local remoteFunctions = game.ReplicatedStorage:WaitForChild("RemoteFunctions")
local getBaseEnergyFunc = remoteFunctions:WaitForChild("GetBaseEnergy")
local getBaseLevelFunc = remoteFunctions:WaitForChild("GetBaseLevel")
local getKnowledgeFunc = remoteFunctions:WaitForChild("GetKnowledge")

local playButtonEventB = game.ReplicatedStorage:WaitForChild("BindableEvents"):WaitForChild("PlayButtonPressed")
playButtonEventB.Event:Wait()

while task.wait(0.25) do
	if screenGui.Enabled == false then continue end
	local energy = getBaseEnergyFunc:InvokeServer()
	local level = getBaseLevelFunc:InvokeServer()
	local knowledge = getKnowledgeFunc:InvokeServer()
	if energy then
		energyPoints.Text = "Energy: "..tostring(energy)
	end
	if level then
		baseLevel.Text = "Base Level: "..tostring(level)
	end
	if knowledge then
		knowledgeLevel.Text = "Knowledge: "..tostring(knowledge)
	end
end