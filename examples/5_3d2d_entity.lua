AddCSLuaFile()

function ENT:Initialize()
	self:SetModel("models/props_c17/consolebox01a.mdl")

	if (SERVER) then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	end
end

if (CLIENT) then
	local circles = include("circles.lua")
	local circle = circles.New(CIRCLE_OUTLINED, 256, 256, 256, 50)

	function ENT:Draw()
		self:DrawModel()

		-- If we don't do this then the entire screen would have the halo effect when the entity has a halo applied to it.
		-- You don't have to have this check for CIRCLE_FILLED type circles.
		if (halo.RenderedEntity() ~= self) then
			local min, max = self:GetRenderBounds()

			-- Get the angle and position to render the circle at.
			local ang = self:LocalToWorldAngles(Angle(0, 90, 0))
			local pos = self:LocalToWorld(Vector(min.x, min.y, max.z))

			-- CIRCLE_BLURRED type circles won't work in 3D2D.
			-- You'd have to use a CIRCLE_FILLED circle and do the blur yourself.

			cam.Start3D2D(pos, ang, 0.0625)
				circle()
			cam.End3D2D()
		end
	end
end
