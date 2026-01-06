-- @ScriptType: ModuleScript
local module = {}

-- Services / Modules
local Players = game:GetService("Players")
local utilities = require(game.ReplicatedStorage:WaitForChild("Utilities"))
local baseSettingsM = require(script:WaitForChild("BaseSettings"))

-- Events
local events = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local functions = game.ReplicatedStorage:WaitForChild("RemoteFunctions")
local bindables = script.Parent:WaitForChild("Bindables")
local changedZoneE = bindables:WaitForChild("PlayerChangedZone")
local retrieveBasesE = functions:WaitForChild("RetrieveBases")
local joinBaseE = events:WaitForChild("JoinBase")

-- GUI Variables
local screenGui = script.Parent:WaitForChild("GUIs"):WaitForChild("JoinBase")
local canvasGroup = screenGui:WaitForChild("CanvasGroup")
local basesF = canvasGroup:WaitForChild("Bases")
local closeB = canvasGroup:WaitForChild("Title"):WaitForChild("Close")
local refreshB = canvasGroup:WaitForChild("Title"):WaitForChild("Refresh")
local refreshBIcon = refreshB:WaitForChild("ImageLabel")
local refreshBText = refreshB:WaitForChild("TextLabel")
local baseF = basesF:WaitForChild("BaseFrame")

-- Refresh Join Base GUI logic

local canJoin = true

local function createBaseFrame(privateServerId, baseData)
	print("Creating Frame!")
	local f = baseF:Clone()
	f.Name = tostring(privateServerId)
	f.NameLabel.Text = tostring(baseData["BaseName"])
	
	-- Set Owners list text
	local ownersList = "Owners:  "
	for i, v in ipairs(baseData["Owners"]) do
		local playerName = Players:GetNameFromUserIdAsync(v)
		ownersList = ownersList..playerName..", "
	end
	ownersList = string.sub(ownersList, 1, string.len(ownersList)-2)
	f.Owners.Text = ownersList
	
	-- Set Helpers list text
	local helpersList = "Helpers:  "
	for i, v in ipairs(baseData["Helpers"]) do
		local playerName = Players:GetNameFromUserIdAsync(v)
		helpersList = helpersList..playerName..", "
	end
	helpersList = string.sub(helpersList, 1, string.len(helpersList)-2)
	f.Helpers.Text = helpersList
	
	-- Set Updated Time
	if baseData["UpdatedTime"] ~= nil then
		print("Time Updated: "..baseData["UpdatedTime"])
		local dateTable = utilities.MillisToDateTimeTable(baseData["UpdatedTime"])--DateTime.fromUnixTimestampMillis(tonumber(baseData["UpdatedTime"])).ToLocalTime()
		f.Modified.Text = dateTable[2] .. " " .. dateTable[3] .. ", " .. dateTable[1]
		print(f.Modified.Text)
	end
	
	-- Set up Join button
	f.JoinButton.MouseButton1Up:Connect(function()
		if not canJoin then return end
		canJoin = false
		
		joinBaseE:FireServer(privateServerId)
		
		for i = 10, 1, -1 do
			f.JoinButton.TextLabel.Text = "("..tostring(i)..")"
			task.wait(1)
		end
		
		canJoin = true
		f.JoinButton.TextLabel.Text = "Join"
	end)
	
	-- Set up Settings button
	f.SettingsButton.MouseButton1Up:Connect(function()
		baseSettingsM.OpenSettingsForBase(privateServerId, baseData)
	end)
	
	f.Parent = basesF
end

local function clearGui()
	for i, v in ipairs(basesF:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
end

local function RefreshGui()
	print("Refreshing JoinBase GUI...")
	clearGui()
	local basesData = retrieveBasesE:InvokeServer()
	if not basesData then return end
	for privateServerId, baseData in pairs(basesData) do
		createBaseFrame(privateServerId, baseData)
	end
	
	-- Adjust scrolling frame size
	local scrollSize = basesF:FindFirstChildWhichIsA("UIListLayout").AbsoluteContentSize.Y + 50
	basesF.CanvasSize = UDim2.new(0, 0, 0, scrollSize)
end

-- Refresh button logic

local refreshCountdown = 20
local canRefresh = true

local function refreshButtonReady()
	canRefresh = true
	refreshBText.Text = ""
	refreshBIcon.Visible = true
	canRefresh = true
end

local function refreshButtonPressed()
	if not canRefresh then return end
	canRefresh = false
	
	-- TODO: Refresh the JoinBase GUI by retrieving the player's Base Index Data
	task.spawn(function() RefreshGui() end)
	
	-- Button cooldown logic
	refreshBIcon.Visible = false
	for i = refreshCountdown, 1, -1 do
		refreshBText.Text = "("..tostring(i)..")"
		task.wait(1)
	end
	refreshButtonReady()
end


function module.Initialize()
	
	-- Initialize Gui
	baseF.Parent = game.ReplicatedStorage:WaitForChild("Templates")
	closeB.MouseButton1Up:Connect(function() changedZoneE:Fire("CreateBase", false) end)
	refreshButtonReady()
	refreshB.MouseButton1Up:Connect(refreshButtonPressed)
	
	-- Refresh GUI initially
	RefreshGui()
	
end

return module
