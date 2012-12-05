local UniquePets = {}
local LibPetJournal = LibStub("LibPetJournal-2.0")
local _
local L = {}
local initialized = false

if GetLocale() == "zhCN" then
	L["Unique Pets"]="独特宠物"
elseif GetLocale() == "zhTW" then
	L["Unique Pets"]="獨特寵物"
else
	L["Unique Pets"]="Unique Pets"
end

--Call back handler for updating unique pet count
function UniquePets:ScanPets()
	local pets = {}
	local count = 0
	for i,petID in LibPetJournal:IteratePetIDs() do
		local speciesID = C_PetJournal.GetPetInfoByPetID(petID)
		if not pets[speciesID] then
			count = count + 1
			pets[speciesID] = speciesID
		end
	end
	UniquePets.frame.uniqueCount:SetText(count)
end

local function Initialize()
	local self = UniquePets
	self.frame = CreateFrame("frame","PJEUniquePetCount",PetJournal,"InsetFrameTemplate3")

	--Create unique pet count UI elements
	local frame = self.frame;
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT",PetJournal,70,-42)
	frame:SetSize(130,18)
	frame.staticText = frame:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
	frame.uniqueCount = frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")

	frame.staticText:ClearAllPoints()
	frame.staticText:SetPoint("LEFT",frame,10,0)
	frame.staticText:SetText(L["Unique Pets"])

	frame.uniqueCount:ClearAllPoints()
	frame.uniqueCount:SetPoint("RIGHT",frame,-10,0)
	frame.uniqueCount:SetText("0")
	
	frame:Show()
	PetJournal.PetCount:SetPoint("TopLeft",70,-22)
	PetJournal.PetCount:SetSize(130,18)

	LibPetJournal.RegisterCallback(self, "PetListUpdated", "ScanPets")
	self:ScanPets()
end

PetJournal:HookScript("OnShow",function()
	if not initialized then
		Initialize()
		initialized = true
	end
end)