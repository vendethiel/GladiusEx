-- ================ SHAMAN ================

-- V: todo, blood list(?)

-- Shaman/baseline
-- Cleanse Spirit
LCT_SpellData[51886] = {
	class = "SHAMAN",
	dispel = true,
	cooldown_starts_on_dispel = true,
	cooldown = 8
}
-- Earth Shock
LCT_SpellData[8042] = {
	class = "SHAMAN",
	offensive = true,
	cooldown = 6
}
-- Earthbind Totem
LCT_SpellData[2484] = {
	class = "SHAMAN",
	cc = true,
	duration = 20,
	cooldown = 30
}
-- Healing Rain
LCT_SpellData[73920] = {
	class = "SHAMAN",
	heal = true,
	duration = 10,
	cooldown = 10
}
-- Healing Stream Totem
LCT_SpellData[5394] = {
	class = "SHAMAN",
	heal = true,
	duration = 15,
	cooldown = 30
}
-- Hex
LCT_SpellData[51514] = {
	class = "SHAMAN",
	cc = true,
	cooldown = 45
}
-- Primal Strike
LCT_SpellData[73899] = {
	class = "SHAMAN",
	offensive = true,
	cooldown = 8
}
-- Spiritwalker's Grace
LCT_SpellData[79206] = {
	class = "SHAMAN",
	specID = { 264 },
	duration = 15,
	cooldown = 120
}
-- Stormblast
LCT_SpellData[115356] = {
	class = "SHAMAN",
	offensive = true,
	cooldown = 8
}
-- Unleash Life
LCT_SpellData[73685] = {
	class = "SHAMAN",
	heal = true,
	cooldown = 15
}
-- Wind Shear
LCT_SpellData[57994] = {
	class = "SHAMAN",
	interrupt = true,
	cooldown = 12
}


-- Shaman/talents
-- Ancestral Guidance
LCT_SpellData[108281] = {
	class = "SHAMAN",
	talent = true,
	heal = true,
	duration = 10,
	cooldown = 120
}
-- Astral Shift
LCT_SpellData[108271] = {
	class = "SHAMAN",
	talent = true,
	defensive = true,
	duration = 8,
	cooldown = 90
}
-- Earthgrab Totem
LCT_SpellData[51485] = {
	class = "SHAMAN",
	talent = true,
	replaces = 2484,
	duration = 20,
	cooldown = 30
}
-- Elemental Blast
LCT_SpellData[117014] = {
	class = "SHAMAN",
	talent = true,
	offensive = true,
	cooldown = 12
}
-- Elemental Mastery
LCT_SpellData[16166] = {
	class = "SHAMAN",
	specID = { 262 },
	talent = true,
	offensive = true,
	duration = 20,
	cooldown = 120
}
-- Healing Tide Totem
LCT_SpellData[108280] = {
	class = "SHAMAN",
	specID = { 264 },
	heal = true,
	duration = 10,
	cooldown = 180
}
-- Stone Bulwark Totem
LCT_SpellData[198838] = {
	class = "SHAMAN",
	specID = { 264 },
	talent = true,
	defensive = true,
	cooldown = 60
}
-- Windwalk Totem
LCT_SpellData[108273] = {
	class = "SHAMAN",
	talent = true,
	defensive = true,
	duration = 6,
	cooldown = 60
}
-- Shaman/Elemental
-- Earthquake
LCT_SpellData[61882] = {
	class = "SHAMAN",
	specID = { 262 },
	knockback = true,
	duration = 10,
	cooldown = 10
}
-- Fire Elemental
LCT_SpellData[198067] = {
	class = "SHAMAN",
	specID = { 262 },
	cooldown = 300,
}
-- Ascendance (elemental)
LCT_SpellData[114050] = {
	class = "SHAMAN",
	specID = { 262 },
	talent = true,
	duration = 15,
	cooldown = 180,
}
-- Lava Burst
LCT_SpellData[51505] = {
	class = "SHAMAN",
	specID = { 262 },
	offensive = true,
	cooldown = 8
}
-- Thunderstorm
LCT_SpellData[51490] = {
	class = "SHAMAN",
	specID = { 262 },
	knockback = true,
	cc = true,
	cooldown = 45
}
-- Earth Elemental
LCT_SpellData[198103] = {
	class = "SHAMAN",
	specID = { 262 },
	defensive = true,
	cooldown = 300
}
-- Shaman/Enhancement
-- Feral Spirit
LCT_SpellData[51533] = {
	class = "SHAMAN",
	specID = { 263 },
	offensive = true,
	heal = true,
	duration = 15,
	cooldown = 120
}
-- Ascendance (enhancement)
LCT_SpellData[114051] = {
	class = "SHAMAN",
	specID = { 263 },
	talent = true,
	offensive = true,
	cooldown = 180
}
-- Lava Lash
LCT_SpellData[60103] = {
	class = "SHAMAN",
	specID = { 263 },
	offensive = true,
	cooldown = 10
}
-- Spirit Walk
LCT_SpellData[58875] = {
	class = "SHAMAN",
	specID = { 263 },
	defensive = true,
	duration = 8,
	cooldown = 60
}
-- Stormstrike
LCT_SpellData[17364] = {
	class = "SHAMAN",
	specID = { 263 },
	offensive = true,
	cooldown = 8
}

-- Shaman/Restoration 264
-- Purify Spirit
LCT_SpellData[77130] = {
	class = "SHAMAN",
	specID = { 264 },
	dispel = true,
	replaces = 51886,
	cooldown_starts_on_dispel = true,
	cooldown = 8
}
-- Riptide
LCT_SpellData[61295] = {
	class = "SHAMAN",
	specID = { 264 },
	heal = true,
	cooldown = 6
}
-- Spirit Link Totem
LCT_SpellData[98008] = {
	class = "SHAMAN",
	specID = { 264 },
	talent = true,
	defensive = true,
	duration = 6, -- V: technically it's 20s
	cooldown = 180
}
