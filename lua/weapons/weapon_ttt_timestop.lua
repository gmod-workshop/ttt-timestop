AddCSLuaFile()

SWEP.HoldType 							= "normal"

if CLIENT then
	LANG.AddToLanguage("english", "timestop_weapon_name", "Time Stop")
	LANG.AddToLanguage("english", "timestop_weapon_desc", "One second... Two seconds...\n")

	SWEP.PrintName 						= "timestop_weapon_name"
	SWEP.Slot 							= 7
	SWEP.Icon 							= "vgui/ttt/icon_timestop.png"

	SWEP.DrawCrosshair 					= false
	SWEP.ViewModelFOV 					= 10

	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "timestop_weapon_desc"
	}
else
	resource.AddWorkshop("1337349942") -- This addon!
	resource.AddFile("sound/the_world_time_start.mp3")
	resource.AddFile("sound/the_world_time_stop.mp3")
	resource.AddFile("sound/time_to_stop.wav")
	resource.AddFile("materials/vgui/ttt/icon_timestop.png")
	resource.AddFile("materials/vgui/ttt/hud_timestop.png")
	util.AddNetworkString("TimeStop.Stop.PlaySound")
	util.AddNetworkString("TimeStop.Start.PlaySound")
end


SWEP.Base 								= "weapon_tttbase"

SWEP.Kind 								= WEAPON_EQUIP2
SWEP.CanBuy 							= {ROLE_TRAITOR}

SWEP.UseHands 							= true
SWEP.ViewModel              			= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel             			= "models/weapons/w_crowbar.mdl"

SWEP.Primary.ClipSize 					= -1
SWEP.Primary.DefaultClip 				= -1
SWEP.Primary.Automatic 					= false
SWEP.Primary.Ammo 						= "none"
SWEP.Primary.Delay 						= 999

SWEP.Secondary.ClipSize     			= -1
SWEP.Secondary.DefaultClip  			= -1
SWEP.Secondary.Automatic    			= true
SWEP.Secondary.Ammo         			= "none"
SWEP.Secondary.Delay        			= 999

SWEP.LimitedStock 						= true
SWEP.AllowDrop 							= false

SWEP.NoSights 							= true

function SWEP:Initialize()
	self.IsTimeStopped = false
	util.PrecacheSound("the_world_time_stop.mp3")
	util.PrecacheSound("the_world_time_start.mp3")
	util.PrecacheSound("time_to_stop.wav")
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:StopTime()
end

function SWEP:SecondaryAttack()
end

function SWEP:StopTime()
	if SERVER then
		net.Start("TimeStop.Stop.PlaySound")
			net.WriteBool(GetConVar("ttt_timestop_tyrone"):GetBool())
		net.Broadcast()

		timer.Create("PrepareTime", 3, 1, function()
			self.IsTimeStopped = true
			RunConsoleCommand("phys_timescale", "0")
			--RunConsoleCommand("ai_disabled", "1")
			RunConsoleCommand("ragdoll_sleepaftertime", "0")
			local StopLength = GetConVar("ttt_timestop_time"):GetFloat()
			local players = {}

			for k, v in pairs(player.GetAll()) do
				if self:CheckChance() and self:CheckRole(v) and self:CheckRadius(v) then
					v:Freeze(true)
					v:SetMoveType(MOVETYPE_NOCLIP)

					if GetConVar("ttt_timestop_fade"):GetBool() then
						v:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0), 1, StopLength)
					else
						v:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 200), 1, StopLength)
					end

					table.insert(players, v)
				end
			end

			table.insert(players, self.Owner)

			if TTT2 and #players > 0 then
				STATUS:AddTimedStatus(players, "ttt_timestop_timer", StopLength, true)
			end

			timer.Create("StopTime", StopLength, 1, function()
				net.Start("TimeStop.Start.PlaySound")
				net.Broadcast()
				self:StartTime()
			end)
		end)
	end
end

function SWEP:StartTime()
	if SERVER and self.IsTimeStopped then
		timer.Create("StartTime", 1, 1, function()
			RunConsoleCommand("phys_timescale", "1")
			--RunConsoleCommand("ai_disabled", "0")
			RunConsoleCommand("ragdoll_sleepaftertime", "5")

			for k, v in pairs(player.GetAll()) do
				if v:IsActive() then
					v:Freeze(false)
					v:SetMoveType(MOVETYPE_WALK)
				end
			end

			self.IsTimeStopped = false
			self:Remove()
		end)
	end
end

function SWEP:CheckRadius(v)
	local range = GetConVar("ttt_timestop_range"):GetFloat()

	if range == 0 then
		return false
	else
		if range == -1 then
			return true
		else
			return self.Owner:GetPos():Distance(v:GetPos()) <= range
		end
	end
end

function SWEP:CheckRole(v)
	if v == self.Owner then
		return false
	else
		if GetConVar("ttt_timestop_immune_traitor"):GetBool() and v:IsActiveTraitor() then
			return false
		else
			if GetConVar("ttt_timestop_immune_detective"):GetBool() and v:IsActiveDetective() then
				return false
			else
				if v:IsActive() then
					return true
				end
			end
		end
	end
end

function SWEP:CheckChance()
	if GetConVar("ttt_timestop_random"):GetBool() then
		return math.random() <= GetConVar("ttt_timestop_random_chance"):GetFloat()
	else
		return true
	end
end

function SWEP:OnRemove()
	if SERVER and self.IsTimeStopped then
		timer.Remove("StartTime")
		timer.Remove("StopTime")
		timer.Remove("PrepareTime")
		net.Start("TimeStop.Start.PlaySound")
		net.Broadcast()

		timer.Create("StartTime", 1, 1, function()
			RunConsoleCommand("phys_timescale", "1")
			--RunConsoleCommand("ai_disabled", "0")
			RunConsoleCommand("ragdoll_sleepaftertime", "5")

			for k, v in pairs(player.GetAll()) do
				v:Freeze(false)
				v:SetMoveType(MOVETYPE_WALK)
			end
		end)

		self.IsTimeStopped = false
	end
end

function SWEP:Deploy()
	self.Owner:DrawViewModel(false)

	self:DrawShadow(false)

	return true
end

function SWEP:Reload()
	return false
end

function SWEP:Holster()
	return true
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:ShouldDropOnDie()
	return false
end

if CLIENT then
	net.Receive("TimeStop.Stop.PlaySound", function()
		if net.ReadBool() then
			surface.PlaySound("time_to_stop.wav")
		else
			surface.PlaySound("the_world_time_stop.mp3")
		end
	end)

	net.Receive("TimeStop.Start.PlaySound", function()
		surface.PlaySound("the_world_time_start.mp3")
	end)
end
