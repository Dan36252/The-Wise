-- @ScriptType: ModuleScript
local module = {}

-- DO NOT CHANGE THE GRID SIZE
module.GRID_SIZE = 4

local objectOffsets = require(game.ReplicatedStorage.ObjectOffsets)

-- Return a Vector3 position in the world from a given Vector3 gridPos coordinate, in a given base model
function module.GetPosFromCoord(baseModel, gridPos)
	local gridOrigin = baseModel.PlayerBase.GridOrigin
	local floorLevel = gridOrigin.FloorLevel
	local origin = floorLevel.WorldCFrame
	
	local xOffset = gridOrigin.CFrame.RightVector * gridPos.X * module.GRID_SIZE
	local yOffset = gridOrigin.CFrame.UpVector * gridPos.Y * module.GRID_SIZE
	local zOffset = gridOrigin.CFrame.LookVector * gridPos.Z * module.GRID_SIZE
	
	return origin.Position + xOffset + yOffset + zOffset
end

-- Get Grid Coordinate from a Vector3 position, in a given base model
function module.GetCoordFromPos(baseModel, pos)
	local gridOrigin = baseModel.PlayerBase.GridOrigin
	local floorLevel = gridOrigin.FloorLevel
	
	local origin = floorLevel.WorldCFrame
	local cframe = CFrame.new(pos)*origin.Rotation
	
	local offset = cframe:ToObjectSpace(origin):Inverse()

	local coordX = math.round(offset.X/module.GRID_SIZE)
	local coordY = math.round(offset.Y/module.GRID_SIZE)
	local coordZ = math.round(offset.Z/module.GRID_SIZE)

	return Vector3.new(coordX, coordY, coordZ)
end

-- Move a given model to the correct grid voxel, applying rotation and offset
function module.MoveModelToGrid(baseModel, model, id, gridPos, rotation)
	-- Move to model to center of correct grid voxel
	module.MoveModelToVoxelCenter(baseModel, model, gridPos)
	-- Apply rotation to model
	module.RotateModel(model, rotation)
	-- Apply offset to model
	module.OffsetModelByID(model, id)
end

-- Move a given model to the center of the correct grid voxel, without applying rotation or offset
function module.MoveModelToVoxelCenter(baseModel, model, gridPos)
	local gridOrigin = baseModel.PlayerBase.GridOrigin
	local floorLevel = gridOrigin.FloorLevel
	local origin = floorLevel.WorldCFrame

	local gridOffset = CFrame.new(gridPos.X * module.GRID_SIZE, gridPos.Y * module.GRID_SIZE, gridPos.Z * module.GRID_SIZE)

	model:PivotTo(origin * gridOffset)
end

-- Rotate a non-offsetted model by a given rotation (0, 1, 2, 3, etc.)
function module.RotateModel(model, rotation)
	local currentCFrame = model:GetPivot()
	local offsetCFrame = CFrame.Angles(0, math.rad(90) * rotation, 0)
	model:PivotTo(currentCFrame * offsetCFrame)
end

-- Offset a given model by the correct offset using ObjectOffsets module
function module.OffsetModelByID(model, id)
	-- Offset the model by the correct offset
	local success, err = pcall(function()
		model:PivotTo(model:GetPivot() * objectOffsets.GetOffsetFromID(id))
	end)
	
	-- If offset not found for the given id, give a warning
	if not success then
		if err then
			warn("Failed to offset model of ID "..id..": "..tostring(err)..". Does offset exist in ObjectOffsets?")
		end
	end
end

-- Return whether or not an object can be placed in a specific grid coordinate
function module.CanPlaceObject(baseObject, gridPos)
	-- Check if any existing blocks in this coordinate
	local occupied = false
	for i, object in ipairs(baseObject.Blocks) do
		if object.GridPos == gridPos then
			occupied = true
			return false
		end
	end
	
	-- Check if the coordinate is within base bounds
	local inBounds = false
	local gridFloor = baseObject.BaseModel.PlayerBase.GridFloor
	local maxCoordX = (gridFloor.Size.X/2) / module.GRID_SIZE
	local maxCoordZ = (gridFloor.Size.Z/2) / module.GRID_SIZE
	if gridPos.X < maxCoordX and gridPos.X > -maxCoordX and gridPos.Z < maxCoordZ and gridPos.Z > -maxCoordZ then
		inBounds = true
	else
		inBounds = false
		return false
	end
	
	-- In future, check if given grid voxel has an obstruction like a tree or rock
	
	return inBounds and not occupied
end

return module
