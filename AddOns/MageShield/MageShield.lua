if select(2, UnitClass("player")) ~= "MAGE" then return end

local M = icrowMedia

-- config
local cfg = {
	["iconsize"] = 35,
	["spacing"] = 4,
	["font"] = "Fonts\\Myriad.ttf",
	["fontsize"] = 14,
	["fontflag"] = "THINOUTLINE",
}

local watchlist = {
	[11426] = "MageShield_Ice_Barrier",
	[1463] = "MageShield_Incanters_Ward",
}

local GetSpellInfo = GetSpellInfo
local UnitBuff = UnitBuff
local GetTime = GetTime

MageShieldDB = MageShieldDB or {}

local function SetFrame(parent, name, spellId)
	local f = CreateFrame("Frame", name, parent)
	local size = cfg.iconsize
	f:SetSize(size, size)
	M.CreateBG(f)
	M.CreateSD(f)
	f.id = spellId
	f.icon = f:CreateTexture(nil, "ARTWORK")
	f.icon:SetAllPoints(f)
	f.icon:SetTexture(select(3, GetSpellInfo(f.id)))
	f.icon:SetTexCoord(.08, .92, .08, .92)
	f.text = f:CreateFontString(nil, "OVERLAY")
	f.text:SetFont(cfg.font, cfg.fontsize, cfg.fontflag)
	f.text:SetPoint("TOP", f, "BOTTOM")
	f.cooldown = CreateFrame("Cooldown", nil, f) 
	f.cooldown:SetAllPoints() 
	f.cooldown:SetReverse(true)
	f:Hide()
	return f
end

local function UpdateAbsorb(self, elapsed)
	self.elapsed = (self.elapsed or 0) - elapsed
	if self.elapsed < 0 then
		self.absorb = select(15, UnitBuff("player", GetSpellInfo(self.id))) or 0
		self.text:SetText(self.absorb)
		self.elapsed = 0.3
	end
end

local function UpdateAura(self)
	local duration, expire = select(6, UnitBuff("player", GetSpellInfo(self.id)))
	if duration and duration > 0 and expire then
		self:Show()
		self.cooldown:SetCooldown(expire - duration, duration)
		self:SetScript("OnUpdate", UpdateAbsorb)
	else
		self:Hide()
		self:SetScript("OnUpdate", nil)
		self.elapsed = nil
	end
end

-- main
local Anchor = CreateFrame("Frame", "MageShieldAnchor", UIParent)
Anchor:SetSize(cfg.iconsize, cfg.iconsize)
Anchor:SetPoint("CENTER", UIParent, "BOTTOMLEFT", MageShieldDB.x or 703, MageShieldDB.y or 280)
M.CreateBG(Anchor)
M.CreateSD(Anchor)
Anchor.text = Anchor:CreateFontString(nil, "OVERLAY")
Anchor.text:SetFont(cfg.font, cfg.fontsize, cfg.fontflag)
Anchor.text:SetAllPoints(Anchor)
Anchor.text:SetText("MageShield")
Anchor:SetMovable(true)
Anchor:EnableMouse(true)
Anchor:RegisterForDrag("LeftButton")
Anchor:Hide()
Anchor:SetScript("OnDragStart", function(self) self:StartMoving() end)
Anchor:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	MageShieldDB.x, MageShieldDB.y = self:GetCenter()
end)

local MageShield = CreateFrame("Frame", "MageShield", UIParent)
MageShield:SetPoint("BOTTOMLEFT", Anchor)
MageShield:SetSize(cfg.iconsize, cfg.iconsize)
MageShield:RegisterEvent("PLAYER_ENTERING_WORLD")
MageShield:Hide()

MageShield:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("UNIT_AURA")
		local i = 1
		for spellId, name in pairs(watchlist) do
			local frame = SetFrame(self, name, spellId)
			frame:SetPoint("BOTTOMLEFT", (i-1)*(cfg.iconsize+cfg.spacing), 0)
			UpdateAura(frame)
			i = i + 1
		end
		self:Show()
	else
		local unitId = ...
		if unitId == "player" then
			for spellId, name in pairs(watchlist) do
				local frame = _G[name]
				UpdateAura(frame)
			end
		end
	end
end)

SlashCmdList["MageShield"] = function() if Anchor:IsVisible() then Anchor:Hide() else Anchor:Show() end end
SLASH_MageShield1 = "/mageshield"