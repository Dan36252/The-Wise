-- @ScriptType: ModuleScript
local module = {}

function module.CopyTable(t)
	local c = {}
	for i, v in pairs(t) do
		if typeof(v) == "table" then
			c[i] = module.CopyTable(v)
		else
			c[i] = v
		end
	end
	return c
end

function module.SetModelCanCollide(model, canCollide)
	for i, v in ipairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = canCollide
		end
	end
end

function module.SetModelTransparentFor(model, duration)
	local originalTransparencies = {}
	for i, v in ipairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			originalTransparencies[i] = {v, v.Transparency}
			v.Transparency = 0.5
		end
	end
	task.wait(duration)
	for i, v in ipairs(originalTransparencies) do
		v[1].Transparency = v[2]
	end
end

module.Months = {"Jan", "Feb", "Mar", "Apr", "May","Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
module.MonthLengths = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

function module.MillisToDateTimeTable(millis)
	local days = math.floor(millis / (86400000))
	local years = math.floor(days / 365.25)
	local YEAR = 1970 + years
	local DAYS = days - math.floor(years * 365.25)
	local MONTH = 1
	local DAY = 0
	local daySum = 0
	for i = 1, 12 do
		MONTH = i
		daySum += module.MonthLengths[i]
		if i == 2 and years % 4 == 0 then
			daySum += 1
		end
		if daySum >= DAYS then
			DAY = DAYS - (daySum - module.MonthLengths[i])
			break
		end
	end
	return {YEAR, module.Months[MONTH], DAY}
end


return module
