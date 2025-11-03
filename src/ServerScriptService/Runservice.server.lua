local ServerMod = require(game.ServerScriptService.ServerMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local ServerModuleList = {
	{ "MapManager", "mapManager" },
	{ "PhysicsManager", "physicsManager" },

	{ "ServerEventManager", "serverEventManager" },
	{ "ServerStoreManager", "serverStoreManager" },

	{ "UserManager", "userManager" },
	{ "MarketManager", "marketManager" },

	{ "TeleportManager", "teleportManager" },
	{ "LeaderManager", "leaderManager" },
}

local ReplicatedModuleList = {
	{ "AnimUtils", "animUtils" },
	{ "TweenManager", "tweenManager" },
}

function LoadAllModules()
	for _, moduleData in pairs(ServerModuleList) do
		local moduleClass, moduleAlias = moduleData[1], moduleData[2]
		local module = require(game.ServerScriptService.ServerManagers[moduleClass])
		ServerMod[moduleAlias] = module
	end

	for _, moduleData in pairs(ReplicatedModuleList) do
		local moduleClass, moduleAlias = moduleData[1], moduleData[2]
		local module = require(game.ReplicatedStorage.SharedManagers[moduleClass])
		ServerMod[moduleAlias] = module
	end
end

function TickSecond()
	-- tick users
	for _, user in pairs(ServerMod.userManager:getAllUsers()) do
		user:tickSecond()
	end

	-- tick leaders
	for _, leader in pairs(ServerMod.leaderManager:getAllLeaders()) do
		leader:tickSecond()
	end
end

function StartAllEvents()
	game.Players.PlayerRemoving:Connect(function(player)
		ServerMod.userManager:removeUser(player)
	end)

	-- SERVER TICK EVENTS
	game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
		local timeRatio = deltaTime / (1 / 60)
		ServerMod:tick(timeRatio)

		for _, user in pairs(ServerMod.userManager:getAllUsers()) do
			user:tick(timeRatio)
		end
	end)

	routine(function()
		while true do
			routine(function()
				local success, err = pcall(function()
					TickSecond()
				end)
				if not success then
					warn("############# TICK SECOND FAILED: ", err)
				end
			end)
			wait(1)
		end
	end)
end

function Run()
	LoadAllModules()
	StartAllEvents()
end

Run()
