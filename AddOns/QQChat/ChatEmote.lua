-- code from EUI, thanks to dtzy @ ngacn.cc
local M = icrowMedia
local CH = QQChat
local i

local ChatEmote = {}
ChatEmote.Config = {
	iconSize = 24,
}
if (GetLocale() == "zhCN") then
	ChatEmote.tipstr = "点击打开聊天表情框" --Click to open emoticon frame
elseif (GetLocale() == "zhTW") then
	ChatEmote.tipstr = "點擊打開聊天表情框"
else
	ChatEmote.tipstr = "Click to open emoticon frame"
end
local customEmoteStartIndex = 9

local emotes = {
	{"{rt1}",	[=[Interface\TargetingFrame\UI-RaidTargetingIcon_1]=]},
	{"{rt2}",	[=[Interface\TargetingFrame\UI-RaidTargetingIcon_2]=]},
	{"{rt3}",	[=[Interface\TargetingFrame\UI-RaidTargetingIcon_3]=]},
	{"{rt4}",	[=[Interface\TargetingFrame\UI-RaidTargetingIcon_4]=]},
	{"{rt5}",	[=[Interface\TargetingFrame\UI-RaidTargetingIcon_5]=]},
	{"{rt6}",	[=[Interface\TargetingFrame\UI-RaidTargetingIcon_6]=]},
	{"{rt7}",	[=[Interface\TargetingFrame\UI-RaidTargetingIcon_7]=]},
	{"{rt8}",	[=[Interface\TargetingFrame\UI-RaidTargetingIcon_8]=]},
	{"{天使}",	[=[Interface\Addons\QQChat\media\Angel]=]},
	{"{生气}",	[=[Interface\Addons\QQChat\media\Angry]=]},

	{"{大笑}",	[=[Interface\Addons\QQChat\media\Biglaugh]=]},
	{"{鼓掌}",	[=[Interface\Addons\QQChat\media\Clap]=]},
	{"{酷}",	[=[Interface\Addons\QQChat\media\Cool]=]},
	{"{哭}",	[=[Interface\Addons\QQChat\media\Cry]=]},
	{"{可爱}",	[=[Interface\Addons\QQChat\media\Cutie]=]},
	{"{鄙视}",	[=[Interface\Addons\QQChat\media\Despise]=]},
	{"{美梦}",	[=[Interface\Addons\QQChat\media\Dreamsmile]=]},
	{"{尴尬}",	[=[Interface\Addons\QQChat\media\Embarrass]=]},
	{"{邪恶}",	[=[Interface\Addons\QQChat\media\Evil]=]},
	{"{兴奋}",	[=[Interface\Addons\QQChat\media\Excited]=]},

	{"{晕}",	[=[Interface\Addons\QQChat\media\Faint]=]},
	{"{打架}",	[=[Interface\Addons\QQChat\media\Fight]=]},
	{"{流感}",	[=[Interface\Addons\QQChat\media\Flu]=]},
	{"{呆}",	[=[Interface\Addons\QQChat\media\Freeze]=]},
	{"{皱眉}",	[=[Interface\Addons\QQChat\media\Frown]=]},
	{"{致敬}",	[=[Interface\Addons\QQChat\media\Greet]=]},
	{"{鬼脸}",	[=[Interface\Addons\QQChat\media\Grimace]=]},
	{"{龇牙}",	[=[Interface\Addons\QQChat\media\Growl]=]},
	{"{开心}",	[=[Interface\Addons\QQChat\media\Happy]=]},
	{"{心}",	[=[Interface\Addons\QQChat\media\Heart]=]},

	{"{恐惧}",	[=[Interface\Addons\QQChat\media\Horror]=]},
	{"{生病}",	[=[Interface\Addons\QQChat\media\Ill]=]},
	{"{无辜}",	[=[Interface\Addons\QQChat\media\Innocent]=]},
	{"{功夫}",	[=[Interface\Addons\QQChat\media\Kongfu]=]},
	{"{花痴}",	[=[Interface\Addons\QQChat\media\Love]=]},
	{"{邮件}",	[=[Interface\Addons\QQChat\media\Mail]=]},
	{"{化妆}",	[=[Interface\Addons\QQChat\media\Makeup]=]},
	{"{马里奥}",	[=[Interface\Addons\QQChat\media\Mario]=]},
	{"{沉思}",	[=[Interface\Addons\QQChat\media\Meditate]=]},
	{"{可怜}",	[=[Interface\Addons\QQChat\media\Miserable]=]},

	{"{好}",	[=[Interface\Addons\QQChat\media\Okay]=]},
	{"{漂亮}",	[=[Interface\Addons\QQChat\media\Pretty]=]},
	{"{吐}",	[=[Interface\Addons\QQChat\media\Puke]=]},
	{"{握手}",	[=[Interface\Addons\QQChat\media\Shake]=]},
	{"{喊}",	[=[Interface\Addons\QQChat\media\Shout]=]},
	{"{闭嘴}",	[=[Interface\Addons\QQChat\media\Shuuuu]=]},
	{"{害羞}",	[=[Interface\Addons\QQChat\media\Shy]=]},
	{"{睡觉}",	[=[Interface\Addons\QQChat\media\Sleep]=]},
	{"{微笑}",	[=[Interface\Addons\QQChat\media\Smile]=]},
	{"{吃惊}",	[=[Interface\Addons\QQChat\media\Suprise]=]},

	{"{失败}",	[=[Interface\Addons\QQChat\media\Surrender]=]},
	{"{流汗}",	[=[Interface\Addons\QQChat\media\Sweat]=]},
	{"{流泪}",	[=[Interface\Addons\QQChat\media\Tear]=]},
	{"{悲剧}",	[=[Interface\Addons\QQChat\media\Tears]=]},
	{"{想}",	[=[Interface\Addons\QQChat\media\Think]=]},
	{"{偷笑}",	[=[Interface\Addons\QQChat\media\Titter]=]},
	{"{猥琐}",	[=[Interface\Addons\QQChat\media\Ugly]=]},
	{"{胜利}",	[=[Interface\Addons\QQChat\media\Victory]=]},
	{"{雷锋}",	[=[Interface\Addons\QQChat\media\Volunteer]=]},
	{"{委屈}",	[=[Interface\Addons\QQChat\media\Wronged]=]},
}

CH.emotes = emotes

local ShowEmoteTableButton
local EmoteTableFrame

local function CreateEmoteTableFrame()
	EmoteTableFrame = CreateFrame("Frame", "EmoteTableFrame", UIParent)
	M.CreateBG(EmoteTableFrame)
	M.CreateSD(EmoteTableFrame)
	EmoteTableFrame:SetWidth((ChatEmote.Config.iconSize+2) * 12+4)
	EmoteTableFrame:SetHeight((ChatEmote.Config.iconSize+2) * 5+4)
	EmoteTableFrame:SetPoint("BOTTOMLEFT", _G.ChatFrame1, "TOPLEFT", 0, 65)
	EmoteTableFrame:Hide()
	EmoteTableFrame:SetFrameStrata("DIALOG")

	local icon, row, col
	row = 1
	col = 1
	for i=1,#emotes do 
		text = emotes[i][1]
		texture = emotes[i][2]
		icon = CreateFrame("Frame", format("IconButton%d",i), EmoteTableFrame)
		icon:SetWidth(ChatEmote.Config.iconSize)
		icon:SetHeight(ChatEmote.Config.iconSize)
		icon.text = text
		icon.texture = icon:CreateTexture(nil,"ARTWORK")
		icon.texture:SetTexture(texture)
		icon.texture:SetAllPoints(icon)
		icon:Show()
		icon:SetPoint("TOPLEFT", (col-1)*(ChatEmote.Config.iconSize+2)+2, -(row-1)*(ChatEmote.Config.iconSize+2)-2)
		icon:SetScript("OnMouseUp", ChatEmote.EmoteIconMouseUp)
		icon:EnableMouse(true)
		col = col + 1 
		if (col>12) then
			row = row + 1
			col = 1
		end
	end
end

function ChatEmote.ToggleEmoteTable()
	if (not EmoteTableFrame) then CreateEmoteTableFrame() end
	if (EmoteTableFrame:IsShown()) then
		EmoteTableFrame:Hide()
	else
		EmoteTableFrame:Show()
	end
end

function ChatEmote.EmoteIconMouseUp(frame, button)
	if (button == "LeftButton") then
		local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
		if (not ChatFrameEditBox:IsShown()) then
			ChatEdit_ActivateChat(ChatFrameEditBox)
		end
		ChatFrameEditBox:Insert(frame.text)
	end
	ChatEmote.ToggleEmoteTable()
end

function CH:LoadChatEmote()
	CH.ChatEmote = ChatEmote
	if (GetLocale() ~= "zhCN" and GetLocale ~= "zhTW") then return; end
	CreateEmoteTableFrame()
end

function CH:InsertEmotions(msg)
	if (GetLocale() == "zhCN" or GetLocale() == "zhTW") then
		for k, v in pairs(self.emotes) do
			msg = string.gsub(msg, v[1], "|T"..v[2]..":16|t");
		end
	end	
	return msg;
end