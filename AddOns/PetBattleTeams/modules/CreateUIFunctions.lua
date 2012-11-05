local M = icrowMedia

-- localization
local L = {
	TITLE = "Pet Battle Teams",
	ATTACH = "Attach to Pet Journal",
	LOCK = "Lock Location",
	CLOSE = "Close Menu",
	ADD = "Click to add a new team",
	FULL = "At maximum number of teams",
}

if GetLocale() == "zhCN" then
	L.TITLE = "宠物战队管理"
	L.ATTACH = "吸附到宠物手册"
	L.LOCK = "锁定位置"
	L.CLOSE = "关闭菜单"
	L.ADD = "点击以添加新的战队"
	L.FULL = "战队数量已满"
elseif GetLocale() == "zhTW" then
	L.TITLE = "戰寵隊伍管理"
	L.ATTACH = "吸附到戰寵手冊"
	L.LOCK = "鎖定位置"
	L.CLOSE = "關閉菜單"
	L.ADD = "點擊以添加新的隊伍"
	L.FULL = "隊伍數量已滿"
end

local PETS_PER_TEAM = 3
local MAX_TEAMS = 60
local ROW_HEIGHT = 44.3   
local MAX_ROWS = 24      

if not PetBattleTeamsUI then PetBattleTeamsUI = {} end

PetBattleTeamsUI.DropDownOnLoad=function(self,level)
	local info = XUIDropDownMenu_CreateInfo()
	info.isNotRadio = true
	
	info.text = L.ATTACH
	info.func = function(_, _, _, value) 
		local attached , locked = PetBattleTeamsSettings:GetFrameInfo()
		
		if not value then
			PetBattleTeamsSettings:SetFrameInfo(true, false)
		else
			PetBattleTeamsSettings:SetFrameInfo(false, locked)
			
			if #PetBattleTeamsSettings.teams <= 12 then
				PetBattleTeamsUI.mainFrame:SetHeight(ROW_HEIGHT * #PetBattleTeamsSettings.teams +90)
			end
		end
		PetBattleTeamsUI:UpdateAllFrames()
	end
	info.checked = function() return select(1,PetBattleTeamsSettings:GetFrameInfo()) end
	XUIDropDownMenu_AddButton(info, level)
	
	info.text = L.LOCK
	info.func = function(_, _, _, value)  
		local attached , locked = PetBattleTeamsSettings:GetFrameInfo()
		PetBattleTeamsSettings:SetFrameInfo(attached, not value)
		PetBattleTeamsUI:UpdateAllFrames()
	end
	info.checked = function()  return select(2,PetBattleTeamsSettings:GetFrameInfo()) end
	XUIDropDownMenu_AddButton(info, level)
	
	info.notCheckable = true
	info.text = L.CLOSE
	info.func = nil
	XUIDropDownMenu_AddButton(info, level)
end

PetBattleTeamsUI.CreateReviveButton =function(self,name,parent)
	local HEAL_PET_SPELL = 125439
	local spellName, spellSubname, spellIcon = GetSpellInfo(HEAL_PET_SPELL)
	local start, duration, enable = GetSpellCooldown(HEAL_PET_SPELL)
	
	button = CreateFrame("Button",name,parent,"secureactionbuttontemplate")
	button:SetAttribute("type", "spell")
	button.spellID = HEAL_PET_SPELL
	button:SetAttribute("spell",spellName)
	button:SetSize(40,40)
	
	button.Icon = button:CreateTexture(name.."Icon","ARTWORK")
	button.Icon:SetTexture(spellIcon)
	button.Icon:SetAllPoints()
	
	button.Border = button:CreateTexture(name.."Border","OVERLAY","ActionBarFlyoutButton-IconFrame")
	button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square","ADD")
	
	button.Cooldown = CreateFrame("Cooldown", name.."Cooldown",button, "CooldownFrameTemplate")
	CooldownFrame_SetTimer(button.Cooldown, start, duration, enable)
	
	button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	
	button:SetScript("OnEvent", function(self,event,...) 
		if event == "SPELL_UPDATE_COOLDOWN"  then
			local start, duration, enable = GetSpellCooldown(self.spellID)
			CooldownFrame_SetTimer(self.Cooldown, start, duration, enable)
			if ( GameTooltip:GetOwner() == self ) then
				--cheat and use blizzards tooltip setup
				PetJournalHealPetButton_OnEnter(self)
			end
		end
	end)
	
	button:SetScript("OnShow", function(self) 
		self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	end)
	button:SetScript("OnHide",function(self) 
		self:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
	end)
	
	button:SetScript("OnEnter", PetJournalHealPetButton_OnEnter )
	button:SetScript("OnLeave",function()  GameTooltip:Hide() end)
	return button
end

PetBattleTeamsUI.CreateTooltip = function(self,name)
	local tooltip = CreateFrame("Frame",name,nil,"PetBattleUnitTooltipTemplate")
	tooltip:SetHeight(225)
	
	tooltip:DisableDrawLayer("BACKGROUND")
	tooltip:DisableDrawLayer("BORDER")
	local bg = CreateFrame("Frame", nil, tooltip)
	bg:SetAllPoints()
	bg:SetFrameLevel(0)
	M.CreateBG(bg)
	tooltip.Delimiter:SetHeight(1)
	tooltip.Delimiter:SetVertexColor(0, 0, 0, 1)
	
	--icon quality glow
	tooltip.rarityGlow = tooltip:CreateTexture("PetBattleTeamTooltipGlow","OVERLAY")
	tooltip.rarityGlow:SetTexture("Interface\\Buttons\\CheckButtonHilight")
	tooltip.rarityGlow:SetBlendMode("ADD")
	tooltip.rarityGlow:ClearAllPoints()
	tooltip.rarityGlow:SetDrawLayer("OVERLAY", 0)
	tooltip.rarityGlow:SetPoint("TOPLEFT", tooltip.Icon)
	tooltip.rarityGlow:SetPoint("BOTTOMRIGHT", tooltip.Icon)
	
	--team indicator
	tooltip.teamText = tooltip:CreateFontString("PetBattleTeamTooltipTeamText","OVERLAY")
	tooltip.teamText:SetJustifyH("CENTER")
	tooltip.teamText:SetFont("Fonts\\FRIZQT__.TTF",10,"MONOCHROMEOUTLINE")
	tooltip.teamText:SetText("")
	tooltip.teamText:SetTextColor(1,1,1)
	tooltip.teamText:SetSize(0,0)
	tooltip.teamText:SetPoint("BOTTOMLEFT",tooltip.Name,"TOPLEFT",0,2)

	--template parts
	tooltip.AbilitiesLabel:Show()
	tooltip.XPBar:Show()
	tooltip.XPBG:Show()
	tooltip.XPBorder:Show()
	tooltip.XPText:Show()
	tooltip.teamText:Show()
	tooltip.WeakToLabel:Hide()
	tooltip.ResistantToLabel:Hide()
	
	return tooltip
end

PetBattleTeamsUI.CreateMenuButton = function(self,name,parent)
	local button = CreateFrame("BUTTON",name,parent)
	button.menu = CreateFrame("FRAME",name,button,"XUIDropDownMenuTemplate")
	button.menu:SetPoint("TOPRIGHT",button,"BOTTOMLEFT",0,0)

	XUIDropDownMenu_Initialize(button.menu, PetBattleTeamsUI.DropDownOnLoad, "MENU")

	button:EnableMouse(true)
	button:SetSize(33,33)
	button:ClearAllPoints()
	
	button.icon = button:CreateTexture("PetBattleTeambuttonButtonIcon","ARTWORK")
	button.icon:SetTexture("Interface\\Icons\\INV_PET_BATTLEPETTRAINING")
	button.icon:SetSize(21,21)
	button.icon:ClearAllPoints()
	button.icon:SetPoint("TOPLEFT",button,"TOPLEFT",7,-6)
	
	button.overlay = button:CreateTexture("PetBattleTeambuttonButtonIcon","OVERLAY")
	button.overlay:SetTexture("Interface\\MiniMap\\MiniMap-TrackingBorder")
	button.overlay:SetSize(56,56)
	button.overlay:ClearAllPoints()
	button.overlay:SetPoint("TOPLEFT",button,"TOPLEFT")
	
	button:SetHighlightTexture("Interface\\MiniMap\\UI-MiniMap-ZoomButton-Highlight","ADD")
	button:RegisterForClicks("LeftButtonUp","RightButtonUp")
	button:SetScript("OnClick", function(self,button) 		
			XToggleDropDownMenu(1, nil, self.menu, self,20,7)
	end)
	return button
end

PetBattleTeamsUI.CreateParentFrame = function(self,name)
	local frame = CreateFrame("Frame", name, UIParent)
	frame:SetClampedToScreen(true)
	frame:SetFrameStrata("MEDIUM")
	frame:SetToplevel(true) 
	frame:SetSize(181,614)
	frame:RegisterForDrag("LeftButton")
	frame:EnableMouse(true)
	local bg = M.CreateBG(frame)
	local sd = M.CreateSD(frame)
	bg:SetPoint("TOPLEFT", 7, -4)
	bg:SetPoint("BOTTOMRIGHT", -7, 4)
	sd:SetPoint("TOPLEFT", 4, -1)
	sd:SetPoint("BOTTOMRIGHT", -4, 1)
	
	frame:SetMaxResize(frame:GetWidth(),frame:GetHeight())
	frame:SetMinResize(frame:GetWidth(),ROW_HEIGHT*1+90)
	
	--frame label
	frame.name = frame:CreateFontString(name.."Title","OVERLAY","GameFontNormal")
	frame.name:SetJustifyH("CENTER")
	frame.name:SetText(L.TITLE)
	frame.name:SetSize(0,0)
	frame.name:SetPoint("CENTER",frame,"TOP",0,-15)
	
	--upper right menu button
	frame.menu = self:CreateMenuButton(name.."Menu",frame)
	frame.menu:SetParent(frame)
	frame.menu:ClearAllPoints()
	frame.menu:SetPoint("TOPRIGHT",frame,"TOPRIGHT",8,8)

	frame.addTeamButton = self:CreateAddTeamButton("PetBattleTeamAddTeamButton",frame)
	frame.addTeamButton:Show()
	frame.petUnitFrames = self:CreatePetUnitFrames(frame)
	frame.revivePetsButton = self:CreateReviveButton("PetBattleTeamReviveButton",frame)
	
	frame.resizeButton = CreateFrame("Button",nil,frame)
	frame.resizeButton:EnableMouse(true)
	frame.resizeButton:SetSize(20,20)
	frame.resizeButton:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-6,6)
	frame.resizeButton.icon = frame.resizeButton:CreateTexture(nil,"ARTWORK")
	frame.resizeButton.icon:SetTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
	frame.resizeButton.icon:SetAllPoints(frame.resizeButton)
	frame.resizeButton:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Highlight","ADD")
	frame.resizeButton:SetPushedTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")
	frame.resizeButton:RegisterForDrag("LeftButton","RightButton")
	--frame.resizeButton:RegisterForClicks("LeftButtonUp","RightButtonUp")
	
	frame.GotoTeamButton = CreateFrame("Frame",nil,frame);
	frame.GotoTeamButton:SetSize(36,36);
	frame.GotoTeamButton:SetPoint("CENTER",frame,"BOTTOM",-6,30)
	frame.GotoTeamButton.icon = frame.GotoTeamButton:CreateTexture(nil,"OVERLAY") 
	frame.GotoTeamButton.icon:SetSize(36,36)
	frame.GotoTeamButton.icon:SetTexture("Interface\\PetBattles\\PetJournal")
	frame.GotoTeamButton.icon:SetTexCoord(0.11328125,0.16210938,0.02246094,0.04687500)
	frame.GotoTeamButton.icon:SetAllPoints(frame.GotoTeamButton)
	frame.GotoTeamButton:EnableMouse(true)
	
	
	--got team button
	frame.GotoTeamButton:SetScript("OnMouseUp",function(self) 
		PetBattleTeamsUI:ScrollToTeam(PetBattleTeamsSettings.selected)
	end)
	
	frame.GotoTeamButton:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:ClearLines()
		
		GameTooltip:AddLine("Click to Scroll to your current team")
		
		GameTooltip:Show()
	end)
	frame.GotoTeamButton:SetScript("OnLeave",function(self)
		GameTooltip:Hide()
	end)
	
	
	
	--resizing
	frame:SetScript("OnSizeChanged",function(self) 
		PetBattleTeamsUI:UpdateAllFrames()
	end)
	
	frame.resizeButton:SetScript("OnDragStart",function(self)
		local attached, locked = PetBattleTeamsSettings:GetFrameInfo()
		if not attached and not locked then
			
			frame:SetResizable(true) 
			frame:StartSizing() 
		end
	end)
	frame.resizeButton:SetScript("OnDragStop",function(self)
		frame:StopMovingOrSizing()
		frame:SetResizable(false) 
		
		frame:SetSize(frame:GetWidth(), ROW_HEIGHT*PetBattleTeamsUI:GetMaxRows()+90)
	end)
	return frame
end

PetBattleTeamsUI.CreateAddTeamButton = function(self,name,parent)
	local button = CreateFrame("Button", name, parent)
	button:SetSize(30,30)
	
	button.icon = button:CreateTexture(name.."Icon","ARTWORK")
	button.icon:SetTexture("Interface\\Icons\\Spell_ChargePositive")
	button.icon:SetTexCoord(0.03,0.97,0.03,0.97)
	button.icon:SetAllPoints(button)
	M.CreateBG(button, 0)
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square","ADD")
	button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	button:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L.ADD)
		if #PetBattleTeamsSettings.teams >= MAX_TEAMS then
			GameTooltip:AddLine(L.FULL,1,0,0,true)
		end
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave",function(self)
		GameTooltip:Hide()
	end)
	
	button:SetScript("OnClick",function(self) 
		PetBattleTeams:CreateNewTeam()
		PetBattleTeamsUI:UpdateAllFrames()
	end)
	
	return button
end

PetBattleTeamsUI.CreatePetButton = function(self,team,petIndex,parent)
	
	local parentName = "PetTeam"..team.."Button"..petIndex
	local button = CreateFrame("Button", parentName, parent, "PetBattleMiniUnitFrameAlly")
	button:EnableMouse(true)
	button.team = team
	button.petIndex = petIndex
	
	-- this is wrong but works and is to ingrained to fix.
	button:SetSize(39,39)
	button.HealthBarBG:SetAlpha(0)
	button.BorderAlive:SetAlpha(0)
	button.ActualHealthBar:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
	button.ActualHealthBar:ClearAllPoints()
	button.ActualHealthBar:SetPoint("BOTTOMLEFT", 1, 1)
	button.HealthDivider:SetAlpha(0)
	-- end bad code
	
	button.healthBarWidth = 37
	
	button.ActualHealthBar.color = {button.ActualHealthBar:GetVertexColor()}
	
	button.rarityGlow = button:CreateTexture(parentName.."Glow","ARTWORK") 
	button.rarityGlow:SetTexture("Interface\\Buttons\\CheckButtonHilight")
	button.rarityGlow:SetBlendMode("ADD")
	button.rarityGlow:ClearAllPoints()
	button.rarityGlow:SetDrawLayer("ARTWORK", 0)
	button.rarityGlow:SetPoint("TOPLEFT", button.Icon)
	button.rarityGlow:SetPoint("BOTTOMRIGHT", button.Icon)
	
	button.level = button:CreateFontString(parentName.."Level","OVERLAY")
	button.level:SetJustifyH("RIGHT")
	button.level:SetFont("Fonts\\FRIZQT__.TTF",10,"MONOCHROMEOUTLINE")
	button.level:SetText("")
	button.level:SetSize(0,0)
	button.level:SetPoint("BOTTOMRIGHT",button.Icon,"BOTTOMRIGHT",0,10)
	
	button.selected = button:CreateTexture(parentName.."Selected","OVERLAY") 
	button.selected:SetSize(36,36)
	button.selected:SetTexture("Interface\\PetBattles\\PetJournal")
	button.selected:SetTexCoord(0.11328125,0.16210938,0.02246094,0.04687500)
	button.selected:SetPoint("CENTER",button,"LEFT",0,0)
	button.selected:Hide()
	
	button:SetScript("OnLoad",nil)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetScript("OnClick", function(self,button) 
		
		local info, petID = GetCursorInfo()
		
		if ( button == "RightButton" ) then
				StaticPopup_Show("PBT_TEAM_DELETE",self.team,nil,self.team)
		elseif button == "LeftButton" then
			if info and info == "battlepet" then
				local success = false
				if PetBattleTeamsUI.CursorStruct and PetBattleTeamsUI.CursorStruct.sourceTeam then
					success = PetBattleTeams:UpdateTeamSwapPets(self.team,self.petIndex, PetBattleTeamsUI.CursorStruct.sourceTeam,PetBattleTeamsUI.CursorStruct.soucePetIndex)
				else
					success = PetBattleTeams:UpdateTeamNewPet(petID,self.team,self.petIndex) -- UpdateTeamNewPet =function(self,petID,team,petIndex)
				end
				if success then
					ClearCursor()
					PetBattleTeamsUI:CursorEmpty()
				end
			else
				PetBattleTeams:SetTeam(self.team)
			end
			
			if IsShiftKeyDown() then
				local petLink = C_PetJournal.GetBattlePetLink(self.petID)
				ChatEdit_InsertLink(petLink)
			end
			
			PetBattleTeamsUI:UpdateAllFrames()
		end
	end)
	
	button:SetScript("OnReceiveDrag", function(self,button) 
		local info, petID = GetCursorInfo()
		if info and info == "battlepet" then
			local success = false
			if PetBattleTeamsUI.CursorStruct and PetBattleTeamsUI.CursorStruct.sourceTeam then
				success = PetBattleTeams:UpdateTeamSwapPets(self.team,self.petIndex, PetBattleTeamsUI.CursorStruct.sourceTeam, PetBattleTeamsUI.CursorStruct.soucePetIndex)
			else
				success = PetBattleTeams:UpdateTeamNewPet(petID,self.team,self.petIndex) -- UpdateTeamNewPet =function(self,petID,team,petIndex)
			end
			if success then
				ClearCursor()
				PetBattleTeamsUI:CursorEmpty()
				PetBattleTeamsUI:UpdateAllFrames()
			end
		end
		
	end)
	
	button:RegisterForDrag("LeftButton")
	
	button:SetScript("OnDragStart", function(self,button)
		C_PetJournal.PickupPet(self.petID, false)
		PetBattleTeamsUI.CursorStruct = {}
		PetBattleTeamsUI.CursorStruct.sourceTeam = self.team
		PetBattleTeamsUI.CursorStruct.soucePetIndex = self.petIndex
		PetBattleTeamsUI:UpdateAllFrames()
	end)

	button:SetScript("OnEnter",function(self) 
		if C_PetJournal.GetPetInfoByPetID(self.petID) then
			local tooltip = PetBattleTeamsUI.tooltip
			tooltip:SetParent(self)
			tooltip:SetFrameStrata("TOOLTIP")
			tooltip:ClearAllPoints()
			
			tooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0)
			local left, bottom, width, height = tooltip:GetBoundsRect()
			
			if left + width > GetScreenWidth() then 
				tooltip:ClearAllPoints()
				tooltip:SetPoint( "TOPRIGHT", self, "BOTTOMLEFT", 0, 0)
			end
			if bottom < 0 then
				tooltip:ClearAllPoints()
				tooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 0)
			end

			PetBattleTeamsUI:TooltipSetUnit(PetBattleTeamsUI.tooltip, self.petID, self.team, self.petIndex)
			tooltip:Show()
		end
	end)
	
	button:SetScript("OnLeave",function(self)
		if ( PetBattleTeamsUI.tooltip:GetParent() == self ) then
			PetBattleTeamsUI.tooltip:Hide()
		end
	end)
	button:UnregisterAllEvents()
	return button
end

PetBattleTeamsUI.CreatePetUnitFrames = function(self,parent)
	local unitFrames = {}
	for team=1,MAX_ROWS do 
		local buttons = {}
		for petIndex =1, PETS_PER_TEAM do 
			button = self:CreatePetButton(team,petIndex,parent)
			
			if petIndex==1 and team == 1 then
				
				button:SetPoint("TOPLEFT", parent ,"TOPLEFT",20,-30)
				--button:SetPoint("TOPLEFT", parent ,"TOPLEFT",17,)
			elseif petIndex == 1 and team > 1 then
				button:SetPoint("TOPLEFT","PetTeam"..(team-1).."Button"..petIndex,"BOTTOMLEFT",0,-4)
			else
				button:SetPoint("LEFT","PetTeam"..team.."Button"..petIndex-1,"RIGHT",5,0)
			end
			
			table.insert(buttons,button)
		end
		table.insert(unitFrames,buttons)
	end
	
	return unitFrames
end

PetBattleTeamsUI.CreateScrollBar = function(self,name,parent)
	frame = CreateFrame("ScrollFrame",name,parent,"FauxScrollFrameTemplate")
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", 0, -30)
	frame:SetPoint("BOTTOMRIGHT", -30, 60)
	frame:EnableMouse(false)
	frame:SetScript("OnVerticalScroll",function(self,offset)
		scrollBar = _G[PetBattleTeamsUI.scrollBar:GetName() .. "ScrollBar"];
		self.offset = math.floor(offset / ROW_HEIGHT + 0.5)
		scrollBar:SetValue(offset)
		PetBattleTeamsUI:UpdateScrollBar()
	end)
	frame:SetScript("OnShow",function(self) 
		PetBattleTeamsUI:UpdateScrollBar()
	end)
	return frame
end