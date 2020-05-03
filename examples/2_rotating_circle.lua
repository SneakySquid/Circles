local circles = include("circles.lua")

local rotating_circle = circles.New(CIRCLE_FILLED, 150, 155, 155)
rotating_circle:SetColor(color_white)
rotating_circle:SetMaterial(Material("__error"))

local function Example2()
	-- This would make the circle have a full revolution every 2 seconds or rotate 180 degrees per second.
	rotating_circle:Rotate(FrameTime() * 180)
	rotating_circle()
end
hook.Add("HUDPaint", "Circle Example 2", Example2)
