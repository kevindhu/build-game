local ServerMod = require(game.ServerScriptService.ServerMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local CurrencyManager = {}
CurrencyManager.__index = CurrencyManager

function CurrencyManager.new(user, data)
	local u = {}
	u.user = user
	u.data = data

	u.itemMods = {}

	setmetatable(u, CurrencyManager)
	return u
end

function CurrencyManager:init()
	for k, v in pairs(self.data) do
		self[k] = v
	end

	self:sendAllItemMods()

	routine(function()
		wait(2)

		self:updateItemMod({
			itemClass = "Power",
			count = 100,
		})

		self:updateItemMod({
			itemClass = "Coins",
			count = 100,
		})
	end)
end

function CurrencyManager:getItemCount(itemClass)
	return self.itemMods[itemClass] or 0
end

function CurrencyManager:updateItemMod(data)
	local itemClass = data["itemClass"]
	local count = data["count"]

	if not self.itemMods[itemClass] then
		self.itemMods[itemClass] = 0
	end
	self.itemMods[itemClass] += count

	if count > 0 then
		self.user.statManager:incrementStatMod("Coins", count)
	end

	self:sendAllItemMods()
end

function CurrencyManager:sendAllItemMods()
	ServerMod:FireClient(self.user.player, "updateCurrencyItemMods", {
		itemMods = self.itemMods,
	})
end

function CurrencyManager:saveState()
	local managerData = {
		itemMods = self.itemMods,
	}
	self.user.store:set(self.moduleAlias .. "Info", managerData)
end

return CurrencyManager
