-- based on BetterPowerBarAlt by nebula @ wowinterface.com
local points = {"BOTTOMLEFT", UIParent, "BOTTOM", 255, 37}
local scale = 0.6
local PlayerPowerBarAlt = PlayerPowerBarAlt

local overlay = CreateFrame("Frame", nil, UIParent)
overlay:SetSize(160, 80)
overlay:SetPoint(unpack(points))
overlay:RegisterEvent("PLAYER_ENTERING_WORLD")
overlay:SetScript("OnEvent", function(self)
	PlayerPowerBarAlt:SetParent(self)
	PlayerPowerBarAlt.SetParent = function() end ---noooo chinchilla, noooo
	PlayerPowerBarAlt:SetScale(scale)
	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:SetPoint("BOTTOMLEFT", self)
	PlayerPowerBarAlt.statusFrame.text:SetPoint("BOTTOM", PlayerPowerBarAlt, "TOP", 0, -5)
	PlayerPowerBarAlt.statusFrame.text:SetFont(NumberFontNormal:GetFont(), 20, "THINOUTLINE")
end)

PlayerPowerBarAlt:HookScript("OnHide", function(self)
	--the last power value isn't cleared so it'll be shown if it isn't used again but the frame is
	PlayerPowerBarAlt.statusFrame.text:SetText("")
end)