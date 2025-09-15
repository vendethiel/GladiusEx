GladiusEx.Data = {}

function GladiusEx.Data.DefaultAlertSpells()
    return {}
end

function GladiusEx.Data.DefaultAuras()
    return {
        [GladiusEx:SafeGetSpellName(57940)] = true -- Essence of Wintergrasp
    }
end

function GladiusEx.Data.DefaultClassicon()
	return {
		-- Higher Number is More Priority
		-- Priority List by Bibimapi
		-- Immunes I and Stealth (10)

		[GladiusEx:SafeGetSpellName(33786)]		= 10,	-- Cyclone
		[GladiusEx:SafeGetSpellName(605)]	  	= 10,	-- Mind Control
		[GladiusEx:SafeGetSpellName(45438)]		= 10,	-- Ice Block 
		[GladiusEx:SafeGetSpellName(642)]	  	= 10,	-- Divine Shield
		[GladiusEx:SafeGetSpellName(27827)]		= 10,	-- Spirit of Redemption
		[GladiusEx:SafeGetSpellName(34692)] 	= 10, -- The Beast Within
		[GladiusEx:SafeGetSpellName(27827)]		= 10,	-- Spirit of Redemption
		[GladiusEx:SafeGetSpellName(5215)]		= 10,	-- Prowl
		[GladiusEx:SafeGetSpellName(32612)]		= 10,	-- Invisibility (main)
        [GladiusEx:SafeGetSpellName(110960)] 	= 10,	--  Greater Invisibility 
		[GladiusEx:SafeGetSpellName(1784)]		= 10,	-- Stealth 
		[GladiusEx:SafeGetSpellName(11327)]		= 10,	-- Vanish
		[GladiusEx:SafeGetSpellName(5384)]		= 10,	-- Feign Death
        [GladiusEx:SafeGetSpellName(58984)]		= 10,	-- Shadowmeld
        [GladiusEx:SafeGetSpellName(46924)]		= 10,	-- Bladestorm

		[GladiusEx:SafeGetSpellName(44166)]		= 10,	-- Refreshment
		[GladiusEx:SafeGetSpellName(27089)]		= 10,	-- Drink1
		[GladiusEx:SafeGetSpellName(46755)]		= 10,	-- Drink2
		[GladiusEx:SafeGetSpellName(23920)] 	= 10,	-- Spell Reflection
		[GladiusEx:SafeGetSpellName(31224)]		= 10,	-- Cloak of Shadows
		[GladiusEx:SafeGetSpellName(131523)] 	= 10, -- Zen Meditation
    	[GladiusEx:SafeGetSpellName(122465)] 	= 10, -- Dematerialize


		-- Breakable CC (9)

		[GladiusEx:SafeGetSpellName(2637)]  	= 9,	-- Hibernate 
		[GladiusEx:SafeGetSpellName(3355)]  	= 9,	-- Freezing Trap 
		[GladiusEx:SafeGetSpellName(37506)]  	= 9,	-- Scatter Shot
		[GladiusEx:SafeGetSpellName(118)]  	 	= 9.1,	-- Polymorph
        [GladiusEx:SafeGetSpellName(51514)]     = 9,    -- Hex
		[GladiusEx:SafeGetSpellName(28272)]  	= 9.1,	-- Polymorph (pig)
		[GladiusEx:SafeGetSpellName(28271)]  	= 9.1,	-- Polymorph (turtle
		[GladiusEx:SafeGetSpellName(20066)]  	= 9,	-- Repentance
		[GladiusEx:SafeGetSpellName(1776)]  	= 9,	-- Gouge
		[GladiusEx:SafeGetSpellName(6770)]  	= 9.1,	-- Sap
		[GladiusEx:SafeGetSpellName(1513)]  	= 9,	-- Scare Beast
		[GladiusEx:SafeGetSpellName(31661)]  	= 9,	-- Dragon's Breath 
		[GladiusEx:SafeGetSpellName(8122)]  	= 9,	-- Psychic Scream 
        [GladiusEx:SafeGetSpellName(113792)]  	= 9,    -- Psychic Terror (Psyfiend)
        [GladiusEx:SafeGetSpellName(88625)]     = 9,    -- Holy Word: Chastise
		[GladiusEx:SafeGetSpellName(2094)]  	= 9,	-- Blind 
		[GladiusEx:SafeGetSpellName(5782)]  	= 9,	-- Fear
        [GladiusEx:SafeGetSpellName(130616)]  	= 9,	-- Fear (Horrify)
		[GladiusEx:SafeGetSpellName(5484)]  	= 9,	-- Howl of Terror
		[GladiusEx:SafeGetSpellName(6358)]  	= 9,	-- Seduction
		[GladiusEx:SafeGetSpellName(5246)]  	= 9,	-- Intimidating Shout 
		[GladiusEx:SafeGetSpellName(22570)]  	= 9,	-- Maim
		[GladiusEx:SafeGetSpellName(19386)]   	= 9,  -- Wyvern Sting
		[GladiusEx:SafeGetSpellName(90337)]   	= 9,  -- Bad Manner
        [GladiusEx:SafeGetSpellName(99)]  		= 9,	-- Disorienting Roar
		[GladiusEx:SafeGetSpellName(126246)] 	= 9, -- Lullaby (Crane)
    	[GladiusEx:SafeGetSpellName(126355)] 	= 9, -- Paralyzing Quill (Porcupine)
    	[GladiusEx:SafeGetSpellName(126423)]	= 9, -- Petrifying Gaze (Basilisk)
		[GladiusEx:SafeGetSpellName(102051)] 	= 9,
		[GladiusEx:SafeGetSpellName(118895)] 	= 9, -- Dragon Roar
		[GladiusEx:SafeGetSpellName(115078)] 	= 9, -- Paralysis

		-- Stuns (8)
        [GladiusEx:SafeGetSpellName(108194)]  	= 8,	-- Asphyxiate (U/F)
		[GladiusEx:SafeGetSpellName(5211)] 	 	= 8,	-- Bash 
		[GladiusEx:SafeGetSpellName(24394)]		= 8,	-- Intimidation 
		[GladiusEx:SafeGetSpellName(853)]  		= 8,	-- Hammer of Justice
		[GladiusEx:SafeGetSpellName(1833)] 		= 8,	-- Cheap Shot 
		[GladiusEx:SafeGetSpellName(408)]  		= 8,	-- Kidney Shot 
		[GladiusEx:SafeGetSpellName(30283)] 	= 8,	-- Shadowfury 
		[GladiusEx:SafeGetSpellName(20549)] 	= 8,	-- War Stomp
		[GladiusEx:SafeGetSpellName(835)]   	= 8,     -- Tidal Charm
		[GladiusEx:SafeGetSpellName(100)]   	= 8,   -- Charge
        [GladiusEx:SafeGetSpellName(119381)]	= 8,	-- Leg Sweep
		[GladiusEx:SafeGetSpellName(120086)] 	= 8, -- Fists of Fury
        [GladiusEx:SafeGetSpellName(91800)]  	= 8,	-- Gnaw
        [GladiusEx:SafeGetSpellName(5211)]  	= 8,	-- Mighty Bash 
        [GladiusEx:SafeGetSpellName(64044)]  	= 8,	-- Psychic Horror
        [GladiusEx:SafeGetSpellName(118345)]  	= 8,	-- Pulverize (Primal Elementalist) 
		[GladiusEx:SafeGetSpellName(118905)]  	= 8,	-- Capacitor Totem
        [GladiusEx:SafeGetSpellName(132168)]  	= 8,	-- Shockwave 
		[GladiusEx:SafeGetSpellName(132169)]  	= 8,	-- Storm Bolt
        [GladiusEx:SafeGetSpellName(20549)]  	= 8,	-- War Stomp
        [GladiusEx:SafeGetSpellName(115001)] 	= 8,      -- Remorseless Winter
		[GladiusEx:SafeGetSpellName(105593)] 	= 8, -- Fist of Justice
		[GladiusEx:SafeGetSpellName(50519)] 	= 8, -- Sonic Blast (bat pet stun)
		[GladiusEx:SafeGetSpellName(117526)]	= 8, -- Binding Shot
		[GladiusEx:SafeGetSpellName(113801)] 	= 8, -- Bash (Force of Nature - Feral Treants)
    	[GladiusEx:SafeGetSpellName(102795)] 	= 8, -- Bear Hug
		[GladiusEx:SafeGetSpellName(113953)] 	= 8,  -- Paralysis (Paralytic Poison)
		[GladiusEx:SafeGetSpellName(115078)] 	= 8, -- Paralysis

		-- Immunes II (7)

		[GladiusEx:SafeGetSpellName(1022)]  	= 7,	-- Blessing of Protection
		[GladiusEx:SafeGetSpellName(33206)]   	= 7, -- Pain Suppression
		[GladiusEx:SafeGetSpellName(5277)]  	= 7,	-- Evasion
		[GladiusEx:SafeGetSpellName(48792)]  	= 7.1,	-- Icebound Fortitude
		[GladiusEx:SafeGetSpellName(48707)]  	= 7,	-- Anti-Magic Shell
		[GladiusEx:SafeGetSpellName(118038)]  	= 7,	-- Die by the Sword


		-- Defensives I (6.5)
		[GladiusEx:SafeGetSpellName(3411)]    	= 6.5,   -- Intervene
		[GladiusEx:SafeGetSpellName(45182)]	 	= 6.5,	 -- Cheat Death
		[GladiusEx:SafeGetSpellName(19263)]   	= 6.5,   -- Deterrence
		[GladiusEx:SafeGetSpellName(47788)]  	= 6.5,	-- Guardian Spirit
		[GladiusEx:SafeGetSpellName(47585)]  	= 6.5,	-- Dispersion
		[GladiusEx:SafeGetSpellName(45182)]		= 6.5,	-- Cheat Death
		[GladiusEx:SafeGetSpellName(116888)]	= 6.5,	-- Purgatory
		[GladiusEx:SafeGetSpellName(116849)]  	= 6.5,	-- Life Cocoon 
		[GladiusEx:SafeGetSpellName(125174)]	= 6.5,	-- Touch of Karma (buff)

		-- Immunes III (6)
		[GladiusEx:SafeGetSpellName(8178)]  	= 6.4,	-- Grounding Totem Effect
		[GladiusEx:SafeGetSpellName(18499)]  	= 6,	-- Berserker Rage
		[GladiusEx:SafeGetSpellName(23920)]  	= 6,	-- Spell Reflection
		[GladiusEx:SafeGetSpellName(49039)]  	= 6,	-- Lichborne
		[GladiusEx:SafeGetSpellName(31224)]  	= 6,	-- Cloak of Shadows
        
		-- Unbreakable CC and Roots (5)

		[GladiusEx:SafeGetSpellName(6789)]  	= 5,	-- Death Coil 
		[GladiusEx:SafeGetSpellName(15487)]  	= 5,	-- Silence
		[GladiusEx:SafeGetSpellName(27559)]  	= 3,	-- Silencing shot (3 second silence)
		[GladiusEx:SafeGetSpellName(1330)]  	= 5,	-- Garrote
		[GladiusEx:SafeGetSpellName(339)]		= 5,	-- Entangling Roots
		[GladiusEx:SafeGetSpellName(122)]   	= 5,	-- Frost Nova
		[GladiusEx:SafeGetSpellName(33395)]  	= 5,	-- Freeze (Water Elemental)
		[GladiusEx:SafeGetSpellName(676)]   	= 5,	-- Disarm 
		[GladiusEx:SafeGetSpellName(16979)]  	= 5,	-- Feral Charge
		[GladiusEx:SafeGetSpellName(90327)]		= 5,	-- Lock Jaw
        [GladiusEx:SafeGetSpellName(107079)]	= 5,	-- Quaking Palm (Pandarian)
        [GladiusEx:SafeGetSpellName(96294)]		= 5,	-- Chains of Ice (Chilblains)
        [GladiusEx:SafeGetSpellName(50435)]		= 5,	-- Chains of Ice (Chilblains)
		[GladiusEx:SafeGetSpellName(710)] 		= 5,    -- Banish
		[GladiusEx:SafeGetSpellName(63685)]  	= 5, 	-- Freeze (Enhancement)
    	[GladiusEx:SafeGetSpellName(64695)]  	= 5, 	-- Earthgrab (Elemental)
		[GladiusEx:SafeGetSpellName(116947)] 	= 5,    -- Earthbind (Earthgrab Totem)
		[GladiusEx:SafeGetSpellName(105421)] 	= 5, 	-- Blinding Light
		[GladiusEx:SafeGetSpellName(110300)] 	= 5,	-- Burden of Guilt
		[GladiusEx:SafeGetSpellName(50541)] 	= 5, -- Clench (scorpid pet disarm)
    	[GladiusEx:SafeGetSpellName(91644)] 	= 5, -- Snatch (bird of prey pet disarm)
		[GladiusEx:SafeGetSpellName(128405)] 	= 5, -- Narrow Escape
		[GladiusEx:SafeGetSpellName(115197)] 	= 5,  -- Partial Paralysis
		[GladiusEx:SafeGetSpellName(107566)] 	= 5, -- Staggering Shout
		[GladiusEx:SafeGetSpellName(140023)]	= 5, -- Ring of Peace
    	[GladiusEx:SafeGetSpellName(137461)] 	= 5, -- Disarmed (Ring of Peace)
    	[GladiusEx:SafeGetSpellName(137460)] 	= 5, -- Silenced (Ring of Peace)

		-- Defensives II (4.5)

		[GladiusEx:SafeGetSpellName(6940)] 		= 4.5,	-- Blessing of Sacrifice
		[GladiusEx:SafeGetSpellName(871)]  		= 4.5,	-- Shield Wall
		[GladiusEx:SafeGetSpellName(145629)]  	= 4.5,	-- Anti-Magic Zone
		[GladiusEx:SafeGetSpellName(102342)]  	= 4.5,	-- Ironbark
		[GladiusEx:SafeGetSpellName(61336)]  	= 4.5,	-- Survival Instincts
        [GladiusEx:SafeGetSpellName(118337)]  	= 4.5,	-- Harden Skin (Earth Elementalist)
		[GladiusEx:SafeGetSpellName(81782)]  	= 4.5,	-- Power Word: Barrier
		[GladiusEx:SafeGetSpellName(108271)]  	= 4.5,	-- Astral Shift
        [GladiusEx:SafeGetSpellName(122783)]  	= 4.5,	-- Diffuse Magic
		[GladiusEx:SafeGetSpellName(122278)]  	= 4.5,	-- Dampen Harm
		[GladiusEx:SafeGetSpellName(6940)]				  	= 4.5,	-- Blessing of Sacrifice
		[GladiusEx:SafeGetSpellName(31850)]  	= 4.5,	-- Ardent Defender
		[GladiusEx:SafeGetSpellName(86659)]  	= 4.5,	-- Guardian of Ancient Kings (P wall)
		[GladiusEx:SafeGetSpellName(33206)]  	= 4.5,	-- Pain Suppression
		[GladiusEx:SafeGetSpellName(114203)] 	= 4.5,


		-- Important II (4)

		[GladiusEx:SafeGetSpellName(29166)]  	= 4,	-- Innervate
		[GladiusEx:SafeGetSpellName(31842)]  	= 4,	-- Divine Illumination
		[GladiusEx:SafeGetSpellName(16188)]  	= 4,	-- Nature's Swiftness (Shaman)
		[GladiusEx:SafeGetSpellName(16166)]  	= 4,	-- Elemental Mastery
		[GladiusEx:SafeGetSpellName(1044)]		= 4,	-- Blessing of Freedom
		[GladiusEx:SafeGetSpellName(34709)]  	= 4,	-- Shadow Sight (eye in arena)
        [GladiusEx:SafeGetSpellName(48265)]  	= 4,	-- Death's Advance
        [GladiusEx:SafeGetSpellName(132158)]  	= 4,	-- Nature's Swiftness
		[GladiusEx:SafeGetSpellName(54216)]  	= 4,	-- Master's Call
		[GladiusEx:SafeGetSpellName(108839)]  	= 4,	-- Ice Floes
        [GladiusEx:SafeGetSpellName(73325)]  	= 4,	-- Leap of Faith
        [GladiusEx:SafeGetSpellName(122470)]  	= 4,	-- Touch of Karma (debuff)
		[GladiusEx:SafeGetSpellName(80240)]  	= 4,	-- Havoc
		[GladiusEx:SafeGetSpellName(34709)]  	= 4,	-- Shadow Sight (eye in arena)
		[GladiusEx:SafeGetSpellName(43523)] 	= 4, -- Unstable Affliction
		[GladiusEx:SafeGetSpellName(110909)] 	= 4, -- Alter Time

		-- Offensives I (3)

		[GladiusEx:SafeGetSpellName(19574)]  	= 3,	-- Bestial Wrath
		[GladiusEx:SafeGetSpellName(12042)]  	= 3,	-- Arcane Power
		[GladiusEx:SafeGetSpellName(12472)]  	= 3,	-- Icy Veins 
		[GladiusEx:SafeGetSpellName(29977)]  	= 3,	-- Combustion
		[GladiusEx:SafeGetSpellName(31884)]  	= 3,	-- Avenging Wrath
		[GladiusEx:SafeGetSpellName(13750)]  	= 3,	-- Adrenaline Rush 
		[GladiusEx:SafeGetSpellName(32182)]  	= 3,	-- Heroism  
		[GladiusEx:SafeGetSpellName(2825)]  	= 3,	-- Bloodlust
		[GladiusEx:SafeGetSpellName(13877)]  	= 3,	-- Blade Flurry 
		[GladiusEx:SafeGetSpellName(1719)]  	= 3,	-- Recklessness
		[GladiusEx:SafeGetSpellName(12292)]  	= 3,	-- Death Wish
		[GladiusEx:SafeGetSpellName(3045)]  	= 3,	-- Rapid Fire
        [GladiusEx:SafeGetSpellName(51271)]  	= 3,	-- Pillar of Frost
		[GladiusEx:SafeGetSpellName(102560)]  	= 3,	-- Incarnation: Chosen of Elune
		[GladiusEx:SafeGetSpellName(102543)]  	= 3,	-- Incarnation: King of the Jungle
		[GladiusEx:SafeGetSpellName(102558)]  	= 3,	-- Incarnation: Guardian of Ursoc
		[GladiusEx:SafeGetSpellName(106951)]  	= 3,	-- Berserk (feral)
		[GladiusEx:SafeGetSpellName(50334)]  	= 3,	-- Berserk (guardian)
		[GladiusEx:SafeGetSpellName(108292)]  	= 3,	-- Heart of the Wild (feral affinity)
		[GladiusEx:SafeGetSpellName(108291)]  	= 3,	-- Heart of the Wild (balance affinity)
        [GladiusEx:SafeGetSpellName(137639)]  	= 3,	-- SEF
        [GladiusEx:SafeGetSpellName(51690)]  	= 3,	-- Killing Spree
        [GladiusEx:SafeGetSpellName(114050)]  	= 3,	-- Ascendance ele
		[GladiusEx:SafeGetSpellName(114051)]  	= 3,	-- Ascendance enha
		[GladiusEx:SafeGetSpellName(114052)]  	= 3,	-- Ascendance rest
		[GladiusEx:SafeGetSpellName(113858)]  	= 3,	-- Dark Soul: Instability
		[GladiusEx:SafeGetSpellName(113860)]  	= 3,	-- Dark Soul: Misery
        [GladiusEx:SafeGetSpellName(79140)]  	= 3,	-- Vendetta

		-- Defensives III (2.5)

		[GladiusEx:SafeGetSpellName(81256)]  	= 2.5,	-- Dancing Rune Weapon (40% parry)
		[GladiusEx:SafeGetSpellName(55233)]  	= 2.5,	-- Vampiric Blood
		[GladiusEx:SafeGetSpellName(22812)]  	= 2.5,	-- Barkskin
        [GladiusEx:SafeGetSpellName(117679)]  	= 2.5,	-- Incarnation: Tree of Life
		[GladiusEx:SafeGetSpellName(16689)]   	= 2.5,   -- Nature's Grasp
		[GladiusEx:SafeGetSpellName(22842)]  	= 2.5,	-- Frenzied Regen
		[GladiusEx:SafeGetSpellName(53480)]  	= 2.5,	-- Roar of Sacrifice
		[GladiusEx:SafeGetSpellName(120954)]  	= 2.5,	-- Fortifying Brew (B)
		[GladiusEx:SafeGetSpellName(498)]  	  	= 2.5,	-- Divine Protection
        [GladiusEx:SafeGetSpellName(47536)]  	= 2.5,	-- Rapture
        [GladiusEx:SafeGetSpellName(97463)]  	= 2.5,	-- Rallying Cry
		[GladiusEx:SafeGetSpellName(12975)]  	= 2.5,	-- Last Stand
		[GladiusEx:SafeGetSpellName(38031)]  	= 2.5,	-- Shield Block
		[GladiusEx:SafeGetSpellName(66)]	   	= 2.5,	-- Invisibility (initial)
		[GladiusEx:SafeGetSpellName(20578)]  	= 2.5,	-- Cannibalize
		[GladiusEx:SafeGetSpellName(8178)]  	= 2.5,	-- Grounding Totem Effect
		[GladiusEx:SafeGetSpellName(8145)]    	= 2.5,   -- Tremor Totem Passive
		[GladiusEx:SafeGetSpellName(6346)]    	= 2.5,   -- Fear Ward
		[GladiusEx:SafeGetSpellName(30823)]   	= 2.5,   -- Shamanistic Rage
		[GladiusEx:SafeGetSpellName(7812)]   	= 2.5,     -- Sacrifice
        [GladiusEx:SafeGetSpellName(48743)]  	= 2.5,	-- Death Pact (big absorb+healing reduced)
		[GladiusEx:SafeGetSpellName(115610)] 	= 2.5, -- Temporal Shield

		-- Offensives II (2)

		[GladiusEx:SafeGetSpellName(47568)]  	= 2,	-- Empower Rune Weapon
        [GladiusEx:SafeGetSpellName(116014)]  	= 2,	-- Rune of Power
        [GladiusEx:SafeGetSpellName(105809)]  	= 2,	-- Holy Avenger
		[GladiusEx:SafeGetSpellName(5217)]  	= 2,	-- Tiger's Fury
		[GladiusEx:SafeGetSpellName(12043)]  	= 2,	-- Presence of Mind
		[GladiusEx:SafeGetSpellName(10060)]  	= 2,	-- Power Infusion
		[GladiusEx:SafeGetSpellName(12328)]  	= 2,	-- Sweeping Strikes
        [GladiusEx:SafeGetSpellName(51533)]  	= 2,	-- Feral Spirit

		-- Misc (1)

		[GladiusEx:SafeGetSpellName(2645)]		= 1,	-- Ghost Wolf
		[GladiusEx:SafeGetSpellName(12051)]   	= 1,  -- Evocation
		[GladiusEx:SafeGetSpellName(16190)]  	= 1,	-- Mana Tide Totem
		[GladiusEx:SafeGetSpellName(1850)]  	= 1,	-- Dash
		[GladiusEx:SafeGetSpellName(5118)]  	= 1,	-- Aspect of the Cheetah
		[GladiusEx:SafeGetSpellName(2983)]  	= 1,	-- Sprint
		[GladiusEx:SafeGetSpellName(36554)]  	= 1,	-- Shadowstep
		[GladiusEx:SafeGetSpellName(41425)]  	= 1,	-- Hypothermia
		[GladiusEx:SafeGetSpellName(25771)]  	= 1,	-- Forbearance
		[GladiusEx:SafeGetSpellName(11426)]  	= 1,  -- Ice Barrier
		[GladiusEx:SafeGetSpellName(1543)]    	= 1,  -- Flare
        [GladiusEx:SafeGetSpellName(19236)]  	= 1,	-- Desperate Prayer
        [GladiusEx:SafeGetSpellName(116841)]  	= 1,	-- Tiger's Lust
  }
end

function GladiusEx.Data.DefaultCooldowns()
    return {
        {
            -- group 1
            [22812] = true, -- Druid/Barkskin
            [33786] = true, -- Druid/Cyclone (feral)
            [99] = true, -- Druid/Disorienting Roar
            [16689] = true, -- Druid/Nature's Grasp
            [5211] = true, -- Druid/Bash
            [16979] = true, -- Druid/Feral Charge
            [17116] = true, -- Druid/Nature's Swiftness
            [29166] = true, -- Druid/Nature's Swiftness
            [19574] = true, -- Hunter/Bestial Wrath
            [19263] = true, -- Hunter/Deterrence
            [781] = true, -- Hunter/Disengage
            [1499] = true, -- Hunter/Freezing Trap
            [19577] = true, -- Hunter/Intimidation
            [23989] = true, -- Hunter/Readiness
            [19386] = true, -- Hunter/Wyvern Sting
            [19503] = true, -- Hunter/Scatter Shot
            [34490] = true, -- Hunter/Silencing Shot
            [26064] = true, -- Hunter/Shell Shield
            [3045] = true, -- Hunter/Rapid Fire
            [1953] = true, -- Mage/Blink
            [11958] = true, -- Mage/Cold Snap. V: changed ID in legion
            [2139] = true, -- Mage/Counterspell
            [122] = true, -- Mage/Frost Nova
            [45438] = true, -- Mage/Ice Block
            [12043] = true, -- Mage/Presence of Mind
            [12051] = true, -- Mage/Evocation
            [31661] = true, -- Mage/Dragon's Breath
            [11129] = true, -- Mage/Combustion
            [12472] = true, -- Mage/Icy Veins
            [4987] = true, -- Paladin/Cleanse
            [31821] = true, -- Paladin/Devotion Aura
            [642] = true, -- Paladin/Divine Shield
            [853] = true, -- Paladin/Hammer of Justice
            [20066] = true, -- Paladin/Repentance
            [1044] = true, -- Paladin/Blessing of Freedom
            [6940] = true, -- Paladin/Blessing of Sacrifice
            [31884] = true, -- Paladin/Avenging Wrath
            [31842] = true, -- Paladin/Divine Illumination
            [20925] = true, -- Paladin/Holy Shield
            [20216] = true, -- Paladin/Divine Favor
            [498] = true, -- Paladin/Divine Protection
            [1022] = true, -- Paladin/Blessing of Protection
            [48173] = true, -- Priest/Desperate Prayer
            [33206] = true, -- Priest/Pain Suppression
            [8122] = true, -- Priest/Psychic Scream
            [527] = true, -- Priest/Purify
            [15487] = true, -- Priest/Silence
            [10060] = true, -- Priest/Power Infusion
            [34433] = true, -- Priest/Shadowfiend
            [14751] = true, -- Priest/Inner Focus
            [6346] = true, -- Priest/Fear Ward
            [47585] = true, -- Priest/Dispersion
            [13750] = true, -- Rogue/Adrenaline Rush
            [13877] = true, -- Rogue/Blade Furry
            [2094] = true, -- Rogue/Blind
            [31224] = true, -- Rogue/Cloak of Shadows
            [1766] = true, -- Rogue/Kick
            [1856] = true, -- Rogue/Vanish
            [14177] = true, -- Rogue/Cold Blood
            [36554] = true, -- Rogue/Shadowstep
            [5277] = true, -- Rogue/Evasion
            [2983] = true, -- Rogue/Sprint
            [14185] = true, -- Rogue/Preparation
            [5484] = true, -- Warlock/Howl of Terror
            [6789] = true, -- Warlock/Death Coil
            [30283] = true, -- Warlock/Shadowfury
            [19647] = true, -- Warlock/Spell Lock
            [19505] = true, -- Warlock/Devour Magic
            [5246] = true, -- Warrior/Intimidating Shout
            [6552] = true, -- Warrior/Pummel
            [1719] = true, -- Warrior/Recklessness
            [871] = true, -- Warrior/Shield Wall
            [23920] = true, -- Warrior/Spell Reflection
            [12292] = true, -- Warrior/Death Wish
            [3411] = true, -- Warrior/Intervene
            [100] = true, -- Warrior/Charge
            [20252] = true, -- Warrior/Intercept
            [12809] = true, -- Warrior/Concussion Blow
            [18499] = true, -- Warrior/Berserker Rage
            [676] = true, -- Warrior/Disarm
            [12975] = true, -- Warrior/Last Stand
            [57994] = true, -- Shaman/Wind Shear
            [16188] = true, -- Shaman/Nature's Swiftness
            [8177] = true, -- Shaman/Grounding Totem
            [30823] = true, -- Shaman/Shamanistic Rage
            [49039] = true, -- Death Knight/Lichborne
            [47476] = true, -- Death Knight/Strangulate
            [48792] = true, -- Death Knight/Icebound Fortitude
            [47528] = true, -- Death Knight/Mind Freeze
            [51052] = true, -- Death Knight/Anti-Magic Zone
            [48707] = true -- Death Knight/Anti-Magic Shell
        },
        {
            -- group 2
            [42292] = true, -- PvP Trinket
            [59752] = true -- Will to Survive (Human EMFH) K: This is not needed since EMFH shares CD with PvP Trinket
        }
    }
end

function GladiusEx.Data.InterruptModifiers()
    return {}
end

function GladiusEx.Data.Interrupts()
    return {
        [19675] = { duration = 4 }, -- Feral Charge Effect (Druid)
        [2139]  = { duration = 7 }, -- Counterspell (Mage)
        [1766]  = { duration = 5 }, -- Kick (Rogue)
        [6552]  = { duration = 4 }, -- Pummel (Warrior)
        [72]    = { duration = 6 }, -- Shield Bash (Warrior)
        [57994] = { duration = 2 }, -- Wind Shear (Shaman)
        [19647] = { duration = 5 }, -- Spell Lock (Warlock)
        [47528] = { duration = 5 }, -- Mind Freeze (Death Knight)
        [93985] = { duration = 4 }, -- Skull Bash (Druid)
        [96231] = { duration = 4 }, -- Rebuke (Paladin)
        [50318] = { duration = 4 }, -- Serenity Dust (Moth - Hunter Pet)
        [50479] = { duration = 2 }, -- Nether Shock (Nether Ray - Hunter Pet)
    }
end

-- K: This is used to assess whether a DR has (dynamically) reset early
GladiusEx.Data.AuraDurations = {
    [64058] = 10,  -- Psychic Horror Disarm Effect
    [51722] = 10,  -- Dismantle
    [676]   = 10,  -- Disarm
    [1513]  = 8,   -- Scare Beast
    [10326] = 8,   -- Turn Evil
    [8122]  = 8,   -- Psychic Scream
    [2094]  = 8,   -- Blind
    [5782]  = 8,   -- Fear
    [6358]  = 8,   -- Seduction (Succubus)
    [5484]  = 8,   -- Howl of Terror
    [5246]  = 8,   -- Intimidating Shout
    [20511] = 8,   -- Intimidating Shout (secondary targets)
    [339]   = 8,   -- Entangling Roots
    [19975] = 8,   -- Nature's Grasp
    [33395] = 8,   -- Freeze (Water Elemental)
    [122]   = 8,   -- Frost Nova
    [605]   = 8,   -- Mind Control
    [49203] = 8,   -- Hungering Cold
    [2637]  = 8,   -- Hibernate
    [3355]  = 8,   -- Freezing Trap Effect
    [9484]  = 8,   -- Shackle Undead
    [118]   = 8,   -- Polymorph
    [28271] = 8,   -- Polymorph: Turtle
    [28272] = 8,   -- Polymorph: Pig
    [61721] = 8,   -- Polymorph: Rabbit
    [61305] = 8,   -- Polymorph: Black Cat
    [51514] = 8,   -- Hex
    [6770]  = 8,   -- Sap
    [19386] = 6,   -- Wyvern Sting
    [33786] = 6,   -- Cyclone
    [20066] = 6,   -- Repentance
    [710]   = 6,   -- Banish
    [853]   = 6,   -- Hammer of Justice
    [64695] = 5,   -- Earthgrab
    [63685] = 5,   -- Freeze (Frost Shock)
    [54706] = 5,   -- Venom Web Spray (Silithid)
    [4167]  = 5,   -- Web (Spider)
    [19306] = 5,   -- Counterattack
    [31661] = 5,   -- Dragon's Breath
    [31117] = 5,   -- Silenced - Unstable Affliction (Rank 1)
    [47476] = 5,   -- Strangulate
    [23694] = 5,   -- Improved Hamstring
    [15487] = 5,   -- Silence
    [44572] = 5,   -- Deep Freeze
    [12809] = 5,   -- Concussion Blow
    [20170] = 5,   -- Seal of Justice Stun
    [1776]  = 4,   -- Gouge
    [5211]  = 4,   -- Bash
    [46968] = 4,   -- Shockwave
    [1833]  = 4,   -- Cheap Shot
    [83073] = 4,   -- Shattered Barrier (4 seconds)
    [55021] = 4,   -- Silenced - Improved Counterspell (Rank 2)
    [89766] = 4,   -- Axe Toss (Felguard)
    [19503] = 4,   -- Scatter Shot
    [67890] = 3,   -- Cobalt Frag Bomb (Item, Frag Belt)
    [24394] = 3,   -- Intimidation
    [2812]  = 3,   -- Holy Wrath
    [30283] = 3,   -- Shadowfury
    [20253] = 3,   -- Intercept Stun
    [9005]  = 3,   -- Pounce
    [19577] = 3,   -- Intimidation
    [39796] = 3,   -- Stoneclaw Stun
    [34490] = 3,   -- Silencing Shot
    [1330]  = 3,   -- Garrote - Silence
    [86759] = 3,   -- Silenced - Improved Kick (Rank 2)
    [24259] = 3,   -- Spell Lock
    [18498] = 3,   -- Silenced - Gag Order (Shield Slam)
    [74347] = 3,   -- Silenced - Gag Order (Heroic Throw)
    [31935] = 3,   -- Avenger's Shield
    [64044] = 3,   -- Psychic Horror
    [6789]  = 3,   -- Death Coil
    [50613] = 2,   -- Arcane Torrent (Racial, Runic Power)
    [18469] = 2,   -- Silenced - Improved Counterspell (Rank 1)
    [55080] = 2,   -- Shattered Barrier (2 seconds)
    [12355] = 2,   -- Impact
    [20549] = 2,   -- War Stomp (Racial)
    [47481] = 2,   -- Gnaw (Ghoul Pet)
    [50519] = 2,   -- Sonic Blast
    [12421] = 2,   -- Mithril Frag Bomb (Item)
    [28730] = 2,   -- Arcane Torrent (Racial, Mana)
    [25046] = 2,   -- Arcane Torrent (Racial, Energy)
    [58861] = 2,   -- Bash (Spirit Wolves)
    [18425] = 1.5, -- Silenced - Improved Kick
    [7922]  = 1.5, -- Charge Stun
    --[81261] = 0, -- Solar Beam (static, unusable)
    [408]   = 6, -- Kidney Shot (varies)
    [22570] = 5, -- Maim (varies)
}

function GladiusEx.Data.GetSpecializationInfoByID(id)
    return GetSpecializationInfoByID(id)
end

function GladiusEx.Data.GetNumSpecializationsForClassID(classID)
    return C_SpecializationInfo.GetNumSpecializationsForClassID(classID)
end

function GladiusEx.Data.GetSpecializationInfoForClassID(classID, specIndex)
    return GetSpecializationInfoForClassID(classID, specIndex)
end

function GladiusEx.Data.GetArenaOpponentSpec(id)
    return GetArenaOpponentSpec(id)
end

function GladiusEx.Data.CountArenaOpponents()
    return GetNumArenaOpponentSpecs()
end

function GladiusEx.Data.GetNumArenaOpponentSpecs()
    return GetNumArenaOpponentSpecs()
end
