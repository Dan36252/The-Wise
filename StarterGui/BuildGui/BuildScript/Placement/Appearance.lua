-- @ScriptType: ModuleScript
local module = {}

function module.CanCollideOff(model)
	for i, v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end

return module
