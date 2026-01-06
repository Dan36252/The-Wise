-- @ScriptType: ModuleScript
local module = {}

function module.GetPointsForLevel(level)
	return math.pow(level-1, 2) * 100
end

function module.GetLevelFromPoints(points)
	if points == 0 then return 1 end
	local level = 1
	while module.GetPointsForLevel(level) < points do
		level += 1
	end
	return level-1
	--return math.floor(math.log(points/100, 2)) + 1
end

return module
