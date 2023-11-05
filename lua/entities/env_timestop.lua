AddCSLuaFile()

ENT.Type = 'anim'
ENT.PrintName = 'Time Stop Effect'
ENT.Author = 'dhkatz & Copper'

ENT.Spawnable = false
ENT.AdminOnly = true

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self:SetPos(self:GetOwner():EyePos())
	self:SetModel('models/XQM/Rails/gumball_1.mdl')
	self:SetModelScale(0.1)
	self:SetModelScale(100, 3)
	timer.Simple(1, function()
		if IsValid(self) then
			self:SetModelScale(0.01, 1)
		end
	end)

	if CLIENT then
		local modify = {
			[ '$pp_colour_addr' ] =  0,
			[ '$pp_colour_addg' ] =  0,
			[ '$pp_colour_addb' ] =  0,
			[ '$pp_colour_brightness' ] =  0,
			[ '$pp_colour_contrast' ] = 0.4,
			[ '$pp_colour_colour' ] = 0.01,
			[ '$pp_colour_mulr' ] = 0.5,
			[ '$pp_colour_mulg' ] = 0.5,
			[ '$pp_colour_mulb' ] = 0.5
		}

		hook.Add('PostDrawTranslucentRenderables', 'TimeStopColor', function()
			render.ClearStencil()
			render.SetStencilEnable(true)
			render.SetStencilWriteMask(1)
			render.SetStencilTestMask(1)
			render.SetStencilReferenceValue(1)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
			render.SetStencilZFailOperation(STENCILOPERATION_KEEP)

			self:SetMaterial('models/shadertest/shader4')

			self:DrawModel()

			DrawColorModify(modify)

			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
			render.SetStencilEnable(false)
		end)
		render.UpdateScreenEffectTexture()
	end
end

function ENT:Think()
	if CLIENT then
		self:SetPos(EyePos() + EyeAngles():Forward() * 2)
		self:SetupBones()
	end
end

function ENT:SetupDataTables()
	self:NetworkVar('Entity', 0, 'Player')

	self:SetPlayer(self:GetOwner())
end

function ENT:OnRemove()
	if CLIENT then
		hook.Remove('PostDrawTranslucentRenderables', 'TimeStopColor')
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Draw()

end

function ENT:DrawTranslucent()
	self:SetPos(EyePos() + EyeAngles():Forward() * 55)
	self:SetupBones()

	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilWriteMask(0xFF)
	render.SetStencilTestMask(0xFF)
	render.SetStencilReferenceValue(0xFF)
	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)

	self:SetMaterial('models/shadertest/shader4')

	if IsValid(self:GetOwner()) then
		self:SetPos(self:GetOwner():EyePos())
	end
	self:SetupBones()
	self:DrawModel()

	local color = HSVToColor((CurTime() * 255) % 360, 1, 1)
	local modify = {
		['$pp_colour_addr'] = color.r / 4096,
		['$pp_colour_addg'] = color.g / 4096,
		['$pp_colour_addb'] = color.b / 4096,
		['$pp_colour_brightness'] = 0,
		['$pp_colour_contrast'] = 1,
		['$pp_colour_colour'] = -2,
		['$pp_colour_mulr'] = -1,
		['$pp_colour_mulg'] = -1,
		['$pp_colour_mulb'] = -1
	}

	render.SetBlend(1)
	DrawColorModify(modify)

	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.SetStencilEnable(false)
end
