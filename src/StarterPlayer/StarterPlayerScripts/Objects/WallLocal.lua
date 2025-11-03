local player = game.Players.LocalPlayer
local playerScripts = player.PlayerScripts
local playerGui = player.PlayerGui

local ClientMod = require(playerScripts.ClientMod)

local WallInfo = require(game.ReplicatedStorage.Data.WallInfo)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local Wall = {}
Wall.__index = Wall

function Wall.new(data)
	local u = {}
	u.data = data

	u.health = 0
	u.maxHealth = 100

	setmetatable(u, Wall)
	return u
end

function Wall:init()
	local data = self.data
	for k, v in pairs(data) do
		self[k] = v
	end

	routine(function()
		self:initModel()
	end)
end

function Wall:updateData(data)
	for k, v in pairs(data) do
		self[k] = v
	end
	self:refreshWallPart()
end

function Wall:initModel()
	local model = game.Workspace:WaitForChild("WallModel"):Clone()
	model.Name = self.wallName
	model.Parent = game.Workspace.Walls

	self.model = model

	model.PrimaryPart.Transparency = 1

	local roadPart = game.Workspace:WaitForChild("RoadPart")
	local startFrame = roadPart.CFrame * CFrame.new(0, roadPart.Size.Y / 2, -roadPart.Size.Z / 2)

	local hOffset = model.PrimaryPart.Size.Y / 2
	local zOffset = model.PrimaryPart.Size.Z / 2
	local newFrame = startFrame * CFrame.new(0, hOffset, zOffset + (self.index - 1) * WallInfo.WALL_DISTANCE)

	model:SetPrimaryPartCFrame(newFrame)

	local wallPart = model.WallPart
	self.wallPart = wallPart

	local bb = wallPart.BB
	self.bb = bb

	bb.Frame.Title.Text = self.index

	self:refreshWallPart()
end

function Wall:refreshWallPart()
	if not self.wallPart then
		return
	end

	local healthRatio = self.health / self.maxHealth

	if healthRatio <= 0 then
		self:toggleWallPart(false)
		return
	end

	self:toggleWallPart(true)

	local bb = self.bb
	bb.Frame.HealthBar.CurrProgress.Size = UDim2.fromScale(healthRatio, 1)
	bb.Frame.HealthBar.Title.Text =
		string.format("%s/%s", Common.abbreviateNumber(self.health, 1), Common.abbreviateNumber(self.maxHealth, 1))
end

function Wall:toggleWallPart(newBool)
	if not self.wallPart then
		return
	end

	local wallPart = self.wallPart
	local bb = self.bb

	if newBool then
		wallPart.Transparency = 0
		wallPart.CanCollide = true
		bb.Enabled = true
	else
		wallPart.Transparency = 1
		wallPart.CanCollide = false
		bb.Enabled = false
	end
end

-- NOTE: no need to destroy on client
function Wall:destroy() end

return Wall
