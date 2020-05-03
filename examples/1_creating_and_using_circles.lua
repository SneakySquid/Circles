-- Be sure to include the file manually. Running it by itself won't do anything.
-- Don't worry about doing this in multiple files since the created table gets cached.
local circles = include("circles.lua")

-- Would create a filled circle 300 pixels wide in the top left of the screen.
local filled = circles.New(CIRCLE_FILLED, 150, 155, 155)

-- An outlined circle with an outline width of 50.
local outlined = circles.New(CIRCLE_OUTLINED, 150, 460, 155, 50)

-- A blurred circle with 3 layers of blur and a blur density of 2.
local blurred = circles.New(CIRCLE_BLURRED, 150, 765, 155, 3, 2)

local function Example1()
	-- Call draw.NoTexture to stop materials being rendered to the circles.
	-- This is called internally if the material has been set to "true" with Circle:SetMaterial.
	draw.NoTexture()

	-- Set the colour of the circles. Can also be set per circle with Circle:SetColor.
	surface.SetDrawColor(255, 255, 255)

	-- Drawing the circles is as easy as calling it's reference.
	filled()
	outlined()

	-- Be careful when using CIRCLE_BLURRED type circles since they use surface.SetMaterial internally.
	-- If you want to render something after one make sure to call draw.NoTexture or surface.SetMaterial afterwards.
	blurred()
end
hook.Add("HUDPaint", "Circle Example 1", Example1)
