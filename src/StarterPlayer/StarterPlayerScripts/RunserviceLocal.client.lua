local RunService = game:GetService("RunService")

local player = game.Players.LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")
local playerGui = player:WaitForChild("PlayerGui")

local ClientMod = require(playerScripts:WaitForChild("ClientMod"))

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local ReplicatedModuleList = {
	{ "AnimUtils", "animUtils" },
	{ "TweenManager", "tweenManager" },
}

local ClientModuleList = {
	{ "ClientEventManager", "clientEventManager" },

	{ "DeviceManager", "deviceManager" },

	{ "UIManager", "uiManager" },
	{ "UIScaleManager", "uiScaleManager" },

	{ "ButtonManager", "buttonManager" },
	{ "UserManager", "userManager" },
	{ "LeaderManager", "leaderManager" },

	{ "CurrencyManager", "currencyManager" },
}

function LoadAllModules()
	local startTime = os.clock()

	for _, moduleInfo in ipairs(ReplicatedModuleList) do
		local moduleClass, moduleAlias = moduleInfo[1], moduleInfo[2]
		local module = require(game.ReplicatedStorage.SharedManagers[moduleClass])
		ClientMod[moduleAlias] = module
	end

	for _, moduleInfo in ipairs(ClientModuleList) do
		local moduleClass, moduleAlias = moduleInfo[1], moduleInfo[2]
		local module = require(playerScripts.ClientManagers:WaitForChild(moduleClass .. "Local"))
		ClientMod[moduleAlias] = module
	end

	print(("CLIENT LOAD MODULES: %.2f seconds"):format(os.clock() - startTime))
end

function LoadLocalUser()
	ClientMod.userManager:addUser({
		name = player.Name,
		player = player,
	})
end

local TickModuleList = {
	"userManager",
}
local TickRenderModuleList = {
	"currencyManager",
}

function StartTickEvents()
	RunService.Heartbeat:Connect(function(deltaTime)
		local timeRatio = deltaTime / (1 / 60)

		ClientMod:tick(timeRatio)

		for _, moduleName in ipairs(TickModuleList) do
			if ClientMod[moduleName] then
				ClientMod[moduleName]:tick(timeRatio)
			end
		end
	end)

	RunService.RenderStepped:Connect(function(deltaTime)
		local timeRatio = deltaTime / (1 / 60)

		for _, moduleName in ipairs(TickRenderModuleList) do
			if ClientMod[moduleName] then
				ClientMod[moduleName]:tickRender(timeRatio)
			end
		end
	end)
end

function Run()
	LoadAllModules()
	LoadLocalUser()
	StartTickEvents()
end

Run()
