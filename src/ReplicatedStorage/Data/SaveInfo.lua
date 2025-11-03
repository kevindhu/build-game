local Common = require(game.ReplicatedStorage.Common)

local SaveInfo = {
	VERSION = "ve.0.002",
	ODS_VERSION = "0.0.1",

	STUDIO_VERSION = "std.ve.0.0.0001",
	STUDIO_ODS_VERSION = "0.0.1",

	-- only enabled in studio!
	NO_SAVE = true,
}

-- if Common.isStudio then
-- 	SaveInfo.VERSION = SaveInfo.STUDIO_VERSION
-- 	SaveInfo.ODS_VERSION = SaveInfo.STUDIO_ODS_VERSION
-- end

return SaveInfo
