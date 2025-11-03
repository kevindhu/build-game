local player = game.Players.LocalPlayer
local playerScripts = player.PlayerScripts
local playerGui = player.PlayerGui

local ClientMod = require(playerScripts.ClientMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

local User = require(playerScripts.Objects.UserLocal)

local UserManager = {
	users = {},
}
UserManager.__index = UserManager

function UserManager:init() end

function UserManager:addUser(data)
	local name = data["name"]
	if not name then
		return
	end

	local user = self.users[name]
	if user then
		-- warn("USER ALREADY EXISTS: " .. name)
		return
	end

	user = User.new(data)
	self.users[data["name"]] = user
	user:init()
end

function UserManager:updateUserOwnedGamepassMods(data)
	local userName = data["userName"]

	-- if userName == player.Name then
	-- 	ClientMod.shopManager:updateOwnedGamepassMods(data)
	-- end

	-- local user = self.users[userName]
	-- if not user then
	-- 	warn("USER NOT FOUND: " .. userName)
	-- 	return
	-- end
end

function UserManager:updateWalkspeed(data)
	local user = self:getLocalUser()
	if not user then
		return
	end
	user:updateWalkspeed(data)
end

function UserManager:getLocalUser()
	return self:getUser(player.Name)
end

function UserManager:getUser(name)
	return self.users[name]
end

function UserManager:removeUser(data)
	local name = data["name"]
	local user = self.users[name]
	if not user then
		warn("USER NOT FOUND: " .. name)
		return
	end

	user:destroy()
	self.users[name] = nil
end

function UserManager:tick(timeRatio)
	for _, user in pairs(self.users) do
		user:tick(timeRatio)
	end
end

UserManager:init()

return UserManager
