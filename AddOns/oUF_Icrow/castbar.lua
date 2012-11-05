--[[

感谢 混乱时雨大大 @ ngacn.cc 从oUF_Qulight里扒出这么好用的施法条!

--]]


--- ----------------------------------
--> Init
--- ----------------------------------

local addon, ns = ...
local oUF = oUF or ns.oUF
local M = icrowMedia

--- ----------------------------------
--> Config
--- ----------------------------------

local bar_texture = M.media.statusbar 						-- 施法条材质
local NameFont = M.media.font								-- 法术名称字体
local NumbFont = M.media.font								-- 施法时间数字字体
local player_castpos = {"BOTTOM",UIParent,"BOTTOM",0,180}	-- 玩家施法条位置
local target_castpos = {"CENTER",UIParent,"CENTER",0,140}	-- 目标施法条位置
local focus_castpos = {"CENTER",UIParent,"CENTER",-335,140}	-- 焦点施法条位置
local pet_castpos = {"CENTER",UIParent,"CENTER",10,120}		-- 宠物施法条位置
local other_castpos = {"CENTER",UIParent,"CENTER",10,120}	-- 其他施法条位置

--- ----------------------------------
--> Function
--- ----------------------------------

local fontstring = function(f, name, size, outline)
    local fs = f:CreateFontString(nil, "OVERLAY")
    fs:SetFont(name, size, outline)
    fs:SetShadowColor(0,0,0,1)
    return fs
end

local channelingTicks = {
	-- 术士
	[GetSpellInfo(1120)] = 5, -- 吸取灵魂
	[GetSpellInfo(689)] = 5, -- 吸取生命
	[GetSpellInfo(5740)] = 4, -- 火雨
	-- 德鲁伊
	[GetSpellInfo(740)] = 4, -- 宁静
	[GetSpellInfo(16914)] = 10, -- 飓风
	-- 牧师
	[GetSpellInfo(15407)] = 3, -- 心灵鞭笞
	[GetSpellInfo(48045)] = 5, -- 心灵灼烧
	[GetSpellInfo(47540)] = 2, -- 苦修
	-- 法师
	[GetSpellInfo(5143)] = 5, -- 奥术飞弹
	[GetSpellInfo(10)] = 5, -- 暴风雪
	[GetSpellInfo(12051)] = 4, -- 唤醒
}
local ticks = {}
	setBarTicks = function(castBar, ticknum)
	if ticknum and ticknum > 0 then
		local delta = castBar:GetWidth() / ticknum
		for k = 1, ticknum do
			if not ticks[k] then
				ticks[k] = castBar:CreateTexture(nil, 'OVERLAY')
				ticks[k]:SetTexture(bar_texture)
				ticks[k]:SetVertexColor(0, 0, 0)
				ticks[k]:SetWidth(1)	--分段施法宽度
				ticks[k]:SetHeight(castBar:GetHeight())
			end
			ticks[k]:ClearAllPoints()
			ticks[k]:SetPoint("CENTER", castBar, "LEFT", delta * k, 0 )
			ticks[k]:Show()
		end
	else
		for k, v in pairs(ticks) do
			v:Hide()
		end
	end
end

CastBar_OnCastbarUpdate = function(self, elapsed)
	local currentTime = GetTime()
	if self.casting or self.channeling then
		local parent = self:GetParent()
		local duration = self.casting and self.duration + elapsed or self.duration - elapsed
		if (self.casting and duration >= self.max) or (self.channeling and duration <= 0) then
			self.casting = nil
			self.channeling = nil
			return
		end
		if parent.unit == 'player' then
			if self.delay ~= 0 then
				self.Time:SetFormattedText('%.1f / |cffff0000%.1f|r', duration, self.casting and self.max + self.delay or self.max - self.delay)
			else
				self.Time:SetFormattedText('%.1f / %.1f', duration, self.max)
			end
		else
			self.Time:SetFormattedText('%.1f / %.1f', duration, self.casting and self.max + self.delay or self.max - self.delay)
		end
		self.duration = duration
		self:SetValue(duration)
		self.Spark:SetPoint('CENTER', self, 'LEFT', (duration / self.max) * self:GetWidth(), 0)
	else
		self.Spark:Hide()
		local alpha = self:GetAlpha() - 0.02
		if alpha > 0 then
			self:SetAlpha(alpha)
		else
			self.fadeOut = nil
			self:Hide()
		end
	end
end

CastBar_OnCastSent = function(self, event, unit, spell, rank)
	if self.unit ~= unit or not self.Castbar.SafeZone then return end
	self.Castbar.SafeZone.sendTime = GetTime()
end

CastBar_PostCastStart = function(self, unit, name, rank, text)
	local pcolor = {255/255, 128/255, 128/255}
	local interruptcb = {95/255, 182/255, 255/255}
	self:SetAlpha(1.0)
	self.Spark:Show()
	self:SetStatusBarColor(unpack(self.casting and self.CastingColor or self.ChannelingColor))
	local parent = self:GetParent()
	if parent.unit == "player" then
		local sf = self.SafeZone
		if sf.sendTime then
			sf.timeDiff = GetTime() - sf.sendTime
			sf.timeDiff = sf.timeDiff > self.max and self.max or sf.timeDiff
			sf:SetWidth(self:GetWidth() * sf.timeDiff / self.max)
			sf:Show()
		end
		if self.casting then
			setBarTicks(self, 0)
		else
			local spell = UnitChannelInfo(unit)
			self.channelingTicks = channelingTicks[spell] or 0
			setBarTicks(self, self.channelingTicks)
		end
	elseif not self.interrupt then
		self:SetStatusBarColor(interruptcb[1],interruptcb[2],interruptcb[3],1)
	else
		self:SetStatusBarColor(pcolor[1], pcolor[2], pcolor[3],1)
	end
end

CastBar_PostCastStop = function(self, unit, name, rank, castid)
	if not self.fadeOut then 
		self:SetStatusBarColor(unpack(self.CompleteColor))
		self.fadeOut = true
	end
	self:SetValue(self.max)
	self:Show()
end

CastBar_PostChannelStop = function(self, unit, name, rank)
	self.fadeOut = true
	self:SetValue(0)
	self:Show()
end

CastBar_PostCastFailed = function(self, event, unit, name, rank, castid)
	self:SetStatusBarColor(unpack(self.FailColor))
	self:SetValue(self.max)
	if not self.fadeOut then
		self.fadeOut = true
	end
	self:Show()
end	

--castbar--
local cbColor = {95/255, 182/255, 255/255}

function EnableCB(self)

end

function DisableCB(self)

end

--- ----------------------------------
--> Create CastBar
--- ----------------------------------
function CreateCastBar(f, unit)
	s = CreateFrame("StatusBar", "oUF_Castbar"..unit, f)
	s:SetHeight(20)
	s:SetWidth(240)

	if unit == "player" then
		s:SetPoint(unpack(player_castpos))
	elseif unit == "target" then
		s:SetPoint(unpack(target_castpos))
	elseif unit == "focus" then
		s:SetWidth(182)
		s:SetPoint(unpack(focus_castpos))
	elseif unit == "pet" then
		s:SetPoint(unpack(pet_castpos))
	else
		s:SetPoint(unpack(other_castpos))	
	end
	
	s:SetStatusBarTexture(bar_texture)
	s:SetStatusBarColor(95/255, 182/255, 255/255, 1)
	s:SetFrameLevel(1)
	s.CastingColor = cbColor
	s.CompleteColor = {20/255, 208/255, 0/255}
	s.FailColor = {255/255, 12/255, 0/255}
	s.ChannelingColor = cbColor
	M.CreateBG(s)
	M.CreateSD(s)
	
    sp = s:CreateTexture(nil, "OVERLAY")
    sp:SetBlendMode("ADD")
    sp:SetAlpha(0.5)
    sp:SetHeight(s:GetHeight()*2.5)
	--castbar txt--
    local txt = fontstring(s, NameFont, 12, "")
	txt:SetShadowOffset(0.5, -0.5)
    txt:SetPoint("LEFT", 5, -0.5)
    txt:SetJustifyH("LEFT")
    local t = fontstring(s, NumbFont, 12, "")
	t:SetShadowOffset(0.5, -0.5)
    t:SetPoint("RIGHT", -5, -0.5)
	
	if unit == "player" then
	  CastingBarFrame:UnregisterAllEvents()
	  CastingBarFrame.Show = CastingBarFrame.Hide
	  CastingBarFrame:Hide()
	elseif unit == "target" then
	  TargetFrameSpellBar:UnregisterAllEvents()
	  TargetFrameSpellBar.Show = TargetFrameSpellBar.Hide
	  TargetFrameSpellBar:Hide()
	elseif unit == "focus" then
	  FocusFrameSpellBar:UnregisterAllEvents()
	  FocusFrameSpellBar.Show = TargetFrameSpellBar.Hide
	  FocusFrameSpellBar:Hide()
	end
	
    if unit == "player" then
      local z = s:CreateTexture(nil,"OVERLAY")
      z:SetTexture(bar_texture)
      z:SetVertexColor(1,0.1,0,.6)
      z:SetPoint("TOPRIGHT")
      z:SetPoint("BOTTOMRIGHT")
	  s:SetFrameLevel(10)
      s.SafeZone = z
      f:RegisterEvent("UNIT_SPELLCAST_SENT", CastBar_OnCastSent)
    end
	
	s.OnUpdate = CastBar_OnCastbarUpdate
    s.PostCastStart = CastBar_PostCastStart
    s.PostChannelStart = CastBar_PostCastStart
    s.PostCastStop = CastBar_PostCastStop
    s.PostChannelStop = CastBar_PostChannelStop
    s.PostCastFailed = CastBar_PostCastFailed
    s.PostCastInterrupted = CastBar_PostCastFailed
	
    f.Castbar = s
    f.Castbar.Text = txt
    f.Castbar.Time = t
    f.Castbar.Spark = sp
end

--- ----------------------------------
--> End
--- ----------------------------------

oUF:AddElement("CastBar", UpdateCB, EnableCB, DisableCB)