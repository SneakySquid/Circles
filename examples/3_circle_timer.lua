local circles = include("circles.lua")

local timer_circle = circles.New(CIRCLE_FILLED, 150, 155, 155)
timer_circle:SetColor(Color(255, 0, 0))

-- The time it takes, in seconds, to become a full circle.
local time = 5
local start_time = SysTime()

local function Example3()
	local delta = (SysTime() - start_time) / time
	if (delta > 1) then start_time = SysTime() end

	draw.NoTexture()

	-- If you wanted it to count down instead just swap the 0 and 360.
	timer_circle:SetEndAngle(Lerp(delta, 0, 360))
	timer_circle()
end
hook.Add("HUDPaint", "Circle Example 3", Example3)
