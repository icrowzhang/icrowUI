local COMPANION_BUTTON_HEIGHT = 46;
local MAX_ACTIVE_PETS = 3
local MAX_BALANCED = 1
local MAX_SPEED = 2
local MAX_STAMINA = 3
local MAX_ATTACK = 4
local _
local Hooked = PetJournalEnhanced:NewModule("Hooked")

function Hooked:Initialize(database)
	if not self.initialized then

		for i=1,#PetJournal.listScroll.buttons do
			button = PetJournal.listScroll.buttons[i]
			button.highStat = button:CreateTexture(nil,"OVERLAY")
			button.highStat:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
			button.highStat:SetTexCoord(0.0,0.5,0.0,0.5)
			button.highStat:SetSize(12,12)

			button.highStat:SetPoint("RIGHT",button.name,"LEFT",0,0)
			button.name:SetPoint("TOPLEFT","PetJournalListScrollFrameButton"..i,"TOPLEFT",10+button.highStat:GetWidth(),-2)
			button.highStat:SetDrawLayer("OVERLAY", 7)
			button.highStat:Hide()
		end


		self.db = database.global

		local ZoneFiltering = PetJournalEnhanced:GetModule("ZoneFiltering")
		self.zoneTree = ZoneFiltering:GetZoneTree()
		UIDropDownMenu_Initialize(PetJournalFilterDropDown, self.PetJournalFilterDropDown , "MENU")

		--self:RegisterMessage("PETJOURNAL_ENHANCED_UPDATE")
		hooksecurefunc("PetJournal_UpdatePetCard", Hooked.PetJournal_UpdatePetCard)
		hooksecurefunc("PetJournal_UpdatePetLoadOut", Hooked.PetJournal_UpdatePetLoadOut)

		--PetJournal_UpdatePetCard = Hooked.PetJournal_UpdatePetCard
		--PetJournal_UpdatePetLoadOut = Hooked.PetJournal_UpdatePetLoadOut
		PetJournal_UpdatePetList = Hooked.PetJournal_UpdatePetList
		PetJournal.listScroll.update = Hooked.PetJournal_UpdatePetList
		PetJournal_ShowPetCard = Hooked.PetJournal_ShowPetCard
		PetJournal_FindPetCardIndex = Hooked.PetJournal_FindPetCardIndex
		PetJournal_SelectSpecies = Hooked.PetJournal_SelectSpecies
		PetJournal_SelectPet = Hooked.PetJournal_SelectPet
		PetJournal_ShowPetDropdown = Hooked.PetJournal_ShowPetDropdown

		--[[hooksecurefunc(PetJournal.listScroll,"update", Hooked.PetJournal_UpdatePetList)
		hooksecurefunc("PetJournal_ShowPetCard", Hooked.PetJournal_ShowPetCard)
		hooksecurefunc("PetJournal_FindPetCardIndex", Hooked.PetJournal_FindPetCardIndex)
		hooksecurefunc("PetJournal_SelectSpecies", Hooked.PetJournal_SelectSpecies)
		hooksecurefunc("PetJournal_SelectPet", Hooked.PetJournal_SelectPet)
		hooksecurefunc("PetJournal_UpdatePetList" , Hooked.PetJournal_UpdatePetList)
		hooksecurefunc("PetJournal_ShowPetDropdown" , Hooked.PetJournal_ShowPetDropdown)]]

		hooksecurefunc(C_PetJournal,"SetFavorite",Hooked.C_PetJournal_SetFavorite)
		PetJournalSearchBox:HookScript("OnTextChanged",function()  PetJournalEnhanced:UpdatePets() end)

		self.initialized = true
	end
end


function Hooked:Update()
	if PetJournal:IsShown() then
		self.PetJournal_FindPetCardIndex()
		self.PetJournal_UpdatePetList()
	end
end

function Hooked.PetJournal_ShowPetDropdown(index, anchorTo, offsetX, offsetY)
	if not PetJournal:IsShown() then return end
	--print("PetJournal_ShowPetDropdown")
	if (not index) then
		return;
	end

	--modified original function here to use the pet mapping
	PetJournal.menuPetIndex = index --PetJournalEnhanced:GetPet(index)
	PetJournal.menuPetID = C_PetJournal.GetPetInfoByIndex(PetJournalEnhanced:GetPet(index));
	--print(C_PetJournal.GetPetInfoByIndex(PetJournalEnhanced:GetPet(index)))
	PetJournal_HidePetDropdown()
	ToggleDropDownMenu(1, nil, PetJournal.petOptionsMenu, anchorTo, offsetX, offsetY);
end

function Hooked.C_PetJournal_SetFavorite()
	PetJournalEnhanced:UpdatePets()
end

function Hooked.PetJournal_ShowPetCard(index)
	if not PetJournal:IsShown() then return end
	--print("PetJournal_ShowPetCard")
	PetJournal_HidePetDropdown();
	PetJournalPetCard.petIndex = index; --original mapping since wow uses this number for caging
	local owned;

	--modified original function here to use the pet mapping instead
	PetJournalPetCard.petID, PetJournalPetCard.speciesID, owned = C_PetJournal.GetPetInfoByIndex(PetJournalEnhanced:GetPet(index), PetJournal.isWild);
	--

	if ( not owned ) then
		PetJournalPetCard.petID = nil;
	end
	PetJournal_UpdatePetCard(PetJournalPetCard);
	PetJournal_UpdatePetList();
	PetJournal_UpdateSummonButtonState();
end

function Hooked.PetJournal_FindPetCardIndex()
	if not PetJournal:IsShown() then return end

	--local description = debugstack()
	--print("PetJournal_FindPetCardIndex")
	--print(description)

	PetJournalPetCard.petIndex = nil;
    --modified original function here to use the pet mapping instead
	local numPets = PetJournalEnhanced:GetNumPets()
	for i = 1, numPets do
		local petID, speciesID, owned = C_PetJournal.GetPetInfoByIndex(PetJournalEnhanced:GetPet(i),false);
		if (owned and petID == PetJournalPetCard.petID) or
			(not owned and speciesID == PetJournalPetCard.speciesID)  then
				PetJournalPetCard.petIndex = i;
				break;
		end
	end
	--
end

function Hooked.PetJournal_SelectSpecies(self, targetSpeciesID)
	if not PetJournal:IsShown() then return end
	--print("PetJournal_SelectSpecies")

	local petIndex = nil;
	 --modified original function here to use the pet mapping instead
	local numPets = PetJournalEnhanced:GetNumPets()
	for i = 1,numPets do
		local petID, speciesID, owned = C_PetJournal.GetPetInfoByIndex(PetJournalEnhanced:GetPet(i), isWild);
		if (speciesID == targetSpeciesID) then
			petIndex = i;
			break;
		end
	end
	--

	if ( petIndex ) then --might be filtered out and have no index.
		PetJournalPetList_UpdateScrollPos(self.listScroll, petIndex);
	end
	PetJournal_ShowPetCardBySpeciesID(targetSpeciesID);
end

function Hooked.PetJournal_SelectPet(self, targetPetID)
	if not PetJournal:IsShown() then return end
	--print("PetJournal_SelectPet")

	local petIndex = nil;
	 --modified original function here to use the pet mapping instead
	local numPets = PetJournalEnhanced:GetNumPets()
	for i = 1,numPets do
		local petID, speciesID, owned = C_PetJournal.GetPetInfoByIndex(PetJournalEnhanced:GetPet(i), isWild);
		if (petID == targetPetID) then
			petIndex = i;
			break;
		end
	end
	--

	if ( petIndex ) then --might be filtered out and have no index.
		PetJournalPetList_UpdateScrollPos(self.listScroll, petIndex);
	end
	PetJournal_ShowPetCardByID(targetPetID);
end

function Hooked.PetJournal_UpdatePetList()
	if not PetJournal:IsShown() then return end

	local scrollFrame = PetJournal.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local petButtons = scrollFrame.buttons;
	local pet, index;

	local isWild = PetJournal.isWild;

	local numPets, numOwned = C_PetJournal.GetNumPets(isWild);
	PetJournal.PetCount.Count:SetText(numOwned);

	local summonedPetID = C_PetJournal.GetSummonedPetID();

	for i = 1,#petButtons do

		pet = petButtons[i];

		index = offset + i;
		if index <= #PetJournalEnhanced.petMapping then
			local petID, speciesID, isOwned, customName, level, favorite, isRevoked, name, icon, petType, creatureID, sourceText, description, isWildPet, canBattle = C_PetJournal.GetPetInfoByIndex(PetJournalEnhanced:GetPet(index), isWild);

			pet.icon:SetTexture(icon);
			pet.petTypeIcon:SetTexture(GetPetTypeTexture(petType));

			if (favorite) then
				pet.dragButton.favorite:Show();
			else
				pet.dragButton.favorite:Hide();
			end

			pet.highStat:Hide()

			if isOwned then
				local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID);

				--enable borders for non wild pets


				--compute and display max stat icon
				if Hooked.db.display.maxStatIcon then
					if canBattle then
						local maxStat = PetJournalEnhanced.GetMaxStat(maxHealth,attack,speed)
						--texture is the same, were just setting what part were rendering
						--todo: move to a table of textures with precomputed texcoords
						if maxStat == MAX_BALANCED then
							pet.highStat:Hide()
						else
							if maxStat == MAX_ATTACK then
								pet.highStat:SetTexCoord(0.0,0.5,0.0,0.5)
							elseif maxStat == MAX_STAMINA then
								pet.highStat:SetTexCoord(0.5,1.0,0.5,1.0)
							elseif maxStat == MAX_SPEED then
								pet.highStat:SetTexCoord(0.0,0.5,0.5,1)
							end
							pet.highStat:Show()
						end
					end
				else
					pet.highStat:Hide()
				end

				--color the names by their rarity
				if Hooked.db.display.coloredNames and canBattle and rarity then
					local r, g, b,hex  = GetItemQualityColor(rarity-1)
					name = "|c"..hex..name.."|r"
				end

				pet.dragButton.levelBG:SetShown(canBattle);
				pet.dragButton.level:SetShown(canBattle);
				pet.dragButton.level:SetText(level);

				pet.icon:SetDesaturated(0);
				pet.name:SetFontObject("GameFontNormal");
				pet.petTypeIcon:SetShown(canBattle);
				pet.petTypeIcon:SetDesaturated(0);
				pet.dragButton:Enable();

				if (isWildPet) then
					pet.iconBorder:Show();
					pet.iconBorder:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b);
				elseif rarity and Hooked.db.display.coloredBorders and canBattle then
					pet.iconBorder:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b)
					pet.iconBorder:Show()
				else
					pet.iconBorder:Hide()
				end

				if (health and health <= 0) then
					pet.isDead:Show();
				else
					pet.isDead:Hide();
				end
				if(isRevoked == true) then
					pet.dragButton.levelBG:Hide();
					pet.dragButton.level:Hide();
					pet.iconBorder:Hide();
					pet.icon:SetDesaturated(1);
					pet.petTypeIcon:SetDesaturated(1);
					pet.dragButton:Disable();
				end
			else
				pet.dragButton.levelBG:Hide();
				pet.dragButton.level:Hide();
				pet.icon:SetDesaturated(1);
				pet.iconBorder:Hide();
				pet.name:SetFontObject("GameFontDisable");
				pet.petTypeIcon:SetShown(canBattle);
				pet.petTypeIcon:SetDesaturated(1);
				pet.dragButton:Disable();
				pet.isDead:Hide();
			end

			if customName then
				pet.name:SetText(customName);
				pet.name:SetHeight(12);
				pet.subName:Show();
				pet.subName:SetText(name);
			else
				pet.name:SetText(name)
--~ 				pet.name:SetText(name.." "..index.." org: "..PetJournalEnhanced.petMapping[index].index );
				pet.name:SetHeight(30);
				pet.subName:Hide();
			end

			if ( petID and petID == summonedPetID ) then
				pet.dragButton.ActiveTexture:Show();
			else
				pet.dragButton.ActiveTexture:Hide();
			end

			pet.petID = petID;
			pet.speciesID = speciesID;
			pet.index = index;
			pet.owned = isOwned;
			pet:Show();

			--Update Petcard Button
			if PetJournalPetCard.petIndex == index then
				pet.selected = true;
				pet.selectedTexture:Show();
			else
				pet.selected = false;
				pet.selectedTexture:Hide()
			end
		else
			pet:Hide();
		end
	end

	local totalHeight = PetJournalEnhanced:GetNumPets() * COMPANION_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());


end

--modified the menu system to cuase the pet mapping to update when ui settings are changed


function Hooked.PetJournal_UpdatePetCard()
	if PetJournalPetCard.petID  then
		local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable = C_PetJournal.GetPetInfoByPetID(PetJournalPetCard.petID)
	    if canBattle then
			local health, maxHealth, power, speed, rarity = C_PetJournal.GetPetStats(PetJournalPetCard.petID)
			PetJournalPetCard.QualityFrame.quality:SetText(_G["BATTLE_PET_BREED_QUALITY"..rarity])
			local r,g,b,hex  = GetItemQualityColor(rarity-1)

			--color names
			if Hooked.db.display.coloredNames and canBattle then
				if customName then
					PetJournalPetCard.PetInfo.subName:SetText("|c"..hex..name.."|r")
				else
					PetJournalPetCard.PetInfo.name:SetText("|c"..hex..name.."|r")
				end
			end

			--display rarity indicator which is hidden by blizzard for some reason for non wild pets.
			PetJournalPetCard.QualityFrame.quality:SetVertexColor(r, g, b)
			PetJournalPetCard.QualityFrame:Show()
		else
			PetJournalPetCard.QualityFrame:Hide()
		end
	end
end

--color names of the active team of pets
function Hooked.PetJournal_UpdatePetLoadOut()
	if Hooked.db.display.coloredNames then
		for i=1, MAX_ACTIVE_PETS do
			local Pet = PetJournal.Loadout["Pet"..i];
			local petID, _, _, _, locked =  C_PetJournal.GetPetLoadOutInfo(i)
			if not locked and petID > 0 then
				local _, customName, _, _, _, _, name = C_PetJournal.GetPetInfoByPetID(petID)
				local rarity = select(5,C_PetJournal.GetPetStats(petID))
				local hex  = select(4,GetItemQualityColor(rarity-1))
				if customName then
					Pet.subName:SetText("|c"..hex..name.."|r");
					Pet.name:SetText(customName);
				else
					Pet.name:SetText("|c"..hex..name.."|r");
				end
			end
		end
	end
end
