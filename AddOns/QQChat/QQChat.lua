-----------------------------------------------
-- config
-----------------------------------------------
-- 显示聊天时间戳(true/false) (显示/不显示) 点击时间复制聊天内容, 不显示时间点 ★ 复制聊天内容 
local showtime = false

-- 隐藏聊天框背景 (true/false) (隐藏/显示)
local hide_chatframe_backgrounds = true

-- 隐藏聊天标签背景 (true/false) (隐藏/显示)
local hide_chattab_backgrounds = false

-- 输入框置顶 (true/false) (顶/底)
local editboxtop = true

-- 输入框背景颜色/透明度 (a是透明度)
local BackdropColor = {r=0, g=0, b=0, a=0}

-- 输入框边框颜色/透明度 (a是透明度,白色请改成 {r=1, g=1, b=1, a=0.8})
local BorderColor = {r=0, g=0, b=0, a=0}

-- 输入框字体大小
fontsize = 14

-- 打开输入框回到上次对话 (1/0 = On/Off)
ChatTypeInfo["SAY"].sticky  = 1; -- 说
ChatTypeInfo["PARTY"].sticky 	= 1; -- 小队
ChatTypeInfo["GUILD"].sticky 	= 1; -- 公会
ChatTypeInfo["WHISPER"].sticky 	= 0; -- 密语 
ChatTypeInfo["BN_WHISPER"].sticky = 0; -- 战网好友密语
ChatTypeInfo["RAID"].sticky 	= 1; -- 团队
ChatTypeInfo["OFFICER"].sticky 	= 1; -- 官员
ChatTypeInfo["CHANNEL"].sticky 	= 1; -- 频道

-- 聊天标签
CHAT_FRAME_FADE_OUT_TIME = 2 -- 聊天窗口褪色时间
CHAT_TAB_HIDE_DELAY = 0      -- 聊天标签弹出延时
CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 0.4   -- 鼠标停留时,标签透明度
CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0       -- 鼠标离开时,标签透明度 (修改这里能一直显示)
CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 0.6   -- 鼠标停留时,选择标签时透明度
CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0     -- 鼠标离开时,选择标签时透明度
CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 0.4 -- 鼠标停留时,标签闪动时透明度
CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 0     -- 鼠标离开时,标签闪动时透明度

-- 阴影/轮廓
outline = false
dropshadow = true

-- 字体
font = ChatFontNormal:GetFont()

-----------------------------------------------------------------------------
BNToastFrame:SetClampedToScreen(true)

local addon, ns = ...
ns.QQChat = {}
QQChat = ns.QQChat
local i
--=========================================================================--
btexture = "Interface\\AddOns\\QQChat\\media\\blank"
etexture = "Interface\\AddOns\\QQChat\\media\\glowtex"

local tabs = {"Left", "Middle", "Right", "SelectedLeft", "SelectedRight",
    "SelectedMiddle", "Glow",}

for i = 1, NUM_CHAT_WINDOWS do
    local editbox = _G['ChatFrame'..i..'EditBox']
    local editboxLanguage = _G['ChatFrame'..i..'EditBoxLanguage']
    local tex=({_G["ChatFrame"..i.."EditBox"]:GetRegions()})
    local resize = _G["ChatFrame"..i.."ResizeButton"]
    local cf = _G['ChatFrame'..i];
	
	_G["ChatFrame"..i.."TabText"]:SetTextColor(.9,.8,.5)
	_G["ChatFrame"..i.."TabText"].SetTextColor = function() end
	_G["ChatFrame"..i.."TabText"]:SetFont(GameFontNormal:GetFont(), 16)
	_G["ChatFrame"..i.."TabText"]:SetShadowOffset(1.5, -1.5)

	-- 输入框
    editbox:SetAltArrowKeyMode(false)
	editbox:EnableMouse(false)
    editbox:ClearAllPoints()
	editboxLanguage:Hide()
	editboxLanguage.Show = function()  end
    if editboxtop==true then
        editbox:SetPoint('BOTTOMLEFT', _G.ChatFrame1, 'TOPLEFT', -3, 39)
        editbox:SetPoint('BOTTOMRIGHT', _G.ChatFrame1, 'TOPRIGHT', 3, 39)
        editbox:SetPoint('TOPLEFT', _G.ChatFrame1, 'TOPLEFT', -3, 63)
        editbox:SetPoint('TOPRIGHT', _G.ChatFrame1, 'TOPRIGHT', 3, 63)
    else
        editbox:SetPoint('TOPLEFT', _G.ChatFrame1, 'BOTTOMLEFT', -4, -2)
        editbox:SetPoint('TOPRIGHT', _G.ChatFrame1, 'BOTTOMRIGHT', 4, -2)
        editbox:SetPoint('BOTTOMLEFT', _G.ChatFrame1, 'BOTTOMLEFT', -4, -26)
        editbox:SetPoint('BOTTOMRIGHT', _G.ChatFrame1, 'BOTTOMRIGHT', 4, -26)
    end

    editbox:SetShadowOffset(1, -1)
    editbox:SetFont(font, fontsize)
    editbox:SetBackdrop({bgFile = btexture, edgeFile = etexture, edgeSize = 2, insets = {top = 1, left = 1, bottom = 1 ,right = 1}})
    editbox:SetBackdropColor(BackdropColor.r,BackdropColor.g,BackdropColor.b,BackdropColor.a)
    editbox:SetBackdropBorderColor(BorderColor.r,BorderColor.g,BorderColor.b,BorderColor.a)	
    tex[6]:SetAlpha(0) tex[7]:SetAlpha(0) tex[8]:SetAlpha(0) tex[9]:SetAlpha(0) tex[10]:SetAlpha(0) tex[11]:SetAlpha(0)
	
    cf:SetMinResize(0,0)
	cf:SetMaxResize(0,0)
    cf:SetFading(show)					
	cf:SetClampRectInsets(0,0,0,0)
    cf:SetClampedToScreen(nil)
    cf:SetFrameStrata("LOW")	
	if not cfshadow then
	local cfshadow = CreateFrame("Frame", "$parentshadow", cf)
	cfshadow:SetFrameLevel(0)
	cfshadow:ClearAllPoints()
	cfshadow:SetPoint("LEFT",cf,"LEFT",-4,0)
	cfshadow:SetPoint("TOP",cf,"TOP",0,5)
	cfshadow:SetPoint("RIGHT",cf,"RIGHT",4,0)
	cfshadow:SetPoint("BOTTOM",cf,"BOTTOM",0,-5)
    cfshadow:SetBackdrop({bgFile = btexture, edgeFile = etexture, edgeSize = 3, insets = {top = 1, left = 1, bottom = 1, right = 1}})
    cfshadow:SetBackdropColor(BackdropColor.r,BackdropColor.g,BackdropColor.b,BackdropColor.a)
    cfshadow:SetBackdropBorderColor(BorderColor.r,BorderColor.g,BorderColor.b,BorderColor.a)
	end

	-- 隐藏聊天标签选择时背景
   _G["ChatFrame"..i.."TabSelectedMiddle"]:SetTexture(nil)
   _G["ChatFrame"..i.."TabSelectedRight"]:SetTexture(nil)
   _G["ChatFrame"..i.."TabSelectedLeft"]:SetTexture(nil)

	-- 聊天框缩放按钮
    resize:SetPoint("BOTTOMRIGHT", cf, "BOTTOMRIGHT", 5,-9) 
    --resize:SetScale(.5)  --大小
    --resize:SetAlpha(.5)  --透明度

	-- 聊天标签背景
	if hide_chattab_backgrounds then
		for index, value in pairs(tabs) do
			local texture = _G['ChatFrame'..i..'Tab'..value]
			texture:SetTexture(nil)
		end
	end

	-- 聊天框背景
	if hide_chatframe_backgrounds then
		for g = 1, #CHAT_FRAME_TEXTURES do
		_G["ChatFrame"..i..CHAT_FRAME_TEXTURES[g]]:SetTexture(nil)
		end
	end
	
	-- 轮廓/阴影
    if (outline==true) then
        cf:SetFont(font, fontsize, "OUTLINE")
        cf:SetShadowOffset(0, 0)
	elseif (dropshadow==true) then
        cf:SetFont(font, fontsize)
        cf:SetShadowOffset(1, -1)
	else
        cf:SetFont(font, fontsize)
        cf:SetShadowOffset(0, 0)
    end
end

----------------------按住CTRL翻页 顶/底-按住SHFIT 翻3行------------------------------
FloatingChatFrame_OnMouseScroll = function(self, dir)
  if(dir > 0) then
    if(IsControlKeyDown()) then
      self:ScrollToTop()
    elseif IsShiftKeyDown() then
      self:ScrollUp()
      self:ScrollUp()
      self:ScrollUp()
    else
     self:ScrollUp()
    end
else
    if(IsControlKeyDown()) then
      self:ScrollToBottom()
    elseif IsShiftKeyDown() then
      self:ScrollDown()
      self:ScrollDown()
      self:ScrollDown()
    else
      self:ScrollDown()
    end
  end
end

-------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
----==TabChangeChannel 按TAB切換頻道.如果是在密語頻道則循環前面密過的人名==--

function ChatEdit_CustomTabPressed(self)
	if strsub(tostring(self:GetText()), 1, 1) == "/" then return end

	if  (self:GetAttribute("chatType") == "SAY")  then
		if ((not IsInRaid()) and GetNumGroupMembers()>0) then
			self:SetAttribute("chatType", "PARTY");
			ChatEdit_UpdateHeader(self);
		elseif (IsInRaid() and GetNumGroupMembers()) then
			self:SetAttribute("chatType", "RAID");
			ChatEdit_UpdateHeader(self);
		elseif (GetNumBattlefieldScores()>0) then
			self:SetAttribute("chatType", "BATTLEGROUND");
			ChatEdit_UpdateHeader(self);
		elseif (IsInGuild()) then
			self:SetAttribute("chatType", "GUILD");
			ChatEdit_UpdateHeader(self);
		else
			return;
		end
	elseif (self:GetAttribute("chatType") == "PARTY") then
		if (IsInRaid() and GetNumGroupMembers()) then
			self:SetAttribute("chatType", "RAID");
			ChatEdit_UpdateHeader(self);
		elseif (GetNumBattlefieldScores()>0) then
			self:SetAttribute("chatType", "BATTLEGROUND");
			ChatEdit_UpdateHeader(self);
		elseif (IsInGuild()) then
			self:SetAttribute("chatType", "GUILD");
			ChatEdit_UpdateHeader(self);
		else
			self:SetAttribute("chatType", "SAY");
			ChatEdit_UpdateHeader(self);
		end			
	elseif (self:GetAttribute("chatType") == "RAID") then
		if (GetNumBattlefieldScores()>0) then
			self:SetAttribute("chatType", "BATTLEGROUND");
			ChatEdit_UpdateHeader(self);
		elseif (IsInGuild()) then
			self:SetAttribute("chatType", "GUILD");
			ChatEdit_UpdateHeader(self);
		else
			self:SetAttribute("chatType", "SAY");
			ChatEdit_UpdateHeader(self);
		end
	elseif (self:GetAttribute("chatType") == "BATTLEGROUND") then
		if (IsInGuild) then
			self:SetAttribute("chatType", "GUILD");
			ChatEdit_UpdateHeader(self);
		else
			self:SetAttribute("chatType", "SAY");
			ChatEdit_UpdateHeader(self);
		end
	elseif (self:GetAttribute("chatType") == "GUILD") then
		self:SetAttribute("chatType", "SAY");
		ChatEdit_UpdateHeader(self);
	end
end

-----------------------------------------------聊天复制------------------------------------
local _AddMessage = ChatFrame1.AddMessage
local _SetItemRef = SetItemRef
local blacklist = {
	[ChatFrame2] = true,
}

local ts = '|cff68ccef|HyCopy|h%s|h|r %s'
local AddMessage = function(self, text, ...)
	if(type(text) == 'string') then
        if showtime then
          text = format(ts, date'%H:%M', text)  --text = format(ts, date'%H:%M:%S', text)
        else
	  text = format(ts, '★', text)
       end
end

	return _AddMessage(self, text, ...)
end

for i=1, NUM_CHAT_WINDOWS do
	local cf = _G['ChatFrame'..i]
	if(not blacklist[cf]) then
		cf.AddMessage = AddMessage
	end
end

local MouseIsOver = function(frame)
	local s = frame:GetParent():GetEffectiveScale()
	local x, y = GetCursorPosition()
	x = x / s
	y = y / s

	local left = frame:GetLeft()
	local right = frame:GetRight()
	local top = frame:GetTop()
	local bottom = frame:GetBottom()

	if(not left) then
		return
	end

	if((x > left and x < right) and (y > bottom and y < top)) then
		return 1
	else
		return
	end
end

local borderManipulation = function(...)
	for l = 1, select('#', ...) do
		local obj = select(l, ...)
		if(obj:GetObjectType() == 'FontString' and MouseIsOver(obj)) then
			return obj:GetText()
		end
	end
end

local eb = ChatFrame1EditBox
SetItemRef = function(link, text, button, ...)
	if(link:sub(1, 5) ~= 'yCopy') then return _SetItemRef(link, text, button, ...) end

	local text = borderManipulation(SELECTED_CHAT_FRAME:GetRegions())
	if(text) then
		text = text:gsub('|c%x%x%x%x%x%x%x%x(.-)|r', '%1')
		text = text:gsub('|H.-|h(.-)|h', '%1')

		eb:Insert(text)
		eb:Show()
		eb:HighlightText()
		eb:SetFocus()
	end
end

----------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
local eventcount = 0 
local a = CreateFrame("Frame") 
a:RegisterAllEvents() 
a:SetScript("OnEvent", function(self, event) 
   eventcount = eventcount + 1 
   if InCombatLockdown() then return end 
   if eventcount > 6000 or event == "PLAYER_ENTERING_WORLD" then 
      collectgarbage("collect") 
      eventcount = 0 
   end 
end) 
