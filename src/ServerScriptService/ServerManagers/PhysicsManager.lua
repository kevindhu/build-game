local PhysicsService = game:GetService("PhysicsService")

local PhysicsManager = {}
PhysicsManager.__index = PhysicsManager

function PhysicsManager:init()
	self:registerPhysics()
end

function PhysicsManager:registerPhysics()
	-- register groups
	PhysicsService:RegisterCollisionGroup("Players")
	PhysicsService:RegisterCollisionGroup("Misc")

	-- set player collide groups
	PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)
	PhysicsService:CollisionGroupSetCollidable("Players", "Misc", false)
end

PhysicsManager:init()

return PhysicsManager
