-- @ScriptType: ModuleScript
local module = {}

local placement = require(script.Parent:WaitForChild("Placement"))
local objectIndex = require(game.ReplicatedStorage:WaitForChild("ObjectIndex"))
local gridSystem = require(game.ReplicatedStorage:WaitForChild("GridSystem"))
local getBaseLevel = game.ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("GetBaseLevel")
local addKnowledgeEvent = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AddKnowledge")

local screenGui = script.Parent.Parent
local background = screenGui:WaitForChild("Background")
local buildButton = screenGui:WaitForChild("BuildButton")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local templateMenu = background:WaitForChild("TemplateMenu")
local templateFrame = templateMenu:WaitForChild("TemplateFrame")
templateFrame.Parent = game.ReplicatedStorage:WaitForChild("Templates")
templateMenu.Parent = game.ReplicatedStorage:WaitForChild("Templates")

local buildMenu = background:WaitForChild("BuildMenu")
local templateButton = buildMenu:WaitForChild("TemplateButton")
templateButton.Parent = game.ReplicatedStorage:WaitForChild("Templates")

module.BuildMenu = {"wall01", "turret01"}

local objectMenus = {}
local objectMenuOpen = false

function module.Initialize()
	
	-- LEFT OFF:
	-- Initialize Build Menu and all Object Menus, if they have placeable objects.
	-- Knowledge will be Base-Independent; stored for each Player, and saved across new Bases.
	-- Make robots break walls.
	-- First make DataStore saving, then loading. No base slots for now.
	-- When current base is disabled (lost), Base Data erased and player must start over.
	
	module.RefreshBuildMenu()
	
	addKnowledgeEvent.OnClientEvent:Connect(module.RefreshBuildMenu)
	
	hum.Died:Connect(module.CloseGui)
end

function module.OpenGui()
	background.Visible = true
	buildButton.Text = "Loading..."
	module.RefreshBuildMenu()
	if background.Visible then buildButton.Text = "Close" end
end

function module.CloseGui()
	placement.EndPlacement()
	background.Visible = false
	
	module.CloseAllObjectMenus()
	buildButton.Text = "Build"
	objectMenuOpen = false
end

function module.ToggleGui()
	if objectMenuOpen then
		module.CloseAllObjectMenus()
	else
		if background.Visible then
			module.CloseGui()
		else
			module.OpenGui()
		end
	end
end

function module.RefreshBuildMenu()
	-- Fill the Build Menu with buttons that stand for each placeable Object Type
	local index = objectIndex.Models
	for objectType, objects in pairs(index) do
		if objectIndex.IsTypePlaceable(objectType) then
			-- Create Object Type button in Build Menu
			if not buildMenu:FindFirstChild(objectType) then
				local b = templateButton:Clone()
				b.Name = objectType
				b.Text = objectType
				b.MouseButton1Up:Connect(function()
					module.CloseAllObjectMenus()
					module.OpenObjectMenu(objectType)
				end)
				b.Parent = buildMenu
			end
			
			-- Create corresponding Object Menu
			module.UpdateObjectMenu(objectType)
		end
	end
end

function module.UpdateObjectMenu(objectType)
	-- Create/Find a menu for the specific object type
	local menu = background:FindFirstChild(objectType)
	if not menu then
		menu = templateMenu:Clone()
		menu.Name = objectType
		menu.Visible = false
		menu.Parent = background
		objectMenus[objectType] = menu
	end
	
	-- Create/Update button frames for each object in this category
	local index = objectIndex.Models
	for modelID, modelDetails in pairs(index[objectType]) do
		if typeof(modelDetails) == "table" and modelDetails[3] then
			-- Find or create button for this modelID
			local frame = menu:FindFirstChild(modelID)
			if not frame then
				--print("Creating new button for "..modelID)
				frame = templateFrame:Clone()
				frame.Name = modelID
				frame.Parent = menu
				frame.TextLabel.Text = objectIndex.GetNameFromID(modelID)
				
				local model = objectIndex.GetModelFromID(modelID):Clone()
				model.Parent = workspace
				model:MoveTo(Vector3.new())
				model.Parent = frame
				
				local viewCam = Instance.new("Camera", frame)
				viewCam.CFrame = CFrame.new(Vector3.new(5, 3, 5), Vector3.new())
				frame.CurrentCamera = viewCam
				
				-- Set up Start Placement when button is clicked
				frame.Button.MouseButton1Click:Connect(function()
					local buttonLevel = modelDetails[5]
					local baseLevel = getBaseLevel:InvokeServer()
					local energyNeeded = modelDetails[4]
					
					if buttonLevel and baseLevel and buttonLevel <= baseLevel then
						placement.StartPlacement(modelID)
					end
				end)
			end
			
			-- Update button details
			local buttonLevel = modelDetails[5]
			local baseLevel = getBaseLevel:InvokeServer()
			local energyNeeded = modelDetails[4]
			if buttonLevel and baseLevel then
				if buttonLevel <= baseLevel then
					frame.Button.Text = tostring(energyNeeded).." Energy"
					frame.Button.TextColor3 = Color3.new(1,1,1)
				else
					frame.Button.Text = "(Base Level "..tostring(buttonLevel)..")"
					frame.Button.TextColor3 = Color3.new(1,0,0)
				end
			else
				frame.Button.Text = "-"
				frame.Button.TextColor3 = Color3.new(1,0.3,0)
			end
			
		end
	end
	
	--b.MouseButton1Up:Connect(function()
	--	placement.EndPlacement()
	--	placement.StartPlacement(v)
	--end)
end

-- Open a specific Object Menu
function module.OpenObjectMenu(objectType)
	if objectMenus[objectType] then
		objectMenus[objectType].Visible = true
		objectMenuOpen = true
		buildButton.Text = "Back"
	end
end

-- Close all open Object Menus
function module.CloseAllObjectMenus()
	buildButton.Text = "Close"
	placement.EndPlacement()
	for objectType, menuFrame in pairs(objectMenus) do
		menuFrame.Visible = false
	end
	objectMenuOpen = false
end

return module
