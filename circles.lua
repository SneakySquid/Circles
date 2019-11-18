local BlurMat = Material("pp/blurscreen")

local rad = math.rad
local deg = math.deg
local cos = math.cos
local sin = math.sin

local CIRCLE = {}
CIRCLE.__index = CIRCLE

CIRCLE_FILLED = 0
CIRCLE_OUTLINED = 1
CIRCLE_BLURRED = 2

local function RotateVertices(vertices, ox, oy, rotation, rotate_uv)
	rotation = rad(rotation)

	local s = sin(rotation)
	local c = cos(rotation)

	for i, vertex in ipairs(vertices) do
		local vx, vy = vertex.x, vertex.y

		vx = vx - ox
		vy = vy - oy

		vertex.x = ox + (vx * c - vy * s)
		vertex.y = oy + (vx * s + vy * c)

		if (not rotate_uv) then
			local u, v = vertex.u, vertex.v
			u, v = u - 0.5, v - 0.5

			vertex.u = 0.5 + (u * c - v * s)
			vertex.v = 0.5 + (u * s + v * c)
		end
	end
end

-- thanks wingiu
local function calc_radius(a, dist, radius)
	local ang1 = a % dist
	local ang2 = (180 - dist) / 2
	local ang3 = 180 - ang2 - ang1
	return (sin(rad(ang2)) * radius) / sin(rad(ang3))
end

local function CalculateStartAngle(vertices, x, y, radius, rotation, start_angle, dist)
	local closest = math.ceil((start_angle + (dist - start_angle % dist)) / dist)

	for i = 1, closest do
		table.remove(vertices, 1)
	end

	local a = rad(start_angle + rotation)
	local r = calc_radius(start_angle, dist, radius)

	local vx = cos(a) * r
	local vy = sin(a) * r

	local mult = 0.5 * (r / radius)

	table.insert(vertices, 1, {
		x = x + vx,
		y = y + vy,

		u = 0.5 + cos(a) * mult,
		v = 0.5 + sin(a) * mult,
	})
end

local function CalculateEndAngle(vertices, x, y, radius, rotation, end_angle, dist)
	local closest = math.ceil((end_angle + (dist - end_angle % dist)) / dist)

	for i = 1, #vertices - closest do
		table.remove(vertices)
	end

	local a = rad(end_angle + rotation)
	local r = calc_radius(end_angle, dist, radius)

	local vx = cos(a) * r
	local vy = sin(a) * r

	local mult = 0.5 * (r / radius)

	table.insert(vertices, {
		x = x + vx,
		y = y + vy,

		u = 0.5 + cos(a) * mult,
		v = 0.5 + sin(a) * mult,
	})
end

local function CalculateVertices(x, y, radius, rotation, start_angle, end_angle, segments, rotate_uv)
	x = tonumber(x) or 0
	y = tonumber(y) or 0
	radius = tonumber(radius) or 16
	rotation = tonumber(rotation) or 0
	start_angle = tonumber(start_angle) or 0
	end_angle = tonumber(end_angle) or 360

	local vertices, cache = {}, {}
	local dist = 360 / segments

	for a = 0, 360 - dist, dist do
		a = rad(a)

		local vertex = {
			x = x + cos(a) * radius,
			y = y + sin(a) * radius,

			u = 0.5 + cos(a) / 2,
			v = 0.5 + sin(a) / 2,
		}

		table.insert(vertices, vertex)
		table.insert(cache, vertex)
	end

	if (rotation ~= 0) then
		RotateVertices(vertices, x, y, rotation, rotate_uv)
		RotateVertices(cache, x, y, rotation, rotate_uv)
	end

	if (end_angle - start_angle ~= 360) then
		if (end_angle ~= 360) then
			CalculateEndAngle(vertices, x, y, radius, rotation, end_angle, dist)
		end

		if (start_angle ~= 0) then
			CalculateStartAngle(vertices, x, y, radius, rotation, start_angle, dist)
		end

		table.insert(vertices, 1, {
			x = x, y = y,
			u = 0.5, v = 0.5,
		})
	end

	return vertices, cache
end

local function Draw(...)
	surface.DrawPoly(CalculateVertices(...))
end

local function New(type, radius, x, y, ...)
	local circle = setmetatable({}, CIRCLE)

	circle:SetType(tonumber(type))
	circle:SetRadius(tonumber(radius))
	circle:SetPos(tonumber(x), tonumber(y))

	if (type == CIRCLE_OUTLINED) then
		local outline_width = ({...})[1]
		circle:SetOutlineWidth(tonumber(outline_width))
	elseif (type == CIRCLE_BLURRED) then
		local blur_quality, blur_density = unpack({...})
		circle:SetBlurQuality(tonumber(blur_quality))
		circle:SetBlurDensity(tonumber(blur_density))
	end

	return circle
end

function CIRCLE:__tostring()
	return string.format("Circle: %p", self)
end

function CIRCLE:CalculateVertices()
	local x, y = self:GetPos()
	local radius = self:GetRadius()
	local rotation = self:GetRotation()
	local start_angle = self:GetStartAngle()
	local end_angle = self:GetEndAngle()
	local segments = self:GetSegments()
	local rotate_uv = self:GetRotateMaterial()

	local vertices, cache = CalculateVertices(x, y, radius, rotation, start_angle, end_angle, segments, rotate_uv)

	self:SetVertices(vertices)
	self:SetCache(cache)

	self:SetDirty(false)
end

function CIRCLE:__call(update)
	if (update or self:GetDirty()) then
		self:SetVertices(false)
		self:SetChildCircle(false)
	end

	if (not self:GetVertices()) then
		self:CalculateVertices()
	end

	if (IsColor(self:GetColour())) then surface.SetDrawColor(self:GetColour()) end
	if (TypeID(self:GetMaterial()) == TYPE_MATERIAL) then surface.SetMaterial(self:GetMaterial()) else draw.NoTexture() end

	if (self:GetType() == CIRCLE_OUTLINED) then
		if (not self:GetChildCircle()) then
			local inner = self:Copy()

			inner:SetType(CIRCLE_FILLED)
			inner:SetRadius(self:GetRadius() - self:GetOutlineWidth())

			self:SetChildCircle(inner)
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

			self:GetChildCircle()()

			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_GREATER)

			surface.DrawPoly(self:GetVertices())
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

			surface.DrawPoly(self:GetVertices())

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
		surface.DrawPoly(self:GetVertices())
	end
end

function CIRCLE:OffsetVertices(x, y)
	if (not self:GetVertices()) then
		self:CalculateVertices()
	end

	x = tonumber(x) or 0
	y = tonumber(y) or 0

	for i, v in ipairs(self:GetVertices()) do
		v.x = v.x + x
		v.y = v.y + y
	end

	self.m_X = self:GetX() + x
	self.m_Y = self:GetY() + y

	if (self:GetChildCircle()) then
		self:GetChildCircle():OffsetVertices(x, y)
	end
end

function CIRCLE:Rotate(rotation)
	if (not self:GetVertices()) then
		self:CalculateVertices()
	end

	local vertices = self:GetVertices()
	local x, y = self:GetPos()
	local rotate_uv = self:GetRotateMaterial()

	RotateVertices(vertices, x, y, rotation, rotate_uv)

	self.m_Rotation = self.m_Rotation + rotation

	if (self:GetChildCircle()) then
		self:GetChildCircle():Rotate(rotation)
	end
end

function CIRCLE:Copy()
	return table.Copy(self)
end

do
	local function AccessorFunc(name, default, dirty, callback)
		local varname = "m_" .. name

		CIRCLE["Get" .. name] = function(self)
			return self[varname]
		end

		CIRCLE["Set" .. name] = function(self, value)
			if (default ~= nil and value == nil) then
				value = default
			end

			if (self[varname] ~= value) then
				if (isfunction(callback)) then
					callback(self, self[varname], value)
				end

				if (dirty) then
					self[dirty] = true
				end
			end

			self[varname] = value
		end

		CIRCLE[varname] = default
	end

	local function OffsetVerticesX(circle, old, new)
		if (circle:GetDirty() or not circle:GetVertices()) then return end

		for i, vertex in ipairs(circle:GetVertices()) do
			vertex.x = 0 - old + new + old
		end

		if (circle:GetChildCircle()) then
			OffsetVerticesX(circle:GetChildCircle(), old, new)
		end
	end

	local function OffsetVerticesY(circle, old, new)
		if (circle:GetDirty() or not circle:GetVertices()) then return end

		for i, vertex in ipairs(circle:GetVertices()) do
			vertex.y = 0 - old + new + old
		end

		if (circle:GetChildCircle()) then
			OffsetVerticesY(circle:GetChildCircle(), old, new)
		end
	end

	local function ScaleVertices(circle, old, new)
		if (circle:GetDirty() or not circle:GetVertices()) then return end

		local x, y = circle:GetPos()

		for i, vertex in ipairs(circle:GetVertices()) do
			vertex.x = (vertex.x - x) * (new / old)
			vertex.y = (vertex.y - y) * (new / old)
		end

		if (circle:GetChildCircle()) then
			ScaleVertices(circle:GetChildCircle(), old, new)
		end
	end

	local function UpdateRotation(circle, old, new)
		if (circle:GetDirty() or not circle:GetVertices()) then return end

		local vertices = circle:GetVertices()
		local x, y = circle:GetPos()
		local rotation = new - old
		local rotate_uv = circle:GetRotateMaterial()

		RotateVertices(vertices, x, y, rotation, rotate_uv)

		if (circle:GetChildCircle()) then
			circle:GetChildCircle():Rotate(rotate)
		end
	end

	local function UpdateStartAngle(circle, old, new)
		if (circle:GetDirty() or not circle:GetVertices()) then return end

		local cache = circle:GetCache()
		if (not cache) then return end

		local x, y = circle:GetPos()
		local radius = circle:GetRadius()
		local rotation = circle:GetRotation()
		local dist = 360 / circle:GetSegments()

		local vertices = table.Copy(cache)

		if (new ~= 0) then
			CalculateStartAngle(vertices, x, y, radius, rotation, new, dist)

			table.insert(vertices, 1, {
				x = x, y = y,
				u = 0.5, v = 0.5,
			})
		end

		circle:SetVertices(vertices)
	end

	local function UpdateEndAngle(circle, old, new)
		if (circle:GetDirty() or not circle:GetVertices()) then return end

		local cache = circle:GetCache()
		if (not cache) then return end

		local x, y = circle:GetPos()
		local radius = circle:GetRadius()
		local rotation = circle:GetRotation()
		local dist = 360 / circle:GetSegments()

		local vertices = table.Copy(cache)

		if (new ~= 360) then
			CalculateEndAngle(vertices, x, y, radius, rotation, new, dist)

			table.insert(vertices, 1, {
				x = x, y = y,
				u = 0.5, v = 0.5,
			})
		end

		circle:SetVertices(vertices)
	end

	local function UpdateOutlineWidth(circle, old, new)
		if (circle:GetDirty() or not circle:GetVertices()) then return end

		local inner = circle:GetChildCircle()
		if (not inner) then return end

		ScaleVertices(inner, inner:GetRadius(), circle:GetRadius() - new)
	end

	AccessorFunc("Dirty", true)

	AccessorFunc("Colour", false)
	AccessorFunc("Material", false)
	AccessorFunc("RotateMaterial", true)

	AccessorFunc("Vertices", false)
	AccessorFunc("Cache", false)
	AccessorFunc("ChildCircle", false)

	AccessorFunc("Type", CIRCLE_FILLED, "m_Dirty")
	AccessorFunc("X", 0, nil, OffsetVerticesX)
	AccessorFunc("Y", 0, nil, OffsetVerticesY)
	AccessorFunc("Radius", 8, nil, ScaleVertices)
	AccessorFunc("Rotation", 0, nil, UpdateRotation)
	AccessorFunc("StartAngle", 0, "m_Dirty") -- nil, UpdateStartAngle)
	AccessorFunc("EndAngle", 360, "m_Dirty") -- nil, UpdateEndAngle)
	AccessorFunc("Segments", 45, "m_Dirty")

	AccessorFunc("BlurDensity", 3)
	AccessorFunc("BlurQuality", 2)
	AccessorFunc("OutlineWidth", 10, nil, UpdateOutlineWidth)

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

return {
	New = New,
	Draw = Draw,
	CalculateVertices = CalculateVertices,
}
