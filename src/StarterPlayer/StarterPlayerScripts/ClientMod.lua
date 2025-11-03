local ContextActionService = game:GetService("ContextActionService")

local player = game.Players.LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")
local playerGui = player:WaitForChild("PlayerGui")

local Common = require(game.ReplicatedStorage.Common)

local mainEvent = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("MainEvent")

local ClientMod = {
	step = 0,
}

function ClientMod:init()
	self:addCons()
end

function ClientMod:addCons() end

function ClientMod:FireServer(...)
	mainEvent:FireServer(...)
end

function ClientMod:tick(timeRatio)
	self.step += 1 * timeRatio
end

ClientMod:init()

return ClientMod
