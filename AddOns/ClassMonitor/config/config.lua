local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

local L = Engine.Locales

Engine.Config = {
--[[
	name = frame name (can be used in anchor)
	kind = MOVER | RESOURCE(mana/runic/energy/focus/rage) | COMBO | POWER | AURA | RUNES | ECLIPSE | REGEN | HEALTH  | DOT | TOTEM | BANDITSGUILE

	MOVER	create a mover in Tukui/ElvUI to be able to move bars via /moveui
	text = string													text to display in config mode
	width = number													width of anchor bar
	height = number													height of anchor bar

	RESOURCE (mana/runic power/energy/focus/rage/chi):
	text = true|false												display resource value (% for mana) [default: true]
	autohide = true|false											hide or not while out of combat [default: false]
	anchor|anchors =												see note below
	width = number													width of resource bar [default: 85]
	height = number													height of resource bar [default: 15]
	color|colors =													see note below [default: tukui power color]
	spec|specs = 													see note below [default: any]

	COMBO:
	autohide = true|false											hide or not while out of combat [default: true]
	anchor|anchors =												see note below
	width = number													width of combo point [default: 85]
	height = number													height of combo point [default: 15]
	spacing = number												space between combo points [default: 3]
	color|colors =													see note below [default: class color]
	filled = true|false												is combo point filled or not [default: false]
	spec|specs = 													see note below [default: any]

	POWER (holy power/soul shard/light force, ...):
	autohide = true|false											hide or not while out of combat [default: false]
	powerType = SPELL_POWER_HOLY_POWER|SPELL_POWER_SOUL_SHARDS|SPELL_POWER_LIGHT_FORCE|SPELL_POWER_BURNING_EMBERS|SPELL_POWER_DEMONIC_FURY|SPELL_POWER_SHADOW_ORBS	power to monitor (can be any power type (http://www.wowwiki.com/PowerType)
	count = number													max number of points to display
	anchor|anchors =												see note below
	width = number													width of power point [default: 85]
	height = number													height of power point [default: 15]
	spacing = number												space between power points [default: 3]
	color|colors =													see note below [default: class color]
	filled = true|false												is power point filled or not [default: false]
	spec|specs = 													see note below [default: any], not available for SPELL_POWER_BURNING_EMBERS|SPELL_POWER_DEMONIC_FURY

	AURA (buff/debuff):
	autohide = true|false											hide or not while out of combat [default: true]
	unit = "player"|"target"|"focus"|"pet"							check aura on this unit [default:"player"]
	spellID = number												spell id of buff/debuff to monitor
	filter = "HELPFUL" | "HARMFUL"									BUFF or DEBUFF
	count = number													max number of stack to display
	anchor|anchors =												see note below
	width = number													width of buff stack or bar[default: 85]
	height = number													height of buff stack or bar [default: 15]
	spacing = number												space between buff stack if no bar[default: 3]
	color|colors =													see note below [default: class color]
	filled = true|false												is buff stack filled or not if no bar[default: false]
	bar = true|false												status bar instead of stack [default: false]
	text = true|false												display current/max stack in status bar [default:true]
	duration = true|false											display buff|debuff time left in status bar [default:false]
	spec|specs = 													see note below [default: any]

	RUNES
	updatethreshold = number										interval between runes display update [default: 0.1]
	autohide = true|false											hide or not while out of combat [default: false]
	orientation = "HORIZONTAL" | "VERTICAL"							direction of rune filling display [default: HORIZONTAL]
	anchor|anchors =												see note below
	width = number													width of rune [default: 85]
	height = number													height of rune [default: 15]
	spacing = number												space between runes [default: 3]
	colors = { blood, unholy, frost, death }						color of runes
	runemap = { 1, 2, 3, 4, 5, 6 }									see instruction in DEATHKNIGHT section

	ECLIPSE
	autohide = true|false											hide or not while out of combat [default: false]
	text = true|false												display eclipse direction [default: true]
	anchor|anchors=													see note below
	width = number													width of eclipse bar [default: 85]
	height = number													height of eclipse bar [default: 15]
	colors = { lunar, solar }										color of lunar and solar bar

	REGEN
	anchor = 														see note below
	text = true|false												display regen value (% for mana) [default: true]
	autohide = true|false											hide or not while out of combat [default: false]
	width = number													width of regen bar [default: 85]
	height = number													height of regen bar [default: 15]
	color =															see note below [default: class color]

	HEALTH
	unit = "player"|"target"|"focus"|"pet"							check aura on this unit [default:"player"]
	anchor = 														see note below
	autohide = true|false											hide or not while out of combat [default: true]
	width = number													width of health bar [default: 85]
	height = number													height of health bar [default: 15]
	color =															see note below [default: class color]
	spec|specs = 													see note below [default: any]

	DOT
	autohide = true|false											hide or not while out of combat [default: true]
	anchor = 														see note below
	width = number													width of dot bar [default: 85]
	height = number													height of dot bar [default: 15]
	spellID = number												spell id of dot to monitor
	latency = true|false											indicate latency on buff (usefull for ignite)
	threshold = number or 0											threshold to work with colors [default: 0]
	colors = array of array : 
		{
			{255/255, 165/255, 0, 1},								bad color : under 75% of threshold -- here orange -- [default: class color]
			{255/255, 255/255, 0, 1},								intermediate color : 0,75% of threshold -- here yellow -- [default: class color]
			{127/255, 255/255, 0, 1},								good color : over threshold -- here green -- [default: class color]
		},
	color = {r, g, b, a}											if treshold is set to 0	[default: class color]
	spec|specs = 													see note below [default: any]

	TOTEM (totems or wildmushrooms):
	autohide = true|false											hide or not while out of combat [default: false]
	anchor = 														see note below
	width = number													width of totem bar [default: 85]
	height = number													height of totem bar [default: 15]
	spacing = number												spacing between each totems [default: 3]
	count = number													number of totems (4 for shaman totems, 3 for druid mushrooms)
	color|colors =													see note below [default: class color]
	spec|specs = 													see note below [default: any]
	text = true|false												display totem duration left [default:false]
	map = array of number											totem remapping
		{ 2, 1, 3, 4 }												display second totem, followed by first totem, then third and fourth

	BANDITSGUILE:
	autohide = true|false											hide or not while out of combat [default: true]
	anchor|anchors =												see note below
	width = number													width of bandit's guilde charge [default: 85]
	height = number													height of bandit's guilde charge [default: 15]
	spacing = number												space between bandit's guilde charge [default: 3]
	color|colors =													see note below [default: class color]
	filled = true|false												is bandit's guilde charge filled or not [default: false]


	Notes about anchor
	anchor = { "POSITION", parent, "POSITION", offsetX, offsetY }
		-> one anchor whatever spec is used
	anchors = { { "POSITION", parent, "POSITION", offsetX, offsetY }, { "POSITION", parent, "POSITION", offsetX, offsetY }, ... { "POSITION", parent, "POSITION", offsetX, offsetY } }
		-> one anchor by spec

	Notes about color
	color = {r, g, b, a}
		-> same color for every point (if no color is specified, raid class color will be used)
	colors = { { {r, g, b, a}, {r, g, b, a}, {r, g, b, a}, ...{r, g, b, a} }
		-> one different color by point (for kind COMBO/AURA/POWER)
	colors = { [RESOURCE_TYPE] = {r, g, b, a}, [RESOURCE_TYPE] = {r, g, b, a}, ...[RESOURCE_TYPE] = {r, g, b, a}}
		-> one different color by resource type (only for kind RESOURCE) (if no color is specified, default resource color will be used)

	Notes about spec
	spec = 1|2|3|4|"any" -> only shown in specified spec
	specs = {table of spec} -> only shown when in any of the specified spec
--]]
	["DRUID"] = {
		{ -- 1
			name = "CM_MOVER",
			kind = "MOVER",
			anchor = { "CENTER", UIParent, "CENTER", 0, -140 },
			width = 202,
			height = 8,
			text = L.classmonitor_move
		},
		{ -- 2
			name = "CM_RESOURCE",
			kind = "RESOURCE",
			text = true,
			autohide = true,
			anchor = { "TOPLEFT", "CM_MOVER", 0, 0 },
			width = 202,
			height = 8,
		},
		{ -- 3
			name = "CM_COMBO",
			kind = "COMBO",
			specs = {2, 3, 4},
			anchor = { "BOTTOMLEFT", "CM_RESOURCE", "TOPLEFT", 0, 3 },
			width = 38,
			height = 8,
			spacing = 3,
			colors = {
				{1.0, 1.0, 1.0, 1}, -- 1
				{1.0, 1.0, 1.0, 1}, -- 2
				{1.0, 1.0, 1.0, 1}, -- 3
				{0.9, 0.7, 0.0, 1}, -- 4
				{1.0, 0.0, 0.0, 1}, -- 5
			},
			filled = true,
		},
		{ -- 4
			name = "CM_ECLIPSE",
			kind = "ECLIPSE",
			spec = 1,
			anchor = { "BOTTOMLEFT", "CM_RESOURCE", "TOPLEFT", 0, 8 },
			width = 202,
			height = 8,
			text = true,
			colors = {
				{0.10, 0.22, 0.90, 1}, -- Lunar
				{1, 0.72, 0.10, 1}, -- Solar
			},
			autohide = true,
		},
		{ -- 5
			name = "CM_WILDMUSHROOMS",
			kind = "TOTEM",
			count = 3,
			specs = {1, 4},
			anchor = { "TOPLEFT", "CM_RESOURCE", "BOTTOMLEFT", 0, -3 },
			width = 66,
			height = 8,
			spacing = 2,
			color = { 35/255, 222/255,  35/255, 1 },
		},
	},
	["PALADIN"] = {
		{
			name = "CM_MOVER",
			kind = "MOVER",
			anchor = { "CENTER", UIParent, "CENTER", 0, -140 },
			width = 202,
			height = 8,
			text = L.classmonitor_move
		},
		--{
		--	name = "CM_HEALTH",
		--	kind = "HEALTH",
		--	text = true,
		--	autohide = true,
		--	anchor = { "TOP", "CM_MOVER", "BOTTOM", 0, -20},
		--	width = 261,
		--	height = 10,
		--},
		{
			name = "CM_MANA",
			kind = "RESOURCE",
			text = true,
			autohide = true,
			anchor = { "TOPLEFT", "CM_MOVER", 0, 0 },
			width = 202, -- 50 + 3 + 50 + 3 + 50 + 3 + 50 + 3 + 50
			height = 8,
		},
		{
			name = "CM_HOLYPOWER",
			kind = "POWER",
			powerType = SPELL_POWER_HOLY_POWER,
			count = 5,
			anchor = { "BOTTOMLEFT", "CM_MANA", "TOPLEFT", 0, 3 },
			width = 38,
			height = 8,
			spacing = 3,
			color = {0.95, 0.90, 0.30, 1},
			filled = true,
		},
	},
	["WARLOCK"] = {
		{
			name = "CM_MOVER",
			kind = "MOVER",
			anchor = { "CENTER", UIParent, "CENTER", 0, -140 },
			width = 201,
			height = 8,
			text = L.classmonitor_move
		},
		{
			name = "CM_MANA",
			kind = "RESOURCE",
			text = true,
			autohide = true,
			anchor = { "TOPLEFT", "CM_MOVER", 0, 0 },
			width = 201,
			height = 8,
		},
		{
			name = "CM_SOUL_SHARD",
			kind = "POWER",
			spec = SPEC_WARLOCK_AFFLICTION,
			powerType = SPELL_POWER_SOUL_SHARDS,
			count = 4,
			anchor = { "BOTTOMLEFT", "CM_MANA", "TOPLEFT", 0, 3 },
			width = 48,
			height = 8,
			spacing = 3,
			color = {0.50, 0.32, 0.55, 1},
			filled = true,
		},
		{
			name = "CM_BURNING_EMBERS",
			kind = "POWER",
			spec = SPEC_WARLOCK_DESTRUCTION,
			powerType = SPELL_POWER_BURNING_EMBERS,
			count = 4,
			anchor = { "BOTTOMLEFT", "CM_MANA", "TOPLEFT", 0, 3 },
			width = 48,
			height = 8,
			spacing = 3,
			color = {222/255, 95/255,  95/255, 1},
			filled = true,
		},
		{
			name = "CM_DEMONIC_FURY",
			kind = "POWER",
			spec = SPEC_WARLOCK_DEMONOLOGY,
			powerType = SPELL_POWER_DEMONIC_FURY,
			count = 1,
			anchor = { "BOTTOMLEFT", "CM_MANA", "TOPLEFT", 0, 3 },
			width = 201,
			height = 8,
			spacing = 3,
			color = {95/255, 222/255,  95/255, 1},
			filled = true,
		},
	},
	["ROGUE"] = {
		{
			name = "CM_MOVER",
			kind = "MOVER",
			anchor = { "CENTER", UIParent, "CENTER", 0, -140 },
			width = 202,
			height = 8,
			text = L.classmonitor_move
		},
		{
			name = "CM_ENERGY",
			kind = "RESOURCE",
			text = true,
			autohide = true,
			anchor = { "TOPLEFT", "CM_MOVER", 0, 0 },
			width = 202,
			height = 8,
		},
		{
			name = "CM_COMBO",
			kind = "COMBO",
			anchor = { "BOTTOMLEFT", "CM_ENERGY", "TOPLEFT", 0, 3 },
			width = 38,
			height = 8,
			spacing = 3,
			colors = { 
				{1.0, 1.0, 1.0, 1}, -- 1
				{1.0, 1.0, 1.0, 1}, -- 2
				{1.0, 1.0, 1.0, 1}, -- 3
				{0.9, 0.7, 0.0, 1}, -- 4
				{1.0, 0.0, 0.0, 1}, -- 5
			},
			filled = true,
			autohide = true,
		},
		{
			name = "CM_ANTICIPATION",
			kind = "AURA",
			spellID = 114015, -- Anticipation
			filter = "HELPFUL",
			count = 5,
			anchor = { "BOTTOMLEFT", "CM_COMBO", "TOPLEFT", 0, 3 },
			width = 38,
			height = 8,
			spacing = 3,
			color = {0.33, 0.63, 0.33, 1},
			filled = true,
		},
		{
			name = "CM_BANDITSGUILE",
			kind = "BANDITSGUILE",
			anchor = { "TOPLEFT", "CM_ENERGY", "BOTTOMLEFT", 0, -3},
			width = 66,
			height = 8,
			spacing = 2,
			colors = {
				{0.0, 1.0, 0.0, 1}, -- shallow
				{1.0, 1.0, 0.0, 1}, -- moderate
				{1.0, 0.0, 0.0, 1}, -- Deep
			},
			filled = true,
		},
	},
	["PRIEST"] = {
		{
			name = "CM_MOVER",
			kind = "MOVER",
			anchor = { "CENTER", UIParent, "CENTER", 0, -140 },
			width = 201,
			height = 8,
			text = L.classmonitor_move
		},
		{
			name = "CM_MANA",
			kind = "RESOURCE",
			text = true,
			autohide = true,
			anchor = { "TOPLEFT", "CM_MOVER", 0, 0 },
			width = 201,
			height = 8,
		},
		{
			name = "CM_SHADOW_ORBS",
			kind = "POWER",
			spec = 3, -- Shadow
			powerType = SPELL_POWER_SHADOW_ORBS,
			count = 3,
			anchor = { "BOTTOMLEFT", "CM_MANA", "TOPLEFT", 0, 3 },
			width = 64,
			height = 8,
			spacing = 3,
			color = {0.5, 0, 0.7, 1},
			filled = true,
		},
		{
			name = "CM_RAPTURE",
			kind = "REGEN",
			spec = 1, -- Discipline
			anchor = { "TOPLEFT", "CM_MANA", "BOTTOMLEFT", 0, -2 },
			width = 201,
			height = 3,
			spellID = 47755, -- Rapture
			filling = true,
			duration = 12,
		},
	},
	["MAGE"] = {
		{
			name = "CM_MOVER",
			kind = "MOVER",
			anchor = { "CENTER", UIParent, "CENTER", 0, -140 },
			width = 201,
			height = 8,
			text = L.classmonitor_move
		},
		{
			name = "CM_MANA",
			kind = "RESOURCE",
			spec = 1,
			text = true,
			autohide = true,
			anchor = { "TOPLEFT", "CM_MOVER", 0, 0 },
			width = 201,
			height = 8,
		},
		{
			name = "CM_ARCANE_BLAST",
			kind = "AURA",
			spec = 1, -- Arcane
			spellID = 36032, -- Arcane blast
			filter = "HARMFUL",
			count = 6,
			anchor = { "BOTTOMLEFT", "CM_MANA", "TOPLEFT", 0, 3 },
			width = 31,
			height = 8,
			spacing = 3,
			filled = true,
		},
	},
	["DEATHKNIGHT"] = {
		{
			name = "CM_MOVER",
			kind = "MOVER",
			anchor = { "CENTER", UIParent, "CENTER", 0, -140 },
			width = 202,
			height = 8,
			text = L.classmonitor_move
		},
		{
			name = "CM_RUNIC_POWER",
			kind = "RESOURCE",
			text = true,
			autohide = true,
			anchor = { "TOPLEFT", "CM_MOVER", 0, 0 },
			width = 202,
			height = 8,
		},
		{
			name = "CM_SHADOW_INFUSION",
			kind = "AURA",
			spec = 3,
			spellID = 91342, -- Shadow infusion
			filter = "HELPFUL",
			count = 5,
			anchor = { "BOTTOMLEFT", "CM_RUNIC_POWER", "TOPLEFT", 0, 3 },
			width = 38,
			height = 8,
			spacing = 4,
			color = { 0.33, 0.59, 0.33, 1 },
			filled = true,
		},
		{
			name = "CM_SCENTOFBLOOD",
			kind = "AURA",
			spec = 1,
			spellID = 50421, -- Scent of Blood
			filter = "HELPFUL",
			count = 5,
			anchor = { "BOTTOMLEFT", "CM_RUNIC_POWER", "TOPLEFT", 0, 3 },
			width = 38,
			height = 8,
			spacing = 4,
			color = { 1, 0.1, 0.1, 1 },
			filled = true,
		},
	},
	["HUNTER"] = {
		{
			name = "CM_MOVER",
			kind = "MOVER",
			anchor = { "CENTER", UIParent, "CENTER", 0, -140 },
			width = 202,
			height = 8,
			text = L.classmonitor_move
		},
		{
			name = "CM_FOCUS",
			kind = "RESOURCE",
			text = true,
			autohide = true,
			anchor = { "TOPLEFT", "CM_MOVER", 0, 0 },
			width = 202,
			height = 8,
		},
		{
			name = "CM_FRENZY",
			unit = "pet",
			kind = "AURA",
			spellID = 19615, -- Frenzy
			filter = "HELPFUL",
			count = 5,
			anchor = { "TOPLEFT", "CM_FOCUS", "BOTTOMLEFT", 0, -3 },
			width = 38,
			height = 8,
			spacing = 3,
			color = { 0.59, 0.63, 0.1, 1},
			filled = true,
		},
	},
	["WARRIOR"] = {
		{
			name = "CM_MOVER",
			kind = "MOVER",
			anchor = { "CENTER", UIParent, "CENTER", 0, -140 },
			width = 201,
			height = 8,
			text = L.classmonitor_move
		},
		{
			name = "CM_RAGE",
			kind = "RESOURCE",
			text = true,
			autohide = true,
			anchor = { "TOPLEFT", "CM_MOVER", 0, 0 },
			width = 201,
			height = 8,
		}
	},
	["SHAMAN"] = {
		{
			name = "CM_MOVER",
			kind = "MOVER",
			anchor = { "CENTER", UIParent, "CENTER", 0, -140 },
			width = 202,
			height = 8,
			text = L.classmonitor_move
		},
		{
			name = "CM_MANA",
			kind = "RESOURCE",
			text = true,
			autohide = true,
			anchor = { "TOPLEFT", "CM_MOVER", 0, 0 },
			width = 202,
			height = 8,
		},
		{
			name = "CM_FULMINATION",
			kind = "AURA",
			spec = 1,  -- Elemental
			spellID = 324, -- Fulmination
			filter = "HELPFUL",
			count = 7,
			anchor = { "BOTTOMLEFT", "CM_MANA", "TOPLEFT", 0, 4 },
			width = 26,
			height = 8,
			spacing = 3,
			color = {0.5, 0, 0.7, 1},
			filled = true,
		},
		{
			name = "CM_MAELSTROMM",
			kind = "AURA",
			spec = 2,  -- Enhancement
			spellID = 53817, -- Maestrom
			filter = "HELPFUL",
			count = 5,
			anchor = { "BOTTOMLEFT", "CM_MANA", "TOPLEFT", 0, 3 },
			width = 38,
			height = 8,
			spacing = 3,
			color = {0.5, 0, 0.7, 1},
			filled = true,
		},
		{
			name = "CM_TOTEMS",
			kind = "TOTEM",
			count = 4,
			anchor = { "TOPLEFT", "CM_MANA", "BOTTOMLEFT", 0, -8 },
			width = 49,
			height = 8,
			spacing = 2,
			text = true,
			colors = {
			-- In the order, fire, earth, water, air
				[1] = {.58,.23,.10},
				[2] = {.23,.45,.13},
				[3] = {.19,.48,.60},
				[4] = {.42,.18,.74},
			},
			-- earth, fire, water, air
			map = {2, 1, 3, 4},
		},
	},
	["MONK"] = {
		{
			name = "CM_MOVER",
			kind = "MOVER",
			anchor = { "CENTER", UIParent, "CENTER", 0, -140 },
			width = 201,
			height = 8,
			text = L.classmonitor_move
		},
		{
			name = "CM_RESOURCE",
			kind = "RESOURCE",
			text = true,
			autohide = true,
			anchor = { "TOPLEFT", "CM_MOVER", 0, 0 },
			width = 201,
			height = 8,
		},
		{
			name = "CM_CHI",
			kind = "POWER",
			powerType = SPELL_POWER_LIGHT_FORCE,
			count = 5,
			anchor = { "BOTTOMLEFT", "CM_RESOURCE", "TOPLEFT", 0, 3 },
			width = 48,
			height = 8,
			spacing = 3,
			colors = {
				[1] = {1.0, 1.0, 1.0, 1},
				[2] = {1.0, 1.0, 1.0, 1},
				[3] = {0.9, 0.7, 0.0, 1},
				[4] = {1.0, 0.0, 0.0, 1},
				[5] = {1.0, 0.0, 0.0, 1},
			},
			filled = true,
		},
		{
			name = "CM_MANATEA",
			kind = "AURA",
			spec = 2,  -- Mistweaver
			spellID = 115867, -- Mana tea
			filter = "HELPFUL",
			count = 20,
			anchor = { "TOPLEFT", "CM_RESOURCE", "BOTTOMLEFT", 0, -8 },
			width = 201,
			height = 8,
			color = {0.5, 0.9, 0.7, 1},
			filled = true,
			bar = true,
			text = true,
			duration = true,
		},
		{
			name = "CM_TIGEREYEBREW",
			kind = "AURA",
			spec = 3, -- Windwalker
			spellID = 125195, -- Tigereye brew
			filter = "HELPFUL",
			count = 10,
			anchor = { "TOPLEFT", "CM_RESOURCE", "BOTTOMLEFT", 0, -8 },
			width = 201,
			height = 8,
			color = {0.5, 0.9, 0.7, 1},
			filled = true,
			bar = true,
			text = true,
			duration = true,
		},
		{
			name = "CM_ELUSIVEBREW",
			kind = "AURA",
			spec = 1, -- Windwalker
			spellID = 128939, -- Elusive brew
			filter = "HELPFUL",
			count = 15,
			anchor = { "TOPLEFT", "CM_RESOURCE", "BOTTOMLEFT", 0, -8 },
			width = 201,
			height = 8,
			color = {0.5, 0.9, 0.7, 1},
			filled = true,
			bar = true,
			text = true,
			duration = true,
		}
	},
}