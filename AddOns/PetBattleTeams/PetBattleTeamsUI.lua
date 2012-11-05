local PETS_PER_TEAM = 3
local MAX_TEAMS = 60
local ROW_HEIGHT = 44.3   
local MAX_ROWS = 24      

if not PetBattleTeamsUI then PetBattleTeamsUI = {} end

PetBattleTeamsUI.CursorEmpty = function(self)
	PetBattleTeamsUI.PetOnCursor = nil
	PetBattleTeamsUI.CursorStruct = nil
end

PetBattleTeamsUI.TeamVisible = function(self,team)
	if #PetBattleTeamsSettings.teams <= 4 then 
		return true;
	elseif self.scrollBar.offset + self:GetMaxRows() < team or self.scrollBar.offset >= team  then
		return false
	end
	return true
end

PetBattleTeamsUI.ScrollToTeam =function(self,team)
	if not self:TeamVisible(team) then
		scrollBar = _G[PetBattleTeamsUI.scrollBar:GetName() .. "ScrollBar"];
		local scrollPosition = 0
		
		if team > 0 then
			scrollPosition = (team /  #PetBattleTeamsSettings.teams) * math.ceil(self.scrollBar:GetVerticalScrollRange())
		end
		
		scrollBar:SetValue(scrollPosition);
		self:UpdateAllFrames()
	end
end

PetBattleTeamsUI.GetMaxRows =function(self)
	local extraSpace = 80
	local extraRow = 0
	local attached = PetBattleTeamsSettings:GetFrameInfo()
	if attached then
		extraSpace = 0 
		extraRow = 1
	end
	local maxRows = math.floor(((self.mainFrame:GetHeight()-extraSpace)/ROW_HEIGHT))-extraRow
	return maxRows
end

PetBattleTeamsUI.CreateUI = function(self)	
	if not self.tooltip then self.tooltip = self:CreateTooltip("PetBattleTeamTooltip")  end

	local attached, locked, x,y, height = PetBattleTeamsSettings:GetFrameInfo()
	if not self.mainFrame and (not attached or IsAddOnLoaded("Blizzard_PetJournal")) then 
		self.mainFrame = self:CreateParentFrame("PetBattleTeamBackgroundFrame")
		self.mainFrame:SetParent("UIParent")
		self.mainFrame:SetPoint("TOPLEFT",UIParent,"TOPLEFT",x,y)
		self.mainFrame:SetSize(self.mainFrame:GetWidth(), height);
		
		if not self.scrollBar then
			self.scrollBar = self:CreateScrollBar("PetBattleTeamsScroll",self.mainFrame)
			PetBattleTeamsUI:UpdateScrollBar()
		end
	end
end

PetBattleTeamsUI.PickupPetHook = function(petID,isWild)
	PetBattleTeamsUI.PetOnCursor = petID
	PetBattleTeamsUI.CursorStruct = nil
	PetBattleTeamsUI:UpdateAllFrames()
end

hooksecurefunc(C_PetJournal,"PickupPet",PetBattleTeamsUI.PickupPetHook)

