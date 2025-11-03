local localPlayer = game.Players.LocalPlayer
local playerScripts = localPlayer.PlayerScripts
local playerGui = localPlayer.PlayerGui

local ClientMod = require(playerScripts.ClientMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local User = {}
User.__index = User

function User.new(data)
	local u = {}
	u.data = data

	u.baseWalkspeed = 16

	setmetatable(u, User)
	return u
end

function User:init()
	local data = self.data
	for k, v in pairs(data) do
		self[k] = v
	end

	local player = self.player
	self.userId = player.UserId

	self:addRigCons()

	routine(function()
		if self:isPlayerUser() then
			ClientMod:FireServer("makeUser")
		end
	end)
end

function User:addRigCons()
	local player = self.player
	routine(function()
		local rig = player.Character or player.CharacterAdded:Wait()
		self:respawn(rig)
	end)
	player.CharacterAdded:Connect(function(rig)
		self:respawn(rig)
	end)
end

function User:updateWalkspeed(data)
	local newWalkspeed = data["newWalkspeed"]
	self.baseWalkspeed = newWalkspeed
end

function User:refreshWalkspeed()
	if not self:isPlayerUser() then
		warn("NOT PLAYER USER CANNOT REFRESH WALKSPEED: ", self.name)
		return
	end

	local humanoid = self.humanoid
	if not humanoid then
		return
	end

	humanoid.WalkSpeed = self.baseWalkspeed
end

function User:respawn(rig)
	ClientMod.animUtils:clearEntity(self)

	local rootPart = rig:WaitForChild("HumanoidRootPart", 10)
	local humanoid = rig:WaitForChild("Humanoid", 10)

	self.rootPart = rootPart
	self.humanoid = humanoid
	self.rig = rig

	if not rootPart or not humanoid then
		warn("!!! NO ROOT PART OR HUMANOID FOUND FOR RESPAWN: ", self.name)
		return
	end
	self.currFrame = rootPart.CFrame
end

function User:tick(timeRatio)
	self:tickCurrFrame(timeRatio)
	-- self:tickWalkSpeed()
end

function User:tickWalkSpeed()
	local humanoid = self.humanoid
	if not humanoid then
		return
	end

	local baseWalkspeed = self.baseWalkspeed
	humanoid.WalkSpeed = baseWalkspeed
end

function User:isPlayerUser()
	return self.name == localPlayer.Name
end

function User:tickCurrFrame(timeRatio)
	local rootPart = self.rootPart
	if not rootPart then
		return
	end

	local newCurrFrame = rootPart.CFrame
	self.currFrame = newCurrFrame
end

-- only works if isPlayerUser
function User:finishInit()
	self.initialized = true
end

function User:destroy()
	if self.destroyed then
		return
	end
	self.destroyed = true

	-- TODO: add more destroy methods here
end

return User
