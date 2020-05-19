local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local fn = LibStub("LibFunctional-1.0")
local LSM = LibStub("LibSharedMedia-3.0")

-- upvalues
local strfind = string.find
local pairs, select, unpack = pairs, select, unpack
local GetTime, SetPortraitTexture = GetTime, SetPortraitTexture
local GetSpellInfo, UnitAura, UnitClass, UnitGUID, UnitBuff, UnitDebuff = GetSpellInfo, UnitAura, UnitClass, UnitGUID, UnitBuff, UnitDebuff
local UnitIsVisible, UnitIsConnected, GetSpecializationInfoByID, GetTexCoordsForRole = UnitIsVisible, UnitIsConnected, GetSpecializationInfoByID, GetTexCoordsForRole

-- NOTE: this list can be modified from the ClassIcon module options, no need to edit it here
-- Nonetheless, if you think that we missed an important aura, please post it on the addon site at curse or wowace
local function GetDefaultImportantAuras()
	return {
		-- Higher Number is More Priority
		-- Priority List by Bibimapi
		[GladiusEx:SafeGetSpellName(167152)]   = 10,    -- Refreshment
		[GladiusEx:SafeGetSpellName(118358)]   = 10,    -- Drink
		[GladiusEx:SafeGetSpellName(115191)]   = 10,    -- Stealth
		[GladiusEx:SafeGetSpellName(5215)]     = 10,    -- Prowl
		[GladiusEx:SafeGetSpellName(114018)]   = 10.2,  -- Shroud of Concealment
		[GladiusEx:SafeGetSpellName(198158)]   = 10.3,  -- Mass Invisibility
		[GladiusEx:SafeGetSpellName(115834)]   = 10.1,  -- Shroud of Concealment


		[GladiusEx:SafeGetSpellName(45438)]    = 10,    -- Ice Block
		[GladiusEx:SafeGetSpellName(45182)]    = 10,    -- Cheating Death
		[GladiusEx:SafeGetSpellName(51690)]    = 10,    -- Killing Spree
		[GladiusEx:SafeGetSpellName(152150)]   = 10,    -- Death from Above
		[GladiusEx:SafeGetSpellName(152175)]   = 10,    -- Hurricane Strike
		[GladiusEx:SafeGetSpellName(227847)]   = 10,    -- Bladestorm
		[GladiusEx:SafeGetSpellName(46924)]    = 10,    -- Bladestorm
		[GladiusEx:SafeGetSpellName(19263)]    = 10,    -- Deterrence
		[GladiusEx:SafeGetSpellName(47585)]    = 10,    -- Dispersion
		[GladiusEx:SafeGetSpellName(202748)]   = 10,    -- Survival Tactics
		[GladiusEx:SafeGetSpellName(642)]      = 10,    -- Divine Shield
		[GladiusEx:SafeGetSpellName(210918)]   = 10,    -- Ethereal Form
		[GladiusEx:SafeGetSpellName(215769)]   = 10,    -- Spirit of Redemption
		[GladiusEx:SafeGetSpellName(186265)]   = 10,    -- Aspect of the Turtle
		[GladiusEx:SafeGetSpellName(196555)]   = 10,    -- Netherwalk
		[GladiusEx:SafeGetSpellName(58984)]    = 10,    -- Shadowmeld
		[GladiusEx:SafeGetSpellName(6940)]      = 9.1,  -- Blessing of Sacrifice
		[GladiusEx:SafeGetSpellName(199448)]    = 9.1,  -- Blessing of Sacrifice (talented)
		[GladiusEx:SafeGetSpellName(19386)]     = 9,    -- Wyvern Sting
		[GladiusEx:SafeGetSpellName(710)]       = 9,    -- Banish              
		[GladiusEx:SafeGetSpellName(2094)]      = 9,    -- Blind
		[GladiusEx:SafeGetSpellName(203126)]    = 9,    -- Maim (Disorient)
		[GladiusEx:SafeGetSpellName(207167)]    = 9,    -- Blinding Sleet
		[GladiusEx:SafeGetSpellName(209753)]    = 9.1,  -- Cyclone (boomy)
		[GladiusEx:SafeGetSpellName(33786)]     = 9.1,  -- Cyclone (rdruid)
		[GladiusEx:SafeGetSpellName(221527)]    = 9.1,  -- Imprison
		[GladiusEx:SafeGetSpellName(605)]       = 9,    -- Mind Control
		[GladiusEx:SafeGetSpellName(118699)]    = 9,    -- Fear
		[GladiusEx:SafeGetSpellName(238559)]    = 9,    -- Bursting Shot
		[GladiusEx:SafeGetSpellName(3355)]      = 9,    -- Freezing Trap
		[GladiusEx:SafeGetSpellName(203337)]    = 9,    -- Freezing Trap (talented)
		[GladiusEx:SafeGetSpellName(209790)]    = 9,    -- Freezing Arrow
		[GladiusEx:SafeGetSpellName(162480)]    = 9,    -- Steel Trap
		[GladiusEx:SafeGetSpellName(51514)]     = 9,    -- Hex
		[GladiusEx:SafeGetSpellName(211004)]    = 9,    -- Hex
		[GladiusEx:SafeGetSpellName(210873)]    = 9,    -- Hex
		[GladiusEx:SafeGetSpellName(211015)]    = 9,    -- Hex
		[GladiusEx:SafeGetSpellName(211010)]    = 9,    -- Hex
		[GladiusEx:SafeGetSpellName(196942)]    = 9,    -- Hex Totem
		[GladiusEx:SafeGetSpellName(5484)]      = 9,    -- Howl of Terror
		[GladiusEx:SafeGetSpellName(5246)]      = 9,    -- Intimidating Shout
		[GladiusEx:SafeGetSpellName(115268)]    = 9,    -- Mesmerize (Shivarra)
		[GladiusEx:SafeGetSpellName(6789)]      = 9,    -- Mortal Coil
		[GladiusEx:SafeGetSpellName(118)]       = 9,    -- Polymorph
		[GladiusEx:SafeGetSpellName(28272)]     = 9,    -- Polymorph
		[GladiusEx:SafeGetSpellName(28271)]     = 9,    -- Polymorph
		[GladiusEx:SafeGetSpellName(61305)]     = 9,    -- Polymorph
		[GladiusEx:SafeGetSpellName(61721)]     = 9,    -- Polymorph
		[GladiusEx:SafeGetSpellName(61780)]     = 9,    -- Polymorph
		[GladiusEx:SafeGetSpellName(126819)]    = 9,    -- Polymorph
		[GladiusEx:SafeGetSpellName(161353)]    = 9,    -- Polymorph
		[GladiusEx:SafeGetSpellName(161354)]    = 9,    -- Polymorph
		[GladiusEx:SafeGetSpellName(161355)]    = 9,    -- Polymorph
		[GladiusEx:SafeGetSpellName(161372)]    = 9,    -- Polymorph
		[GladiusEx:SafeGetSpellName(105421)]    = 9,    -- Blinding Light
		[GladiusEx:SafeGetSpellName(213691)]    = 9,    -- Scatter Shot
		[GladiusEx:SafeGetSpellName(8122)]      = 9,    -- Psychic Scream
		[GladiusEx:SafeGetSpellName(20066)]     = 9,    -- Repentance
		[GladiusEx:SafeGetSpellName(82691)]     = 9,    -- Ring of Frost
		[GladiusEx:SafeGetSpellName(6770)]      = 9.1,  -- Sap
		[GladiusEx:SafeGetSpellName(99)]        = 8,    -- Disorienting Roar
		[GladiusEx:SafeGetSpellName(198909)]    = 8,    -- Song of Chi-Ji
		[GladiusEx:SafeGetSpellName(107079)]    = 9,    -- Quaking Palm
		[GladiusEx:SafeGetSpellName(6358)]      = 9,    -- Seduction (Succubus)
		[GladiusEx:SafeGetSpellName(9484)]      = 9,    -- Shackle Undead
		[GladiusEx:SafeGetSpellName(1776)]      = 9,    -- Gouge
		[GladiusEx:SafeGetSpellName(31661)]     = 9,    -- Dragon's Breath


		[GladiusEx:SafeGetSpellName(108194)]    = 8,    -- Asphyxiate
		[GladiusEx:SafeGetSpellName(207171)]    = 8,    -- Winter is Coming
		[GladiusEx:SafeGetSpellName(210141)]    = 8,    -- Zombie Explosion
		[GladiusEx:SafeGetSpellName(22703)]     = 8,    -- Infernal Awakening
		[GladiusEx:SafeGetSpellName(91800)]     = 8,    -- Gnaw (Ghoul)
		[GladiusEx:SafeGetSpellName(91797)]     = 8,    -- Monstrous Blow (Dark Transformation Ghoul)
		[GladiusEx:SafeGetSpellName(89766)]     = 8,    -- Axe Toss (Felguard)
		[GladiusEx:SafeGetSpellName(24394)]     = 8,    -- Intimidation
		[GladiusEx:SafeGetSpellName(7922)]      = 8,    -- Charge Stun
		[GladiusEx:SafeGetSpellName(1833)]      = 8,    -- Cheap Shot
		[GladiusEx:SafeGetSpellName(199804)]    = 8,    -- Between the Eyes
		[GladiusEx:SafeGetSpellName(226943)]    = 8,    -- Mind Bomb
		[GladiusEx:SafeGetSpellName(77505)]     = 8,    -- Earthquake
		[GladiusEx:SafeGetSpellName(91800)]     = 8,    -- Gnaw
		[GladiusEx:SafeGetSpellName(47481)]     = 8,    -- Gnaw
		[GladiusEx:SafeGetSpellName(213688)]    = 8,    -- Fel Cleave
		[GladiusEx:SafeGetSpellName(853)]       = 8,    -- Hammer of Justice
		[GladiusEx:SafeGetSpellName(200196)]    = 8,    -- Holy Word: Chastise
		[GladiusEx:SafeGetSpellName(19577)]     = 8,    -- Intimidation
		[GladiusEx:SafeGetSpellName(408)]       = 8,    -- Kidney Shot
		[GladiusEx:SafeGetSpellName(200200)]    = 8,    -- Holy Word: Chastise
		[GladiusEx:SafeGetSpellName(119381)]    = 8.2,  -- Leg Sweep
		[GladiusEx:SafeGetSpellName(179057)]    = 8.1,  -- Chaos Nova
		[GladiusEx:SafeGetSpellName(200166)]     = 8,    -- Metamorphosis
		[GladiusEx:SafeGetSpellName(211881)]    = 8,    -- Fel Eruption
		[GladiusEx:SafeGetSpellName(204399)]    = 8,    -- Earthfury
		[GladiusEx:SafeGetSpellName(204437)]    = 8,    -- Lightning Lasso
		[GladiusEx:SafeGetSpellName(197214)]    = 8,    -- Sundering
		[GladiusEx:SafeGetSpellName(203123)]    = 8,    -- Maim
		[GladiusEx:SafeGetSpellName(5211)]      = 8,    -- Mighty Bash
		[GladiusEx:SafeGetSpellName(118345)]    = 8,    -- Pulverize (Primal Earth Elemental)
		[GladiusEx:SafeGetSpellName(30283)]     = 8,    -- Shadowfury
		[GladiusEx:SafeGetSpellName(212332)]    = 8,    -- Smash
		[GladiusEx:SafeGetSpellName(212337)]    = 8,    -- Powerful Smash
		[GladiusEx:SafeGetSpellName(22703)]     = 8,    -- Summon Infernal
		[GladiusEx:SafeGetSpellName(132168)]    = 8,    -- Shockwave
		[GladiusEx:SafeGetSpellName(118905)]    = 8,    -- Lightning Surge Totem
		[GladiusEx:SafeGetSpellName(132169)]    = 8,    -- Storm Bolt
		[GladiusEx:SafeGetSpellName(20549)]     = 8,    -- War Stomp
		[GladiusEx:SafeGetSpellName(16979)]     = 8,    -- Wild Charge
		[GladiusEx:SafeGetSpellName(87204)]     = 8,    -- Sin and Punishment
		[GladiusEx:SafeGetSpellName(117526)]    = 8,    -- Binding Shot
		[163505]    = 8,    -- Rake
		[GladiusEx:SafeGetSpellName(232055)]    = 8.3,  -- Fists of Fury
		[GladiusEx:SafeGetSpellName(48792)]     = 8,    -- Icebound Fortitude
		[GladiusEx:SafeGetSpellName(115078)]    = 8.1,  -- Paralysis
		[GladiusEx:SafeGetSpellName(217832)]    = 8,  -- Imprison
		[GladiusEx:SafeGetSpellName(236025)]    = 8,  -- Enraged Maim
		[GladiusEx:SafeGetSpellName(199743)]    = 8.1,  -- Parley


		[GladiusEx:SafeGetSpellName(104773)]    = 8,    -- Unending Resolve
		[GladiusEx:SafeGetSpellName(77606)]    = 7.4,  -- Dark Simulacrum

		-- Silence Auras
		[GladiusEx:SafeGetSpellName(122470)]    = 7,    -- Touch of Karma
		[GladiusEx:SafeGetSpellName(125174)]    = 7,    -- Touch of Karma
		[GladiusEx:SafeGetSpellName(5277)]      = 7.4,  -- Evasion
		[GladiusEx:SafeGetSpellName(213602)]    = 7.4,  -- greater fade
		[GladiusEx:SafeGetSpellName(226364)]    = 7.3,  -- Evasion
		[GladiusEx:SafeGetSpellName(198760)]    = 7.2,  -- Intercept
		[GladiusEx:SafeGetSpellName(199027)]    = 7.2,  -- Veil of Midnight
		[GladiusEx:SafeGetSpellName(199754)]    = 7.3,  -- Riposte
		[GladiusEx:SafeGetSpellName(198144)]    = 7.3,  -- Ice Form
		[GladiusEx:SafeGetSpellName(202627)]    = 7.3,  -- Catlike Reflexes
		[GladiusEx:SafeGetSpellName(210655)]    = 7.3,  -- Protection of Ashamane
		[GladiusEx:SafeGetSpellName(188499)]    = 7.3,  -- Blade Dance
		[GladiusEx:SafeGetSpellName(212800)]    = 7.2,  -- Blur
		[GladiusEx:SafeGetSpellName(209426)]    = 7.1,  -- Darkness
		[GladiusEx:SafeGetSpellName(1022)]      = 7.4,  -- Hand of Protection
		[GladiusEx:SafeGetSpellName(18499)]     = 7.3,  -- Berserker Rage
    [196364]                                = 7,    -- UA silence
		[1330]                                  = 7,    -- Garrote (Silence)
		[GladiusEx:SafeGetSpellName(15487)]     = 7,    -- Silence
		[GladiusEx:SafeGetSpellName(236077)]    = 7,    -- Disarm
		[GladiusEx:SafeGetSpellName(209749)]    = 7,    -- Faerie Swarm
		[GladiusEx:SafeGetSpellName(199683)]    = 7,    -- Last Word
		[GladiusEx:SafeGetSpellName(202933)]    = 7,    -- Spider Sting
		[GladiusEx:SafeGetSpellName(47476)]     = 7.5,  -- Strangulate
		[GladiusEx:SafeGetSpellName(31935)]     = 7,    -- Avenger's Shield
		[GladiusEx:SafeGetSpellName(116844)]    = 7,    -- Ring of Peace
		[GladiusEx:SafeGetSpellName(207319)]    = 7,    -- Corpse Shield
		[GladiusEx:SafeGetSpellName(81261)]     = 7,    -- Solar Beam
		[GladiusEx:SafeGetSpellName(201325)]    = 7,    -- Zen Meditation
		[GladiusEx:SafeGetSpellName(28730)]     = 7,    -- Arcane Torrent (Mana version)
		[GladiusEx:SafeGetSpellName(80483)]     = 7,    -- Arcane Torrent (Focus version)
		[GladiusEx:SafeGetSpellName(25046)]     = 7,    -- Arcane Torrent (Energy version)
		[GladiusEx:SafeGetSpellName(50613)]     = 7,    -- Arcane Torrent (Runic Power version)
		[GladiusEx:SafeGetSpellName(69179)]     = 7,    -- Arcane Torrent (Rage version)


		[GladiusEx:SafeGetSpellName(91807)]      = 6,    -- Shambling Rush (Ghoul)
		[GladiusEx:SafeGetSpellName(116706)]    = 6,    -- Disable
		[GladiusEx:SafeGetSpellName(157997)]     = 6,    -- Ice Nova
		[GladiusEx:SafeGetSpellName(228600)]     = 6,    -- Glacial Spike
		[GladiusEx:SafeGetSpellName(198121)]     = 6,    -- Frostbite
		[GladiusEx:SafeGetSpellName(233395)]     = 6,    -- Frozen Center
		[GladiusEx:SafeGetSpellName(64695)]      = 6,    -- Earthgrab (Earthgrab Totem)
		[GladiusEx:SafeGetSpellName(61685)]      = 6,    -- Charge (Various)
		[GladiusEx:SafeGetSpellName(64695)]      = 6,    -- Earthgrab
		[GladiusEx:SafeGetSpellName(64803)]      = 6,    -- Entrapment
		[GladiusEx:SafeGetSpellName(339)]        = 6,    -- Entangling Roots
		[GladiusEx:SafeGetSpellName(236699)]    = 6,    -- Tar Trap
		[GladiusEx:SafeGetSpellName(170995)]     = 6,    -- Cripple
		[GladiusEx:SafeGetSpellName(170855)]     = 6,    -- Entangling Roots
		[GladiusEx:SafeGetSpellName(235963)]     = 6,    -- Entangling Roots
		[GladiusEx:SafeGetSpellName(45334)]      = 6,    -- Immobilized (Wild Charge - Bear)
		[GladiusEx:SafeGetSpellName(33395)]      = 6,    -- Freeze (Water Elemental)
		[GladiusEx:SafeGetSpellName(122)]        = 6,    -- Frost Nova
		[GladiusEx:SafeGetSpellName(102359)]     = 6,    -- Mass Entanglement
		[GladiusEx:SafeGetSpellName(190927)]     = 6,    -- Harpoon
		[GladiusEx:SafeGetSpellName(200108)]     = 6,    -- Ranger's Net
		[GladiusEx:SafeGetSpellName(212638)]     = 6,    -- Tracker's Net
		[GladiusEx:SafeGetSpellName(201158)]     = 6,    -- Super Sticky Tar
		[GladiusEx:SafeGetSpellName(237338)]     = 6,    -- xplosive miss
		[GladiusEx:SafeGetSpellName(135373)]     = 6,    -- Entrapment
		[GladiusEx:SafeGetSpellName(64803)]      = 6,    -- Entrapment
		[GladiusEx:SafeGetSpellName(53148)]      = 6,    -- Charge
		[GladiusEx:SafeGetSpellName(105771)]     = 6,    -- Charge
		[GladiusEx:SafeGetSpellName(91807)]      = 6,    -- Shambling Rush (Dark Transformation) 
		[GladiusEx:SafeGetSpellName(212540)]     = 6,    -- Flesh Hook
		[GladiusEx:SafeGetSpellName(204085)]     = 6,    -- Deathchill


		[GladiusEx:SafeGetSpellName(48707)]      = 5.2,  -- Anti-Magic Shell
		[GladiusEx:SafeGetSpellName(212295)]     = 5.2,  -- Nether Ward
		[GladiusEx:SafeGetSpellName(116849)]     = 5,    -- Life Cocoon
		[GladiusEx:SafeGetSpellName(110960)]     = 5.1,  -- Greater Invisibility
		[GladiusEx:SafeGetSpellName(113862)]     = 5,    -- Greater Invisibility
		[GladiusEx:SafeGetSpellName(108271)]     = 5,    -- Astral Shift
		[GladiusEx:SafeGetSpellName(22812)]      = 5,    -- Barkskin
		[GladiusEx:SafeGetSpellName(197268)]     = 5.4,  -- Ray of Hope
		[GladiusEx:SafeGetSpellName(31224)]      = 5.3,  -- Cloak of Shadows
		[GladiusEx:SafeGetSpellName(108359)]     = 5,    -- Dark Regeneration
		[GladiusEx:SafeGetSpellName(118038)]     = 5.1,  -- Die by the Sword
		[GladiusEx:SafeGetSpellName(209484)]     = 5,    -- Tactical Advance
		[GladiusEx:SafeGetSpellName(498)]        = 5,    -- Divine Protection
		[GladiusEx:SafeGetSpellName(236321)]     = 5,    -- War Banner
		[GladiusEx:SafeGetSpellName(199507)]     = 5,    -- Spreading The Word: Protection
		[GladiusEx:SafeGetSpellName(205191)]     = 5.1,  -- Eye for an Eye
		[GladiusEx:SafeGetSpellName(47788)]      = 5,    -- Guardian Spirit
		[GladiusEx:SafeGetSpellName(66)]         = 5,    -- Invisibility
		[GladiusEx:SafeGetSpellName(32612)]      = 5,    -- Invisibility
		[GladiusEx:SafeGetSpellName(102342)]     = 5,    -- Ironbark
		[GladiusEx:SafeGetSpellName(210256)]     = 5,    -- Blessing of Sanctuary
		[GladiusEx:SafeGetSpellName(213610)]     = 5,    -- Holy Ward
		[GladiusEx:SafeGetSpellName(122783)]     = 5.1,  -- Diffuse Magic
		[GladiusEx:SafeGetSpellName(33206)]      = 5,    -- Pain Suppression
		[GladiusEx:SafeGetSpellName(53480)]      = 5,    -- Roar of Sacrifice
		[GladiusEx:SafeGetSpellName(192081)]     = 5,    -- Ironfur
		[GladiusEx:SafeGetSpellName(184364)]     = 5,    -- Enraged Regeneration
		[GladiusEx:SafeGetSpellName(207736)]     = 5,    -- Shadowy Duel
		[GladiusEx:SafeGetSpellName(236273)]     = 5,    -- Duel
		[GladiusEx:SafeGetSpellName(207756)]     = 5,    -- Shadowy Duel
		[GladiusEx:SafeGetSpellName(198111)]     = 5,    -- Temporal Shield
		[GladiusEx:SafeGetSpellName(216890)]     = 5.1,  -- Spell Reflection
		[GladiusEx:SafeGetSpellName(248519)]     = 5.1,  -- Interlope (bm pet redirect)
		[GladiusEx:SafeGetSpellName(61336)]      = 5,    -- Survival Instincts


		--[GladiusEx:SafeGetSpellName(31842)]      = 4,    -- V: removed in Bfa. Divine Favor
		[GladiusEx:SafeGetSpellName(196773)]     = 4,    -- inner focus
		[GladiusEx:SafeGetSpellName(206803)]     = 4.1,  -- Rain from Above
		[GladiusEx:SafeGetSpellName(206804)]     = 4,    -- Rain from Above
		[GladiusEx:SafeGetSpellName(1044)]       = 4,    -- Blessing of Freedom
		[GladiusEx:SafeGetSpellName(198498)]     = 4,    -- Blood Hunt
		[GladiusEx:SafeGetSpellName(197003)]     = 4,    -- Maneuverability
		[GladiusEx:SafeGetSpellName(198065)]     = 4,    -- Prismatic Cloak
		[GladiusEx:SafeGetSpellName(54216)]      = 4,    -- Master's Call
		[GladiusEx:SafeGetSpellName(207777)]     = 7,    -- Dismantle
		[GladiusEx:SafeGetSpellName(8178)]       = 4,    -- Grounding Totem Effect
		[GladiusEx:SafeGetSpellName(115192)]     = 4.1,  -- Subterfuge
		[GladiusEx:SafeGetSpellName(11327)]      = 4,    -- Vanish


		[GladiusEx:SafeGetSpellName(12042)]      = 3,    -- Arcane Power
		[GladiusEx:SafeGetSpellName(114050)]     = 3,    -- Ascendance
		[GladiusEx:SafeGetSpellName(208997)]     = 3.1,  -- Counterstrike Totem
		--[GladiusEx:SafeGetSpellName(203727)]     = 3.1,  -- V: removed in Bfa. Thorns
		[GladiusEx:SafeGetSpellName(236696)]     = 3.1,  -- Thorns
		[GladiusEx:SafeGetSpellName(114051)]     = 3,    -- Ascendance
		[GladiusEx:SafeGetSpellName(114052)]     = 3,    -- Ascendance
		[GladiusEx:SafeGetSpellName(47536)]      = 3.1,    -- Rapture
		[GladiusEx:SafeGetSpellName(231895)]     = 3,    -- Crusade
		[GladiusEx:SafeGetSpellName(196098)]     = 3,    -- Soul Harvest
		[GladiusEx:SafeGetSpellName(212284)]     = 3.1,  -- Firestone
		[GladiusEx:SafeGetSpellName(216708)]     = 3.1,  -- Deadwind Harvester
		[GladiusEx:SafeGetSpellName(194249)]     = 3,    -- Voidform
		[GladiusEx:SafeGetSpellName(1719)]       = 3.4,  -- Battle Cry
		[GladiusEx:SafeGetSpellName(16166)]      = 3,    -- Elemental Mastery
		[GladiusEx:SafeGetSpellName(204362)]     = 3.3,  -- Heroism
		[GladiusEx:SafeGetSpellName(204361)]     = 3.3,  -- Bloodlust
		[GladiusEx:SafeGetSpellName(12472)]      = 3,    -- Icy Veins
		[GladiusEx:SafeGetSpellName(33891)]      = 3,    -- Incarnation: Tree of Life
		[GladiusEx:SafeGetSpellName(102560)]     = 3,    -- Incarnation: Chosen of Elune
		[GladiusEx:SafeGetSpellName(102543)]     = 3,    -- Incarnation: King of the Jungle
		[GladiusEx:SafeGetSpellName(102558)]     = 3,    -- Incarnation: Son of Ursoc
		[GladiusEx:SafeGetSpellName(19574)]      = 3,    -- Bestial Wrath
		[GladiusEx:SafeGetSpellName(190319)]     = 3,    -- Combustion
		[GladiusEx:SafeGetSpellName(193526)]     = 3,    -- Trueshot
		[GladiusEx:SafeGetSpellName(216113)]     = 3,    -- Way of the Crane
		[GladiusEx:SafeGetSpellName(1719)]       = 3,    -- Recklessness
		[GladiusEx:SafeGetSpellName(186289)]     = 2.9,  -- Aspect of the Eagle
		[GladiusEx:SafeGetSpellName(193530)]     = 2.9,  -- Aspect of the Wild
		[GladiusEx:SafeGetSpellName(194223)]     = 3,    -- Celestial Alignment
		[GladiusEx:SafeGetSpellName(191427)]     = 3,    -- Metamorphosis
		[GladiusEx:SafeGetSpellName(152173)]     = 3,    -- Serenity


		[GladiusEx:SafeGetSpellName(185422)]     = 2.3,  -- Shadow Dance

		[GladiusEx:SafeGetSpellName(121471)]     = 2.2,  -- Shadow Blades
		[GladiusEx:SafeGetSpellName(79140)]      = 2.3,  -- Vendetta
		--[GladiusEx:SafeGetSpellName(211048)]     = 2.3,  -- V: removed in Bfa. Chaos Blades
		[GladiusEx:SafeGetSpellName(51271)]      = 2.1,  -- Pillar of Frost
		[GladiusEx:SafeGetSpellName(207127)]     = 2,    -- Hungering Rune Weapon
		[GladiusEx:SafeGetSpellName(204945)]     = 2,    -- Doom Winds
		[GladiusEx:SafeGetSpellName(207256)]     = 1.9,  -- Obliteration
		[GladiusEx:SafeGetSpellName(107574)]     = 2.1,  -- Avatar
		[GladiusEx:SafeGetSpellName(13750)]      = 2.1,  -- Adrenaline Rush
		[GladiusEx:SafeGetSpellName(202665)]     = 2,    -- Curse of the Dreadblades
		[GladiusEx:SafeGetSpellName(201318)]     = 2.1,  -- Fortifying Elixir
		[GladiusEx:SafeGetSpellName(97463)]      = 2.2,  -- Rallying Cry
		--[GladiusEx:SafeGetSpellName(31842)]      = 2.1,  --  V: removed in Bfa.Avenging Wrath
		[GladiusEx:SafeGetSpellName(31884)]      = 2.1,  -- Avenging Wrath
		[GladiusEx:SafeGetSpellName(216331)]     = 2.1,  -- Avenging Crusader
		[GladiusEx:SafeGetSpellName(184662)]     = 2.2,  -- Shield of Vengeance
		[GladiusEx:SafeGetSpellName(116014)]     = 2,    -- Rune of Power
		[GladiusEx:SafeGetSpellName(221404)]     = 2.1,  -- Burning Determination
		[GladiusEx:SafeGetSpellName(1966)]       = 2.1,  -- Feint
		[GladiusEx:SafeGetSpellName(201325)]     = 2.1,  -- Zen Moment
		[GladiusEx:SafeGetSpellName(122278)]     = 2.2,  -- Dampen
		[GladiusEx:SafeGetSpellName(207498)]     = 2.1,  -- Ancestral Protection
		[GladiusEx:SafeGetSpellName(206649)]     = 2,    -- Eye of Leotheras


		[GladiusEx:SafeGetSpellName(116095)]     = 1.1,  -- Disable
		[GladiusEx:SafeGetSpellName(186257)]     = 1.1,  -- Aspect of the Cheetah
		[GladiusEx:SafeGetSpellName(108212)]     = 1.1,  -- Burst of Speed

		[GladiusEx:SafeGetSpellName(36554)]      = 1.1,  -- Shadowstep
		[GladiusEx:SafeGetSpellName(221886)]     = 1.1,  -- Divine Steed
		[GladiusEx:SafeGetSpellName(116841)]     = 1,    -- Tiger's Lust
		[GladiusEx:SafeGetSpellName(97463)]      = 1,    -- Commanding Shout
		[GladiusEx:SafeGetSpellName(195638)]     = 1.3,  -- Focused Fire
		[GladiusEx:SafeGetSpellName(221677)]     = 1.3,  -- Calming Waters
		[GladiusEx:SafeGetSpellName(212552)]     = 1.1,  -- Wraith Walk
		[GladiusEx:SafeGetSpellName(188501)]     = 1,    -- Spectral Sight
		[GladiusEx:SafeGetSpellName(5384)]       = 1,    -- Feign Death
		[GladiusEx:SafeGetSpellName(51052)]      = 1,    -- Anti-Magic Zone
		[GladiusEx:SafeGetSpellName(76577)]      = 1,    -- Smoke Bomb
		[GladiusEx:SafeGetSpellName(212183)]     = 1,    -- Smoke Bomb
		[GladiusEx:SafeGetSpellName(88611)]      = 1,    -- Smoke Bomb
		[GladiusEx:SafeGetSpellName(57934)]      = 1,    -- Tricks
		[GladiusEx:SafeGetSpellName(197690)]     = 1,    -- def stance
		[GladiusEx:SafeGetSpellName(199890)]     = 1,    -- Curse of Tongues
		[GladiusEx:SafeGetSpellName(199892)]     = 1,    -- Curse of Weakness
		[GladiusEx:SafeGetSpellName(199954)]     = 1,    -- Curse of Fragility
		[GladiusEx:SafeGetSpellName(200587)]     = 1.2,  -- Fel Fissure
		[GladiusEx:SafeGetSpellName(198819)]     = 1.2,  -- Mortal Strike
		[GladiusEx:SafeGetSpellName(80240)]      = 1.1,  -- Havoc
		[GladiusEx:SafeGetSpellName(200548)]     = 1.1,  -- Bane of Havoc
		[GladiusEx:SafeGetSpellName(199483)] = 1.2,  -- Camouflage
	}
end

local defaults = {
	classIconMode = "SPEC",
	classIconGloss = false,
	classIconGlossColor = { r = 1, g = 1, b = 1, a = 0.4 },
	classIconImportantAuras = true,
	classIconCrop = true,
	classIconCooldown = true,
	classIconCooldownReverse = true,
	classIconAuras = GetDefaultImportantAuras()
}

local ClassIcon = GladiusEx:NewGladiusExModule("ClassIcon",
	fn.merge(defaults, {
		classIconPosition = "LEFT",
	}),
	fn.merge(defaults, {
		classIconPosition = "RIGHT",
	}))

function ClassIcon:OnEnable()
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "UNIT_AURA")
	self:RegisterEvent("UNIT_MODEL_CHANGED")
	self:RegisterMessage("GLADIUS_SPEC_UPDATE", "UNIT_AURA")
	self:RegisterMessage("GLADIUSEX_INTERRUPT", "UNIT_AURA")

	if not self.frame then
		self.frame = {}
	end
end

function ClassIcon:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()

	for unit in pairs(self.frame) do
		self.frame[unit]:Hide()
	end
end

function ClassIcon:GetAttachType(unit)
	return "InFrame"
end

function ClassIcon:GetAttachPoint(unit)
	return self.db[unit].classIconPosition
end

function ClassIcon:GetAttachSize(unit)
	return GladiusEx:GetBarsHeight(unit)
end

function ClassIcon:GetModuleAttachPoints()
	return {
		["ClassIcon"] = L["ClassIcon"],
	}
end

function ClassIcon:GetModuleAttachFrame(unit)
	if not self.frame[unit] then
		self:CreateFrame(unit)
	end

	return self.frame[unit]
end

function ClassIcon:UNIT_AURA(event, unit)
	if not self.frame[unit] then return end

	-- important auras
	self:UpdateAura(unit)
end

function ClassIcon:UNIT_MODEL_CHANGED(event, unit)
	if not self.frame[unit] then return end

	-- force model update
	if self.frame[unit].portrait3d then
		self.frame[unit].portrait3d.guid = false
	end

	self:UpdateAura(unit)
end

function ClassIcon:ScanAuras(unit)
	local best_priority = 0
	local best_name, best_icon, best_duration, best_expires

	-- debuffs
	for index = 1, 40 do
		local name, icon, _, _, duration, expires, _, _, _, spellid = UnitDebuff(unit, index)
		if not name then break end
		local prio = self:GetImportantAura(unit, name) or self:GetImportantAura(unit, spellid)
		if prio and prio > best_priority or (prio == best_priority and best_expires and expires < best_expires) then
			best_name, best_icon, best_duration, best_expires, best_priority = name, icon, duration, expires, prio
		end
	end

	-- buffs
	for index = 1, 40 do
		local name, icon, _, _, duration, expires, _, _, _, spellid = UnitBuff(unit, index)
		if not name then break end
		local prio = self:GetImportantAura(unit, name) or self:GetImportantAura(unit, spellid)
		-- V: make sure we have a best_expires before comparing it
		if prio and prio > best_priority or (prio == best_priority and best_expires and expires < best_expires) then
			best_name, best_icon, best_duration, best_expires, best_priority = name, icon, duration, expires, prio
		end
	end
	
	-- interrupts
	local interrupt = GladiusEx:GetModule("Interrupts", true)
	if interrupt then
		interrupt = {interrupt:GetInterruptFor(unit)}
		local name, icon, duration, expires, prio = unpack(interrupt)
		if prio and prio > best_priority or (prio == best_priority and best_expires and expires < best_expires) then
			best_name, best_icon, best_duration, best_expires, best_priority = name, icon, duration, expires, prio
		end
	end
	
	return best_name, best_icon, best_duration, best_expires
end

function ClassIcon:UpdateAura(unit)
	if not self.frame[unit] or not self.db[unit].classIconImportantAuras then return end

	local name, icon, duration, expires = self:ScanAuras(unit)

	if name then
		self:SetAura(unit, name, icon, duration, expires)
	else
		self:SetClassIcon(unit)
	end
end

function ClassIcon:SetAura(unit, name, icon, duration, expires)
	-- display aura
	self:SetTexture(unit, icon, true, 0, 1, 0, 1)

	if self.db[unit].classIconCooldown then
		CooldownFrame_Set(self.frame[unit].cooldown, expires - duration, duration, 1)
		self.frame[unit].cooldown:Show()
	end
end

function ClassIcon:SetTexture(unit, texture, needs_crop, left, right, top, bottom)
	-- so the user wants a border, but the borders in the blizzard icons are
	-- messed up in random ways (some are missing the alpha at the corners, some contain
	-- random blocks of colored pixels there)
	-- so instead of using the border already present in the icons, we crop them and add
	-- our own (this would have been a lot easier if wow allowed alpha mask textures)
	local needs_border = needs_crop and not self.db[unit].classIconCrop
	local size = self:GetAttachSize(unit)
	if needs_border then
		self.frame[unit].texture:ClearAllPoints()
		self.frame[unit].texture:SetPoint("CENTER")
		self.frame[unit].texture:SetWidth(size * (1 - 6 / 64))
		self.frame[unit].texture:SetHeight(size * (1 - 6 / 64))
		self.frame[unit].texture_border:Show()
	else
		self.frame[unit].texture:ClearAllPoints()
		self.frame[unit].texture:SetPoint("CENTER")
		self.frame[unit].texture:SetWidth(size)
		self.frame[unit].texture:SetHeight(size)
		self.frame[unit].texture_border:Hide()
	end

	if needs_crop then
		local n
		if self.db[unit].classIconCrop then n = 5 else n = 3 end
		left = left + (right - left) * (n / 64)
		right = right - (right - left) * (n / 64)
		top = top + (bottom - top) * (n / 64)
		bottom = bottom - (bottom - top) * (n / 64)
	end

	-- set texture
	self.frame[unit].texture:SetTexture(texture)
	self.frame[unit].texture:SetTexCoord(left, right, top, bottom)

	-- hide portrait
	if self.frame[unit].portrait3d then
		self.frame[unit].portrait3d:Hide()
	end
	if self.frame[unit].portrait2d then
		self.frame[unit].portrait2d:Hide()
	end
end

function ClassIcon:SetClassIcon(unit)
	if not self.frame[unit] then return end

	-- hide cooldown frame
	self.frame[unit].cooldown:Hide()

	if self.db[unit].classIconMode == "PORTRAIT2D" then
		-- portrait2d
		if not self.frame[unit].portrait2d then
			self.frame[unit].portrait2d = self.frame[unit]:CreateTexture(nil, "OVERLAY")
			self.frame[unit].portrait2d:SetAllPoints()
			local n = 9 / 64
			self.frame[unit].portrait2d:SetTexCoord(n, 1 - n, n, 1 - n)
		end
		if not UnitIsVisible(unit) or not UnitIsConnected(unit) then
			self.frame[unit].portrait2d:Hide()
		else
			SetPortraitTexture(self.frame[unit].portrait2d, unit)
			self.frame[unit].portrait2d:Show()
			if self.frame[unit].portrait3d then
				self.frame[unit].portrait3d:Hide()
			end
			self.frame[unit].texture:SetTexture(0, 0, 0, 1)
			return
		end
	elseif self.db[unit].classIconMode == "PORTRAIT3D" then
		-- portrait3d
		local zoom = 1.0
		if not self.frame[unit].portrait3d then
			self.frame[unit].portrait3d = CreateFrame("PlayerModel", nil, self.frame[unit])
			self.frame[unit].portrait3d:SetAllPoints()
			self.frame[unit].portrait3d:SetScript("OnShow", function(f) f:SetPortraitZoom(zoom) end)
			self.frame[unit].portrait3d:SetScript("OnHide", function(f) f.guid = nil end)
		end
		if not UnitIsVisible(unit) or not UnitIsConnected(unit) then
			self.frame[unit].portrait3d:Hide()
		else
			local guid = UnitGUID(unit)
			if self.frame[unit].portrait3d.guid ~= guid then
				self.frame[unit].portrait3d.guid = guid
				self.frame[unit].portrait3d:SetUnit(unit)
				self.frame[unit].portrait3d:SetPortraitZoom(zoom)
				self.frame[unit].portrait3d:SetPosition(0, 0, 0)
			end
			self.frame[unit].portrait3d:Show()
			self.frame[unit].texture:SetTexture(0, 0, 0, 1)
			if self.frame[unit].portrait2d then
				self.frame[unit].portrait2d:Hide()
			end
			return
		end
	end

	-- get unit class
	local class, specID
	if not GladiusEx:IsTesting(unit) then
		class = select(2, UnitClass(unit))
		specID = GladiusEx.buttons[unit].specID
		-- check for arena prep info
		if not class then
			if GladiusEx.buttons[unit].class then
				class = GladiusEx.buttons[unit].class
			end
		end
	else
		class = GladiusEx.testing[unit].unitClass
		specID = GladiusEx.testing[unit].specID
	end

	local texture
	local left, right, top, bottom
	local needs_crop

	if not class then
		texture = [[Interface\Icons\INV_Misc_QuestionMark]]
		left, right, top, bottom = 0, 1, 0, 1
		needs_crop = true
	elseif self.db[unit].classIconMode == "ROLE" and specID then
		local _, _, _, _, _, role = GetSpecializationInfoByID(specID)
		texture = [[Interface\LFGFrame\UI-LFG-ICON-ROLES]]
		left, right, top, bottom = GetTexCoordsForRole(role)
		needs_crop = false
	elseif self.db[unit].classIconMode == "SPEC" and specID then
		texture = select(4, GetSpecializationInfoByID(specID))
		left, right, top, bottom = 0, 1, 0, 1
		needs_crop = true
	else
		texture = [[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]]
		left, right, top, bottom = unpack(CLASS_ICON_TCOORDS[class])
		needs_crop = true
	end

	self:SetTexture(unit, texture, needs_crop, left, right, top, bottom)
end

function ClassIcon:CreateFrame(unit)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	-- create frame
	self.frame[unit] = CreateFrame("CheckButton", "GladiusEx" .. self:GetName() .. "Frame" .. unit, button, "ActionButtonTemplate")
	self.frame[unit]:EnableMouse(false)
	self.frame[unit].texture = _G[self.frame[unit]:GetName().."Icon"]
	self.frame[unit].normalTexture = _G[self.frame[unit]:GetName().."NormalTexture"]
	self.frame[unit].cooldown = _G[self.frame[unit]:GetName().."Cooldown"]
	self.frame[unit].cooldown:SetSwipeColor(0, 0, 0, 1)
	self.frame[unit].texture_border = self.frame[unit]:CreateTexture(nil, "BACKGROUND", nil, -1)
	self.frame[unit].texture_border:SetTexture([[Interface\AddOns\GladiusEx\media\icon_border]])
	self.frame[unit].texture_border:SetAllPoints()
end

function ClassIcon:Update(unit)
	-- create frame
	if not self.frame[unit] then
		self:CreateFrame(unit)
	end

	-- style action button
	self.frame[unit].normalTexture:SetHeight(self.frame[unit]:GetHeight() + self.frame[unit]:GetHeight() * 0.4)
	self.frame[unit].normalTexture:SetWidth(self.frame[unit]:GetWidth() + self.frame[unit]:GetWidth() * 0.4)

	self.frame[unit].normalTexture:ClearAllPoints()
	self.frame[unit].normalTexture:SetPoint("CENTER")
	self.frame[unit]:SetNormalTexture([[Interface\AddOns\GladiusEx\media\gloss]])

	self.frame[unit].texture:ClearAllPoints()
	self.frame[unit].texture:SetPoint("TOPLEFT", self.frame[unit], "TOPLEFT")
	self.frame[unit].texture:SetPoint("BOTTOMRIGHT", self.frame[unit], "BOTTOMRIGHT")

	self.frame[unit].normalTexture:SetVertexColor(self.db[unit].classIconGlossColor.r, self.db[unit].classIconGlossColor.g,
		self.db[unit].classIconGlossColor.b, self.db[unit].classIconGloss and self.db[unit].classIconGlossColor.a or 0)

	self.frame[unit].cooldown:SetReverse(self.db[unit].classIconCooldownReverse)

	-- hide
	self.frame[unit]:Hide()
end

function ClassIcon:Refresh(unit)
	self:SetClassIcon(unit)
	self:UpdateAura(unit)
end

function ClassIcon:Show(unit)
	-- show frame
	self.frame[unit]:Show()

	-- set class icon
	self:SetClassIcon(unit)
	self:UpdateAura(unit)
end

function ClassIcon:Reset(unit)
	if not self.frame[unit] then return end

	-- hide
	self.frame[unit]:Hide()
end

function ClassIcon:Test(unit)
end

function ClassIcon:GetImportantAura(unit, name)
	return self.db[unit].classIconAuras[name]
end

local function HasAuraEditBox()
	return not not LibStub("AceGUI-3.0").WidgetVersions["Aura_EditBox"]
end

function ClassIcon:GetOptions(unit)
	local options
	options = {
		general = {
			type = "group",
			name = L["General"],
			order = 1,
			args = {
				widget = {
					type = "group",
					name = L["Widget"],
					desc = L["Widget settings"],
					inline = true,
					order = 1,
					args = {
						classIconMode = {
							type = "select",
							name = L["Show"],
							values = {
								["CLASS"] = L["Class"],
								["SPEC"] = L["Spec"],
								["ROLE"] = L["Role"],
								["PORTRAIT2D"] = L["Portrait 2D"],
								["PORTRAIT3D"] = L["Portrait 3D"],
							},
							desc = L["When available, show specialization instead of class icons"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 3,
						},
						sep = {
							type = "description",
							name = "",
							width = "full",
							order = 4,
						},
						classIconImportantAuras = {
							type = "toggle",
							name = L["Important auras"],
							desc = L["Show important auras instead of the class icon"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 5,
						},
						classIconCrop = {
							type = "toggle",
							name = L["Crop borders"],
							desc = L["Toggle if the icon borders should be cropped or not"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 6,
						},
						sep2 = {
							type = "description",
							name = "",
							width = "full",
							order = 7,
						},
						classIconCooldown = {
							type = "toggle",
							name = L["Cooldown spiral"],
							desc = L["Display the cooldown spiral for the important auras"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 10,
						},
						classIconCooldownReverse = {
							type = "toggle",
							name = L["Cooldown reverse"],
							desc = L["Invert the dark/bright part of the cooldown spiral"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 15,
						},
						sep3 = {
							type = "description",
							name = "",
							width = "full",
							order = 17,
						},
						classIconGloss = {
							type = "toggle",
							name = L["Gloss"],
							desc = L["Toggle gloss on the icon"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 20,
						},
						classIconGlossColor = {
							type = "color",
							name = L["Gloss color"],
							desc = L["Color of the gloss"],
							get = function(info) return GladiusEx:GetColorOption(self.db[unit], info) end,
							set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db[unit], info, r, g, b, a) end,
							hasAlpha = true,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 25,
						},
					},
				},
				position = {
					type = "group",
					name = L["Position"],
					desc = L["Position settings"],
					inline = true,
					order = 3,
					args = {
						classIconPosition = {
							type = "select",
							name = L["Position"],
							desc = L["Position of the frame"],
							values = { ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"] },
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 1,
						},
					},
				},
			},
		},
		auraList = {
			type = "group",
			name = L["Important auras"],
			childGroups = "tree",
			order = 3,
			args = {
				newAura = {
					type = "group",
					name = L["New aura"],
					desc = L["New aura"],
					inline = true,
					order = 1,
					args = {
						name = {
							type = "input",
							dialogControl = HasAuraEditBox() and "Aura_EditBox" or nil,
							name = L["Name"],
							desc = L["Name of the aura"],
							get = function() return self.newAuraName and tostring(self.newAuraName) or "" end,
							set = function(info, value)
								if tonumber(value) and GetSpellInfo(value) then
									value = tonumber(value)
								end
								self.newAuraName = value
							end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 1,
						},
						priority = {
							type= "range",
							name = L["Priority"],
							desc = L["Select what priority the aura should have - higher equals more priority"],
							get = function() return self.newAuraPriority or "" end,
							set = function(info, value) self.newAuraPriority = value end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							min = 0,
							max = 10,
							step = 0.1,
							order = 2,
						},
						add = {
							type = "execute",
							name = L["Add new aura"],
							func = function(info)
								self.db[unit].classIconAuras[self.newAuraName] = self.newAuraPriority
								options.auraList.args[tostring(self.newAuraName)] = self:SetupAuraOptions(options, unit, self.newAuraName)
								self.newAuraName = nil
								GladiusEx:UpdateFrames()
							end,
							disabled = function() return not self:IsUnitEnabled(unit) or not (self.newAuraName and self.newAuraPriority) end,
							order = 3,
						},
					},
				},
			},
		},
	}

	-- set some initial value for the auras priority
	self.newAuraPriority = 5

	-- setup auras
	for aura, priority in pairs(self.db[unit].classIconAuras) do
		-- priority is false for deleted values
		if priority then
			options.auraList.args[tostring(aura)] = self:SetupAuraOptions(options, unit, aura)
		end
	end

	return options
end

function ClassIcon:SetupAuraOptions(options, unit, aura)
	local function setAura(info, value)
		if (info[#(info)] == "name") then
			local new_name = value
			if tonumber(new_name) and GetSpellInfo(new_name) then
				new_name = tonumber(new_name)
			end

			-- create new aura
			self.db[unit].classIconAuras[new_name] = self.db[unit].classIconAuras[aura]
			options.auraList.args[new_name] = self:SetupAuraOptions(options, unit, new_name)

			-- delete old aura
			self.db[unit].classIconAuras[aura] = false
			options.auraList.args[aura] = nil
		else
			self.db[unit].classIconAuras[info[#(info) - 1]] = value
		end

		GladiusEx:UpdateFrames()
	end

	local function getAura(info)
		if (info[#(info)] == "name") then
			return tostring(aura)
		else
			return self.db[unit].classIconAuras[aura]
		end
	end

	local name = aura
	if type(aura) == "number" then
		name = string.format("%s [%s]", GladiusEx:SafeGetSpellName(aura), aura)
	end

	return {
		type = "group",
		name = name,
		desc = name,
		get = getAura,
		set = setAura,
		disabled = function() return not self:IsUnitEnabled(unit) end,
		args = {
			name = {
				type = "input",
				dialogControl = HasAuraEditBox() and "Aura_EditBox" or nil,
				name = L["Name"],
				desc = L["Name of the aura"],
				disabled = function() return not self:IsUnitEnabled(unit) end,
				order = 1,
			},
			priority = {
				type= "range",
				name = L["Priority"],
				desc = L["Select what priority the aura should have - higher equals more priority"],
				min = 0, softMax = 10, step = 0.1,
				order = 2,
			},
			delete = {
				type = "execute",
				name = L["Delete"],
				func = function(info)
					local aura = info[#(info) - 1]
					-- very important: set to false so that they're not removed
					-- see https://github.com/slaren/GladiusEx/issues/10
					self.db[unit].classIconAuras[aura] = false
					options.auraList.args[aura] = nil
					GladiusEx:UpdateFrames()
				end,
				disabled = function() return not self:IsUnitEnabled(unit) end,
				order = 3,
			},
		},
	}
end
