AddCSLuaFile()

if SERVER then
	util.AddNetworkString('TimeStop.Stop.PlaySound')
	util.AddNetworkString('TimeStop.Start.PlaySound')
end

if engine.ActiveGamemode() ~= 'terrortown' then
	SWEP.PrintName = 'Time Stop'

	SWEP.Author = 'dhkatz'
	SWEP.Purpose = 'Stop time for everyone but you.'
	SWEP.Instructions = 'Left click to stop time.'

	SWEP.Category = 'Other'
	SWEP.Spawnable = true
	SWEP.AdminOnly = false

	SWEP.Base = 'weapon_base'

	SWEP.Slot = 4
	SWEP.SlotPos = 5

	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
else
	SWEP.PrintName = 'timestop_name'

	SWEP.Base = 'weapon_tttbase'

	SWEP.Slot = 7
	SWEP.Icon = 'vgui/ttt/icon_timestop.png'

	SWEP.EquipMenuData = {
		type = 'item_weapon',
		name = 'timestop_name',
		desc = 'timestop_desc'
	}

	SWEP.Kind = WEAPON_EQUIP2
	SWEP.CanBuy = { ROLE_TRAITOR }
	SWEP.LimitedStock = true

	SWEP.AllowDrop = false
	SWEP.NoSights = true
end

SWEP.HoldType = 'normal'
SWEP.UseHands 							= true
SWEP.ViewModel              			= 'models/weapons/v_crowbar.mdl'
SWEP.WorldModel             			= 'models/weapons/w_crowbar.mdl'
SWEP.ViewModelFOV = 54

SWEP.Primary.ClipSize 					= 8
SWEP.Primary.DefaultClip 				= 8
SWEP.Primary.Automatic 					= false
SWEP.Primary.Ammo 						= 'AR2AltFire'
SWEP.Primary.Delay 						= 999

SWEP.Secondary.ClipSize     			= -1
SWEP.Secondary.DefaultClip  			= -1
SWEP.Secondary.Automatic    			= true
SWEP.Secondary.Ammo         			= 'none'
SWEP.Secondary.Delay        			= 999

hook.Add('ShouldDrawLocalPlayer', 'TimeStopShouldDrawLocalPlayer', function(ply)
	local weapon = ply:GetActiveWeapon()
	if not IsValid(weapon) then return end

	if ply:GetActiveWeapon():GetClass() == 'weapon_ttt_timestop' and ply:GetActiveWeapon():GetTimeStopping() then
		return true
	end
end)

function SWEP:Initialize()
	util.PrecacheSound('the_world_time_stop.mp3')
	util.PrecacheSound('the_world_time_start.mp3')
	util.PrecacheSound('time_to_stop.wav')

	self.ConVarTime = GetConVar('ttt_timestop_time')
	self.ConVarRange = GetConVar('ttt_timestop_range')
	self.ConVarFade = GetConVar('ttt_timestop_fade')
	self.ConVarImmuneTraitor = GetConVar('ttt_timestop_immune_traitor')
	self.ConVarImmuneDetective = GetConVar('ttt_timestop_immune_detective')
	self.ConVarRandom = GetConVar('ttt_timestop_random')
	self.ConVarRandomChance = GetConVar('ttt_timestop_random_chance')
	self.ConVarTyrone = GetConVar('ttt_timestop_tyrone')
	self.ConVarCooldown = GetConVar('ttt_timestop_cooldown')
	self.ConVarVisuals = GetConVar('ttt_timestop_visuals')

	if CLIENT then
		self.ConVarOffset = GetConVar('ttt_timestop_offset')
	end

	if engine.ActiveGamemode() == 'terrortown' then
		self:SetClip1(1)
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar('Bool', 0, 'TimeStopped')
	self:NetworkVar('Bool', 1, 'TimeStopping')
	self:NetworkVar('Entity', 0, 'TimeStopEnv')

	self:SetTimeStopped(false)
	self:SetTimeStopping(false)
	self:SetTimeStopEnv(NULL)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then
		if engine.ActiveGamemode() == 'terrortown' then
			SafeRemoveEntityDelayed(self, 0)
		end
		return
	end

	self:StopTime()

	self:TakePrimaryAmmo(1)
	self:SetNextPrimaryFire(CurTime() + math.max(4 + self.ConVarTime:GetFloat(), self.ConVarCooldown:GetFloat()))
end

function SWEP:SecondaryAttack()
end

function SWEP:CalcView(ply, origin, angle)
	if not self:GetTimeStopping() then
		return origin, angle
	end

	local offset = string.Split(self.ConVarOffset:GetString(), ',')
	offset = Vector(offset[1], offset[2], offset[3])
	offset:Rotate(angle)

	local trace = util.TraceHull({
		start = origin,
		endpos = origin - angle:Forward() * 100,
		filter = {ply:GetActiveWeapon(), ply, ply:GetVehicle()},
		mins = Vector(-4, -4, -4),
		maxs = Vector(4, 4, 4),
	})

	if trace.Hit then
		origin = trace.HitPos
	else
		origin = trace.HitPos
	end

	return origin + offset, angle
end

function SWEP:StopTime()
	if not SERVER then return end
	if self:GetTimeStopping() or self:GetTimeStopped() then return end

	self:SetTimeStopping(true)

	net.Start('TimeStop.Stop.PlaySound')
		net.WriteBool(self.ConVarTyrone:GetBool())
	net.Broadcast()

	timer.Create('StopEffect', 2, 1, function()
		if IsValid(self) then
			self:StopEffect()
		end
	end)

	timer.Create('PrepareTime', 3, 1, function()
		if not IsValid(self) then return end

		self:SetTimeStopped(true)

		RunConsoleCommand('phys_timescale', '0')
		--RunConsoleCommand('ai_disabled', '1')
		RunConsoleCommand('ragdoll_sleepaftertime', '0')

		self:StopEntities()

		local StopLength = self.ConVarTime:GetFloat()

		timer.Create('StopTime', StopLength, 1, function()
			net.Start('TimeStop.Start.PlaySound')
			net.Broadcast()
			if IsValid(self) then
				self:StartTime()
			end
		end)

		timer.Create('StoppingTime', 1, 1, function()
			if IsValid(self) then
				self:SetTimeStopping(false)
			end
		end)
	end)
end

function SWEP:StartTime()
	if not SERVER or not self:GetTimeStopped() then return end

	self:StartEffect()

	timer.Create('StartTime', 1, 1, function()
		RunConsoleCommand('phys_timescale', '1')
		--RunConsoleCommand('ai_disabled', '0')
		RunConsoleCommand('ragdoll_sleepaftertime', '5')

		self:StartEntities()

		if IsValid(self) then
			self:SetTimeStopped(false)
			if engine.ActiveGamemode() == 'terrortown' and self:Clip1() <= 0 then
				SafeRemoveEntityDelayed(self, 0)
			end
		end
	end)
end

function SWEP:StopEffect()
	if not self.ConVarVisuals:GetBool() then return end

	if IsFirstTimePredicted() then
		local effect = EffectData()
		effect:SetEntity(self:GetOwner())
		effect:SetOrigin(self:GetOwner():GetPos())
		effect:SetMagnitude(1)
		util.Effect('tw', effect)
	end

	local timestop = ents.Create('env_timestop')
	timestop:SetOwner(self:GetOwner())
	timestop:Spawn()
	timestop:Activate()
	self:SetTimeStopEnv(timestop)
	self:DeleteOnRemove(timestop)
end

function SWEP:StartEffect()
	if IsValid(self:GetTimeStopEnv()) then
		self:GetTimeStopEnv():Remove()
	end

	self:SetTimeStopEnv(NULL)

	if not self.ConVarVisuals:GetBool() then return end

	timer.Simple(0.01, function()
		if not IsValid(self) then return end

		local effect = EffectData()
		effect:SetEntity(self:GetOwner())
		effect:SetOrigin(self:GetOwner():GetPos())
		effect:SetMagnitude(3)
		util.Effect('tw', effect)
	end)
end

function SWEP:StopEntities()
	local StopLength = self.ConVarTime:GetFloat()
	local players = {}

	for k, v in pairs(ents.GetAll()) do
		if not (self:CheckChance(v) and self:CheckRole(v) and self:CheckRadius(v)) then continue end

		if v:IsPlayer() then
			v:Freeze(true)

			if engine.ActiveGamemode() == 'terrortown' then
				v:SetMoveType(MOVETYPE_NOCLIP)
			end

			if self.ConVarFade:GetBool() then
				v:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0), 1, StopLength)
			else
				v:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 200), 1, StopLength)
			end

			table.insert(players, v)
		elseif v:IsNPC() then
			v:SetSchedule(SCHED_NPC_FREEZE)
		end

		if not self:CheckEntity(v) then continue end

		v:SetNWBool('TimeStopped', true)
		v:SetNWInt('TimeStoppedCount', v:GetNWBool('TimeStoppedCount', 0) + 1)
	end

	table.insert(players, self:GetOwner())

	if TTT2 and #players > 0 then
		STATUS:AddTimedStatus(players, 'ttt_timestop_timer', StopLength, true)
	end
end

function SWEP:StartEntities()
	for k, v in pairs(ents.GetAll()) do
		local timeStopped = v:GetNWBool('TimeStopped', false)
		local timeStoppedCount = math.max(v:GetNWBool('TimeStoppedCount', 0) - 1, 0)

		v:SetNWInt('TimeStoppedCount', timeStoppedCount)
		v:SetNWBool('TimeStopped', timeStoppedCount > 0)

		if timeStoppedCount > 0 or not timeStopped then continue end

		if v:IsPlayer() then
			if engine.ActiveGamemode() == 'terrortown' then
				if v:IsActive() then
					v:Freeze(false)
					v:SetMoveType(MOVETYPE_WALK)
				end
			else
				v:Freeze(false)
			end
		elseif v:IsNPC() and v:GetCurrentSchedule() == SCHED_NPC_FREEZE then
			v:SetCondition(COND.NPC_UNFREEZE)
		end
	end
end

function SWEP:CheckRadius(v)
	local range = self.ConVarRange:GetFloat()

	if range == 0 then
		return false
	else
		if range == -1 then
			return true
		else
			return self:GetOwner():GetPos():Distance(v:GetPos()) <= range
		end
	end
end

function SWEP:CheckRole(v)
	if v == self:GetOwner() then
		return false
	end

	if v:IsWeapon() and v:GetOwner() == self:GetOwner() then
		return false
	end

	if engine.ActiveGamemode() ~= 'terrortown' then
		return true
	else
		if not v:IsPlayer() then return true end

		if self.ConVarImmuneTraitor:GetBool() and v:IsActiveTraitor() then
			return false
		else
			if self.ConVarImmuneDetective:GetBool() and v:IsActiveDetective() then
				return false
			else
				if v:IsActive() then
					return true
				end
			end
		end
	end
end

function SWEP:CheckChance(v)
	if not v:IsPlayer() and not v:IsNPC() then return true end

	if self.ConVarRandom:GetBool() then
		return math.random() <= self.ConVarRandomChance:GetFloat()
	else
		return true
	end
end

function SWEP:CheckEntity(v)
	if v:IsWorld() then return false end

	local cls = v:GetClass()
	if cls == 'predicted_viewmodel' then return false end
	if string.StartsWith(cls, 'env_') then return false end
	if string.StartsWith(cls, 'info_') then return false end
	if string.StartsWith(cls, 'point_') then return false end

	return true
end

function SWEP:OnRemove()
	if SERVER and self:GetTimeStopped() then
		timer.Remove('StartTime')
		timer.Remove('StopTime')
		timer.Remove('PrepareTime')
		net.Start('TimeStop.Start.PlaySound')
		net.Broadcast()

		timer.Create('StartTime', 1, 1, function()
			RunConsoleCommand('phys_timescale', '1')
			--RunConsoleCommand('ai_disabled', '0')
			RunConsoleCommand('ragdoll_sleepaftertime', '5')

			for k, v in pairs(player.GetAll()) do
				v:Freeze(false)
				v:SetMoveType(MOVETYPE_WALK)
			end
		end)

		self:SetTimeStopped(false)
	end
end

function SWEP:Deploy()
	return true
end

function SWEP:Reload()
	if engine.ActiveGamemode() == 'terrortown' then return false end

	self:DefaultReload(ACT_VM_IDLE)
end

function SWEP:Holster()
	return true
end

function SWEP:OnDrop()
	SafeRemoveEntityDelayed(self, 0)
end

function SWEP:ShouldDropOnDie()
	return false
end

if CLIENT then
	net.Receive('TimeStop.Stop.PlaySound', function()
		if net.ReadBool() then
			surface.PlaySound('time_to_stop.wav')
		else
			surface.PlaySound('the_world_time_stop.mp3')
		end
	end)

	net.Receive('TimeStop.Start.PlaySound', function()
		surface.PlaySound('the_world_time_start.mp3')
	end)
else
	hook.Add('Tick', 'TimeStopTick', function()
		for k, v in pairs(ents.GetAll()) do
			if not v:IsPlayer() and not v:IsNPC() and v:GetNWBool('TimeStopped', false) then
				v:SetPlaybackRate(0)
			end
		end
	end)
end
