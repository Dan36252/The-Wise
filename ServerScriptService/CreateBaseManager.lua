-- @ScriptType: ModuleScript
local module = {}

-- Events
local events = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local functions = game.ReplicatedStorage:WaitForChild("RemoteFunctions")
local startNewBaseE = events:WaitForChild("StartNewBase")
local addPlayerToBaseE = events:WaitForChild("AddPlayerToBase")
local removePlayerFromBaseE = events:WaitForChild("RemovePlayerFromBase")
local setPlayerRoleE = events:WaitForChild("SetPlayerRole")
local createBaseE = events:WaitForChild("CreateBase")
local refreshIncompleteBaseE = functions:WaitForChild("RefreshIncompleteBase")
local refreshRequestE = events:WaitForChild("RefreshCreateBaseGui")

-- Modules
local basesData = require(game.ServerScriptService.DataStore.Bases)
local teleport = require(game.ServerScriptService.Teleportation)

-- Store all existing incomplete bases that are being made in this lobby
local incomplete_bases = {}

-- Creates a new Incomplete Base for the given player (creator)
function module.CreateIncompleteBase(creator)
	if incomplete_bases[creator.UserId] then return end
	
	incomplete_bases[creator.UserId] = {["Owners"] = {creator.UserId}, ["Helpers"] = {}}
	--print("Created new base object!")
	refreshRequestE:FireClient(creator)
end

-- Gets the given player's Incomplete Base and creates an actual Base,
-- teleporting the creator and all who are joined to the new Private Server
function module.CreateBase(creator, baseName)
	local incomplete_base = module.GetIncompleteBase(creator)
	if incomplete_base then
		print("Creating Base!!")
		local accessCode = basesData.CreateBase(creator.UserId, incomplete_base["Owners"], incomplete_base["Helpers"], baseName)
		local players = module.GetAllPlayersInBase(creator)
		if players then
			teleport.Teleport(players, "Base", accessCode, false)
		end
	end
end

function module.GetAllPlayersInBase(creator)
	local incomplete_base = module.GetIncompleteBase(creator)
	if incomplete_base then
		local players = {}
		-- table.insert(players, creator) -- Don't add the creator, because they're already an owner
		for i, v in ipairs(incomplete_base["Owners"]) do
			local plr = game.Players:GetPlayerByUserId(v)
			-- TODO: Also check if this player chose to join this new base right now
			if plr then table.insert(players, plr) end
		end
		for i, v in ipairs(incomplete_base["Helpers"]) do
			local plr = game.Players:GetPlayerByUserId(v)
			-- TODO: Also check if this player chose to join this new base right now
			if plr then table.insert(players, plr) end
		end
		return players
	else
		warn("Failed to get all players for "..creator.Name.."'s base. Does it exist?")
		return nil
	end
end

function module.GetIncompleteBase(creator)
	if not incomplete_bases[creator.UserId] then return nil end
	return incomplete_bases[creator.UserId]
end

function module.AddPlayerToBase(creator, playerId)
	if not incomplete_bases[creator.UserId] then return end
	
	if not table.find(incomplete_bases[creator.UserId]["Owners"], playerId) then
		table.insert(incomplete_bases[creator.UserId]["Owners"], playerId)
	end
	
	refreshRequestE:FireClient(creator)
end

function module.RemovePlayerFromBase(creator, playerId)
	if not incomplete_bases[creator.UserId] then return end
	
	if table.find(incomplete_bases[creator.UserId]["Owners"], playerId) then
		table.remove(incomplete_bases[creator.UserId]["Owners"], table.find(incomplete_bases[creator.UserId]["Owners"], playerId))
	end
	
	if table.find(incomplete_bases[creator.UserId]["Helpers"], playerId) then
		table.remove(incomplete_bases[creator.UserId]["Helpers"], table.find(incomplete_bases[creator.UserId]["Helpers"], playerId))
	end
	
	refreshRequestE:FireClient(creator)
end

function module.SetPlayerRole(creator, playerId, role)
	if not incomplete_bases[creator.UserId] then return end
	module.RemovePlayerFromBase(creator, playerId)
	table.insert(incomplete_bases[creator.UserId][role], playerId)
	
	refreshRequestE:FireClient(creator)
end


function module.Initialize()
	refreshIncompleteBaseE.OnServerInvoke = module.GetIncompleteBase
	startNewBaseE.OnServerEvent:Connect(module.CreateIncompleteBase)
	createBaseE.OnServerEvent:Connect(module.CreateBase)
	addPlayerToBaseE.OnServerEvent:Connect(module.AddPlayerToBase)
	removePlayerFromBaseE.OnServerEvent:Connect(module.RemovePlayerFromBase)
	setPlayerRoleE.OnServerEvent:Connect(module.SetPlayerRole)
end


return module
