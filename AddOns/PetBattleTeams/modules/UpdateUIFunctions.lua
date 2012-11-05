local PETS_PER_TEAM = 3
local MAX_TEAMS = 60
local ROW_HEIGHT = 44.3   
local MAX_ROWS = 24    

if not PetBattleTeamsUI then PetBattleTeamsUI = {} end

PetBattleTeamsUI.UpdateAllFrames = function(self,msg)
	
	if self.mainFrame then
		self:UpdateAddTeamButton(self.mainFrame.addTeamButton,#PetBattleTeamsSettings.teams)
		self:UpdateMainFrame(self.mainFrame,#PetBattleTeamsSettings.teams)
		self:UpdateReviveButton(self.mainFrame.revivePetsButton, #PetBattleTeamsSettings.teams)
		self:UpdateScrollBar(msg)
	end
end

PetBattleTeamsUI.UpdateAddTeamButton = function(self,button,numTeams)
	if button then
		button:SetPoint("BOTTOMLEFT", button:GetParent() ,"BOTTOMLEFT",18,10)			
		if numTeams == MAX_TEAMS then 
			button.icon:SetDesaturated(true)	
		else
			button.icon:SetDesaturated(false)
		end
	end
end

PetBattleTeamsUI.UpdateReviveButton = function(self,button,numTeams)
	if button then
		local attached , locked = PetBattleTeamsSettings:GetFrameInfo()
		if not attached  then
			button:Show()
			button:SetPoint("BOTTOMRIGHT", button:GetParent() ,"BOTTOMRIGHT",-32,10)
		else
			button:Hide()
		end
	end
end

PetBattleTeamsUI.UpdateMainFrame=function(self,frame, numTeams)
	if frame then
		local attached , locked = PetBattleTeamsSettings:GetFrameInfo()
		
		
		if C_PetBattles.IsInBattle() or C_PetBattles.GetPVPMatchmakingInfo() then
			frame.GotoTeamButton.icon:SetTexture("Interface\\PetBattles\\PetBattle-LockIcon")
			frame.GotoTeamButton.icon:SetTexCoord(0,1,0,1)
		else
			frame.GotoTeamButton.icon:SetTexture("Interface\\PetBattles\\PetJournal")
			frame.GotoTeamButton.icon:SetTexCoord(0.11328125,0.16210938,0.02246094,0.04687500)
		end
		
		
		
		--set min and max sizes depending on number of teams
		if #PetBattleTeamsSettings.teams > 4 then 
			frame:SetMinResize(frame:GetWidth(),ROW_HEIGHT*4+90)
			if #PetBattleTeamsSettings.teams <= 12 then
				frame:SetMaxResize(frame:GetWidth(),ROW_HEIGHT*#PetBattleTeamsSettings.teams+90)
			else
				frame:SetMaxResize(frame:GetWidth(),ROW_HEIGHT*12+90)
			end
			frame.resizeButton:Show()
		else
			frame:SetMinResize(frame:GetWidth(),ROW_HEIGHT*1+90)
			frame:SetMaxResize(frame:GetWidth(),ROW_HEIGHT*#PetBattleTeamsSettings.teams+90)
			frame.resizeButton:Hide()
		end
		
		if attached and PetJournal then
			locked = false
			frame:SetParent(PetJournal)
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT",PetJournal,"TOPRIGHT",-5,4)
		else
			frame:SetParent("UIParent")
		end
		
		if locked or attached then 
			frame:SetMovable(false)
			frame:SetScript("OnDragStart", nil)
			frame:SetScript("OnDragStop", nil)
		else
			frame:SetScript("OnDragStart", frame.StartMoving)
			frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
			frame:SetMovable(true)
			--frame.menu:SetMovable(true)
		end
		
		if frame then
			if attached then
				frame:SetHeight(614)
				frame.resizeButton:Hide()
			else
				--handles frame sizing when you have less then minimum teams to activate the scroll bar
				if #PetBattleTeamsSettings.teams <= 4 then
					PetBattleTeamsUI.mainFrame:SetHeight(ROW_HEIGHT * #PetBattleTeamsSettings.teams +90)
				end
				
				--if we delete a team when the scroll bar is hidden then the pet frame is bigger then it should be
				if self.scrollBar and not self.scrollBar:IsShown() and (PetBattleTeamsUI.mainFrame:GetHeight()-90)/ROW_HEIGHT > #PetBattleTeamsSettings.teams then
					PetBattleTeamsUI.mainFrame:SetHeight(ROW_HEIGHT * #PetBattleTeamsSettings.teams +90)
				end
			end
		end
	end
end

PetBattleTeamsUI.UpdatePetButton=function(self,button,team,petIndex,msg)
	button:Hide()
	local lockedTeam = C_PetBattles.IsInBattle() or C_PetBattles.GetPVPMatchmakingInfo()
	
	if PetBattleTeamsSettings.teams[team] and PetBattleTeamsSettings.teams[team][petIndex] then
		
		button.team = team
		button.petIndex = petIndex
		button.petID = PetBattleTeamsSettings.teams[team][petIndex].petID
		
		button:Show()
		button.BorderAlive:Show()
		
		button.rarityGlow:Hide()
		button.selected:Hide()
		button.ActualHealthBar:Hide()
		button.level:Hide()
		button.BorderDead:Hide()
		
		--set icon for unknown pet
		button.Icon:SetTexture("\Interface\\ICONS\\INV_Misc_QuestionMark")
		
		if petIndex == 1 and PetBattleTeamsSettings.selected == team then
			button.selected:Show()
			if lockedTeam then
				button.selected:SetTexture("Interface\\PetBattles\\PetBattle-LockIcon")
				button.selected:SetTexCoord(0,1,0,1)
			else
				button.selected:SetTexture("Interface\\PetBattles\\PetJournal")
				button.selected:SetTexCoord(0.11328125,0.16210938,0.02246094,0.04687500)
			end
		end
		
		if lockedTeam and PetBattleTeamsSettings.selected == team then
			button:Disable()
		else
			button:Enable()
		end
		
		
		
		if button.petID and button.petID > 0 and C_PetJournal.GetPetInfoByPetID(button.petID) then
			-- get info about the pet
			local speciesID, customName, level, xp, maxXp, displayID, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable = C_PetJournal.GetPetInfoByPetID(button.petID)
			local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(button.petID)
			
			if rarity then
				local r, g, b = GetItemQualityColor(rarity-1)
				button.rarityGlow:SetVertexColor(r, g, b)
			end
			
			button.level:SetText(level)
			button.level:Show()

			button.Icon:SetTexture(icon)

			--set health bar
			if health and maxHealth then
				if  ( health == 0 ) then
					button.ActualHealthBar:Hide()
				else
					button.ActualHealthBar:Show()
				end
				button.ActualHealthBar:SetWidth((health / max(maxHealth,1)) * button.healthBarWidth)
			end
			
			--Set alive border
			if health and ( health == 0 ) then
				button.BorderAlive:Hide()
				button.rarityGlow:Hide()
			else
				button.BorderAlive:Show()
				button.rarityGlow:Show()
			end
			
			--set dead border
			if health and ( health == 0 ) then
				button.BorderDead:Show()
				button.rarityGlow:Hide()
			else
				button.BorderDead:Hide()
				button.rarityGlow:Show()
			end
			
			for _, object in pairs(button.hideWhenDeadList) do
				if ( health == 0 ) then
					object:Hide()
				else
					object:Show()
				end
			end
			
			--button.Icon:SetVertexColor(1,1,1,1)
			local PetOnCursor = PetBattleTeamsUI.PetOnCursor
			local CursorStruct = PetBattleTeamsUI.CursorStruct
			button.Icon:SetVertexColor(1,1,1)
			--print(PetOnCursor,CursorStruct)
			button.Icon:SetDesaturated(false)
			
			
			
			local r,g,b = unpack(button.ActualHealthBar.color)
			button.ActualHealthBar:SetVertexColor(r,g,b)
			if PetOnCursor then
				
				if CursorStruct then
					
					
					if CursorStruct.sourceTeam ~= button.team and button.petID ~= PetOnCursor or (lockedTeam and PetBattleTeamsSettings.selected == button.team) then
						for i=1,PETS_PER_TEAM do
							if PetOnCursor == PetBattleTeamsSettings.teams[team][i].petID or button.petID == PetBattleTeamsSettings.teams[CursorStruct.sourceTeam][i].petID then
								--button.Icon:SetVertexColor(1,0,0)
								button.Icon:SetDesaturated(1)
								button.ActualHealthBar:SetVertexColor(.6,.6,.6)
								button.rarityGlow:Hide()
							end
						end
					end
				
				else
					
					if PetOnCursor ~= button.petID or (lockedTeam and PetBattleTeamsSettings.selected == button.team) then
						
						for i=1,PETS_PER_TEAM do
							if PetOnCursor == PetBattleTeamsSettings.teams[team][i].petID then
								--button.Icon:SetVertexColor(1,0,0)
								button.Icon:SetDesaturated(1)
								button.ActualHealthBar:SetVertexColor(.6,.6,.6)
								button.rarityGlow:Hide()
							end
						end
					end
				end
			end
			
			if lockedTeam and PetBattleTeamsSettings.selected == button.team then
				button.Icon:SetDesaturated(1)
				button.ActualHealthBar:SetVertexColor(.6,.6,.6)
				button.rarityGlow:Hide()
			end	
			
			
			
		end
	end
end

  

PetBattleTeamsUI.TooltipSetUnit = function(self,tooltip, petID, team, petIndex)
	local speciesID, customName, level, xp, maxXp, displayID, petName, petIcon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(petID)
	local pet = PetBattleTeamsSettings.teams[team][petIndex]
	
	local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID)
	local r, g, b,hex = GetItemQualityColor(rarity-1)
	
	tooltip.rarityGlow:SetVertexColor(r, g, b)
	tooltip.Icon:SetTexture(petIcon)
	tooltip.Name:SetText("|c"..hex..petName.."|r")
	tooltip.Level:SetText(level)
	tooltip.XPBar:SetWidth(max((xp / max(maxXp,1)) * tooltip.xpBarWidth, 1))
	tooltip.Delimiter:SetPoint("TOP", tooltip.XPBG, "BOTTOM", 0, -10)
	tooltip.XPText:SetFormattedText(tooltip.xpTextFormat or PET_BATTLE_CURRENT_XP_FORMAT, xp, maxXp)
	tooltip.teamText:SetText("Team "..team)
	tooltip.AttackAmount:SetText(attack)
	tooltip.SpeedAmount:SetText(speed)
	tooltip.PetType.Icon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType])
	
	tooltip.SpeciesName:Hide()
	if customName then
		if ( customName ~= petName ) then
			tooltip.Name:SetText(customName)
			tooltip.SpeciesName:SetText(petName)
			tooltip.SpeciesName:Show()
		end
	end
	
	if ( tooltip.HealthText ) then
		tooltip.HealthText:SetFormattedText(tooltip.healthTextFormat or PET_BATTLE_CURRENT_HEALTH_FORMAT, health, maxHealth)
	end
	
	if ( health == 0 ) then
		tooltip.ActualHealthBar:SetWidth(1)
	else
		tooltip.ActualHealthBar:SetWidth((health / max(maxHealth,1)) * tooltip.healthBarWidth)
	end
		
	for i=1, #pet.abilities do
		local name, icon, petType = C_PetJournal.GetPetAbilityInfo(pet.abilities[i])
		local abilityIcon = tooltip["AbilityIcon"..i]
		local abilityName = tooltip["AbilityName"..i]

		abilityName:SetShown(name)
		abilityIcon:SetShown(icon)
		abilityIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Neutral")
		if name then 
			--abilityName:SetText(name.." "..pet.abilities[i])
			abilityName:SetText(name)
		end
	end
end

PetBattleTeamsUI.UpdateScrollBar = function(self,msg)
	
	if self.scrollBar then
		
		local maxRows = self:GetMaxRows();
		local maxValue = #PetBattleTeamsSettings.teams
		local offset = FauxScrollFrame_GetOffset(self.scrollBar)
		local row = self.mainFrame.petUnitFrames
		
		PetBattleTeamsUI.mainFrame.GotoTeamButton:SetShown(not PetBattleTeamsUI:TeamVisible(PetBattleTeamsSettings.selected))
		FauxScrollFrame_Update(self.scrollBar, maxValue, maxRows, ROW_HEIGHT)	
		
		for i = 1, maxRows do
			local value = i + offset
			if value <= maxValue then
				
				for j=1,PETS_PER_TEAM do
					
					PetBattleTeamsUI:UpdatePetButton(row[i][j],value,j,msg)
				end
			else
				for j=1,PETS_PER_TEAM do
					row[i][j]:Hide()
				end
			end
		end
		
		for i=maxRows+1,MAX_ROWS do
			for j=1,PETS_PER_TEAM do
				if row[i] and row[i][j] then
					row[i][j]:Hide()
				end
			end
		end
	end
end