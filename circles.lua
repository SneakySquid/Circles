local CIRCLE = {}
local blur = Material("pp/blurscreen")

CIRCLE_FILLED = 0
CIRCLE_OUTLINED = 1
CIRCLE_BLURRED = 2

CIRCLE.__index = CIRCLE
CIRCLE.__tostring = function(self)
	return string.format("Circle [%i][%i]", self.Type, self.R)
end

CIRCLE.Type = CIRCLE_FILLED

CIRCLE.X = 0
CIRCLE.Y = 0
CIRCLE.R = 0

CIRCLE.Rotation = 0
CIRCLE.Thickness = 1
CIRCLE.Quality = 2
CIRCLE.Density = 3

CIRCLE.StartAngle = 0
CIRCLE.EndAngle = 360

AccessorFunc(CIRCLE, "R", "Radius", FORCE_NUMBER)
AccessorFunc(CIRCLE, "Rotation", "Rotation", FORCE_NUMBER)
AccessorFunc(CIRCLE, "Thickness", "Thickness", FORCE_NUMBER)
AccessorFunc(CIRCLE, "Quality", "Quality", FORCE_NUMBER)
AccessorFunc(CIRCLE, "Density", "Density", FORCE_NUMBER)

function CIRCLE:SetRadius(r)
	if (self.R == r) then return end

	self.R = r
	self.Vertices = nil
	self.InnerCircle = nil
end

function CIRCLE:SetDiameter(d)
	self:SetRadius(d / 2)
end

function CIRCLE:SetRotation(rotation)
	if (self.Rotation == rotation) then return end

	self.Rotation = rotation
	self.Vertices = nil
end

function CIRCLE:SetThickness(thicc)
	if (self.Thickness == thicc) then return end

	self.Thickness = thicc
	self.InnerCircle = nil
end

function CIRCLE:SetPos(x, y)
	if (self.X == x and self.Y == Y) then return end

	self.X = x
	self.Y = y

	self.Vertices = nil
end

function CIRCLE:SetAngles(start, finish)
	if (self.StartAngle == start and self.EndAngle == finish) then return end

	self.StartAngle = start
	self.EndAngle = finish

	self.Vertices = nil
end

function CIRCLE:ScaleVertices(x, y)
	if not (self.Vertices) then
		self:Calculate()
	end

	for i, v in ipairs(self.Vertices) do
		v.x = v.x * x
		v.y = v.y * y
	end
end

function CIRCLE:OffsetVertices(x, y)
	if not (self.Vertices) then
		self:Calculate()
	end

	for i, v in ipairs(self.Vertices) do
		v.x = v.x + x
		v.y = v.y + y
	end
end

function CIRCLE:Calculate()
	local r = self.R
	local x, y = self.X, self.Y
	local start, finish = self.StartAngle, self.EndAngle

	local verts, dist = {}, 360 / (2 * math.pi * r / 2)

	if (math.abs(start - finish) ~= 360) then
		table.insert(verts, {
			x = x,
			y = y,

			u = 0.5,
			v = 0.5,
		})
	end

	for a = start, finish + dist, dist do
		a = math.max(start, math.min(finish, a))

		local rad = math.rad(a)
		local rot = math.rad(self.Rotation)

		table.insert(verts, {
			x = x + math.cos(rad + rot) * r,
			y = y + math.sin(rad + rot) * r,

			u = math.cos(rad - rot) / 2 + 0.5,
			v = math.sin(rad - rot) / 2 + 0.5,
		})
	end

	if (self.Type == CIRCLE_OUTLINED and not self.InnerCircle) then
		local inner = draw.CreateCircle(CIRCLE_FILLED)
		inner:SetRadius(r - self.Thickness)
		inner:SetPos(x, y)

		self.InnerCircle = inner
	end

	self.Vertices = verts
end

function CIRCLE:Outline()
	if not (self.Vertices) then
		self:Calculate()
	end

	local prev = self.Vertices[#self.Vertices]

	for i, vert in ipairs(self.Vertices) do
		surface.DrawLine(prev.x, prev.y, vert.x, vert.y)
		prev = vert
	end
end

function CIRCLE:Draw(outline)
	if not (self.Vertices) then
		self:Calculate()
	end

	local x, y, r = self.X, self.Y, self.R

	if (self.Type == CIRCLE_OUTLINED) then
		render.ClearStencil()

		render.SetStencilEnable(true)
			render.SetStencilReferenceValue(1)
			render.SetStencilWriteMask(1)
			render.SetStencilTestMask(1)

			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_NEVER)
			render.SetStencilFailOperation(STENCIL_REPLACE)
			render.SetStencilZFailOperation(STENCIL_REPLACE)

			self.InnerCircle:Draw()

			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_GREATER)

			surface.DrawPoly(self.Vertices)
		render.SetStencilEnable(false)
	elseif (self.Type == CIRCLE_BLURRED) then
		render.ClearStencil()

		render.SetStencilEnable(true)
			render.SetStencilReferenceValue(1)
			render.SetStencilWriteMask(1)
			render.SetStencilTestMask(1)

			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_NEVER)
			render.SetStencilFailOperation(STENCIL_REPLACE)
			render.SetStencilZFailOperation(STENCIL_REPLACE)

			surface.DrawPoly(self.Vertices)

			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_LESSEQUAL)

			surface.SetMaterial(blur)

			render.SetScissorRect(x - r, y - r, x + r * 2, y + r * 2, true)
				for i = 1, self.Quality do
					blur:SetFloat("$blur", (i / self.Quality) * self.Density)
					blur:Recompute()

					render.UpdateScreenEffectTexture()
					surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
				end
			render.SetScissorRect(0, 0, 0, 0, false)
		render.SetStencilEnable(false)
	else
		surface.DrawPoly(self.Vertices)
	end

	if (outline) then
		self:Outline()
	end
end

CIRCLE.Render = CIRCLE.Draw

function draw.CreateCircle(type)
	return setmetatable({
		Type = type,
	}, CIRCLE)
end
