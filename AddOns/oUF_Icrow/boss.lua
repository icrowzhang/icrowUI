-- Based on boss frames from oUF_Lure by lurelure

local M = icrowMedia
local addon, ns = ...
local oUF = oUF or ns.oUF

-- config
local bartexture = M.media.statusbar
local font = M.media.font
local fontsize = 12
local fontflag = "THINOUTLINE"
local BossNameLength = 30
local BossFrameWidth = 140
local BossFrameHeight = 5
local BossSpacingVertical = 20

---------->> HideBossFrames by Arnialys
function hideBossFrames()
	for i = 1, 4 do
		local frame = _G["Boss"..i.."TargetFrame"]
		frame:UnregisterAllEvents()
		frame:Hide()
		frame.Show = function () end
	end
end

hideBossFrames()
---------->> HideBossFrames end

oUF.Tags.Events["bossname"] = "UNIT_HEALTH"
oUF.Tags.Methods['bossname'] = function(u) 
	return UnitName(u):sub(1, BossNameLength) 
end

local function LayoutBoss(self, unit)
	self.colors = colors
	self:RegisterForClicks("AnyDown")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	M.CreateBG(self)
	M.CreateSD(self)

	self.Health = CreateFrame('StatusBar', nil, self)
	self.Health:SetAllPoints(self)
	self.Health:SetStatusBarTexture(bartexture)
	self.Health:SetStatusBarColor(50, 0, 0)
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.Smooth = true
	self.Health:SetFrameLevel(5)

	local name = self.Health:CreateFontString(nil, "OVERLAY")
	name:SetFont(font, fontsize, fontflag)
	name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 2, 0)
	name:SetJustifyH("LEFT")
	self:Tag(name, "[bossname]")
	
	local percent = self.Health:CreateFontString(nil, "OVERLAY")
	percent:SetFont(font, fontsize, fontflag)
	percent:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -2, 0)
	percent:SetJustifyH("RIGHT")
	self:Tag(percent, "[perhp]%")
	
	self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetPoint("RIGHT", name, "LEFT", -2, 0)
	self.RaidIcon:SetHeight(12)
	self.RaidIcon:SetWidth(12)
end

function oUF_Icrow_ApplyBossOptions()
	for i = 1, MAX_BOSS_FRAMES do
		local boss = _G["oUF_Boss"..i]
		boss:SetWidth(BossFrameWidth)
		boss:SetHeight(BossFrameHeight)
	end
end

function oUF_Icrow_SpawnBoss(self)
	
	oUF:RegisterStyle("IcrowBoss", LayoutBoss)
	oUF:SetActiveStyle("IcrowBoss")
	
	local boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		unit = oUF:Spawn("boss"..i, "oUF_Boss"..i)
		if i==1 then
			unit:SetPoint("TOP", Minimap, "BOTTOM", 0, -40)
		else
			unit:SetPoint("TOPRIGHT", boss[i-1], "BOTTOMRIGHT", 0, -BossSpacingVertical)
		end
		boss[i] = unit
	end
	
	oUF_Icrow_ApplyBossOptions()
end