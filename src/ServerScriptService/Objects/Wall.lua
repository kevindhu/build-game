local ServerMod = require(game.ServerScriptService.ServerMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local WallInfo = require(game.ReplicatedStorage.Data.WallInfo)

local Wall = {}
Wall.__index = Wall

function Wall.new(user, data)
	local self = {}
	self.user = user
	self.data = data

	setmetatable(self, Wall)
	return self
end

function Wall:init()
	for k, v in pairs(self.data) do
		self[k] = v
	end

	self.maxHealth = self:getMaxHealth(self.index)
	self.health = self.maxHealth

	self:initCurrFrame()

	-- routine(function()
	-- 	wait(Common.randomBetween(1, 3))
	-- 	self:updateHealth(-Common.randomBetween(1, 1000))
	-- end)
end

function Wall:initCurrFrame()
	local roadPart = game.Workspace:WaitForChild("RoadPart")
	local startFrame = roadPart.CFrame * CFrame.new(0, roadPart.Size.Y / 2, -roadPart.Size.Z / 2)

	local baseModel = game.Workspace.WallModel
	local hOffset = baseModel.PrimaryPart.Size.Y / 2
	local zOffset = baseModel.PrimaryPart.Size.Z / 2
	self.currFrame = startFrame * CFrame.new(0, hOffset, zOffset + (self.index - 1) * WallInfo.WALL_DISTANCE)
end

function Wall:updateHealth(amount)
	self.health += amount
	self.health = math.clamp(self.health, 0, self.maxHealth)
	self:sendData()
end

function Wall:checkToggled()
	if self.health <= 0 then
		return false
	end
	return true
end

function Wall:getMaxHealth(index)
	local health = 100 * (1.397 ^ index)
	health = math.round(health)
	return health
end

function Wall:getData()
	return {
		wallName = self.wallName,

		health = self.health,
		maxHealth = self.maxHealth,
	}
end

function Wall:sendData()
	ServerMod:FireClient(self.user.player, "updateWallData", self:getData())
end

function Wall:destroy()
	if self.destroyed then
		warn("ALREADY DESTROYED USER HUH: ", self.name)
		return
	end
	self.destroyed = true
end

return Wall
