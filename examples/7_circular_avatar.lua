local circles = include("circles.lua")

-- Method 1 using Images!
-- Less FPS and memory intensive
-- Easier to implement

local images = include("images.lua") -- https://pastebin.com/Qf2zAU95

local method1 = circles.New(CIRCLE_FILLED, 32, 32, 64)
method1:SetDistance(1)
method1:SetColor(color_white)
method1:SetMaterial(images.GetAvatar(LocalPlayer(), 64)) -- Also works with SteamID64 in place of a player


-- Method 2 using stencils
-- Looks marginally nicer

do
	local PANEL = {}

	function PANEL:Init()
		self.mask = circles.New(CIRCLE_FILLED, 32, 32, 32)
		self.mask:SetDistance(1)

		self.avatar = self:Add("AvatarImage")
		self.avatar:Dock(FILL)
		self.avatar:SetPaintedManually(true)

		self.SetPlayer = function(self, ...) self.avatar:SetPlayer(...) end
		self.SetSteamID = function(self, ...) self.avatar:SetSteamID(...) end
	end

	function PANEL:OnSizeChanged(w, h)
		self.mask:SetPos(w / 2, h / 2)
		self.mask:SetRadius(math.min(w, h) / 2)
	end

	function PANEL:Paint(w, h)
		render.ClearStencil()
		render.SetStencilEnable(true)
			render.SetStencilWriteMask(1)
			render.SetStencilTestMask(1)

			render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
			render.SetStencilPassOperation(STENCILOPERATION_ZERO)
			render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
			render.SetStencilReferenceValue(1)

			draw.NoTexture()
			surface.SetDrawColor(255, 255, 255)
			self.mask()

			render.SetStencilFailOperation(STENCILOPERATION_ZERO)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
			render.SetStencilReferenceValue(1)

			self.avatar:PaintManual()
		render.SetStencilEnable(false)
		render.ClearStencil()
	end

	vgui.Register("CircularAvatar", PANEL)
end

local avatar = vgui.Create("CircularAvatar")
avatar:SetSize(64, 64)
avatar:SetPos(0, 96)
avatar:SetPaintedManually(true)
avatar:SetPlayer(LocalPlayer(), 64)

local function method2()
	avatar:PaintManual()
end

-- Comparison: https://i.imgur.com/fS7KbPY.png
local function Example7()
	method1()
	method2()
end
hook.Add("HUDPaint", "Circles Example 7", Example7)
