-- @ScriptType: ModuleScript
local module = {}

local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local objectIndex = require(game.ReplicatedStorage:WaitForChild("ObjectIndex"))
local gridSystem = require(game.ReplicatedStorage:WaitForChild("GridSystem"))
local appearance = require(script:WaitForChild("Appearance"))
local getBaseObjectFunc = game.ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("GetBaseObject")
local getBaseEnergyFunc = game.ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("GetBaseEnergy")
local placeObjectEvent = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PlaceObject")

module.IsPlacing = false

-- Set up rotation preview handling
local rotation = 0
uis.InputBegan:Connect(function(input)
	if input.KeyCode and input.KeyCode == Enum.KeyCode.R and module.IsPlacing then
		rotation += 1
		if rotation >= 4 then rotation = 0 end
	end
end)

-- Preview model placement variables
local preview = nil
local coord = Vector3.new()
local previewConnection, placementConnection = nil

function module.StartPlacement(modelId)
	-- End any previous placement
	module.EndPlacement()
	
	module.IsPlacing = true
	
	-- Get player's Base Model
	local baseObject = getBaseObjectFunc:InvokeServer()
	if not baseObject then
		warn("BaseObject not loaded yet. Placement failed")
		module.EndPlacement()
		return
	end
	
	-- Create preview model
	preview = objectIndex.GetModelFromID(modelId):Clone()
	preview.Parent = game.Workspace
	mouse.TargetFilter = preview
	appearance.CanCollideOff(preview)
	
	-- Move preview model to correct Grid Coordinate, offset, and rotation given mouse position
	previewConnection = rs.RenderStepped:Connect(function()
		if not preview then return end
		
		-- Get Grid Coordinate from mouse position and camera/mouse unit ray
		local hit = mouse.Hit
		local offset = mouse.UnitRay.Direction * -0.25
		coord = gridSystem.GetCoordFromPos(baseObject.BaseModel, hit.Position + offset)
		
		-- Move model to correct CFrame
		gridSystem.MoveModelToGrid(baseObject.BaseModel, preview, modelId, coord, rotation)
		
	end)
	
	-- Place object when player clicks
	placementConnection = mouse.Button1Up:Connect(function()
		-- Check if object can be placed
		if not gridSystem.CanPlaceObject(baseObject, coord) then
			print(modelId.." can't be placed: Obstruction or out of bounds!")
			return
		end
		
		-- Check if player has enough energy points
		if getBaseEnergyFunc:InvokeServer() < objectIndex.GetEnergyFromID(modelId) then
			print(modelId.." can't be placed: Not enough energy!")
			return
		end
		
		-- Send request to place object
		placeObjectEvent:FireServer(modelId, coord, rotation)
		print("Place object event fired!")
		
		-- End Placement
		module.EndPlacement()
	end)
end

function module.EndPlacement()
	module.IsPlacing = false
	
	-- Disconnect placement and preview connection
	if placementConnection then placementConnection:Disconnect() end
	if previewConnection then previewConnection:Disconnect() end
	
	-- Destroy preview model
	if preview then
		preview:Destroy()
		preview = nil
	end
end



return module
