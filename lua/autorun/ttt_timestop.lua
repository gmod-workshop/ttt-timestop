AddCSLuaFile()

CreateConVar("ttt_timestop_time", 5, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "How long should time be stopped for?")
CreateConVar("ttt_timestop_range", 1024, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "What radius should time be stopped in? (-1 for infinite)")
CreateConVar("ttt_timestop_fade", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Should a player's screen go black when time is stopped for them?")
CreateConVar("ttt_timestop_immune_traitor", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Should other Traitors be immune to the Time Stop?")
CreateConVar("ttt_timestop_immune_detective", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Should Detectives be immune to the Time Stop?")
CreateConVar("ttt_timestop_random", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Should Time Stop be random for each player?")
CreateConVar("ttt_timestop_random_chance", 0.5, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Chance time stops for each player (if enabled) (0.0 - 1.0)")
CreateConVar("ttt_timestop_tyrone", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Should the alternate Big Man Tyrone sound be used?")

hook.Add("TTTUlxInitCustomCVar", "TimeStopTTTUlxInitCustomCVar", function(name)
  ULib.replicatedWritableCvar("ttt_timestop_time", "rep_ttt_timestop_time", GetConVar("ttt_timestop_time"):GetFloat(), true, false, name)
  ULib.replicatedWritableCvar("ttt_timestop_range", "rep_ttt_timestop_range", GetConVar("ttt_timestop_range"):GetInt(), true, false, name)
  ULib.replicatedWritableCvar("ttt_timestop_fade", "rep_ttt_timestop_fade", GetConVar("ttt_timestop_fade"):GetBool(), true, false, name)
  ULib.replicatedWritableCvar("ttt_timestop_immune_traitor", "rep_ttt_timestop_immune_traitor", GetConVar("ttt_timestop_immune_traitor"):GetBool(), true, false, name)
  ULib.replicatedWritableCvar("ttt_timestop_immune_detective", "rep_ttt_timestop_immune_detective", GetConVar("ttt_timestop_immune_detective"):GetBool(), true, false, name)
  ULib.replicatedWritableCvar("ttt_timestop_random", "rep_ttt_timestop_random", GetConVar("ttt_timestop_random"):GetBool(), true, false, name)
  ULib.replicatedWritableCvar("ttt_timestop_random_chance", "rep_ttt_timestop_random_chance", GetConVar("ttt_timestop_random_chance"):GetFloat(), true, false, name)
  ULib.replicatedWritableCvar("ttt_timestop_tyrone", "rep_ttt_timestop_tyrone", GetConVar("ttt_timestop_tyrone"):GetBool(), true, false, name)
end)

if CLIENT then
  hook.Add("Initialize", "TimeStopInitialize", function()
    if not TTT2 then return end

    STATUS:RegisterStatus("ttt_timestop_timer", {
      hud = Material("vgui/ttt/hud_timestop.png"),
      type = "default"
    })
  end)

  hook.Add("TTTUlxModifyAddonSettings", "TimeStopTTTUlxModifyAddonSettings", function(name)
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

    local tttrsdh14 = xlib.makecheckbox{label = 'ttt_timestop_random (Def. 0)', repconvar = 'rep_ttt_timestop_random', parent = tttrslst1}
    tttrslst1:AddItem(tttrsdh14)

    local tttrsdh15 = xlib.makeslider{label = 'ttt_timestop_random_chance (Def. 0.5)', repconvar = 'rep_ttt_timestop_random_chance', min = 0, max = 1, decimal = 2, parent = tttrslst1}
    tttrslst1:AddItem(tttrsdh15)
    
    local tttrsdh16 = xlib.makecheckbox{label = 'ttt_timestop_tyrone (Def. 0)', repconvar = 'rep_ttt_timestop_tyrone', parent = tttrslst1}
    tttrslst1:AddItem(tttrsdh16)

    -- Immunity Settings 
    local tttrsclp2 = vgui.Create('DCollapsibleCategory', tttrspnl)
    tttrsclp2:SetSize(390, 50)
    tttrsclp2:SetExpanded(1)
    tttrsclp2:SetLabel('Immunity Settings')
      
    local tttrslst2 = vgui.Create('DPanelList', tttrsclp2)
    tttrslst2:SetPos(5, 25)
    tttrslst2:SetSize(390, 50)
    tttrslst2:SetSpacing(5)

    local tttrsdh21 = xlib.makecheckbox{label = 'ttt_timestop_immune_traitor (Def. 0)', repconvar = 'rep_ttt_timestop_immune_traitor', parent = tttrslst2}
    tttrslst2:AddItem(tttrsdh21)

    local tttrsdh22 = xlib.makecheckbox{label = 'ttt_timestop_immune_detective (Def. 0)', repconvar = 'rep_ttt_timestop_immune_detective', parent = tttrslst2}
    tttrslst2:AddItem(tttrsdh22)

    xgui.hookEvent("onProcessModules", nil, tttrspnl.processModules)
    xgui.addSubModule("Time Stop", tttrspnl, nil, name)
  end)
end