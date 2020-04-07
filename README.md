# Circles!

## Functions:
#### New(number type, number radius, number x, number y, number outline_width | number blur_density, blur_quality)
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
	
#### RotateVertices(table vertices, number origin_x, number origin_y, number rotation, boolean rotate_uv)
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
	
#### CalculateVertices(x, y, radius, rotation, start_angle, end_angle, distance, rotate_uv)
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
	- Usually you'd use a smaller distance for larger circles and a smaller distance for smaller circles.
8. boolean **rotate_uv** = `nil`
	- Whether or not to rotate the UV coordinates too.
	

## Examples:
Coming soon!
