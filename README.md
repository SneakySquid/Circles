# Circles!

## Example:
```lua
include("circles.lua")

local filled = draw.NewCircle(CIRCLE_FILLED)
filled:SetPos(150, 150)
filled:SetRadius(128)

local outlined = filled:Copy()
outlined:SetType(CIRCLE_OUTLINED)
outlined:OffsetVertices(256 + 5, 0)
outlined:SetThickness(10)

local blurred = outlined:Copy()
blurred:SetType(CIRCLE_BLURRED)
blurred:OffsetVertices(256 + 5, 0)

local TestMat = Material("error")

hook.Add("HUDPaint", "Circle Example", function()
	filled(color_white)
	outlined(color_white, TestMat)
	blurred(color_white)
end)
```
 ## Output:
 ![](https://i.imgur.com/gy3MyfB.png)
