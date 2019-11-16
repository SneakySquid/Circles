local BlurMat = Material("pp/blurscreen")

local abs = math.abs
local cos = math.cos
local max = math.max
local min = math.min
local rad = math.rad
local sin = math.sin
local Clamp = math.Clamp

local CIRCLE = {}
CIRCLE.__index = CIRCLE

CIRCLE_FILLED = 0
CIRCLE_OUTLINED = 1
CIRCLE_BLURRED = 2

do
	local function AccessorFunc(name, default, dirty, callback)
		local varname = "m_" .. name

		meta["Get" .. name] = function(self)
			return self[varname]
		end

		meta["Set" .. name] = function(self, value)
			if (default ~= nil and value == nil) then
				value = default
			end

			if (self[varname] ~= value) then
				if (isfunction(callback)) then
						callback(self, meta["Get" .. name]() or default, value)
					end
				end

				if (dirty) then
					self[dirty] = true
				end
			end

			self[varname] = value
		end

		meta["Set" .. name](meta, default)
	end

	AccessorFunc("Dirty", true)

	AccessorFunc("Colour", false)
	AccessorFunc("Material", false)
	AccessorFunc("Vertexes", false)

	AccessorFunc("Type", CIRCLE_FILLED, "m_Dirty")
	AccessorFunc("X", 0, false, function(self, old, new) self:OffsetVertices(old - new, 0) end)
	AccessorFunc("Y", 0, false, function(self, old, new) self:OffsetVertices(0, old - new) end)
	AccessorFunc("Radius", 16, "m_Dirty")
	AccessorFunc("Rotation", 0, "m_Dirty")
	AccessorFunc("StartAngle", 0, "m_Dirty")
	AccessorFunc("EndAngle", 360, "m_Dirty")
	AccessorFunc("Vertices", 45, "m_Dirty")

	AccessorFunc("BlurDensity", 3)
	AccessorFunc("BlurQuality", 2)
	AccessorFunc("OutlineWidth", 10, "m_Dirty")

	function CIRCLE:SetPos(x, y)
		self:SetX(x)
		self:SetY(y)
	end

	function CIRCLE:SetAngles(s, e)
		self:SetStartAngle(s)
		self:SetEndAngle(e)
	end

	function CIRCLE:GetPos()
		return self:GetX(), self:GetY()
	end

	function CIRCLE:GetAngles()
		return self:GetStartAngle(), self:GetEndAngle()
	end
end

local function New(t, r, x, y, ...)
	local circle = setmetatable({}, CIRCLE)

	circle:SetType(tonumber(t))
	circle:SetRadius(tonumber(r))
	circle:SetPos(tonumber(x), tonumber(y))

	if (t == CIRCLE_OUTLINED) then
		local w = ({...})[1]
		circle:SetOutlineWidth(tonumber(w))
	elseif (t == CIRCLE_BLURRED) then
		local q, d = unpack({...})
		circle:SetBlurQuality(tonumber(q))
		circle:SetBlurDensity(tonumber(d))
	end

	return circle
end

local function CalculateVertexes(r, x, y, ro, sa, ea, dist)
	local vertexes, prev, final = {}, nil, 360

	r = tonumber(r) or 16
	x = tonumber(x) or 0
	y = tonumber(y) or 0
	ro = rad(tonumber(ro) or 0)
	sa = max(tonumber(sa) or 0, -360)
	ea = min(tonumber(ea) or 360, 360)
	dist = Clamp(tonumber(dist) or 10, 1, 120)

	if (sa > ea) then
		local tmp = sa
		sa = ea
		ea = tmp
	end

	if (ea - sa ~= 360) then
		table.insert(vertexes, {
			x = x,
			y = y,

			u = 0.5,
			v = 0.5,
		})

		final = ea + dist
	end

	for a = sa, 360, dist do
		local ra, radius = rad(Clamp(a, sa, ea)), r

		if (a == sa - sa % dist) then
			local angle1 = sa % dist
			local angle2 = (180 - dist) / 2
			local angle3 = 180 - angle2 - angle1
			radius = (sin(rad(angle2)) * r) / sin(rad(angle3))
		elseif (a == final - final % dist) then
			local angle1 = final % dist
			local angle2 = (180 - dist) / 2
			local angle3 = 180 - angle2 - angle1
			radius = (sin(rad(angle2)) * r) / sin(rad(angle3))
		end

		local x = x + cos(ra + ro) * radius
		local y = y + sin(ra + ro) * radius

		if (vertexes[1] and abs(vertexes[1].x - x) < 1e-12 and abs(vertexes[1].y - y) < 1e-12) then break end
		if (prev and abs(prev[1] - x) < 1e-12 and abs(prev[2] - y) < 1e-12) then goto CONTINUE end

		table.insert(vertexes, {
			x = x,
			y = y,

			u = cos(ra - ro) / 2 + 0.5,
			v = sin(ra - ro) / 2 + 0.5,
		})

		prev = prev or {}
		prev[1] = x
		prev[2] = y

		::CONTINUE::
	end

	return vertexes
end

local function Draw(r, x, y, ro, sa, ea, dist)
	surface.DrawPoly(CalculateVertexes(r, x, y, ro, sa, ea, dist))
end

function CIRCLE:__tostring()
	return string.format("Circle: %p", self)
end

function CIRCLE:CalculateVertexes()
	local r = self:GetRadius()
	local x, y = self:GetPos()
	local ro = self:GetRotation()
	local sa = self:GetStartAngle()
	local ea = self:GetEndAngle()
	local verts, dist = self:GetVertices()

	if (not verts) then
		dist = max(8, 360 / (r * math.pi))
	else
		dist = 360 / verts
	end

	self:SetVertexes(CalculateVertexes(r, x, y, ro, sa, ea, dist))
end

function CIRCLE:__call(update)
	if (update or self:GetDirty()) then
		self.m_Vertexes = false
		self.m_InnerCircle = false

		self:SetDirty(false)
	end

	if (not self:GetVertexes()) then
		self:CalculateVertexes()
	end

	if (IsColor(self:GetColour())) then surface.SetDrawColor(self:GetColour()) end
	if (TypeID(self:GetMaterial()) == TYPE_MATERIAL) then surface.SetMaterial(self:GetMaterial()) else draw.NoTexture() end

	if (self:GetType() == CIRCLE_OUTLINED) then
		if (not self.m_InnerCircle) then
			local inner = self:Copy()

			inner:SetType(CIRCLE_FILLED)
			inner:SetRadius(self:GetRadius() - self:GetOutlineWidth())

			self.m_InnerCircle = inner
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

			self.m_InnerCircle()

			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_GREATER)

			surface.DrawPoly(self:GetVertexes())
		render.SetStencilEnable(false)
	elseif (self:GetType() == CIRCLE_BLURRED) then
		render.ClearStencil()

		render.SetStencilEnable(true)
			render.SetStencilReferenceValue(1)
			render.SetStencilWriteMask(1)
			render.SetStencilTestMask(1)

			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_NEVER)
			render.SetStencilFailOperation(STENCIL_REPLACE)
			render.SetStencilZFailOperation(STENCIL_REPLACE)

			surface.DrawPoly(self:GetVertexes())

			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_LESSEQUAL)

			surface.SetMaterial(BlurMat)

			local sw, sh = ScrW(), ScrH()

			for i = 1, self:GetBlurQuality() do
				BlurMat:SetFloat("$blur", (i / self:GetBlurQuality()) * self:GetBlurDensity())
				BlurMat:Recompute()

				render.UpdateScreenEffectTexture()

				surface.DrawTexturedRect(0, 0, sw, sh)
			end
		render.SetStencilEnable(false)
	else
		surface.DrawPoly(self:GetVertexes())
	end
end

function CIRCLE:OffsetVertexes(x, y)
	if (not self:GetVertexes()) then
		self:CalculateVertexes()
	end

	x = tonumber(x) or 0
	y = tonumber(y) or 0

	for i, v in ipairs(self:GetVertexes()) do
		v.x = v.x + x
		v.y = v.y + y
	end

	self.m_X = self.m_X + x
	self.m_Y = self.m_Y + y

	if (self.m_InnerCircle) then
		self.m_InnerCircle:OffsetVertices(x, y)
	end
end

function CIRCLE:Copy()
	return table.Copy(self)
end

return {
	New = New,
	Draw = Draw,
	CalculateVertexes = CalculateVertexes,
}
