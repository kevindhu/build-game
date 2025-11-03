local player = game.Players.LocalPlayer
local playerScripts = player.PlayerScripts
local playerGui = player.PlayerGui

local ClientMod = require(playerScripts.ClientMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local ClientEventManager = {}
ClientEventManager.__index = ClientEventManager

function ClientEventManager:init()
	local mainEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("MainEvent")
	mainEvent.OnClientEvent:connect(function(req, ...)
		local fullData = { ... }
		local data = fullData[1]

		self:handleRequest(req, data)
	end)
end

function ClientEventManager:handleRequest(req, data)
	local user = ClientMod.userManager:getLocalUser()
	if not user then
		print("NO LOCAL USER FOUND FOR REQUEST WHAAAAAAAT: ", req)
		return
	end

	-- FINISH INIT
	if req == "finishUserInit" then
		user:finishInit(data)

	-- USERMANAGER
	elseif req == "addUser" then
		ClientMod.userManager:addUser(data)
	elseif req == "updateUserOwnedGamepassMods" then
		ClientMod.userManager:updateUserOwnedGamepassMods(data)
	elseif req == "removeUser" then
		ClientMod.userManager:removeUser(data)
	elseif req == "updateWalkspeed" then
		ClientMod.userManager:updateWalkspeed(data)

	-- SHOPMANAGER
	elseif req == "toggleProductLoading" then
		ClientMod.shopManager:toggleProductLoading(data)

	-- WALLMANAGER
	elseif req == "updateWallData" then
		ClientMod.wallManager:updateWallData(data)
	elseif req == "updateAllWallData" then
		ClientMod.wallManager:updateAllWallData(data)

	-- LEADERMANAGER
	elseif req == "addLeader" then
		ClientMod.leaderManager:addLeader(data)
	elseif req == "updateLeaderUserMods" then
		ClientMod.leaderManager:updateLeaderUserMods(data)

	-- CURRENCYMANAGER
	elseif req == "updateCurrencyItemMods" then
		ClientMod.currencyManager:updateAllItemMods(data)

	-- COMMON UPDATES
	elseif req == "updateUsernameMap" then
		Common.updateUsernameMap(data)
		ClientMod.leaderManager:refreshLeaderUsernames()
	end
end

ClientEventManager:init()

return ClientEventManager
