local ServerMod = require(game.ServerScriptService.ServerMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local PunchManager = {}
PunchManager.__index = PunchManager

function PunchManager.new(user, data)
	local u = {}
	u.user = user
	u.data = data

	setmetatable(u, PunchManager)
	return u
end

function PunchManager:init()
	for k, v in pairs(self.data) do
		self[k] = v
	end
end

function PunchManager:getNearestWall(pos)
	local nearestWall = nil
	local nearestDistance = math.huge
	for _, wall in pairs(self.user.wallManager.walls) do
		local wallZPos = wall.currFrame.Position.Z
		local userZPos = pos.Z
		local distance = math.abs(wallZPos - userZPos)

		-- print(distance)

		if distance < nearestDistance then
			nearestDistance = distance
			nearestWall = wall
		end
	end

	if nearestDistance > 20 then
		-- warn("TOO FAR FROM WALL: ", nearestDistance)
		return nil
	end

	return nearestWall
end

function PunchManager:getDamage()
	local damage = self.user.currencyManager:getItemCount("Power")
	return damage
end

function PunchManager:tryHitWall(data)
	local pos = self.user.currFrame.Position
	local damage = self:getDamage()

	local wall = self:getNearestWall(pos)
	if not wall then
		return false
	end

	local wallIndex = wall.index
	for i = 1, wallIndex - 1 do
		local otherWallName = "WALL_" .. i
		local otherWall = self.user.wallManager.walls[otherWallName]
		if not otherWall then
			continue
		end
		if otherWall:checkToggled() then
			return false
		end
	end

	if self.punchExpiree and self.punchExpiree > Common.getCurrentDecimalTime() then
		return false
	end
	local bufferMultiplier = 0.9
	self.punchExpiree = Common.getCurrentDecimalTime() + 0.2 * bufferMultiplier

	-- print("PUNCHING WALL: ", wall.name)

	wall:updateHealth(-damage)
	return true
end

function PunchManager:saveState()
	local managerData = {}
	self.user.store:set(self.moduleAlias .. "Info", managerData)
end

return PunchManager
