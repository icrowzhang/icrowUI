-- 设置: true为开启, false为关闭
local cfg = {
	saysapped = false,				-- 被贼闷棍自动喊<<有贼>>
	classportrait = true,			-- 将玩家头像显示为职业图标
	killfilter = true,				-- 干掉讨厌的@#$%^&*聊天绿坝娘
	blizzsctfont = true,			-- 替换系统内置的玩家受到伤害和治疗的数字字体
	killblizzframes = false,		-- 干掉某些不想要的系统框体(目前没有)
	killbossemotes = false,			-- 干掉系统内置的山寨DBM(版本初期不推荐, 建议等DBM完善了再...)
	safequeue = true,				-- 排进战场的时候再也不怕错点到退出队列按钮了!
}

---------->> saysapped by Ray @ ngacn.cc
local function SaySappedOn(self, event, ...)
	local eventType = select(2, ...)
	if eventType == "SPELL_AURA_APPLIED" then
		local destFlags = select(10, ...)
		local spellID = select(12, ...)
		if bit.band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE
		and spellID == 6770 then
			SendChatMessage("<<有贼>>", "SAY")
		end
	end
end

---------->> show class portrait
local function ShowClassPortrait(s)
	if s.portrait then
		if UnitIsPlayer(s.unit) then
			local t = CLASS_ICON_TCOORDS[select(2,UnitClass(s.unit))]
			if t then
				s.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
				s.portrait:SetTexCoord(unpack(t))
			end
		else
			s.portrait:SetTexCoord(0, 1, 0, 1)
		end
	end
end

---------->> BlizzSctFont
local sctfontName = NumberFontNormal:GetFont()

local function FS_SetFont()
	local _, fHeight, fFlags = CombatTextFont:GetFont()
	CombatTextFont:SetFont(sctfontName, fHeight, fFlags)
end

---------->> kill Blizz frames
local function kill(f)
	if f.UnregisterAllEvents then
		f:UnregisterAllEvents()
	end
	f.Show = function() end
	f:Hide()
end

---------->> kill boss emotes
local RaidBossEmoteFrame = RaidBossEmoteFrame
local function KillBossEmotes()
	RaidBossEmoteFrame:UnregisterEvent("RAID_BOSS_EMOTE")
end

---------->> SafeQueue by Jordon
local SQbutton2 = StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"].button2
local function SafeQueue_Enable()
	StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"].button2 = nil
	StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"].hideOnEscape = false
end

---------->> main event frame
local icrowGallery = CreateFrame("Frame", nil, UIParent)
icrowGallery:RegisterEvent("PLAYER_ENTERING_WORLD")
icrowGallery:SetScript("OnEvent", function(self, event, ...)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if cfg.saysapped then
		local SaySapped = CreateFrame("Frame")
		SaySapped:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		SaySapped:SetScript("OnEvent", SaySappedOn)
	end
	if cfg.classportrait then
		hooksecurefunc("UnitFramePortrait_Update", ShowClassPortrait)
	end
	if cfg.killfilter and BNConnected() and BNGetMatureLanguageFilter() == true then
		BNSetMatureLanguageFilter(false)
	end
	if cfg.blizzsctfont then
		FS_SetFont()
	end
	if cfg.killblizzframes then
		
	end
	if cfg.killbossemotes then
		KillBossEmotes()
	end
	if cfg.safequeue then
		SafeQueue_Enable()
	end
end)