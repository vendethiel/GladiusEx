GladiusEx.Data = {}

function GladiusEx.Data.DefaultAlertSpells()
  return {}
end

function GladiusEx.Data.DefaultAuras()
	return {}
end

function GladiusEx.Data.DefaultClassicon()
	return {
		-- Higher Number is More Priority
		-- Priority List by Bibimapi
-- Immunes I and Stealth (10)

		[GladiusEx:SafeGetSpellName(33786)]	= 10,	-- Cyclone
		[GladiusEx:SafeGetSpellName(605)]	= 10,	-- Mind Control
		[GladiusEx:SafeGetSpellName(45438)]	= 10,	-- Ice Block 
		[GladiusEx:SafeGetSpellName(642)]	= 10,	-- Divine Shield
		[27827]					= 10,	-- Spirit of Redemption

		[GladiusEx:SafeGetSpellName(5215)]	= 10,	-- Prowl
		[32612]					= 10,	-- Invisibility (main)
		[GladiusEx:SafeGetSpellName(1784)]	= 10,	-- Stealth 
		[GladiusEx:SafeGetSpellName(11327)]	= 10,	-- Vanish
		[GladiusEx:SafeGetSpellName(5384)]	= 10,	-- Feign Death



  -- Breakable CC (9)

  [GladiusEx:SafeGetSpellName(99)]  	= 9,	-- Incapacitating Roar
  [GladiusEx:SafeGetSpellName(2637)]  	= 9,	-- Hibernate 
  [GladiusEx:SafeGetSpellName(3355)]  	= 9,	-- Freezing Trap 
  [GladiusEx:SafeGetSpellName(118)]  	= 9.1,	-- Polymorph
  [GladiusEx:SafeGetSpellName(28272)]  	= 9.1,	-- Polymorph (pig)
  [GladiusEx:SafeGetSpellName(28271)]  	= 9.1,	-- Polymorph (turtle)
  [GladiusEx:SafeGetSpellName(20066)]  	= 9,	-- Repentance
  [GladiusEx:SafeGetSpellName(1776)]  	= 9,	-- Gouge
  [GladiusEx:SafeGetSpellName(6770)]  	= 9.1,	-- Sap
		[GladiusEx:SafeGetSpellName(1513)]  	= 9,	-- Scare Beast
		[GladiusEx:SafeGetSpellName(31661)]  	= 9,	-- Dragon's Breath 
		[GladiusEx:SafeGetSpellName(8122)]  	= 9,	-- Psychic Scream 
		[GladiusEx:SafeGetSpellName(2094)]  	= 9,	-- Blind 
		[GladiusEx:SafeGetSpellName(5484)]  	= 9,	-- Howl of Terror
		[GladiusEx:SafeGetSpellName(6358)]  	= 9,	-- Seduction
		[GladiusEx:SafeGetSpellName(5246)]  	= 9,	-- Intimidating Shout 
		[GladiusEx:SafeGetSpellName(10326)]  	= 9,	-- Turn Evil (undead dk)
		[GladiusEx:SafeGetSpellName(9484)]  	= 9,	-- Shackle Undead (undead dk)


		-- Stuns (8)

		[GladiusEx:SafeGetSpellName(5211)]  	= 8,	-- Mighty Bash 
		[GladiusEx:SafeGetSpellName(12809)]  	= 8,	-- Concussion Blow 
		[GladiusEx:SafeGetSpellName(24394)]  	= 8,	-- Intimidation 
		[GladiusEx:SafeGetSpellName(853)]  	= 8,	-- Hammer of Justice
		[GladiusEx:SafeGetSpellName(1833)]  	= 8,	-- Cheap Shot 
		[GladiusEx:SafeGetSpellName(408)]  	= 8,	-- Kidney Shot 
		[GladiusEx:SafeGetSpellName(30283)]  	= 8,	-- Shadowfury 
		[GladiusEx:SafeGetSpellName(20549)]  	= 8,	-- War Stomp


		-- Immunes II (7)

		[GladiusEx:SafeGetSpellName(1022)]  	= 7,	-- Blessing of Protection
		[5277]				  	= 7,	-- Evasion


		-- Defensives I (6.5)

		[45182]				  	= 6.5,	-- Cheat Death


		-- Immunes III (6)
		[GladiusEx:SafeGetSpellName(8178)]  	= 6.4,	-- Grounding Totem Effect


		[GladiusEx:SafeGetSpellName(23920)]  	= 6,	-- Spell Reflection
		[GladiusEx:SafeGetSpellName(31224)]  	= 6,	-- Cloak of Shadows



		-- Unbreakable CC and Roots (5)

		[GladiusEx:SafeGetSpellName(6789)]  	= 5,	-- Mortal Coil 
		[GladiusEx:SafeGetSpellName(15487)]  	= 5,	-- Silence
		[GladiusEx:SafeGetSpellName(1330)]  	= 5,	-- Garrote
		[GladiusEx:SafeGetSpellName(339)]  	= 5,	-- Entangling Roots
		[GladiusEx:SafeGetSpellName(122)]  	= 5,	-- Frost Nova
		[GladiusEx:SafeGetSpellName(33395)]  	= 5,	-- Freeze (Water Elemental)
		[GladiusEx:SafeGetSpellName(45334)]  	= 5,	-- Immobilized (wild charge) 


		-- Defensives II (4.5)

		[6940]				  	= 4.5,	-- Blessing of Sacrifice
		[GladiusEx:SafeGetSpellName(31850)]  	= 4.5,	-- Ardent Defender
		[GladiusEx:SafeGetSpellName(33206)]  	= 4.5,	-- Pain Suppression
		[GladiusEx:SafeGetSpellName(871)]  	= 4.5,	-- Shield Wall



		-- Important II (4)

		[GladiusEx:SafeGetSpellName(29166)]  	= 4,	-- Innervate
		[1044]				  	= 4,	-- Blessing of Freedom
		[GladiusEx:SafeGetSpellName(1714)]  	= 4,	-- Curse of Tongues
		[GladiusEx:SafeGetSpellName(34709)]  	= 4,	-- Shadow Sight (eye in arena)

		-- Offensives I (3)

		[GladiusEx:SafeGetSpellName(19574)]  	= 3,	-- Bestial Wrath
		[GladiusEx:SafeGetSpellName(31884)]  	= 3,	-- Avenging Wrath
    [GladiusEx:SafeGetSpellName(31842)] = 3, -- Divine Illumination
    [GladiusEx:SafeGetSpellName(20925)] = 3, -- Holy Shield
    [GladiusEx:SafeGetSpellName(20216)] = 3, -- Divine Favor
    [GladiusEx:SafeGetSpellName(14751)] = 3, -- Inner Focus
    [GladiusEx:SafeGetSpellName(498)] = 3, -- Divine Favor
		[GladiusEx:SafeGetSpellName(13750)]  	= 3,	-- Adrenaline Rush 
		[GladiusEx:SafeGetSpellName(1719)]  	= 3,	-- Recklessness


		-- Defensives III (2.5)

		[GladiusEx:SafeGetSpellName(22812)]  	= 2.5,	-- Barkskin
		[GladiusEx:SafeGetSpellName(22842)]  	= 2.5,	-- Frenzied Regen
		[GladiusEx:SafeGetSpellName(498)]  	= 2.5,	-- Divine Protection
		[GladiusEx:SafeGetSpellName(1966)]  	= 2.5,	-- Feint
		[GladiusEx:SafeGetSpellName(12975)]  	= 2.5,	-- Last Stand
		[66]				  	= 2.5,	-- Invisibility (initial)
		[GladiusEx:SafeGetSpellName(20578)]  	= 2.5,	-- Cannibalize
 
		-- Offensives II (2)

		[GladiusEx:SafeGetSpellName(10060)]  	= 2,	-- Power Infusion
		[GladiusEx:SafeGetSpellName(6346)]  	= 2,	-- Fear Ward


		-- Misc (1)

		[GladiusEx:SafeGetSpellName(19236)]  	= 1,	-- Desperate Prayer
		[2645]				  	= 1,	-- Ghost Wolf
		[GladiusEx:SafeGetSpellName(31821)]  	= 1,	-- Aura Mastery 
		[GladiusEx:SafeGetSpellName(1850)]  	= 1,	-- Dash
		[GladiusEx:SafeGetSpellName(2983)]  	= 1,	-- Sprint
		[GladiusEx:SafeGetSpellName(41425)]  	= 1,	-- Hypothermia
		[GladiusEx:SafeGetSpellName(25771)]  	= 1,	-- Forbearance
		[GladiusEx:SafeGetSpellName(702)]  	= 1,	-- Curse of Weakness
  }
end

function GladiusEx.Data.DefaultCooldowns()
	return {
		{ -- group 1
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

			[19236] = true, -- Priest/Desperate Prayer
			[33206] = true, -- Priest/Pain Suppression
			[8122] = true, -- Priest/Psychic Scream
			[527] = true, -- Priest/Purify
			[15487] = true, -- Priest/Silence
			[10060] = true, -- Priest/Power Infusion
			[32548] = true, -- Priest/Symbols of Hope
			[34433] = true, -- Priest/Shadowfiend
			[14751] = true, -- Priest/Inner Focus
			[6346] = true, -- Priest/Fear Ward

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

      [16188] = true, -- Shaman/Nature's Swiftness
      [8177] = true, -- Shaman/Grounding Totem
      [30823] = true, -- Shaman/Shamanistic Rage
      [5730] = true, -- Shaman/Stoneclaw
		},
		{ -- group 2
		}
	}
end

function GladiusEx.Data.InterruptModifiers()
  return {}
end

function GladiusEx.Data.Interrupts()
  return {}
end

function GladiusEx.Data.GetSpecializationInfoByID(id)
end

