local M = icrowMedia

local width = 140
local height = 5
local ypos = -12
local xpcolor = {r = 0, g = 0.6, b = 1}

local bf = CreateFrame("Frame", nil, Minimap)
bf:SetFrameStrata("LOW")
bf:SetFrameLevel(2)
bf:SetWidth(width)
bf:SetHeight(height)
bf:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 0, ypos)
M.CreateBG(bf)
M.CreateSD(bf)
bf:Hide()

local rbar = CreateFrame("StatusBar", "jRestBar", bf)
rbar:SetStatusBarTexture(M.media.statusbar)
rbar:SetStatusBarColor(0, 0.6, 1, 0.3)
rbar:SetFrameStrata("LOW")
rbar:SetFrameLevel(1)
rbar:SetWidth(width)
rbar:SetHeight(height)
rbar:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 0, ypos)
rbar:SetMinMaxValues(0,1)
rbar:SetValue(0)
rbar:Show()

local xbar = CreateFrame("StatusBar", "jExpBar", bf)
xbar:SetStatusBarTexture(M.media.statusbar)
xbar:SetStatusBarColor(xpcolor.r,xpcolor.g,xpcolor.b, 0.85)
xbar:SetFrameStrata("LOW")
xbar:SetFrameLevel(3)
xbar:SetWidth(width)
xbar:SetHeight(height)
xbar:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 0, ypos)
xbar:Show()

function rbar_ReSetValue(rxp, xp, mxp)
	if rxp then
		if rxp+xp >= mxp then
			rbar:SetValue(mxp)
		else
			rbar:SetValue(rxp+xp)
		end
	else
		rbar:SetValue(0)
	end
end	

function bf_ShowRep()
	name, standing, minrep, maxrep, value = GetWatchedFactionInfo()
	if name then
		bf:Show()
		xbar:SetStatusBarColor(FACTION_BAR_COLORS[standing].r, FACTION_BAR_COLORS[standing].g, FACTION_BAR_COLORS[standing].b, 0.85)
		xbar:SetMinMaxValues(minrep,maxrep)
		xbar:SetValue(value)
		rbar:SetValue(0)
	elseif UnitLevel("player") ~= MAX_PLAYER_LEVEL then
		bf:Show()
		mxp = UnitXPMax("player")
		xp = UnitXP("player")
		rxp = GetXPExhaustion()
		bf_ShowXP(rxp, xp, mxp)
	else
		bf:Hide()
	end
end

function bf_ShowXP(rxp, xp, mxp)
	bf:Show()
	xbar:SetStatusBarColor(xpcolor.r,xpcolor.g,xpcolor.b, 0.85)
	xbar:SetMinMaxValues(0,mxp)
	xbar:SetValue(xp)
	rbar:SetMinMaxValues(0,mxp)
	rbar_ReSetValue(rxp, xp, mxp)
end

function bf_OnEvent(this, event, arg1, arg2, arg3, arg4, ...)
	mxp = UnitXPMax("player")
	xp = UnitXP("player")
	rxp = GetXPExhaustion()
	
	if event == "PLAYER_ENTERING_WORLD" then
		if UnitLevel("player") == MAX_PLAYER_LEVEL then
			bf_ShowRep()
		else
			bf_ShowXP(rxp, xp, mxp)
		end
	elseif event == "PLAYER_XP_UPDATE" and arg1 == "player" then
		xbar:SetValue(xp)
		rbar_ReSetValue(rxp, xp, mxp)
	elseif event == "PLAYER_LEVEL_UP" then
		if UnitLevel("player") == MAX_PLAYER_LEVEL then
			bf_ShowRep()
		else
			bf_ShowXP(rxp, xp, mxp)
		end
	elseif event == "MODIFIER_STATE_CHANGED" then
		if arg1 == "LCTRL" or arg1 == "RCTRL" then
			if arg2 == 1 then
				bf_ShowRep()
			elseif arg2 == 0 and UnitLevel("player") ~= MAX_PLAYER_LEVEL then
				bf_ShowXP(rxp, xp, mxp)
			end
		end
	elseif event == "UPDATE_FACTION" then
		if UnitLevel("player") == MAX_PLAYER_LEVEL then
			bf_ShowRep()
		end
	end
end

function bf_OnEnter()
	mxp = UnitXPMax("player")
	xp = UnitXP("player")
	rxp = GetXPExhaustion()
	name, standing, minrep, maxrep, value = GetWatchedFactionInfo()

	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
	GameTooltip:AddLine("jExp")
	if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
		GameTooltip:AddDoubleLine(COMBAT_XP_GAIN, xp.."|cffffd100/|r"..mxp.." |cffffd100/|r "..floor((xp/mxp)*1000)/10 .."%",NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,1,1,1)
		if rxp then
			GameTooltip:AddDoubleLine(TUTORIAL_TITLE26, rxp .." |cffffd100/|r ".. floor((rxp/mxp)*1000)/10 .."%", NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,1,1,1)
		end
		if name then
			GameTooltip:AddLine(" ")			
		end
	end
	if name then
		GameTooltip:AddDoubleLine(FACTION, name, NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,1,1,1)
		GameTooltip:AddDoubleLine(STANDING, getglobal("FACTION_STANDING_LABEL"..standing), NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,FACTION_BAR_COLORS[standing].r, FACTION_BAR_COLORS[standing].g, FACTION_BAR_COLORS[standing].b)
		GameTooltip:AddDoubleLine(REPUTATION, value-minrep .."|cffffd100/|r"..maxrep-minrep.." |cffffd100/|r "..floor((value-minrep)/(maxrep-minrep)*1000)/10 .."%", NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b,1,1,1)
	end
		
	GameTooltip:Show()
end

function bf_OnLeave()
	GameTooltip:Hide()
end

bf:EnableMouse(true)
bf:SetScript("OnEvent", bf_OnEvent)
bf:SetScript("OnEnter", bf_OnEnter)
bf:SetScript("OnLeave", bf_OnLeave)
bf:RegisterEvent("PLAYER_XP_UPDATE")
bf:RegisterEvent("PLAYER_LEVEL_UP")
bf:RegisterEvent("PLAYER_ENTERING_WORLD")
bf:RegisterEvent("UPDATE_FACTION")
bf:RegisterEvent("MODIFIER_STATE_CHANGED")
