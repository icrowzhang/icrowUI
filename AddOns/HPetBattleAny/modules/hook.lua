-----####Hook1.51####
-----1.51修复点击其他人发出来的无品质宠物链接报错的问题
local _
----- Globals
local _G = getfenv(0)
local hooksecurefunc, tinsert, pairs, wipe = _G.hooksecurefunc, _G.table.insert, _G.pairs, _G.wipe
local ipairs = _G.ipairs
local C_PetJournal = _G.C_PetJournal
----- --------
local L = HPetLocals
local hookfunction = CreateFrame("frame")
HPetBattleAny.hook = hookfunction

hookfunction.init = function()
	PetBattlePrimaryUnitTooltip:HookScript("OnHide",function() GameTooltip:Hide() end)

	for a,b in pairs(HPetBattleAny.hook) do
		if a=="PetBattleUnitFrame_OnClick" then
			--------------------------点击头像
			PetBattleFrame.ActiveAlly:SetScript("OnClick",b)
			PetBattleFrame.ActiveEnemy:SetScript("OnClick",b)
			PetBattleFrame.Ally2:SetScript("OnClick",b)
			PetBattleFrame.Ally3:SetScript("OnClick",b)
			PetBattleFrame.Enemy2:SetScript("OnClick",b)
			PetBattleFrame.Enemy3:SetScript("OnClick",b)
		elseif a=="PetJournalUtil_GetDisplayName" then
			PetJournalUtil_GetDisplayName=b
		elseif a~=0 and a~="init" then
			hooksecurefunc(a,b)
		end
		PetJournal.listScroll.update = PetJournal_UpdatePetList;
	end

	if HPetBattleAny.CreateLinkByInfo then C_PetJournal.GetBattlePetLink=HPetBattleAny.CreateLinkByInfo end
end

--[[	Hook	]]--
--------------------		鼠标提示/头像
hookfunction.PetBattleUnitTooltip_UpdateForUnit = function(self, petOwner, petIndex)
	local r,g,b,hex=GetItemQualityColor(C_PetBattles.GetBreedQuality(petOwner,petIndex)-1)
------- 成长值
	GameTooltip:SetOwner(self,"ANCHOR_BOTTOM");
	if petOwner == LE_BATTLE_PET_ENEMY and HPetBattleAny.EnemyPetInfo[petIndex] then
		local EnemyPet=HPetBattleAny.EnemyPetInfo[petIndex]
		local ghealth, gpower, gspeed = HPetBattleAny.ShowMaxValue(EnemyPet.level,EnemyPet.health,EnemyPet.power,EnemyPet.speed,EnemyPet.rarity)
		GameTooltip:AddDoubleLine(L["Breed Point"],"|c"..hex..ghealth.."/"..gpower.."/"..gspeed.."|r")
	end
----- 一个额外的鼠标提示
	local speciesID=C_PetBattles.GetPetSpeciesID(petOwner,petIndex)
	local name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable = C_PetJournal.GetPetInfoBySpeciesID(speciesID)

	if sourceText and sourceText~="" and HPetBattleAny.GetPetCollectedInfo then
		local str1,str2 = HPetBattleAny:GetPetCollectedInfo(HPetBattleAny.HasPet[speciesID])
--~ 		GameTooltip:SetOwner(self,"ANCHOR_BOTTOM");
		GameTooltip:AddDoubleLine(str1..str2,nil, 1, 1, 1);
		GameTooltip:AddLine(sourceText, 1, 1, 1, true);
		GameTooltip:Show();
	end
----- 	技能CD
	if true then
		for i = 1, NUM_BATTLE_PET_ABILITIES do
			local id, name, icon, maxCooldown, description, numTurns, abilityPetType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(petOwner, petIndex, i);
			local enemyPetType = C_PetBattles.GetPetType(PetBattleUtil_GetOtherPlayer(petOwner), C_PetBattles.GetActivePet(PetBattleUtil_GetOtherPlayer(petOwner)));
			local abilityIcon = self["AbilityIcon"..i];
			local abilityName = self["AbilityName"..i];
			if id then
				local CanUse, abilityCD = C_PetBattles.GetAbilityState(petOwner,petIndex,i)
				if CanUse then
					name = "|cffffff00"..name.."|r"
				else
					name = "|cffff0000"..name.."|r"
				end

				if abilityCD~=0 then
					name = name.." CD:"..abilityCD.."/"..maxCooldown.."|r"
				elseif maxCooldown ~= 0 then
					name = name.." CD:"..maxCooldown.."|r"
				end

				abilityName:SetText(name)

				if not abilityName:IsShown() then
					local modifier = 1.0;
					if (abilityPetType and enemyPetType) then
						modifier = C_PetBattles.GetAttackModifier(abilityPetType, enemyPetType);
					end

					if ( noStrongWeakHints or modifier == 1 ) then
						abilityIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Neutral");
					elseif ( modifier < 1 ) then
						abilityIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Weak");
					elseif ( modifier > 1 ) then
						abilityIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong");
					end

					abilityIcon:Show();
					abilityName:Show();
				end
			end
		end
	end
end
--------------------		UnitFrame上色
hookfunction.PetBattleUnitFrame_UpdateDisplay=function(self)
	if self.petOwner and self.petIndex and self.petIndex <= C_PetBattles.GetNumPets(self.petOwner)  then
		local rarity = C_PetBattles.GetBreedQuality(self.petOwner,self.petIndex)
		local r,g,b = GetItemQualityColor(rarity-1)
		if (self.Border) then
			if (ENABLE_COLORBLIND_MODE == "1") then
				self.Name:SetText(self.Name:GetText().." (".._G["BATTLE_PET_BREED_QUALITY"..rarity]..")");
			end
		end

		if self.Name then
			self.Name:SetVertexColor(r, g, b);
		end

		if self.Icon then
			if not self.glow then
				self.glow = self:CreateTexture(nil, 'ARTWORK', nil, 2)
				self.glow:SetTexture('Interface\\Buttons\\CheckButtonHilight')
				self.glow:SetSize(self.Icon:GetWidth(), self.Icon:GetHeight())
				self.glow:SetPoint('CENTER', self.Icon)
				self.glow:SetBlendMode('ADD')
				self.glow:SetAlpha(1)
			end
			self.glow:SetVertexColor(r,g,b)
			if not self.BorderAlive and not HPetSaves.HighGlow then
				self.glow:Hide()
			end
		end
	end
end

----- 宠物对战的时候，鼠标放置技能上面。tooltip固定到了右下角。但是放在被动上面却依附在鼠标附近。这应该算是个bug，所以我hook这一段，进行了一点点修改
hookfunction.PetBattleAbilityButton_OnEnter= function(self)
	local petIndex = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY);
	if ( self:GetEffectiveAlpha() > 0 and C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, petIndex, self:GetID()) ) then
		PetBattleAbilityTooltip_SetAbility(LE_BATTLE_PET_ALLY, petIndex, self:GetID());
		PetBattleAbilityTooltip_Show("BOTTOMLEFT", self, "TOPRIGHT", 0, 0, self.additionalText);
	elseif ( self.abilityID ) then
		PetBattleAbilityTooltip_SetAbilityByID(LE_BATTLE_PET_ALLY, petIndex, self.abilityID, format(PET_ABILITY_REQUIRES_LEVEL, self.requiredLevel));
		PetBattleAbilityTooltip_Show("BOTTOMLEFT", self, "TOPRIGHT", 0, 0);
	else
		PetBattlePrimaryAbilityTooltip:Hide();
	end
end
------ 宠物日志滚动列表条刷新
hookfunction.PetJournal_UpdatePetList=function()
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
		if index <= numPets then
			local petID, speciesID, isOwned, customName, level, favorite, isRevoked, name, icon, petType, creatureID, sourceText, description, isWildPet, canBattle = C_PetJournal.GetPetInfoByIndex(index, isWild);
			if isOwned then
				local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID);
				if (isWildPet) or rarity then
					pet.iconBorder:Show();
					pet.iconBorder:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b);
				else
					pet.iconBorder:Hide();
				end
			end
		end
	end
end
----- 对没有标示品质的宠物进行标示品质
hookfunction.PetJournal_UpdatePetCard=function(self)
	if PetJournalPetCard.petID then
		local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable = C_PetJournal.GetPetInfoByPetID(PetJournalPetCard.petID)
		local _,health,power,speed,rarity = C_PetJournal.GetPetStats(PetJournalPetCard.petID)
		if canBattle and self.QualityFrame:IsShown()==nil then
			if rarity then
				self.QualityFrame.quality:SetText(_G["BATTLE_PET_BREED_QUALITY"..rarity]);
				local color = ITEM_QUALITY_COLORS[rarity-1];
				self.QualityFrame.quality:SetVertexColor(color.r, color.g, color.b);
				self.QualityFrame:Show();
			end
		end
		if HPetSaves.ShowGrowInfo and speciesID and HPetBattleAny.ShowMaxValue then
			local ghealth, gpower, gspeed = HPetBattleAny.ShowMaxValue(level,health,power,speed,rarity)
			self.HealthFrame.health:SetText(format("%d(+%.1f)",health,ghealth))
			self.PowerFrame.power:SetText(format("%d(+%.1f)",power,gpower))
			self.SpeedFrame.speed:SetText(format("%d(+%.1f)",speed,gspeed))
		end
	end
	if PetJournalPetCard.speciesID then
		local petType=select(3,C_PetJournal.GetPetInfoBySpeciesID(PetJournalPetCard.speciesID))
		PetJournalPetCard.TypeInfo.type:SetText(_G["BATTLE_PET_NAME_"..petType].."("..PetJournalPetCard.speciesID..")")
	end
end

----- 点击未收集的宠物链接直接链接到宠物日志
hookfunction.FloatingBattlePet_Show=function(speciesID,level)
	if level==0 then
		FloatingBattlePetTooltip:Hide()
		if (not PetJournalParent) then
			PetJournal_LoadUI();
		end
		if (not PetJournalParent:IsShown()) then
			ShowUIPanel(PetJournalParent);
		end
		PetJournalParent_SetTab(PetJournalParent, 2);
		if (speciesID and speciesID > 0) then
			PetJournal_SelectSpecies(PetJournal, speciesID);
		end
	end
end

----- 修复宠物对战中一些快捷键失效的问题
hookfunction.PetBattleFrame_ButtonUp=function(id)
	if id==4 or id== 5 then
		local button=PetBattleFrame.BottomFrame[(id==4 and "SwitchPetButton" or "CatchButton")]
		if ( button:GetButtonState() == "PUSHED" ) then
			button:SetButtonState("NORMAL");
			if ( not GetCVarBool("ActionButtonUseKeydown") ) then
				button:Click();
			end
		end
	end
end

hookfunction.BattlePetTooltipTemplate_SetBattlePet=function(frame,data)
	local mPet=HPetBattleAny.HasPet[data.speciesID]
	if mPet then
		frame.BattlePet:SetText(TOOLTIP_BATTLE_PET.."("..COLLECTED..")");
	else
		frame.BattlePet:SetText(TOOLTIP_BATTLE_PET.."|cffff0000".."("..NOT_COLLECTED..")|r");
	end
	if data.level ~=0 and data.breedQuality ~= -1 then
		local ghealth, gpower, gspeed = HPetBattleAny.ShowMaxValue(data.level,data.maxHealth,data.power,data.speed,data.breedQuality+1)
		frame.Health:SetText(format("%d(+%.1f)",data.maxHealth,ghealth))
		frame.Power:SetText(format("%d(+%.1f)",data.power,gpower))
		frame.Speed:SetText(format("%d(+%.1f)",data.speed,gspeed))
	end

end

----------------------------------------------------------------------
----- 点击头像,链接到宠物日志
hookfunction.PetBattleUnitFrame_OnClick=function(self,button)
	if button=="LeftButton" then
		local speciesID = C_PetBattles.GetPetSpeciesID(self.petOwner,self.petIndex)
		if speciesID then hookfunction.FloatingBattlePet_Show(speciesID,0) end
	end
end
----------删除宠物，提醒消息中附带宠物颜色
hookfunction.PetJournalUtil_GetDisplayName=function(petID)
	local speciesID, customName, level, xp, maxXp, displayID, petName, petIcon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(petID);
	local rarity = select(5,C_PetJournal.GetPetStats(petID))
	if ( customName ) then
		return ITEM_QUALITY_COLORS[rarity-1].hex..customName.."|r";
	else
		return ITEM_QUALITY_COLORS[rarity-1].hex..petName.."|r";
	end
end
