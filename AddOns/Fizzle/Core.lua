-- info panel config
local cfg = {
	showpanel = true,
	point = {"bottomright", UIParent, -85, 7},
	font = {"Fonts\\ROADWAY.ttf", 15, "outline"},
	autorepair = true,
}

------->> Info panel from diminfo
local panel = CreateFrame("Frame", nil, UIParent)

if cfg.showpanel == true then

	panel.stat = CreateFrame("Frame")
	panel.stat:EnableMouse(true)
	panel.stat:SetFrameStrata("BACKGROUND")
	panel.stat:SetFrameLevel(3)

	panel.text = panel:CreateFontString(nil, "OVERLAY")
	panel.text:SetFont(unpack(cfg.font))
	panel.text:SetPoint(unpack(cfg.point))

	panel.stat:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			ToggleCharacter("PaperDollFrame")
		else
			if not PlayerTalentFrame then
				LoadAddOn("Blizzard_TalentUI")
			end
			ToggleFrame(PlayerTalentFrame)
		end
	end)
end

----------------->> our item slot tables
local items = {
	"Head",
	"Shoulder",
	"Chest",
	"Waist",
	"Legs",
	"Feet",
	"Wrist",
	"Hands",
	"MainHand",
	"SecondaryHand",
}

local function gradient(perc)
	perc = perc > 1 and 1 or perc < 0 and 0 or perc -- Stay between 0-1
	local seg, relperc = math.modf(perc*2)
	local r1,g1,b1,r2,g2,b2 = select(seg*3+1,1,0,0,1,1,0,0,1,0,0,0,0) -- R -> Y -> G
	local r,g,b = r1+(r2-r1)*relperc,g1+(g2-g1)*relperc,b1+(b2-b1)*relperc
	return format("|cff%02x%02x%02x",r*255,g*255,b*255),r,g,b
end

local function CreateStr(slottype, slot, name)
	local gslot = _G[slottype..slot.."Slot"]
	if gslot then
		local str = gslot:CreateFontString(slot .. name .. "S", "OVERLAY")
		local font = "Fonts\\FRIZQT__.ttf"
		str:SetFont(font, 10, "MONOCHROMEOUTLINE")
		str:SetPoint("CENTER", gslot, "BOTTOM", 1, 5)
	end
end

local function MakeTypeTable()
	for _, item in ipairs(items) do
		CreateStr("Character", item, "Fizzle")
	end
end

local function GetThresholdColour(percent)
	if percent < 0 then
		return 1, 0, 0
	elseif percent <= 0.5 then
		return 1, percent * 2, 0
	elseif percent >= 1 then
		return 0, 1, 0
	else
		return 2 - percent * 2, 1, 0
	end
end

local function Fizzle_UpdateItems()
	-- Go and set the durability string for each slot that has an item equipped that has durability.
	-- Thanks Tekkub again for the base of this code.
	local Total = 0
	local current = 0
	local max = 0
	for _, item in ipairs(items) do
		local id, _ = GetInventorySlotInfo(item .. "Slot")
		local str = _G[item.."FizzleS"]
		local v1, v2 = GetInventoryItemDurability(id)
		v1, v2 = tonumber(v1) or 0, tonumber(v2) or 0
		current = current + v1
		max = max + v2
		if v2 ~= 0 then	
			local percent = v1 / v2 * 100
			-- Colour our string depending on current durability percentage
			str:SetTextColor(GetThresholdColour(v1/v2))
			str:SetFormattedText("%d%%", percent)
			Total = Total + 1
		else
			-- No durability in slot, so hide the text.
			str:SetText(nil)
		end
	end
	if cfg.showpanel then
		if Total > 0 then
			panel.text:SetText(format(gradient(floor(current/max*100)/100).."%d|r%%d", floor(current/max*100)))
		else
			panel.text:SetText("-%d")
		end
		panel.stat:SetAllPoints(panel.text)
	end
end

-- main
local Fizzle = CreateFrame("Frame", "Fizzle", CharacterFrame)
Fizzle:RegisterEvent("PLAYER_ENTERING_WORLD")
Fizzle:Show()

Fizzle:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("UNIT_INVENTORY_CHANGED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("MERCHANT_SHOW")
		self:RegisterEvent("MERCHANT_CLOSED")
		MakeTypeTable()
	end
	if event == "UNIT_INVENTORY_CHANGED" then
		local unitId = select(1, ...)
		if unitId ~= "player" then return end
	end
	if event == "MERCHANT_SHOW" then
		self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	end
	if event == "MERCHANT_CLOSED" then
		self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
		return
	end
	Fizzle_UpdateItems()
end)

Fizzle:SetScript("OnHide", function(self)
	self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	collectgarbage("collect")
end)

Fizzle:SetScript("OnShow", function(self)
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	Fizzle_UpdateItems()
end)

--自动修理部分(优先使用公会修理)
local g = CreateFrame("Frame")
g:RegisterEvent("MERCHANT_SHOW")
g:SetScript("OnEvent", function()    
	if (cfg.autorepair == true and CanMerchantRepair()) then
		local cost = GetRepairAllCost()
		if cost > 0 then
			local money = GetMoney()
			if IsInGuild() then
				local guildMoney = GetGuildBankWithdrawMoney()
				if guildMoney > GetGuildBankMoney() then
					guildMoney = GetGuildBankMoney()
				end
				if guildMoney > cost and CanGuildBankRepair() then
					RepairAllItems(1)
					print(format("|cff99CCFF你偷偷用了公会修理: |r|cffFFFFFF%.1f|r|cffffd700%s|r", cost * 0.0001,GOLD_AMOUNT_SYMBOL))
					return
				end
			end
			if money > cost then
				RepairAllItems()
				print(format("|cff99CCFF修理花费: |r|cffFFFFFF%.1f|r|cffffd700%s|r", cost * 0.0001,GOLD_AMOUNT_SYMBOL))
			else
				print("|cff99CCFF菜鸟连装备都修不起，快去farm吧！|r")
			end
		end
	end
end)