local wow_version, wow_build, wow_data, tocversion = GetBuildInfo()
wow_build = tonumber(wow_build)

-- Fix incorrect translations in the German Locale.  For whatever reason
-- Blizzard changed the oneletter time abbreviations to be 3 letter in
-- the German Locale.
if GetLocale() == "deDE" then
	-- This one confirmed still bugged as of Mists of Pandaria build 16030
	DAY_ONELETTER_ABBR = "%d d"
end

local Dummy = function() end

-- fixes the issue with InterfaceOptionsFrame_OpenToCategory not actually opening the Category (and not even scrolling to it)
-- Confirmed still broken in Mists of Pandaria as of build 16016 (5.0.4) 
do
	local doNotRun = false
	local function get_panel_name(panel)
		local cat = INTERFACEOPTIONS_ADDONCATEGORIES
		if ( type(panel) == "string" ) then
			for i, p in pairs(cat) do
				if p.name == panel then
					if p.parent then
						return get_panel_name(p.parent)
					else
						return panel
					end
				end
			end
		elseif ( type(panel) == "table" ) then
			for i, p in pairs(cat) do
				if p == panel then
					if p.parent then
						return get_panel_name(p.parent)
					else
						return panel.name
					end
				end
			end
		end
	end

	local function InterfaceOptionsFrame_OpenToCategory_Fix(panel)
		if InCombatLockdown() then return end
		if doNotRun then return end
		local panelName = get_panel_name(panel);
		if not panelName then return end -- if its not part of our list return early
		local noncollapsedHeaders = {}
		local shownpanels = 0
		local mypanel 
		local t = {}
		for i, panel in ipairs(INTERFACEOPTIONS_ADDONCATEGORIES) do
			if not panel.parent or noncollapsedHeaders[panel.parent] then
				if panel.name == panelName then
					panel.collapsed = true
					t.element = panel
					InterfaceOptionsListButton_ToggleSubCategories(t)
					noncollapsedHeaders[panel.name] = true
					mypanel = shownpanels + 1
				end
				if not panel.collapsed then
					noncollapsedHeaders[panel.name] = true
				end
				shownpanels = shownpanels + 1
			end
		end
		local Smin, Smax = InterfaceOptionsFrameAddOnsListScrollBar:GetMinMaxValues()
		InterfaceOptionsFrameAddOnsListScrollBar:SetValue((Smax/(shownpanels-15))*(mypanel-2))
		doNotRun = true
		InterfaceOptionsFrame_OpenToCategory(panel)
		doNotRun = false
	end
	hooksecurefunc("InterfaceOptionsFrame_OpenToCategory", InterfaceOptionsFrame_OpenToCategory_Fix)
end

-- Fix an issue where the GlyphUI depends on the TalentUI but doesn't
-- always load it.  This issue will manafest with an error like this:
-- attempt to index global "PlayerTalentFrame" (a nil value)
-- More details and the report to Blizzard here:
-- http://us.battle.net/wow/en/forum/topic/6470967787
if wow_build >= 16016 then
	local frame = CreateFrame("Frame")

	local function OnEvent(self, event, name)
		if event == "ADDON_LOADED" and name == "Blizzard_GlyphUI" then
			TalentFrame_LoadUI()
		end
	end

	frame:SetScript("OnEvent",OnEvent)
	frame:RegisterEvent("ADDON_LOADED")
end

-- code from Grimsin @ wowinterface.com, to fix the WorldMapBlobFrame taint issue
local GUIWorldMapEvents = CreateFrame("Frame", nil, UIParent)
GUIWorldMapEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
GUIWorldMapEvents:RegisterEvent("PLAYER_REGEN_ENABLED") 
GUIWorldMapEvents:RegisterEvent("PLAYER_REGEN_DISABLED")
 
GUIWorldMapEvents:SetScript("OnEvent", function(self)
    if event == "PLAYER_ENTERING_WORLD" then
        ToggleFrame(WorldMapFrame)
        ToggleFrame(WorldMapFrame)
		ToggleFrame(SpellBookFrame)
		ToggleFrame(SpellBookFrame)
    
    elseif event == "PLAYER_REGEN_DISABLED" then
        WatchFrame.showObjectives = nil;
        WorldMapQuestShowObjectives:SetChecked(false)
        WorldMapQuestShowObjectives:Hide()
        WorldMapTrackQuest:Hide()
        WorldMapTitleButton:Hide()
        WorldMapFrameSizeUpButton:Hide()
        WorldMapBlobFrame:Hide()
        WorldMapPOIFrame:Hide()
        
        WorldMapFrameSizeUpButton.Show = Dummy
        WorldMapQuestShowObjectives.Show = Dummy
        WorldMapTrackQuest.Show = Dummy
        WorldMapTitleButton.Show = Dummy
        WorldMapBlobFrame.Show = Dummy
        WorldMapPOIFrame.Show = Dummy
        
        WatchFrame_Update();
    
    elseif event == "PLAYER_REGEN_ENABLED" then
        
        WorldMapFrameSizeUpButton.Show = WorldMapFrameSizeUpButton:Show()
        WorldMapQuestShowObjectives.Show = WorldMapQuestShowObjectives:Show()
        WorldMapTrackQuest.Show = WorldMapTrackQuest:Show()
        WorldMapTitleButton.Show = WorldMapTitleButton:Show()
        WorldMapBlobFrame.Show = WorldMapBlobFrame:Show()
        WorldMapPOIFrame.Show = WorldMapPOIFrame:Show()
        
        WatchFrame.showObjectives = true;
        WorldMapQuestShowObjectives:SetChecked(true)
 
        WorldMapQuestShowObjectives:Show()
        WorldMapTrackQuest:Show()
        WorldMapTitleButton:Show()
        WorldMapFrameSizeUpButton:Show()
        WorldMapBlobFrame:Show()
        WorldMapPOIFrame:Show()
        
        WatchFrame_Update();
    end
end)