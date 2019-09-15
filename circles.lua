local blur = Material("pp/blurscreen")

CIRCLE_FILLED = 0
CIRCLE_OUTLINED = 1
CIRCLE_BLURRED = 2

local CIRCLE = {}
CIRCLE.__index = CIRCLE

CIRCLE.m_iType = CIRCLE_FILLED

CIRCLE.m_iX = 0
CIRCLE.m_iY = 0
CIRCLE.m_iR = 0

CIRCLE.m_iRotation = 0
CIRCLE.m_iThickness = 1
CIRCLE.m_iQuality = 2
CIRCLE.m_iDensity = 3

CIRCLE.m_iStartAngle = 0
CIRCLE.m_iEndAngle = 360

CIRCLE.m_bRotateMat = true

AccessorFunc(CIRCLE, "m_iType", "Type", FORCE_NUMBER)
AccessorFunc(CIRCLE, "m_iR", "Radius", FORCE_NUMBER)
AccessorFunc(CIRCLE, "m_iVertices", "Vertices", FORCE_NUMBER)
AccessorFunc(CIRCLE, "m_iRotation", "Rotation", FORCE_NUMBER)
AccessorFunc(CIRCLE, "m_iThickness", "Thickness", FORCE_NUMBER)
AccessorFunc(CIRCLE, "m_iQuality", "Quality", FORCE_NUMBER)
AccessorFunc(CIRCLE, "m_iDensity", "Density", FORCE_NUMBER)
AccessorFunc(CIRCLE, "m_bRotateMat", "RotateMaterial", FORCE_BOOL)

function CIRCLE:__tostring()
	return string.format("Circle: %p", self)
end

function CIRCLE:SetRadius(r)
	if (self.m_iR == r) then return end

	self.m_iR = r
	self.m_tVertices = nil
	self.m_cInnerCircle = nil
end

function CIRCLE:SetVertices(vertices)
	vertices = math.Clamp(vertices, 3, 360)

	if (self.m_iVertices == vertices) then return end

	self.m_iVertices = vertices
	self.m_iSteps = 360 / vertices

	self.m_tVertices = nil
	self.m_cInnerCircle = nil
end

function CIRCLE:SetRotation(rotation)
	if (self.m_iRotation == rotation) then return end

	self.m_iRotation = rotation
	self.m_tVertices = nil
	self.m_cInnerCircle = nil
end

function CIRCLE:SetThickness(thicc)
	if (self.m_iThickness == thicc) then return end

	self.m_iThickness = thicc
	self.m_cInnerCircle = nil
end

function CIRCLE:SetPos(x, y)
	if (self.m_iX == x and self.m_iY == Y) then return end

	self.m_iX = x
	self.m_iY = y

	self.m_tVertices = nil
	self.m_cInnerCircle = nil
end

function CIRCLE:SetAngles(start, finish)
	if (self.m_iStartAngle == start and self.m_iEndAngle == finish) then return end

	self.m_iStartAngle = math.min(start, finish)
	self.m_iEndAngle = math.max(start, finish)

	self.m_tVertices = nil
	self.m_cInnerCircle = nil
end

function CIRCLE:OffsetVertices(x, y)
	if (not self.m_tVertices) then
		self:Calculate()
	end

	x = x or 0
	y = y or 0

	self.m_iX = self.m_iX + x
	self.m_iY = self.m_iY + y

	for i, v in ipairs(self.m_tVertices) do
		v.x = v.x + x
		v.y = v.y + y
	end

	if (self.m_cInnerCircle) then
		self.m_cInnerCircle:OffsetVertices(x, y)
	end
end

function CIRCLE:Copy()
	return table.Copy(self)
end

function CIRCLE:Calculate()
	local r = self.m_iR
	local x, y = self.m_iX, self.m_iY
	local start, finish = self.m_iStartAngle, self.m_iEndAngle

	local verts, dist = {}, math.Clamp(self.m_iSteps or math.max(8, 360 / (r * math.pi)), 1, 120)

	if (finish - start ~= 360) then
		table.insert(verts, {
			x = x,
			y = y,

			u = 0.5,
			v = 0.5,
		})

		finish = finish + dist
	else
		finish = finish - dist
	end

	for a = start, finish, dist do
		a = math.Clamp(a, start, self.m_iEndAngle)

		local rad = math.rad(a)
		local rot = math.rad(self.m_iRotation)

		table.insert(verts, {
			x = x + math.cos(rad + rot) * r,
			y = y + math.sin(rad + rot) * r,

			u = math.cos(self.m_bRotateMat and rad - rot or rad) / 2 + 0.5,
			v = math.sin(self.m_bRotateMat and rad - rot or rad) / 2 + 0.5,
		})
	end

	self.m_tVertices = verts
end

function CIRCLE:__call(colour, material)
	if (not self.m_tVertices) then
		self:Calculate()
	end

	if (IsColor(colour)) then surface.SetDrawColor(colour) end
	if (TypeID(material) == TYPE_MATERIAL) then surface.SetMaterial(material) elseif (material) then draw.NoTexture() end

	if (self.m_iType == CIRCLE_OUTLINED) then
		if (not self.m_cInnerCircle) then
			local inner = self:Copy()

			inner:SetType(CIRCLE_FILLED)
			inner:SetRadius(self.m_iR - self.m_iThickness)

			self.m_cInnerCircle = inner
		end

		render.ClearStencil()

		render.SetStencilEnable(true)
			render.SetStencilReferenceValue(1)
			render.SetStencilWriteMask(1)
			render.SetStencilTestMask(1)

			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_NEVER)
			render.SetStencilFailOperation(STENCIL_REPLACE)
			render.SetStencilZFailOperation(STENCIL_REPLACE)

			self.m_cInnerCircle()

			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_GREATER)

			surface.DrawPoly(self.m_tVertices)
		render.SetStencilEnable(false)
	elseif (self.m_iType == CIRCLE_BLURRED) then
		render.ClearStencil()

		render.SetStencilEnable(true)
			render.SetStencilReferenceValue(1)
			render.SetStencilWriteMask(1)
			render.SetStencilTestMask(1)

			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_NEVER)
			render.SetStencilFailOperation(STENCIL_REPLACE)
			render.SetStencilZFailOperation(STENCIL_REPLACE)

			surface.DrawPoly(self.m_tVertices)

			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_LESSEQUAL)

			surface.SetMaterial(blur)

			local sw, sh = ScrW(), ScrH()

			for i = 1, self.m_iQuality do
				blur:SetFloat("$blur", (i / self.m_iQuality) * self.m_iDensity)
				blur:Recompute()

				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect(0, 0, sw, sh)
			end
		render.SetStencilEnable(false)
	else
		surface.DrawPoly(self.m_tVertices)
	end
end

debug.getregistry()["Circle"] = CIRCLE

function draw.NewCircle(type)
	return setmetatable({m_iType = tonumber(type)}, CIRCLE)
end
