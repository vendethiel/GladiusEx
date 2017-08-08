-- ================ MONK ================
-- Spec
-- 268 brewmaster
-- 267 windwalker
-- 270 mistweaver
-- Monk/baseline

-- Roll
LCT_SpellData[109132] = {
	class = "MONK",
	charges = 2,
	cooldown = 20,
}
-- Chi Torpedo
LCT_SpellData[115008] = 109132

-- Detox
LCT_SpellData[115450] = {
	class = "MONK",
	dispel = true,
	cooldown_starts_on_dispel = true,
	cooldown = 8,
}
-- Fortifying Brew
LCT_SpellData[115203] = {
	class = "MONK",
	specID = { 268 },
	defensive = true,
	duration = 15,
	cooldown = 420,
}
-- Paralysis
LCT_SpellData[115078] = {
	class = "MONK",
	cc = true,
	cooldown = 15,
}
-- Spear Hand Strike
LCT_SpellData[116705] = {
	class = "MONK",
	interrupt = true,
	silence = true,
	cooldown = 15,
}
-- Touch of Death
LCT_SpellData[115080] = {
	class = "MONK",
	specID = { 269 },
	offensive = true,
	cooldown = 120,
}
-- Storm, Earth, and Fire
LCT_SpellData[137639] = {
	class = "MONK",
	specID = { 269 },
	offensive = true,
	cooldown = 90,
}
-- Transcendence
LCT_SpellData[101643] = {
	class = "MONK",
	cooldown = 45,
}
-- Transcendence: Transfer
LCT_SpellData[119996] = {
	class = "MONK",
	cooldown = 25,
}
-- Zen Meditation
LCT_SpellData[115176] = {
	class = "MONK",
	specID = { 268 },
	defensive = true,
	duration = 8,
	cooldown = 300,
}
-- Exploding Keg
LCT_SpellData[214326] = {
	class = "MONK",
	specID = { 268 },
	offensive = true,
	cooldown = 75,
}
-- Chi Brew
LCT_SpellData[115399] = {
	class = "MONK",
	talent = true,
	charges = 2,
	cooldown = 45
}
-- Chi Wave
LCT_SpellData[115098] = {
	class = "MONK",
	talent = true,
	cooldown = 15
}
-- Dampen Harm (mistweaver &windwalker)
LCT_SpellData[122278] = {
	class = "MONK",
	specID = { 270, 269 },
	talent = true,
	defensive = true,
	duration = 10,
	cooldown = 120,
}
-- Diffuse Magic (mistweaver & windwalker)
LCT_SpellData[122783] = {
	class = "MONK",
	specID = { 270, 269 },
	talent = true,
	defensive = true,
	duration = 6,
	cooldown = 90
}
-- Zen Moment
LCT_SpellData[201325] = {
	class = "MONK",
	specID = { 269 },
	defensive = true,
	duration = 10,
	cooldown = 45
}
-- Invoke Xuen, the White Tiger
LCT_SpellData[123904] = {
	class = "MONK",
	specID = { 269 },
	talent = true,
	duration = 45,
	cooldown = 180
}
-- Grapple Weapon
LCT_SpellData[233759] = {
	class = "MONK",
	specID = { 269 },
	disarm = true, -- V: TODO disarms
	cooldown = 60
}
-- Serenity
LCT_SpellData[152173] = {
	class = "MONK",
	specID = { 269 },
	talent = true,
	offensive = true,
	duration = 8,
	cooldown = 90
}
-- Leg Sweep
LCT_SpellData[119381] = {
	class = "MONK",
	talent = true,
	stun = true,
	cooldown = 45
}
-- Ring of Peace
LCT_SpellData[116844] = {
	class = "MONK",
	talent = true,
	defensive = true,
	duration = 8,
	cooldown = 45
}
-- Rushing Jade Wind
LCT_SpellData[116847] = {
	class = "MONK",
	talent = true,
	offensive = true,
	cooldown = 6,
}
-- Tiger's Lust
LCT_SpellData[116841] = {
	class = "MONK",
	talent = true,
	defensive = true,
	duration = 6,
	cooldown = 30,
}

-- Monk/Brewmaster
-- Elusive Brew
LCT_SpellData[115308] = {
	class = "MONK",
	specID = { 268 },
	defensive = true,
	duration = 3,
	cooldown = 6,
	charges = 3,
}
-- Keg Smash
LCT_SpellData[121253] = {
	class = "MONK",
	specID = { 268 },
	offensive = true,
	cooldown = 8
}
-- Summon Black Ox
LCT_SpellData[115315] = {
	class = "MONK",
	specID = { 268 },
	cooldown = 10
}
-- Monk/Windwalker
-- Energizing Brew
LCT_SpellData[115288] = {
	class = "MONK",
	specID = { 269 },
	offensive = true,
	duration = 6,
	cooldown = 60,
}
-- Fists of Fury
LCT_SpellData[113656] = {
	class = "MONK",
	specID = { 269 },
	offensive = true,
	duration = 4,
	cooldown = 25,
}
-- Flying Serpent Kick
LCT_SpellData[101545] = {
	class = "MONK",
	specID = { 269 },
	cooldown = 25,

}
-- Rising Sun Kick
LCT_SpellData[107428] = {
	class = "MONK",
	specID = { 269 },
	offensive = true,
	cooldown = 8,

}
-- Touch of Karma
LCT_SpellData[122470] = {
	class = "MONK",
	specID = { 269 },
	offensive = true,
	defensive = true,
	duration = 10,
	cooldown = 90
}
-- Monk/Mistweaver
-- Life Cocoon
LCT_SpellData[116849] = {
	class = "MONK",
	specID = { 270 },
	heal = true,
	duration = 12,
	cooldown = 90, -- NOTE: without Chrysalis (PVP talent), it's 180 sec
}
-- Renewing Misg
-- TODO: 3 possible charges with Pool of Mists
LCT_SpellData[115151] = {
	class = "MONK",
	specID = { 270 },
	heal = true,
	cooldown = 8
}
-- Revival
LCT_SpellData[115310] = {
	class = "MONK",
	specID = { 270 },
	mass_dispel = true,
	cooldown = 180
}
-- Summon Jade Serpent
LCT_SpellData[115313] = {
	class = "MONK",
	specID = { 270 },
	heal = true,
	cooldown = 10
}
-- Thunder Focus Tea
LCT_SpellData[116680] = {
	class = "MONK",
	specID = { 270 },
	heal = true,
	duration = 30,
	cooldown = 45
}
-- Invoke Chi-Ji, red crane
LCT_SpellData[198664] = {
	class = "MONK",
	specID = { 270 },
	talent = true,
	heal = true,
	duration = 45,
	cooldown = 180
}
-- Mana Tea
LCT_SpellData[197908] = {
	class = "MONK",
	specID = { 270 },
	talent = true,
	heal = true,
	duration = 10,
	cooldown = 90
}
