-- based on oUF_Lure by lurelure @ wowinterface.com

local addon, ns = ...
local oUF = oUF or ns.oUF

local function LayoutPlayer(self, unit)
	CreateCastBar(self, "player")
end

local function LayoutTarget(self, unit)
	CreateCastBar(self, "target")
end

local function LayoutFocus(self, unit)
	CreateCastBar(self, "focus")
end

function oUF_Icrow_SpawnCore(self)
	oUF:RegisterStyle("IcrowPlayer", LayoutPlayer)
	oUF:SetActiveStyle("IcrowPlayer")
	oUF:Spawn("player", "oUF_player")
	
	oUF:RegisterStyle("IcrowTarget", LayoutTarget)
	oUF:SetActiveStyle("IcrowTarget")
	oUF:Spawn("target", "oUF_target")

	oUF:RegisterStyle("IcrowFocus", LayoutFocus)
	oUF:SetActiveStyle("IcrowFocus")
	oUF:Spawn("focus", "oUF_focus")
end

local addon = CreateFrame("Frame")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
function addon:OnEvent(event)
	if event == "PLAYER_ENTERING_WORLD" then
		addon:UnregisterEvent("PLAYER_ENTERING_WORLD")
		oUF_Icrow_SpawnCore()
		oUF_Icrow_SpawnBoss()
	end
end
addon:SetScript("OnEvent", addon.OnEvent)