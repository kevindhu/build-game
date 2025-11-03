local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local playerScripts = player.PlayerScripts

local ClientMod = require(playerScripts.ClientMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine

local UIManager = {}

function UIManager:init()
	self:addCons()
end

function UIManager:addCons() end

function UIManager:toggleOffAllGUI()
	local managerList = {}

	for _, managerClass in pairs(managerList) do
		if not ClientMod[managerClass] then
			continue
		end
		-- ClientMod[managerClass]:toggle({
		-- 	newBool = false,
		-- 	animateClose = false,
		-- 	noBlur = true,
		-- })
	end
end

UIManager:init()

return UIManager
