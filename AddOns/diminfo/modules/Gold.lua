--------------------------------------------------------------------
-- GOLD
--------------------------------------------------------------------
local addon, ns = ...
local cfg = ns.cfg
local init = ns.init
local panel = CreateFrame("Frame", nil, UIParent)
local _

if cfg.Gold == true then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	local Text  = panel:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.GoldPoint))

	local Profit	= 0
	local Spent		= 0
	local OldMoney	= 0
	local NewMoney
	local Change

	local function formatMoney(money)
		local gold = floor(abs(money) / 10000)
		local silver = mod(floor(abs(money) / 100), 100)
		local copper = mod(floor(abs(money)), 100)
		if gold ~= 0 then
			return format("%s".."|cffffd700g|r".." %s".."|cffc7c7cfs|r".." %s".."|cffeda55fc|r", gold, silver, copper)
		elseif silver ~= 0 then
			return format("%s".."|cffc7c7cfs|r".." %s".."|cffeda55fc|r", silver, copper)
		else
			return format("%s".."|cffeda55fc|r", copper)
		end
	end
	
	local function formatTextMoney(money)
		return format("|cffffd700%.0f|r%s", money * 0.0001, "g")
	end

	local function FormatTooltipMoney(money)
		local gold, silver, copper = abs(money / 10000), abs(mod(money / 100, 100)), abs(mod(money, 100))
		local cash = ""
		cash = format("%d".."|cffffd700g|r".." %d".."|cffc7c7cfs|r".." %d".."|cffeda55fc|r", gold, silver, copper)		
		return cash
	end	

	local function OnEvent(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			self:RegisterEvent("PLAYER_MONEY")
			self:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
			self:RegisterEvent("SEND_MAIL_COD_CHANGED")
			self:RegisterEvent("PLAYER_TRADE_MONEY")
			self:RegisterEvent("TRADE_MONEY_CHANGED")
			-- Setup Money Tooltip
			OldMoney = GetMoney()
			local myPlayerRealm = GetCVar("realmName");
			local myPlayerName  = UnitName("player");				
			if (diminfo.gold == nil) then diminfo.gold = {}; end
			if (diminfo.gold[myPlayerRealm]==nil) then diminfo.gold[myPlayerRealm]={}; end
			diminfo.gold[myPlayerRealm][myPlayerName] = GetMoney();

			self:SetScript("OnEnter", function()
				GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 6);
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 1)
				GameTooltip:ClearLines()
				GameTooltip:AddLine(CURRENCY,0,.6,1)
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine("Session: ",.6,.8,1)
				GameTooltip:AddDoubleLine(infoL["Earned:"], formatMoney(Profit), 1, 1, 1, 1, 1, 1)
				GameTooltip:AddDoubleLine(infoL["Spent:"], formatMoney(Spent), 1, 1, 1, 1, 1, 1)
				if Profit < Spent then
					GameTooltip:AddDoubleLine(infoL["Deficit:"], formatMoney(Profit-Spent), 1, 0, 0, 1, 1, 1)
				elseif (Profit-Spent)>0 then
					GameTooltip:AddDoubleLine(infoL["Profit:"], formatMoney(Profit-Spent), 0, 1, 0, 1, 1, 1)
				end				
				GameTooltip:AddLine(' ')								
			
				local totalGold = 0				
				GameTooltip:AddLine("Character: ",.6,.8,1)			
				local thisRealmList = diminfo.gold[myPlayerRealm];
				for k, v in pairs(thisRealmList) do
					GameTooltip:AddDoubleLine(k, FormatTooltipMoney(v), 1, 1, 1, 1, 1, 1)
					totalGold=totalGold+v;
				end 
				GameTooltip:AddLine(' ')
				GameTooltip:AddLine("Server: ",.6,.8,1)
				GameTooltip:AddDoubleLine(infoL["Total"]..": ", FormatTooltipMoney(totalGold), 1, 1, 1, 1, 1, 1)

				for i = 1, MAX_WATCHED_TOKENS do
					local name, count, extraCurrencyType, icon, itemID = GetBackpackCurrencyInfo(i)
					if name and i == 1 then
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine(CURRENCY)
					end
					local r, g, b = 1,1,1
					if itemID then r, g, b = GetItemQualityColor(select(3, GetItemInfo(itemID))) end
					if name and count then GameTooltip:AddDoubleLine(name, count, r, g, b, 1, 1, 1) end
				end
				GameTooltip:Show()
			end)
			self:SetScript("OnLeave", function() GameTooltip:Hide() end)
		end
		
		NewMoney = GetMoney()
		Change = NewMoney - OldMoney -- Positive if we gain money
		
		if OldMoney > NewMoney then		-- Lost Money
			Spent = Spent - Change
		else							-- Gained Moeny
			Profit = Profit + Change
		end
		OldMoney = NewMoney;
		Text:SetText(formatTextMoney(NewMoney))
		self:SetAllPoints(Text)
	end
	
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			ToggleCharacter("TokenFrame")
		else
			ToggleAllBags()
		end
	end)
	Stat:SetScript("OnEvent", OnEvent)
	
	-- reset gold diminfo
	local function RESETGOLD()
		local myPlayerRealm = GetCVar("realmName");
		local myPlayerName  = UnitName("player");
		
		diminfo.gold = {}
		diminfo.gold[myPlayerRealm]={}
		diminfo.gold[myPlayerRealm][myPlayerName] = GetMoney();
	end
	SLASH_RESETGOLD1 = "/resetgold"
	SlashCmdList["RESETGOLD"] = RESETGOLD
end