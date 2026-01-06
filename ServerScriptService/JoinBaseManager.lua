-- @ScriptType: ModuleScript
local module = {}

local dataStore = game.ServerScriptService:WaitForChild("DataStore")
local bases = require(dataStore:WaitForChild("Bases"))
local baseObjects = require(dataStore:WaitForChild("BaseObjects"))
local playerBasesIndex = require(dataStore:WaitForChild("PlayerBasesIndex"))
local teleport = require(game.ServerScriptService:WaitForChild("Teleportation"))

local retrieveBasesE = game.ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("RetrieveBases")
local joinBaseE = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("JoinBase")
local LEAVEBASEE = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("LEAVEBASE")

-- Return all the Bases that the given player is part of, either as an Owner or a Helper.
-- Return a table in this format:
-- [privateServerId] = {
-- 	 ["Creator"] = ... ,
-- 	 ["Owners"] = {...},
-- 	 ["Helpers"] = {...},
-- 	 ["KeyInfo"] = ... ,  -- For getting Created and Modified date
-- 	 ["BaseObject"] = {...},
-- }
function module.RetrievePlayerBases(player)
	local finalData = {}
	
	local basesIndex = playerBasesIndex.GetPlayerBases(player.UserId)
	if not basesIndex then return nil end
	for i, privateServerId in ipairs(basesIndex) do
		local baseData, keyInfo = bases.GetBase(privateServerId)
		if not baseData then return nil end
		finalData[privateServerId] = {}
		finalData[privateServerId]["Creator"] = baseData[2]
		finalData[privateServerId]["Owners"] = baseData[3]
		finalData[privateServerId]["Helpers"] = baseData[4]
		finalData[privateServerId]["BaseName"] = baseData[5]
		
		--local baseObject, keyInfo = baseObjects.GetBaseObject(privateServerId)
		--if baseObject and keyInfo then
		if baseData and keyInfo then
			finalData[privateServerId]["UpdatedTime"] = keyInfo.UpdatedTime
			finalData[privateServerId]["BaseObject"] = nil --baseObject
			print("Updated Time: "..keyInfo.UpdatedTime)
		else
			finalData[privateServerId]["KeyInfo"] = nil
			finalData[privateServerId]["BaseObject"] = nil
		end
		
	end
	
	return finalData
end

function module.TeleportPlayer(player, privateServerId)
	-- Verify that base exists
	local baseData = bases.GetBase(privateServerId)
	if not baseData then
		warn("Cannot teleport"..player.Name..": Base Data doesn't exist! ("..tostring(privateServerId)..")")
		return nil
	end
	
	-- Verify that player is part of this base
	local userId = player.UserId
	local partOfBase = (userId == baseData[2]) or table.find(baseData[3], userId) or table.find(baseData[4], userId)
	
	-- If player is part of this base, teleport them
	if partOfBase then
		print("Succes: Player "..player.Name.." is part of this base!")
		local accessCode = baseData[1]
		teleport.Teleport({player}, "Base", accessCode)
	end
end

function module.Initialize()
	retrieveBasesE.OnServerInvoke = module.RetrievePlayerBases
	joinBaseE.OnServerEvent:Connect(module.TeleportPlayer)
	LEAVEBASEE.OnServerEvent:Connect(function(player, privateServerId)
		bases.RemovePlayer(privateServerId, player.UserId)
	end)
end

return module
