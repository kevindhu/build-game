local player = game.Players.LocalPlayer
local playerScripts = player.PlayerScripts
local playerGui = player.PlayerGui

local ClientMod = require(playerScripts.ClientMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local Leader = require(playerScripts.Objects.LeaderLocal)

local LeaderManager = {
	leaders = {},
}
LeaderManager.__index = LeaderManager

function LeaderManager:init() end

function LeaderManager:addLeader(data)
	local name = data[1]
	if self.leaders[name] then
		warn("LEADER ALREADY EXISTS, CANNOT ADD: ", name)
		return
	end

	local leader = Leader.new(data)
	leader:init()
	self.leaders[leader.name] = leader
end

function LeaderManager:updateLeaderUserMods(data)
	local name = data["name"]
	local leader = self.leaders[name]
	if not leader then
		return
	end
	leader:updateUserMods(data)
end

function LeaderManager:refreshLeaderUsernames()
	for _, leader in pairs(self.leaders) do
		leader:refreshUsernames()
	end
end

LeaderManager:init()

return LeaderManager
