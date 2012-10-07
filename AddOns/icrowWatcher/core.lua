-- based on Sora's AuraWatch by Neavo @ ngacn.cc
local M = icrowMedia
local addon, ns = ...
local cfg = ns.Config

local AuraList, Aura, MaxFrame = {}, {}, 12
local MyClass = select(2, UnitClass("player")) 
local BuildICON = cfg.BuildICON
if not iWatcherDB then iWatcherDB = {} end

local uflag = true
local ishunter = (MyClass == "HUNTER") and true or false

-- Init
local function BuildAuraList()
	AuraList = ns.Watchlist["ALL"] and ns.Watchlist["ALL"] or {}
	for key, _ in pairs(ns.Watchlist) do
		if key == MyClass then
			for _, value in pairs(ns.Watchlist[MyClass]) do tinsert(AuraList, value) end
		end
	end
	wipe(ns.Watchlist)
end

local function MakeMoveHandle(Frame, Text, key, Pos)
	local MoveHandle = CreateFrame("Frame", nil, UIParent)
	MoveHandle:SetWidth(Frame:GetWidth())
	MoveHandle:SetHeight(Frame:GetHeight())
	MoveHandle:SetFrameStrata("HIGH")
	MoveHandle:SetBackdrop({bgFile = M.media.solid})
	MoveHandle:SetBackdropColor(0, 0, 0, 0.9)
	MoveHandle.Text = MoveHandle:CreateFontString(nil, "OVERLAY")
	MoveHandle.Text:SetFont(M.media.font, 10, "THINOUTLINE")
	MoveHandle.Text:SetPoint("CENTER")
	MoveHandle.Text:SetText(Text)
	if not iWatcherDB[key] then 
		MoveHandle:SetPoint(unpack(Pos))
	else
		MoveHandle:SetPoint(unpack(iWatcherDB[key]))		
	end
	MoveHandle:EnableMouse(true)
	MoveHandle:SetMovable(true)
	MoveHandle:RegisterForDrag("LeftButton")
	MoveHandle:SetScript("OnDragStart", function(self) MoveHandle:StartMoving() end)
	MoveHandle:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local AnchorF, _, AnchorT, X, Y = self:GetPoint()
		iWatcherDB[key] = {AnchorF, "UIParent", AnchorT, X, Y}
	end)
	MoveHandle:Hide()
	Frame:SetPoint("CENTER", MoveHandle)
	return MoveHandle
end

local function BuildAura()
	for key, value in pairs(AuraList) do
		local FrameTable = {}
		for i = 1, MaxFrame do
			local Frame = BuildICON(value.IconSize)
			if i == 1 then Frame.MoveHandle = MakeMoveHandle(Frame, value.Name, key, value.Pos) end
			tinsert(FrameTable, Frame)
		end
		FrameTable.Index = 1
		FrameTable.UnitID = value.UnitID
		tinsert(Aura, FrameTable)
	end
end

local function UpdatePos()
	for key, value in pairs(Aura) do
		local Direction, Interval = AuraList[key].Direction, AuraList[key].Interval
		for i = 1, MaxFrame do
			value[i]:ClearAllPoints()
			if i == 1 then
				value[i]:SetPoint("CENTER", value[i].MoveHandle)
			elseif Direction:lower() == "right" then
				value[i]:SetPoint("LEFT", value[i-1], "RIGHT", Interval, 0)
			elseif Direction:lower() == "left" then
				value[i]:SetPoint("RIGHT", value[i-1], "LEFT", -Interval, 0)
			elseif Direction:lower() == "up" then
				value[i]:SetPoint("BOTTOM", value[i-1], "TOP", 0, Interval)
			elseif Direction:lower() == "down" then
				value[i]:SetPoint("TOP", value[i-1], "BOTTOM", 0, -Interval)
			end
		end
	end
end

local function Init()
	BuildAuraList()
	BuildAura()
	UpdatePos()
end

-- UpdateAura
local function UpdateAuraFrame(index, icon, count, duration, expires)
	local Frame = Aura[index][Aura[index].Index]
	if Frame then Frame:Show() end
	if Frame.Icon then Frame.Icon:SetTexture(icon) end
	if Frame.Count then Frame.Count:SetText((count and count > 1) and count or nil) end
	if Frame.Cooldown and expires and duration then
		Frame.Cooldown:SetReverse(true)
		Frame.Cooldown:SetCooldown(expires-duration, duration)
	end
	
	Aura[index].Index = (Aura[index].Index + 1 > MaxFrame) and MaxFrame or Aura[index].Index + 1
end

local function AuraFilter(spellID, UnitID, index)
	for KEY, VALUE in pairs(AuraList) do
		if VALUE.UnitID == UnitID then
			for key, value in pairs(VALUE.List) do
				if value == spellID then
					if VALUE.Type == "buff" then
						local _, _, icon, count, _, duration, expires = UnitBuff(VALUE.UnitID, index)
						return KEY, icon, count, duration, expires
					elseif UnitID == "target" then
						local _, _, icon, count, _, duration, expires = UnitDebuff(VALUE.UnitID, index, "PLAYER")
						return KEY, icon, count, duration, expires
					else
						local _, _, icon, count, _, duration, expires = UnitDebuff(VALUE.UnitID, index)
						return KEY, icon, count, duration, expires
					end
				end
			end
		end
	end
	return false
end

local function UpdateAura(UnitID)
	local filter = UnitID == "target" and "PLAYER" or nil
	local index = 1
    while true do
		local name, _, _, _, _, _, _, _, _, _, spellID = UnitBuff(UnitID, index)
		if not name then break end
		if AuraFilter(spellID, UnitID, index) then UpdateAuraFrame(AuraFilter(spellID, UnitID, index)) end
		index = index + 1
	end
	local index = 1
    while true do
		local name, _, _, _, _, _, _, _, _, _, spellID = UnitDebuff(UnitID, index, filter)
		if not name then break end
		if AuraFilter(spellID, UnitID, index) then UpdateAuraFrame(AuraFilter(spellID, UnitID, index)) end
		index = index + 1
	end
end

-- CleanUp
local function CleanUp(UnitID)
	for _, value in pairs(Aura) do
		if value.UnitID == UnitID then
			for i = 1, MaxFrame do
				if value[i] then
					value[i]:Hide()
				end
				if value[i].Icon then value[i].Icon:SetTexture(nil) end
				if value[i].Count then value[i].Count:SetText(nil) end
			end
			value.Index = 1
		end
	end
end

local function CleanAll()
	for _, value in pairs(Aura) do
		for i = 1, MaxFrame do
			if value[i] then
				value[i]:Hide()
			end
			if value[i].Icon then value[i].Icon:SetTexture(nil) end
			if value[i].Count then value[i].Count:SetText(nil) end
		end
		value.Index = 1
	end
end

local function UpdateFlag(self, elapsed)
	self.elapsed = (self.elapsed or 0) - elapsed
	if self.elapsed < 0 and uflag == false then
		uflag = true
		self.elapsed = 0.1
	end
end

-- Event
local Event = CreateFrame("Frame")
Event:RegisterEvent("PLAYER_ENTERING_WORLD")
Event:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		Init()
		self.Timer = 0
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("UNIT_AURA")
		self:RegisterEvent("UNIT_TARGET")
	elseif event == "UNIT_TARGET" then
		local unitId = ...
		if unitId == "player" then
			CleanUp("target")
			UpdateAura("target")
		end
	else
		local unitId = ...
		if unitId == "target" and uflag then
			CleanUp("target")
			UpdateAura("target")
			uflag = false
		elseif unitId == "player" then
			CleanUp("player")
			UpdateAura("player")
		elseif unitId == "pet" and ishunter then
			CleanUp("pet")
			UpdateAura("pet")
		end
	end
end)
Event:SetScript("OnUpdate", UpdateFlag)

-- Test
local TestFlag = true
SlashCmdList.icrowWatcher = function(msg)
	if msg:lower() == "test" then
		if TestFlag then
			TestFlag = false
			for _, value in pairs(Aura) do
				for i = 1, MaxFrame do
					if value[i] then
						value[i]:Show()	
					end		
					if value[i].Icon then value[i].Icon:SetTexture(select(3, GetSpellInfo(118))) end
					if value[i].Count then value[i].Count:SetText("9") end			
				end
				value[1].MoveHandle:Show()
			end
		else
			TestFlag = true
			CleanAll()
			for _, value in pairs(Aura) do value[1].MoveHandle:Hide() end
		end
	elseif msg:lower() == "reset" then
		wipe(iWatcherDB)
		ReloadUI()
	else
		print("/iw test -- 测试模式")
		print("/iw reset -- 恢复默认设置")
	end
end
SLASH_icrowWatcher1 = "/iw"