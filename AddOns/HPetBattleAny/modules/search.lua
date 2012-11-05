-----####Search1.3####
local _
--~ Globals
local _G = getfenv(0)
local hooksecurefunc, tinsert, pairs, wipe = _G.hooksecurefunc, _G.table.insert, _G.pairs, _G.wipe
local ipairs = _G.ipairs
local C_PetJournal = _G.C_PetJournal
--~ --------
local L = HPetLocals

local function Qstringfind(strm,strf)
	local strf1=strf[1]
	local strf2=strf[2]
	local strf3=strf[3]
	local str1={}	---查找词组
	local str2={}	---查找词组中排除词组 "/"
	local str3={}	---排除词组 "-"

	if strf1 then
		while strf1 and strf1~="" do
			local strt=""
			strt,strf1=strf1:match("^%s*(%S*)%s*(.-)$")
			str1[strt]=0
		end
	end

	if strf2 then
		while strf2 and strf2~="" do
			local strt=""
			strt,strf2=strf2:match("^%s*(%S*)%s*(.-)$")
			str2[strt]=0
		end
	end

	if strf3 then
		while strf3~="" do
			local strt=""
			strt,strf3=strf3:match("^%s*(%S*)%s*(.-)$")

			str3[strt]=0
		end
	end

	local result=""

	for index=1,6 do

		for i,_ in pairs(str3) do
			if strm[index] and string.find(strm[index],i)~=nil then
				return false
			end
		end

		local btmp=true
		for i,_ in pairs(str2) do
			if strm[index] and string.find(strm[index],i)~=nil then
				btmp=false
			end
		end

		if strm[index] and btmp then result=result..strm[index] end

	end

	for i,_ in pairs(str1) do
		if string.find(result,i)==nil then return false end
	end


	return true
end


function HPetBattleAny:Search(command,rest)
	local stemp=GetZoneText()
	local tmp1=""
	local tmp2=""
	if rest ~= "" then stemp=rest end

	local serachtemp={}
	serachtemp[1],serachtemp[3]=string.split("-",stemp)
	serachtemp[1],serachtemp[2]=string.split("/",serachtemp[1])
	if serachtemp[1]~="" then
		if serachtemp[3] and serachtemp[3]~="" then
			self:PetPrintEX(L["search key"]..serachtemp[1]:match"^%s*(.-)$"..","..L["search remove key"]..serachtemp[3]:match"^%s*(.-)$")
		else
			self:PetPrintEX(L["search key"]..serachtemp[1]:match"^%s*(.-)$")
		end
	end

	for i=1,C_PetJournal.GetNumPets(false) do
		local petID,speciesID,isOwned, _, _, _, _, name, _, _, _, sourceText=C_PetJournal.GetPetInfoByIndex(i)
		if command=="s" then
			if serachtemp and string.find(sourceText,serachtemp[1]) then
				if isOwned then
					tmp1=tmp1..self.CreateLinkByInfo(petID or 0, 0)
				else
					tmp2=tmp2.."\124cffffff00\124Hbattlepet:"..speciesID..":0:0:0:0:0\124h["..name.."]\124h\124r"
				end
			end
		else
			local strm={}
			for j=1,6 do
				local abilityID=C_PetJournal.GetPetAbilityList(speciesID)[j]
				if not abilityID then break end
				local _,st1,_,_,st2,_,st3=C_PetBattles.GetAbilityInfoByID(abilityID)
				strm[j]=st1..st2.._G["BATTLE_PET_NAME_"..st3]
			end
			if (serachtemp and Qstringfind(strm,serachtemp)) then
				if isOwned then
					tmp1=tmp1..self.CreateLinkByInfo(petID or 0, 0)
				else
					tmp2=tmp2.."\124cffffff00\124Hbattlepet:"..speciesID..":0:0:0:0:0\124h["..name.."]\124h\124r"
				end
			end
		end
	end
	self:PetPrintEX(COLLECTED..":"..tmp1)
	self:PetPrintEX(NOT_COLLECTED..":"..tmp2)
end
