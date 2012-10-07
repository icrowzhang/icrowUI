-- code from EUI, thanks to dtzy @ ngacn.cc
local CH = QQChat
local L = CH.L

local cfg = { -- 设置
	font = "Fonts\\Semplice.ttf",								-- 字体
	fontsize = 8,												-- 文字大小
	fontflag = "MONOCHROMEOUTLINE",								-- 文字描边
	buttonsize = 16,											-- 按钮大小(参考值: 16)
	margin = 4,													-- 间距(参考值: 横排为4, 竖排为0)
	vertical = false,											-- 是否竖排, true为竖排, false为横排
	point = {'TOPLEFT', _G.ChatFrame1, 'TOPLEFT', 10, 43},		-- 位置(参考值: 'TOPLEFT', _G.ChatFrame1, 'TOPLEFT', 10, 43)
}

local children = {}
QQChatDB = QQChatDB or {}
QQChatDB.autojoin = QQChatDB.autojoin or false

local function place(frame, index, anchor)
	if cfg.vertical then
		frame:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", 0, (index == 1) and -45 or -(45 + (index - 1) * (cfg.buttonsize + cfg.margin)))
	else
		frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", (index == 1) and 5 or (5 + (index - 1) * (cfg.buttonsize + cfg.margin)), 0)
	end
end

local function CannelButton(parent, position, order, text, color)
	local f = CreateFrame("Button", nil, parent);
	f:SetFrameLevel(parent:GetFrameLevel()+1)
	f:SetSize(cfg.buttonsize, cfg.buttonsize);
	place(f, position, parent)
	f:RegisterForClicks("AnyUp");
	f:SetScript("OnClick", function() ChatFrame_OpenChat(order, SELECTED_DOCK_FRAME) end)
	
	f.text = f:CreateFontString(nil, 'OVERLAY')
	f.text:SetFont(cfg.font, cfg.fontsize, cfg.fontflag)
	f.text:SetText(text)
	f.text:SetPoint("CENTER", 0, 0)	
	f.text:SetTextColor(unpack(color))
	
	tinsert(children, f)
end

function CH:LoadChatbar()
	local chat = CreateFrame("Frame", "ChatBar", UIParent)
	chat:SetPoint(unpack(cfg.point))
	chat:SetWidth(_G.ChatFrame1:GetWidth()+5)
	chat:SetHeight(_G.ChatFrame1:GetHeight()+43)
	chat:SetFrameStrata("LOW")
	chat:SetFrameLevel(0)
	CH.chatbar = chat
	
	-- "队伍(/p)" --
	CannelButton(self.chatbar, 1, "/p ", "P", {170/255, 170/255, 255/255})
	-- "公会(/g)" --
	CannelButton(self.chatbar, 2, "/g ", "G", {64/255, 255/255, 64/255})
	-- "团队(/raid)" --
	CannelButton(self.chatbar, 3, "/raid ", "R", {255/255, 137/255, 0})
	-- "大脚世界频道(/5)" --
	CannelButton(self.chatbar, 4, "/5 ", "5", {213/255, 180/255, 140/255})
	-- "战场(/BG)" -- 
	CannelButton(self.chatbar, 5, "/BG ", "B", {255/255, 137/255, 0})
	
	-- ROLL点
	local roll = CreateFrame("Button", "rollMacro", UIParent, "SecureActionButtonTemplate")
	roll:SetAttribute("*type*", "macro")
	roll:SetAttribute("macrotext", "/roll")
	roll:SetParent(self.chatbar)
	roll:SetWidth(16);
	roll:SetHeight(16);
	place(roll, 8, self.chatbar)
	
	roll.text = roll:CreateFontString(nil, 'OVERLAY')
	roll.text:SetFont(cfg.font, cfg.fontsize, cfg.fontflag)
	roll.text:SetText("R")
	roll.text:SetPoint("CENTER", 0, 0)
	roll.text:SetTextColor(23/255, 132/255, 209/255)
	
	tinsert(children, roll)
	
	-- 角色属性通报
	local statreport = CreateFrame("Button", nil, self.chatbar);
	statreport:SetWidth(16);
	statreport:SetHeight(16);
	place(statreport, 7, self.chatbar);
	statreport:RegisterForClicks("AnyUp");
	statreport:SetScript("OnClick", function() CH:SendReport() end)
	
	statreport.text = statreport:CreateFontString(nil, 'OVERLAY')
	statreport.text:SetFont(cfg.font, cfg.fontsize, cfg.fontflag)
	statreport.text:SetText("S")
	statreport.text:SetPoint("CENTER", 0, 0)	
	statreport.text:SetTextColor(23/255, 132/255, 209/255)
	
	statreport:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self, 'ANCHOR_TOP', 0, 6)
		GameTooltip:AddLine(CH.L.INFO_DURABILITY_TIP)
		GameTooltip:Show() 
	end)
	statreport:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	tinsert(children, statreport)
	
	if (GetLocale() == "zhCN" or GetLocale == "zhTW") then
		-- 大脚世界频道
		local big = CreateFrame("Button", "Bigfootcannel", self.chatbar)
		place(big, 9, self.chatbar)
		big:SetSize(16, 16)
		big:RegisterForClicks("AnyDown")
		
		big.text = big:CreateFontString(nil, 'OVERLAY')
		big.text:SetFont(cfg.font, cfg.fontsize, cfg.fontflag)
		big.text:SetText("BF")
		big.text:SetPoint("CENTER", 0, 0)
		
		if QQChatDB.autojoin then
			big.text:SetTextColor(23/255, 132/255, 209/255)
		else
			big.text:SetTextColor(.5, .5, .5)
		end
		big:SetScript("OnClick", function(self)
			if QQChatDB.autojoin ~= true then
				JoinTemporaryChannel(L["BigFootChannel"])
				ChatFrame_RemoveChannel(DEFAULT_CHAT_FRAME, L["BigFootChannel"])
				ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, L["BigFootChannel"])	
				QQChatDB.autojoin = true
				self.text:SetTextColor(23/255, 132/255, 209/255)
			else
				SlashCmdList["LEAVE"](L["BigFootChannel"])
				QQChatDB.autojoin = false
				self.text:SetTextColor(.5, .5, .5)
			end
		end)
		big:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_TOP', 0, 6)
			GameTooltip:AddLine(L["Enable/Disable"].. ' '..L["Auto join BigFootChannel"])
			GameTooltip:Show()
		end)
		big:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
		tinsert(children, big)
		
		-- 表情
		local Emote = CH.ChatEmote;
		local ChatEmote = CreateFrame("Button", nil, self.chatbar)
		place(ChatEmote, 6, self.chatbar)
		ChatEmote:SetSize(16, 16)
		ChatEmote:SetScript("OnClick", function() Emote.ToggleEmoteTable() end)
		
		ChatEmote.text = ChatEmote:CreateFontString(nil, 'OVERLAY')
		ChatEmote.text:SetFont(cfg.font, cfg.fontsize, cfg.fontflag)
		ChatEmote.text:SetPoint("CENTER", 0, 0)
		ChatEmote.text:SetText("E")
		ChatEmote.text:SetTextColor(23/255, 132/255, 209/255)
		ChatEmote:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_TOP', 0, 6)
			GameTooltip:AddLine(Emote.tipstr)
			GameTooltip:Show()
		end)
		ChatEmote:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
		tinsert(children, ChatEmote)
	end
end

function CH:SmileyFilter(event, msg, ...)
	msg = CH:InsertEmotions(msg)
	return false, msg, ...
end

local eventframe = CreateFrame("Frame", nil, UIParent)
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	CH:LoadChatEmote()
	CH:LoadChatbar()
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", CH.SmileyFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", CH.SmileyFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", CH.SmileyFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", CH.SmileyFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", CH.SmileyFilter)	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", CH.SmileyFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", CH.SmileyFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", CH.SmileyFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", CH.SmileyFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", CH.SmileyFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", CH.SmileyFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", CH.SmileyFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", CH.SmileyFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION", CH.SmileyFilter)	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", CH.SmileyFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", CH.SmileyFilter)
end)