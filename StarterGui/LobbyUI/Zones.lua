-- @ScriptType: ModuleScript
local module = {}

local createBaseRing = game.Workspace:WaitForChild("CreateBase"):WaitForChild("Ring")
local joinBaseRing = game.Workspace:WaitForChild("JoinBase"):WaitForChild("Ring")

local events = script.Parent:WaitForChild("Bindables")
local changedZone = events:WaitForChild("PlayerChangedZone")

-- Keep track of the {Current, Previous} state of the player in each zone: true = in zone, false = not in zone
local cache = {
	["CreateBase"] = {false, false},
	["JoinBase"] = {false, false}
}


local player = game.Players.LocalPlayer

local function isInRing(ringObj)
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local dist = (root.Position - ringObj.Position).Magnitude
	return dist <= ringObj.Size.Z/2
end

function module.Initialize()

	task.spawn(function()
		while task.wait(0.25) do
			cache["CreateBase"][1] = isInRing(createBaseRing)
			cache["JoinBase"][1] = isInRing(joinBaseRing)
			
			for zone, v in pairs(cache) do
				if v[1] ~= v[2] then
					changedZone:Fire(zone, v[1])
					--print("Zone "..zone.." = "..tostring(v[1]))
					v[2] = v[1]
				end
			end
		end
	end)
end

return module
