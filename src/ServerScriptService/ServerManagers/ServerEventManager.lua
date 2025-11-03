local ServerMod = require(game.ServerScriptService.ServerMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local ServerEventManager = {}

function ServerEventManager:init()
	self:createMainEvent()
	self:addCons()
end

function ServerEventManager:createMainEvent()
	local event = Instance.new("RemoteEvent")
	event.Name = "MainEvent"
	event.Parent = game.ReplicatedStorage.Events
end

function ServerEventManager:addCons()
	local event = game.ReplicatedStorage.Events.MainEvent
	event.OnServerEvent:connect(function(player, req, ...)
		local fullData = { ... }
		local data = fullData[1]
		self:handleRequest(player, req, data)
	end)
end

function ServerEventManager:handleRequest(player, req, data)
	if req == "makeUser" then
		ServerMod.userManager:addUser(player)
		return
	end

	local user = ServerMod.userManager:getUser(player.Name)
	if not user then
		return
	end
	if not user.initialized or user.destroyed then
		-- warn("USER NOT AVAILABLE TO DO: " .. req)
		return
	end

	local shopManager = user.shopManager
	local rewardManager = user.rewardManager

	-- USER
	if req == "userDied" then
		user:die()

	-- REWARDMANAGER
	elseif req == "tryClaimGroupReward" then
		rewardManager:tryClaimGroupReward()

	-- SHOPMANAGER
	elseif req == "tryBuyGamepass" then
		shopManager:tryBuyGamepass(data)
	elseif req == "tryBuyProduct" then
		shopManager:tryBuyProduct(data)
	elseif req == "tryBuyPremium" then
		shopManager:tryBuyPremium(data)
	end
end

ServerEventManager:init()

return ServerEventManager
