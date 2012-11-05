local zoneIDs = PetJournalEnhanced:NewModule("ZoneIDs")

zoneIDs.continents = {
	 [1] = {--	Kalimdor
		772,--	Ahn'Qiraj: The Fallen Kingdom
		894,--	Ammen Vale MoP
		43,--	Ashenvale
		181,--	Azshara
		464,--	Azuremyst Isle
		476,--	Bloodmyst Isle
		890,--	Camp Narache MoP
		42,--	Darkshore
		381,--	Darnassus
		101,--	Desolace
		4,--	Durotar
		141,--	Dustwallow Marsh
		891,--	Echo Isles MoP
		182,--	Felwood
		121,--	Feralas
		795,--	Molten Front
		241,--	Moonglade
		606,--	Mount Hyjal
		9,--	Mulgore
		11,--	Northern Barrens
		321,--	Orgrimmar
		888,--	Shadowglen MoP
		261,--	Silithus
		607,--	Southern Barrens
		81,--	Stonetalon Mountains
		161,--	Tanaris
		41,--	Teldrassil
		471,--	The Exodar
		61,--	Thousand Needles
		362,--	Thunder Bluff
		720,--	Uldum
		201,--	Un'Goro Crater
		889,--	Valley of Trials MoP
		281,--	Winterspring
	},
	[2] = {--	Eastern Kingdoms
		614,--	Abyssal Depths
		16,--	Arathi Highlands
		17,--	Badlands
		19,--	Blasted Lands
		29,--	Burning Steppes
		866,--	Coldridge Valley MoP
		32,--	Deadwind Pass
		892,--	Deathknell MoP
		27,--	Dun Morogh
		34,--	Duskwood
		23,--	Eastern Plaguelands
		30,--	Elwynn Forest
		462,--	Eversong Woods
		463,--	Ghostlands
		545,--	Gilneas
		611,--	Gilneas City
		24,--	Hillsbrad Foothills
		341,--	Ironforge
		499,--	Isle of Quel'Danas
		610,--	Kelp'thar Forest
		35,--	Loch Modan
		895,--	New Tinkertown MoP
		37,--	Northern Stranglethorn
		864,--	Northshire MoP
		36,--	Redridge Mountains
		684,--	Ruins of Gilneas
		685,--	Ruins of Gilneas City
		28,--	Searing Gorge
		615,--	Shimmering Expanse
		480,--	Silvermoon City
		21,--	Silverpine Forest
		301,--	Stormwind City
		689,--	Stranglethorn Vale
		893,--	Sunstrider Isle MoP
		38,--	Swamp of Sorrows
		673,--	The Cape of Stranglethorn
		26,--	The Hinterlands
		502,--	The Scarlet Enclave
		20,--	Tirisfal Glades
		708,--	Tol Barad
		709,--	Tol Barad Peninsula
		700,--	Twilight Highlands
		382,--	Undercity
		613,--	Vashj'ir
		22,--	Western Plaguelands
		39,--	Westfall
		40,--	Wetlands
	},
	[3]={--	Outland
		475,--	Blade's Edge Mountains
		465,--	Hellfire Peninsula
		477,--	Nagrand
		479,--	Netherstorm
		473,--	Shadowmoon Valley
		481,--	Shattrath City
		478,--	Terokkar Forest
		467,--	Zangarmarsh
	},
	

	[4]={--	Northrend
		486,--	Borean Tundra
		510,--	Crystalsong Forest
		504,--	Dalaran
		488,--	Dragonblight
		490,--	Grizzly Hills
		491,--	Howling Fjord
		541,--	Hrothgar's Landing
		492,--	Icecrown
		493,--	Sholazar Basin
		495,--	The Storm Peaks
		501,--	Wintergrasp
		496,--	Zul'Drak
	},


	[5]={--	The Maelstrom
		640,--	Deepholm
		605,--	Kezan
		544,--	The Lost Isles
		737,--	The Maelstrom
	},


	[6]={--	Pandaria MoP
		858,--	Dread Wastes MoP
		857,--	Krasarang Wilds MoP
		809,--	Kun-Lai Summit MoP
		905,--	Shrine of Seven Stars MoP
		903,--	Shrine of Two Moons MoP
		806,--	The Jade Forest MoP
		873,--	The Veiled Stair MoP
		808,--	The Wandering Isle MoP
		810,--	Townlong Steppes MoP
		811,--	Vale of Eternal Blossoms MoP
		807,--	Valley of the Four Winds MoP
	}
}
zoneIDs.instances = {
	["Battlegrounds"] = {
		401,--	Alterac Valley
		461,--	Arathi Basin
		482,--	Eye of the Storm
		540,--	Isle of Conquest
		512,--	Strand of the Ancients
		736,--	The Battle for Gilneas
		626,--	Twin Peaks
		443,--	Warsong Gulch
	},
	["Classic Dungeons"]={
		688,--	Blackfathom Deeps
		704,--	Blackrock Depths
		721,--	Blackrock Spire
		699,--	Dire Maul
		691,--	Gnomeregan
		750,--	Maraudon
		680,--	Ragefire Chasm
		760,--	Razorfen Downs
		761,--	Razorfen Kraul
		762,--	Scarlet Monastery
		763,--	Scholomance
		764,--	Shadowfang Keep
		765,--	Stratholme
		756,--	The Deadmines
		690,--	The Stockade
		687,--	The Temple of Atal'Hakkar
		692,--	Uldaman
		749,--	Wailing Caverns
		686,--	Zul'Farrak
	},
	["Classic Raids"]={
		755,--	Blackwing Lair
		696,--	Molten Core
		717,--	Ruins of Ahn'Qiraj
		766,--	Temple of Ahn'Qiraj
	},
	["Burning Crusade Dungeons"]={
		722,--	Auchenai Crypts
		797,--	Hellfire Ramparts
		798,--	Magisters' Terrace
		732,--	Mana-Tombs
		734,--	Old Hillsbrad Foothills
		723,--	Sethekk Halls
		724,--	Shadow Labyrinth
		731,--	The Arcatraz
		733,--	The Black Morass
		725,--	The Blood Furnace
		729,--	The Botanica
		730,--	The Mechanar
		710,--	The Shattered Halls
		728,--	The Slave Pens
		727,--	The Steamvault
		726,--	The Underbog
	},
	["Burning Crusade Raids"]={
		796,--	Black Temple
		776,--	Gruul's Lair
		775,--	Hyjal Summit
		799,--	Karazhan
		779,--	Magtheridon's Lair
		780,--	Serpentshrine Cavern
		789,--	Sunwell Plateau
		782,--	The Eye
	},
	["Wrath Dungeons"]={
		522,--	Ahn'kahet: The Old Kingdom
		533,--	Azjol-Nerub
		534,--	Drak'Tharon Keep
		530,--	Gundrak
		525,--	Halls of Lightning
		603,--	Halls of Reflection
		526,--	Halls of Stone
		602,--	Pit of Saron
		521,--	The Culling of Stratholme
		601,--	The Forge of Souls
		520,--	The Nexus
		528,--	The Oculus
		536,--	The Violet Hold
		542,--	Trial of the Champion
		523,--	Utgarde Keep
		524,--	Utgarde Pinnacle
	},
	["Wrath Raids"]={
		604,--	Icecrown Citadel
		535,--	Naxxramas
		718,--	Onyxia's Lair
		527,--	The Eye of Eternity
		531,--	The Obsidian Sanctum
		609,--	The Ruby Sanctum
		543,--	Trial of the Crusader
		529,--	Ulduar
		532,--	Vault of Archavon
	},
	["Cataclysm Dungeons"]={
		753,--	Blackrock Caverns
		820,--	End Time
		757,--	Grim Batol
		759,--	Halls of Origination
		819,--	Hour of Twilight
		747,--	Lost City of the Tol'vir
		768,--	The Stonecore
		769,--	The Vortex Pinnacle
		767,--	Throne of the Tides
		816,--	Well of Eternity
		781,--	Zul'Aman
		793,--	Zul'Gurub
	},
	["Cataclysm Raids"]={
		752,--	Baradin Hold
		754,--	Blackwing Descent
		824,--	Dragon Soul
		800,--	Firelands
		758,--	The Bastion of Twilight
		773,--	Throne of the Four Winds
	},
	["Pandaria Dungeons"]={
		875,--	Gate of the Setting Sun MoP
		885,--	Mogu'Shan Palace MoP
		877,--	Shado-pan Monastery MoP
		887,--	Siege of Niuzao Temple MoP
		876,--	Stormstout Brewery MoP
		867,--	Temple of the Jade Serpent MoP
	},
	["Pandaria Raids"]={
		897,--	Heart of Fear MoP
		896,--	Mogu'shan Vaults MoP
		886,--	Terrace of Endless Spring MoP
	}
}