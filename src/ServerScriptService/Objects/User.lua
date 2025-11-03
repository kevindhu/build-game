local PolicyService = game:GetService("PolicyService")

local ServerMod = require(game.ServerScriptService.ServerMod)
local Store = require(game.ServerScriptService.Datastore.Store)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local User = {}
User.__index = User

local LoadManagerList = {
	{ "ShopManager", "shopManager" },
	{ "StatManager", "statManager" },
	{ "BadgeManager", "badgeManager" },
	{ "RewardManager", "rewardManager" },
	{ "AnalyticsManager", "analyticsManager" },
	{ "WallManager", "wallManager" },
	{ "CurrencyManager", "currencyManager" },
	{ "PunchManager", "punchManager" },
}

local TickManagerList = {
	-- "shopManager",
}

local TickSecondModuleList = {}

local SaveManagerList = {
	"shopManager",
	"statManager",
	"badgeManager",
	"rewardManager",
	"currencyManager",
}

local DestroyManagerList = {}

local SyncManagerList = {}

function User.new(player)
	local self = {}
	self.player = player
	self.name = player.Name
	self.userId = player.UserId
	self.displayName = player.DisplayName

	self.respawnTimer = 1

	setmetatable(self, User)
	return self
end

function User:init()
	self:initPlayer()

	routine(function()
		self:initUserManagers()
		self:addRespawnCons()

		self.initialized = true

		local data = {}
		ServerMod:FireClient(self.player, "finishUserInit", data)

		routine(function()
			self.badgeManager:addBadge("Join")
		end)

		self:syncAllGlobalMods()

		-- self.analyticsManager:logFunnelStepEvent("UserSession", 1, "Joined", {})
	end)
end

function User:initPlayer()
	local success, policyMod = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(self.player)
	end)
	if success then
		self.policyMod = policyMod
	end

	self.funnelSessionId = self.userId .. "_" .. Common.getGUID()
end

function User:addRespawnCons()
	local player = self.player

	routine(function()
		local rig = player.Character or player.CharacterAdded:Wait()
		self:respawn(rig)
	end)

	player.CharacterAdded:Connect(function(rig)
		self:respawn(rig)
	end)
end

function User:respawn(rig)
	self.dead = false

	self:addRigCons(rig)
	self:tickCurrFrame()

	Common.setCollisionGroup(rig, "Players")
end

function User:addRigCons(rig)
	self.rig = rig
	rig.Parent = game.Workspace.UserRigs

	local rootPart = rig:FindFirstChild("HumanoidRootPart")
	self.rootPart = rootPart

	local spawnFrame = game.Workspace.SpawnLocation.CFrame * CFrame.new(0, 10, 0)
	rootPart:PivotTo(spawnFrame)

	local humanoid = self.rig:FindFirstChild("Humanoid")
	if humanoid then
		self:addHumanoidCons(humanoid)
	end
end

function User:addHumanoidCons(humanoid)
	self.humanoid = humanoid

	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	self:refreshWalkspeed()
end

function User:die()
	if self.dead then
		return
	end
	self.dead = true

	self.humanoid.Health = 0

	local timer = self.respawnTimer
	wait(timer)

	self:preventMemoryLeak()
	self.player:LoadCharacter()
end

function User:preventMemoryLeak()
	local player = self.player
	-- prevent memory leak? https://twitter.com/MrChickenRocket/status/1699005062360789405
	if player.Character then
		player.Character:Destroy()
		player.Character = nil
	end
end

function User:getWalkspeed()
	local newWalkspeed = 25

	-- finally add the multiplier at the end, so it stacks
	if self.shopManager:checkOwnsGamepass("VIP") then
		newWalkspeed = newWalkspeed * 1.2
	end
	return newWalkspeed
end

function User:refreshWalkspeed()
	local humanoid = self.humanoid
	if not humanoid then
		return
	end

	local newWalkspeed = self:getWalkspeed()
	humanoid.WalkSpeed = newWalkspeed

	ServerMod:FireClient(self.player, "updateWalkspeed", {
		newWalkspeed = newWalkspeed,
	})
end

function User:tickCurrFrame()
	local rootPart = self.rootPart
	if rootPart then
		local currFrame = rootPart.CFrame
		self.currFrame = currFrame
	end
end

function User:initUserManagers()
	if self.destroyed then
		return
	end

	local store = Store.new(self)
	store:init()
	self.store = store

	for _, moduleInfo in ipairs(LoadManagerList) do
		self:loadUserManager(moduleInfo[1], moduleInfo[2])
	end

	-- finish initing all usermanagers, can toggle saving
	self.store:toggleSave(true)

	return true
end

function User:loadUserManager(moduleName, moduleAlias)
	local store = self.store

	local defaultInfo = {
		isNew = true,
	}
	local managerInfo = store:get(moduleAlias .. "Info") or defaultInfo

	local UserManager = require(game.ServerScriptService.UserManagers[moduleName])

	local userManager = UserManager.new(self, managerInfo)
	userManager.moduleAlias = moduleAlias
	userManager:init()
	self[moduleAlias] = userManager
end

function User:tick(timeRatio)
	if not self.initialized then
		return
	end
	if self.destroyed then
		return
	end

	self:tickCurrFrame()

	for _, managerClass in pairs(TickManagerList) do
		local manager = self[managerClass]
		if not manager then
			continue
		end
		manager:tick(timeRatio)
	end
end

function User:tickSecond()
	for _, moduleName in ipairs(TickSecondModuleList) do
		local module = self[moduleName]
		if module then
			module:tickSecond()
		end
	end
end

function User:sync(otherUser)
	local data = {
		name = self.name,
		player = self.player,
	}
	ServerMod:FireClient(otherUser.player, "addUser", data)

	for _, moduleName in ipairs(SyncManagerList) do
		local module = self[moduleName]
		if module then
			module:sync(otherUser)
		end
	end
end

function User:syncAllGlobalMods()
	if self.destroyed then
		return
	end

	self:sync(self)

	for _, otherUser in pairs(ServerMod.userManager:getAllUsers()) do
		if otherUser == self or not otherUser.initialized or otherUser.destroyed then
			continue
		end
		otherUser:sync(self)
		self:sync(otherUser)
	end

	for _, leader in pairs(ServerMod.leaderManager:getAllLeaders()) do
		leader:sync(self)
	end

	routine(function()
		wait(2)
		-- retry syncing again just to make sure globalUsers are gotten
		if self.destroyed then
			return
		end

		-- retry syncing with self after waiting
		self:sync(self)

		-- retry syncing with others again after waiting
		for _, otherUser in pairs(ServerMod.userManager:getAllUsers()) do
			if otherUser == self or not otherUser.initialized or otherUser.destroyed then
				continue
			end
			otherUser:sync(self)
			self:sync(otherUser)
		end
	end)
end

function User:saveAllManagers()
	for _, managerClass in pairs(SaveManagerList) do
		local manager = self[managerClass]
		if not manager then
			continue
		end
		manager:saveState()
	end
end

function User:destroyAllManagers()
	local store = self.store
	if store then
		store:release()
	end

	for _, managerClass in pairs(DestroyManagerList) do
		local manager = self[managerClass]
		if not manager then
			continue
		end
		manager:destroy()
	end
end

function User:destroy()
	if self.destroyed then
		warn("ALREADY DESTROYED USER HUH: ", self.name)
		return
	end
	self.destroyed = true

	routine(function()
		self:saveAllManagers()
		self:destroyAllManagers()
	end)
end

return User
