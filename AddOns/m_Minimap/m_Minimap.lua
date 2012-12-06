local M = icrowMedia

-- Config
local Scale = 1				-- Minimap scale
local MapPosition = {"TOPRIGHT", "UIParent", "TOPRIGHT", -15, -15}
local zoneTextYOffset = -3		-- Zone text position

-- Localization
local locale = (GetLocale() == "zhCN" or GetLocale() == "zhTW") and GetLocale() or "default"

local L = {
	["zhCN"] = {
		"角色信息",
		"法术书和技能",
		"专精与天赋",
		"成就",
		"任务日志",
		"社交",
		"公会",
		"PvP",
		"地下城查找器",
		"坐骑与宠物",
		"客服支持",
		"日历",
		"地下城手册",
	},
	["zhTW"] = {
		"角色信息",
		"法術書和技能",
		"專精與天賦",
		"成就",
		"任務日誌",
		"社交",
		"公會",
		"PvP",
		"地城查找器",
		"坐騎與寵物",
		"客服支持",
		"日曆",
		"地城導覽",
	},
	["default"] = {
		"Character",
		"Spell book",
		"Talents",
		"Achievement",
		"Quest log",
		"Friends",
		"Guild",
		"PvP",
		"LFD",
		"Mount & Pet",
		"Help",
		"Calendar",
		"Dungeon Journal",
	},
}

-- Shape, location and scale
function GetMinimapShape() return "SQUARE" end
Minimap:ClearAllPoints()
Minimap:SetPoint(MapPosition[1], MapPosition[2], MapPosition[3], MapPosition[4] / Scale, MapPosition[5] / Scale)
MinimapCluster:SetScale(Scale)
Minimap:SetFrameLevel(10)

-- Mask texture hint => addon will work with Carbonite
local hint = CreateFrame("Frame")
local total = 0
local SetTextureTrick = function(self, elapsed)
    total = total + elapsed
    if(total > 2) then
        Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
        hint:SetScript("OnUpdate", nil)
    end
end

hint:RegisterEvent("PLAYER_LOGIN")
hint:SetScript("OnEvent", function()
    hint:SetScript("OnUpdate", SetTextureTrick)
end)

-- Background
M.CreateBG(Minimap)
M.CreateSD(Minimap)

-- Mousewheel zoom
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(_, zoom)
    if zoom > 0 then
        Minimap_ZoomIn()
    else
        Minimap_ZoomOut()
    end
end)

-- Hiding ugly things
local dummy = function() end
local _G = _G

local frames = {
    "GameTimeFrame",
    "MinimapBorderTop",
    "MinimapNorthTag",
    "MinimapBorder",
    "MinimapZoneTextButton",
    "MinimapZoomOut",
    "MinimapZoomIn",
    "MiniMapVoiceChatFrame",
    "MiniMapWorldMapButton",
    "MiniMapMailBorder",
}

for i in pairs(frames) do
	_G[frames[i]]:Hide()
	_G[frames[i]].Show = dummy
end
MinimapCluster:EnableMouse(false)

-- Tracking
MiniMapTrackingBackground:SetAlpha(0)
MiniMapTrackingButton:SetAlpha(0)
MiniMapTrackingIconOverlay:SetAlpha(0)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("BOTTOMLEFT", Minimap, -5, -5)
MiniMapTracking:SetAlpha(0)

-- Queue Status icon
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButtonBorder:SetAlpha(0)
QueueStatusMinimapButton:SetPoint("TOPLEFT", Minimap, -5, 5)
QueueStatusMinimapButton:SetSize(32,32)
QueueStatusMinimapButton:SetFrameStrata("MEDIUM")

-- Instance Difficulty flag
MiniMapInstanceDifficulty:Hide() 
MiniMapInstanceDifficulty.Show = function() return end

-- Guild Instance Difficulty flag
GuildInstanceDifficulty:Hide() 
GuildInstanceDifficulty.Show = function() return end

local rd = CreateFrame("Frame", nil, Minimap)
rd:SetSize(24, 8)
rd:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -2, -4)
rd:RegisterEvent("PLAYER_ENTERING_WORLD")
rd:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
rd:RegisterEvent("GUILD_PARTY_STATE_UPDATED")

local rdt = rd:CreateFontString(nil, "OVERLAY")
rdt:SetFont("Fonts\\Semplice.ttf", 8, "MONOCHROMEOUTLINE")
rdt:SetJustifyH("RIGHT")
rdt:SetPoint("TOPRIGHT", -1, -1)

rd:SetScript("OnEvent", function()
	local difficulty = GetInstanceDifficulty() - 1
	local inGroup = InGuildParty()
	
	if difficulty == DIFFICULTY_DUNGEON_NORMAL then
		rdt:SetText("5")
	elseif difficulty == DIFFICULTY_DUNGEON_HEROIC then
		rdt:SetText("5H")
	elseif difficulty == DIFFICULTY_RAID10_NORMAL then
		rdt:SetText("10")
	elseif difficulty == DIFFICULTY_RAID25_NORMAL then
		rdt:SetText("25")
	elseif difficulty == DIFFICULTY_RAID10_HEROIC then
		rdt:SetText("10H")
	elseif difficulty == DIFFICULTY_RAID25_HEROIC then
		rdt:SetText("25H")
	elseif difficulty == DIFFICULTY_RAID_LFR then
		rdt:SetText("LFR")
	elseif difficulty == DIFFICULTY_DUNGEON_CHALLENGE then
		rdt:SetText("5C")
	elseif difficulty == DIFFICULTY_RAID40 then
		rdt:SetText("40")
	else
		rdt:SetText("")
	end
	
	if inGroup then
		rdt:SetTextColor(0, .76, 1, 1)
	else
		rdt:SetTextColor(1, 1, 1, 1)
	end
	
end)

-- Mail icon
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -6)
MiniMapMailIcon:SetTexture("Interface\\AddOns\\m_Minimap\\mail")

-- Invites Icon
GameTimeCalendarInvitesTexture:ClearAllPoints()
GameTimeCalendarInvitesTexture:SetParent("Minimap")
GameTimeCalendarInvitesTexture:SetPoint("TOPRIGHT")

if FeedbackUIButton then
FeedbackUIButton:ClearAllPoints()
FeedbackUIButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 6, -6)
FeedbackUIButton:SetScale(0.8)
end

if StreamingIcon then
StreamingIcon:ClearAllPoints()
StreamingIcon:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 8, 8)
StreamingIcon:SetScale(0.8)
end

-- Creating right click menu
local menuFrame = CreateFrame("Frame", "m_MinimapRightClickMenu", UIParent, "XUIDropDownMenuTemplate")
local menuList = {
    {text = L[locale][1],
	notCheckable = true,
    func = function() ToggleCharacter("PaperDollFrame") end},
    {text = L[locale][2],
	notCheckable = true,
    func = function() ToggleFrame(SpellBookFrame) end},
    {text = L[locale][3],
	notCheckable = true,
    func = function() if not PlayerTalentFrame then LoadAddOn("Blizzard_TalentUI") end ToggleFrame(PlayerTalentFrame) end},
    {text = L[locale][4],
	notCheckable = true,
    func = function() ToggleAchievementFrame() end},
    {text = L[locale][5],
	notCheckable = true,
    func = function() ToggleFrame(QuestLogFrame) end},
    {text = L[locale][6],
	notCheckable = true,
    func = function() ToggleFriendsFrame(1) end},
    {text = L[locale][7],
	notCheckable = true,
    func = function() ToggleGuildFrame() end},
    {text = L[locale][8],
	notCheckable = true,
    func = function() ToggleFrame(PVPFrame) end},
    {text = L[locale][9],
	notCheckable = true,
    func = function() PVEFrame_ToggleFrame('GroupFinderFrame', LFDParentFrame) end},
    {text = L[locale][10],
	notCheckable = true,
    func = function() TogglePetJournal() end},
    {text = L[locale][11],
	notCheckable = true,
    func = function() ToggleHelpFrame() end},
    {text = L[locale][12],
	notCheckable = true,
    func = function()
    if(not CalendarFrame) then LoadAddOn("Blizzard_Calendar") end
        Calendar_Toggle()
    end},
    {text = L[locale][13],
	notCheckable = true,
	func = function() ToggleEncounterJournal() end},
}

-- Click func
Minimap:SetScript("OnMouseUp", function(_, btn)
    if(btn=="MiddleButton") then
        ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "cursor", 0, 0)
    elseif(btn=="RightButton") then
        XEasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 1)
	else
		local x, y = GetCursorPosition()
		x = x / Minimap:GetEffectiveScale()
		y = y / Minimap:GetEffectiveScale()
		local cx, cy = Minimap:GetCenter()
		x = x - cx
		y = y - cy
		if ( sqrt(x * x + y * y) < (Minimap:GetWidth() / 2) ) then
			Minimap:PingLocation(x, y)
		end
		Minimap_SetPing(x, y, 1)
	end
end) 

-- Clock
if not IsAddOnLoaded("Blizzard_TimeManager") then
	LoadAddOn("Blizzard_TimeManager")
end

local clockFrame, clockTime = TimeManagerClockButton:GetRegions()
clockFrame:Hide()
clockTime:SetFont("Fonts\\ROADWAY.ttf", 15, "outline")
clockTime:SetTextColor(1,1,1)
clockTime:SetShadowColor(0,0,0,0)
clockTime:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 5)
TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -3)
TimeManagerClockButton:SetScript("OnClick", function(_,btn)
 	if btn == "LeftButton" then
		TimeManager_Toggle()
	end 
	if btn == "RightButton" then
		if not CalendarFrame then
			LoadAddOn("Blizzard_Calendar")
		end
		Calendar_Toggle()
	end
end)

local function ClockEvent(self, event)
	local pendingCalendarInvites = CalendarGetNumPendingInvites()
	if pendingCalendarInvites > 0 then
		clockTime:SetTextColor(1, 0, 0, 1)
	else
		clockTime:SetTextColor(1, 1, 1, 1)
	end
end

local mclock = CreateFrame("Frame", nil, UIParent)
mclock:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
mclock:RegisterEvent("PLAYER_ENTERING_WORLD")
mclock:RegisterEvent("UPDATE_INSTANCE_INFO")
mclock:SetScript("OnEvent", ClockEvent)

-- Zone text
local zoneTextFrame = CreateFrame("Frame", nil, UIParent)
zoneTextFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, zoneTextYOffset)
zoneTextFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, zoneTextYOffset)
zoneTextFrame:SetHeight(19)
zoneTextFrame:SetAlpha(0)
MinimapZoneText:SetParent(zoneTextFrame)
MinimapZoneText:ClearAllPoints()
MinimapZoneText:SetPoint("LEFT", 2, 1)
MinimapZoneText:SetPoint("RIGHT", -2, 1)
MinimapZoneText:SetFont("Fonts\\ARHei.ttf", 14, "THINOUTLINE")
MinimapZoneText:SetShadowColor(0,0,0,0)
Minimap:SetScript("OnEnter", function(self)
	UIFrameFadeIn(zoneTextFrame, 0.3, 0, 1)
end)
Minimap:SetScript("OnLeave", function(self)
	UIFrameFadeOut(zoneTextFrame, 0.3, 1, 0)
end)