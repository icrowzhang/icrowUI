local M = icrowMedia
local addon, ns = ...
local cfg = ns.cfg

local f = CreateFrame"Frame"
f:RegisterEvent("VARIABLES_LOADED")
f:SetScript("OnEvent", function()
	if cfg.disable_timers then cfg.disable_timers = 0 else cfg.disable_timers = 1 end
	SetCVar("buffDurations",cfg.disable_timers) -- enabling buff durations
end)

ConsolidatedBuffs:ClearAllPoints()
ConsolidatedBuffs:SetPoint(unpack(cfg.BUFFpos))
ConsolidatedBuffs:SetSize(cfg.iconsize, cfg.iconsize)
ConsolidatedBuffs.SetPoint = nil
ConsolidatedBuffsIcon:SetTexture("Interface\\Icons\\Spell_ChargePositive")
ConsolidatedBuffsIcon:SetTexCoord(0.03,0.97,0.03,0.97)
ConsolidatedBuffsIcon:SetAllPoints(ConsolidatedBuffs)
ConsolidatedBuffsCount:SetPoint("BOTTOMRIGHT", 1, -1)
ConsolidatedBuffsCount:SetFont(cfg.font, cfg.countfontsize, "OUTLINE")
M.CreateBG(ConsolidatedBuffs)
M.CreateSD(ConsolidatedBuffs)

for i = 1, 3 do
	local te 			= _G["TempEnchant"..i]
	local teicon 		= _G["TempEnchant"..i.."Icon"]
	local teduration 	= _G["TempEnchant"..i.."Duration"]
	local teborder		= _G["TempEnchant"..i.."Border"]
	te:SetParent(BuffFrame)
	te:SetSize(cfg.iconsize,cfg.iconsize)
	teicon:SetTexCoord(.08, .92, .08, .92)
	teicon:SetAllPoints(te)
	teduration:ClearAllPoints()
	teduration:SetPoint("BOTTOM", 0, cfg.timeYoffset)
	teduration:SetFont(cfg.font, cfg.timefontsize, "THINOUTLINE")
	M.CreateBG(te)
	M.CreateSD(te)
	if teborder then 
		teborder:SetTexture(cfg.auratex)
		teborder:SetTexCoord(0.03125, 0.96875, 0.03125, 0.96875)
		teborder:SetPoint("TOPLEFT", te, -1, 1)
		teborder:SetPoint("BOTTOMRIGHT", te, 1, -1)
	end
end

local function CreateBuffStyle(buttonName, i, debuff)
	local buff		= _G[buttonName..i]
	local icon		= _G[buttonName..i.."Icon"]
	local border	= _G[buttonName..i.."Border"]
	local duration	= _G[buttonName..i.."Duration"]
	local count 	= _G[buttonName..i.."Count"]
	if icon and not _G[buttonName..i.."Background"] then
		buff:SetSize(cfg.iconsize,cfg.iconsize)
		icon:SetTexCoord(.08, .92, .08, .92)
		icon:SetAllPoints(buff)
		duration:ClearAllPoints()
		duration:SetPoint("BOTTOM", 0, cfg.timeYoffset)
		duration:SetFont(cfg.font, cfg.timefontsize, "THINOUTLINE")
		M.CreateBG(buff)
		M.CreateSD(buff)
		count:ClearAllPoints()
		count:SetPoint("TOPRIGHT", 3, 0)
		count:SetFont(cfg.font, cfg.countfontsize, "OUTLINE")
	end
	if border then 
		border:SetTexture(cfg.auratex)
		border:SetTexCoord(0.03125, 0.96875, 0.03125, 0.96875)
		border:SetPoint("TOPLEFT", buff, -1, 1)
		border:SetPoint("BOTTOMRIGHT", buff, 1, -1)
	end
end

local function OverrideBuffAnchors()
	local buttonName = "BuffButton" -- c
	local buff, previousBuff, aboveBuff;
	local numBuffs = 0;
	local slack = BuffFrame.numEnchants
	if ShouldShowConsolidatedBuffFrame() then
		slack = slack + 1;	
	end
	for i=1, BUFF_ACTUAL_DISPLAY do
		CreateBuffStyle(buttonName, i, false)
		local buff = _G[buttonName..i]
		if not ( buff.consolidated ) then	
			numBuffs = numBuffs + 1
			i = numBuffs + slack
			buff:ClearAllPoints()
			if ( (i > 1) and (mod(i, BUFFS_PER_ROW) == 1) ) then
 				if ( i == BUFFS_PER_ROW+1 ) then
					buff:SetPoint("TOP", ConsolidatedBuffs, "BOTTOM", 0, -20)
				else
					buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -20)
				end
				aboveBuff = buff; 
			elseif ( i == 1 ) then
				buff:SetPoint(unpack(cfg.BUFFpos))
			else
				if cfg.direction =="LEFT" then
					if ( numBuffs == 1 ) then
						local  mh, _, _, oh, _, _, te = GetWeaponEnchantInfo()
						if mh and oh and te and not UnitHasVehicleUI("player") then
							buff:SetPoint("TOPLEFT", TempEnchant3, "TOPRIGHT", cfg.spacing, 0);
						elseif ((mh and oh) or (mh and te) or (oh and te)) and not UnitHasVehicleUI("player") then
							buff:SetPoint("TOPLEFT", TempEnchant2, "TOPRIGHT", cfg.spacing, 0);
						elseif ((mh and not oh and not te) or (oh and not mh and not te) or (te and not mh and not oh)) and not UnitHasVehicleUI("player") then
							buff:SetPoint("TOPLEFT", TempEnchant1, "TOPRIGHT", cfg.spacing, 0)
						else
							buff:SetPoint("TOPLEFT", ConsolidatedBuffs, "TOPRIGHT", cfg.spacing, 0);
						end
					else
							buff:SetPoint("LEFT", previousBuff, "RIGHT", cfg.spacing, 0);
					end
				else
					if ( numBuffs == 1 ) then
						local  mh, _, _, oh, _, _, te = GetWeaponEnchantInfo()
						if mh and oh and te and not UnitHasVehicleUI("player") then
							buff:SetPoint("TOPRIGHT", TempEnchant3, "TOPLEFT", -cfg.spacing, 0);
						elseif ((mh and oh) or (mh and te) or (oh and te)) and not UnitHasVehicleUI("player") then
							buff:SetPoint("TOPRIGHT", TempEnchant2, "TOPLEFT", -cfg.spacing, 0);
						elseif ((mh and not oh and not te) or (oh and not mh and not te) or (te and not mh and not oh)) and not UnitHasVehicleUI("player") then
							buff:SetPoint("TOPRIGHT", TempEnchant1, "TOPLEFT", -cfg.spacing, 0)
						else
							buff:SetPoint("TOPRIGHT", ConsolidatedBuffs, "TOPLEFT", -cfg.spacing, 0);
						end
					else
							buff:SetPoint("RIGHT", previousBuff, "LEFT", -cfg.spacing, 0);
					end
				end
			end
			previousBuff = buff
		end		
	end
end

local function OverrideDebuffAnchors(buttonName, i)
	CreateBuffStyle(buttonName, i, true)
	local color
	local buffName = buttonName..i
	local dtype = select(5, UnitDebuff("player",i))   
	local debuffSlot = _G[buffName.."Border"]
	local debuff = _G[buttonName..i];
	debuff:ClearAllPoints()
	if i == 1 then
		debuff:SetPoint(unpack(cfg.DEBUFFpos))
	else
		if cfg.direction =="LEFT" then
			debuff:SetPoint("LEFT", _G[buttonName..(i-1)], "RIGHT", cfg.spacing, 0)
		else
			debuff:SetPoint("RIGHT", _G[buttonName..(i-1)], "LEFT", -cfg.spacing, 0)	
		end
	end
	if (dtype ~= nil) then
		color = DebuffTypeColor[dtype]
	else
		color = DebuffTypeColor["none"]
	end
	if debuffSlot then debuffSlot:SetVertexColor(color.r * 0.6, color.g * 0.6, color.b * 0.6, 1) end
end

-- fixing the consolidated buff container sizes because the default formula is just SHIT!
local function OverrideConsolidatedBuffsAnchors()
	for i = 1, NUM_LE_RAID_BUFF_TYPES do
		local buff = ConsolidatedBuffsTooltip["Buff"..i]
		buff.icon:SetTexCoord(.08, .92, .08, .92)
		buff.label:SetFont(M.media.font, 14, "")
		if buff.bg then return end
		local bg = CreateFrame("Frame", nil, buff)
		bg:SetFrameLevel(0)
		bg:SetBackdrop({
			bgFile = M.media.solid,
			edgeFile = M.media.solid,
			edgeSize = 1,
		})
		bg:SetPoint("TOPLEFT", buff.icon, -1, 1)
		bg:SetPoint("BOTTOMRIGHT", buff.icon, 1, -1)
		bg:SetBackdropColor(.05, .05, .05, .95)
		bg:SetBackdropBorderColor(0, 0, 0, 1)
		buff.bg = bg
	end
end

local cbt = ConsolidatedBuffsTooltip
cbt:SetScale(1)
cbt:SetBackdrop(nil)
M.CreateBG(cbt)
M.CreateSD(cbt)

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", OverrideBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", OverrideDebuffAnchors)
hooksecurefunc("RaidBuffTray_Update", OverrideConsolidatedBuffsAnchors)
