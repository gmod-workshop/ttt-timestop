AddCSLuaFile()

-- Resource Caching

if SERVER then
	resource.AddWorkshop('1337349942') -- This addon!

	resource.AddFile('sound/the_world_time_start.mp3')
	resource.AddFile('sound/the_world_time_stop.mp3')
	resource.AddFile('sound/time_to_stop.wav')

	resource.AddFile('materials/vgui/ttt/icon_timestop.png')
	resource.AddFile('materials/vgui/ttt/hud_timestop.png')
end

-- ConVars

CreateConVar('ttt_timestop_time', 5, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, 'How long should time be stopped for?')
CreateConVar('ttt_timestop_range', 1024, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, 'What radius should time be stopped in? (-1 for infinite)')
CreateConVar('ttt_timestop_fade', 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, 'Should a player\'s screen go black when time is stopped for them?')
CreateConVar('ttt_timestop_immune_traitor', 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, 'Should other Traitors be immune to the Time Stop?')
CreateConVar('ttt_timestop_immune_detective', 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, 'Should Detectives be immune to the Time Stop?')
CreateConVar('ttt_timestop_random', 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, 'Should Time Stop be random for each player?')
CreateConVar('ttt_timestop_random_chance', 0.5, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, 'Chance time stops for each player (if enabled) (0.0 - 1.0)')
CreateConVar('ttt_timestop_tyrone', 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, 'Should the alternate Big Man Tyrone sound be used?')
CreateConVar('ttt_timestop_cooldown', 10, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, 'How long should the cooldown be (in seconds)?')
CreateConVar('ttt_timestop_visuals', 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, 'Should the Time Stop visuals be shown?')

CreateClientConVar('ttt_timestop_offset', '0,0,0', true, false, 'The offset of the Time Stop effect (X,Y,Z)')

-- Sandbox Compatibility

hook.Add('AddToolMenuCategories', 'TimeStopAddToolMenuCategories', function()
	spawnmenu.AddToolCategory('Utilities', 'Time Stop', 'Time Stop')
end)

local TIMESTOP_DEFAULTS = {
	['ttt_timestop_time'] = 5,
	['ttt_timestop_range'] = 1024,
	['ttt_timestop_fade'] = 0,
	['ttt_timestop_immune_traitor'] = 0,
	['ttt_timestop_immune_detective'] = 0,
	['ttt_timestop_random'] = 0,
	['ttt_timestop_random_chance'] = 0.5,
	['ttt_timestop_tyrone'] = 0,
	['ttt_timestop_cooldown'] = 10,
	['ttt_timestop_visuals'] = 1
}

hook.Add('PopulateToolMenu', 'TimeStopPopulateToolMenu', function()
	spawnmenu.AddToolMenuOption('Utilities', 'Time Stop', 'time_stop', 'Settings', '', '', function(panel)
		panel:Help('Time Stop Settings')

		panel:ToolPresets('ttt_timestop_presets', TIMESTOP_DEFAULTS)

		panel:Help('General Settings')

		panel:NumSlider('Time Stop Time', 'ttt_timestop_time', 1, 10, 1)
		panel:ControlHelp('How long should time be stopped for?')

		panel:NumSlider('Time Stop Range', 'ttt_timestop_range', 0, 4096, 0)
		panel:ControlHelp('What radius should time be stopped in? (-1 for infinite)')

		panel:CheckBox('Time Stop Fade', 'ttt_timestop_fade')
		panel:ControlHelp('Should a player\'s screen go black when time is stopped for them?')

		panel:NumSlider('Time Stop Cooldown', 'ttt_timestop_cooldown', 5, 60, 1)
		panel:ControlHelp('How long should the cooldown be (in seconds)?')

		panel:Help('Immunity Settings')

		panel:CheckBox('Time Stop Immune Traitor', 'ttt_timestop_immune_traitor')
		panel:ControlHelp('Should other Traitors be immune to the Time Stop?')

		panel:CheckBox('Time Stop Immune Detective', 'ttt_timestop_immune_detective')
		panel:ControlHelp('Should Detectives be immune to the Time Stop?')

		panel:Help('Chance Settings')

		panel:CheckBox('Time Stop Random', 'ttt_timestop_random')
		panel:ControlHelp('Should Time Stop be random for each player?')

		panel:NumSlider('Time Stop Random Chance', 'ttt_timestop_random_chance', 0, 1, 2)
		panel:ControlHelp('Chance time stops for each player (if enabled) (0.0 - 1.0)')

		panel:Help('Effect Settings')

		panel:CheckBox('Time Stop Visuals', 'ttt_timestop_visuals')
		panel:ControlHelp('Should the Time Stop visuals be shown?')

		panel:CheckBox('Time Stop Tyrone', 'ttt_timestop_tyrone')
		panel:ControlHelp('Should the alternate Big Man Tyrone sound be used?')
	end)
end)

-- TTT Compatibility

hook.Add('InitPostEntity', 'TimeStopInitPostEntity', function()
	if TTT2 ~= nil or LANG == nil then return end

	LANG.AddToLanguage('English', 'timestop_name', 'Time Stop')
	LANG.AddToLanguage('English', 'timestop_desc', 'One second... Two seconds...\n')
end)

-- TTT ULX Compatibility

hook.Add('TTTUlxInitCustomCVar', 'TimeStopTTTUlxInitCustomCVar', function(name)
	ULib.replicatedWritableCvar('ttt_timestop_time', 'rep_ttt_timestop_time', GetConVar('ttt_timestop_time'):GetFloat(), true, false, name)
	ULib.replicatedWritableCvar('ttt_timestop_range', 'rep_ttt_timestop_range', GetConVar('ttt_timestop_range'):GetInt(), true, false, name)
	ULib.replicatedWritableCvar('ttt_timestop_fade', 'rep_ttt_timestop_fade', GetConVar('ttt_timestop_fade'):GetBool(), true, false, name)
	ULib.replicatedWritableCvar('ttt_timestop_immune_traitor', 'rep_ttt_timestop_immune_traitor', GetConVar('ttt_timestop_immune_traitor'):GetBool(), true, false, name)
	ULib.replicatedWritableCvar('ttt_timestop_immune_detective', 'rep_ttt_timestop_immune_detective', GetConVar('ttt_timestop_immune_detective'):GetBool(), true, false, name)
	ULib.replicatedWritableCvar('ttt_timestop_random', 'rep_ttt_timestop_random', GetConVar('ttt_timestop_random'):GetBool(), true, false, name)
	ULib.replicatedWritableCvar('ttt_timestop_random_chance', 'rep_ttt_timestop_random_chance', GetConVar('ttt_timestop_random_chance'):GetFloat(), true, false, name)
	ULib.replicatedWritableCvar('ttt_timestop_tyrone', 'rep_ttt_timestop_tyrone', GetConVar('ttt_timestop_tyrone'):GetBool(), true, false, name)
	ULib.replicatedWritableCvar('ttt_timestop_cooldown', 'rep_ttt_timestop_cooldown', GetConVar('ttt_timestop_cooldown'):GetFloat(), true, false, name)
	ULib.replicatedWritableCvar('ttt_timestop_visuals', 'rep_ttt_timestop_visuals', GetConVar('ttt_timestop_visuals'):GetBool(), true, false, name)
end)

if CLIENT then
	hook.Add('TTTUlxModifyAddonSettings', 'TimeStopTTTUlxModifyAddonSettings', function(name)
		local tttrspnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

		-- Basic Settings 
		local tttrsclp1 = vgui.Create('DCollapsibleCategory', tttrspnl)
		tttrsclp1:SetSize(390, 50)
		tttrsclp1:SetExpanded(1)
		tttrsclp1:SetLabel('Basic Settings')

		local tttrslst1 = vgui.Create('DPanelList', tttrsclp1)
		tttrslst1:SetPos(5, 25)
		tttrslst1:SetSize(390, 150)
		tttrslst1:SetSpacing(5)

		local tttrsdh11 = xlib.makeslider{label = 'ttt_timestop_time (Def. 5)', repconvar = 'rep_ttt_timestop_time', min = 1, max = 10, decimal = 1, parent = tttrslst1}
		tttrslst1:AddItem(tttrsdh11)

		local tttrsdh12 = xlib.makeslider{label = 'ttt_timestop_range (Def. 1024)', repconvar = 'rep_ttt_timestop_range', min = 0, max = 4096, decimal = 0, parent = tttrslst1}
		tttrslst1:AddItem(tttrsdh12)

		local tttrsdh13 = xlib.makecheckbox{label = 'ttt_timestop_fade (Def. 0)', repconvar = 'rep_ttt_timestop_fade', parent = tttrslst1}
		tttrslst1:AddItem(tttrsdh13)

		local tttrsdh14 = xlib.makeslider{label = 'ttt_timestop_cooldown (Def. 10)', repconvar = 'rep_ttt_timestop_cooldown', min = 0, max = 60, decimal = 1, parent = tttrslst1}
		tttrslst1:AddItem(tttrsdh14)

		-- Chance Settings
		local tttrsclp2 = vgui.Create('DCollapsibleCategory', tttrspnl)
		tttrsclp2:SetSize(390, 50)
		tttrsclp2:SetExpanded(1)
		tttrsclp2:SetLabel('Chance Settings')

		local tttrslst2 = vgui.Create('DPanelList', tttrsclp2)
		tttrslst2:SetPos(5, 25)
		tttrslst2:SetSize(390, 50)
		tttrslst2:SetSpacing(5)

		local tttrsdh21 = xlib.makecheckbox{label = 'ttt_timestop_random (Def. 0)', repconvar = 'rep_ttt_timestop_random', parent = tttrslst2}
		tttrslst1:AddItem(tttrsdh21)

		local tttrsdh22 = xlib.makeslider{label = 'ttt_timestop_random_chance (Def. 0.5)', repconvar = 'rep_ttt_timestop_random_chance', min = 0, max = 1, decimal = 2, parent = tttrslst2}
		tttrslst1:AddItem(tttrsdh22)

		-- Immunity Settings 
		local tttrsclp3 = vgui.Create('DCollapsibleCategory', tttrspnl)
		tttrsclp3:SetSize(390, 50)
		tttrsclp3:SetExpanded(1)
		tttrsclp3:SetLabel('Immunity Settings')

		local tttrslst3 = vgui.Create('DPanelList', tttrsclp3)
		tttrslst3:SetPos(5, 25)
		tttrslst3:SetSize(390, 50)
		tttrslst3:SetSpacing(5)

		local tttrsdh31 = xlib.makecheckbox{label = 'ttt_timestop_immune_traitor (Def. 0)', repconvar = 'rep_ttt_timestop_immune_traitor', parent = tttrslst3}
		tttrslst3:AddItem(tttrsdh31)

		local tttrsdh32 = xlib.makecheckbox{label = 'ttt_timestop_immune_detective (Def. 0)', repconvar = 'rep_ttt_timestop_immune_detective', parent = tttrslst3}
		tttrslst3:AddItem(tttrsdh32)

		-- Effect Settings
		local tttrsclp4 = vgui.Create('DCollapsibleCategory', tttrspnl)
		tttrsclp4:SetSize(390, 50)
		tttrsclp4:SetExpanded(1)
		tttrsclp4:SetLabel('Effect Settings')

		local tttrslst4 = vgui.Create('DPanelList', tttrsclp4)
		tttrslst4:SetPos(5, 25)
		tttrslst4:SetSize(390, 50)
		tttrslst4:SetSpacing(5)

		local tttrsdh41 = xlib.makecheckbox{label = 'ttt_timestop_visuals (Def. 1)', repconvar = 'rep_ttt_timestop_visuals', parent = tttrslst4}
		tttrslst4:AddItem(tttrsdh41)

		local tttrsdh42 = xlib.makecheckbox{label = 'ttt_timestop_tyrone (Def. 0)', repconvar = 'rep_ttt_timestop_tyrone', parent = tttrslst4}
		tttrslst4:AddItem(tttrsdh42)

		xgui.hookEvent('onProcessModules', nil, tttrspnl.processModules)
		xgui.addSubModule('Time Stop', tttrspnl, nil, name)
	end)
end

-- TTT2 Compatibility

if CLIENT then
	hook.Add('Initialize', 'TimeStopInitialize', function()
		if not TTT2 then return end

		STATUS:RegisterStatus('ttt_timestop_timer', {
			hud = Material('vgui/ttt/hud_timestop.png'),
			type = 'default'
		})
	end)
end
