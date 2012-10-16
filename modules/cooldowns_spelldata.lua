-- Data for spell cooldowns

local SpellData = {
	-- ================ DK ================
	-- ================ DRUID ================
	-- ================ PALADIN ================
	-- ================ SHAMAN ================
	-- ================ WARLOCK ================


	-- ================ MONK ================
	-- Monk/baseline
	-- Detox
	[115450] = {
		class = "MONK",
	 	dispel = true,
		cooldown = 8,
	},	
	-- Expel Harm
	[115072] = {
		class = "MONK",
		heal = true,
		offensive = true,
		cooldown = 15,
	},	
	-- Fortifying Brew
	[115203] = {
		class = "MONK",
		defensive = true,
		duration = 20,
		cooldown = 180,
	},	
	-- Grapple Weapon
	[117368] = {
		class = "MONK",
		disarm = true,
		cc = true,
		cooldown = 60,
	},	
	-- Paralysis
	[115078] = {
		class = "MONK",
		cc = true,
		cooldown = 15,
	},	
	-- Spear Hand Strike
	[116705] = {
		class = "MONK",
		interrupt = true,
		silence = true,
		cooldown = 15,
	},	
	-- Touch of Death
	[115080] = {
		class = "MONK",
		offensive = true,
		cooldown = 90,
	},	
	-- Transcendence
	[101643] = {
		class = "MONK",
		cooldown = 45,
	},
	-- Transcendence: Transfer
	[119996] = {
		class = "MONK",
		cooldown = 25,
	},
	-- Zen Meditation
	[115176] = {
		class = "MONK",
		defensive = true,
		duration = 8,
		cooldown = 180,
	},	

	-- Monk/talents
	-- Charging Ox Wave
	[119392] = {
		class = "MONK",
		talent = true,
		stun = true,
		cooldown = 60,
	},	
	-- Chi Brew
	[115399] = {
		class = "MONK",
		talent = true,
		cooldown = 90
	},
	-- Chii Wave
	[115098] = {
		class = "MONK",
		talent = true,
		cooldown = 8
	},
	-- Dampen Harm
	[122278] = {
		class = "MONK",
		talent = true,
		defensive = true,
		duration = 45,
		cooldown = 90,
	},	
	-- Diffuse Magic
	[122783] = {
		class = "MONK",
		talent = true,
		defensive = true,
		duration = 6,
		cooldown = 90,
	},	
	-- Invoke Xuen, the White
	[123904] = {
		class = "MONK",
		talent = true,
		duration = 45,
		cooldown = 180
	},
	-- Leg Sweep
	[119381] = {
		class = "MONK",
		talent = true,
		stun = true,
		cooldown = 45,
	},	
	-- Rushing Jade Wind
	[116847] = {
		class = "MONK",
		talent = true,
		offensive = true,
		cooldown = 30,
	},	
	-- Tiger's Lust
	[116841] = {
		class = "MONK",
		talent = true,
		defensive = true,
		duration = 6,
		cooldown = 30,
	},	

	-- Monk/Brewmaster
	-- Avert Harm
	[115213] = {
		class = "MONK",
		specID = { [268] = true },
		defensive = true,
		duration = 6,
		cooldown = 180
	},	
	-- Clash
	[122057] = {
		class = "MONK",
		specID = { [268] = true },
		cooldown = 35
	},
	-- Elusive Brew
	[115308] = {
		class = "MONK",
		specID = { [268] = true },
		defensive = true,
		duration = 3,
		cooldown = 9,
	},	
	-- Guard
	[115295] = {
		class = "MONK",
		specID = { [268] = true },
		defensive = true,
		duration = 30,
		cooldown = 30
	},	
	-- Keg Smash
	[121253] = {
		class = "MONK",
		specID = { [268] = true },
		offensive = true,
		cooldown = 8
	},	
	-- Summon Black Ox
	[115315] = {
		class = "MONK",
		specID = { [268] = true },
		cooldown = 30
	},

	-- Monk/Windwalker
	-- Energizing Brew
	[115288] = {
		class = "MONK",
		specID = { [269] = true },
		offensive = true,
		duration = 6,
		cooldown = 60,
	},	
	-- Fists of Fury
	[113656] = {
		class = "MONK",
		specID = { [269] = true },
		offensive = true,
		duration = 4,
		cooldown = 25,
	},	
	-- Flying Serpent Kick
	[101545] = {
		class = "MONK",
		specID = { [269] = true },
		cooldown = 25,

	},
	-- Rising Sun Kick
	[107428] = {
		class = "MONK",
		specID = { [269] = true },
		offensive = true,
		cooldown = 8,

	},
	-- Touch of Karma
	[122470] = {
		class = "MONK",
		specID = { [269] = true },
		offensive = true,
		defensive = true,
		duration = 10,
		cooldown = 90
	},

	-- Monk/Mistweaver
	-- Life Cocoon
	[116849] = {
		class = "MONK",
		specID = { [270] = true },
	 	heal = true,
		duration = 12,
		cooldown = 120,
	},	
	-- Renewing Misg
	[115151] = {
		class = "MONK",
		specID = { [270] = true },
		heal = true,
		cooldown = 8
	},	
	-- Revival
	[115310] = {
		class = "MONK",
		specID = { [270] = true },
		mass_dispel = true,
		cooldown = 180
	},	
	-- Summon Jade Serpent
	[115313] = {
		class = "MONK",
		specID = { [270] = true },
		heal = true,
		cooldown = 30
	},	
	-- Thunder Focus Tea
	[116680] = {
		class = "MONK",
		specID = { [270] = true },
		heal = true,
		duration = 30,
		cooldown = 45
	},	


	-- ================ MAGE ================
	-- Mage/baseline
	-- Alter Time
	[108978] = {
		class = "MAGE",
		defensive = true,
		duration = 6,
		cooldown = 180
	},
	-- Blink
	[1953] = {
		class = "MAGE",
		defensive = true,
		cooldown = 15
	},
	-- Cone of Cold
	[120] = {
		class = "MAGE",
		offensive = true,
		cooldown = 10
	},
	-- Counterspell
	[2139] = {
		class = "MAGE",
		interrupt = true,
		silence = true, -- with glyph
		cooldown = 24,
	},
	-- Deep Freeze
	[44572] = {
		class = "MAGE",
		stun = true,
		cooldown = 30
	},
	-- Evocation
	[12051] = {
		class = "MAGE",
		defensive = true,
		duration = 6,
		cooldown = 120
	},
	-- Fire Blast
	[2136] = {
		class = "MAGE",
		offensive = true,
		cooldown = 8
	},
	-- Flamestrike
	[2120] = {
		class = "MAGE",
		offensive = true,
		duration = 8,
		cooldown = 12
	},
	-- Frost Nova
	[122] = {
		class = "MAGE",
		cc = true,
		cooldown = 25
	},
	-- Ice Block
	[45438] = {
		class = "MAGE",
		defensive = true,
		immune = true,
		duration = 10,
		cooldown = 300
	},
	-- Invisibility
	[66] = {
		class = "MAGE",
		defensive = true,
		duration = 3,
		cooldown = 300
	},
	-- Mirror Image
	[55342] = {
		class = "MAGE",
		offensive = true,
		duration = 30,
		cooldown = 180
	},
	-- Time Warp
	[80353] = {
		class = "MAGE",
		offensive = true,
		duration = 40,
		cooldown = 300
	},
	-- Mage/talents
	-- Blazing Speed
	[108843] = {
		class = "MAGE",
		talent = true,
		defensive = true,
		duration = 1.5,
		cooldown = 25
	},
	-- Cauterize
	[86949] = {
		class = "MAGE",
		talent = true,
		defensive = true,
		duration = 6,
		cooldown = 120
	},
	-- Cold Snap
	[11958] = {
		class = "MAGE",
		talent = true,
		resets = { 45438, 122, 120 },
		cooldown = 180
	},
	-- Frost Bomb
	[112948] = {
		class = "MAGE",
		talent = true,
		offensive = true,
		cooldown = 10
	},
	-- Frostjaw
	[102051] = {
		class = "MAGE",
		talent = true,
		silence = true,
		cc = true,
		cooldown = 20
	},
	-- Greater Invisibility
	[110959] = {
		class = "MAGE",
		talent = true,
		defensive = true,
		replaces = 66,
		duration = 20,
		cooldown = 150
	},
	-- Ice Barrier
	[11426] = {
		class = "MAGE",
		talent = true,
		defensive = true,
		duration = 60,
		cooldown = 25
	},
	-- Ice Floes
	[108839] = {
		class = "MAGE",
		talent = true,
		offensive = true,
		cooldown = 60
	},
	-- Ice Ward
	[111264] = {
		class = "MAGE",
		talent = true,
		cc = true,
		cooldown = 20
	},
	-- Incanter's Ward
	[1463] = {
		class = "MAGE",
		talent = true,
		defensive = true,
		duration = 8,
		cooldown = 25
	},
	-- Invocation
	[114003] = {
		class = "MAGE",
		talent = true,
		defensive = true,
		replaces = 12051,
		cooldown = 10
	},
	-- Presence of Mind
	[12043] = {
		class = "MAGE",
		talent = true,
		offensive = true,
		cooldown_starts_on_aura_fade = true,
		cooldown = 90
	},
	-- Ring of Frost
	[113724] = {
		class = "MAGE",
		talent = true,
		cc = true,
		duration = 10,
		cooldown = 30
	},
	-- Temporal Shield
	[115610] = {
		class = "MAGE",
		talent = true,
		defensive = true,
		duration = 4,
		cooldown = 25
	},
	-- Mage/Arcane
	-- Arcane Power
	[12042] = {
		class = "MAGE",
		specID = { [62] = true },
		offensive = true,
		duration = 15,
		cooldown = 90
	},
	-- Mage/Fire
	-- Combustion
	[11129] = {
		class = "MAGE",
		specID = { [63] = true },
		stun = true,
		offensive = true,
		cooldown = 45
	},
	-- Dragon's Breath
	[31661] = {
		class = "MAGE",
		specID = { [63] = true },
		cc = true,
		cooldown = 20
	},
	-- Mage/Frost
	-- Frozen Orb
	[84714] = {
		class = "MAGE",
		specID = { [64] = true },
		offensive = true,
		duration = 10,
		cooldown = 60
	},
	-- Icy Veins
	[12472] = {
		class = "MAGE",
		specID = { [64] = true },
		offensive = true,
		duration = 20,
		cooldown = 180
	},
	-- Summon Water Elemental
	[31687] = {
		class = "MAGE",
		specID = { [64] = true },
		offensive = true,
		cooldown = 60
	},

	-- ================ PRIEST ================
	-- Priest/baseline
	-- Hymn of Hope
	[64901] = {
		class = "PRIEST",
		defensive = true,
		duration = 8,
		cooldown = 360,
	},
	-- Psychic Scream
	[8122] = {
		class = "PRIEST",
		cc = true,
		cooldown = 27,
	},
	-- Shadowfiend
	[34433] = {
		class = "PRIEST",
		offensive = true,
		duration = 12,
		cooldown =  180,
	},
	-- Leap of Faith
	[73325] = {
		class = "PRIEST",
		defensive = true,
		cooldown = 90,
	},
	-- Void Shift
	[108968] = {
		class = "PRIEST",
		defensive = true,
		cooldown = 360,
	},
	-- Mass Dispel
	[32375] = {
		class = "PRIEST",
		mass_dispel = true,
		cooldown = 15
	},
	-- Priest/talents
	-- Void Tendrils
	[108920] = {
		class = "PRIEST",
		talent = true,
		cc = true,
		cooldown =  30
	},
	-- Psyfiend
	[108921] = {
		class = "PRIEST",
		talent = true,
		cc = true,
		duration = 10,
		cooldown =  45
	},
	-- Phantasm
	[108942] = {
		class = "PRIEST",
		talent = true,
		defensive = true,
		cooldown =  30
	},
	-- Mindbender
	[123040] = {
		class = "PRIEST",
		talent = true,
		replaces = 34433,
		offensive = true,
		duration = 15,
		cooldown = 60
	},
	-- Desperate Prayer
	[19236] = {
		class = "PRIEST",
		talent = true,
		defensive = true,
		cooldown = 120
	},
	-- Spectral Guise
	[112833] = {
		class = "PRIEST",
		talent = true,
		defensive = true,
		duration = 6,
		cooldown = 30
	},
	-- Angelic Bulwark
	[108945] = {
		class = "PRIEST",
		talent = true,
		defensive = true,
		cooldown = 90
	},
	-- Power Infusion
	[10060] = {
		class = "PRIEST",
		talent = true,
		offensive = true,
		duration = 20,
		cooldown = 120
	},
	-- Cascade
	[121135] = {
		class = "PRIEST",
		talent = true,
		offensive = true,
		heal = true,
		cooldown = 25
	},
	-- Divine Star
	[110744] = {
		class = "PRIEST",
		talent = true,
		offensive = true,
		heal = true,
		cooldown =  15
	},
	-- Halo
	[120517] = {
		class = "PRIEST",
		talent = true,
		offensive = true,
		heal = true,
		cooldown =  40
	},

	-- Priest/Discipline
	-- Penance
	[47540] = {
		class = "PRIEST",
		specID = { [256] = true },
		heal = true,
		duration = 2,
		cooldown = 10,
	},
	-- Inner Focus
	[89485] = {
		class = "PRIEST",
		specID = { [256] = true },
		defensive = true,
		cooldown_starts_on_aura_fade = true,
		sets_cooldown = { spellid = 96267, cooldown = 45 },
		cooldown = 45,
	},
	-- Glyph of Inner Focus
	[96267] = {
		class = "PRIEST",
		specID = { [256] = true },
		glyph = true,
		defensive = true,
		replaces = 89485,
		active_until_cooldown_start = true,
		duration = 5,
	},
	-- Pain Suppression
	[33206] = {
		class = "PRIEST",
		specID = { [256] = true },
		defensive = true,
		duration = 8,
		cooldown = 180,
	},
	-- Power Word: Barrier
	[62618] = {
		class = "PRIEST",
		specID = { [256] = true },
		defensive = true,
		duration = 10,
		cooldown = 180,
	},
	-- Spirit Shell
	[109964] = {
		class = "PRIEST",
		specID = { [256] = true },
		defensive = true,
		duration = 15,
		cooldown = 60,
	},
	-- Purify
	[527] = {
		class = "PRIEST",
		specID = { [256] = true, [257] = true },
		dispel = true,
		cooldown_starts_on_dispel = true,
		cooldown = 8,
	},
	
	-- Priest/Holy
	-- Guardian Spirit
	[47788] = {
		class = "PRIEST",
		specID = { [257] = true },
		defensive = true,
		duration = 10,
		cooldown = 180,
	},
	-- Lightwell
	[724] = {
		class = "PRIEST",
		specID = { [257] = true },
		heal = true,
		cooldown = 180,
	},
	-- Divine Hymn
	[64843] = {
		class = "PRIEST",
		specID = { [257] = true },
		heal = true,
		duration = 8,
		cooldown = 18
	},
	-- Holy Word: Chastise
	[88625] = {
		class = "PRIEST",
		specID = { [257] = true },
		cc = true,
		cooldown = 30
	},
	-- Holy Word: Serenity
	-- 88684 0 10
	-- Circle of Healing
	[34861] = {
		class = "PRIEST",
		specID = { [257] = true },
		heal = true,
		cooldown = 10
	},

	-- Priest/Shadow
	-- Dispersion
	[47585] = {
		class = "PRIEST",
		specID = { [258] = true },
		defensive = true,
		duration = 6,
		cooldown = 105, -- 120
	},
	-- Psychic Horror
	[64044] = {
		class = "PRIEST",
		specID = { [258] = true },
		cc = true,
		cooldown = 45
	},
	-- Silence
	[15487] = {
		class = "PRIEST",
		specID = { [258] = true },
		silence = true,
		cooldown = 45,
	},

	-- ================ ROGUE ================
	-- Rogue/baseline
	-- Blind
	[2094] = {
		class = "ROGUE",
		cc = true,
		cooldown = 180
	},
	-- Cloak of Shadows
	[31224] = {
		class = "ROGUE",
		defensive = true,
		duration = 5,
		cooldown = 120
	},
	-- Dismantle
	[51722] = {
		class = "ROGUE",
		cc = true,
		cooldown = 60
	},
	-- Evasion
	[5277] = {
		class = "ROGUE",
		defensive = true,
		duration = 15,
		cooldown = 180
	},
	--[[
	-- Feint
	[1966] = {
		class = "ROGUE",
		defensive = true,
		duration = 5
	},
	]]
	-- Gouge
	[1776] = {
		class = "ROGUE",
		cc = true,
		cooldown = 10
	},
	-- Kick
	[1766] = {
		class = "ROGUE",
		interrupt = true,
		cooldown = 15
	},
	-- Kidney Shot
	[408] = {
		class = "ROGUE",
		stun = true,
		cooldown = 20
	},
	-- Redirect
	[73981] = {
		class = "ROGUE",
		offensive = true,
		cooldown = 60
	},
	-- Shadow Blades
	[121471] = {
		class = "ROGUE",
		offensive = true,
		duration = 12,
		cooldown = 180
	},
	-- Smoke Bomb
	[76577] = {
		class = "ROGUE",
		defensive = true,
		duration = 5,
		cooldown = 180
	},
	-- Sprint
	[2983] = {
		class = "ROGUE",
		duration = 8,
		cooldown = 60
	},
	-- Tricks of the Trade
	[57934] = {
		class = "ROGUE",
		offensive = true,
		duration = 6,
		cooldown = 30
	},
	-- Vanish
	[1856] = {
		class = "ROGUE",
		defensive = true,
		duration = 3,
		cooldown = 180
	},

	-- Rogue/Assassination 259
	-- Vendetta
	[79140] = {
		class = "ROGUE",
		specID = { [259] = true },
		offensive = true,
		duration = 20,
		cooldown = 120
	},

	-- Rogue/Combat 260
	-- Adrenaline Rush
	[13750] = {
		class = "ROGUE",
		specID = { [260] = true },
		offensive = true,
		duration = 15,
		cooldown = 180
	},
	-- Killing Spree
	[51690] = {
		class = "ROGUE",
		specID = { [260] = true },
		offensive = true,
		duration = 3,
		cooldown = 120
	},

    -- Rogue/Subtlety 261
    -- Premeditation
    [14183] = {
    	class = "ROGUE",
    	specID = { [261] = true },
    	offensive = true,
    	cooldown = 20
    },
    -- Shadow Dance
    [51713] = {
    	class = "ROGUE",
    	specID = { [261] = true },
    	offensive = true,
    	duration = 8,
    	cooldown = 60
    },

    -- Rogue/talents
	-- Cheat Death
	[31230] = {
		class = "ROGUE",
		talent = true,
		defensive = true,
		duration = 3,
		cooldown = 90
	},
	-- Combat Readiness
	[74001] = {
		class = "ROGUE",
		talent = true,
		defensive = true,
		duration = 20,
		cooldown = 120
	},
	-- Preparation
	[14185] = {
		class = "ROGUE",
		talent = true,
		defensive = true,
		resets = { 2983, 1856, 31224, 5277, 51722 },
		cooldown = 300
	},
	-- Shadowstep
	[36554] = {
		class = "ROGUE",
		talent = true,
		offensive = true,
		duration = 2,
		cooldown = 24
	},

	-- ================ WARRIOR ================
	-- Warrior/baseline
	-- Berserker Rage
	[18499] = {
		class = "WARRIOR",
		offensive = true,
		duration = 6,
		cooldown = 30
	},
	-- Charge
	[100] = {
		class = "WARRIOR",
		stun = true,
		cooldown = 20
	},
	-- Deadly Calm
	[85730] = {
		class = "WARRIOR",
		offensive = true,
		cooldown = 60
	},
	-- Disarm
	[676] = {
		class = "WARRIOR",
		cc = true,
		cooldown = 60
	},
	-- Heroic Leap
	[6544] = {
		class = "WARRIOR",
		cooldown = 45
	},
	-- Heroic Throw
	[57755] = {
		class = "WARRIOR",
		silence = true,
		cooldown = 30
	},
	-- Intervene
	[3411] = {
		class = "WARRIOR",
		defensive = true,
		cooldown = 30
	},
	-- Intimidating Shout
	[5246] = {
		class = "WARRIOR",
		cc = true,
		cooldown = 60
	},
	-- Pummel
	[6552] = {
		class = "WARRIOR",
		interrupt = true,
		silence = true,
		cooldown = 15
	},
	-- Rallying Cry
	[97462] = {
		class = "WARRIOR",
		defensive = true,
		duration = 10,
		cooldown = 180
	},
	-- Recklessness
	[1719] = {
		class = "WARRIOR",
		offensive = true,
		duration = 12,
		cooldown = 300
	},
	-- Shattering Throw
	[64382] = {
		class = "WARRIOR",
		mass_dispel = true,
		offensive = true,
		cooldown = 300
	},
	-- Shield Wall
	[871] = {
		class = "WARRIOR",
		defensive = true,
		duration = 12,
		cooldown = 300
	},
	-- Skull Banner
	[114207] = {
		class = "WARRIOR",
		offensive = true,
		duration = 10,
		cooldown = 180
	},
	-- Spell Reflection
	[23920] = {
		class = "WARRIOR",
		defensive = true,
		duration = 5,
		cooldown = 25
	},
	-- Warrior/talents
	-- Enraged Regeneration
	[55694] = {
		class = "WARRIOR",
		talent = true,
		heal = true,
		duration = 5,
		cooldown = 60
	},
	-- Impending Victory
	[103840] = {
		class = "WARRIOR",
		heal = true,
		talent = true,
		cooldown = 30
	},
	-- Staggering Shout
	[107566] = {
		class = "WARRIOR",
		talent = true,
		cc = true,
		cooldown = 40
	},
	-- Disrupting Shout
	[102060] = {
		class = "WARRIOR",
		talent = true,
		interrupt = true,
		cooldown = 40
	},
	-- Shockwave
	[46968] = {
		class = "WARRIOR",
		talent = true,
		stun = true,
		cooldown = 20
	},
	-- Bladestorm
	[46924] = {
		class = "WARRIOR",
		talent = true,
		offensive = true,
		duration = 6,
		cooldown = 90
	},
	-- Dragon Roar
	[118000] = {
		class = "WARRIOR",
		talent = true,
		knockback = true,
		duration = 0.5,
		cooldown= 60
	},
	-- Vigilance
	[114030] = {
		class = "WARRIOR",
		talent = true,
		defensive = true,
		duration = 12,
		cooldown = 120
	},
	-- Safeguard
	[114029] = {
		class = "WARRIOR",
		talent = true,
		defensive = true,
		duration = 6,
		cooldown = 30
	},
	-- Mass Spell Reflection
	[114028] = {
		class = "WARRIOR",
		talent = true,
		defensive = true,
		duration = 5,
		cooldown = 60
	},
	-- Avatar
	[107574] = {
		class = "WARRIOR",
		talent = true,
		offensive = true,
		duration = 20,
		cooldown = 180
	},
	-- Storm Bolt
	[107570] = {
		class = "WARRIOR",
		talent = true,
		stun = true,
		cooldown = 30
	},
	-- Bloodbath
	[12292] = {
		class = "WARRIOR",
		talent = true,
		offensive = true,
		duration = 12,
		cooldown = 60
	},
	-- Warrior/Arms
	-- Colossus Smash
	[86346] = {
		class = "WARRIOR",
		specID = { [71] = true, [72] = true },
		offensive = true,
		duration = 6,
		cooldown = 20
	},
	-- Mortal Strike
	[12294] = {
		class ="WARRIOR",
		specID = { [71] = true },
		offensive = true,
		cooldown = 6
	},
	-- Die by the Sword
	[118038] = {
		class = "WARRIOR",
		specID = { [71] = true, [72] = true },
		defensive = true,
		duration = 8,
		cooldown = 120
	},
    -- Warrior/Fury
    -- Warrior/Protection
    -- Demoralizing Shout
    [1160] = {
    	class = "WARRIOR",
    	specID = { [73] = true },
    	defensive = true,
    	duration = 10,
    	cooldown = 60
    },
    -- Last Stand
    [12975] = {
    	class = "WARRIOR",
    	specID = { [73] = true },
    	defensive = true,
    	duration = 20,
    	cooldown = 180
    },
    -- Shield Barrier
    [112048] = {
    	class = "WARRIOR",
    	specID = { [73] = true },
    	defensive = true,
    	duration = 6,
    	cooldown = 90
    },

	-- Racials
	-- Every Man for Himself (Human)
	[59752] = 42292,
	-- Gift of the Naaru (Draenei)
	[59544] = {
		race = "Draenei",
		heal = true,
		duration = 15,
		cooldown = 180,
	},
	[28880] = 59544,
	[59542] = 59544,
	[59543] = 59544,
	[59545] = 59544,
	[59547] = 59544,
	[59548] = 59544,
	[121093] = 59544,
	-- Arcane Torrent (Blood Elf)
	[28730] = {
		race = "BloodElf",
		silence = true,
		cooldown = 120,
	},
	[50613] = 28730,
	[80483] = 28730,
	[129597] = 28730,
	[25046] = 28730,
	[69179] = 28730,
	-- Blood Fury (Orc)
	[20572] = {
		race = "Orc",
		offensive = true,
		duration = 15,
		cooldown = 120,
	},
	[33697] = 20572,
	[33702] = 20572,
	-- Cannibalize (Undead)
	[20577] = {
		race = "Scourge",
		duration = 10,
		cooldown = 120,
	},
	-- Will of the Forsaken (Undead)
	[7744] = {
		race = "Scourge",
		cooldown = 120,
	},
	-- Darkflight (Worgen)
	[68992] = {
		race = "Worgen",
		duration = 10,
		cooldown = 120,
	},
	-- Escape Artist (Gnome)
	[20589] = {
		race = "Gnome",
		defensive = true,
		cooldown = 90,
	},
	-- Quaking Palm (Pandaren)
	[107079] = {
		race = "Pandaren",
		cc = true,
		cooldown = 120,
	},
	-- Rocket Barrage (Goblin)
	[69041] = {
		race = "Goblin",
		offensive = true,
		cooldown = 120,
	},
	-- Rocket Jump (Goblin)
	[69070] = {
		race = "Goblin",
		cooldown = 120,
	},
	-- Shadowmeld (Night Elf)
	[58984] = {
		race = "NightElf",
		defensive = true,
		cooldown = 120,
	},
	-- Stoneform (Dwarf)
	[20594] = {
		race = "Dwarf",
		defensive = true,
		duration = 8,
		cooldown = 120,
	},
	-- War Stomp (Tauren)
	[20549] = {
		race = "Tauren",
		stun = true,
		duration = 2,
		cooldown = 120,
	},
	-- Berserking (Troll)
	[26297] = {
		race = "Troll",
		offensive = true,
		duration = 10,
		cooldown = 180
	},

	-- Items
	-- PvP Trinket
	[42292] = {
		item = true,
		pvp_trinket = true,
		icon_alliance = [[Interface\Icons\INV_Jewelry_TrinketPVP_01]],
		icon_horde = [[Interface\Icons\INV_Jewelry_TrinketPVP_02]],
		cooldown = 120,
	},
}

-- insert additional info
for spellid, spelldata in pairs(SpellData) do
	if type(spelldata) == "table" then
		local name, _, icon = GetSpellInfo(spellid)	
		spelldata.name = name
		spelldata.icon = icon
	end
end

Gladius.CooldownsSpellData = SpellData
