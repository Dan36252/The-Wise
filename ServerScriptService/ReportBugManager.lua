-- @ScriptType: Script
local HttpService = game:GetService("HttpService")
local bugReportUrl = "https://inspire-learning.org/api/bug-report"

local reportBugEvent = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ReportBug")

local cooldowns = {} -- List of booleans for each player. If true, player cannot send bug request; if false, they can.

reportBugEvent.OnServerEvent:Connect(function(player, bug)
	if cooldowns[player.UserId] ~= nil and cooldowns[player.UserId] == true then return end
	cooldowns[player.UserId] = true
	
	local tries = 0
	local success = false
	local err = nil
	
	while tries < 3 do
		success, err = pcall(function()
			HttpService:PostAsync(bugReportUrl, HttpService:JSONEncode({["player"] = player.Name, ["bug"] = bug}), Enum.HttpContentType.ApplicationJson)
		end)
		if success then
			print("Sent bug report successfully!!!")
			break
		else
			warn("Failed to send bug report. Retrying...")
			warn("Error: "..tostring(err))
			task.wait(3)
		end
	end
	
	reportBugEvent:FireClient(player, success, err)
	
	wait(10)
	cooldowns[player.UserId] = false
end)