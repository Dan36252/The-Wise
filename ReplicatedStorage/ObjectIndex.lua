-- @ScriptType: ModuleScript
local module = {}

local insertService = game:GetService("InsertService")
local runService = game:GetService("RunService")
local serverScriptService = game:GetService("ServerScriptService")

local assetsID = 73141693115023
local assets

local classes = game.ReplicatedStorage.ObjectClasses
local objectC = classes.Object

function module.LoadAssets()
	task.spawn(function()
		-- Load Assets Package
		local success = false
		local err = nil
		local tryCount = 0
		
		while success == false do
			tryCount += 1
			success, err = pcall(function()
				assets = insertService:LoadAsset(assetsID)
			end)
			if success then
				print("Assets loaded in "..tostring(tryCount).." tries!")
				assets.Parent = game.ReplicatedStorage.ObjectModels
				assets.Name = "Assets"
				assets = assets:FindFirstChild("BuildingBlocks")
			else
				if err then
					warn("Couldn't load assets: "..err)
					warn(tostring(tryCount).." tries so far. Retrying...")
				end
			end
			wait(0.25)
		end
		
	end)
end

-- MAIN OBJECT INDEX DICTIONARY --
-- Format: [Object Type] >> [Object ID] : {Model Path, Object Class, Placeable, Energy Needed, Level Needed}
module.Models = {
	["Pulsars"] = {
		["pulsarCore01"] = {"Pulsars/PulsarCore1", objectC, true, 5000, 3}	
	},
	["Medicine Stations"] = {
		["medicineStation01"] = "MedicineStations/Campfire1"	
	},
	["Walls"] = {
		["wall01"] = {"Walls/Wall01", objectC.Wall, true, 50, 1},
		["wall02"] = {"Walls/Wall02", objectC.Wall, true, 100, 2},
		["wall03"] = {"Walls/Wall03", objectC.Wall, true, 200, 3},
		["wall04"] = {"Walls/Wall04", objectC.Wall, true, 400, 4},
		["wall05"] = {"Walls/Wall05", objectC.Wall, true, 1000, 5},
		["wall06"] = {"Walls/Wall06", objectC.Wall, true, 2500, 6},
		["wall07"] = {"Walls/Wall07", objectC.Wall, true, 5000, 7},
		["wall08"] = {"Walls/Wall08", objectC.Wall, true, 10000, 8},
		["wall09"] = {"Walls/Wall09", objectC.Wall, true, 15000, 9},
		["wall10"] = {"Walls/Wall10", objectC.Wall, true, 50000, 10},
	},
	["Defenses"] = {
		["turret01"] = {"Turrets/Turret01", objectC.Turret, true, 100, 1},
		["turret02"] = {"Turrets/Turret02", objectC.Turret, true, 200, 2},
		["turret03"] = {"Turrets/Turret03", objectC.Turret, true, 400, 3},
		["turret04"] = {"Turrets/Turret04", objectC.Turret, true, 800, 4},
		["turret05"] = {"Turrets/Turret05", objectC.Turret, true, 2500, 5},
		["turret06"] = {"Turrets/Turret06", objectC.Turret, true, 6000, 6},
		["turret07"] = {"Turrets/Turret07", objectC.Turret, true, 12000, 7},
		["turret08"] = {"Turrets/Turret08", objectC.Turret, true, 24000, 8},
		["turret09"] = {"Turrets/Turret09", objectC.Turret, true, 50000, 9},
		["turret10"] = {"Turrets/Turret10", objectC.Turret, true, 100000, 10},
	},
	["Storage Containers"] = {
		["container01"] = "StorageContainers/Container1"
	},
	--["Energy Racks"] = {
	--	["rack01"] = "EnergyRacks/PulsarHolder1"
	--},
	["Enemies"] = {
		["enemy01"] = "Enemies/Robot01"
	}
}

function module.WaitForAssetsToLoad()
	-- Wait for assets to load
	if runService:IsServer() then
		while not assets do
			print("waiting for assets to load (server)...")
			wait(0.25)
		end
	elseif runService:IsClient() then
		local assetsFolder = game.ReplicatedStorage:WaitForChild("ObjectModels"):WaitForChild("Assets"):WaitForChild("BuildingBlocks")
		while #assetsFolder:GetChildren() < #module.Models do
			print("waiting for assets to load (client)...")
			wait(0.25)
		end
		assets = assetsFolder
	end
end

-- Return the model in the imported Assets folder that corresponds to the given ID, using Object Index
function module.GetModelFromID(id)
	
	module.WaitForAssetsToLoad()
	
	-- Check every key/value in the Object Index until correct ID found
	for objectType, objectIndex in pairs(module.Models) do
		for modelID, modelDetails in pairs(objectIndex) do
			if modelID == id then
				-- Get the model path
				local modelPath = "Walls/Wall01"
				if typeof(modelDetails) == "string" then modelPath = modelDetails
				elseif typeof(modelDetails) == "table" then modelPath = modelDetails[1] end
				
				--print("ID: "..id)
				--print("modelDetails: ")
				--print(modelDetails)

				-- Try to follow the model path to get the model
				local obj
				local success, err = pcall(function()
					local path = modelPath:split("/")
					obj = assets:FindFirstChild(path[1])
					for i = 2, #path do
						obj = obj:FindFirstChild(path[i])
					end
				end)
				
				-- Return model if success; else, give warning and return placeholder model
				if success then
					--print("Found object for ID '"..id.."' successfully! The model's name is: "..obj.Name)
					if not obj then warn("Error: Could not find model for "..modelID.."! Is model path "..modelPath.." correct?") end
					if not obj.PrimaryPart then warn("Warning: "..obj.Name.." does not have a Primary Part!!!") end
					return obj
				else
					warn("Failed to find model for ID "..id..". Is assets package loaded?")
					return game.ReplicatedStorage.ObjectModels.Placeholder
				end
			end
		end
	end
end

-- Get the corresponding Object Class for this object ID
function module.GetClassFromID(id)
	module.WaitForAssetsToLoad()
	
	for objectType, objectIndex in pairs(module.Models) do
		for modelID, modelDetails in pairs(objectIndex) do
			if modelID == id then
				-- Found object ID
				if typeof(modelDetails) == "string" then
					warn("No corresponding object class for object ID: "..id)
					return objectC
				elseif typeof(modelDetails) == "table" then
					return modelDetails[2]
				else
					warn("Unexpected data type in Object Index for object ID: "..id)
					return objectC
				end
			end
		end
	end
end

-- Return the object type for the given object ID (Walls, Defenses, etc.)
function module.GetTypeFromID(id)
	module.WaitForAssetsToLoad()
	
	for objectType, objectIndex in pairs(module.Models) do
		for modelID, modelDetails in pairs(objectIndex) do
			if modelID == id then
				return objectType
			end
		end
	end
	
	warn("ID not found, or ObjectType not found for ID: "..id)
	return "Walls"
end

-- Return the Energy Needed to place the given object, or 0 if not placeable
function module.GetEnergyFromID(id)
	module.WaitForAssetsToLoad()
	
	for objectType, objectIndex in pairs(module.Models) do
		for modelID, modelDetails in pairs(objectIndex) do
			if modelID == id then
				-- Found object ID
				if typeof(modelDetails) == "string" then
					warn("No corresponding Energy Needed for object ID: "..id)
					return objectC
				elseif typeof(modelDetails) == "table" then
					if modelDetails[3] then
						print("Success! Energy needed to place "..id.." is "..modelDetails[4])
						return modelDetails[4]
					else
						warn("Object ID "..id.." is not placeable. Returning Energy Needed = 0")
					end
					return modelDetails[2]
				else
					warn("Unexpected data type in Object Index for object ID: "..id)
					return 0
				end
			end
		end
	end
	
	warn("ID not found when getting Energy Needed: "..id..". Returning 0")
	return 0
end

-- Return whether or not the given Object Type has placeable objects
function module.IsTypePlaceable(objType)
	for objectType, objectIndex in pairs(module.Models) do
		if objectType == objType then
			for modelID, modelDetails in pairs(objectIndex) do
				if typeof(modelDetails) == "table" and modelDetails[3] then
					-- There is at least one placeable object in this object type
					return true
				else
					return false
				end
			end
		end
	end
	
	warn("Didn't find object type "..objType.." when looking if it is placeable")
	return false
end

-- Get a readable Model Name from the given model ID
function module.GetNameFromID(id)
	module.WaitForAssetsToLoad()
	
	for objectType, objectIndex in pairs(module.Models) do
		for modelID, modelDetails in pairs(objectIndex) do
			if modelID == id then
				local path = "Model"
				if typeof(modelDetails) == "string" then
					path = modelDetails
				elseif typeof(modelDetails) == "table" then
					path = modelDetails[1]
				end
				local names = string.split(path, "/")
				local name = names[#names]
				local final = ""
				for i = 1, string.len(name) do
					local letter = string.sub(name, i, i)
					local code = string.byte(letter, 1, 1)
					if code == 48 then
						continue
					elseif code >= 65 and code <= 90 then
						final = final.." "..letter
					elseif code >= 49 and code <= 57 then
						final = final.." "..string.sub(name, i, string.len(name))
						return final
					else
						final = final..letter
					end
				end
				return final
			end
		end
	end
	
	warn("Didn't find model ID "..id.." when trying to get Model Name")
	return "Model"
end

-- Get a model number from an id. Example: "enemy01" --> 1
function module.GetModelNumberFromID(modelId)
	for i = 1, string.len(modelId) do
		local code = string.byte(modelId, i, i)
		if code >= 49 and code <= 57 then
			-- this char is a number 1-9
			return tonumber(string.sub(modelId, i, string.len(modelId)))
		end
	end
	warn("Couldn't get Model Number from id "..modelId..". Returning 0")
	return 0
end

-- Get Enemy Model ID from Base Level
function module.GetEnemyIDFromLevel(level)
	for enemyID, enemyDetails in pairs(module.Models.Enemies) do
		local enemyLevel = module.GetModelNumberFromID(enemyID)
		if enemyLevel == level then
			return enemyID
		end
	end
	warn("Couldn't find Enemy ID for level: "..level)
	return "enemy01"
end

return module
