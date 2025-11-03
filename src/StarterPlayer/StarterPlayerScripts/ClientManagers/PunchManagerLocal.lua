local UserInputService = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local playerScripts = player.PlayerScripts

local ClientMod = require(playerScripts.ClientMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine

local PunchManager = {}

function PunchManager:init()
	self:addCons()
end

function PunchManager:addCons()
	UserInputService.InputBegan:Connect(function(input)
		if Common.listContains(Common.clickInputTypes, input.UserInputType) then
			self:tryHitWall()
		end
	end)
end

function PunchManager:tryHitWall()
	if self.punchExpiree and self.punchExpiree > Common.getCurrentDecimalTime() then
		return
	end
	self.punchExpiree = Common.getCurrentDecimalTime() + 0.2

	local user = ClientMod.userManager:getLocalUser()
	if not user then
		return
	end

	-- print("PUNCHING: ", user.name)

	ClientMod.animUtils:animate(user, {
		race = "Attack",
		animationClass = "Punch1",
	})

	ClientMod:FireServer("tryHitWall", {})
end

PunchManager:init()

return PunchManager
