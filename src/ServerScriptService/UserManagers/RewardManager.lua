local ServerMod = require(game.ServerScriptService.ServerMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local RewardManager = {}
RewardManager.__index = RewardManager

function RewardManager.new(user, data)
	local u = {}
	u.user = user
	u.data = data

	u.groupRewardClaimed = false

	setmetatable(u, RewardManager)
	return u
end

function RewardManager:init()
	for k, v in pairs(self.data) do
		self[k] = v
	end
end

function RewardManager:addRewards(rewardData)
	print("TODO: ADD REWARDS: ", rewardData)
end

function RewardManager:tryClaimGroupReward()
	if self.groupRewardClaimed then
		-- self.user:notifyError("You have already claimed the group reward!")
		return
	end
	if not Common.checkInGroup(self.user.player) then
		-- self.user:notifyError("Like and join group to claim!")
		return
	end

	self.groupRewardClaimed = true

	-- self.user:notifySuccess("Group reward claimed!")

	ServerMod:FireClient(self.user.player, "newSoundMod", {
		soundClass = "SuccessRebirth",
		volume = 0.5,
	})

	self:addRewards({
		itemMod = {
			itemName = "Coins",
			count = 500,
		},
	})
end

function RewardManager:saveState()
	local managerData = {
		groupRewardClaimed = self.groupRewardClaimed,
	}
	self.user.store:set(self.moduleAlias .. "Info", managerData)
end

function RewardManager:destroy() end

return RewardManager
