--Constants
local SETTINGS_VERSION = 22
local MAX_BALANCED = 1
local MAX_SPEED = 2
local MAX_STAMINA = 3
local MAX_ATTACK = 4

local ASCENDING =  1
local DESCENDING = 2
local USER = nil

local _

PetJournalEnhanced = LibStub("AceAddon-3.0"):NewAddon("PetJournalEnhanced","AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("PetJournalEnhanced")

local function trim(s)
  return s:match'^%s*(.*%S)' or ''
end

function PetJournalEnhanced:UpdatePets()
	if PetJournal:IsShown() then
		self:SortPets()
		self.modules.Hooked:Update()
	end
end

--Only refresh pets when the number of pets changes otherwise multiple updates occure
--[[function PetJournalEnhanced:RefreshPets()
	local numPets,numOwned = C_PetJournal.GetNumPets(false);
	print(numPets,numOwned)
	if numOwned ~= self.petCount and numPets + 1 <=  then
		print("updating")
		self.petCount = numOwned
		self:UpdatePets()
	end
end]]


function PetJournalEnhanced:InitPetJournal()
	if not self.initialized then
		self.modules.ZoneFiltering:Initialize()
		for k,v in pairs(self.modules) do
			if v.Initialize then
				v:Initialize(self.db)
			end
		end
		self:SetZoneFilter()
		self.initialized = true
	end
end

--creates all of the required sorting functions a head of time for faster use.
function PetJournalEnhanced:GetSortFunctions()
	local sortFunctions = {
		self:ComposeSortFunction("isOwned",DESCENDING,"level",  USER,"name", ASCENDING),--level
		self:ComposeSortFunction("isOwned",DESCENDING,"name",   USER,"level",DESCENDING),--alpha
		self:ComposeSortFunction("isOwned",DESCENDING,"petType",USER,"level",DESCENDING,"name",ASCENDING),--pet type
		self:ComposeSortFunction("isOwned",DESCENDING,"rarity", USER,"level",DESCENDING,"name",ASCENDING),--rarity
		self:ComposeSortFunction("isOwned",DESCENDING,"maxStat",USER,"level",DESCENDING,"name",ASCENDING),--specialization
	}

	--local sortTypes = {"Level","Alphabetical","Pet Type","Rarity","Pet Highest Stat"}


	if self.db.global.sorting.favoritesFirst then
		for i=1,#sortFunctions do
			sortFunctions[i] = self:GetCompareFunc("favorite",   sortFunctions[i],  DESCENDING)
		end
	end

	return sortFunctions
end

--builds sorting functions for readability
function PetJournalEnhanced:ComposeSortFunction(...)
	local args = {...}
	local func = nil
	for i=#args,1,-2 do
		local name = args[i-1];
		local direction = args[i]
		func = self:GetCompareFunc(name,func,direction)
	end
	return func
end

--creates a sorting function that can defer fallback sorting to another function
function PetJournalEnhanced:GetCompareFunc(var,func,direction)

	return function(a,b)
		local order = self.db.global.sorting.order
		local avar = a[var]
		local bvar = b[var]
		if type(avar) == "boolean" then
			avar = avar and 1 or 0
			bvar = bvar and 1 or 0
		end

		if avar == bvar and func then
			return func(a,b)
		end

		if direction then
			if direction == ASCENDING then
				return avar < bvar
			elseif  direction == DESCENDING then
				return avar > bvar
			end
		elseif  order == ASCENDING then
			return avar < bvar
		elseif order == DESCENDING then
			--if not avar or not bvar then print(avar,bvar,var) print(a.name,b.name) end
			return avar > bvar
		end
	end
end

function PetJournalEnhanced:CreateOptionsMenu()
	local db = self.db.global.display
	local options = {
    name = "PetJournal Enhanced",
    handler = self,
    type = 'group',
    args = {
		petJournal = {
			name = "PetJournal",
			handler = self,
			type = 'group',
			order = 1,
			args = {
				showPetCount = {
					order = 1,
					name = L["Show unique pet count"],
					type = "toggle",
					set = function(info,val)
						db.uniquePetCount = val
						self:SendMessage("PETJOURNAL_ENHANCED_OPTIONS_UPDATE")
					end,
					get = function(info) return db.uniquePetCount or false end
				},
				showMaxStat = {
					order = 2,
					name = L["Show pets specialization"],
					type = "toggle",
					width = "double",
					set = function(info,val)
						db.maxStatIcon = val
						self:SendMessage("PETJOURNAL_ENHANCED_OPTIONS_UPDATE")
					end,
					get = function(info) return db.maxStatIcon or false end
				},
				colorBorders = {
					order = 2,
					name = L["Color pet borders"],
					type = "toggle",
					width = "double",
					set = function(info,val)
						db.coloredBorders = val
						self:SendMessage("PETJOURNAL_ENHANCED_OPTIONS_UPDATE")
					end,
					get = function(info) return db.coloredBorders or false end
				},
				colorName = {
					order = 2,
					name = L["Color pet names"],
					type = "toggle",
					width = "double",
					set = function(info,val)
						db.coloredNames = val
						self:SendMessage("PETJOURNAL_ENHANCED_OPTIONS_UPDATE")
					end,
					get = function(info) return db.coloredNames or false end
				},
			},
		},


    },

}
	LibStub("AceConfig-3.0"):RegisterOptionsTable("PetJournalEnhanced", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PetJournalEnhanced","PetJournal Enhanced")
end

--Return highest stat for a pet. Check constants for return values.
function PetJournalEnhanced.GetMaxStat(maxHealth,attack,speed)

	maxHealth = tonumber(maxHealth)
	stamina = tonumber(math.floor((maxHealth -100)/5))
	attack = tonumber(attack)
	speed = tonumber(speed)

	if attack > speed and attack > stamina then
		return MAX_ATTACK
	elseif speed > attack and speed > stamina  then
		return MAX_SPEED
	elseif stamina > attack and stamina > speed  then
		return MAX_STAMINA
	end
	return MAX_BALANCED
end

function PetJournalEnhanced:AddPet(pet)
	if pet.isOwned then
		self.pets[pet.petID] = pet
	else
		self.pets[pet.speciesID] = pet
	end
end

function PetJournalEnhanced:RetreivePet(id)
	return self.pets[id]
end


function PetJournalEnhanced:SetZoneFilter()
	local zoneTree = self.modules.ZoneFiltering.zoneTree--self.modules.ZoneFiltering:GetZoneTree()
	local zones2Pets = self.modules.ZoneFiltering.zones2Pets--self.modules.ZoneFiltering:GetZones2Pets()

	wipe(self.zoneFilter)

	for continent,zones in pairs(zoneTree) do
		for zone,enabled in pairs(zones) do
			for i=1,#zones2Pets[zone] do
				local speciesID = zones2Pets[zone][i]
				self.zoneFilter[speciesID] = self.zoneFilter[speciesID] or enabled
			end
		end
	end


end

function PetJournalEnhanced:Reset()
	C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_COLLECTED, true)
	C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_FAVORITES, false);
	C_PetJournal.SetFlagFilter(LE_PET_JOURNAL_FLAG_NOT_COLLECTED, true);
	C_PetJournal.AddAllPetTypesFilter();
	C_PetJournal.AddAllPetSourcesFilter();

	local zoneTree = self.modules.ZoneFiltering.zoneTree
	for continent,zones in pairs(zoneTree) do
		for zone,_ in pairs(zones) do
			zones[zone] = true
		end
	end

	self:SetZoneFilter()

	local filtering = self.db.global.filtering
	local sorting = self.db.global.sorting

	for i=1,#filtering.rarity do
		filtering.rarity[i] = true
	end

	for i=1,#filtering.specialization do
		filtering.specialization[i] = true
	end

	filtering.currentZone = false
	filtering.canBattle = true
	filtering.cantBattle = true
	filtering.unknownZone = true
	filtering.canTrade = true
	filtering.cantTrade = true




	sorting.selection = 2
	sorting.order = ASCENDING
	sorting.favoritesFirst = false

	self:UpdatePets()
end


--/run PetJournalEnhanced:Debug("albino snake")
--/run PetJournalEnhanced:Debug("yellow moth")
--/run PetJournalEnhanced:Debug("albino snack")
function PetJournalEnhanced:Debug(petName)
	petName = trim(petName)
	print("Begining Debug")

	local FAILED = "|c00FF0000FAILED|r"
	local SUCCESS = "|c0000FF00SUCCESS|r"

	if IsAddOnLoaded("Pet Theory") then
		print(FAILED,"Detected Pet theory is installed, Pet journal enhances is not compatible with pet theory")
	end

	if IsAddOnLoaded("_PetJournalEnhanced") then
		print(FAILED," a conflicting and outdated install of PetJournal Enhanced was detected, Delete _PetJournalEnhanced from your addons folder")
	end

	self:InitPetJournal()

	self:Reset()

	print("Settings reset for maximum pets")

	print("Searching blizzard for",petName)
	local numPets = C_PetJournal.GetNumPets(PetJournal.isWild)
	local petNameUpper = string.upper(petName)
	for i=1,numPets do
		local _, _, _, _, _, _, _, name = C_PetJournal.GetPetInfoByIndex(i, PetJournal.isWild)
		nameUpper = string.upper(name)
		if  petNameUpper == nameUpper then
			print(SUCCESS,"found: ",name,"in blizzard's list at position",i)
			break
		end
		if i==numPets then
			print(FAILED,"to find:",petName," in blizzards list")
		end
	end

	print("Sorting pets")
	self:SortPets(true)

	print("Searching Pet Journal Enhanced for ",petName)
	for i=1,#self.petMapping do
		nameUpper = string.upper(self.petMapping[i].name)
		if  petNameUpper == nameUpper then
			print(SUCCESS,"found: ",self.petMapping[i].name,"in Pet Journal Enhanced's list at position",i)
			print("opening pet journal to ",self.petMapping[i].name)
			if not PetJournalParent:IsShown() then
				TogglePetJournal(2)
			end
			self.modules.Hooked.PetJournal_ShowPetCard(i)
			break
		end
		if i==#self.petMapping then
			print(FAILED,"to find:",petName," in Pet Journal Enhanced's list")
		end
	end



	self:UpdatePets()
	print("End Debug")

end

function PetJournalEnhanced:SortPets(forceSort)
	if PetJournalParent:IsShown() or forceSort then
		local db = self.db.global
		local filtering = db.filtering
		local numPets = C_PetJournal.GetNumPets(PetJournal.isWild)



		--clearing pet mapping makes the garbage collector happy
		wipe(self.petMapping)


		for i=1,numPets do
			local petID, speciesID, isOwned, customName, level, favorite, isRevoked, name, icon, petType, creatureID, sourceText, description, isWildPet, canBattle, tradable, unique = C_PetJournal.GetPetInfoByIndex(i, PetJournal.isWild)
			local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID)

			local id = nil
			if isOwned then id = petID else id = name end
			local pet = self:RetreivePet(id)

			if not pet then
				pet = {}
				pet.speciesID = speciesID
				pet.petID = petID
				pet.isOwned = isOwned
				pet.name = name
				pet.petType = petType
				pet.canBattle = canBattle
				pet.rarity = rarity or 0

				pet.maxStat = 0
				if isOwned and canBattle and maxHealth and attack and speed then
					pet.maxStat = self.GetMaxStat(maxHealth,attack,speed)
				end

				--pets that cant battle shouldn't have a level for sorting purposes
				if not canBattle then
					pet.level = 0
					pet.rarity = 0
					pet.petType = 0
				end
				--Unused currently
				--pet.health = health
				--pet.maxHealth = maxHealth
				--pet.attack = attack
				--pet.speed = speed
				--pet.health = 0
				--pet.maxHealth = 0
				--pet.attack = 0
				--pet.speed = 0
				self:AddPet(pet)
			end

			pet.favorite = favorite
			pet.index = i

			if canBattle then
				pet.level = level
			end

			local exclude = false

			if not filtering.cantBattle and not canBattle  then
				exclude = true
			elseif not filtering.canBattle and canBattle  then
				exclude = true
			elseif not filtering.canTrade and tradable  then
				exclude = true
			elseif not filtering.cantTrade and not tradable  then
				exclude = true
			elseif filtering.currentZone and not string.find(sourceText, GetZoneText(),1,true) then
				exclude = true
			elseif pet.rarity and pet.rarity > 0 and not filtering.rarity[pet.rarity] then
				exclude = true
			elseif pet.maxStat > 0 and  not filtering.specialization[pet.maxStat] then
				exclude = true
			elseif self.zoneFilter[speciesID] == false then
				exclude = true
			elseif not filtering.unknownZone and not (string.find(sourceText,"Pet Battle:") or string.find(sourceText,"Zone:"))  then
				exclude = true

			end

			if not exclude then

				table.insert(self.petMapping,pet)
			end
		end

		local sortFunc = self.SortFunctions[db.sorting.selection]
		table.sort(self.petMapping,sortFunc)
	end
end


function PetJournalEnhanced:OnInitialize()
	local defaults = {
		global = {
			display = {
				uniquePetCount = true,
				coloredNames = true,
				coloredBorders = true,
				maxStatIcon = true,
			},
			filtering = {
				rarity = {[1]=true,[2]=true,[3]=true,[4]=true},
				specialization = {[1]=true,[2]=true,[3]=true,[4]=true},
				currentZone = false,
				canBattle =true,
				cantBattle = true,
				unknownZone = true,
				cantTrade = true,
				canTrade = true,
			},
			sorting = {
				selection = 1,
				order = ASCENDING,
				favoritesFirst = false,
			},
		}
	}
	self.db = LibStub("AceDB-3.0"):New("PetJournalEnhancedDB", defaults, true)
	self.db.global.filtering.unknownZone = true --always reset to true

	self.fromUnknownZone =true
	self.petMapping = {}
	self.zoneFilter = {}
	self.pets = {}
	self.SortFunctions = self:GetSortFunctions()
	--self:InitPetJournal()

	PetJournal:HookScript("OnShow",function()
		local self = PetJournalEnhanced
		self:InitPetJournal()
		self:UpdatePets()
	end)

	self:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PET_JOURNAL_PET_DELETED")
	--self:RegisterEvent("PET_BATTLE_CAPTURED")

	self:RegisterMessage("PETJOURNAL_ENHANCED_OPTIONS_UPDATE")
	self:RegisterMessage("PETJOURNAL_ENHANCED_UPDATE")
	--self.numPets , self.numOwned,  = C_PetJournal.GetNumPets(false);
	self:CreateOptionsMenu()

	local LibPetJournal = LibStub("LibPetJournal-2.0")
	LibPetJournal.RegisterCallback(PetJournalEnhanced,"PostPetListUpdated", "ScanPets")
end

 --event handlers

function PetJournalEnhanced:PETJOURNAL_ENHANCED_UPDATE()
	self:UpdatePets()
end

function PetJournalEnhanced:ScanPets()
	--print("Scanned")
	PetJournalEnhanced:UpdatePets()
end

function PetJournalEnhanced:ZONE_CHANGED_NEW_AREA()
	self:ZONE_CHANGED()
end

function PetJournalEnhanced:PETJOURNAL_ENHANCED_OPTIONS_UPDATE()
	self:UpdatePets()
end

function PetJournalEnhanced:PET_JOURNAL_PET_DELETED()
	--print("PET_JOURNAL_PET_DELETED")
	--self.petCount = self.petCount -1
	self:UpdatePets()
end

--due to a bug with curse.com client not cleanly uninstalling old versions
--notify user if old version is found
function PetJournalEnhanced:ADDON_LOADED(event,...)
	local name = ...
	if name == "_PetJournalEnhanced"  then
		StaticPopup_Show("PETJOURNAL_ENHANCED_DUPLICATE")
	end
end

function PetJournalEnhanced:ZONE_CHANGED()
	if self.db.global.filtering.currentZone then
		self:UpdatePets()
	end
end

function PetJournalEnhanced:PET_JOURNAL_LIST_UPDATE()
	--print("PET_JOURNAL_LIST_UPDATE")
	--self:RefreshPets()
end

function PetJournalEnhanced:GetPet(index)
	if self.petMapping[index] then
		return self.petMapping[index].index
	end
end

function PetJournalEnhanced:GetNumPets()
	return #self.petMapping
end

--blizzard functions to overwrite


--static dialog for notifying the user of a duplicate and outdated installation of PJE
StaticPopupDialogs["PETJOURNAL_ENHANCED_DUPLICATE"] = {
    text = "You have a second copy of PetJournal Enhanced|n installed named _PetJournalEnhanced|n in your /interface/addons/ folder",
    button1 = "OK",
    button2 = "Don't warn me again",
    OnAccept = function (self)  end,
    OnCancel = function (self) PetJournalEnhancedOptions.warning = false end,
    OnHide = function (self) end,
    hideOnEscape = 1,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
}




