local ServerMod = require(game.ServerScriptService.ServerMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local Wall = require(game.ServerScriptService.Objects.Wall)

local WallInfo = require(game.ReplicatedStorage.Data.WallInfo)

local WallManager = {}
WallManager.__index = WallManager

function WallManager.new(user, data)
	local u = {}
	u.user = user
	u.data = data

	u.walls = {}

	setmetatable(u, WallManager)
	return u
end

function WallManager:init()
	for k, v in pairs(self.data) do
		self[k] = v
	end

	routine(function()
		self:initWalls()
		self:sendAllWallData()
	end)
end

function WallManager:sendAllWallData()
	local fullWallData = {}
	for _, wall in pairs(self.walls) do
		fullWallData[wall.wallName] = wall:getData()
	end

	ServerMod:FireClient(self.user.player, "updateAllWallData", fullWallData)
end

function WallManager:initWalls()
	for i = 1, WallInfo.TOTAL_WALLS do
		local data = {
			index = i,
		}
		self:addWall(data)
	end
end

function WallManager:addWall(data)
	local wallName = "WALL_" .. data["index"]
	data["wallName"] = wallName

	local wall = Wall.new(self.user, data)
	wall:init()

	self.walls[wallName] = wall
	return wall
end

return WallManager
