-- based on Sora's AuraWatch by Neavo @ ngacn.cc
local M = icrowMedia
local addon, ns = ...

local cfg = CreateFrame("Frame")
local class = select(2, UnitClass("player")) 
local CLASS_COLORS = RAID_CLASS_COLORS[class]

-- BuildICON
function cfg.BuildICON(IconSize)
	local Frame = CreateFrame("Frame", nil, UIParent)
	Frame:SetSize(IconSize, IconSize)
	
	Frame.Icon = Frame:CreateTexture(nil, "ARTWORK") 
	Frame.Icon:SetAllPoints()
	Frame.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	
	M.CreateBG(Frame)
	M.CreateSD(Frame)
	
	Frame.Count = Frame:CreateFontString(nil, "OVERLAY") 
	Frame.Count:SetFont(M.media.font, math.floor((IconSize + 1) / 3), "THINOUTLINE") 
	Frame.Count:SetPoint("BOTTOMRIGHT", 3, -1)
	
	Frame.Cooldown = CreateFrame("Cooldown", nil, Frame) 
	Frame.Cooldown:SetAllPoints() 
	Frame.Cooldown:SetReverse(true)
	
	Frame:Hide()
	return Frame
end

ns.Config = cfg