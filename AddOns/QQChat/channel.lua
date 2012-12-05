------------====================自定义频道可在(95行-183行)修改==================------------

--精简公共频道 (true/false) (精简/不精简)
local ShortChannel = true
local i
----==============================精简聊天频道,可修改汉字自定义==========================----
if (GetLocale() == "zhTW") then 
 --公会
  CHAT_GUILD_GET = "|Hchannel:GUILD|h[會]|h %s: "
  CHAT_OFFICER_GET = "|Hchannel:OFFICER|h[官]|h %s: "
    
  --团队
  CHAT_RAID_GET = "|Hchannel:RAID|h[團]|h %s: "
  CHAT_RAID_WARNING_GET = "[警告] %s: "
  CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[團長]|h %s: "
  
  --队伍
  CHAT_PARTY_GET = "|Hchannel:PARTY|h[隊]|h %s: "
  CHAT_PARTY_LEADER_GET =  "|Hchannel:PARTY|h[隊長]|h %s: "
  CHAT_PARTY_GUIDE_GET =  "|Hchannel:PARTY|h[向導]|h %s: "

  --战场
  CHAT_INSTANCE_CHAT_GET = "|Hchannel:BATTLEGROUND|h[戰]|h %s: "
  CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:BATTLEGROUND|h[指揮]|h %s: "

  CHAT_FLAG_AFK = "[暫離] "
  CHAT_FLAG_DND = "[勿擾] "
  CHAT_FLAG_GM = "[GM] "

elseif (GetLocale() == "zhCN") then

 --公会
  CHAT_GUILD_GET = "|Hchannel:GUILD|h[会]|h %s: "
  CHAT_OFFICER_GET = "|Hchannel:OFFICER|h[官]|h %s: "
    
  --团队
  CHAT_RAID_GET = "|Hchannel:RAID|h[团]|h %s: "
  CHAT_RAID_WARNING_GET = "[警告] %s: "
  CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[团长]|h %s: "
  
  --队伍
  CHAT_PARTY_GET = "|Hchannel:PARTY|h[队]|h %s: "
  CHAT_PARTY_LEADER_GET =  "|Hchannel:PARTY|h[队长]|h %s: "
  CHAT_PARTY_GUIDE_GET =  "|Hchannel:PARTY|h[向导]:|h %s: "

  --战场
  CHAT_INSTANCE_CHAT_GET = "|Hchannel:BATTLEGROUND|h[战]|h %s: "
  CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:BATTLEGROUND|h[指挥]|h %s: "

  --flags
  CHAT_FLAG_AFK = "[暂离] "
  CHAT_FLAG_DND = "[勿扰] "
  CHAT_FLAG_GM = "[GM] "

else
  CHAT_GUILD_GET = "|Hchannel:GUILD|h[G]|h %s "
  CHAT_OFFICER_GET = "|Hchannel:OFFICER|h[O]|h %s "
  CHAT_RAID_GET = "|Hchannel:RAID|h[RA]|h %s "
  CHAT_RAID_WARNING_GET = "[RW] %s "
  CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[RL]|h %s "
  CHAT_PARTY_GET = "|Hchannel:PARTY|h[P]|h %s "
  CHAT_PARTY_LEADER_GET =  "|Hchannel:PARTY|h[PL]|h %s "
  CHAT_PARTY_GUIDE_GET =  "|Hchannel:PARTY|h[PG]|h %s "
  CHAT_INSTANCE_CHAT_GET = "|Hchannel:BATTLEGROUND|h[BG]|h %s "
  CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:BATTLEGROUND|h[BGL]|h %s "  
  CHAT_FLAG_AFK = "[AFK] "
  CHAT_FLAG_DND = "[DND] "
  CHAT_FLAG_GM = "[GM] "
end

--================================公共频道和自定义频道精简================================--
local gsub = _G.string.gsub
local newAddMsg = {}
local chn, rplc
  if (GetLocale() == "zhCN") then  ---国服
	rplc = {
		"[%1综]",  
		"[%1交]",   
		"[%1防]",   
		"[%1组]",   
		"[%1防]",   
		"[%1募]",
                "[%1世]", 
                "[%1自]",    -- 自定义频道缩写请自行修改
	}

   elseif (GetLocale() == "zhTW") then  ---台服
       rplc = {
		"[%1綜]",          
		"[%1貿]",             
		"[%1防]",             
		"[%1組]",            
		"[%1防]",           
		"[%1募]",
                "[%1世]",  
                "[%1自]",   -- 自定义频道缩写请自行修改
        }
        else
        
	rplc = {
		"[GEN]", 
		"[TR]", 
		"[WD]", 
		"[LD]", 
		"[LFG]", 
		"[GR]",
                "[BFC]", 
                "[CL]",      -- 英文缩写
	}
        end

	chn = {
		"%[%d+%. General.-%]",
		"%[%d+%. Trade.-%]",
		"%[%d+%. LocalDefense.-%]",
		"%[%d+%. LookingForGroup%]",
		"%[%d+%. WorldDefense%]",
		"%[%d+%. GuildRecruitment.-%]",
                "%[%d+%. BigFootChannel.-%]",
                "%[%d+%. CustomChannel.-%]",       -- 自定义频道英文名随便填写
	}

---------------------------------------- 国服 ---------------------------------------------
	local L = GetLocale()
	if L == "zhCN" then
		chn[1] = "%[%d+%. 综合.-%]"
		chn[2] = "%[%d+%. 交易.-%]"
		chn[3] = "%[%d+%. 本地防务.-%]"
		chn[4] = "%[%d+%. 寻求组队%]"
                chn[5] = "%[%d+%. 世界防务%]"	
		chn[6] = "%[%d+%. 公会招募.-%]"
                chn[7] = "%[%d+%. 大脚世界频道.-%]"
                chn[8] = "%[%d+%. 自定义频道.-%]"   -- 请修改频道名对应你游戏里的频道

---------------------------------------- 台服 ---------------------------------------------
        elseif L == "zhTW" then
		chn[1] = "%[%d+%. 綜合.-%]"
		chn[2] = "%[%d+%. 貿易.-%]"
	        chn[3] = "%[%d+%. 本地防務.-%]"
		chn[4] = "%[%d+%. 尋求組隊%]"
		chn[5] = "%[%d+%. 世界防務%]"
		chn[6] = "%[%d+%. 公會招募.-%]"
                chn[7] = "%[%d+%. 大脚世界频道.-%]"
                chn[8] = "%[%d+%. 自定义频道.-%]"   -- 请修改频道名对应你游戏里的频道
	else 
---------------------------------------- 英文 ----------------------------------------------- 
		chn[1] = "%[%d+%. General.-%]"
		chn[2] = "%[%d+%. Trade.-%]"
		chn[3] = "%[%d+%. LocalDefense.-%]"
		chn[4] = "%[%d+%. LookingForGroup%]"
		chn[5] = "%[%d+%. WorldDefense%]"
		chn[6] = "%[%d+%. GuildRecruitment.-%]"
                chn[7] = "%[%d+%. BigFootChannel.-%]"
                chn[8] = "%[%d+%. CustomChannel.-%]"   -- 自定义频道英文名随便填写

	end

local function AddMessage(frame, text, ...)
	for i = 1, 8 do	 -- 对应上面几个频道(如果有9个频道就for i = 1, 9 do)
		text = gsub(text, chn[i], rplc[i])
	end

	text = gsub(text, "%[(%d0?)%. .-%]", "%1.") 
	return newAddMsg[frame:GetName()](frame, text, ...)
end

if ShortChannel then
	for i = 1, 5 do
		if i ~= 2 then 
			local f = _G[format("%s%d", "ChatFrame", i)]
			newAddMsg[format("%s%d", "ChatFrame", i)] = f.AddMessage
			f.AddMessage = AddMessage
		end
	end
end