local LeaderInfo = {}

LeaderInfo["leaderList"] = {
	-- "TopCoins",
}

LeaderInfo["leaders"] = {
	["TopCoins"] = {
		alias = "Top Cash",
		itemClass = "Coins",
	},
}

function LeaderInfo:init() end

function LeaderInfo:getMeta(name, noWarn)
	local Common = require(game.ReplicatedStorage.Common)
	self.categoryList = {
		"leaders",
	}
	return Common.getInfoMeta(self, name, noWarn)
end

LeaderInfo:init()

return LeaderInfo
