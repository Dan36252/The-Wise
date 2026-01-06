-- @ScriptType: ModuleScript
local module = {}

local safeTP = require(script.SafeTeleport)

module.PlaceIds = {
	["Lobby"] = 83737487404887,
	["Base"] = 80907030981808,
	["OldBase"] = 115110336694508,
	["Plains"] = 91633092122530
}

local requests = {}

-- Teleport player to a specific place
function module.Teleport(players, placeName, accessCode, isTutorial)
	
	-- If player already requested a teleport, ignore new requests
	if table.find(requests, players) then return end
	table.insert(requests, players)
	
	local placeId = module.PlaceIds[placeName]
	if placeId then
		local options = nil
		if accessCode then
			options = Instance.new("TeleportOptions")
			options.ReservedServerAccessCode = accessCode
			if isTutorial then
				options:SetTeleportData({["Tutorial"] = true})
			end
		end
		local success, result = safeTP(placeId, players, options)
		if success then table.remove(requests, table.find(requests, players)) end
	else
		warn("Invalid place name")
	end
end

return module
