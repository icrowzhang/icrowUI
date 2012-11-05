local START = 1
local FINISHED = 5
local PETS_PER_TEAM = 3
local MAX_TEAMS = 60
local ROW_HEIGHT = 44.3   
local MAX_ROWS = 24   


PetBattleTeams = CreateFrame("Frame")
PetBattleTeams.version = 102
PetBattleTeams.resetTeams = false;
PetBattleTeams.step = 5
SLASH_PETBATTLETEAMS1, SLASH_PETBATTLETEAMS2 = '/pbt', '/petbattleteams' 

--PetBattleTeamsSettings helper functions
local function GetFrameInfo(self)
	if self.frameInfo and self.frameInfo[GetRealmName()] and self.frameInfo[GetRealmName()][GetUnitName("player")] then
		local settings = self.frameInfo[GetRealmName()][GetUnitName("player")]
		return settings.attached, settings.locked, settings.x, settings.y, settings.height
	end
	return true, false,0,0,0
end

local function SetFrameInfo(self,attached, locked, x,y,height)
	if not self.frameInfo then 
		self.frameInfo = {} 
	end
	if not self.frameInfo[GetRealmName()] then
		self.frameInfo[GetRealmName()] = {}
	end
	self.frameInfo[GetRealmName()][GetUnitName("player")] = {["attached"]=attached,["locked"]=locked, ["x"]=x, ["y"]=y,["height"]=height}
end

PetBattleTeams.RemoveTeam = function(self,team)
	
	table.remove(PetBattleTeamsSettings.teams,team)
	if #PetBattleTeamsSettings.teams > 1 then
		if PetBattleTeamsSettings.selected == team then
			PetBattleTeams:SetTeam(PetBattleTeamsSettings.selected-1)
		elseif PetBattleTeamsSettings.selected > team then
			PetBattleTeams:SetTeam(PetBattleTeamsSettings.selected-1)
		
			
		end
	elseif  #PetBattleTeamsSettings.teams == 1  then
		PetBattleTeams:SetTeam(1)
	end
	--PetBattleTeamsUI:UpdateAllFrames()
end

PetBattleTeams.CreateNewTeam = function(self) 
	if #PetBattleTeamsSettings.teams < MAX_TEAMS then
		local team = {}
		for i = 1,PETS_PER_TEAM do
			pet = {}
			pet.abilities = {}
			pet.petID, pet.abilities[1], pet.abilities[2], pet.abilities[3] = C_PetJournal.GetPetLoadOutInfo(i)
			table.insert(team,pet)
		end
		if #team > 0 then
			table.insert(PetBattleTeamsSettings.teams,team)
			PetBattleTeamsSettings.selected = #PetBattleTeamsSettings.teams
			PetBattleTeamsUI:UpdateAllFrames()
		end
	end
end

PetBattleTeams.UpdateCurrentTeam = function()
	if not PetBattleTeams:IsWorking() then
		local team = {}
		for i = 1,PETS_PER_TEAM do
			pet = {}
			pet.abilities = {}
			pet.petID, pet.abilities[1], pet.abilities[2], pet.abilities[3] = C_PetJournal.GetPetLoadOutInfo(i)
			table.insert(team,pet)
		end
		
		if PetBattleTeamsSettings.selected == 0 then
			PetBattleTeams:CreateNewTeam()
		else
			PetBattleTeamsSettings.teams[PetBattleTeamsSettings.selected] = team
		end
		PetBattleTeamsUI:UpdateAllFrames()
	end
end

PetBattleTeams.UpdateTeamSwapPets=function(self,destinationTeam,destinationPetIndex,sourceTeam,sourcePetIndex)
	
	if C_PetBattles.IsInBattle() and not C_PetBattles.GetPVPMatchmakingInfo() and destinationTeam ~= sourceTeam and (destinationTeam == PetBattleTeamsSettings.selected or sourceTeam == PetBattleTeamsSettings.selected) then
		return false
	end

	if not PetBattleTeams:IsWorking() then
		petA = PetBattleTeamsSettings.teams[destinationTeam][destinationPetIndex]
		petB = PetBattleTeamsSettings.teams[sourceTeam][sourcePetIndex]
		
		if petA.petID ~= petB.petID and sourceTeam ~= destinationTeam  then
			for i=1,PETS_PER_TEAM do
				if petA.petID == PetBattleTeamsSettings.teams[sourceTeam][i].petID or petB.petID == PetBattleTeamsSettings.teams[destinationTeam][i].petID then
					return false
				end
			end
		end
		
		PetBattleTeamsSettings.teams[destinationTeam][destinationPetIndex] = petB
		PetBattleTeamsSettings.teams[sourceTeam][sourcePetIndex] = petA
		
		if destinationTeam == PetBattleTeamsSettings.selected or sourceTeam == PetBattleTeamsSettings.selected  then 
			self:SetTeam(PetBattleTeamsSettings.selected)
		end
		PetBattleTeamsUI:UpdateAllFrames()
	end
	return true
end

PetBattleTeams.UpdateTeamNewPet =function(self,petID,team,petIndex)
	if not C_PetBattles.GetPVPMatchmakingInfo() and C_PetBattles.IsInBattle() and team == PetBattleTeamsSettings.selected then return false end
	
	if not PetBattleTeams:IsWorking() then
		if PetBattleTeamsSettings.teams[team][petIndex].petID ~= petID then
			for i=1,PETS_PER_TEAM do
				if petID == PetBattleTeamsSettings.teams[team][i].petID then
					return false
				end
			end
		end
		
		local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable = C_PetJournal.GetPetInfoByPetID(petID)
		if speciesID and canBattle then
			local pet = {}
			local abilities = {}
			C_PetJournal.GetPetAbilityList(speciesID, abilities, {})
			pet.petID = petID
			pet.abilities = {}
			for i=1,3 do
				pet.abilities[i] = abilities[i]
			end
			PetBattleTeamsSettings.teams[team][petIndex] = pet;
			
			if team == PetBattleTeamsSettings.selected  then 
				self:SetTeam(PetBattleTeamsSettings.selected)
			end
			--PetBattleTeamsUI:UpdateAllFrames()
		end
	end
	return true
end

PetBattleTeams.SetTeam = function(self,team)
	if not C_PetBattles.IsInBattle() and not C_PetBattles.GetPVPMatchmakingInfo() or PetBattleTeamsSettings.selected == team  then
		oldTeam = PetBattleTeamsSettings.selected
		PetBattleTeamsSettings.selected = team
		
		--PetBattleTeamsUI:UpdateAllFrames()
		PetBattleTeams:StartWork()
	end
end

--Pet switching logic
PetBattleTeams.OnUpdate = function(self)
	if self.step < 4 then    
		if PetBattleTeamsSettings.teams[PetBattleTeamsSettings.selected] and PetBattleTeamsSettings.teams[PetBattleTeamsSettings.selected][self.step] and C_PetJournal.GetPetInfoByPetID(PetBattleTeamsSettings.teams[PetBattleTeamsSettings.selected][self.step].petID) then
			pet = PetBattleTeamsSettings.teams[PetBattleTeamsSettings.selected][self.step]			
			local petID, ability1, ability2, ability3, locked = C_PetJournal.GetPetLoadOutInfo(self.step)
			
			if locked then 
				C_PetJournal.SetPetLoadOutInfo(self.step,0)
				if C_PetJournal.GetPetLoadOutInfo(self.step) == 0 then
					self.step = self.step +1
					return
				end
			end
			
			if petID ~= pet.petID then 
				C_PetJournal.SetPetLoadOutInfo(self.step,pet.petID) 
				return
			else
				if ability1 ~= pet.abilities[1] then 
					C_PetJournal.SetAbility(self.step, 1, pet.abilities[1])
					return
				elseif ability2 ~= pet.abilities[2] then
					C_PetJournal.SetAbility(self.step, 2, pet.abilities[2])
					return
				elseif ability3 ~= pet.abilities[3] then
					C_PetJournal.SetAbility(self.step, 3, pet.abilities[3])
					return
				end
			end
			
			if petID == pet.petID and ability1 == pet.abilities[1] and ability2 == pet.abilities[2] and ability3 == pet.abilities[3] then
				self.step = self.step +1
			end
		else --invalid pet / non existant
			C_PetJournal.SetPetLoadOutInfo(self.step,0)
			if C_PetJournal.GetPetLoadOutInfo(self.step) == 0 then
				self.step = self.step +1
			end
		end 
	else
		if PetJournal then
			PetJournal_UpdatePetLoadOut()
		end
		self:SetScript("OnUpdate",nil)
		self.step = FINISHED
	end 
end

PetBattleTeams.StartWork = function(self)
	self.step = START
	self:SetScript("OnUpdate",PetBattleTeams.OnUpdate)
end

PetBattleTeams.IsWorking = function(self)
	return self.step < FINISHED 
end

--Reset saved variables
PetBattleTeams.Reset = function(self,resetTeams)
	local backupTeams = {}
	if  PetBattleTeamsSettings then
		backupTeams = PetBattleTeamsSettings.teams
	end
	
	PetBattleTeamsSettings={}
	PetBattleTeamsSettings.GetFrameInfo = GetFrameInfo
	PetBattleTeamsSettings.SetFrameInfo = SetFrameInfo
	
	if resetTeams then
		PetBattleTeamsSettings.teams = {}
		PetBattleTeamsSettings.frameInfo = {}
		
	else
		PetBattleTeamsSettings.teams = backupTeams;
		if #PetBattleTeamsSettings.teams > MAX_TEAMS then
			for i=#PetBattleTeamsSettings.teams,MAX_TEAMS+1,-1 do
				table.remove(PetBattleTeamsSettings.teams,i);
			end
		end
	end
	
	--if #PetBattleTeamsSettings.teams == 0 then
	--	PetBattleTeams:CreateNewTeam()
	--end
	
	SetFrameInfo(PetBattleTeamsSettings,true,false,0,0,614);
	
	PetBattleTeamsSettings.version = PetBattleTeams.version
	PetBattleTeamsSettings.selected = 0
	PetBattleTeamsSettings.displayLevel = false 
end

PetBattleTeams.ValidatePets = function(self)
	local invalid = 0
	local total = #PetBattleTeamsSettings.teams * PETS_PER_TEAM
	for i=1,#PetBattleTeamsSettings.teams do
		for j=1,PETS_PER_TEAM do
			if not C_PetJournal.GetPetInfoByPetID(PetBattleTeamsSettings.teams[i][j].petID) then
				invalid = invalid + 1
			end
		end
	end
	return invalid, total
end

-- misc functions
PetBattleTeams.OnEvent = function(self,event,...)
    if event == "ADDON_LOADED" then
        name = ...
        if name == "PetBattleTeams" then
			
			if not PetBattleTeamsSettings  or PetBattleTeamsSettings.version ~= PetBattleTeams.version then
				self:Reset(self.resetTeams)
			end
			
			PetBattleTeamsSettings.GetFrameInfo = GetFrameInfo
			PetBattleTeamsSettings.SetFrameInfo = SetFrameInfo
			
			PetBattleTeamsUI:CreateUI()
			PetBattleTeamsUI:UpdateAllFrames()
			
			--self:UnregisterEvent("ADDON_LOADED")
        end
		if name == "Blizzard_PetJournal" then
			PetBattleTeamsUI:CreateUI()
			PetBattleTeamsUI:UpdateAllFrames()
		end
    end
	if event == "PET_JOURNAL_LIST_UPDATE" or event =="PET_JOURNAL_PET_DELETED" or event == "PET_BATTLE_QUEUE_STATUS" or event == "PET_BATTLE_OPENING_START" or event =="PET_BATTLE_CLOSE" then 
		PetBattleTeamsUI:UpdateAllFrames()
	end
	
	if event == "BATTLE_PET_CURSOR_CLEAR" then
		PetBattleTeamsUI:CursorEmpty()
		PetBattleTeamsUI:UpdateAllFrames()
		
	end

	if event == "PLAYER_LOGOUT" then
		local attached , locked = PetBattleTeamsSettings:GetFrameInfo();
		local left, bottom, width, height = PetBattleTeamsUI.mainFrame:GetBoundsRect()
		PetBattleTeamsSettings:SetFrameInfo(attached,locked,left,bottom+height,height);
	end
	
	

end

local DELETE_TEXT = "Are you sure you want to delete team |cffffd200%s|r?"
if GetLocale() == "zhCN" then DELETE_TEXT = "你确定要删除战队|cffffd200%s|r吗？"
elseif GetLocale() == "zhTW" then DELETE_TEXT = "你確定要刪除隊伍|cffffd200%s|r嗎?"
end
StaticPopupDialogs["PBT_TEAM_DELETE"] = {
	text = DELETE_TEXT,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		PetBattleTeams:RemoveTeam(self.data)
		PetBattleTeamsUI:UpdateAllFrames()
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
}

function SlashCmdList.PETBATTLETEAMS(msg, editbox)
	id = tonumber(msg)
	if id and id > 0 and id <= #PetBattleTeamsSettings.teams then
		PetBattleTeams:SetTeam(id)
	elseif msg =="reset teams" then
		PetBattleTeamsSettings.teams = {}
		PetBattleTeamsUI:UpdateAllFrames()
	elseif msg == "reset all" then
		PetBattleTeams:Reset(true)
		PetBattleTeamsUI:UpdateAllFrames()
		if PetJournalParent and not PetJournalParent:IsShown() then
			TogglePetJournal(2)
		end
	elseif msg == "reset ui" then
		PetBattleTeams:Reset(false)
		PetBattleTeamsUI:UpdateAllFrames()
		if PetJournalParent and not PetJournalParent:IsShown() then
			TogglePetJournal(2)
		end
	elseif msg =="validate" then
		local invalid, total = PetBattleTeams:ValidatePets()
		print(invalid.." invalid pets of "..total.. " pets")
	elseif msg =="random" then
		local team = math.random(#PetBattleTeamsSettings.teams) 
		PetBattleTeams:SetTeam(team)
		PetBattleTeamsUI:UpdateAllFrames()
	else
		print("To switch between pet teams use /pbt # or /petbattleteams #, where # is a number between 1 and ".. #PetBattleTeamsSettings.teams)
		print("To reset your PBT setting use /pbt reset all")
		print("To reset your PBT UI setting use /pbt reset ui")
		print("To reset your PBT Teams use /pbt reset teams")
		print("To select a random Team use /pbt random")
	end
end

function PrintObject(object,prepend)
	if not prepend then prepend = "   " end
	if string.len(prepend) > 9 then return end
	if object and type(object) == "table" then
		for k,v in pairs(object) do 
			if type(v) == "table" then 
				print(prepend,k) 
				PrintObject(v,prepend.."  ")
			else
				print (prepend,tostring(k),tostring(v))
			end
			
		end
	end
end

--Begin addon
PetBattleTeams:RegisterEvent("BATTLE_PET_CURSOR_CLEAR")
PetBattleTeams:RegisterEvent("PET_BATTLE_CLOSE")
PetBattleTeams:RegisterEvent("PET_BATTLE_OPENING_START")
PetBattleTeams:RegisterEvent("PET_BATTLE_QUEUE_STATUS")
PetBattleTeams:RegisterEvent("PET_JOURNAL_PET_DELETED")
PetBattleTeams:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
PetBattleTeams:RegisterEvent("ADDON_LOADED")
PetBattleTeams:RegisterEvent("PLAYER_LOGOUT")

PetBattleTeams:SetScript("OnEvent" , PetBattleTeams.OnEvent)

hooksecurefunc(C_PetJournal, "SetPetLoadOutInfo", PetBattleTeams.UpdateCurrentTeam)
hooksecurefunc(C_PetJournal, "SetAbility", PetBattleTeams.UpdateCurrentTeam)
