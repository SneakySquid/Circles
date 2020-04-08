# Circles!
[Methods](#methods)\
[Examples](#examples)

## Functions:

#### New(number type, number radius, number x, number y, number outline_width | number blur_density, blur_quality)
###### Arguments:
1. number **type** = `CIRCLE_FILLED`
	- The type of circle to make. Valid option are CIRCLE_FILLED, CIRCLE_OUTLINED, and CIRCLE_BLURRED.
2. number **radius** = `8`
	- The radius of the circle.
3. number **x** = `0`
	- The X position of the centre of the circle.
4. number **y** = `0`
	- The Y position of the centre of the circle.
5.	​
	- \[CIRCLE_OUTLINED\] number **outline_width** = `10`
		- The outline width of CIRCLE_OUTLINED type circles.
	- \[CIRCLE_BLURRED\] number **blur_density** = `3`
		- The density of the blur for CIRCLE_BLURRED type circles.
6. \[CIRCLE_BLURRED\] number **blur_quality** = `2`
	- The quality of the blur for CIRCLE_BLURRED type circles.

###### Returns
1. table **circle**
	- The newly created Circle object.


#### RotateVertices(table vertices, number origin_x, number origin_y, number rotation, boolean rotate_uv)
###### Arguments:
1. table **vertices** = `nil`
	- Vertices that you want to be rotate.
2. number **origin_x** = `nil`
	- X position you want the vertices to be rotated around.
3. number **origin_y** = `nil`
	- Y position you want the vertices to be rotated around.
4. number **rotation** = `nil`
	- Amount of degrees to rotate the vertices by. Positive = clockwise.
5. boolean **rotate_uv** = `nil`
	- Whether or not to rotate the UV coordinates too.

###### Returns
1. table **vertices**
	- The rotated vertices.


#### CalculateVertices(x, y, radius, rotation, start_angle, end_angle, distance, rotate_uv)
###### Arguments:
1. number **x** = `0`
	- The X position of the centre of the circle.
2. number **y** = `0`
	- The Y position of the centre of the circle.
3. number **radius** = `16`
	- Radius of the circle.
4. number **rotation** = `0`
	- Amount of degrees to rotate the vertices by. Positive = clockwise.
5. number **start_angle** = `0`
	- Start angle of the circle.
6. number **end_angle** = `360`
	- End angle of the circle.
7. number **distance** = `10`
	- Distance between calculated vertices.
	- Smaller means a smoother circle but more vertices. Larger means a sharper circle but less vertices.
	- Usually you'd use a smaller distance for larger circles, e.g. circles used in 3D2D, and a smaller distance for smaller circles, e.g. circles used in 2D.
8. boolean **rotate_uv** = `nil`
	- Whether or not to rotate the UV coordinates too.

###### Returns
1. table **vertices**
	- The newly calculated circle vertices.



## Methods:
Methods marked with an asterisk (*) are accessors meaning they have Set and Get equivalents.

### *Color(table color)
###### Arguments:
1. table **color** = `false`
	- The colour the circle should be. If not set then the previous colour set with surface.SetDrawColor will be used.


### *Material(IMaterial material)
###### Arguments:
1. IMaterial **material** = `false`
	- The material the circle should have. If not set then the previous material set with surface.SetMaterial will be used. Use `draw.NoTexture` before rendering a circle if you don't want it to have a material.


### *RotateMaterial(boolean rotate)
###### Arguments:
1. boolean **rotate** = `true`
	- Whether or not the UV coordinated should be rotated when the Rotate method is used.


### *DisableClipping(boolean clip)
###### Arguments:
1. boolean **clip** = `false`
	- Whether or not the circle should be clipped when it's rendered. Use this if you render the circle in a vgui element or partially off-screen.


### *Type(number type)
###### Arguments:
1. number **type** = `CIRCLE_FILLED`
	- The type of the circle. Valid options are CIRCLE_FILLED, CIRCLE_OUTLINED, and CIRCLE_BLURRED.


### *X(number x)
###### Arguments:
1. number **x** = `0`
	- The X position of the centre of the circle.


### *Y(number y)
###### Arguments:
1. number **y** = `0`
	- The Y position of the centre of the circle.


### *Radius(number radius)
###### Arguments:
1. number **radius** = `8`
	- The circle's radius.


### *Rotation(number rotation)
###### Arguments:
1. number **rotation** = `0`
	- The absolute rotation, in degrees, of the circle.


### *StartAngle(number start_angle)
###### Arguments:
1. number **start_angle** = `0`
	- The start angle of the circle.


### *EndAngle(number end_angle)
###### Arguments:
1. number **end_angle** = `360`
	- The end angle of the circle.


### *Distance(number distance)
###### Arguments:
1. number **distance** = `10`
	- The distance between the circle's vertices.


### *BlurDensity(number density)
###### Arguments:
1. number **density** = `3`
	- The density of the blur for CIRCLE_BLURRED type circles.


### *BlurQuality(number quality)
###### Arguments:
1. number **quality** = `2`
	- The quality of the blur for CIRCLE_BLURRED type circles.


### *OutlineWidth(number width)
###### Arguments:
1. number **width** = `10`
	- The outline width for CIRCLE_OUTLINED type circles.


### *Pos(number x, number y)
###### Arguments:
1. number **x** = `0`
	- The X position of the centre of the circle.
2. number **y** = `0`
	- The Y position of the centre of the circle.


### *Angles(number start_angle, number end_angle)
###### Arguments:
1. number **start_angle** = `0`
	- The start angle of the circle.
2. number **end_angle** = `360`
	- The end angle of the circle.


### Copy()
###### Returns:
1. table **circle**
	- The copied circle.


### Translate(number x, number y)
###### Arguments:
1. number **x** = `0`
	- The X distance to translate the current X position.
2. number **y** = `0`
	- The Y distance to translate the current Y position.


### Scale(number scale)
###### Arguments:
1. number **scale** = `1`
	- How much to scale the circle's vertices, e.g. a scale of `2` would double the circle's radius.


### Rotate(number degrees)
###### Arguments:
1. number **degrees** = `0`
	- How many degrees to rotate the circle relative to the current rotation.



## Examples:

### Creating and Using Circles:
```lua
-- Be sure to include the file manually. Running it by itself won't do anything.
-- Don't worry about doing this in multiple files since the created table gets cached.
local circles = include("circles.lua")

-- Would create a filled circle 300 pixels wide in the top left of the screen.
local filled = circles.New(CIRCLE_FILLED, 150, 155, 155)

-- An outlined circle with an outline width of 50.
local outlined = circles.New(CIRCLE_OUTLINED, 150, 460, 155, 50)

-- A blurred circle with a blur density of 3 and quality of 2.
local blurred = circles.New(CIRCLE_BLURRED, 150, 765, 155, 3, 2)

local function Example1()
	-- Call draw.NoTexture to stop materials being rendered to the circles.
	draw.NoTexture()

	-- Set the colour of the circles. Can also be done per circle with Circle:SetColor.
	surface.SetDrawColor(color_white)

	-- Drawing the circles is as easy as calling it's reference.
	filled()
	outlined()

	-- Be careful when using CIRCLE_BLURRED type circles since they use surface.SetMaterial internally.
	-- If you want to render something after one make sure to call draw.NoTexture or surface.SetMaterial afterwards.
	blurred()
end
hook.Add("HUDPaint", "Circle Example 1", Example1)
```


### Rotating a Circle:
```lua
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
```


### A Circle Timer:
```lua
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
```


### Partial Circle Health Indicator:
```lua
local circles = include("circles.lua")

local health_color = Color(255, 0, 0)
local health_circle = circles.New(CIRCLE_FILLED, 300, 5, 5)
health_circle:SetColor(health_color)
health_circle:SetAngles(0, 90)

local function Example4()
	local ply = LocalPlayer()

	local hp = ply:Health()
	local maxhp = ply:GetMaxHealth()
	local percent = hp / maxhp

	-- Makes the colour go from red to black the lower it gets.
	health_color.r = 255 * percent

	-- If you wanted it to go from green to red you'd do
	-- health_color.r = 255 - 255 * percent
	-- health_color.g = 255 * percent

	-- The 90 here is how many degrees the quarter circle is.
	--If you wanted to use a full circle for the health meter you'd replace it with 360.
	local end_angle = 90 * percent

	-- Make the partial circle smaller depending on health.
	-- If you wanted to change the end angle you'd do Circle:SetEndAngle(end_angle)
	health_circle:SetStartAngle(90 - end_angle) -- This 90 represents the maximum end angle set above.

	health_circle()
end
hook.Add("HUDPaint", "Circle Example 4", Example4)
```
