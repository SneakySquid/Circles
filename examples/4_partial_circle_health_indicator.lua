local circles = include("circles.lua")

local health_color = Color(0, 0, 0)
local health_circle = circles.New(CIRCLE_FILLED, 300, 5, 5)
health_circle:SetMaterial(true) -- Makes draw.NoTexture get called internally.
health_circle:SetColor(health_color)
health_circle:SetAngles(0, 90)

local function Example4()
	local ply = LocalPlayer()

	local hp = ply:Health()
	local maxhp = ply:GetMaxHealth()
	local percent = math.Clamp(hp / maxhp, 0, 1)

	-- Makes the colour go from red to black the lower it gets.
	health_color.r = 255 * percent

	-- If you wanted it to go from green to red you'd do
	-- health_color.r = 255 - 255 * percent
	-- health_color.g = 255 * percent

	-- The 90 here is how many degrees the quarter circle is.
	-- If you wanted to use a full circle for the health meter you'd replace it with 360.
	local end_angle = 90 * percent

	-- Make the partial circle smaller depending on health.
	-- If you wanted to change the end angle you'd do Circle:SetEndAngle(end_angle)
	health_circle:SetStartAngle(90 - end_angle) -- This 90 represents the maximum end angle set above.

	health_circle()
end
hook.Add("HUDPaint", "Circle Example 4", Example4)
