local ContentProvider = game:GetService("ContentProvider")

local AnimInfo = {}

local Common = require(game.ReplicatedStorage.Common)
local len, routine = Common.len, Common.routine

AnimInfo["baseAnimations"] = {
	["UserIdle"] = 180435571,
	["UserRun"] = 180426354,

	["HoldStashTool"] = 117729271251640,

	["Punch1"] = 92909965529494,
}

AnimInfo["animationGroups"] = {
	["FoeHurt"] = {
		14742703757, -- EnemyHurt1
		14742708229, -- EnemyHurt2
		14742712593, -- EnemyHurt3
	},
}

function AnimInfo:init()
	self.categoryList = {
		"baseAnimations",
	}

	-- self:preloadAnimations()
end

function AnimInfo:preloadAnimations()
	if Common.isServer then
		return
	end

	routine(function()
		local animations = {}
		for _, category in pairs(self.categoryList) do
			for _, animationId in pairs(self[category]) do
				if animationId == -1 then
					continue
				end

				local animation = Instance.new("Animation")
				animation.AnimationId = "rbxassetid://" .. animationId
				table.insert(animations, animation)
			end
		end

		for _, animationIds in pairs(self.animationGroups) do
			for _, animationId in pairs(animationIds) do
				local animation = Instance.new("Animation")
				animation.AnimationId = "rbxassetid://" .. animationId
				table.insert(animations, animation)
			end
		end

		ContentProvider:PreloadAsync(animations)
	end)
end

function AnimInfo:getMeta(itemClass, noWarn)
	return Common.getInfoMeta(self, itemClass, noWarn)
end

AnimInfo:init()

return AnimInfo
