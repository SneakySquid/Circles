include("circles.lua")

local filled = draw.CreateCircle(CIRCLE_FILLED)
filled:SetRadius(100)
filled:SetPos(110, 200)
filled:SetAngles(0, 270)

local outlined = draw.CreateCircle(CIRCLE_OUTLINED)
outlined:SetRadius(100)
outlined:SetPos(110 * 3, 200)
outlined:SetAngles(90, 360)
outlined:SetThickness(5)

local blurred = draw.CreateCircle(CIRCLE_BLURRED)
blurred:SetRadius(100)
blurred:SetPos(110 * 5, 200)
blurred:SetAngles(0, 270)
blurred:SetRotation(180)
blurred:SetQuality(5)
blurred:SetDensity(5)

hook.Add("HUDPaint", "circles!", function()
	draw.NoTexture()
	surface.SetDrawColor(255, 255, 255)

	filled:Draw()
	outlined:Draw()
	blurred:Draw(true)
end)
