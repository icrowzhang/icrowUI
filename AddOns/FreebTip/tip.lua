local _, ns = ...
local M = icrowMedia

local cfg = {
    font = M.media.font,
    fontsize = 14,
    outline = "OUTLINE",
    tex = "Interface\\TARGETINGFRAME\\UI-StatusBar",

    scale = 1,
    point = { "BOTTOMRIGHT", "BOTTOMRIGHT", -14, 34 },
    cursor = false,    --true鼠标跟随,false右下角

    hideTitles = true,
    hideRealm = false,
	
    gcolor = { r=1, g=1, b=1 }, -- guild

    you = "<你>",
    boss = "首领",
    colorborderClass = false,           --职业着色边框
    combathide = false,                 --战斗隐藏
}

local classification = {
    elite = "+",
    rare = " 稀有",
    rareelite = " 稀有+",
}

local find = string.find
local format = string.format
local hex = function(color)
    return format('|cff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
end

local function unitColor(unit)
    local color = { r=1, g=1, b=1 }
    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        if class then color = RAID_CLASS_COLORS[class] end
        return color
    else
        local reaction = UnitReaction(unit, "player")
        if reaction then
            color = FACTION_BAR_COLORS[reaction]
            return color
        end
    end
    return color
end

local function getTarget(unit)
    if UnitIsUnit(unit, "player") then
        return ("|cffff0000%s|r"):format(cfg.you)
    else
        return hex(unitColor(unit))..UnitName(unit).."|r"
    end
end

local function setBakdrop(frame)
	local name = frame:GetName()
	if string.find(name, "DropDownList") then
		local bg = M.CreateBG(frame)
		bg:ClearAllPoints()
		bg:SetPoint("TOPLEFT", frame)
		bg:SetPoint("BOTTOMRIGHT", frame)
		M.CreateSD(frame, -1)
	else
		M.CreateBG(frame)
		M.CreateSD(frame)
	end
    frame:SetScale(cfg.scale)

    frame.freebBak = true
end

local function style(frame)
    if not frame.freebBak then
        setBakdrop(frame)
    end

    frame:SetBackdrop(nil)

    if cfg.colorborderClass then
        local _, unit = GameTooltip:GetUnit()
        if UnitIsPlayer(unit) then
            frame:SetBackdropBorderColor(GameTooltip_UnitColor(unit))
        end
    end

    if frame.NumLines then
        for index=1, frame:NumLines()+1 do
            if index == 1 then
                _G[frame:GetName()..'TextLeft'..index]:SetFont(cfg.font, cfg.fontsize+2, cfg.outline)
            else
                _G[frame:GetName()..'TextLeft'..index]:SetFont(cfg.font, cfg.fontsize, cfg.outline)
            end
            _G[frame:GetName()..'TextRight'..index]:SetFont(cfg.font, cfg.fontsize, cfg.outline)
        end
    end
end

GameTooltipStatusBar:SetStatusBarTexture(cfg.tex)
M.CreateBG(GameTooltipStatusBar)
M.CreateSD(GameTooltipStatusBar)

local numberize = function(val)
    if (val >= 1e6) then
        return ("%.1fm"):format(val / 1e6)
    elseif (val >= 1e3) then
        return ("%.1fk"):format(val / 1e3)
    else
        return ("%d"):format(val)
    end
end

local tooltips = {
    GameTooltip,
    ItemRefTooltip,
    ShoppingTooltip1,
    ShoppingTooltip2, 
    ShoppingTooltip3,
    WorldMapTooltip,
	FriendsTooltip,
    DropDownList1MenuBackdrop, 
    DropDownList2MenuBackdrop,
}

if IsAddOnLoaded("!UIDropDownMenuFix") then
	tinsert(tooltips, XDropDownList1MenuBackdrop)
	tinsert(tooltips, XDropDownList2MenuBackdrop)
end

for i, frame in ipairs(tooltips) do
    frame:SetScript("OnShow", function(frame) style(frame) end)
end

local itemrefScripts = {
    "OnTooltipSetItem",
    "OnTooltipSetAchievement",
    "OnTooltipSetQuest",
    "OnTooltipSetSpell",
}

for i, script in ipairs(itemrefScripts) do
    ItemRefTooltip:HookScript(script, function(self)
        style(self)
    end)
end

if IsAddOnLoaded("ManyItemTooltips") then
    MIT:AddHook("FreebTip", "OnShow", function(frame) style(frame) end)
end

local f = CreateFrame"Frame"
f:SetScript("OnEvent", function(self, event, ...) if ns[event] then return ns[event](ns, event, ...) end end)
function ns:RegisterEvent(...) for i=1,select("#", ...) do f:RegisterEvent((select(i, ...))) end end
function ns:UnregisterEvent(...) for i=1,select("#", ...) do f:UnregisterEvent((select(i, ...))) end end

ns:RegisterEvent"PLAYER_ENTERING_WORLD"
function ns:PLAYER_LOGIN()
    for i, frame in ipairs(tooltips) do
        setBakdrop(frame)
    end

    ns:UnregisterEvent"PLAYER_ENTERING_WORLD"
end

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    local name, unit = self:GetUnit()

    if unit then
        if cfg.combathide and InCombatLockdown() then
            return self:Hide()
        end

        local color = unitColor(unit)
        local ricon = GetRaidTargetIndex(unit)

        if ricon then
            local text = GameTooltipTextLeft1:GetText()
            GameTooltipTextLeft1:SetText(("%s %s"):format(ICON_LIST[ricon].."18|t", text))
        end

        if UnitIsPlayer(unit) then
            self:AppendText((" |cff00cc00%s|r"):format(UnitIsAFK(unit) and CHAT_FLAG_AFK or 
            UnitIsDND(unit) and CHAT_FLAG_DND or 
            not UnitIsConnected(unit) and "<DC>" or ""))

            if cfg.hideTitles then
                local title = UnitPVPName(unit)
                if title then
                    local text = GameTooltipTextLeft1:GetText()
                    title = title:gsub(name, "")
                    text = text:gsub(title, "")
                    if text then GameTooltipTextLeft1:SetText(text) end
                end
            end

            if cfg.hideRealm then
                local _, realm = UnitName(unit)
                if realm then
                    local text = GameTooltipTextLeft1:GetText()
                    text = text:gsub("- "..realm, "")
                    if text then GameTooltipTextLeft1:SetText(text) end
                end
            end

            local unitGuild, tmp,tmp2 = GetGuildInfo(unit)
            local text = GameTooltipTextLeft2:GetText()
            if tmp then
               tmp2=tmp2+1
               GameTooltipTextLeft2:SetText("<"..text..">")
            end
        end


        local alive = not UnitIsDeadOrGhost(unit)
        local level = UnitLevel(unit)

        if level then
            local unitClass = UnitIsPlayer(unit) and hex(color)..UnitClass(unit).."|r" or ""
            local creature = not UnitIsPlayer(unit) and UnitCreatureType(unit) or ""
            local diff = GetQuestDifficultyColor(level)

            if level == -1 then
                level = "|cffff0000"..cfg.boss
            end

            local classify = UnitClassification(unit)
            local textLevel = ("%s%s%s|r"):format(hex(diff), tostring(level), classification[classify] or "")

            for i=2, self:NumLines() do
                local tiptext = _G["GameTooltipTextLeft"..i]
                if tiptext:GetText():find(LEVEL) then
                    if alive then
                        tiptext:SetText(("%s %s%s %s"):format(textLevel, creature, UnitRace(unit) or "", unitClass):trim())
                    else
                        tiptext:SetText(("%s %s"):format(textLevel, "|cffCCCCCC"..DEAD.."|r"):trim())
                    end
                end

                if tiptext:GetText():find(PVP) then
                    tiptext:SetText(nil)
                end
            end
        end

        if not alive then
            GameTooltipStatusBar:Hide()
        end

        if UnitExists(unit.."target") then
            local tartext = ("%s: %s"):format(TARGET, getTarget(unit.."target"))
            self:AddLine(tartext)
        end

        GameTooltipStatusBar:SetStatusBarColor(0, .9, 0)
    else
        for i=2, self:NumLines() do
            local tiptext = _G["GameTooltipTextLeft"..i]

            if tiptext:GetText():find(PVP) then
                tiptext:SetText(nil)
            end
        end

        GameTooltipStatusBar:SetStatusBarColor(0, .9, 0)
    end

    if GameTooltipStatusBar:IsShown() then
        GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetHeight(5)
        GameTooltipStatusBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
        GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 4)
    end
end)

GameTooltipStatusBar:SetScript("OnValueChanged", function(self, value)
    if not value then
        return
    end
    local min, max = self:GetMinMaxValues()
    if (value < min) or (value > max) then
        return
    end
    local _, unit = GameTooltip:GetUnit()
    if unit then
        min, max = UnitHealth(unit), UnitHealthMax(unit)
        if not self.text then
            self.text = self:CreateFontString(nil, "OVERLAY")
            self.text:SetPoint("BOTTOM", GameTooltipStatusBar, 0, -2)
            self.text:SetFont("Fonts\\Semplice.ttf", 8, "MONOCHROMEOUTLINE")
        end
        self.text:Show()
        local hp = numberize(min).." / "..numberize(max)
        self.text:SetText(hp)
    end
end)

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
    local frame = GetMouseFocus()
    if cfg.cursor then
        tooltip:SetOwner(parent, "ANCHOR_CURSOR_RIGHT")
    else
        tooltip:SetOwner(parent, "ANCHOR_NONE")	
        tooltip:SetPoint(cfg.point[1], UIParent, cfg.point[2], cfg.point[3], cfg.point[4])
    end
    tooltip.default = 1
end)

hooksecurefunc("PartyMemberBuffTooltip_Update", function(self)
	for i = 1, MAX_PARTY_TOOLTIP_BUFFS do
		local bu = _G["PartyMemberBuffTooltipBuff"..i]
		local icon = _G["PartyMemberBuffTooltipBuff"..i.."Icon"]
		if icon then
			icon:SetTexCoord(.08, .92, .08, .92)
			if bu.bg then return end
			local bg = CreateFrame("Frame", nil, bu)
			bg:SetBackdrop({
				bgFile = M.media.solid,
				edgeFile = M.media.solid,
				edgeSize = 1,
			})
			bg:SetPoint("TOPLEFT", icon, -1, 1)
			bg:SetPoint("BOTTOMRIGHT", icon, 1, -1)
			bg:SetBackdropColor(0, 0, 0, 0)
			bg:SetBackdropBorderColor(0, 0, 0, 1)
			bu.bg = bg
		end
	end
end)