local MapManager = {}

local ServerMod = require(game.ServerScriptService.ServerMod)

local Common = require(game.ReplicatedStorage.Common)
local len, routine, wait = Common.len, Common.routine, Common.wait

function MapManager:init()
	self:initFolders()
end

function MapManager:initFolders()
	-- first create replicated folders
	local replicatedStorageFolders = {
		"Events",
	}
	for _, folderName in pairs(replicatedStorageFolders) do
		local folder = Instance.new("Folder")
		folder.Name = folderName
		folder.Parent = game.ReplicatedStorage
	end

	-- then create workspace folders
	local workspaceFolders = {
		-- globals
		"HitBoxes",
		"GlobalSounds",
		"MusicFolder",

		-- rigs
		"UserRigs",
	}
	for _, folderName in pairs(workspaceFolders) do
		local folder = Instance.new("Folder")
		folder.Name = folderName
		folder.Parent = game.Workspace
	end
end

MapManager:init()

return MapManager
