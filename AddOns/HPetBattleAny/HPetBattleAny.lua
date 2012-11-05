-----####HPetBattleAny1.1####
local _
--- Globals
local _G = getfenv(0)
local hooksecurefunc, tinsert, pairs, wipe = _G.hooksecurefunc, _G.table.insert, _G.pairs, _G.wipe
local ipairs = _G.ipairs
local C_PetJournal = _G.C_PetJournal
--- --------
local VERSION = "v1.0"
local H_PET_BATTLE_CHAT_FRAME={}
local LEVEL_COLLECTED = "(lv:%s)"
local L = HPetLocals


if GetLocale()=="zhCN" then
	PET_BATTLE_COMBAT_LOG_AURA_APPLIED ="%1$s对%3$s %4$s 造成了%2$s效果."
	PET_BATTLE_COMBAT_LOG_PAD_AURA_APPLIED = "%1$s对%3$s 造成了%2$s效果."
end

HPetBattleAny = CreateFrame("frame");
HPetBattleAny:SetScript('OnEvent', function(_, event, ...) return HPetBattleAny[event](HPetBattleAny, event, ...) end)

function HPetBattleAny:PlaySoundFile()
------- 这里可以修改声音文件
	PlaySoundFile( [[Sound\Events\scourge_horn.wav]], "Master" );
end
function HPetBattleAny:Loadinginfo()
	--self:PetPrintEX(format("HPetBattleAny"..VERSION..L["Loading"],"|cffff0000/hpq|r"))
end
--------------------		SAVE
HPetSaves = {}
function HPetBattleAny:GetDefault()
	return {
		ShowMsg = true,				--在聊天窗口显示信息
		Sound=true,
		ShowGrowInfo=true,			--显示成长值
		PetGreedInfo=false,			--显示品值
		EnemyAbility=true,			--显示敌对技能
		EnemyAbPoint={},			--位置(nil)
		EnemyAbScale=0.8,			--敌对技能大小
		OnlyInPetInfo=false,
		HighGlow=false,				--战斗中用品质颜色对宠物头像着色
	}
end

HPetSaves = HPetBattleAny:GetDefault()

--------------------		载入宠物手册的数据
HPetBattleAny.HasPet={}

--[[		function	]]--
-----	测试函数
function printt(str)
	if HPetSaves.god then
		print(str)
	end
end

function HPetBattleAny.sortRarityLevelAsc(a, b)
	if a.rarity == b.rarity then
		return a.level < b.level
	else
		return a.rarity < b.rarity
	end
end
-----	却确定宠物信息窗口
function HPetBattleAny:GetPetBattleChatFrmae()
	wipe(H_PET_BATTLE_CHAT_FRAME)
	H_PET_BATTLE_CHAT_FRAME={}
	if HPetSaves.OnlyInPetInfo then
		for _, chatFrameName in pairs(CHAT_FRAMES) do
			local frame = _G[chatFrameName];
			for index = #frame.messageTypeList,1,-1 do
				if frame.messageTypeList[index] == "PET_BATTLE_COMBAT_LOG" then
					table.insert(H_PET_BATTLE_CHAT_FRAME,frame)
					break
				end
			end
		end
	end
	if #H_PET_BATTLE_CHAT_FRAME==0 then
		table.insert(H_PET_BATTLE_CHAT_FRAME,DEFAULT_CHAT_FRAME)
	end
end
-----	打印函数
function HPetBattleAny:PetPrintEX(str,...)
	HPetBattleAny:GetPetBattleChatFrmae()

	for _,frame in pairs(H_PET_BATTLE_CHAT_FRAME) do
		if not frame:IsShown() then FCF_StartAlertFlash(frame) end
		frame:AddMessage(str,...)
	end

end
-----	创建customName的宠物链接
function HPetBattleAny.CreateLinkByInfo(petid,level,health,power,speed,rarity)
	if petid == 0 then return nil end
	local name = ""
	local speciesID, customName, petlevel= C_PetJournal.GetPetInfoByPetID(petid or 0)
	---将第二个参数作为开关，决定是否显示customName///显示customName的链接无法发送到其他窗口
	if level ~= 0 then customName=nil end

	if speciesID then
		_,health,power,speed,rarity = C_PetJournal.GetPetStats(petid)

		level = petlevel
	else	--没有唯一ID说明petid就是唯一ID
		speciesID = petid
	end

	name = customName or C_PetJournal.GetPetInfoBySpeciesID(speciesID)

	if name then
		local link=""
		rarity = rarity - 1
		link=ITEM_QUALITY_COLORS[rarity].hex.."\124Hbattlepet:"
		link=link..speciesID..":"..level..":"..rarity..":"..health..":"..power..":"..speed..":"..petid
		link=link.."\124h["..(customName or name).."]\124h\124r"
		return link
	end
	return
end

function HPetBattleAny.ShowMaxValue(level,health,power,speed,rarity)
	local level=tonumber(level)
	local power=tonumber(power)
	local speed=tonumber(speed)
	local health=tonumber(health)-100
	local breed = 1
	if HPetSaves.PetGreedInfo then
		breed=tonumber("1."..(rarity-1))
		health=format("%.1f",health/5/level/breed)
	else
		health=format("%.1f",health/level/breed)
	end
	power=format("%.1f",power/level/breed)
	speed=format("%.1f",speed/level/breed)

	if HPetSaves.PetGreedInfo then
		if tonumber(health)>=10 or tonumber(power)>=10 or tonumber(speed)>=10 then
			return health,power,speed,true
		end
	end
	return health,power,speed,false
end

-----	调出宠物收集信息(已有宠物信息)
function HPetBattleAny:GetPetCollectedInfo(pets,enemypet,islink)
	local str1=""
	local str2=""
	if enemypet and enemypet.level then
		if enemypet.level>15 then
			enemypet.level = enemypet.level-1
		end
		if enemypet.level>20 then
			enemypet.level = enemypet.level-1
		end
	end
	if pets then
		table.sort(pets,self.sortRarityLevelAsc)
		if enemypet and self.sortRarityLevelAsc(pets[1],enemypet) then
			str1 = str1.."|cffff0000"..L["Only collected"]	.."：|r"
		else
			str1 = str1.."|cffffff00"..COLLECTED.."：|r"
		end
		for i,petInfo in pairs(pets) do
			local petlink
			local _,custname,_,_,_,_,name=C_PetJournal.GetPetInfoByPetID(petInfo.petID)

			if islink then
				petlink=HPetBattleAny.CreateLinkByInfo(petInfo.petID or 0, 0)
			end

			if not petlink then
				if custname or name then
					petlink=ITEM_QUALITY_COLORS[petInfo.rarity-1].hex..(custname or name).."|r"
				else
					petlink=ITEM_QUALITY_COLORS[petInfo.rarity-1].hex.._G["BATTLE_PET_BREED_QUALITY"..petInfo.rarity].."|r"

				end
			end


			if petlink then
				if LEVEL_COLLECTED then str2 = format(LEVEL_COLLECTED.."%s",petInfo.level,str2) end
				str2 = petlink..str2
				if not islink then str2="|n"..str2 end
			end
		end
	else
		if C_PetBattles.IsPlayerNPC(2) and select(2,C_PetBattles.IsTrapAvailable())>5 and select(2,C_PetBattles.IsTrapAvailable())<9 then
			str1=str1.."|cffffff00".._G["PET_BATTLE_TRAP_ERR_"..select(2,C_PetBattles.IsTrapAvailable())]
		else
			str1=str1.."|cffff0000"..NOT_COLLECTED.."!|r"
		end
	end
	return str1,str2
end


--[[ 	OnEvent:					PET_BATTLE_OPENING_START	]]--
HPetBattleAny.EnemyPetInfo={}
function HPetBattleAny:PET_BATTLE_OPENING_START()
printt("test:战斗开始")
----- 输出敌对宠物的数据
		local FindBlue=false
		petOwner=2
		for petIndex=1, C_PetBattles.GetNumPets(petOwner) do

			local rarity=C_PetBattles.GetBreedQuality(petOwner,petIndex)
			local speciesID=C_PetBattles.GetPetSpeciesID(petOwner,petIndex)
			local mPet=HPetBattleAny.HasPet[speciesID]
			if rarity>3 then
				FindBlue=true
			end

			local level = C_PetBattles.GetLevel(petOwner, petIndex);
			local health = C_PetBattles.GetMaxHealth(petOwner, petIndex);
			if C_PetBattles.IsPlayerNPC(petOwner) then health =format("%.0f",health * 1.2) end
			local power = C_PetBattles.GetPower(petOwner, petIndex);
			local speed = C_PetBattles.GetSpeed(petOwner, petIndex);
			if C_PetBattles.GetAuraInfo(petOwner,petIndex,1) == 239 then speed=format("%.0f",speed/1.5) end
			self.EnemyPetInfo[petIndex]={["level"]=level,["health"]=health,["power"]=power,["speed"]=speed,["rarity"]=rarity}
			tmprint=format(L["this is"],petIndex)
			if select(4,HPetBattleAny.ShowMaxValue(level,health,power,speed,rarity)) then
				tmprint=tmprint..ICON_LIST[ICON_TAG_LIST[strlower(RAID_TARGET_1)]] .. "0|t"
			end
			tmprint=tmprint..HPetBattleAny.CreateLinkByInfo(speciesID,level,health,power,speed,rarity)
			if LEVEL_COLLECTED then tmprint=format("%s"..LEVEL_COLLECTED,tmprint,level) end
			if HPetSaves.Contrast or true then
				local str1,str2 = HPetBattleAny:GetPetCollectedInfo(mPet,{level=level,rarity=rarity},true)
				tmprint = tmprint..str1..str2
			end
			if HPetSaves.ShowMsg then
				HPetBattleAny:PetPrintEX(tmprint)
			end
		end

		if HPetSaves.Sound and FindBlue and C_PetBattles.IsWildBattle() then --C_PetBattles.IsPlayerNPC(2) and select(2,C_PetBattles.IsTrapAvailable())~=7 then
--- 		PlaySoundFile( [[Sound\Event Sounds\Event_wardrum_ogre.wav]], "Master" );
			self:PlaySoundFile()
		end
end


--[[	OnEvent:					PET_JOURNAL_LIST_UPDATE		]]--

function HPetBattleAny:PET_JOURNAL_LIST_UPDATE()
	if (HPetSaves.Contrast or true ) and not self.HasPetloading then
		self:UnregisterEvent("PET_JOURNAL_LIST_UPDATE")
		local _,numPets = C_PetJournal.GetNumPets(false);
		if numPets ~=  self.HasPet.num then
		printt("系统数据:"..numPets.."插件数据"..self.HasPet.num)
			self:LoadUserPetInfo()
		end
		self:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
	end
end
function HPetBattleAny:LoadUserPetInfo()
	printt("test:数据处理.进入判断")
	if HPetBattleAny.HasPetloading then
		return	false
	end
	printt("test:数据处理.开始")
	HPetBattleAny.HasPetloading = true
	wipe(HPetBattleAny.HasPet)
	HPetBattleAny.HasPet.num= 0
	C_PetJournal.ClearSearchFilter();
	C_PetJournal.AddAllPetTypesFilter();
	C_PetJournal.AddAllPetSourcesFilter();
	C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_COLLECTED, true)
	C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_FAVORITES, false)
	for i=1,select(2,C_PetJournal.GetNumPets(true)) do
		local petID, speciesID, isOwned, _,level= C_PetJournal.GetPetInfoByIndex(i);
		if isOwned then
			if not HPetBattleAny.HasPet[speciesID] then HPetBattleAny.HasPet[speciesID]={} end
			local _,_,_,_,rarity = C_PetJournal.GetPetStats(petID)
			HPetBattleAny.HasPet.num = HPetBattleAny.HasPet.num + 1
			table.insert(HPetBattleAny.HasPet[speciesID],{petID=petID,rarity=rarity,level=level})
		end
	end
	HPetBattleAny.HasPetloading = false
	printt("test:数据处理.结束,载入数据"..self.HasPet.num)
end


--[[	OnEvent:	 				ADDON_LOADED			]]--
function HPetBattleAny:ADDON_LOADED(_, name)
		if name == "HPetBattleAny" and not self.initialized then
			self:UnregisterEvent("ADDON_LOADED")
			self.initialized = true
			printt("test:插件载入")

			self:Loadinginfo()
			self.hook:init()
			self:initforJournalFrame()

			self:LoadUserPetInfo()
			self:RegisterEvent("PET_BATTLE_OPENING_START");
			self:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
		end
end



------------------------我是和谐的分割线---------------------------------


function HPetBattleAny:initforJournalFrame()

	button = CreateFrame("Button","HPetInitOpenButton",PetJournal,"UIPanelButtonTemplate")
	button:SetText(L["HPet Options"])
	button:SetHeight(22)
	button:SetWidth(150)
	button:SetPoint("RIGHT", PetJournalFindBattle, "LEFT", -40, 0)
	if IsAddOnLoaded("Aurora") then
		local F, C = unpack(Aurora)
		F.Reskin(button)
	end
	button:SetScript("OnClick",function()
		if HPetOption then
			if not HPetOption.ready then HPetOption:Init() end
			if not HPetOption:IsShown() then HPetOption:Open() else HPetOption:Hide() end
		end
	end)

end

HPetBattleAny:RegisterEvent("ADDON_LOADED")
