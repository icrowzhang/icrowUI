local M = icrowMedia
local ComboColor = nPower.energy.comboColor
local playerClass = select(2, UnitClass('player'))

local RuneColor = {
    [1] = {r = 0.7, g = 0.1, b = 0.1},
    [2] = {r = 0.7, g = 0.1, b = 0.1},
    [3] = {r = 0.4, g = 0.8, b = 0.2},
    [4] = {r = 0.4, g = 0.8, b = 0.2},
    [5] = {r = 0.0, g = 0.6, b = 0.8},
    [6] = {r = 0.0, g = 0.6, b = 0.8},
}

local f = CreateFrame('Frame', nil, UIParent)
f:SetScale(1.4)
f:SetSize(18, 18)
f:SetPoint(unpack(nPower.position))
f:EnableMouse(false)

f:RegisterEvent('PLAYER_REGEN_ENABLED')
f:RegisterEvent('PLAYER_REGEN_DISABLED')
f:RegisterEvent('PLAYER_ENTERING_WORLD')

f:RegisterEvent('UNIT_COMBO_POINTS')
f:RegisterEvent('PLAYER_TARGET_CHANGED')

f:RegisterEvent('RUNE_TYPE_UPDATE')

if (nPower.energy.showComboPoints) then
    f.ComboPoints = {}

    for i = 1, 5 do
        f.ComboPoints[i] = f:CreateFontString(nil, 'ARTWORK')
        
        if (nPower.energy.comboFontOutline) then
            f.ComboPoints[i]:SetFont(nPower.energy.comboFont, nPower.energy.comboFontSize, 'THINOUTLINE')
            f.ComboPoints[i]:SetShadowOffset(0, 0)
        else
            f.ComboPoints[i]:SetFont(nPower.energy.comboFont, nPower.energy.comboFontSize)
            f.ComboPoints[i]:SetShadowOffset(1, -1)
        end
        
        f.ComboPoints[i]:SetParent(f)
        f.ComboPoints[i]:SetText(i)
        f.ComboPoints[i]:SetAlpha(0)
    end

    f.ComboPoints[1]:SetPoint('CENTER', -52, 0)
    f.ComboPoints[2]:SetPoint('CENTER', -26, 0)
    f.ComboPoints[3]:SetPoint('CENTER', 0, 0)
    f.ComboPoints[4]:SetPoint('CENTER', 26, 0)
    f.ComboPoints[5]:SetPoint('CENTER', 52, 0)
end

if (playerClass == 'DEATHKNIGHT' and nPower.rune.showRuneCooldown) then
    for i = 1, 6 do 
        RuneFrame:UnregisterAllEvents()
        _G['RuneButtonIndividual'..i]:Hide()
    end

    f.Rune = {}

    for i = 1, 6 do
        f.Rune[i] = f:CreateFontString(nil, 'ARTWORK')
        
        if (nPower.rune.runeFontOutline) then
            f.Rune[i]:SetFont(nPower.rune.runeFont, nPower.rune.runeFontSize, 'THINOUTLINE')
            f.Rune[i]:SetShadowOffset(0, 0)
        else
            f.Rune[i]:SetFont(nPower.rune.runeFont, nPower.rune.runeFontSize)
            f.Rune[i]:SetShadowOffset(1, -1)
        end

        f.Rune[i]:SetShadowOffset(0, 0)
        f.Rune[i]:SetParent(f)
    end

    f.Rune[1]:SetPoint('CENTER', -65, 0)
    f.Rune[2]:SetPoint('CENTER', -39, 0)
    f.Rune[3]:SetPoint('CENTER', 39, 0)
    f.Rune[4]:SetPoint('CENTER', 65, 0)
    f.Rune[5]:SetPoint('CENTER', -13, 0)
    f.Rune[6]:SetPoint('CENTER', 13, 0)
end

f.Power = CreateFrame('StatusBar', nil, UIParent)
f.Power:SetScale(UIParent:GetScale())
f.Power:SetSize(nPower.sizeWidth, 3)
f.Power:SetPoint('CENTER', f, 0, -23)
f.Power:SetStatusBarTexture(M.media.statusbar)
f.Power:SetAlpha(0)
M.CreateBG(f.Power)
M.CreateSD(f.Power)

f.Power.Value = f.Power:CreateFontString(nil, 'ARTWORK')

if (nPower.valueFontOutline) then
    f.Power.Value:SetFont(nPower.valueFont, nPower.valueFontSize, 'THINOUTLINE')
    f.Power.Value:SetShadowOffset(0, 0)
else
    f.Power.Value:SetFont(nPower.valueFont, nPower.valueFontSize)
    f.Power.Value:SetShadowOffset(1, -1)
end

f.Power.Value:SetPoint('CENTER', f.Power, 0, nPower.valueFontAdjustmentX)
f.Power.Value:SetVertexColor(1, 1, 1)

f.Power.Below = f.Power:CreateTexture(nil, 'BACKGROUND')
f.Power.Below:SetHeight(14)
f.Power.Below:SetWidth(14)
f.Power.Below:SetTexture('Interface\\AddOns\\nPower\\media\\textureArrowBelow')

f.Power.Above = f.Power:CreateTexture(nil, 'BACKGROUND')
f.Power.Above:SetHeight(14)
f.Power.Above:SetWidth(14)
f.Power.Above:SetTexture('Interface\\AddOns\\nPower\\media\\textureArrowAbove')

local function SetComboColor(i)
    local comboPoints = GetComboPoints('player', 'target') or 0

    if (i > comboPoints or UnitIsDeadOrGhost('target')) then
        return 1, 1, 1
    else
        return ComboColor[i].r, ComboColor[i].g, ComboColor[i].b
    end
end

local function SetComboAlpha(i)
    local comboPoints = GetComboPoints('player', 'target') or 0

    if (i == comboPoints) then
        return 1
    else
        return 0
    end
end

local function CalcRuneCooldown(self)
    local start, duration, runeReady = GetRuneCooldown(self)
    local time = floor(GetTime() - start)
    local cooldown = ceil(duration - time)
    
    if (runeReady or UnitIsDeadOrGhost('player')) then
        return '#'
    elseif (not UnitIsDeadOrGhost('player') and cooldown) then
        return cooldown
    end
end

local function SetRuneColor(i)
    if (f.Rune[i].type == 4) then
        return 1, 0, 1
    else
        return RuneColor[i].r, RuneColor[i].g, RuneColor[i].b
    end
end

local function UpdateBarVisibility()
    local _, powerType = UnitPowerType('player')
    
    if ((not nPower.energy.show and powerType == 'ENERGY') or (not nPower.focus.show and powerType == 'FOCUS') or (not nPower.rage.show and powerType == 'RAGE') or (not nPower.mana.show and powerType == 'MANA') or (not nPower.rune.show and powerType == 'RUNEPOWER') or UnitIsDeadOrGhost('player') or UnitHasVehicleUI('player')) then
        f.Power:SetAlpha(0)
    elseif (InCombatLockdown()) then
        f.Power:SetAlpha(nPower.activeAlpha)
    elseif (not InCombatLockdown() and UnitPower('player') > 0) then
        f.Power:SetAlpha(nPower.inactiveAlpha)
    else
        f.Power:SetAlpha(nPower.emptyAlpha)
    end
end

local function UpdateArrow()
    if (UnitPower('player') == 0) then
        f.Power.Below:SetAlpha(0.3)
        f.Power.Above:SetAlpha(0.3)
    else
        f.Power.Below:SetAlpha(1)
        f.Power.Above:SetAlpha(1)
    end
    
    local newPosition = UnitPower('player') / UnitPowerMax('player') * f.Power:GetWidth() - 7
    f.Power.Below:SetPoint('LEFT', f.Power, 'LEFT', newPosition, -8)
    f.Power.Above:SetPoint('LEFT', f.Power, 'LEFT', newPosition, 8)
end

local function FormatValue(self)
    if (self >= 10000) then
		return ('%.1fk'):format(self / 1e3)
    else
        return self
    end
end

local function UpdateBarValue()
    f.Power:SetMinMaxValues(0, UnitPowerMax('player', f))
    f.Power:SetValue(UnitPower('player'))
    
    local curValue = UnitPower('player')
	if (nPower.valuePercent and select(2, UnitPowerType('player')) == 'MANA') then
		local percent = curValue / UnitPowerMax('player') * 100
		f.Power.Value:SetText(UnitPower('player') >= 0 and ('%.1f%%'):format(percent) or '' )
    elseif (nPower.valueAbbrev) then
        f.Power.Value:SetText(UnitPower('player') >= 0 and FormatValue(curValue) or '')
    else
        f.Power.Value:SetText(UnitPower('player') >= 0 and curValue or '')
    end
end

local function UpdateBarColor()
    local _, powerType, altR, altG, altB = UnitPowerType('player')
    local unitPower = PowerBarColor[powerType]
    
    if (unitPower) then
        f.Power:SetStatusBarColor(unitPower.r, unitPower.g, unitPower.b)
    else
        f.Power:SetStatusBarColor(altR, altG, altB)
    end
end

local function UpdateBar()
    UpdateBarColor()
    UpdateBarValue()
    UpdateArrow()
end

f:SetScript('OnEvent', function(self, event, arg1)
    if (f.ComboPoints) then
        if (event == 'UNIT_COMBO_POINTS' or event == 'PLAYER_TARGET_CHANGED') then
            for i = 1, 5 do
                f.ComboPoints[i]:SetTextColor(SetComboColor(i))
                f.ComboPoints[i]:SetAlpha(SetComboAlpha(i))
            end
        end
    end
    
    if (event == 'RUNE_TYPE_UPDATE') and nPower.rune.showRuneCooldown then
        f.Rune[arg1].type = GetRuneType(arg1)
    end
    
    if (event == 'PLAYER_ENTERING_WORLD') then
        if (InCombatLockdown()) then
            f:SetAlpha(1)
        else
            f:SetAlpha(nPower.inactiveAlpha)
        end
    end

    if (event == 'PLAYER_REGEN_DISABLED') then
        f:SetAlpha(1)
    end
    
    if (event == 'PLAYER_REGEN_ENABLED') then
        f:SetAlpha(nPower.inactiveAlpha)
    end
end)

local updateTimer = 0
f:SetScript('OnUpdate', function(self, elapsed)
    updateTimer = updateTimer + elapsed
	
    if (updateTimer > 0.1) then
        if (f.Rune) then
            for i = 1, 6 do
                if (UnitHasVehicleUI('player')) then
                    if (f.Rune[i]:IsShown()) then
                        f.Rune[i]:Hide()
                    end
                else
                    if (not f.Rune[i]:IsShown()) then
                        f.Rune[i]:Show()
                    end
                end
                
                f.Rune[i]:SetText(CalcRuneCooldown(i))
                f.Rune[i]:SetTextColor(SetRuneColor(i))
            end
        end
        
        UpdateBar()
        UpdateBarVisibility()
        
        updateTimer   = 0
    end
end)