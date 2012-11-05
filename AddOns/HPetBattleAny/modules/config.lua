-----####Config1.22####
local _
local F, C = unpack(Aurora)
--~ Globals
local _G = getfenv(0)
local hooksecurefunc, tinsert, pairs, wipe = _G.hooksecurefunc, _G.table.insert, _G.pairs, _G.wipe
local ipairs = _G.ipairs
local C_PetJournal = _G.C_PetJournal
--~ --------

local L = HPetLocals

local HPetOption = CreateFrame("Frame","HPetOption",UIParent)

HPetOption:Hide()
tinsert(UISpecialFrames, "HPetOption")

function HPetOption:Init()
	-- init frame
	self:SetWidth(350); self:SetHeight(300);
	self:SetPoint("CENTER")
	self:SetFrameStrata("HIGH")
	self:SetToplevel(true)
	self:SetMovable(true)
	self:SetClampedToScreen(true)

	-- background
	if IsAddOnLoaded("Aurora") then
		F.SetBD(self)
	else
		self:SetBackdrop( {
		  bgFile = "Interface\\BUTTONS\\WHITE8X8",
		  edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 1,
		});
		self:SetBackdropColor(0,0,0)
	end

	-- drag
	self:EnableMouse(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart",function(self) self:StartMoving() end)
	self:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)

	-- title
	self:CreateFontString("HPetOptionTitle","ARTWORK","GameFontHighlight")
	HPetOptionTitle:SetPoint("TOP",0,-10)
	HPetOptionTitle:SetTextColor(1,1,0)
	HPetOptionTitle:SetText(L["HPet Options"])

	-- bottom title
	self:CreateFontString("HPetOptionBTitle","ARTWORK","GameFontHighlight")
	HPetOptionBTitle:SetPoint("BOTTOM",0,55)
	HPetOptionBTitle:SetTextColor(1,1,0)
	HPetOptionBTitle:SetText(L["bottom title"])

	-- buttons
	HPetOption:InitButtons()

	-- read options
	HPetOption:LoadOptions()

	-- done
	self.ready = true
end

function HPetOption:InitButtons()
	self.Buttons={
		---confing buttons
		{name="Close",type="Button",inherits="UIPanelCloseButton",
			point="TOPRIGHT",
			func=function() HPetOption:Hide() end,
		},
		{name="Reset",type="Button",inherits="UIPanelButtonTemplate",
			point="TOPLEFT",x=5,y=-5,width=50, height=20, text = L["Reset"],
			func=self.Reset,
		},
		{name="Help",type="Button",inherits="UIPanelButtonTemplate",
			point="BOTTOMLEFT",x=5,y=5,width=100, height=20, text = L["Search Help"],
			func=self.HelpButton_Click,
		},

		----value buttons
		{name="Message",type="CheckButton",var="ShowMsg",
			point="TOPLEFT",x=20,y=-35
		},
		{name="Sound",type="CheckButton",var="Sound",
			point="LEFT",relative="Message",rpoint="RIGHT",
			x=100,
		},

		{name="OnlyInPetInfo",type="CheckButton",var="OnlyInPetInfo",
			point="TOP",relative="Message",rpoint="BOTTOM",
		},
		{name="HighGlow",type="CheckButton",var="HighGlow",
			point="LEFT",relative="OnlyInPetInfo",rpoint="RIGHT",
			x=100,
		},

		{name="PetGrowInfo",type="CheckButton",var="ShowGrowInfo",
			point="TOP",relative="OnlyInPetInfo",rpoint="BOTTOM",
		},
		{name="PetGreedInfo",type="CheckButton",var="PetGreedInfo",
			point="LEFT",relative="PetGrowInfo",rpoint="RIGHT",
			x=100,
		},

		{name="EnemyAbility",type="CheckButton",var="EnemyAbility",
			point="TOP",relative="PetGrowInfo",rpoint="BOTTOM",
		},
		{name="LockEnemyAbility",type="CheckButton",var="LockEnemyAbility",
			point="LEFT",relative="EnemyAbility",rpoint="RIGHT",
			x=100,
		},
		-- Sliders
		{name="EnemyAbilityScale",type="Slider",min=0.00,max=2.00,step=0.01,width=220,
			var = "EnemyAbScale",
			func = HPetOption.OnScaleChanged,
			point="CENTER",rpoint="CENTER",y=-20,
		},


	}

	local button, text, name, value
	for key,value in pairs(self.Buttons) do
		-- pre settings
		if value.type == "CheckButton" then
			value.inherits = "OptionsCheckButtonTemplate"
		elseif value.type == "Slider" then
			value.inherits = "OptionsSliderTemplate"
		elseif value.type == "EditBox" then
			value.inherits = "InputBoxTemplate"
		end

		-- create frame
		button = CreateFrame(value.type,self:GetName()..value.name,self,value.inherits)

		if value.type == "CheckButton" then
			text = button:CreateFontString(button:GetName().."Text","ARTWORK","GameFontNormal")
			text:SetPoint("LEFT",button,"RIGHT",7,0)
			text:SetVertexColor(1,1,1)
			button:SetFontString(text)
		elseif value.type == "EditBox" then
			text = button:CreateFontString(button:GetName().."Text","ARTWORK","GameFontNormal")
			text:SetPoint("LEFT",button,"RIGHT",10,0)
			button.text = text
		end
		
		-- setup
		button:SetID(key)
		if value.width then
			button:SetWidth(value.width)
		end
		if value.height then
			button:SetHeight(value.height)
		end
		if value.point then
			if value.relative then
				value.relative = self:GetName()..value.relative
			end
			button:SetPoint(value.point, value.relative or HPetOption, value.rpoint or value.point, value.x or 0, value.y or 0)
		end
		if value.text then
			if button.text then
				button.text:SetText(value.text)
			else
				button:SetText(value.text)
			end
		end

		-- post settings
		if value.type == "Button" then
			if value.text then button:SetText(value.text) end
			if value.func then button:SetScript("OnClick",value.func) end
		elseif value.type == "CheckButton" then
			if not value.text then button:SetText(L[value.name]) end
			if value.func then
				button:SetScript("OnClick", value.func)
			else
				button:SetScript("OnClick", HPetOption.OnCheckButtonClicked)
			end
		elseif value.type == "Slider" then
			button.text = _G["HPetOption"..value.name.."Text"]
			if value.text then
				button.title = value.text
			else
				button.title = L[value.name]
			end
			button.text:SetText(button.title)
			_G["HPetOption"..value.name.."Low"]:SetText(value.min)
			_G["HPetOption"..value.name.."High"]:SetText(value.max)
			button:SetMinMaxValues(value.min, value.max)
			button:SetValueStep(value.step)
			if value.func then button:SetScript("OnValueChanged", value.func) end
		elseif value.type == "EditBox" then
			button:SetAutoFocus(false)
			if not value.text then button.text:SetText(L[value.name]) end
			if value.func then
				button:SetScript("OnEnterPressed", value.func)
			else
				button:SetScript("OnEnterPressed", HPetOption.OnEditBoxEnterPressed)
			end
			button:SetScript("OnEscapePressed", button.ClearFocus)
		end

		if L[value.name.."Tooltip"] then
			button:SetScript("OnEnter", function(s)
				self:CheckButton_OnEnter(s,L[value.name.."Tooltip"])
			end)
		end
		
		-- Aurora-lize!
		if IsAddOnLoaded("Aurora") then
			if value.type == "CheckButton" then
				F.ReskinCheck(button)
			elseif value.type == "Slider" then
				F.ReskinSlider(button)
			elseif value.type == "EditBox" then
				F.ReskinInput(button)
			elseif value.type == "Button" then
				if value.inherits == "UIPanelCloseButton" then
					F.ReskinClose(button)
				else
					F.Reskin(button)
				end
			end
		end
	end
end

function HPetOption:OnCheckButtonClicked()
	isChecked = self:GetChecked()
	if isChecked then
		PlaySound("igMainMenuOptionCheckBoxOn")
	else
		PlaySound("igMainMenuOptionCheckBoxOff")
	end
	value = HPetOption.Buttons[self:GetID()]
	if value.var then
		if isChecked then
			HPetSaves[value.var] = true
		else
			HPetSaves[value.var] = false
		end
	end
	if value.var == "EnemyAbility" and PetBattleFrame:IsShown() then
		HAbiFrame:Ref()
	elseif value.var == "HighGlow" and PetBattleFrame:IsShown() then
		if isChecked then
			PetBattleFrame.ActiveEnemy.glow:Show()
			PetBattleFrame.ActiveAlly.glow:Show()
		else
			PetBattleFrame.ActiveEnemy.glow:Hide()
			PetBattleFrame.ActiveAlly.glow:Hide()
		end
	end
end


function HPetOption:OnScaleChanged()
	local scale = self:GetValue()
	if scale == 0 then scale = 0.01 end
	HPetSaves.EnemyAbScale = scale
	if HAbiFrame then HAbiFrame:Ref() end
	self.text:SetText(self.title.." : "..math.floor(scale*100).."%")
end

function HPetOption:CheckButton_OnEnter(button,message)
	GameTooltip:SetOwner(button,"ANCHOR_NONE");
	GameTooltip:SetPoint("BOTTOMLEFT",button,"TOPRIGHT")
	GameTooltip:AddLine(message, 1, 1, 0, true);
	GameTooltip:Show()
end

function HPetOption:HelpButton_Click()
	HPetBattleAny:PetPrintEX(L["searchhelp1"],1,1,0)
	HPetBattleAny:PetPrintEX(L["searchhelp2"],1,1,0)
end

--[[
	read options
--]]
function HPetOption:LoadOptions()
	local button
	for key, value in ipairs(HPetOption.Buttons) do
		button = _G["HPetOption"..value.name]
		if value.type == "CheckButton" then
			if value.var then
				button:SetChecked(HPetSaves[value.var])
			end
		elseif value.type == "Slider" then
			button:SetValue(HPetSaves[value.var] or 0.8)
		elseif value.type == "EditBox" then
			button:SetText(HPetSaves[value.var] or "")
		end
	end
	-- for anchor
	local anchor = HPetSaves["Anchor"]
	local result = {false,false,false,false}
	if anchor then
		if anchor > 2 then
			anchor = anchor - 3
		else
			result[4] = true
		end
		result[anchor+1] = true
	end
end

function HPetOption:Reset()
	HPetSaves = HPetBattleAny:GetDefault()
	HPetOption:LoadOptions()
end

function HPetOption:Open()
	self:LoadOptions()
	self:Show()
end



--------------------		SLASH,以后直接弄个设置面板
SLASH_PETQUALITY1 = "/hpetquality";
SLASH_PETQUALITY2 = "/hpq";
SlashCmdList["PETQUALITY"] = function(msg, editbox)
	local comm, rest = msg:match("^(%S*)%s*(.-)$")
	local command = string.lower(comm)
	if command =="" then
		if HPetOption then
			if not HPetOption.ready then HPetOption:Init() end
			if not HPetOption:IsShown() then
				HPetOption:Open()
			else
				HPetOption:Hide()
			end
		end
	end
--~ 	这是搜索功能
	if command =="s" or command =="搜索" or command == "ss" then
		HPetBattleAny:Search(command,rest)
	end
end
