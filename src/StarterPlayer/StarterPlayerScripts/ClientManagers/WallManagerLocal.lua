local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local playerScripts = player.PlayerScripts

local ClientMod = require(playerScripts.ClientMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local Wall = require(playerScripts.Objects.WallLocal)

local WallInfo = require(game.ReplicatedStorage.Data.WallInfo)

local WallManager = {
	walls = {},
}
WallManager.__index = WallManager

function WallManager:init()
	self:initAllWalls()
end

function WallManager:initAllWalls()
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

	local wall = Wall.new(data)
	wall:init()

	self.walls[wallName] = wall
	return wall
end

function WallManager:updateAllWallData(data)
	for wallName, wallData in pairs(data) do
		local wall = self.walls[wallName]
		if not wall then
			warn("NO WALL FOUND: ", wallName)
			continue
		end
		wall:updateData(wallData)
	end
end

function WallManager:updateWallData(data)
	local wallName = data["wallName"]

	local wall = self.walls[wallName]
	if not wall then
		warn("NO WALL FOUND: ", wallName)
		return
	end

	wall:updateData(data)
end

WallManager:init()

return WallManager
