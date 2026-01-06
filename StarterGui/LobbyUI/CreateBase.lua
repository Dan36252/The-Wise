-- @ScriptType: ModuleScript
local module = {}

-- Services
local players = game:GetService("Players")

-- Variables
local player = players.LocalPlayer

-- Events
local events = game.ReplicatedStorage:WaitForChild("RemoteEvents")
local functions = game.ReplicatedStorage:WaitForChild("RemoteFunctions")
local bindables = script.Parent:WaitForChild("Bindables")

local startNewBaseE = events:WaitForChild("StartNewBase")
local addPlayerToBaseE = events:WaitForChild("AddPlayerToBase")
local removePlayerFromBaseE = events:WaitForChild("RemovePlayerFromBase")
local setPlayerRoleE = events:WaitForChild("SetPlayerRole")
local createBaseE = events:WaitForChild("CreateBase")
local refreshIncompleteBaseE = functions:WaitForChild("RefreshIncompleteBase")
local refreshRequestBE = bindables:WaitForChild("RefreshCreateBaseGui")
local refreshRequestE = events:WaitForChild("RefreshCreateBaseGui")
local changedZoneE = bindables:WaitForChild("PlayerChangedZone")

-- GUI Variables
local screenGui = script.Parent:WaitForChild("GUIs"):WaitForChild("CreateBase")
local canvasGroup = screenGui:WaitForChild("CanvasGroup")
local closeButton = canvasGroup:WaitForChild("Title"):WaitForChild("Close")
local cacheF = screenGui:WaitForChild("Cache")

local primaryButton = canvasGroup:WaitForChild("PrimaryButton")

local addedPlayersF = canvasGroup:WaitForChild("AddedPlayers")
local playerFTemplate = addedPlayersF:WaitForChild("PlayerFrame")

local searchFriendsButton = canvasGroup:WaitForChild("SearchFriends")
local searchLobbyButton = canvasGroup:WaitForChild("SearchLobby")
local searchUserButton = canvasGroup:WaitForChild("SearchUsername")
local searchF = canvasGroup:WaitForChild("SearchFrame")
local searchBox = searchF:WaitForChild("TextBox")

local searchResultsF = canvasGroup:WaitForChild("SearchResults")

local nameBaseF = canvasGroup:WaitForChild("NameBase")
local confirmNameButton = nameBaseF:WaitForChild("Ok")
local cancelNameButton = nameBaseF:WaitForChild("Cancel")
local baseNameBox = nameBaseF:WaitForChild("TextBox")

local confirmCreateF = canvasGroup:WaitForChild("ConfirmCreate")
local createBaseButton = confirmCreateF:WaitForChild("CreateBase")
local cancelButton = confirmCreateF:WaitForChild("Cancel")

-- Player Frames Cache
local cache = {}
local placeholders = {}

-- Add Players Search Mode
local searchMode = "Friends" -- Friends, Lobby, Username

local function GetPlayerFrame(userId, alreadyAdded)
	-- Check if Player Frame already created
	if cache[userId] and not alreadyAdded then
		return cache[userId]
	else
		if alreadyAdded and placeholders[userId] then return placeholders[userId] end
		
		-- CREATE NEW PLAYER FRAME
		
		-- Get Player Name
		local name = "(no name found)"
		local success, err = pcall(function()
			name = players:GetNameFromUserIdAsync(userId)
		end)
		
		-- If Player Name Found:
		if success then
			
			-- Create new Player Frame
			local pf = playerFTemplate:Clone()
			pf.Name = name
			pf:WaitForChild("Name").Text = name
			pf:WaitForChild("Text").Visible = false
			
			-- Load profile picture
			local picSuccess, picErr = pcall(function()
				pf:WaitForChild("ProfilePicture").Image = players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			end)
			
			-- Button events
			if not alreadyAdded then
				local addB = pf:WaitForChild("AddButton")
				addB.MouseButton1Up:Connect(function()
					addPlayerToBaseE:FireServer(userId)
					--refreshRequestBE:Fire()
				end)
				
				local removeB = pf:WaitForChild("RemoveButton")
				removeB.MouseButton1Up:Connect(function()
					removePlayerFromBaseE:FireServer(userId)
					--refreshRequestBE:Fire()
				end)
				
				local roleB = pf:WaitForChild("RoleButton")
				roleB.MouseButton1Up:Connect(function()
					if roleB.TextLabel.Text == "Owner" then
						setPlayerRoleE:FireServer(userId, "Helpers")
					elseif roleB.TextLabel.Text == "Helper" then
						setPlayerRoleE:FireServer(userId, "Owners")
					end
					--refreshRequestBE:Fire()
				end)
				
				-- Add to cache
				cache[userId] = pf
			else
				placeholders[userId] = pf
			end
			
			pf.Parent = cacheF
			
			return pf
			
		else
			warn("Name not found when creating player frame for UserId: "..tostring(userId))
			if err then warn("Error: "..tostring(err)) end
			return nil
		end
		
	end
end

local function MovePlayerFrame(userId, newParent, alreadyAdded, role)
	local playerF = GetPlayerFrame(userId, alreadyAdded)
	
	if not alreadyAdded then
		-- Hide/Show correct buttons
		if newParent.Name == "AddedPlayers" then
			playerF.AddButton.Visible = false
			playerF.RemoveButton.Visible = true
			playerF.RoleButton.Visible = true
		elseif newParent.Name == "SearchResults" then
			playerF.AddButton.Visible = true
			playerF.RemoveButton.Visible = false
			playerF.RoleButton.Visible = false
		end
		
		-- Change Role button to correct color and text
		if role then
			if role == "Owners" then
				playerF.RoleButton.TextLabel.Text = "Owner"
				playerF.RoleButton.ImageColor3 = Color3.fromRGB(0, 141, 237)
			elseif role == "Helpers" then
				playerF.RoleButton.TextLabel.Text = "Helper"
				playerF.RoleButton.ImageColor3 = Color3.fromRGB(38, 154, 7)
			end
		end	
	else
		playerF.AddButton.Visible = false
		playerF.RemoveButton.Visible = false
		playerF.RoleButton.Visible = false
		
		playerF.Text.Visible = true
		playerF.Text.Text = "(Already Added)"
		
		if userId == player.UserId then
			playerF.Text.Text = "(Creator)"
		end
	end
	
	playerF.Parent = newParent
end

local function ClearSearchResults()
	for userId, playerF in pairs(cache) do
		if playerF.Parent == searchResultsF then
			playerF.Parent = cacheF
		end
	end
	for userId, playerF in pairs(placeholders) do
		if playerF.Parent == searchResultsF then
			playerF.Parent = cacheF
		end
	end
end

local function isUserAdded(incompleteBase, userId)
	for i, v in ipairs(incompleteBase["Owners"]) do
		if v == userId then
			return true
		end
	end
	for i, v in ipairs(incompleteBase["Helpers"]) do
		if v == userId then
			return true
		end
	end
	return false
end

local function FillFriendsResults(incompleteBase)
	local friends = nil
	local success, err = pcall(function()
		friends = players:GetFriendsAsync(player.UserId):GetCurrentPage()
	end)
	if success and friends then
		for i, friend in ipairs(friends) do
			local alreadyAdded = isUserAdded(incompleteBase, friend.Id)
			MovePlayerFrame(friend.Id, searchResultsF, alreadyAdded)
		end
	else
		warn("Couldn't get player's friends: "..tostring(err))
	end
end

local function FillLobbyResults(incompleteBase)
	for i, v in ipairs(players:GetPlayers()) do
		if v == player then continue end
		local alreadyAdded = isUserAdded(incompleteBase, v.UserId)
		MovePlayerFrame(v.UserId, searchResultsF, alreadyAdded)
	end
end

local function FillUserResults(incompleteBase)
	
end

local function ResetSearchModeColors()
	searchFriendsButton.ImageColor3 = Color3.fromRGB(66, 255, 250)
	searchLobbyButton.ImageColor3 = Color3.fromRGB(66, 255, 250)
	searchUserButton.ImageColor3 = Color3.fromRGB(66, 255, 250)
end

-- Keep track if a RefreshIncompleteBaseGui function is already running
local currentRefreshRoutine = nil

local function RefreshIncompleteBaseGui()
	-- If this function is already running, cancel it, and run it from the beginning
	if currentRefreshRoutine then task.cancel(currentRefreshRoutine) end
	currentRefreshRoutine = task.spawn(function()
	
		local incompleteBase = refreshIncompleteBaseE:InvokeServer()
		if not incompleteBase then return end
		
		-- Fill Added Players frame
		for i, v in ipairs(incompleteBase["Owners"]) do
			local alreadyAdded = false
			if v == player.UserId then alreadyAdded = true end
			MovePlayerFrame(v, addedPlayersF, alreadyAdded, "Owners")
		end
		for i, v in ipairs(incompleteBase["Helpers"]) do
			MovePlayerFrame(v, addedPlayersF, false, "Helpers")
		end
		
		-- Fill Search Results and change GUI based on selected Search Mode
		ClearSearchResults()
		ResetSearchModeColors()
		if searchMode == "Friends" then
			FillFriendsResults(incompleteBase)
			searchFriendsButton.ImageColor3 = Color3.fromRGB(0, 255, 200)
		elseif searchMode == "Lobby" then
			FillLobbyResults(incompleteBase)
			searchLobbyButton.ImageColor3 = Color3.fromRGB(0, 255, 200)
		elseif searchMode == "Username" then
			FillUserResults(incompleteBase)
			searchUserButton.ImageColor3 = Color3.fromRGB(0, 255, 200)
		end
		
		currentRefreshRoutine = nil
	
	end)
end

local function SetSearchMode(mode)
	searchMode = mode
	RefreshIncompleteBaseGui()
end

local creatingBase = false

function module.Initialize()
	startNewBaseE:FireServer()
	
	-- Setup GUI
	playerFTemplate.Parent = game.ReplicatedStorage:WaitForChild("Templates")
	searchF.Visible = false
	nameBaseF.Visible = false
	confirmCreateF.Visible = false
	
	searchFriendsButton.MouseButton1Up:Connect(function() SetSearchMode("Friends") end)
	searchLobbyButton.MouseButton1Up:Connect(function() SetSearchMode("Lobby") end)
	searchUserButton.MouseButton1Up:Connect(function() SetSearchMode("Username") end)
	
	closeButton.MouseButton1Up:Connect(function() changedZoneE:Fire("CreateBase", false) end)
	
	createBaseButton.MouseButton1Up:Connect(function()
		if creatingBase then return end
		creatingBase = true
		createBaseE:FireServer(baseNameBox.Text)
		
		for i = 20, 0, -1 do
			createBaseButton.Text = "Creating... ("..tostring(i)..")"
			task.wait(1)	
		end
		
		createBaseButton.Text = "Create Base"
		creatingBase = false
	end)
	
	cancelButton.MouseButton1Up:Connect(function() confirmCreateF.Visible = false end)
	cancelNameButton.MouseButton1Up:Connect(function() nameBaseF.Visible = false end)
	
	primaryButton.MouseButton1Up:Connect(function() nameBaseF.Visible = true end)
	
	confirmNameButton.MouseButton1Up:Connect(function()
		confirmCreateF.Visible = true
		nameBaseF.Visible = false
	end)
	
	-- Try to start new Incomplete Base whenever enters Create Base zone
	changedZoneE.Event:Connect(function(zone, present)
		if zone == "CreateBase" and present then
			startNewBaseE:FireServer()
		end
	end)
	
	-- Set up Refresh Event
	refreshRequestBE.Event:Connect(RefreshIncompleteBaseGui)
	refreshRequestE.OnClientEvent:Connect(RefreshIncompleteBaseGui)
	
	-- Refresh GUI for first time
	RefreshIncompleteBaseGui()
	
end

return module
