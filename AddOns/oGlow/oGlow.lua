-- Based on oGlow by Haste

-- pixel perfect script of custom ui scale.
local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/UIParent:GetEffectiveScale()
local function scale(x)
    return mult*math.floor(x/mult+.5)
end
function Scale(x) return scale(x) end
mult = mult

local function Kill(object)
	if object.IsProtected then 
		if object:IsProtected() then
			error("Attempted to kill a protected object: <"..object:GetName()..">")
		end
	end
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = function() return end
	object:Hide()
end

local function UpdateGlow(button, id)
	local quality, texture, _
	if(id) then
		quality, _, _, _, _, _, _, texture = select(3, GetItemInfo(id))
	end

	local glow = button.glow
	if(not glow) then
		button.glow = glow
		glow = button:CreateTexture(nil, "OVERLAY")
		glow:SetPoint("TOPLEFT", -mult, mult)
		glow:SetPoint("BOTTOMRIGHT", mult, -mult)
		glow:SetTexture("Interface\\AddOns\\oGlow\\CheckButtonHilight1")
		button.glow = glow
	end

	if texture then
		local r, g, b
			r, g, b = GetItemQualityColor(quality)
			if (r == g and g == b) then r, g, b = 0, 0, 0 end
		glow:SetVertexColor(r, g, b)
		glow:Show()
	else
		glow:Hide()
	end
end

hooksecurefunc("ContainerFrame_Update", function(self)
	local name = self:GetName()
	local id = self:GetID()
	local isQuestItem, questId, isActive, questTexture

	for i=1, self.size do
		local button = _G[name.."Item"..i]
		local itemID = GetContainerItemID(id, button:GetID())
		questTexture = _G[name.."Item"..i.."IconQuestTexture"]
		Kill(questTexture)
		UpdateGlow(button, itemID)
		isQuestItem, questId, isActive = GetContainerItemQuestInfo(id, button:GetID())
		if ( questId and not isActive ) then
			button.glow:SetVertexColor(1, 1, 0, 1)
		elseif ( questId or isQuestItem ) then
			button.glow:SetVertexColor(1, 0, 0, 1)
		end
	end
end)

hooksecurefunc("BankFrameItemButton_Update", function(button)
		local itemID = GetContainerItemID(BANK_CONTAINER, button:GetID())
		local questTexture = _G[button:GetName().."IconQuestTexture"]
		if questTexture then Kill(questTexture)	end
		UpdateGlow(button, itemID)
		local isQuestItem, questId, isActive = GetContainerItemQuestInfo(BANK_CONTAINER, button:GetID())
		if ( questId and not isActive ) then
			button.glow:SetVertexColor(1, 1, 0, 1)
		elseif ( questId or isQuestItem ) then
			button.glow:SetVertexColor(1, 0, 0, 1)
		end
end)

local slots = {
	"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
	"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
	"SecondaryHand", "Tabard",
}

local updatechar = function(self)
	if CharacterFrame:IsShown() then
		for key, slotName in ipairs(slots) do
			-- Ammo is located at 0.
			local slotID = key % 20
			local slotFrame = _G['Character' .. slotName .. 'Slot']
			local slotLink = GetInventoryItemLink('player', slotID)

			UpdateGlow(slotFrame, slotLink)
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f:SetScript("OnEvent", updatechar)
CharacterFrame:HookScript('OnShow', updatechar)

local updateinspect = function(self)
	local unit = InspectFrame.unit
	if InspectFrame:IsShown() and unit then
		for key, slotName in ipairs(slots) do
			local slotID = key % 20
			local slotFrame = _G["Inspect"..slotName.."Slot"]
			local slotLink = GetInventoryItemLink(unit, slotID)
			UpdateGlow(slotFrame, slotLink)
		end
	end
end

local last = 0
local OnUpdate = function(self, elapsed)
	last = last + elapsed
	if last >= 1 then
		self:SetScript("OnUpdate", nil)
		last = 0
		updateinspect()
	end
end

local startinspect = function()
	updateinspect()
	InspectFrame:SetScript("OnUpdate", OnUpdate)
end

local g = CreateFrame("Frame")
g:RegisterEvent("ADDON_LOADED")
g:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_InspectUI" then
	InspectFrame:HookScript("OnShow", function()
		g:RegisterEvent("PLAYER_TARGET_CHANGED")
		g:RegisterEvent("INSPECT_READY")
		g:SetScript("OnEvent", startinspect)
	end)
	InspectFrame:HookScript("OnHide", function()
		g:UnregisterEvent("PLAYER_TARGET_CHANGED")
		g:UnregisterEvent("INSPECT_READY")
		g:SetScript("OnEvent", nil)
		InspectFrame:SetScript("OnUpdate", nil)
	end)

		g:UnregisterEvent("ADDON_LOADED")
	end
end)

local h = CreateFrame("Frame")
h:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
h:RegisterEvent("GUILDBANKFRAME_OPENED")
h:SetScript("OnEvent", function()
	if not IsAddOnLoaded("Blizzard_GuildBankUI") then return end

	local tab = GetCurrentGuildBankTab()
	for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local index = math.fmod(i, 14)
		if index == 0 then
			index = 14
		end
		local column = math.ceil((i-0.5)/14)

		local slotLink = GetGuildBankItemLink(tab, i)
		local slotFrame = _G["GuildBankColumn"..column.."Button"..index]

		UpdateGlow(slotFrame, slotLink)
	end
end)