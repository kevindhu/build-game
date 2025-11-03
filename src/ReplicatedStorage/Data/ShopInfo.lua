local ShopInfo = {
	idMap = {},
}

ShopInfo["gamepassList"] = {
	"VIP",
	"2xBrainrotLuck",
	"2xCoins",
	"2MorePets",
}

ShopInfo["gamepasses"] = {
	["VIP"] = {
		alias = "VIP",
		description = "+20% strength and +20% move speed",
		id = 1392300408,
	},
}

ShopInfo["productList"] = {}

ShopInfo["products"] = {
	["BuyEgg1"] = {
		id = 3378332057,
		rewards = {
			premiumEggClass = "Egg1",
		},
	},
}

ShopInfo["currencies"] = {
	["Coins1"] = {
		alias = "Coins",
		id = 3365897403,

		rewards = {
			currencyClass = "Coins",
			count = 2500,
		},
	},
}

function ShopInfo:init()
	self.categoryList = {
		"gamepasses",
		"products",
		"currencies",
	}
	for _, categoryClass in pairs(self.categoryList) do
		local mods = self[categoryClass]
		for itemClass, mod in pairs(mods) do
			local id = mod["id"]

			-- map the ids to the classes
			self.idMap[id] = itemClass
		end
	end
end

function ShopInfo:getClassFromId(id)
	return ShopInfo.idMap[id]
end

function ShopInfo:getMeta(itemClass, noWarn)
	local Common = require(game.ReplicatedStorage.Common)
	return Common.getInfoMeta(self, itemClass, noWarn)
end

ShopInfo:init()

return ShopInfo
