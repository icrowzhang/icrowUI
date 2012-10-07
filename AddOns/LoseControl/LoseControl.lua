--[[ Code Credits - to the people whose code I borrowed and learned from:
Wowwiki
Kollektiv
Tuller
ckknight
The authors of Nao!!
And of course, Blizzard

Thanks! :)
]]

local M = icrowMedia
local addonName, _ = ...
local UIParent = UIParent -- it's faster to keep local references to frequently used global vars
local floor = floor
local format = format

local function log(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end -- alias for convenience

local function TimeText(s)
    if s < 5 then
		return format('|cffff0000%.1f|r', floor(s*10)/10), s - floor(s*10)/10
	else
		return format('|cffffff00%d|r', floor(s)), s - floor(s)
	end
end

-------------------------------------------------------------------------------
local spellIds = { 
   -- Death Knight 
   [108200] = "Snare",      -- Remorseless Winter 
   [115001] = "CC",      -- Remorseless Winter Stun 
   [108194] = "CC",      -- Asphyxiate 
   [47481] = "CC",      -- Gnaw (Ghoul) 
   [91797] = "CC",      -- Monstrous Blow (Super ghoul) 
   [47476] = "Silence",      -- Strangulate 
   [45524] = "Snare",      -- Chains of Ice 
   [96294] = "Root",      -- Chains of Ice Root 
   -- Druid 
   [114238] = "Silence",   -- Glyph of Fae Silence 
   [99] = "CC",      -- Disorienting Roar 
   [102359] = "Root",   -- Mass Entanglement 
   [126458] = "CC",      -- Symbiosis: Grapple Weapon 
   [110698] = "CC",      -- Symbiosis: Hammer of Justice 
   [113004] = "CC",      -- Symbiosis: Intimidating Roar 
   [110693] = "Root",   -- Symbiosis: Frost Nova 
   [102795] = "CC",      -- Bear Hug 
   [5211]  = "CC",      -- Mighty Bash 
   [33786] = "CC",      -- Cyclone 
   [2637]  = "CC",      -- Hibernate 
   [22570] = "CC",      -- Maim 
   [9005]  = "CC",      -- Pounce 
   [81261] = "Silence",      -- Solar Beam 
   [339]   = "Root",      -- Entangling Roots 
   [19975]   = "Root",      -- Entangling Roots 
   [45334] = "Root",      -- Feral Charge Effect 
   [61391] = "Snare",      -- Typhoon 
   -- Hunter 
   [128405] = "Root",   -- Narrow Escape 
   [109248] = "CC",      -- Binding Shot 
   [3355]  = "CC",      -- Freezing Trap Effect 
   [24394] = "CC",      -- Intimidation 
   [1513]  = "CC",      -- Scare Beast 
   [19503] = "CC",      -- Scatter Shot 
   [19386] = "CC",      -- Wyvern Sting 
   [34490] = "Silence",      -- Silencing Shot 
   [19185] = "Root",      -- Entrapment 
   [35101] = "Snare",      -- Concussive Barrage 
   [5116]  = "Snare",      -- Concussive Shot 
   [13810] = "Snare",      -- Frost Trap Aura 
   [61394] = "Snare",      -- Glyph of Freezing Trap 
   -- Hunter Pets 
   [56626] = "CC",      -- Sting (Wasp) 
   [91644] = "Disarm",   -- Snatch (Bird of Prey) 
   [50433] = "Snare",   -- Ankle Crack (Crocolisk) 
   [50519] = "CC",      -- Sonic Blast (Bat) 
   [50541] = "Disarm",      -- Clench (Scorpid) 
   [54644] = "Snare",      -- Frost Breath (Chimera) 
   [50245] = "Root",      -- Pin (Crab) 
   [90337] = "CC",      -- Bad Manner (Monkey) 
   [54706] = "Root",      -- Venom Web Spray (Silithid) 
   [4167]  = "Root",      -- Web (Spider) 
   -- Mage 
   [102051] = "CC",      -- Frostjaw 
   [113092] = "Snare",   -- Frost Bomb Slow 
   [110694] = "Snare",   -- Frost Armor Slow 
   [55021] = "Silence",   -- Silenced - Improved Counterspell 
   [111340] = "Root",   -- Ice Ward 
   [118271] = "CC",      -- Combustion Impact 
   [44572] = "CC",      -- Deep Freeze 
   [31661] = "CC",      -- Dragon's Breath 
   [118]   = "CC",      -- Polymorph 
   [82691] = "CC",      -- Ring of Frost 
   [33395] = "Root",      -- Freeze (Water Elemental) 
   [122]   = "Root",      -- Frost Nova 
   [11113] = "Snare",      -- Blast Wave 
   [6136]  = "Snare",      -- Chilled 
   [120]   = "Snare",      -- Cone of Cold 
   [116]   = "Snare",      -- Frostbolt 
   [44614] = "Snare",      -- Frostfire Bolt 
   [31589] = "Snare",      -- Slow 
   -- Monk 
   [123393] = "CC",      -- Glyph of Breath of Fire 
   [119392] = "CC",      -- Charging Ox Wave 
   [119381] = "CC",      -- Leg Sweep 
   [115078] = "CC",      -- Paralysis 
   --[-----] = "CC",      -- Clash 
   [117368] = "Disarm",   -- Grapple Weapon 
   [116709] = "Silence",   -- Silenced - Spear Hand Strike 
   [113275] = "Root",   -- Simbiosis: Entangling Roots 
   [116706] = "Root",   -- Disable Root 
   [116095] = "Snare",   -- Disable 
   [118585] = "Snare",   -- Leer of the Ox 
   [123727] = "Snare",   --Dizzying Haze 
   [123586] = "Snare",   -- Flying Serpent Kick 
   [123407] = "Root",   -- Spinning Fire Blossom 
   -- Paladin 
   [105421] = "CC",      -- Blinding Light 
   [115752] = "CC",      -- GLyph of Blinding Light (Stun) 
   [110300] = "Snare",      -- Burden of Guilt 
   [105593] = "CC",      -- Fist of Justice 
   [853]   = "CC",      -- Hammer of Justice 
   [2812]  = "CC",      -- Holy Wrath 
   [20066] = "CC",      -- Repentance 
   [10326] = "CC",      -- Turn Evil 
   [31935] = "Silence",      -- Avenger's Shield 
   [63529] = "Snare",      -- Dazed - Avenger's Shield 
   [20170] = "Snare",      -- Seal of Justice 
   -- Priest 
   [87194] = "Root",      -- Glyph of Mind Blast 
   [113506] = "CC",      -- Symbiosis: Cyclone 
   [113792] = "CC",      -- Psyfiend 
   [114404] = "Root",      -- Void Tendril's Grasp 
   [605]   = "CC",      -- Dominate Mind 
   [64044] = "CC",      -- Psychic Horror 
   [8122]  = "CC",      -- Psychic Scream 
   [9484]  = "CC",      -- Shackle Undead 
   [87204] = "CC",      -- Sin and Punishment 
   [15487] = "Silence",      -- Silence 
   --[64058] = "Disarm",      -- Psychic Horror 
   [87194] = "Root",      -- Paralysis 
   [15407] = "Snare",      -- Mind Flay 
   -- Rogue 
   [119696] = "Snare",   -- Debilitation 
   [113953] = "CC",      -- Paralysis 
   [115197] = "Root",   -- Partial Paralysis 
   [2094]  = "CC",      -- Blind 
   [1833]  = "CC",      -- Cheap Shot 
   [1776]  = "CC",      -- Gouge 
   [408]   = "CC",      -- Kidney Shot 
   [6770]  = "CC",      -- Sap 
   [76577] = "CC",      -- Smoke Bomb 
   [1330]  = "Silence",      -- Garrote - Silence 
   [51722] = "Disarm",      -- Dismantle 
   [3409]  = "Snare",      -- Crippling Poison 
   [26679] = "Snare",      -- Deadly Throw 
   -- Shaman 
   [118905] = "CC",      -- Static Charge 
   --[77478] = "Snare",   -- Glyph of Unstable Earth 
   [113287] = "Silence",   -- Symbiosis: Solar Beam 
   [118345] = "CC",      -- Pulverize 
   [76780] = "CC",      -- Bind Elemental 
   [77505] = "CC",      -- Earthquake Stun 
   [51514] = "CC",      -- Hex 
   [64695] = "Root",      -- Earthgrab (Earth's Grasp) 
   [63685] = "Root",      -- Freeze (Frozen Power) 
   [3600]  = "Snare",      -- Earthbind 
   [8056]  = "Snare",      -- Frost Shock 
   [8034]  = "Snare",      -- Frostbrand Attack 
   -- Warlock 
   [118093] = "Disarm",   -- Disarm (Voidwalker/Voidlord) 
   [104045] = "CC",      -- Metamorphosis: Sleep 
   [115268] = "CC",      -- Mesmerize (Shivarra) 
   [111397] = "CC",      -- Blood Fear 
   [89766] = "CC",      -- Axe Toss (Felguard) 
   [710]   = "CC",      -- Banish 
   [6789]  = "CC",      -- Mortal Coil 
   [54786] = "CC",      -- Demon Leap 
   [5782]  = "CC",      -- Fear 
   [5484]  = "CC",      -- Howl of Terror 
   [6358]  = "CC",      -- Seduction (Succubus) 
   [30283] = "CC",      -- Shadowfury 
   [24259] = "Silence",      -- Spell Lock (Felhunter) 
   [31117] = "Silence",      -- Unstable Affliction 
   [18223] = "Snare",      -- Curse of Exhaustion 
   [63311] = "Snare",      -- Shadowsnare (Glyph of Shadowflame) 
   -- Warrior 
   [105771] = "CC",      -- Warbringer 
   [107566] = "Root",      -- Staggering Shout 
   [118000] = "CC",      -- Dragon Roar 
   [7922]  = "CC",      -- Charge Stun 
   [6544]  = "CC",      -- Heroic Leap 
   [5246]  = "CC",      -- Intimidating Shout 
   [46968] = "CC",      -- Shockwave 
   [18498] = "Silence",      -- Silenced - Gag Order 
   [676]   = "Disarm",      -- Disarm 
   [1715]  = "Snare",      -- Hamstring 
   [12323] = "Snare",      -- Piercing Howl 
   -- Other 
   [107079] = "CC",      -- Quaking Palm (Pandaren Racial) 
   [30217] = "CC",      -- Adamantite Grenade 
   [67769] = "CC",      -- Cobalt Frag Bomb 
   [30216] = "CC",      -- Fel Iron Bomb 
   [13327] = "CC",      -- Reckless Charge 
   [56]    = "CC",      -- Stun 
   [20549] = "CC",      -- War Stomp 
   [25046] = "Silence",   -- Arcane Torrent 
   [39965] = "Root",   -- Frost Grenade 
   [55536] = "Root",   -- Frostweave Net 
   [13099] = "Root",   -- Net-o-Matic 
   -- CC Immunities 
   [131523] = "Immune",   -- Zen Meditation [Monk's Buff] 
   [115018] = "Immune",   -- Desecrated Ground (Death Knight) 
   [110715] = "Immune",   -- Dispersion (Symbiosis: Druid) 
   [110700] = "Immune",   -- Divine Shield (Symbiosis: Druid) 
   [19574] = "Immune",   -- Bestial Wrath (Hunter pet) 
   [46924] = "Immune",   -- Bladestorm (Warrior) 
   [19263] = "Immune",   -- Deterrence [except aoe?] (Hunter) 
   [47585] = "Immune",   -- Dispersion (Priest) 
   [642]   = "Immune",   -- Divine Shield (Paladin) 
   [45438] = "Immune",   -- Ice Block (Mage) 
   --[54216] = "Immune",   -- Master's Call (Hunter pet + target, root and snare immune only) 
   -- Spell Immunities 
   [115176] = "ImmuneSpell",   -- Zen Meditation [Spell reflect for the party/raid] 
   [114239] = "ImmuneSpell",   -- Phantasm (Priest) [untargetable by ranged attacks] 
   [115760] = "ImmuneSpell",   -- Glyph of Ice Block (Mage) 
   [110788] = "ImmuneSpell",   -- Cloak of Shadows (Symbio: Druid) 
   [48707] = "ImmuneSpell",   -- Anti-magic Shell (Death Knight) 
   [31224] = "ImmuneSpell",   -- Cloak of Shadows (Rogue) 
   [8178]  = "ImmuneSpell",   -- Grounding Totem Effect [exept aoe] (Shaman) 
   [113002] = "ImmuneSpell",   -- Spell Reflection [except aoe] (Symbiosis: Druid) 
   [23920] = "ImmuneSpell",   -- Spell Reflection [except aoe] (Warrior) 
   [114028] = "ImmuneSpell",   -- Mass Spell Reflection [except aoe] (Warrior + Party/raid Members) 
   -- Other Immunities - optional, not sure how to handle these; many have durations that are quite long 
   --[18499] = "ImmuneFearIncapacitate",   -- Berserker Rage (Warrior) 
   --[45182] = "ImmuneDamage",   -- Cheating Death [only 90% immune] (Rogue) 
   --[5277]  = "ImmuneMelee",   -- Evasion [only +50% immune to melee, +25% to ranged] (Rogue) 
   --[110791] = "ImmuneMelee",   -- Evasion (Symbiosis: Druid) 
   --[48792] = "ImmuneStun",   -- Icebound Fortitude [stuns] (Death Knight) 
   --[49039] = "ImmuneFearPoly",   -- Lichborne [charm, fear, sleep, hex, polymorph] (Death Knight) 
   --[51271] = "ImmuneMove",   -- Pillar of Frost (Death Knight)
}
local abilities = {} -- localized names are saved here
for k, v in pairs(spellIds) do
	local name = GetSpellInfo(k)
	if name then
		abilities[name] = v
	else -- Thanks to inph for this idea. Keeps things from breaking when Blizzard changes things.
		log(addonName .. " unknown spellId: " .. k)
	end
end

-------------------------------------------------------------------------------
-- Global references for attaching icons to various unit frames
local anchors = {
	None = {}, -- empty but necessary
	Blizzard = {
		player = "PlayerPortrait",
		pet    = "PetPortrait",
		target = "TargetFramePortrait",
		focus  = "FocusFramePortrait",
		party1 = "PartyMemberFrame1Portrait",
		party2 = "PartyMemberFrame2Portrait",
		party3 = "PartyMemberFrame3Portrait",
		party4 = "PartyMemberFrame4Portrait",
		arena1 = "ArenaEnemyFrame1ClassPortrait",
		arena2 = "ArenaEnemyFrame2ClassPortrait",
		arena3 = "ArenaEnemyFrame3ClassPortrait",
		arena4 = "ArenaEnemyFrame4ClassPortrait",
		arena5 = "ArenaEnemyFrame5ClassPortrait",
	},
	Perl = {
		player = "Perl_Player_Portrait",
		pet    = "Perl_Player_Pet_Portrait",
		target = "Perl_Target_Portrait",
		focus  = "Perl_Focus_Portrait",
		party1 = "Perl_Party_MemberFrame1_Portrait",
		party2 = "Perl_Party_MemberFrame2_Portrait",
		party3 = "Perl_Party_MemberFrame3_Portrait",
		party4 = "Perl_Party_MemberFrame4_Portrait",
	},
	XPerl = {
		player = "XPerl_PlayerportraitFrameportrait",
		pet    = "XPerl_Player_PetportraitFrameportrait",
		target = "XPerl_TargetportraitFrameportrait",
		focus  = "XPerl_FocusportraitFrameportrait",
		party1 = "XPerl_party1portraitFrameportrait",
		party2 = "XPerl_party2portraitFrameportrait",
		party3 = "XPerl_party3portraitFrameportrait",
		party4 = "XPerl_party4portraitFrameportrait",
	},
	LUI = {
		player = "oUF_LUI_player",
		pet    = "oUF_LUI_pet",
		target = "oUF_LUI_target",
		focus  = "oUF_LUI_focus",
		party1 = "oUF_LUI_partyUnitButton1",
		party2 = "oUF_LUI_partyUnitButton2",
		party3 = "oUF_LUI_partyUnitButton3",
		party4 = "oUF_LUI_partyUnitButton4",
	},
}

-------------------------------------------------------------------------------
-- Default settings
local DBdefaults = {
	timerfont = { font = "Fonts\\Roadway.ttf", size = 26, flag = "THINOUTLINE"},
	version = 4.3, -- This is the settings version, not necessarily the same as the LoseControl version
	tracking = { -- To Do: Priority
		Immune		= true, --100
		ImmuneSpell	= true, -- 90
		CC		= true,  -- 80
		PvE		= false,  -- 70
		Silence		= true,  -- 60
		Disarm		= false,  -- 50
		Root		= false, -- 40
		Snare		= false, -- 30
	},
	frames = {
		player = {
			enabled = true,
			size = 54,
			alpha = 1,
			anchor = "None",
			x = -91,
			y = 9,
		},
		pet = {
			enabled = false,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		target = {
			enabled = true,
			size = 56,
			alpha = 1,
			anchor = "Blizzard",
		},
		focus = {
			enabled = true,
			size = 56,
			alpha = 1,
			anchor = "Blizzard",
		},
		party1 = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		party2 = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		party3 = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		party4 = {
			enabled = true,
			size = 36,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena1 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena2 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena3 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena4 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
		arena5 = {
			enabled = true,
			size = 28,
			alpha = 1,
			anchor = "Blizzard",
		},
	},
}
local LoseControlDB -- local reference to the addon settings. this gets initialized when the ADDON_LOADED event fires

-------------------------------------------------------------------------------
-- Create the main class
local LoseControl = CreateFrame("Cooldown", nil, UIParent) -- Exposes the SetCooldown method

function LoseControl:OnEvent(event, ...) -- functions created in "object:method"-style have an implicit first parameter of "self", which points to object
	self[event](self, ...) -- route event parameters to LoseControl:event methods
end
LoseControl:SetScript("OnEvent", LoseControl.OnEvent)

-- Initialize a frame's position
function LoseControl:PLAYER_ENTERING_WORLD() -- this correctly anchors enemy arena frames that aren't created until you zone into an arena
	self.frame = DBdefaults.frames[self.unitId] -- store a local reference to the frame's settings
	local frame = self.frame
	self.anchor = _G[anchors[frame.anchor][self.unitId]] or UIParent

	self:SetParent(self.anchor:GetParent()) -- If Hide() is called on the parent frame, its children are hidden too. This also sets the frame strata to be the same as the parent's.
	self:ClearAllPoints() -- if we don't do this then the frame won't always move
	self:SetWidth(frame.size)
	self:SetHeight(frame.size)
	self:SetPoint(
		frame.point or "CENTER",
		self.anchor,
		frame.relativePoint or "CENTER",
		frame.x or 0,
		frame.y or 0
	)
	--self:SetAlpha(frame.alpha) -- doesn't seem to work; must manually set alpha after the cooldown is displayed, otherwise it doesn't apply.
	self:Hide()
end

local WYVERN_STING = GetSpellInfo(19386)
local PSYCHIC_HORROR = GetSpellInfo(64058)
local UNSTABLE_AFFLICTION = GetSpellInfo(31117)
local SMOKE_BOMB = GetSpellInfo(76577)
local SOLAR_BEAM = GetSpellInfo(81261)
local GROUNDING_TOTEM = GetSpellInfo(8178)
local UnitDebuff = UnitDebuff
local UnitBuff = UnitBuff
local GetTime = GetTime

-- This is the main event
function LoseControl:UNIT_AURA(unitId) -- fired when a (de)buff is gained/lost
	if unitId ~= self.unitId or not self.frame.enabled or not self.anchor:IsVisible() then return end

	local maxExpirationTime = 0
	local _, name, icon, Icon, duration, Duration, expirationTime, wyvernsting

	for i = 1, 40 do
		name, _, icon, _, _, duration, expirationTime = UnitDebuff(unitId, i)
		if not name then break end -- no more debuffs, terminate the loop
		--log(i .. ") " .. name .. " | " .. rank .. " | " .. icon .. " | " .. count .. " | " .. debuffType .. " | " .. duration .. " | " .. expirationTime )

		-- exceptions
		if name == WYVERN_STING then
			wyvernsting = 1
			if not self.wyvernsting then
				self.wyvernsting = 1 -- this is the first time the debuff has been applied
			elseif expirationTime > self.wyvernsting_expirationTime then
				self.wyvernsting = 2 -- this is the second time the debuff has been applied
			end
			self.wyvernsting_expirationTime = expirationTime
			if self.wyvernsting == 2 then
				name = nil -- hack to skip the next if condition since LUA doesn't have a "continue" statement
			end
		elseif (name == PSYCHIC_HORROR and icon ~= "Interface\\Icons\\Spell_Shadow_PsychicHorrors") or -- hack to remove Psychic Horror disarm effect
			(name == UNSTABLE_AFFLICTION and icon ~= "Interface\\Icons\\Spell_Holy_Silence") then
			name = nil
		elseif name == SMOKE_BOMB then
			expirationTime = GetTime() + 5 -- hack, normal expirationTime = 0
		elseif name == SOLAR_BEAM then
			expirationTime = GetTime() + 10 -- hack, normal expirationTime = 0
		end

		if expirationTime > maxExpirationTime and DBdefaults.tracking[abilities[name]] then
			maxExpirationTime = expirationTime
			Duration = duration
			Icon = icon
		end
	end

	-- continue hack for Wyvern Sting
	if self.wyvernsting == 2 and not wyvernsting then -- dot either removed or expired
		self.wyvernsting = nil
	end

	-- Track Immunities
	local Immune = DBdefaults.tracking.Immune
	local ImmuneSpell = DBdefaults.tracking.ImmuneSpell
	if (Immune or ImmuneSpell) and unitId ~= "player" then
		for i = 1, 40 do
			name, _, icon, _, _, duration, expirationTime = UnitBuff(unitId, i)
			if not name then break end

			-- exceptions
			if name == GROUNDING_TOTEM then
				expirationTime = GetTime() + 45 -- hack, normal expirationTime = 0
			end

			if expirationTime > maxExpirationTime and (
				(Immune and abilities[name] == "Immune") or
				(ImmuneSpell and abilities[name] == "ImmuneSpell")
			) then
				maxExpirationTime = expirationTime
				Duration = duration
				Icon = icon
			end
		end
	end

	if maxExpirationTime == 0 then -- no (de)buffs found
		self.maxExpirationTime = 0
		if self.anchor ~= UIParent and self.drawlayer then
			self.anchor:SetDrawLayer(self.drawlayer) -- restore the original draw layer
		end
		self:Hide()
	elseif maxExpirationTime ~= self.maxExpirationTime then -- this is a different (de)buff, so initialize the cooldown
		self.maxExpirationTime = maxExpirationTime
		if self.anchor ~= UIParent then
			self:SetFrameLevel(self.anchor:GetParent():GetFrameLevel()) -- must be dynamic, frame level changes all the time
			if not self.drawlayer and self.anchor.GetDrawLayer then
 				self.drawlayer = self.anchor:GetDrawLayer() -- back up the current draw layer
 			end
			if self.drawlayer and self.anchor.SetDrawLayer then
				self.anchor:SetDrawLayer("BACKGROUND") -- Temporarily put the portrait texture below the debuff texture. This is the only reliable method I've found for keeping the debuff texture visible with the cooldown spiral on top of it.
			end
		end
		if self.frame.anchor == "Blizzard" then
			SetPortraitToTexture(self.texture, Icon) -- Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits. TO DO: mask the cooldown frame somehow so the corners don't stick out of the portrait frame. Maybe apply a circular alpha mask in the OVERLAY draw layer.
		else
			self.texture:SetTexture(Icon)
		end
		self:Show()
		if Duration > 0 then
			if self.frame.anchor == "Blizzard" then
				if (unitId ~= "target" and unitId ~= "focus") then
					LoseControl:StartTimer(self, maxExpirationTime, 0.64)
				else
					LoseControl:StartTimer(self, maxExpirationTime)
				end
			else
				self.cooldown:SetCooldown(maxExpirationTime - Duration, Duration)
			end
		end
		self:SetAlpha(self.frame.alpha) -- hack to apply transparency to the cooldown timer
	end
end

function LoseControl:PLAYER_FOCUS_CHANGED()
	self:UNIT_AURA("focus")
end

function LoseControl:PLAYER_TARGET_CHANGED()
	self:UNIT_AURA("target")
end

function LoseControl:StartTimer(f, eTime, scale)
	if scale then
		local fontsize = floor(DBdefaults.timerfont.size * scale)
		f.timer:SetFont(DBdefaults.timerfont.font, fontsize, DBdefaults.timerfont.flag)
	end
	local text, nextupdate = TimeText(eTime-GetTime())
	f.eTime = eTime
	f.total = nextupdate
	f.timer:SetFormattedText(text)
	f.timer:Show()
	f:SetScript("OnUpdate", function(self, elapsed)
		self.total = self.total + elapsed
		if self.total >= nextupdate then
			if self.eTime - GetTime() > 0 and self:IsVisible() then
				text, nextupdate = TimeText(eTime-GetTime())
				self.timer:SetFormattedText(text)
				self.total = 0
			else
				self.timer:SetText(nil)
				self:Hide()
			end
		end
	end)
end

-- Constructor method
function LoseControl:new(unitId)
	local o = CreateFrame("Frame", addonName .. unitId) --, UIParent)
	o.cooldown = CreateFrame("Cooldown", nil, o)
	o.cooldown:SetAllPoints(o)
	o.timer = o:CreateFontString("nil", "ARTWORK")
	o.timer:SetFont(DBdefaults.timerfont.font, DBdefaults.timerfont.size, DBdefaults.timerfont.flag)
	o.timer:SetShadowOffset(1, -1)
	o.timer:SetPoint("CENTER")
	o.timer:Hide()
	setmetatable(o, self)
	self.__index = self

	-- Init class members
	o.unitId = unitId -- ties the object to a unit
	o.texture = o:CreateTexture(nil, "BORDER") -- displays the debuff; draw layer should equal "BORDER" because cooldown spirals are drawn in the "ARTWORK" layer.
	o.texture:SetTexCoord(0.03, 0.97, 0.03, 0.97)
	o.texture:SetAllPoints(o) -- anchor the texture to the frame
	o.cooldown:SetReverse(true) -- makes the cooldown shade from light to dark instead of dark to light
	if unitId == "player" then
		M.CreateBG(o)
		M.CreateSD(o)
	end
	o:Hide()

	-- Handle events
	o:SetScript("OnEvent", self.OnEvent)
	o:RegisterEvent("PLAYER_ENTERING_WORLD")
	o:RegisterEvent("UNIT_AURA")
	if unitId == "focus" then
		o:RegisterEvent("PLAYER_FOCUS_CHANGED")
	elseif unitId == "target" then
		o:RegisterEvent("PLAYER_TARGET_CHANGED")
	end

	return o
end

-- Create new object instance for each frame
local LC = {}
for k in pairs(DBdefaults.frames) do
	LC[k] = LoseControl:new(k)
end