local circles = include("circles.lua")

local r, x, y = 128, 256, 256
local options = {
	"Option 1", "Option 2",
	"Option 3", "Option 4",
	"Option 5", "Option 6",
	"Option 7", "Option 8",
}

local background = circles.New(CIRCLE_OUTLINED, r, x, y, 15)
background:SetMaterial(true)
background:SetColor(color_white)

local wedge = circles.New(CIRCLE_OUTLINED, r + 5, x, y, 25)
wedge:SetColor(color_black)
wedge:SetEndAngle(360 / #options)

local function FindSelected(x, y, segment_size)
	local mouse_pos = Vector(input.GetCursorPos())
	mouse_pos:Sub(Vector(x, y, 0))

	local mouse_ang = math.atan2(mouse_pos[2], mouse_pos[1]) * 180 / math.pi

	if mouse_ang < 0 then
		mouse_ang = 360 + mouse_ang
	end

	return math.floor(mouse_ang / segment_size)
end

hook.Add("HUDPaint", "Radial Menu", function()
	local segment_size = 360 / #options
	local selected = FindSelected(x, y, segment_size)

	background()

	wedge:SetRotation(selected * segment_size)
	wedge()

	for i = 0, #options - 1 do
		local option = options[i + 1]
		local a = math.rad(segment_size * i + segment_size / 2)

		local x = x + math.cos(a) * r
		local y = y + math.sin(a) * r

		draw.SimpleText(
			option, "DermaLarge", x, y,
			selected == i and color_white or color_black,
			TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
		)
	end
end)
