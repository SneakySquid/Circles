local _R = debug.getregistry()
if (_R.Circles) then return _R.Circles end

local BlurMat = Material("pp/blurscreen")

local rad = math.rad
local cos = math.cos
local sin = math.sin
local min = math.min
local max = math.max

local CIRCLE = {}
CIRCLE.__index = CIRCLE

CIRCLE_FILLED = 0
CIRCLE_OUTLINED = 1
CIRCLE_BLURRED = 2

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

local function RotateVertices(vertices, ox, oy, rotation, rotate_uv)
	rotation = rad(rotation)

	local c = cos(rotation)
	local s = sin(rotation)

	for i = 1, #vertices do
		local vertex = vertices[i]
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
	local ang2 = 0.5 * (math.pi - dist)
	local ang3 = math.pi - ang2 - ang1

	return sin(ang2) * radius / sin(ang3)
end

local function CalculateVertices(x, y, radius, rotation, start_angle, end_angle, step, rotate_uv)
	x = tonumber(x) or 0
	y = tonumber(y) or 0
	radius = tonumber(radius) or 16
	rotation = tonumber(rotation) or 0
	start_angle = tonumber(start_angle) or 0
	end_angle = tonumber(end_angle) or 360
	step = tonumber(step) or 8

	local vertices = {}
	local dist = rad(step)

	for a = 0, end_angle + step, step do
		if (a <= start_angle - step) then goto CONTINUE end

		a = max(start_angle, min(end_angle, a))
		a = rad(a)

		local r = calc_radius(a, dist, radius)

		local c = cos(a)
		local s = sin(a)

		local vertex = {
			x = x + c * r,
			y = y + s * r,

			u = 0.5 + c / 2,
			v = 0.5 + s / 2,
		}

		table.insert(vertices, vertex)

		::CONTINUE::
	end

	if (end_angle - start_angle ~= 360) then
		table.insert(vertices, 1, {
			x = x, y = y,
			u = 0.5, v = 0.5,
		})
	else
		table.remove(vertices)
	end

	if (rotation ~= 0) then
		RotateVertices(vertices, x, y, rotation, rotate_uv)
	end

	return vertices
end

function CIRCLE:__tostring()
	return string.format("Circle: %p", self)
end

function CIRCLE:Copy()
	return table.Copy(self)
end

function CIRCLE:Calculate()
	local rotate_uv = self:GetRotateMaterial()
	local x, y = self:GetPos()
	local radius = self:GetRadius()
	local rotation = self:GetRotation()
	local start_angle = self:GetStartAngle()
	local end_angle = self:GetEndAngle()
	local distance = self:GetDistance()
	local segments = self:GetSegments()

	local step

	if (distance and distance > 0) then
		step = (distance * 360) / (2 * math.pi * radius)
	else
		step = 360 / max(segments, 3)
	end

	self:SetVertices(CalculateVertices(x, y, radius, rotation, start_angle, end_angle, step, rotate_uv))

	if (self:GetType() == CIRCLE_OUTLINED) then
		local inner = self:Copy()

		inner:SetType(CIRCLE_FILLED)
		inner:SetRadius(self:GetRadius() - self:GetOutlineWidth())
		inner:SetDisableClipping(false)

		self:SetChildCircle(inner)
	end

	self:SetDirty(false)
end

function CIRCLE:__call()
	if (self:GetDirty()) then
		self:Calculate()
	end

	if (IsColor(self:GetColour())) then surface.SetDrawColor(self:GetColour()) end
	if (TypeID(self:GetMaterial()) == TYPE_MATERIAL) then surface.SetMaterial(self:GetMaterial()) end

	local clip = self:GetDisableClipping()
	if (clip) then surface.DisableClipping(true) end

	if (self:GetType() == CIRCLE_OUTLINED) then
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

	if (clip) then surface.DisableClipping(false) end
end

function CIRCLE:Offset(x, y)
	self.m_X = self:GetX() + x
	self.m_Y = self:GetY() + y

	if (self:GetDirty()) then return end

	x = tonumber(x) or 0
	y = tonumber(y) or 0

	for i, v in ipairs(self:GetVertices()) do
		v.x = v.x + x
		v.y = v.y + y
	end

	if (self:GetType() == CIRCLE_OUTLINED) then
		self:GetChildCircle():Offset(x, y)
	end
end

function CIRCLE:Scale(scale)
	self.m_Radius = self:GetRadius() * scale

	if (self:GetDirty()) then return end

	local x, y = self:GetPos()

	for i, vertex in ipairs(self:GetVertices()) do
		vertex.x = x + ((vertex.x - x) * scale)
		vertex.y = y + ((vertex.y - y) * scale)
	end

	if (self:GetType() == CIRCLE_OUTLINED) then
		self:GetChildCircle():Scale(scale)
	end
end

function CIRCLE:Rotate(degrees)
	self.m_Rotation = self:GetRotation() + degrees

	if (self:GetDirty()) then return end

	local vertices = self:GetVertices()
	local x, y = self:GetPos()
	local rotate_uv = self:GetRotateMaterial()

	RotateVertices(vertices, x, y, degrees, rotate_uv)

	if (self:GetType() == CIRCLE_OUTLINED) then
		self:GetChildCircle():Rotate(degrees)
	end
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
				if (dirty) then
					self[dirty] = true
				end

				if (isfunction(callback)) then
					value = callback(self, self[varname], value) or value
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

		if (circle:GetType() == CIRCLE_OUTLINED) then
			OffsetVerticesX(circle:GetChildCircle(), old, new)
		end
	end

	local function OffsetVerticesY(circle, old, new)
		if (circle:GetDirty() or not circle:GetVertices()) then return end

		for i, vertex in ipairs(circle:GetVertices()) do
			vertex.y = 0 - old + new + old
		end

		if (circle:GetType() == CIRCLE_OUTLINED) then
			OffsetVerticesY(circle:GetChildCircle(), old, new)
		end
	end

	local function UpdateRotation(circle, old, new)
		if (circle:GetDirty() or not circle:GetVertices()) then return end

		local vertices = circle:GetVertices()
		local x, y = circle:GetPos()
		local rotation = new - old
		local rotate_uv = circle:GetRotateMaterial()

		RotateVertices(vertices, x, y, rotation, rotate_uv)

		if (circle:GetType() == CIRCLE_OUTLINED) then
			UpdateRotation(circle:GetChildCircle(), old, new)
		end
	end

	-- These are set internally. Only use them if you know what you're doing.
	AccessorFunc("Dirty", true)
	AccessorFunc("Vertices", false)
	AccessorFunc("ChildCircle", false)

	AccessorFunc("Colour", false) -- The colour you want the circle to be. If set to false then surface.SetDrawColor's can be used.
	AccessorFunc("Material", false) -- The material you want the circle to render. If set to false then surface.SetMaterial can be used.
	AccessorFunc("RotateMaterial", true) -- Sets whether or not the circle's UV points should be rotated with the vertices.
	AccessorFunc("DisableClipping", false) -- Sets whether or not to disable clipping when the circle is rendered. Useful for circles that go out of the render bounds.

	AccessorFunc("Type", CIRCLE_FILLED, "m_Dirty") -- The circle's type.
	AccessorFunc("X", 0, false, OffsetVerticesX) -- The circle's X position relative to the top left of the screen.
	AccessorFunc("Y", 0, false, OffsetVerticesY) -- The circle's Y position relative to the top left of the screen.
	AccessorFunc("Radius", 8, "m_Dirty") -- The circle's radius.
	AccessorFunc("Rotation", 0, false, UpdateRotation) -- The circle's rotation, measured in degrees.
	AccessorFunc("StartAngle", 0, "m_Dirty") -- The circle's start angle, measured in degrees.
	AccessorFunc("EndAngle", 360, "m_Dirty") -- The circle's end angle, measured in degrees.
	AccessorFunc("Distance", 10, "m_Dirty") -- The maximum distance between each of the circle's vertices. Set to false to use segments instead. This should typically be used for large circles in 3D2D.
	AccessorFunc("Segments", 45, "m_Dirty") -- The amount of segments that will be calculated if Distance is set to false. If you're setting this higher than 360 then you should be using Distance instead.

	AccessorFunc("BlurDensity", 3) -- The circle's blur density if Type is set to CIRCLE_BLURRED.
	AccessorFunc("BlurQuality", 2) -- The circle's blur quality if Type is set to CIRCLE_BLURRED.
	AccessorFunc("OutlineWidth", 10, "m_Dirty") -- The circle's outline width if Type is set to CIRCLE_OUTLINED.

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

_R.Circles = {
	New = New,
	RotateVertices = RotateVertices,
	CalculateVertices = CalculateVertices,
}

return _R.Circles
