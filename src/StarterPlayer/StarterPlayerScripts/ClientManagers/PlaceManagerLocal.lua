local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local playerScripts = player.PlayerScripts
local playerGui = player.PlayerGui

local ClientMod = require(playerScripts.ClientMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local PlaceManager = {
	finalPlaceRotation = 0,
}
PlaceManager.__index = PlaceManager

function PlaceManager:init()
	self:addCons()
	routine(function()
		wait(1)
		self:initPlaceModel()
		self.initialized = true
	end)
end

local GRID_SIZE = 5

function PlaceManager:initPlaceModel()
	self.placeModel = game.Workspace:WaitForChild("BaseBlock"):Clone()
	self.placeModel.Parent = game.Workspace.PlaceModels

	local basePart = self.placeModel:WaitForChild("BasePart")
	local baseFrame = basePart.CFrame * CFrame.new(-basePart.Size.X / 2, -basePart.Size.Y / 2, -basePart.Size.Z / 2)

	for _, child in self.placeModel:GetDescendants() do
		if child:IsA("BasePart") then
			child.CanCollide = false
			child.Transparency = 0.5
		end
	end

	-- add rootPart
	local rootPart = Instance.new("Part")
	rootPart.Name = "RootPart"
	rootPart.Anchored = true
	rootPart.CanCollide = false
	rootPart.Color = Color3.fromRGB(255, 255, 255)
	rootPart.Size = Vector3.new(GRID_SIZE, GRID_SIZE, GRID_SIZE)
	rootPart.CFrame = baseFrame * CFrame.new(GRID_SIZE / 2, GRID_SIZE / 2, GRID_SIZE / 2)
	rootPart.Transparency = 1
	rootPart.Parent = self.placeModel
end

function PlaceManager:addCons()
	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:placeBlock()
		end
		-- if keycode is R then rotate the place model
		if input.KeyCode == Enum.KeyCode.R then
			self:rotatePlaceModel()
		end
	end)

	local plotPart = game.Workspace:WaitForChild("Plots"):WaitForChild("Plot1")
	local plotBasePos = plotPart.Position + Vector3.new(-plotPart.Size.X / 2, plotPart.Size.Y / 2, -plotPart.Size.Z / 2)

	self.plotBasePos = plotBasePos + Vector3.new(GRID_SIZE * 0.5, GRID_SIZE * 0.5, GRID_SIZE * 0.5)

	local line = Common.createTestLine(plotBasePos, plotBasePos + Vector3.new(0, 2, 0))
end

function PlaceManager:rotatePlaceModel()
	self.finalPlaceRotation = (self.finalPlaceRotation + 90) % 360
end

function PlaceManager:tick()
	if not self.initialized then
		return
	end

	self:movePlaceModel()
end

function PlaceManager:movePlaceModel()
	local placeFrame = self:getPlaceFrame()
	if not placeFrame then
		return
	end

	local placeModel = self.placeModel
	placeModel:SetPrimaryPartCFrame(placeFrame)
	placeModel.Parent = workspace
end

function PlaceManager:placeBlock()
	local placeFrame = self:getPlaceFrame()
	if not placeFrame then
		return
	end

	-- print("PLACING BLOCK")

	local block = game.Workspace:WaitForChild("BaseBlock"):Clone()
	block:SetPrimaryPartCFrame(placeFrame)
	block.PrimaryPart.Transparency = 1
	block.Name = "Block_" .. Common.getGUID()
	block.Parent = game.Workspace.Blocks
end

function PlaceManager:getPlaceFrame()
	-- raycast from the mouse position
	local mouse = player:GetMouse()
	local ray = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)

	local whiteList = {
		workspace.Blocks,
		workspace.Plots,
	}
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = whiteList
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist

	local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)

	if not hit then
		-- warn("NO HIT FOUND")
		return
	end

	local gridStartFrame = CFrame.new()
	local rotationFrame = Common.getCAngle(gridStartFrame) * CFrame.Angles(0, math.rad(self.finalPlaceRotation), 0)

	local rayPos = hit.Position
	local normal = hit.Normal

	rayPos = rayPos + normal * GRID_SIZE * 0.5

	-- Get the model and calculate offset between RootPart and PrimaryPart
	local placeModel = self.placeModel
	local basePart = placeModel.PrimaryPart
	local rootPart = placeModel.RootPart

	-- get the rotation first
	placeModel:PivotTo(rotationFrame)

	-- Calculate offset (RootPart position relative to PrimaryPart)
	local offsetPos = rootPart.Position - basePart.Position
	-- Only consider X and Z for horizontal placement
	offsetPos = Vector3.new(offsetPos.X, 0, offsetPos.Z)

	-- Apply offset to raycast position to get where the model center should be
	local currPos = rayPos + offsetPos

	-- Calculate position relative to the plot's base position
	local relativePos = currPos - self.plotBasePos

	-- Snap to grid - this is where the model CENTER will be snapped
	local snappedRelative = Vector3.new(
		(math.round(relativePos.X / GRID_SIZE)) * GRID_SIZE,
		(math.round(relativePos.Y / GRID_SIZE)) * GRID_SIZE,
		(math.round(relativePos.Z / GRID_SIZE)) * GRID_SIZE
	)

	-- This is the snapped grid position for the model center
	local gridPos = self.plotBasePos + snappedRelative

	-- Calculate the RootPart CFrame (subtract offset, apply rotation)
	local placeFrame = CFrame.new(gridPos - offsetPos) * rotationFrame
	return placeFrame
end

PlaceManager:init()

return PlaceManager
