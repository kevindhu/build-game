local player = game.Players.LocalPlayer
local playerScripts = player.PlayerScripts
local playerGui = player.PlayerGui

local ClientMod = require(playerScripts.ClientMod)

local currencyGUI = playerGui:WaitForChild("CurrencyGUI")
local coinsFrame = currencyGUI.LeftFrame.CoinsFrame
local powerFrame = currencyGUI.TopFrame.PowerFrame

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local CurrencyManager = {
	itemMods = {},
	lerpItemMods = {},
}

function CurrencyManager:init()
	self:addCons()
end

function CurrencyManager:addCons() end

function CurrencyManager:updateAllItemMods(data)
	local itemMods = data["itemMods"]
	for itemClass, count in pairs(itemMods) do
		self.itemMods[itemClass] = count
	end
end

function CurrencyManager:tickRender(timeRatio)
	for itemClass, itemMod in pairs(self.itemMods) do
		if not Common.listContains({ "Coins", "Power" }, itemClass) then
			return
		end

		local startValue = self.lerpItemMods[itemClass] or 0
		local endValue = self.itemMods[itemClass] or 0

		local lerpRatio = 0.1 * timeRatio
		local newValue = Common.lerp(startValue, endValue, lerpRatio)

		self.lerpItemMods[itemClass] = newValue

		if itemClass == "Coins" then
			local coinsString = Common.abbreviateNumber(math.round(newValue), 1)
			coinsFrame.Title.Text = coinsString
		elseif itemClass == "Power" then
			local powerString = Common.abbreviateNumber(math.round(newValue), 1)
			powerFrame.Title.Text = powerString
		end
	end
end

CurrencyManager:init()

return CurrencyManager
