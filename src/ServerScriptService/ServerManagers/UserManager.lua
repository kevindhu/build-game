local ServerMod = require(game.ServerScriptService.ServerMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local User = require(game.ServerScriptService.Objects.User)

local UserManager = {
	users = {},
}
UserManager.__index = UserManager

function UserManager:init() end

function UserManager:addUser(player)
	if self.users[player.Name] then
		warn("ALREADY HAVE THIS USER WHAAT: ", player.Name)
		return
	end

	local user = User.new(player)
	routine(function()
		user:init()
	end)

	-- FIRST put it in the storage so you can send events!
	self.users[user.name] = user
end

function UserManager:getUser(name)
	return self.users[name]
end

function UserManager:getUserFromUserId(userId)
	for _, user in pairs(self.users) do
		if user.userId == userId then
			return user
		end
	end
	return nil
end

function UserManager:removeUser(player)
	local user = self.users[player.Name]
	if not user then
		warn("NO USER TO REMOVE: ", player.Name)
		return
	end
	user:destroy()
	self.users[player.Name] = nil
end

function UserManager:getAllUsers()
	return self.users
end

return UserManager
