-- ================ HUNTER ================
-- Specs:
-- 253 BM
-- 254 MM
-- 255 Survival

-- Hunter/baseline
-- Concussive Shot
LCT_SpellData[5116] = {
	class = "HUNTER",
	cc = true,
	cooldown = 5
}
-- Disengage
LCT_SpellData[781] = {
	class = "HUNTER",
	defensive = true,
	cooldown = 30
}
-- Counter Shot
LCT_SpellData[147362] = {
	class = "HUNTER",
	interrupt = true,
	cooldown = 24,
	specID = { 253, 254 }, -- BM, MM
}
-- Freezing Trap
-- V: legion id 1499 => 187650
LCT_SpellData[187650] = {
	class = "HUNTER",
	cc = true,
	cooldown = 30
}
-- Explosive Trap
LCT_SpellData[13813] = {
	class = "HUNTER",
	offensive = true,
	cooldown = 30
}
-- Flare
LCT_SpellData[1543] = {
	class = "HUNTER",
	none = true,
	cooldown = 20
}
-- Ice Trap
LCT_SpellData[13809] = {
	class = "HUNTER",
	cc = true,
	cooldown = 30
}
-- Master's Call
LCT_SpellData[53271] = {
	class = "HUNTER",
	defensive = true,
	duration = 4,
	cooldown = 45
}
-- Aspect of Turtle. old: Deterrence
-- V: legion id 19263 => 186265
LCT_SpellData[186265] = {
	class = "HUNTER",
	defensive = true,
	duration = 8,
	charges = 2,
	cooldown = 180
}

-- Hunter/talent
-- Binding Shot
LCT_SpellData[109248] = {
	class = "HUNTER",
	talent = true,
	cc = true,
	cooldown = 45
}
-- Wyvern Sting
LCT_SpellData[19386] = {
	class = "HUNTER",
	talent = true,
	cc = true,
	cooldown = 45
}
-- Exhilaration
LCT_SpellData[109304] = {
	class = "HUNTER",
	heal = true,
	cooldown = 120
}
-- Dire Beast
-- V: legion changed CD
LCT_SpellData[120679] = {
	class = "HUNTER",
	talent = true,
	offensive = true,
	duration = 8,
	cooldown = 12
}
-- Fervor
LCT_SpellData[82726] = {
	class = "HUNTER",
	talent = true,
	offensive = true,
	duration = 10,
	cooldown = 30
}
-- A Murder of Crows
LCT_SpellData[131894] = {
	class = "HUNTER",
	talent = true,
	offensive = true,
	duration = 15,
	cooldown = 60
}
-- Blink Strike
LCT_SpellData[130392] = {
	class = "HUNTER",
	talent = true,
	offensive = true,
	cooldown = 20
}
-- Barrage
LCT_SpellData[120360] = {
	class = "HUNTER",
	talent = true,
	offensive = true,
	duration = 3,
	cooldown = 20
}
-- Intimidation
LCT_SpellData[19577] = {
	class = "HUNTER",
	talent = true,
	stun = true,
	cooldown = 60
}

-- Hunter/253 - Beast Mastery
-- Kill Command
LCT_SpellData[34026] = {
	class = "HUNTER",
	specID = { 253 },
	offensive = true,
	cooldown = 6
}
-- Bestial Wrath
LCT_SpellData[19574] = {
	class = "HUNTER",
	specID = { 253 },
	offensive = true,
	duration = 10,
	cooldown = 60
}
-- Hunter/254 - Marksmanship
-- Rapid Fire
LCT_SpellData[3045] = {
	class = "HUNTER",
	specID = { 254 },
	offensive = true,
	duration = 15,
	cooldown = 120
}
-- Chimera Shot
LCT_SpellData[53209] = {
	class = "HUNTER",
	specID = { 254 },
	offensive = true,
	cooldown = 9
}
-- Pet/Ferocity
-- Heart of the Phoenix
LCT_SpellData[55709] = {
	class = "HUNTER",
	pet = true,
	defensive = true,
	cooldown = 480
}
-- Dash
LCT_SpellData[61684] = {
	class = "HUNTER",
	pet = true,
	duration = 16,
	cooldown = 32
}

-- Pet/Tenacity
-- Last Stand
LCT_SpellData[53478] = {
	class = "HUNTER",
	pet = true,
	defensive = true,
	duration = 20,
	cooldown = 360
}
-- Charge
LCT_SpellData[61685] = {
	class = "HUNTER",
	pet = true,
	offensive = true,
	cooldown = 25
}
-- Thunderstomp
LCT_SpellData[63900] = {
	class = "HUNTER",
	pet = true,
	offensive = true,
	cooldown = 10
}

-- Pet/Cunning
-- Roar of Sacrifice
LCT_SpellData[53480] = {
	class = "HUNTER",
	pet = true,
	defensive = true,
	duration = 12,
	cooldown = 60
}
-- Bullheaded
LCT_SpellData[53490] = {
	class = "HUNTER",
	pet = true,
	defensive = true,
	duration = 12,
	cooldown = 180
}
-- Reflective Armor Plating
LCT_SpellData[137798] = {
	class = "HUNTER",
	pet = true,
	defensive = true,
	duration = 6,
	cooldown = 30
}
-- Shell Shield
LCT_SpellData[26064] = {
	class = "HUNTER",
	pet = true,
	defensive = true,
	duration = 12,
	cooldown = 60
}
-- Time Warp
LCT_SpellData[35346] = {
	class = "HUNTER",
	pet = true,
	cc = true,
	cooldown = 15
}
-- Ankle Crack
LCT_SpellData[50433] = {
	class = "HUNTER",
	pet = true,
	cc = true,
	cooldown = 10
}
-- Harden Carapace
LCT_SpellData[90339] = {
	class = "HUNTER",
	pet = true,
	defensive = true,
	duration = 12,
	cooldown = 60
}
-- Eternal Guardian
LCT_SpellData[126393] = {
	class = "HUNTER",
	pet = true,
	res = true,
	cooldown = 600
}
-- Frost Breath
LCT_SpellData[54644] = {
	class = "HUNTER",
	pet = true,
	cc = true,
	cooldown = 10
}
-- Burrow Attack
LCT_SpellData[93433] = {
	class = "HUNTER",
	pet = true,
	offensive = true,
	duration = 8,
	cooldown = 14
}
-- Spirit Mend
LCT_SpellData[90361] = {
	class = "HUNTER",
	pet = true,
	heal = true,
	cooldown = 30
}

-- Aspect of the wild
LCT_SpellData[90361] = {
	class = "HUNTER",
	specID = { 253 },
	offensive = true,
	duration = 10,
	cooldown = 120
}
-- Stampede
LCT_SpellData[201430] = {
	class = "HUNTER",
	specID = { 253 },
	offensive = true,
	duration = 12,
	cooldown = 180
}
-- Trueshot
LCT_SpellData[193526] = {
	class = "HUNTER",
	specID = { 254 },
	offensive = true,
	duration = 15,
	cooldown = 180
}
-- Aspect of the eagle
LCT_SpellData[186289] = {
	class = "HUNTER",
	specID = { 255 },
	offensive = true,
	duration = 10,
	cooldown = 120
}
-- Caltrops
LCT_SpellData[194277] = {
	class = "HUNTER",
	specID = { 255 },
	defensive = true,
	cooldown = 15
}