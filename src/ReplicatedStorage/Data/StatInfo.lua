local StatInfo = {}

StatInfo.statList = {
	"Playtime",
	"RobuxSpent",

	"Coins",
}

StatInfo["stats"] = {
	["Playtime"] = {
		alias = "Playtime",
		defaultCount = 0,
		colonNotation = true,
	},
	["RobuxSpent"] = {
		alias = "Robux Spent",
		defaultCount = 0,
		robuxNotation = true,
	},

	-- currencies
	["Coins"] = {
		alias = "Coins",
		defaultCount = 0,
		abbreviateNum = true,
	},

	-- total currencies
	["TotalCoins"] = {
		alias = "Coins",
		defaultCount = 0,
		abbreviateNum = true,
	},
}

function StatInfo:init()
	self.categoryList = {
		"stats",
	}
	for index, statClass in pairs(self.statList) do
		local statData = self.stats[statClass]
		statData["index"] = index
	end
end

function StatInfo:getMeta(itemClass, noWarn)
	local Common = require(game.ReplicatedStorage.Common)
	return Common.getInfoMeta(self, itemClass, noWarn)
end

StatInfo:init()

return StatInfo
