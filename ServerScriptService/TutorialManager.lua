-- @ScriptType: ModuleScript
local module = {}

local basesData = require(game.ServerScriptService:WaitForChild("DataStore"):WaitForChild("Bases"))
local tutorialsData = require(game.ServerScriptService:WaitForChild("DataStore"):WaitForChild("Tutorials"))
local teleport = require(game.ServerScriptService:WaitForChild("Teleportation"))

local hasDoneTutorialF = game.ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("HasDoneTutorial")
local startNewTutorialE = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("StartNewTutorial")

-- Keep track of who created a new tutorial, to prevent them from making one again too soon
local cooldowns = {}

-- Create a new Tutorial Base for the player, and teleport them with correct Teleport Data to start the tutorial
local function StartNewTutorial(player)
	if cooldowns[player.UserId] then return end
	cooldowns[player.UserId] = true
	
	local baseName = "Tutorial Base " .. tostring(tutorialsData.NumCompletedTutorials(player.UserId) + 1)
	local accessCode, privateServerId = basesData.CreateBase(player.UserId, {player.UserId}, {}, baseName)
	teleport.Teleport({player}, "Base", accessCode, true)
	
	task.wait(15)
	cooldowns[player.UserId] = false
end

function module.Initialize()
	hasDoneTutorialF.OnServerInvoke = function(player) return tutorialsData.HasPlayerDoneTutorial(player.UserId) end
	startNewTutorialE.OnServerEvent:Connect(StartNewTutorial)
end

return module
