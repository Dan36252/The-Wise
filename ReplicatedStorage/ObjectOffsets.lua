-- @ScriptType: ModuleScript
local module = {}

local objectIndex = require(game.ReplicatedStorage:WaitForChild("ObjectIndex"))

module.Offsets = {
	["pulsarCore1"] = CFrame.new(0, 0, 0),
	["Defenses"] = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(-90)),
	["Walls"] = CFrame.new(0, 1.75, -1.75)
	
}

-- Return the offset CFrame for the given object ID, or CFrame.new() if not found
function module.GetOffsetFromID(id)
	local c = CFrame.new()
	if module.Offsets[id] then
		c = module.Offsets[id]
	elseif module.Offsets[objectIndex.GetTypeFromID(id)] then
		c = module.Offsets[objectIndex.GetTypeFromID(id)]
	end

	return c
end

return module
