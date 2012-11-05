-----####Ability1.45####
local _
--~ Globals
local _G = getfenv(0)
local hooksecurefunc, tinsert, pairs, wipe = _G.hooksecurefunc, _G.table.insert, _G.pairs, _G.wipe
local ipairs = _G.ipairs
local C_PetJournal = _G.C_PetJournal
--~ --------

local function PetBattleAbilityButton_OnEnterhook(self)
	local petOwner ,petIndex = self:GetParent():GetPetXY()
	if ( self:GetEffectiveAlpha() > 0 and C_PetBattles.GetAbilityInfo(petOwner, petIndex, self:GetID()) ) then
		PetBattleAbilityTooltip_SetAbility(petOwner, petIndex, self:GetID());
		PetBattleAbilityTooltip_Show('BOTTOM', self, 'TOP',self.additionalText);
	elseif ( self.abilityID ) then
		PetBattleAbilityTooltip_SetAbilityByID(petOwner, petIndex, self.abilityID, format(PET_ABILITY_REQUIRES_LEVEL, self.requiredLevel));
		PetBattleAbilityTooltip_Show('BOTTOM', self, 'TOP')
	else
		PetBattlePrimaryAbilityTooltip:Hide();
	end
end

local function PetBattleAbilityButton_UpdateBetterIconhook(self)
	if (not self.BetterIcon) then return end
	self.BetterIcon:Hide();

	local petOwner, petIndex= self:GetParent():GetPetXY()
	local enemypet = petOwner == LE_BATTLE_PET_ALLY and LE_BATTLE_PET_ENEMY or LE_BATTLE_PET_ALLY

	if (not petIndex) or (not petOwner) or (not enemypet) then
		return;
	end

	local petType, noStrongWeakHints, _;
	_, _, _, _, _, _, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(petOwner, petIndex, self:GetID());
	if (not petType) then
		return;
	end

	-- 获取 Strong/Weak 图标,并显示到按钮.
	local enemyPetSlot = C_PetBattles.GetActivePet(enemypet);
	local enemyType = C_PetBattles.GetPetType(enemypet, enemyPetSlot);
	local modifier = C_PetBattles.GetAttackModifier(petType, enemyType);

	if ( noStrongWeakHints or modifier == 1 ) then
		self.BetterIcon:Hide();return;
	elseif (modifier > 1) then
		self.BetterIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong");
	elseif (modifier < 1) then
		self.BetterIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Weak");
	end
	self.BetterIcon:Show();
end

local function PetBattleAbilityButton_UpdateIconshook(self)
	local petOwner ,petIndex = self:GetParent():GetPetXY()
	local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(petOwner, petIndex, self:GetID());
	self.abilityID = id;
	if ( not icon ) then
		icon = "Interface\\Icons\\INV_Misc_QuestionMark";
	end
	if ( not name ) then
		--We don't have an ability here.
		local abilities = {};
		local abilityLevels = {};
		local speciesID = C_PetBattles.GetPetSpeciesID(petOwner, petIndex);
		C_PetJournal.GetPetAbilityList(speciesID, abilities, abilityLevels);	--Read ability/ability levels into the correct tables
		self.abilityID = abilities[self:GetID()];
		if ( not self.abilityID ) then
			self.Icon:SetTexture("INTERFACE\\ICONS\\INV_Misc_Key_05");
			self:Hide();
		else
			name, icon, typeEnum = C_PetJournal.GetPetAbilityInfo(self.abilityID);
			self.Icon:SetTexture(icon);
			self.Lock:Show();
			self.requiredLevel = abilityLevels[self:GetID()];
		end
		self.Icon:SetVertexColor(1, 1, 1);
		return;
	end
	self.Icon:SetTexture(icon);
	self:Enable();
	self:Show();

	PetBattleAbilityButton_UpdateBetterIconhook(self);
end



local function PetBattleActionButton_UpdateStatehook(self)

	local petOwner ,petIndex = self:GetParent():GetPetXY()

	local actionType = self.actionType;
	local actionIndex = self.actionIndex;

	local _, usable, cooldown, hasSelected, isSelected, isLocked, isHidden;


	--获取usable/cooldown/locked的状态
	if ( actionType == LE_BATTLE_PET_ACTION_ABILITY ) then
		local _, name, icon = C_PetBattles.GetAbilityInfo(petOwner, petIndex, actionIndex);
		if ( name ) then
			local isUsable, currentCooldown = C_PetBattles.GetAbilityState(petOwner, petIndex, actionIndex);
			usable, cooldown = isUsable, currentCooldown;
		else
			isLocked = true;
		end
	end

	--获取usable/cooldown/locked的状态
	if ( actionType == LE_BATTLE_PET_ACTION_ABILITY ) then
		local _, name, icon = C_PetBattles.GetAbilityInfo(petOwner, petIndex, actionIndex);
		if ( name ) then
			local isUsable, currentCooldown = C_PetBattles.GetAbilityState(petOwner, petIndex, actionIndex);
			usable, cooldown = isUsable, currentCooldown;
		else
			isLocked = true;
		end
	end

	if ( isLocked ) then
		--Set the frame up to look like a cooldown, but with a required level
		if ( self.Icon ) then
			self.Icon:SetVertexColor(0.5, 0.5, 0.5);
			self.Icon:SetDesaturated(true);
		end
		self:SetAlpha(1);
		if ( self.CooldownShadow ) then
			self.CooldownShadow:Show();
		end
		if ( self.Cooldown ) then
			self.Cooldown:Hide();
		end
		if ( self.Lock ) then
			self.Lock:Show();
		end
		if ( self.AdditionalIcon ) then
			self.AdditionalIcon:SetVertexColor(0.5, 0.5, 0.5);
		end
		if ( self.BetterIcon ) then
			self.BetterIcon:Hide();
		end
	elseif ( cooldown and cooldown > 0 ) then
		--Set the frame up to look like a cooldown.
		if ( self.Icon ) then
			self.Icon:SetVertexColor(0.5, 0.5, 0.5);
			self.Icon:SetDesaturated(true);
		end
		self:SetAlpha(1);
		if ( self.CooldownShadow ) then
			self.CooldownShadow:Show();
		end
		if ( self.Cooldown ) then
			self.Cooldown:SetText(cooldown);
			self.Cooldown:Show();
		end
		if ( self.Lock ) then
			self.Lock:Hide();
		end
		if ( self.AdditionalIcon ) then
			self.AdditionalIcon:SetVertexColor(0.5, 0.5, 0.5);
		end
	elseif ( not usable or (hasSelected and not isSelected) ) then
		--Set the frame up to look unusable.
		if ( self.Icon ) then
			self.Icon:SetVertexColor(0.5, 0.5, 0.5);
			self.Icon:SetDesaturated(true);
		end
		self:SetAlpha(1);
		if ( self.CooldownShadow ) then
			self.CooldownShadow:Hide();
		end
		if ( self.Cooldown ) then
			self.Cooldown:Hide();
		end
		if ( self.Lock ) then
			self.Lock:Hide();
		end
		if ( self.AdditionalIcon ) then
			self.AdditionalIcon:SetVertexColor(0.5, 0.5, 0.5);
		end
	else
		--Set the frame up to look clickable/usable.
		if ( self.Icon ) then
			self.Icon:SetVertexColor(1, 1, 1);
			self.Icon:SetDesaturated(false);
		end
		self:SetAlpha(1);
		if ( self.CooldownShadow ) then
			self.CooldownShadow:Hide();
		end
		if ( self.Cooldown ) then
			self.Cooldown:Hide();
		end
		if ( self.Lock ) then
			self.Lock:Hide();
		end
		if ( self.AdditionalIcon ) then
			self.AdditionalIcon:SetVertexColor(1, 1, 1);
		end
		if (self.CooldownFlash ) then
			self.CooldownFlashAnim:Play();
		end
	end
end


local Backdrop={
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	}

HAbiFrame = CreateFrame("frame","HAbiFrameTemp",PetBattleFrame)

function HAbiFrame:Init(unit)
	self:SetSize("215","85")
	self:SetToplevel(true)
--~ 	self:SetClampedToScreen(true)
	self:SetMovable(true)
--~ 	self:SetBackdrop(Backdrop);
	self:SetBackdropColor(0,0,0)

	self.unit=unit

	self:SetScript('OnEvent',self.Update)
	self:RegisterEvent('PET_BATTLE_PET_CHANGED')
	self:RegisterEvent('PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE')
	self:RegisterEvent("PET_BATTLE_OPENING_START");

end

function HAbiFrame:GetPetXY()
	if PetBattleFrame and PetBattleFrame[self.unit] then
		return PetBattleFrame[self.unit].petOwner,PetBattleFrame[self.unit].petIndex
	else
		return 2,1
	end
end

function HAbiFrame:SetUnit(str)
	self.unit=str
	self:Update()
end

function HAbiFrame:Update()
	if self.AbilityButtons==nil then
		self.AbilityButtons={}
		self:InitButton()
		self:Ref()
	end
	for i=1, #self.AbilityButtons do
		local button = self.AbilityButtons[i];
		PetBattleAbilityButton_UpdateIconshook(button);
		PetBattleActionButton_UpdateStatehook(button);
	end
end

function HAbiFrame:Ref()
		if not HPetSaves.EnemyAbPoint then HPetSaves.EnemyAbPoint={} end

		HPetSaves.EnemyAbScale=HPetSaves.EnemyAbScale or 0.8

		self:SetScale(HPetSaves.EnemyAbScale)

		self:SetPoint(HPetSaves.EnemyAbPoint[1] or 'BOTTOM',
			HPetSaves.EnemyAbPoint[2] or nil,
			HPetSaves.EnemyAbPoint[3] or 'BOTTOM',
			HPetSaves.EnemyAbPoint[4] or '300',
			HPetSaves.EnemyAbPoint[5] or '170')

		if HPetSaves.EnemyAbility then
			self:Show()
		else
			self:Hide()
		end
end

function HAbiFrame:InitButton()
	for i=1, NUM_BATTLE_PET_ABILITIES do
		local Button = self.AbilityButtons[i];
		if ( not Button ) then
			self.AbilityButtons[i] = CreateFrame("CheckButton", nil, self, "PetBattleAbilityButtonTemplate", i);
		end
		Button=self.AbilityButtons[i]

		Button:SetPoint('LEFT', (Button:GetWidth() + 5) * (i-1)+25, 0)
		Button:SetScript('OnEnter', PetBattleAbilityButton_OnEnterhook)

		Button:SetScript('OnClick',nil)

		Button:RegisterForDrag("LeftButton")
		Button:SetScript("OnDragStart",function(self) if HPetSaves and not HPetSaves.LockEnemyAbility then self:GetParent():StartMoving() end end)
		Button:SetScript("OnDragStop",function(self)
			if HPetSaves and not HPetSaves.LockEnemyAbility then self:GetParent():StopMovingOrSizing() end
			if HPetSaves then
				HPetSaves.EnemyAbPoint = {self:GetParent():GetPoint()}
				if HPetSaves.EnemyAbPoint[2] then HPetSaves.EnemyAbPoint[2]=HPetSaves.EnemyAbPoint[2]:GetName()end
			end

		end)

		Button:SetHighlightTexture(nil)
		Button:SetPushedTexture(nil)
		Button:UnregisterAllEvents()

		Button = self.AbilityButtons[i];
		Button:Show()
		Button:SetFrameLevel(self:GetFrameLevel() + 1, Button);
	end
end

HAbiFrame:Init("ActiveEnemy")
