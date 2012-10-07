﻿-- code frome EUI, thanks to dtzy @ ngacn.cc

local CH = QQChat
local i

local L = {}
if (GetLocale() == "zhCN") then
	L["Enable/Disable"] = "启用/禁用"
	L["BigFootChannel"] = "大脚世界频道"
	L["Auto join BigFootChannel"] = "自动加入大脚世界频道"
	L.INFO_NO_SPECIALIZATION = "无专精"
	L.INFO_DURABILITY_STAT1 = "法伤"
	L.INFO_DURABILITY_STAT2 = "命中"
	L.INFO_DURABILITY_STAT3 = "爆击"
	L.INFO_DURABILITY_STAT4 = "急速"
	L.INFO_DURABILITY_STAT5 = "法力"
	L.INFO_DURABILITY_STAT6 = "治疗"
	L.INFO_DURABILITY_STAT7 = "5秒法力回复"
	L.INFO_DURABILITY_STAT8 = "强度"
	L.INFO_DURABILITY_STAT9 = "精准"
	L.INFO_DURABILITY_STAT10 = "生命"
	L.INFO_DURABILITY_STAT11 = "躲闪"
	L.INFO_DURABILITY_STAT12 = "招架"
	L.INFO_DURABILITY_STAT13 = "格挡"
	L.INFO_DURABILITY_STAT14 = "护甲"
	L.INFO_DURABILITY_NO = "无"
	L.INFO_DURABILITY_TIP3 = "角色数据报告: "
	L.INFO_DURABILITY_TIP4 = "天赋"
	L.INFO_DURABILITY_TIP5 = "装备等级"
	L.INFO_DURABILITY_TIP6 = "精通点数"
	L.INFO_DURABILITY_TIP7 = "韧性"
	L.INFO_DURABILITY_TIP = "点击发送用户状态报告"
elseif (GetLocale() == "zhTW") then
	L["Enable/Disable"] = "啟用/禁用"
	L["BigFootChannel"] = "大腳世界頻道"
	L["Auto join BigFootChannel"] = "自動加入大腳世界頻道"
	L.INFO_NO_SPECIALIZATION = "無專精"
	L.INFO_DURABILITY_STAT1 = "法傷"
	L.INFO_DURABILITY_STAT2 = "命中"
	L.INFO_DURABILITY_STAT3 = "爆擊"
	L.INFO_DURABILITY_STAT4 = "急速"
	L.INFO_DURABILITY_STAT5 = "法力"
	L.INFO_DURABILITY_STAT6 = "治療"
	L.INFO_DURABILITY_STAT7 = "5秒法力回復"
	L.INFO_DURABILITY_STAT8 = "強度"
	L.INFO_DURABILITY_STAT9 = "精准"
	L.INFO_DURABILITY_STAT10 = "生命"
	L.INFO_DURABILITY_STAT11 = "躲閃"
	L.INFO_DURABILITY_STAT12 = "招架"
	L.INFO_DURABILITY_STAT13 = "格擋"
	L.INFO_DURABILITY_STAT14 = "護甲"
	L.INFO_DURABILITY_NO = "無"
	L.INFO_DURABILITY_TIP3 = "角色數據報告: "
	L.INFO_DURABILITY_TIP4 = "天賦"
	L.INFO_DURABILITY_TIP5 = "裝備等級"
	L.INFO_DURABILITY_TIP6 = "精通點數"
	L.INFO_DURABILITY_TIP7 = "韌性"
	L.INFO_DURABILITY_TIP = "點擊發送用戶狀態報告"
else
	L["Enable/Disable"] = "Enable/Disalbe"
	L["BigFootChannel"] = "BigFootChannel"
	L["Auto join BigFootChannel"] = "Auto join BigFootChannel"
	L.INFO_NO_SPECIALIZATION = "No Specialization"
	L.INFO_DURABILITY_STAT1 = "Spell Power"
	L.INFO_DURABILITY_STAT2 = "Hit Rating"
	L.INFO_DURABILITY_STAT3 = "Crit Chance"
	L.INFO_DURABILITY_STAT4 = "Haste"
	L.INFO_DURABILITY_STAT5 = "Mana"
	L.INFO_DURABILITY_STAT6 = "Healing "
	L.INFO_DURABILITY_STAT7 = "Mana Regen"
	L.INFO_DURABILITY_STAT8 = "Attack Power"
	L.INFO_DURABILITY_STAT9 = "Expertise"
	L.INFO_DURABILITY_STAT10 = "Life"
	L.INFO_DURABILITY_STAT11 = "Dodge"
	L.INFO_DURABILITY_STAT12 = "Parry"
	L.INFO_DURABILITY_STAT13 = "Block"
	L.INFO_DURABILITY_STAT14 = "Armor"
	L.INFO_DURABILITY_NO = "None"
	L.INFO_DURABILITY_TIP3 = "Player Status Report:"
	L.INFO_DURABILITY_TIP4 = "Talent"
	L.INFO_DURABILITY_TIP5 = "Item Level"
	L.INFO_DURABILITY_TIP6 = "Mastery"
	L.INFO_DURABILITY_TIP7 = "Resilience"
	L.INFO_DURABILITY_TIP = "Click to send player status report"
end
CH.L = L
--状态报告
local MyData = {};
local function StatReport_GetSpellText()
	local text = "";
	text = text..L.INFO_DURABILITY_STAT1..':'..MyData.SSP;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT2..':'..MyData.SHIT;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT3..':'..format("%.1f%%", MyData.SCRIT);
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT4..':'..MyData.SHASTE;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT5..':'..MyData.MP;
	return text;
end

local function StatReport_GetHealText()
	local text = "";
	text = text..L.INFO_DURABILITY_STAT6..':'..MyData.SHP;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT3..':'..format("%.1f%%", MyData.SCRIT);
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT4..':'..MyData.SHASTE;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT5..':'..MyData.MP;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT7..':'..MyData.SMR;
	return text;
end

local function StatReport_GetSpellAndHealText()
	local text = "";
	text = text..L.INFO_DURABILITY_STAT1..':'..MyData.SSP;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT6..':'..MyData.SHP;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT2..':'..MyData.SHIT;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT3..':'..format("%.1f%%", MyData.SCRIT);
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT4..':'..MyData.SHASTE;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT5..':'..MyData.MP;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT7..':'..MyData.SMR;
	return text;
end

local function StatReport_GetMeleeText()
	local text = "";
	text = text..L.INFO_DURABILITY_STAT8..':'..MyData.MAP;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT2..':'..MyData.MHIT;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT3..':'..format("%.2f%%", MyData.MCRIT);
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT9..':'..MyData.MEXPER;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT4..':'..MyData.SHASTE;	
	return text;
end

local function StatReport_GetRangedText()
	local text = "";
	text = text..L.INFO_DURABILITY_STAT8..':'..MyData.RAP;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT2..':'..MyData.RHIT;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT3..':'..format("%.1f%%", MyData.RCRIT);
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT4..':'..MyData.SHASTE;
	return text;
end

local function StatReport_GetTankText()
	local text = "";
	text = text..L.INFO_DURABILITY_STAT10..':'..MyData.HP;
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT11..':'..format("%.1f%%", MyData.DODGE);
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT12..':'..format("%.1f%%", MyData.PARRY);
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT13..':'..format("%.1f%%", MyData.BLOCK);
	text = text..", ";
	text = text..L.INFO_DURABILITY_STAT14..':'..MyData.ARMOR;
	return text;
end

local function StatReport_TalentData()
	local role = "DAMAGER";
	local specinfo = L.INFO_NO_SPECIALIZATION;
	local spec = GetSpecialization(); -- 得到当前天赋类别1,2,3
	if spec then
		role = GetSpecializationRole(spec); --得到当前天赋职责 tank, healer, dps..
		specinfo = select(2, GetSpecializationInfo(spec)); -- 得到天赋描述
	end
	return specinfo.. " (".. _G[role]..")", ''
end

local function StatReport_UnitAttackPower()
	local base, posBuff, negBuff = UnitAttackPower("player");
	return floor(base + posBuff + negBuff);
end

local function StatReport_UnitRangedAttackPower()
	local base, posBuff, negBuff = UnitRangedAttackPower("player");
	return floor(base + posBuff + negBuff);
end

local function StatReport_GetSpellBonusDamage()
	local SSP = GetSpellBonusDamage(2);
	for i=3, 7 do
		SSP = max(SSP, GetSpellBonusDamage(i));
	end
	return floor(SSP);
end

local function StatReport_GetSpellCritChance()
	local SCRIT = GetSpellCritChance(2);
	for i=3, 7 do
		SCRIT = max(SCRIT, GetSpellCritChance(i));
	end
	return SCRIT;
end

local function StatReport_UnitDefense()
	local baseDEF, posDEF = UnitDefense("player");
	return floor(baseDEF + posDEF);
end

local slotName = {
	"HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "WristSlot",
	"HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
	"Trinket0Slot", "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot"
}
local function GetAiL(unit)
	local i, total, slot, itn, level = 0, 0, nil, 0

	for i in pairs(slotName) do
		slot = GetInventoryItemLink(unit, GetInventorySlotInfo(slotName[i]))
		if slot ~= nil then
			itn = itn + 1
			level = select(4, GetItemInfo(slot))
			total = total + level
		end
	end

	if total < 1 or itn < 1 then return 0 end

	return floor(total / itn)
end

local function StatReport_UpdateMyData()
	MyData.Name = UnitName("player");							--名称
	MyData.LV = UnitLevel("player");							--等级
	MyData.CLASS, MyData.CLASS_EN = UnitClass("player");		--职业
	MyData.HP = UnitHealthMax("player");						--生命值
	MyData.MP = UnitManaMax("player");							--法力值
	MyData.TKEY, MyData.TDATA = StatReport_TalentData();		--天赋
	MyData.ILVL = GetAiL("player");								--平均装备等级
	
	MyData.Mastery = format("%.2f%%", GetMasteryEffect());		--精通点数
	--基础属性
	MyData.STR = UnitStat("player", 1);							--力量
	MyData.AGI = UnitStat("player", 2);							--敏捷
	MyData.STA = UnitStat("player", 3);							--耐力
	MyData.INT = UnitStat("player", 4);							--智力
	MyData.SPI = UnitStat("player", 5);							--精神
	--近战
	MyData.MAP = StatReport_UnitAttackPower();					--强度
	MyData.MHIT = GetCombatRating(6);							--命中等级
	MyData.MCRIT = GetCritChance();								--爆击率%
	MyData.MEXPER = format("%.1f", GetExpertise());				--精准
	--远程
	MyData.RAP = StatReport_UnitRangedAttackPower();			--强度
	MyData.RHIT = GetCombatRating(7);							--命中等级
	MyData.RCRIT = GetRangedCritChance();						--爆击率%
	--法术
	MyData.SSP = StatReport_GetSpellBonusDamage();				--伤害加成
	MyData.SHP = GetSpellBonusHealing();						--治疗加成
	MyData.SHIT = GetCombatRating(8);							--命中等级
	MyData.SCRIT = StatReport_GetSpellCritChance();				--爆击率
	MyData.SHASTE = GetCombatRating(20);						--急速等级
	MyData.SMR = floor(GetManaRegen()*5);						--法力回复（每5秒）
	--防御
	_,_,MyData.ARMOR = UnitArmor("player");						--护甲
	MyData.DEF = StatReport_UnitDefense();						--防御
	MyData.DODGE = GetDodgeChance();							--躲闪%
	MyData.PARRY = GetParryChance();							--招架%
	MyData.BLOCK = GetBlockChance();							--格挡%
	MyData.CRDEF = GetCombatRating(15);							--韧性
end

function CH:SendReport()
	--发送状态报告
	local msg = L.INFO_DURABILITY_TIP3
	StatReport_UpdateMyData()
	msg = msg..MyData.CLASS;
	msg = msg..", ";
	msg = msg..L.INFO_DURABILITY_TIP4..':'..MyData.TKEY..MyData.TDATA;
	msg = msg..", ";
	msg = msg..L.INFO_DURABILITY_TIP5..':'..MyData.ILVL;
	msg = msg..", ";
	msg = msg..L.INFO_DURABILITY_TIP6..':'..MyData.Mastery;

	msg = msg..", ";
	if MyData.CLASS_EN == "MAGE" or MyData.CLASS_EN == "WARLOCK" then
		msg = msg..StatReport_GetSpellText();
	end
	if MyData.CLASS_EN == "ROGUE" then
		msg = msg..StatReport_GetMeleeText();
	end
	if MyData.CLASS_EN == "HUNTER" then
		msg = msg..StatReport_GetRangedText();
	end
	if MyData.CLASS_EN == "DRUID" then
		if MyData.TKEY == select(2,GetSpecializationInfo(1)) then
			msg = msg..StatReport_GetSpellText();
		elseif MyData.TKEY == select(2,GetSpecializationInfo(2)) then
			if UnitBuff("player", GetSpellInfo(5487)) then
				msg = msg..StatReport_GetTankText();
			else
				msg = msg..StatReport_GetMeleeText();
			end
		elseif MyData.TKEY == select(2,GetSpecializationInfo(3)) then
			msg = msg..StatReport_GetHealText();
		else
			msg = msg..StatReport_GetMeleeText();
		end
	end
	if MyData.CLASS_EN == "SHAMAN" then
		if MyData.TKEY == select(2,GetSpecializationInfo(1)) then
			msg = msg..StatReport_GetSpellText();
		elseif MyData.TKEY == select(2,GetSpecializationInfo(2)) then
			msg = msg..StatReport_GetMeleeText();
		elseif MyData.TKEY == select(2,GetSpecializationInfo(3)) then
			msg = msg..StatReport_GetHealText();
		else
			msg = msg..StatReport_GetMeleeText();
		end
	end
	if MyData.CLASS_EN == "PALADIN" then
		if MyData.TKEY == select(2,GetSpecializationInfo(1)) then
			msg = msg..StatReport_GetHealText();
		elseif MyData.TKEY == select(2,GetSpecializationInfo(2)) then
			msg = msg..StatReport_GetTankText();
		elseif MyData.TKEY == select(2,GetSpecializationInfo(3)) then
			msg = msg..StatReport_GetMeleeText();
		else
			msg = msg..StatReport_GetMeleeText();
		end
	end
	if MyData.CLASS_EN == "MONK" then
		if MyData.TKEY == select(2,GetSpecializationInfo(2)) then
			msg = msg..StatReport_GetHealText();
		elseif MyData.TKEY == select(2,GetSpecializationInfo(1)) then
			msg = msg..StatReport_GetTankText();
		elseif MyData.TKEY == select(2,GetSpecializationInfo(3)) then
			msg = msg..StatReport_GetMeleeText();
		else
			msg = msg..StatReport_GetMeleeText();
		end
	end	
	if MyData.CLASS_EN == "PRIEST" then
		if MyData.TKEY == select(2,GetSpecializationInfo(1)) then
			msg = msg..StatReport_GetSpellAndHealText();
		elseif MyData.TKEY == select(2,GetSpecializationInfo(2)) then
			msg = msg..StatReport_GetHealText();
		elseif MyData.TKEY == select(2,GetSpecializationInfo(3)) then
			msg = msg..StatReport_GetSpellText();
		else
			msg = msg..StatReport_GetSpellText();
		end
	end
	if MyData.CLASS_EN == "WARRIOR" then
		if MyData.TKEY == select(2,GetSpecializationInfo(1)) then
			msg = msg..StatReport_GetMeleeText();
		elseif MyData.TKEY == select(2,GetSpecializationInfo(2)) then
			msg = msg..StatReport_GetMeleeText();
		elseif MyData.TKEY == select(2,GetSpecializationInfo(3)) then
			msg = msg..StatReport_GetTankText();
		else
			msg = msg..StatReport_GetMeleeText();
		end
	end
	if MyData.CLASS_EN == "DEATHKNIGHT" then
		if MyData.TKEY == select(2,GetSpecializationInfo(1)) then
			msg = msg..StatReport_GetTankText();
		else
			msg = msg..StatReport_GetMeleeText();
		end
	end

	if MyData.CRDEF > (200*(MyData.LV/70)) then
		msg = msg..", ";
		msg = msg..MyData.CRDEF..L.INFO_DURABILITY_TIP7;
	end	
	
	if IsAddOnLoaded("GearScoreLite") then
		msg = msg..", ";
		msg = msg.."GS:"..(GearScore_GetScore(UnitName("player"), "player") or "");
	end
	
	if IsAddOnLoaded("GearScore") then
		TenTonHammer:GetPlayerInfo();
		if TenTonHammer.PlayerInfo then
			msg = msg..", ";
			msg = msg.."GS:"..TenTonHammer.PlayerInfo['GearScore'];
		end
	end
	
	if ChatFrame1EditBox:IsShown() then
		ChatFrame1EditBox:Insert(msg);
	else
		local ExistMSG = ChatFrame1EditBox:GetText() or "";
		ChatFrame1EditBox:SetText(ExistMSG..msg);
		ChatEdit_SendText(ChatFrame1EditBox);
		ChatFrame1EditBox:SetText("");
		ChatFrame1EditBox:Hide();
	end
end