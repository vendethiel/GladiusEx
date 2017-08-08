-- ================ PALADIN ================
-- Paladin/baseline
-- Avenging Wrath
LCT_SpellData[31884] = {
	class = "PALADIN",
	specID = { 66, 70 },
	offensive = true,
	defensive = true,
	duration = 20,
	cooldown = 120
}
-- Templar's verdict
-- V: not a CD, require 3 HoPo
--LCT_SpellData[85256] = {
--	class = "PALADIN",
--	specID = { 70 },
--	offensive = true,
--	defensive = true,
--	duration = 20,
--	cooldown = 120
--}
-- Eye for an eye
LCT_SpellData[205191] = {
	class = "PALADIN",
	specID = { 70 },
	defensive = true,
	duration = 10,
	cooldown = 60
}

-- Blinding Light
LCT_SpellData[115750] = {
	class = "PALADIN",
	cc = true,
	talent = true,
	cooldown = 90
}
-- Cleanse
LCT_SpellData[4987] = {
	class = "PALADIN",
	cooldown_starts_on_dispel = true,
	dispel = true,
	cooldown = 8
}
-- V: legion: Devotion Aura => Aura Mastery
LCT_SpellData[31821] = {
	class = "PALADIN",
	specID = { 65 },
	defensive = true,
	duration = 6,
	cooldown = 180
}
-- Divine Protection
LCT_SpellData[498] = {
	class = "PALADIN",
	specID = { 66 },
	defensive = true,
	duration = 8,
	cooldown = 60
}
-- Divine Shield
LCT_SpellData[642] = {
	class = "PALADIN",
	immune = true,
	duration = 8,
	cooldown = 300
}
-- Hammer of Justice
LCT_SpellData[853] = {
	class = "PALADIN",
	stun = true,
	cooldown = 60
}
-- Hammer of Wrath
LCT_SpellData[24275] = {
	class = "PALADIN",
	offensive = true,
	cooldown = 6
}
-- Hand of Freedom
LCT_SpellData[1044] = {
	class = "PALADIN",
	defensive = true,
	opt_charges = 2,
	opt_charges_linked = { 1022, 6940 },
	duration = 6,
	cooldown = 25
}
-- Hand of Protection
LCT_SpellData[1022] = {
	class = "PALADIN",
	defensive = true,
	opt_charges = 2,
	opt_charges_linked = { 1044, 6940 },
	duration = 10,
	cooldown = 300
}
-- Hand of Sacrifice
LCT_SpellData[6940] = {
	class = "PALADIN",
	defensive = true,
	opt_charges = 2,
	opt_charges_linked = { 1044, 1022 },
	duration = 12,
	cooldown = 120
}
-- Judgement
LCT_SpellData[20271] = {
	class = "PALADIN",
	offensive = true,
	cooldown = 6
}
-- Lay on Hands
--[[
LCT_SpellData[633] = {
	class = "PALADIN",
	heal = true -- todo: available on arenas?
	cooldown = 600
}
]]
-- Rebuke
LCT_SpellData[96231] = {
	class = "PALADIN",
	interrupt = true,
	cooldown = 15
}
-- Holy Avenger
LCT_SpellData[105809] = {
	class = "PALADIN",
	specID = { 65 },
	talent = true,
	offensive = true,
	defensive = true,
	duration = 20,
	cooldown = 90
}
-- Holy Prism
LCT_SpellData[114165] = {
	class = "PALADIN",
	talent = true,
	offensive = true,
	heal = true,
	cooldown = 20
}
-- Light's Hammer
LCT_SpellData[114158] = {
	class = "PALADIN",
	talent = true,
	offensive = true,
	heal = true,
	duration = 16,
	cooldown = 60
}
-- Repentance
LCT_SpellData[20066] = {
	class = "PALADIN",
	talent = true,
	cc = true,
	cooldown = 15
}
-- Sacred Shield
--LCT_SpellData[20925] = {
--	class = "PALADIN",
--	talent = true,
--	defensive = true,
--	duration = 30,
--	cooldown = 6
--}
-- Speed of Light
LCT_SpellData[85499] = {
	class = "PALADIN",
	talent = true,
	duration = 8,
	cooldown = 45
}

-- Paladin/Holy
-- V: legion renamed, Divine Favor => Avenging Wrath (holy)
LCT_SpellData[31842] = {
	class = "PALADIN",
	specID = { 65 },
	defensive = true,
	duration = 20,
	cooldown = 180
}
-- Holy Shock
LCT_SpellData[20473] = {
	class = "PALADIN",
	specID = { 65 },
	offensive = true,
	heal = true,
	cooldown = 6
}

-- Paladin/Protection
-- Ardent Defender
LCT_SpellData[31850] = {
	class = "PALADIN",
	specID = { 66 },
	defensive = true,
	duration = 10,
	cooldown = 180
}
-- Avenger's Shield
LCT_SpellData[31935] = {
	class = "PALADIN",
	specID = { 66 },
	silence = true,
	interrupt = true,
	cooldown = 15
}
-- Consecration
LCT_SpellData[26573] = {
	class = "PALADIN",
	specID = { 66 },
	offensive = true,
	duration = 9,
	cooldown = 9
}
-- Guardian of Ancient Kings
LCT_SpellData[86659] = {
	class = "PALADIN",
	specID = { 66 },
	duration = 12,
	defensive = true,
	cooldown = 180
}
