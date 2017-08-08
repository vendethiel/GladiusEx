-- used to be Items. Now PVP trinekts

-- TODO: currently only sets WoTF, should set EMFH(human) as well

set_wotf_emfh = {
	-- WOTF
	{ spellid = 7744, cooldown = 30 },
	-- EMFH
	{ spellid = 59752, cooldown = 30 },
}

-- Honorable Medallion
LCT_SpellData[195710] = {
	pvp_trinket = true,
	replaces = 208683, -- V: that's a big lie :D
	talent = true,
	sets_cooldowns = set_wotf_emfh,
	cooldown = 180
}
-- Gladiator's Medallion
LCT_SpellData[208683] = {
	pvp_trinket = true,
	sets_cooldowns = set_wotf_emfh,
	cooldown = 120
}
-- Adaptation
LCT_SpellData[214027] = {
	pvp_trinket = true,
	talent = true,
	replaces = 208683,
	sets_cooldowns = set_wotf_emfh,
	cooldown = 60
}
-- Relentless
LCT_SpellData[196029] = {
	pvp_trinket = true,
	talent = true,
	replaces = 208683,
	--sets_cooldown = { spellid = 7744, cooldown = 30 }
}

-- Healthstone
LCT_SpellData[6262] = {
	item = true,
	talent = true, -- hack to prevent it being displayed before being detected
	heal = true,
	cooldown = 60
}