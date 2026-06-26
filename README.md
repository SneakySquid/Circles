# Circles! 2 Available Now:
https://steamcommunity.com/sharedfiles/filedetails/?id=2345345767

### Benchmarks:
###### Averaged over 50,000 frames.
```
FILLED
	shader_filled                  total: 1.11235390s   avg: 0.02224708ms   fastest
	drawpoly_filled_cached         total: 15.08045330s   avg: 0.30160907ms   +1255.72% slower
	drawpoly_filled                total: 27.56120290s   avg: 0.55122406ms   +2377.74% slower

OUTLINED
	shader_outlined                total: 1.12631550s   avg: 0.02252631ms   fastest
	drawpoly_outlined_cached       total: 27.66445510s   avg: 0.55328910ms   +2356.19% slower
	drawpoly_outlined              total: 72.46823810s   avg: 1.44936476ms   +6334.10% slower

BLURRED
	shader_blurred                 total: 1.24676350s   avg: 0.02493527ms   fastest
	drawpoly_blurred_cached        total: 19.84194110s   avg: 0.39683882ms   +1491.48% slower
	drawpoly_blurred               total: 32.52834620s   avg: 0.65056692ms   +2509.02% slower
```

---

# Circles!
[Methods](#methods)

## Functions:

#### New(number type, number radius, number x, number y, number outline_width | number blur_density, blur_quality)
###### Arguments:
1. number **type** = `CIRCLE_FILLED`
	- The type of circle to make. Valid options are CIRCLE_FILLED, CIRCLE_OUTLINED, and CIRCLE_BLURRED.
2. number **radius** = `8`
	- The radius of the circle.
3. number **x** = `0`
	- The X position of the centre of the circle.
4. number **y** = `0`
	- The Y position of the centre of the circle.
5.	​
	- \[CIRCLE_OUTLINED\] number **outline_width** = `10`
		- The outline width of CIRCLE_OUTLINED type circles.
	- \[CIRCLE_BLURRED\] number **blur_layers** = `3`
		- The amount of layers of blur for CIRCLE_BLURRED type circles.
6. \[CIRCLE_BLURRED\] number **blur_density** = `2`
	- The density of the blur for CIRCLE_BLURRED type circles.

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
	- The material the circle should have. If not set then the previous material set with surface.SetMaterial will be used. Set to `true` or call `draw.NoTexture` before rendering a circle if you don't want it to have a material.


### *AcceptRadians(boolean accept_rads)
1. boolean **accept_rads** = `false`
	- Converts function inputs to degrees. Functions affected by this are Rotate, SetRotation, SetStartAngle, SetEndAngle, and SetAngles.

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
