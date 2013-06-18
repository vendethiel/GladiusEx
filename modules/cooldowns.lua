local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM = LibStub("LibSharedMedia-3.0")
local CT = LibStub("LibCooldownTracker-1.0")
local fn = LibStub("LibFunctional-1.0")

-- global functions
local tinsert, tremove, tsort = table.insert, table.remove, table.sort
local pairs, ipairs, select, type, unpack, wipe = pairs, ipairs, select, type, unpack, wipe
local min, max, ceil, random = math.min, math.max, math.ceil, math.random
local GetTime, UnitExists, UnitFactionGroup, UnitClass, UnitRace = GetTime, UnitExists, UnitFactionGroup, UnitClass, UnitRace
local UnitBuff = UnitBuff

local function GetDefaultSpells()
	return {
		{ -- group 1
			[28730] = true, -- BloodElf/Arcane Torrent
			[107079] = true, -- Pandaren/Quaking Palm
			[69070] = true, -- Goblin/Rocket Jump
			[7744] = true, -- Scourge/Will of the Forsaken
			[48707] = true, -- Death Knight/Anti-Magic Shell
			[42650] = true, -- Death Knight/Army of the Dead
			[108194] = true, -- Death Knight/Asphyxiate
			[49576] = true, -- Death Knight/Death Grip
			[48743] = true, -- Death Knight/Death Pact
			[108201] = true, -- Death Knight/Desecrated Ground
			[47568] = true, -- Death Knight/Empower Rune Weapon
			[48792] = true, -- Death Knight/Icebound Fortitude
			[49039] = true, -- Death Knight/Lichborne
			[47528] = true, -- Death Knight/Mind Freeze
			[51271] = true, -- Death Knight/Pillar of Frost
			[61999] = true, -- Death Knight/Raise Ally
			[108200] = true, -- Death Knight/Remorseless Winter
			[47476] = true, -- Death Knight/Strangulate
			[49206] = true, -- Death Knight/Summon Gargoyle
			[110570] = true, -- Druid/Anti-Magic Shell
			[22812] = true, -- Druid/Barkskin
			[122288] = true, -- Druid/Cleanse
			[110788] = true, -- Druid/Cloak of Shadows
			[33786] = true, -- Druid/Cyclone (feral)
			[112970] = true, -- Druid/Demonic Circle: Teleport
			[110617] = true, -- Druid/Deterrence
			[99] = true, -- Druid/Disorienting Roar
			[110715] = true, -- Druid/Dispersion
			[102280] = true, -- Druid/Displacer Beast
			[110700] = true, -- Druid/Divine Shield
			[110791] = true, -- Druid/Evasion
			[126456] = true, -- Druid/Fortifying Brew
			[110693] = true, -- Druid/Frost Nova
			[110698] = true, -- Druid/Hammer of Justice
			[108288] = true, -- Druid/Heart of the Wild
			[110696] = true, -- Druid/Ice Block
			[110575] = true, -- Druid/Icebound Fortitude
			[106731] = true, -- Druid/Incarnation
			[113004] = true, -- Druid/Intimidating Roar
			[102342] = true, -- Druid/Ironbark
			[110718] = true, -- Druid/Leap of Faith
			[102359] = true, -- Druid/Mass Entanglement
			[5211] = true, -- Druid/Mighty Bash
			[88423] = true, -- Druid/Nature's Cure
			[132158] = true, -- Druid/Nature's Swiftness
			[2782] = true, -- Druid/Remove Corruption
			[80964] = true, -- Druid/Skull Bash
			[78675] = true, -- Druid/Solar Beam
			[132469] = true, -- Druid/Typhoon
			[122291] = true, -- Druid/Unending Resolve
			[102793] = true, -- Druid/Ursol's Vortex
			[90337] = true, -- Hunter/Bad Manner
			[19574] = true, -- Hunter/Bestial Wrath
			[19263] = true, -- Hunter/Deterrence
			[781] = true, -- Hunter/Disengage
			[1499] = true, -- Hunter/Freezing Trap
			[19577] = true, -- Hunter/Intimidation
			[126246] = true, -- Hunter/Lullaby
			[50479] = true, -- Hunter/Nether Shock
			[126355] = true, -- Hunter/Paralyzing Quill
			[126423] = true, -- Hunter/Petrifying Gaze
			[26090] = true, -- Hunter/Pummel
			[23989] = true, -- Hunter/Readiness
			[19503] = true, -- Hunter/Scatter Shot
			[34490] = true, -- Hunter/Silencing Shot
			[50519] = true, -- Hunter/Sonic Blast
			[121818] = true, -- Hunter/Stampede
			[96201] = true, -- Hunter/Web Wrap
			[19386] = true, -- Hunter/Wyvern Sting
			[108843] = true, -- Mage/Blazing Speed
			[1953] = true, -- Mage/Blink
			[11958] = true, -- Mage/Cold Snap
			[2139] = true, -- Mage/Counterspell
			[44572] = true, -- Mage/Deep Freeze
			[122] = true, -- Mage/Frost Nova
			[102051] = true, -- Mage/Frostjaw
			[113074] = true, -- Mage/Healing Touch
			[45438] = true, -- Mage/Ice Block
			[115450] = true, -- Monk/Detox
			[122783] = true, -- Monk/Diffuse Magic
			[113656] = true, -- Monk/Fists of Fury
			[115203] = true, -- Monk/Fortifying Brew
			[119381] = true, -- Monk/Leg Sweep
			[116849] = true, -- Monk/Life Cocoon
			[137562] = true, -- Monk/Nimble Brew
			[115078] = true, -- Monk/Paralysis
			[115310] = true, -- Monk/Revival
			[116844] = true, -- Monk/Ring of Peace
			[116705] = true, -- Monk/Spear Hand Strike
			[116680] = true, -- Monk/Thunder Focus Tea
			[116841] = true, -- Monk/Tiger's Lust
			[122470] = true, -- Monk/Touch of Karma
			[115750] = true, -- Paladin/Blinding Light
			[4987] = true, -- Paladin/Cleanse
			[31821] = true, -- Paladin/Devotion Aura
			[642] = true, -- Paladin/Divine Shield
			[105593] = true, -- Paladin/Fist of Justice
			[86698] = true, -- Paladin/Guardian of Ancient Kings
			[86669] = true, -- Paladin/Guardian of Ancient Kings
			[853] = true, -- Paladin/Hammer of Justice
			[96231] = true, -- Paladin/Rebuke
			[20066] = true, -- Paladin/Repentance
			[19236] = true, -- Priest/Desperate Prayer
			[47585] = true, -- Priest/Dispersion
			[47788] = true, -- Priest/Guardian Spirit
			[96267] = true, -- Priest/Inner Focus
			[89485] = true, -- Priest/Inner Focus
			[73325] = true, -- Priest/Leap of Faith
			[33206] = true, -- Priest/Pain Suppression
			[8122] = true, -- Priest/Psychic Scream
			[108921] = true, -- Priest/Psyfiend
			[527] = true, -- Priest/Purify
			[15487] = true, -- Priest/Silence
			[112833] = true, -- Priest/Spectral Guise
			[108968] = true, -- Priest/Void Shift
			[108920] = true, -- Priest/Void Tendrils
			[13750] = true, -- Rogue/Adrenaline Rush
			[2094] = true, -- Rogue/Blind
			[31230] = true, -- Rogue/Cheat Death
			[31224] = true, -- Rogue/Cloak of Shadows
			[1766] = true, -- Rogue/Kick
			[137619] = true, -- Rogue/Marked for Death
			[14185] = true, -- Rogue/Preparation
			[121471] = true, -- Rogue/Shadow Blades
			[51713] = true, -- Rogue/Shadow Dance
			[76577] = true, -- Rogue/Smoke Bomb
			[1856] = true, -- Rogue/Vanish
			[79140] = true, -- Rogue/Vendetta
			[114049] = true, -- Shaman/Ascendance
			[51886] = true, -- Shaman/Cleanse Spirit
			[8177] = true, -- Shaman/Grounding Totem
			[108280] = true, -- Shaman/Healing Tide Totem
			[51514] = true, -- Shaman/Hex
			[16190] = true, -- Shaman/Mana Tide Totem
			[77130] = true, -- Shaman/Purify Spirit
			[30823] = true, -- Shaman/Shamanistic Rage
			[113286] = true, -- Shaman/Solar Beam
			[98008] = true, -- Shaman/Spirit Link Totem
			[79206] = true, -- Shaman/Spiritwalker's Grace
			[51490] = true, -- Shaman/Thunderstorm
			[8143] = true, -- Shaman/Tremor Totem
			[57994] = true, -- Shaman/Wind Shear
			[89766] = true, -- Warlock/Axe Toss
			[111397] = true, -- Warlock/Blood Horror
			[103967] = true, -- Warlock/Carrion Swarm
			[110913] = true, -- Warlock/Dark Bargain
			[108359] = true, -- Warlock/Dark Regeneration
			[113858] = true, -- Warlock/Dark Soul: Instability
			[113861] = true, -- Warlock/Dark Soul: Knowledge
			[113860] = true, -- Warlock/Dark Soul: Misery
			[48020] = true, -- Warlock/Demonic Circle: Teleport
			[5484] = true, -- Warlock/Howl of Terror
			[6789] = true, -- Warlock/Mortal Coil
			[115781] = true, -- Warlock/Optical Blast
			[30283] = true, -- Warlock/Shadowfury
			[89808] = true, -- Warlock/Singe Magic
			[19647] = true, -- Warlock/Spell Lock
			[6229] = true, -- Warlock/Twilight Ward
			[104773] = true, -- Warlock/Unending Resolve
			[107574] = true, -- Warrior/Avatar
			[118038] = true, -- Warrior/Die by the Sword
			[5246] = true, -- Warrior/Intimidating Shout
			[6552] = true, -- Warrior/Pummel
			[1719] = true, -- Warrior/Recklessness
			[871] = true, -- Warrior/Shield Wall
			[46968] = true, -- Warrior/Shockwave
			[23920] = true, -- Warrior/Spell Reflection
		},
		{ -- group 2
			[42292] = true, -- ITEMS/PvP Trinket
		}
	}
end

local function MakeGroupDb(settings)
	local defaults = {
		cooldownsAttachTo = "Frame",
		cooldownsAnchor = "TOPLEFT",
		cooldownsRelativePoint = "BOTTOMLEFT",
		cooldownsOffsetX = 0,
		cooldownsOffsetY = 0,
		cooldownsBackground = { r = 0, g = 0, b = 0, a = 0 },
		cooldownsGrow = "DOWNRIGHT",
		cooldownsPaddingX = 0,
		cooldownsPaddingY = 0,
		cooldownsSpacingX = 0,
		cooldownsSpacingY = 0,
		cooldownsPerColumn = 10,
		cooldownsMax = 10,
		cooldownsSize = 20,
		cooldownsCrop = true,
		cooldownsDetached = false,
		cooldownsLocked = false,
		cooldownsGroupByUnit = false,
		cooldownsTooltips = true,
		cooldownsSpells = {},
		cooldownsBorderSize = 1,
		cooldownsBorderAvailAlpha = 1,
		cooldownsBorderUsingAlpha = 1,
		cooldownsBorderCooldownAlpha = 0.2,
		cooldownsIconAvailAlpha = 1,
		cooldownsIconUsingAlpha = 1,
		cooldownsIconCooldownAlpha = 0.2,
		cooldownsCatPriority = {
			"pvp_trinket", "dispel", "mass_dispel", "immune",
			"interrupt", "silence", "stun", "knockback", "cc",
			"offensive", "defensive", "heal", "uncat"
		},
		cooldownsCatColors = {
			["pvp_trinket"] = { r = 0, g = 0, b = 0 }, ["dispel"] =    { r = 1, g = 1, b = 1 },
			["mass_dispel"] = { r = 1, g = 1, b = 1 }, ["immune"] =    { r = 0, g = 0, b = 1 },
			["interrupt"] =   { r = 1, g = 0, b = 1 }, ["silence"] =   { r = 1, g = 0, b = 1 },
			["stun"] =        { r = 0, g = 1, b = 1 }, ["knockback"] = { r = 0, g = 1, b = 1 },
			["cc"] =          { r = 0, g = 1, b = 1 }, ["offensive"] = { r = 1, g = 0, b = 0 },
			["defensive"] =   { r = 0, g = 1, b = 0 }, ["heal"] =      { r = 0, g = 1, b = 0 },
			["uncat"] =       { r = 1, g = 1, b = 1 },
		},
		cooldownsHideTalentsUntilDetected = true,
	}
	return fn.merge(defaults, settings or {})
end

local defaults = {
	num_groups = 2,
	group_table = {
		[1] = "group_1",
		[2] = "group_2",
	}
}

local g1_defaults = MakeGroupDb {
	cooldownsGroupId = 1,
	cooldownsBorderSize = 0,
	cooldownsPaddingX = 0,
	cooldownsPaddingY = 2,
	cooldownsSpacingX = 2,
	cooldownsSpacingY = 0,
	cooldownsSpells = GetDefaultSpells()[1],
}

local g2_defaults = MakeGroupDb {
	cooldownsGroupId = 2,
	cooldownsPerColumn = 1,
	cooldownsMax = 1,
	cooldownsSize = 42,
	cooldownsCrop = true,
	cooldownsTooltips = false,
	cooldownsBorderSize = 1,
	cooldownsBorderAvailAlpha = 1.0,
	cooldownsBorderUsingAlpha = 1.0,
	cooldownsBorderCooldownAlpha = 1.0,
	cooldownsIconAvailAlpha = 1.0,
	cooldownsIconUsingAlpha = 1.0,
	cooldownsIconCooldownAlpha = 1.0,
	cooldownsSpells = GetDefaultSpells()[2],
}

local Cooldowns = GladiusEx:NewGladiusExModule("Cooldowns",
	fn.merge(defaults, {
		groups = {
			["group_1"] = fn.merge(g1_defaults, {
				cooldownsAttachTo = "Frame",
				cooldownsAnchor = "TOPLEFT",
				cooldownsRelativePoint = "BOTTOMLEFT",
				cooldownsGrow = "DOWNRIGHT",
			}),
			["group_2"] = fn.merge(g2_defaults, {
				cooldownsAttachTo = "Frame",
				cooldownsAnchor = "TOPLEFT",
				cooldownsRelativePoint = "TOPRIGHT",
				cooldownsGrow = "DOWNRIGHT",
			})
		},
	}),
	fn.merge(defaults, {
		groups = {
			["group_1"] = fn.merge(g1_defaults, {
				cooldownsAttachTo = "Frame",
				cooldownsAnchor = "TOPRIGHT",
				cooldownsRelativePoint = "BOTTOMRIGHT",
				cooldownsGrow = "DOWNLEFT",
			}),
			["group_2"] = fn.merge(g2_defaults, {
				cooldownsAttachTo = "Frame",
				cooldownsAnchor = "TOPRIGHT",
				cooldownsRelativePoint = "TOPLEFT",
				cooldownsGrow = "DOWNLEFT",
			})
		}
	}))

local MAX_ICONS = 40

local unit_state = {}
function Cooldowns:GetGroupState(unit, group)
	local gu = unit_state[unit]
	if not gu then
		gu = {}
		unit_state[unit] = gu
	end

	local gs = gu[group]
	if not gs then
		gs = {}
		gu[group] = gs
	end
	return gs
end

function Cooldowns:MakeGroupId()
	-- not ideal, but should be good enough for its purpose
	return math.random(2^31-1)
end

function Cooldowns:GetNumGroups(unit)
	return self.db[unit].num_groups
end

function Cooldowns:GetGroupDB(unit, group)
	local k = self.db[unit].group_table[group]
	return self.db[unit].groups[k]
end

function Cooldowns:GetGroupById(unit, gid)
	for group = 1, self:GetNumGroups(unit) do
		local gdb = self:GetGroupDB(unit, group)
		if gdb.cooldownsGroupId == gid then
			return gdb, group
		end
	end
end

function Cooldowns:AddGroup(unit, groupdb)
	local group = self:GetNumGroups(unit) + 1
	self.db[unit].num_groups = group
	self.db[unit].groups["group_" .. groupdb.cooldownsGroupId] = groupdb
	self.db[unit].group_table[group] = "group_" .. groupdb.cooldownsGroupId
	return self:GetNumGroups(unit)
end

function Cooldowns:RemoveGroup(unit, group)
	local groupdb = self:GetGroupDB(unit, group)
	self.db[unit].num_groups = self:GetNumGroups(unit) - 1
	tremove(self.db[unit].group_table, group)
	self.db[unit].groups["group_" .. groupdb.cooldownsGroupId] = nil
end

local header_units = { ["player"] = true, ["arena1"] = true }
local function IsHeaderUnit(unit)
	return header_units[unit]
end

local function GetHeaderUnit(unit)
	return GladiusEx:IsPartyUnit(unit) and "player" or "arena1"
end

function Cooldowns:OnEnable()
	CT.RegisterCallback(self, "LCT_CooldownUsed")
	CT.RegisterCallback(self, "LCT_CooldownsReset")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterMessage("GLADIUS_SPEC_UPDATE")
end

function Cooldowns:OnDisable()
	for unit in pairs(unit_state) do
		self:Reset(unit)
	end

	CT.UnregisterAllCallbacks(self)
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()
end

function Cooldowns:GetFrames(unit)
	local frames = {}
	for group = 1, self:GetNumGroups(unit) do
		local db = self:GetGroupDB(unit, group)
		if not db.cooldownsDetached then
			tinsert(frames, self:GetGroupState(unit, group).frame)
		end
	end
	return frames
end

function Cooldowns:OnProfileChanged()
	self.super.OnProfileChanged(self)
	self:SpellSortingChanged()
end

function Cooldowns:GetModuleAttachPoints(unit)
	local t = {}
	for group = 1, self:GetNumGroups(unit) do
		local db = self:GetGroupDB(unit, group)
		if not db.cooldownsDetached then
			t["Cooldowns_" .. db.cooldownsGroupId] = string.format(L["Cooldowns group %i"], group)
		end
	end
	return t
end

function Cooldowns:GetModuleAttachFrame(unit, point)
	local gid = string.match(point, "^Cooldowns_(%d+)$")
	if not gid then return nil end

	local group, gidx = self:GetGroupById(unit, tonumber(gid))
	if not group then return nil end

	-- self:CreateGroupFrame(unit, group)

	return self:GetGroupState(unit, gidx).frame
end

function Cooldowns:GLADIUS_SPEC_UPDATE(event, unit)
	self:UpdateIcons(unit)
end

function Cooldowns:UNIT_NAME_UPDATE(event, unit)
	-- hopefully at this point the opponent's faction is known
	if GladiusEx:IsHandledUnit(unit) then
		self:UpdateIcons(unit)
	end
end

function Cooldowns:LCT_CooldownsReset(event, unit)
	self:UpdateIcons(unit)
end

function Cooldowns:LCT_CooldownUsed(event, unit, spellid)
	self:UpdateIcons(unit)
end

local function CooldownFrame_OnUpdate(frame)
	local tracked = frame.tracked
	local now = GetTime()

	if tracked and (not tracked.charges_detected or not tracked.charges or tracked.charges <= 0) then
		if tracked.used_start and ((not tracked.used_end and not tracked.cooldown_start) or (tracked.used_end and tracked.used_end > now)) then
			-- using
			if frame.state == 0 then
				if tracked.used_end then
					frame.cooldown:SetReverse(true)
					frame.cooldown:SetCooldown(tracked.used_start, tracked.used_end - tracked.used_start)
					frame.cooldown:Show()
				else
					frame.cooldown:Hide()
				end
				local a = Cooldowns:GetGroupDB(frame.unit, frame.group).cooldownsIconUsingAlpha
				local ab = Cooldowns:GetGroupDB(frame.unit, frame.group).cooldownsBorderUsingAlpha
				frame:SetBackdropBorderColor(frame.color.r, frame.color.g, frame.color.b, ab)
				frame.icon_frame:SetAlpha(a)
				frame.state = 1
			end
			return
		end
		if tracked.used_start and not tracked.cooldown_start and frame.spelldata.active_until_cooldown_start then
			-- waiting to be used (inner focus)
			if frame.state ~= 2 then
				local a = Cooldowns:GetGroupDB(frame.unit, frame.group).cooldownsIconUsingAlpha
				local ab = Cooldowns:GetGroupDB(frame.unit, frame.group).cooldownsBorderUsingAlpha
				frame:SetBackdropBorderColor(frame.color.r, frame.color.g, frame.color.b, ab)
				frame.icon_frame:SetAlpha(a)
				frame.cooldown:Hide()
				frame.state = 2
			end
			return
		end
		if tracked.cooldown_end and tracked.cooldown_end > now then
			-- in cooldown
			if frame.state ~= 3 then
				frame.cooldown:SetReverse(false)
				frame.cooldown:SetCooldown(tracked.cooldown_start, tracked.cooldown_end - tracked.cooldown_start)
				local a = Cooldowns:GetGroupDB(frame.unit, frame.group).cooldownsIconCooldownAlpha
				local ab = Cooldowns:GetGroupDB(frame.unit, frame.group).cooldownsBorderCooldownAlpha
				frame:SetBackdropBorderColor(frame.color.r, frame.color.g, frame.color.b, ab)
				frame.icon_frame:SetAlpha(a)
				frame.cooldown:Show()
				frame.state = 3
			end
			return
		end
	end

	-- not on cooldown or being used
	if frame.tracked and frame.tracked.charges_detected and frame.tracked.charges < frame.tracked.max_charges then
		-- show the charge cooldown
		frame.cooldown:SetReverse(false)
		frame.cooldown:SetCooldown(tracked.cooldown_start, tracked.cooldown_end - tracked.cooldown_start, frame.tracked.charges, frame.tracked.max_charges)
		frame.cooldown:Show()
	else
		frame.cooldown:SetCooldown(0, 0)
	end
	local a = Cooldowns:GetGroupDB(frame.unit, frame.group).cooldownsIconAvailAlpha
	local ab = Cooldowns:GetGroupDB(frame.unit, frame.group).cooldownsBorderAvailAlpha
	frame:SetBackdropBorderColor(frame.color.r, frame.color.g, frame.color.b, ab)
	frame.icon_frame:SetAlpha(a)
	frame:SetScript("OnUpdate", nil)
	frame.tracked = nil
end

local unit_sortscore = {}
function Cooldowns:SpellSortingChanged()
	-- remove cached sorting info from spells
	unit_sortscore = {}
end

local function GetSpellSortScore(unit, group, spellid)
	local db = Cooldowns:GetGroupDB(unit, group)

	local group_sortscore = unit_sortscore[unit]
	if not group_sortscore then
		group_sortscore = {}
		unit_sortscore[unit] = group_sortscore
	end

	local sortscore = group_sortscore[group]
	if not sortscore then
		sortscore = {}
		group_sortscore[group] = sortscore
	end

	local spelldata = CT:GetCooldownData(spellid)

	if spelldata.replaces then
		spellid = spelldata.replaces
		spelldata = CT:GetCooldownData(spelldata.replaces)
	end

	if sortscore[spellid] then
		return sortscore[spellid]
	end

	local cat_priority = db.cooldownsCatPriority

	local score = 0
	local value = 2^30
	local uncat_score = 0

	for i = 1, #cat_priority do
		local key = cat_priority[i]
		if key == "uncat" then
			uncat_score = value
		end
		if spelldata[key] then
			score = score + value
		end
		value = value / 2
	end
	if score == 0 then score = uncat_score end

	-- use the decimal part to sort by name. will probably fail in some locales.
	local len = min(4, spelldata.name:len())
	local max = 256^len
	local sum = 0
	for i = 1, len do
		sum = bit.bor(bit.lshift(sum, 8), spelldata.name:byte(i))
	end
	score = score + (max - sum) / max

	sortscore[spellid] = score

	return score
end

function Cooldowns:UpdateIcons(unit)
	for group = 1, self:GetNumGroups(unit) do
		self:UpdateGroupIcons(unit, group)
	end
end

local function GetUnitInfo(unit)
	local specID, class, race
	if GladiusEx:IsTesting(unit) then
		specID = GladiusEx.testing[unit].specID
		class = GladiusEx.testing[unit].unitClass
		race = GladiusEx.testing[unit].unitRace
	elseif GladiusEx.buttons[unit] then
		specID = GladiusEx.buttons[unit].specID
		class = GladiusEx.buttons[unit].class or select(2, UnitClass(unit))
		race = select(2, UnitRace(unit))
	end
	return specID, class, race
end

local function GetUnitFaction(unit)
	if GladiusEx:IsTesting(unit) then
		return (UnitFactionGroup("player") == "Alliance" and GladiusEx:IsPartyUnit(unit)) and "Alliance" or "Horde"
	else
		return UnitFactionGroup(unit)
	end
end

local spell_list = {}
local unit_sorted_spells = {}
local function GetCooldownList(unit, group)
	local db = Cooldowns:GetGroupDB(unit, group)

	local specID, class, race = GetUnitInfo(unit)

	-- generate list of valid cooldowns for this unit
	wipe(spell_list)
	for spellid, spelldata in CT:IterateCooldowns(class, specID, race) do
		-- check if the spell is enabled by the user
		if db.cooldownsSpells[spellid] or (spelldata.replaces and db.cooldownsSpells[spelldata.replaces]) then
			local tracked = CT:GetUnitCooldownInfo(unit, spellid)
			-- check if the spell has a cooldown valid for an arena, and check if it is a talent that has not yet been detected
			if (not spelldata.cooldown or spelldata.cooldown < 600) and ((not spelldata.glyph and not spelldata.talent and not spelldata.pet and not spelldata.symbiosis) or (tracked and tracked.detected) or not db.cooldownsHideTalentsUntilDetected) then
				-- check if the spell requires an aura
				if not spelldata.requires_aura or UnitBuff(unit, spelldata.requires_aura_name) then
					if spelldata.replaces then
						-- remove replaced spell if detected
						spell_list[spelldata.replaces] = false
					end
					-- do not overwrite if this spell has been replaced
					if spell_list[spellid] == nil then
						spell_list[spellid] = true
					end
				end
			end
		end
	end

	-- sort spells
	unit_sorted_spells[unit] = unit_sorted_spells[unit] or {}
	unit_sorted_spells[unit][group] = unit_sorted_spells[unit][group] or {}
	local sorted_spells = unit_sorted_spells[unit][group]
	wipe(sorted_spells)
	for spellid, valid in pairs(spell_list) do
		if valid then
			tinsert(sorted_spells, spellid)
		end
	end

	tsort(sorted_spells,
		function(a, b)
			return GetSpellSortScore(unit, group, a) > GetSpellSortScore(unit, group, b)
		end)

	return sorted_spells
end

local function UpdateGroupIconFrames(unit, group, sorted_spells)
	local gs = Cooldowns:GetGroupState(unit, group)
	local db = Cooldowns:GetGroupDB(unit, group)

	local cat_priority = db.cooldownsCatPriority
	local border_colors = db.cooldownsCatColors
	local cooldownsPerColumn = db.cooldownsPerColumn

	local sidx = 1
	local shown = 0
	for i = 1, #sorted_spells do
		local icon_unit = type(sorted_spells[i]) == "table" and sorted_spells[i][1] or unit
		local spellid = type(sorted_spells[i]) == "table" and sorted_spells[i][2] or sorted_spells[i]
		local faction = GetUnitFaction(icon_unit)
		local spelldata = CT:GetCooldownData(spellid)
		local tracked = CT:GetUnitCooldownInfo(icon_unit, spellid)
		local frame = gs.frame[sidx]

		-- icon
		local icon
		if spelldata.icon_alliance and faction == "Alliance" then
			icon = spelldata.icon_alliance
		elseif spelldata.icon_horde and faction == "Horde" then
			icon = spelldata.icon_horde
		else
			icon = spelldata.icon
		end

		-- set border color
		local color
		for i = 1, #cat_priority do
			local key = cat_priority[i]
			if spelldata[key] then
				color = border_colors[key]
				break
			end
		end

		-- charges
		local charges
		if spelldata.charges then
			charges = (tracked and tracked.charges) or spelldata.charges
		elseif tracked and tracked.charges_detected then
			charges = tracked.charges or spelldata.opt_charges
		end

		-- update frame state
		frame.unit = icon_unit
		frame.spellid = spellid
		frame.spelldata = spelldata
		frame.state = 0
		frame.tracked = tracked
		frame.color = color or border_colors["uncat"]

		-- refresh frame
		frame.icon:SetTexture(icon)
		frame:SetScript("OnUpdate", CooldownFrame_OnUpdate)
		frame.count:SetText(charges)
		frame:Show()

		sidx = sidx + 1
		shown = shown + 1
		if sidx > #gs.frame or shown >= db.cooldownsMax then
			break
		end
	end

	-- hide unused icons
	for i = sidx, #gs.frame do
		gs.frame[i]:Hide()
	end
end

function Cooldowns:UpdateGroupIcons(unit, group)
	local gs = self:GetGroupState(unit, group)
	local db = Cooldowns:GetGroupDB(unit, group)

	-- get spells lists
	local sorted_spells = GetCooldownList(unit, group)

	-- update icon frames
	if db.cooldownsDetached then
		local header_unit = GetHeaderUnit(unit)
		local header_gs = self:GetGroupState(header_unit, group)

		-- save detached group spells
		local index = GladiusEx:GetUnitIndex(unit)
		header_gs.unit_spells = header_gs.unit_spells or { ["unit"] = unit }
		header_gs.unit_spells[index] = sorted_spells

		-- make list of the spells of all the units
		local detached_spells = {}
		for i = 1, 5 do
			local us = header_gs.unit_spells[i]
			if us then
				local dunit = us.unit
				for j = 1, #us do
					tinsert(detached_spells, { dunit, us[j] })
				end
			end
		end

		-- sort the list
		if not db.cooldownsGroupByUnit then
			tsort(detached_spells,
				function(a, b)
					return GetSpellSortScore(unit, group, a[2]) > GetSpellSortScore(unit, group, b[2])
				end)
		end

		UpdateGroupIconFrames(header_unit, group, detached_spells)
	else
		UpdateGroupIconFrames(unit, group, sorted_spells)
	end
end

local function CreateCooldownFrame(name, parent)
	local frame = CreateFrame("Frame", name, parent)

	frame.icon_frame = CreateFrame("Frame", nil, frame)
	frame.icon_frame:SetAllPoints()

	frame.icon = frame.icon_frame:CreateTexture(nil, "BACKGROUND") -- bg
	frame.icon:SetPoint("CENTER")

	frame.cooldown = CreateFrame("Cooldown", nil, frame.icon_frame)
	frame.cooldown:SetAllPoints(frame.icon)
	frame.cooldown:SetReverse(true)
	frame.cooldown:Hide()

	frame.count = frame.icon_frame:CreateFontString(nil, "OVERLAY")
	frame.count:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.base.globalFont), 10, "OUTLINE")
	frame.count:SetTextColor(1, 1, 1, 1)
	frame.count:SetPoint("BOTTOMRIGHT", 2, 0)
	frame.count:Show()

	return frame
end

function Cooldowns:CreateFrame(unit)
	for group = 1, self:GetNumGroups(unit) do
		self:CreateGroupFrame(unit, group)
	end
end

function Cooldowns:CreateGroupFrame(unit, group)
	local button = GladiusEx.buttons[unit]
	if not button then return end

	local gs = self:GetGroupState(unit, group)

	-- create cooldown frame
	if not gs.frame then
		gs.frame = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. "frame" .. unit, button)
		gs.frame:EnableMouse(false)

		for i = 1, MAX_ICONS do
			gs.frame[i] = CreateCooldownFrame("GladiusEx" .. self:GetName() .. "frameIcon" .. i .. unit, gs.frame)
			gs.frame[i]:SetScript("OnUpdate", CooldownFrame_OnUpdate)
			gs.frame[i].group = group
		end
	end
end

local function UpdateCooldownFrame(frame, size, border_size, crop)
	frame:SetSize(size, size)
	if border_size ~= 0 then
		frame:SetBackdrop({ edgeFile = [[Interface\ChatFrame\ChatFrameBackground]], edgeSize = border_size })
		frame.icon:SetSize(size - border_size * 2, size - border_size * 2)
	else
		frame:SetBackdrop(nil)
		frame.icon:SetSize(size, size)
	end

	if crop then
		local n = 5
		frame.icon:SetTexCoord(n / 64, 1 - n / 64, n / 64, 1 - n / 64)
	else
		frame.icon:SetTexCoord(0, 1, 0, 1)
	end
end

function Cooldowns:SaveAnchorPosition(unit, group)
	local db = self:GetGroupDB(unit, group)
	local gs = self:GetGroupState(unit, group)
	local anchor = gs.anchor
	local scale = anchor:GetEffectiveScale() or 1
	db.cooldownsAnchorX = (anchor:GetLeft() or 0) * scale
	db.cooldownsAnchorY = (anchor:GetTop() or 0) * scale
end

function Cooldowns:CreateGroupAnchor(unit, group)
	local db = self:GetGroupDB(unit, group)
	local gs = self:GetGroupState(unit, group)

	-- anchor
	local anchor = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. unit .. "Group" .. group .. "Anchor", UIParent)
	anchor:SetScript("OnMouseDown", function(f, button)
		if button == "LeftButton" then
			if IsShiftKeyDown() then
				-- center horizontally
				anchor:ClearAllPoints()
				anchor:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, f:GetBottom())
				self:SaveAnchorPosition(unit, group)
			elseif IsAltKeyDown() then
				-- center vertically
				anchor:ClearAllPoints()
				anchor:SetPoint("LEFT", UIParent, "LEFT", f:GetLeft(), 0)
				self:SaveAnchorPosition(unit, group)
			end
		elseif button == "RightButton" then
			GladiusEx:ShowOptionsDialog()
		end
	end)

	anchor:SetScript("OnDragStart", function(f)
		anchor:StartMoving()
	end)

	anchor:SetScript("OnDragStop", function(f)
		anchor:StopMovingOrSizing()
		self:SaveAnchorPosition(unit, group)
	end)

	anchor.text = anchor:CreateFontString(nil, "OVERLAY")
	anchor.text2 = anchor:CreateFontString(nil, "OVERLAY")

	gs.anchor = anchor
end

function Cooldowns:UpdateGroupAnchor(unit, group)
	local db = self:GetGroupDB(unit, group)
	local gs = self:GetGroupState(unit, group)

	if not gs.anchor then
		self:CreateGroupAnchor(unit, group)
	end

	local anchor = gs.anchor

	-- update anchor
	local anchor_width = 200
	local anchor_height = 40

	anchor:ClearAllPoints()
	anchor:SetSize(anchor_width, anchor_height)
	anchor:SetScale(GladiusEx.db[unit].frameScale)

	if not db.cooldownsAnchorX or not db.cooldownsAnchorY then
		anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	else
		local eff = anchor:GetEffectiveScale()
		anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", db.cooldownsAnchorX / eff, db.cooldownsAnchorY / eff)
	end

	anchor:SetBackdrop({
		edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = GladiusEx:AdjustPixels(anchor, max(1, floor(GladiusEx.db[unit].frameScale + 0.5))),
		bgFile = [[Interface\Buttons\WHITE8X8]], tile = true, tileSize = 8,
	})
	anchor:SetBackdropColor(0, 0, 0, 1)
	anchor:SetBackdropBorderColor(1, 1, 1, 1)
	anchor:SetFrameLevel(200)
	anchor:SetFrameStrata("MEDIUM")

	anchor:SetClampedToScreen(true)
	anchor:EnableMouse(true)
	anchor:SetMovable(true)
	anchor:RegisterForDrag("LeftButton")

	-- anchor texts
	anchor.text:SetPoint("TOP", anchor, "TOP", 0, -7)
	anchor.text:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.base.globalFont), 11, GladiusEx.db.base.globalFontOutline)
	anchor.text:SetTextColor(1, 1, 1, 1)
	anchor.text:SetShadowOffset(1, -1)
	anchor.text:SetShadowColor(0, 0, 0, 1)
	anchor.text:SetText(string.format(L["Group %i anchor (%s)"], group, GladiusEx:IsPartyUnit(unit) and L["Party"] or L["Arena"]))

	anchor.text2:SetPoint("BOTTOM", anchor, "BOTTOM", 0, 7)
	anchor.text2:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.base.globalFont), 11, GladiusEx.db.base.globalFontOutline)
	anchor.text2:SetTextColor(1, 1, 1, 1)
	anchor.text2:SetShadowOffset(1, -1)
	anchor.text2:SetShadowColor(0, 0, 0, 1)
	anchor.text2:SetText(L["Lock the group to hide"])

	anchor:Hide()
end

local function UpdateCooldownGroup(
	unit,
	cooldownFrame,
	cooldownBackground,
	cooldownParent,
	cooldownAnchor,
	cooldownRelativePoint,
	cooldownOffsetX,
	cooldownOffsetY,
	cooldownPerColumn,
	cooldownGrow,
	cooldownSize,
	cooldownBorderSize,
	cooldownPaddingX,
	cooldownPaddingY,
	cooldownSpacingX,
	cooldownSpacingY,
	cooldownMax,
	cooldownCrop,
	cooldownTooltips)

	-- anchor point
	local parent = cooldownParent

	-- local xo, yo = GladiusEx:AdjustFrameOffset(parent, cooldownRelativePoint)
	local xo, yo = 0, 0
	cooldownPaddingX = GladiusEx:AdjustPositionOffset(parent, cooldownPaddingX)
	cooldownPaddingY = GladiusEx:AdjustPositionOffset(parent, cooldownPaddingY)
	cooldownSpacingX = GladiusEx:AdjustPositionOffset(parent, cooldownSpacingX)
	cooldownSpacingY = GladiusEx:AdjustPositionOffset(parent, cooldownSpacingY)
	cooldownOffsetX = GladiusEx:AdjustPositionOffset(parent, cooldownOffsetX) + xo
	cooldownOffsetY = GladiusEx:AdjustPositionOffset(parent, cooldownOffsetY) + yo
	cooldownSize = GladiusEx:AdjustPositionOffset(parent, cooldownSize)
	cooldownBorderSize = GladiusEx:AdjustPixels(parent, cooldownBorderSize)

	cooldownFrame:ClearAllPoints()
	cooldownFrame:SetPoint(cooldownAnchor, parent, cooldownRelativePoint, cooldownOffsetX, cooldownOffsetY)
	cooldownFrame:SetFrameLevel(61)

	-- size
	cooldownFrame:SetWidth(cooldownSize * cooldownPerColumn + cooldownSpacingX * (cooldownPerColumn - 1) + cooldownPaddingX * 2)
	cooldownFrame:SetHeight(cooldownSize * ceil(cooldownMax / cooldownPerColumn) + (cooldownSpacingY * (ceil(cooldownMax / cooldownPerColumn) - 1)) + cooldownPaddingY * 2)

	-- backdrop
	cooldownFrame:SetBackdrop({ bgFile = [[Interface\Buttons\WHITE8X8]], tile = true, tileSize = 16 })
	cooldownFrame:SetBackdropColor(cooldownBackground.r, cooldownBackground.g, cooldownBackground.b, cooldownBackground.a)

	-- icon points
	local anchor, parent, relativePoint, offsetX, offsetY

	-- grow anchor
	local grow1, grow2, grow3, startRelPoint
	if cooldownGrow == "DOWNRIGHT" then
		grow1, grow2, grow3, startRelPoint = "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT", "TOPLEFT"
	elseif cooldownGrow == "DOWNLEFT" then
		grow1, grow2, grow3, startRelPoint = "TOPRIGHT", "BOTTOMRIGHT", "TOPLEFT", "TOPRIGHT"
	elseif cooldownGrow == "UPRIGHT" then
		grow1, grow2, grow3, startRelPoint = "BOTTOMLEFT", "TOPLEFT", "BOTTOMRIGHT", "BOTTOMLEFT"
	elseif cooldownGrow == "UPLEFT" then
		grow1, grow2, grow3, startRelPoint = "BOTTOMRIGHT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"
	end

	local grow_left = string.find(cooldownGrow, "LEFT")
	local grow_down = string.find(cooldownGrow, "DOWN")

	local start, startAnchor = 1, cooldownFrame
	for i = 1, #cooldownFrame do
		if cooldownMax >= i then
			if start == 1 then
				anchor, parent, relativePoint = grow1, startAnchor, startRelPoint
				offsetX = i == 1 and (grow_left and -cooldownPaddingX or cooldownPaddingX) or 0
				offsetY = i == 1 and (grow_down and -cooldownPaddingY or cooldownPaddingY) or (grow_down and -cooldownSpacingY or cooldownSpacingY)
			else
				anchor, parent, relativePoint = grow1, cooldownFrame[i - 1], grow3
				offsetX = grow_left and -cooldownSpacingX or cooldownSpacingX
				offsetY = 0
			end

			if start == cooldownPerColumn then
				start = 0
				startAnchor = cooldownFrame[i - cooldownPerColumn + 1]
				startRelPoint = grow2
			end

			start = start + 1
		end

		cooldownFrame[i]:ClearAllPoints()
		cooldownFrame[i]:SetPoint(anchor, parent, relativePoint, offsetX, offsetY)

		if cooldownTooltips then
			cooldownFrame[i]:SetScript("OnEnter", function(self)
				if self.spellid then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetSpellByID(self.spellid)
				end
			end)
			cooldownFrame[i]:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
			cooldownFrame[i]:EnableMouse(true)
		else
			cooldownFrame[i]:SetScript("OnEnter", nil)
			cooldownFrame[i]:SetScript("OnLeave", nil)
			cooldownFrame[i]:EnableMouse(false)
		end

		UpdateCooldownFrame(cooldownFrame[i], cooldownSize, cooldownBorderSize, cooldownCrop)
	end
end

function Cooldowns:Update(unit)
	for group = 1, self:GetNumGroups(unit) do
		self:UpdateGroup(unit, group)
	end
	-- hide excess groups after one is deleted
	local group_state = unit_state[unit]
	for group = self:GetNumGroups(unit) + 1, #group_state do
		if group_state[group].frame then
			group_state[group].frame:Hide()
		end
		if group_state[group].anchor then
			group_state[group].anchor:Hide()
		end
	end
end

function Cooldowns:Refresh(unit)
	self:UpdateIcons(unit)
end

function Cooldowns:UpdateGroup(unit, group)
	local db = self:GetGroupDB(unit, group)
	local gs = self:GetGroupState(unit, group)

	if not db.cooldownsDetached or IsHeaderUnit(unit) then
		-- create frame
		self:CreateGroupFrame(unit, group)

		-- update anchor
		if db.cooldownsDetached then
			self:UpdateGroupAnchor(unit, group)
			if db.cooldownsLocked then
				gs.anchor:Hide()
			else
				gs.anchor:Show()
			end
		end

		-- update cooldown frame
		UpdateCooldownGroup(unit,
			gs.frame,
			db.cooldownsBackground,
			db.cooldownsDetached and gs.anchor or GladiusEx:GetAttachFrame(unit, db.cooldownsAttachTo),
			db.cooldownsAnchor,
			db.cooldownsRelativePoint,
			db.cooldownsOffsetX,
			db.cooldownsOffsetY,
			db.cooldownsPerColumn,
			db.cooldownsGrow,
			db.cooldownsSize,
			db.cooldownsBorderSize,
			db.cooldownsPaddingX,
			db.cooldownsPaddingY,
			db.cooldownsSpacingX,
			db.cooldownsSpacingY,
			db.cooldownsMax,
			db.cooldownsCrop,
			db.cooldownsTooltips)
	elseif gs.frame then
		gs.frame:SetSize(0, 0)
	end

	-- update icons
	self:UpdateGroupIcons(unit, group)

	-- hide group
	if gs.frame then
		gs.frame:Hide()
	end
end

local ct_registered = {}

function Cooldowns:Show(unit)
	for group = 1, self:GetNumGroups(unit) do
		local gs = self:GetGroupState(unit, group)
		local db = self:GetGroupDB(unit, group)

		if not ct_registered[unit] then
			CT:RegisterUnit(unit)
			ct_registered[unit] = true
		end

		if gs.frame and (not db.cooldownsDetached or IsHeaderUnit(unit)) then
			gs.frame:Show()
		end
	end
end

function Cooldowns:Reset(unit)
	for group = 1, self:GetNumGroups(unit) do
		local gs = self:GetGroupState(unit, group)
		local db = self:GetGroupDB(unit, group)

		if ct_registered[unit] then
			CT:UnregisterUnit(unit)
			ct_registered[unit] = false
		end

		if db.cooldownsDetached then
			local header_gs = self:GetGroupState(GetHeaderUnit(unit), group)
			if header_gs.unit_spells then
				local index = GladiusEx:GetUnitIndex(unit)
				header_gs.unit_spells[index] = nil
			end
		end

		if gs.frame then
			-- hide cooldown frame
			gs.frame:Hide()
		end
	end
end

function Cooldowns:Test(unit)
	self:UpdateIcons(unit)
end

function Cooldowns:GetOptions(unit)
	local options = {}

	options.sep = {
		type = "description",
		name = "",
		width = "full",
		order = 1,
	}
	options.addgroup = {
		type = "execute",
		name = L["Add cooldowns group"],
		desc = L["Add cooldowns group"],
		func = function()
			local gdb = MakeGroupDb({
				cooldownsGroupId = self:MakeGroupId(),
				cooldownsSpells = { [42292] = true },
			})
			local group_idx = self:AddGroup(unit, gdb)
			options["group" .. group_idx] = self:MakeGroupOptions(unit, group_idx)
			GladiusEx:UpdateFrames()
		end,
		disabled = function() return not self:IsUnitEnabled(unit) end,
		order = 2,
	}

	--[[
	options.help = {
		type = "group",
		name = L["Help"],
		order = 3,
		args = {
		}
	}
	]]

	-- setup groups
	for group = 1, self:GetNumGroups(unit) do
		options["group" .. group] = self:MakeGroupOptions(unit, group)
	end

	return options
end

local FormatSpellDescription

function Cooldowns:MakeGroupOptions(unit, group)
	local function getOption(info)
		return (info.arg and self:GetGroupDB(unit, group)[info.arg] or self:GetGroupDB(unit, group)[info[#info]])
	end

	local function setOption(info, value)
		local key = info[#info]
		self:GetGroupDB(unit, group)[key] = value
		GladiusEx:UpdateFrames()
	end

	local group_options = {
		type = "group",
		name = L["Group"] .. " " .. group,
		childGroups = "tab",
		order = 10 + group,
		hidden = function() return self:GetNumGroups(unit) < group end,
		get = getOption,
		set = setOption,
		args = {
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
							cooldownsBackground = {
								type = "color",
								name = L["Background color"],
								desc = L["Color of the frame background"],
								hasAlpha = true,
								get = function(info) return GladiusEx:GetColorOption(self:GetGroupDB(unit, group), info) end,
								set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self:GetGroupDB(unit, group), info, r, g, b, a) end,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 1,
							},
							sep = {
								type = "description",
								name = "",
								width = "full",
								order = 13,
							},
							cooldownsCrop = {
								type = "toggle",
								name = L["Crop borders"],
								desc = L["Toggle if the icon borders should be cropped or not"],
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 14,
							},
							cooldownsTooltips = {
								type = "toggle",
								name = L["Show tooltips"],
								desc = L["Toggle if the icons should show the spell tooltip when hovered"],
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 15,
							},
							sep2 = {
								type = "description",
								name = "",
								width = "full",
								order = 18,
							},
							cooldownsPerColumn = {
								type = "range",
								name = L["Icons per column"],
								desc = L["Number of icons per column"],
								min = 1, max = MAX_ICONS, step = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 19,
							},
							cooldownsMax = {
								type = "range",
								name = L["Icons max"],
								desc = L["Number of max icons"],
								min = 1, max = MAX_ICONS, step = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 20,
							},
							sep3 = {
								type = "description",
								name = "",
								width = "full",
								order = 23,
							},
							remgroup = {
								type = "execute",
								name = L["Remove this cooldowns group"],
								desc = L["Remove this cooldowns group"],
								width = "double",
								func = function()
									self:RemoveGroup(unit, group)
									GladiusEx:UpdateFrames()
								end,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 244,
							},
						},
					},
					icon_transparency = {
						type = "group",
						name = L["Icon transparency"],
						desc = L["Icon transparency settings"],
						inline = true,
						order = 1.1,
						args = {
							cooldownsIconAvailAlpha = {
								type = "range",
								name = L["Available"],
								desc = L["Alpha of the icon while the spell is not on cooldown"],
								min = 0, max = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 1,
							},
							cooldownsIconUsingAlpha = {
								type = "range",
								name = L["Active"],
								desc = L["Alpha of the icon while the spell is being used"],
								min = 0, max = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 2,
							},
							cooldownsIconCooldownAlpha = {
								type = "range",
								name = L["On cooldown"],
								desc = L["Alpha of the icon while the spell is on cooldown"],
								min = 0, max = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 3,
							},
							sep = {
								type = "description",
								name = "",
								width = "full",
								order = 4,
							},
						},
					},
					border_transparency = {
						type = "group",
						name = L["Border transparency"],
						desc = L["Border transparency settings"],
						inline = true,
						order = 1.2,
						args = {
							cooldownsBorderAvailAlpha = {
								type = "range",
								name = L["Available"],
								desc = L["Alpha of the icon border while the spell is not on cooldown"],
								min = 0, max = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 1,
							},
							cooldownsBorderUsingAlpha = {
								type = "range",
								name = L["Active"],
								desc = L["Alpha of the icon border while the spell is being used"],
								min = 0, max = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 2,
							},
							cooldownsBorderCooldownAlpha = {
								type = "range",
								name = L["On cooldown"],
								desc = L["Alpha of the icon border while the spell is on cooldown"],
								min = 0, max = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 3,
							},
							sep = {
								type = "description",
								name = "",
								width = "full",
								order = 4,
							},
						},
					},
					size = {
						type = "group",
						name = L["Size"],
						desc = L["Size settings"],
						inline = true,
						order = 2,
						args = {
							cooldownsSize = {
								type = "range",
								name = L["Icon size"],
								desc = L["Size of the cooldown icons"],
								min = 1, softMin = 10, softMax = 100, step = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 5,
							},
							cooldownsBorderSize = {
								type = "range",
								name = L["Icon border size"],
								desc = L["Size of the cooldown icon borders"],
								min = 0, softMin = 0, softMax = 10, step = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 6,
							},
							sep = {
								type = "description",
								name = "",
								width = "full",
								order = 13,
							},
							cooldownsPaddingY = {
								type = "range",
								name = L["Vertical padding"],
								desc = L["Vertical padding of the icons"],
								min = 0, softMax = 30, step = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 15,
							},
							cooldownsPaddingX = {
								type = "range",
								name = L["Horizontal padding"],
								desc = L["Horizontal padding of the icons"],
								disabled = function() return not self:IsUnitEnabled(unit) end,
								min = 0, softMax = 30, step = 1,
								order = 20,
							},
							sep2 = {
								type = "description",
								name = "",
								width = "full",
								order = 23,
							},
							cooldownsSpacingY = {
								type = "range",
								name = L["Vertical spacing"],
								desc = L["Vertical spacing of the icons"],
								min = 0, softMax = 30, step = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 25,
							},
							cooldownsSpacingX = {
								type = "range",
								name = L["Horizontal spacing"],
								desc = L["Horizontal spacing of the icons"],
								disabled = function() return not self:IsUnitEnabled(unit) end,
								min = 0, softMax = 30, step = 1,
								order = 30,
							},
						},
					},
					position = {
						type = "group",
						name = L["Position"],
						desc = L["Position settings"],
						inline = true,
						order = 4,
						args = {
							cooldownsDetached = {
								type = "toggle",
								name = L["Detached group"],
								desc = L["Detach the group from the unit frames, showing the cooldowns of all the units and allowing you to move it freely"],
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 1,
							},
							cooldownsLocked = {
								type = "toggle",
								name = L["Locked"],
								desc = L["Toggle if the detached group can be moved"],
								disabled = function() return not self:IsUnitEnabled(unit) or not self:GetGroupDB(unit, group).cooldownsDetached end,
								order = 2,
							},
							cooldownsGroupByUnit = {
								type = "toggle",
								name = L["Group by unit"],
								desc = L["Toggle if the cooldowns in the detached group should be grouped by unit"],
								disabled = function() return not self:IsUnitEnabled(unit) or not self:GetGroupDB(unit, group).cooldownsDetached end,
								order = 3,
							},
							sep = {
								type = "description",
								name = "",
								width = "full",
								order = 9,
							},

							cooldownsAttachTo = {
								type = "select",
								name = L["Attach to"],
								desc = L["Attach to the given frame"],
								values = function() return self:GetOtherAttachPoints(unit) end,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								hidden = function() return self:GetGroupDB(unit, group).cooldownsDetached end,
								order = 10,
							},
							cooldownsPosition = {
								type = "select",
								name = L["Position"],
								desc = L["Position of the frame"],
								values = GladiusEx:GetGrowSimplePositions(),
								get = function()
									return GladiusEx:GrowSimplePositionFromAnchor(
										self:GetGroupDB(unit, group).cooldownsAnchor,
										self:GetGroupDB(unit, group).cooldownsRelativePoint,
										self:GetGroupDB(unit, group).cooldownsGrow)
								end,
								set = function(info, value)
									self:GetGroupDB(unit, group).cooldownsAnchor, self:GetGroupDB(unit, group).cooldownsRelativePoint =
										GladiusEx:AnchorFromGrowSimplePosition(value, self:GetGroupDB(unit, group).cooldownsGrow)
									GladiusEx:UpdateFrames()
								end,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								hidden = function() return GladiusEx.db.base.advancedOptions end,
								order = 11,
							},
							cooldownsGrow = {
								type = "select",
								name = L["Grow direction"],
								desc = L["Grow direction of the icons"],
								values = {
										["UPLEFT"] = L["Up left"],
										["UPRIGHT"] = L["Up right"],
										["DOWNLEFT"] = L["Down left"],
										["DOWNRIGHT"] = L["Down right"],
								},
								set = function(info, value)
									if not GladiusEx.db.base.advancedOptions then
										self:GetGroupDB(unit, group).cooldownsAnchor, self:GetGroupDB(unit, group).cooldownsRelativePoint =
											GladiusEx:AnchorFromGrowDirection(
												self:GetGroupDB(unit, group).cooldownsAnchor,
												self:GetGroupDB(unit, group).cooldownsRelativePoint,
												self:GetGroupDB(unit, group).cooldownsGrow,
												value)
									end
									self:GetGroupDB(unit, group).cooldownsGrow = value
									GladiusEx:UpdateFrames()
								end,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 13,
							},
							sep2 = {
								type = "description",
								name = "",
								width = "full",
								order = 17,
							},
							cooldownsAnchor = {
								type = "select",
								name = L["Anchor"],
								desc = L["Anchor of the frame"],
								values = GladiusEx:GetPositions(),
								disabled = function() return not self:IsUnitEnabled(unit) end,
								hidden = function() return not GladiusEx.db.base.advancedOptions end,
								order = 20,
							},
							cooldownsRelativePoint = {
								type = "select",
								name = L["Relative point"],
								desc = L["Relative point of the frame"],
								values = GladiusEx:GetPositions(),
								disabled = function() return not self:IsUnitEnabled(unit) end,
								hidden = function() return not GladiusEx.db.base.advancedOptions end,
								order = 25,
							},
							sep3 = {
								type = "description",
								name = "",
								width = "full",
								order = 27,
							},
							cooldownsOffsetX = {
								type = "range",
								name = L["Offset X"],
								desc = L["X offset of the frame"],
								softMin = -100, softMax = 100, bigStep = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 30,
							},
							cooldownsOffsetY = {
								type = "range",
								name = L["Offset Y"],
								desc = L["Y offset of the frame"],
								disabled = function() return not self:IsUnitEnabled(unit) end,
								softMin = -100, softMax = 100, bigStep = 1,
								order = 35,
							},
						},
					},
				},
			},
			category_options = {
				type = "group",
				name = L["Category"],
				order = 2,
				args = {
				},
			},
			cooldowns = {
				type = "group",
				name = function()
					local count = 0
					local cooldownsSpells = self:GetGroupDB(unit, group).cooldownsSpells
					for spellid in pairs(CT:GetCooldownsData()) do
						if cooldownsSpells[spellid] then count = count + 1 end
					end
					return string.format("%s [%i]", L["Cooldowns"], count)
				end,
				order = 3,
				args = {
					cooldownsHideTalentsUntilDetected = {
						type = "toggle",
						name = L["Hide talents until detected"],
						disabled = function() return not self:IsUnitEnabled(unit) end,
						width = "double",
						order = nil,
					},
					enableall = {
						type = "execute",
						name = L["Enable all"],
						desc = L["Enable all the spells"],
						func = function()
							for spellid, spelldata in pairs(CT:GetCooldownsData()) do
								if type(spelldata) == "table" then
									self:GetGroupDB(unit, group).cooldownsSpells[spellid] = true
								end
							end
							GladiusEx:UpdateFrames()
						end,
						disabled = function() return not self:IsUnitEnabled(unit) end,
						order = 0.2,
					},
					disableall = {
						type = "execute",
						name = L["Disable all"],
						desc = L["Disable all the spells"],
						func = function()
							for spellid, spelldata in pairs(CT:GetCooldownsData()) do
								if type(spelldata) == "table" then
									self:GetGroupDB(unit, group).cooldownsSpells[spellid] = false
								end
							end
							GladiusEx:UpdateFrames()
						end,
						disabled = function() return not self:IsUnitEnabled(unit) end,
						order = 0.5,
					},
					preracesep = {
						type = "group",
						name = "",
						order = 2,
						args = {}
					},
					preitemsep = {
						type = "group",
						name = "",
						order = 4,
						args = {}
					},
				},
			},
		},
	}

	-- fill category list
	local pargs = group_options.args.category_options.args
	for i = 1, #(self:GetGroupDB(unit, group).cooldownsCatPriority) do
		local cat = self:GetGroupDB(unit, group).cooldownsCatPriority[i]
		local option = {
			type = "group",
			name = L["cat:" .. cat],
			order = function()
				for i = 1, #(self:GetGroupDB(unit, group).cooldownsCatPriority) do
					if self:GetGroupDB(unit, group).cooldownsCatPriority[i] == cat then return i end
				end
			end,
			args = {
				header = {
					type = "description",
					name = L["cat:" .. cat],
					order = 1,
				},
				color = {
					type = "color",
					name = L["Color"],
					desc = L["Border color for spells in this category"],
					get = function()
						local c = self:GetGroupDB(unit, group).cooldownsCatColors[cat]
						return c.r, c.g, c.b
					end,
					set = function(info, r, g, b)
						self:GetGroupDB(unit, group).cooldownsCatColors[cat] = { r = r, g = g, b = b }
						GladiusEx:UpdateFrames()
					end,
					disabled = function() return not self:IsUnitEnabled(unit) end,
					order = 2,
				},
				sep = {
					type = "description",
					name = "",
					width = "full",
					order = 5,
				},
				moveup = {
					type = "execute",
					name = L["Up"],
					desc = L["Increase the priority of spells in this category"],
					func = function()
						for i = 1, #self:GetGroupDB(unit, group).cooldownsCatPriority do
							if self:GetGroupDB(unit, group).cooldownsCatPriority[i] == cat then
								if i ~= 1 then
									local tmp = self:GetGroupDB(unit, group).cooldownsCatPriority[i - 1]
									self:GetGroupDB(unit, group).cooldownsCatPriority[i - 1] = self:GetGroupDB(unit, group).cooldownsCatPriority[i]
									self:GetGroupDB(unit, group).cooldownsCatPriority[i] = tmp

									self:SpellSortingChanged()
									GladiusEx:UpdateFrames()
								end
								return
							end
						end
					end,
					disabled = function() return not self:IsUnitEnabled(unit) end,
					order = 10,
				},
				movedown = {
					type = "execute",
					name = L["Down"],
					desc = L["Decrease the priority of spells in this category"],
					func = function()
						for i = 1, #self:GetGroupDB(unit, group).cooldownsCatPriority do
							if self:GetGroupDB(unit, group).cooldownsCatPriority[i] == cat then
								if i ~= #self:GetGroupDB(unit, group).cooldownsCatPriority then
									local tmp = self:GetGroupDB(unit, group).cooldownsCatPriority[i + 1]
									self:GetGroupDB(unit, group).cooldownsCatPriority[i + 1] = self:GetGroupDB(unit, group).cooldownsCatPriority[i]
									self:GetGroupDB(unit, group).cooldownsCatPriority[i] = tmp

									self:SpellSortingChanged()
									GladiusEx:UpdateFrames()
								end
								return
							end
						end
					end,
					disabled = function() return not self:IsUnitEnabled(unit) end,
					order = 11,
				},
				enableall = {
					type = "execute",
					name = L["Enable all"],
					desc = L["Enable all the spells in this category"],
					func = function()
						for spellid, spelldata in pairs(CT:GetCooldownsData()) do
							if type(spelldata) == "table" then
								if spelldata[cat] then
									self:GetGroupDB(unit, group).cooldownsSpells[spellid] = true
								end
							end
						end
						GladiusEx:UpdateFrames()
					end,
					disabled = function() return not self:IsUnitEnabled(unit) end,
					order = 20,
				},
				disableall = {
					type = "execute",
					name = L["Disable all"],
					desc = L["Disable all the spells in this category"],
					func = function()
						for spellid, spelldata in pairs(CT:GetCooldownsData()) do
							if type(spelldata) == "table" then
								if spelldata[cat] then
									self:GetGroupDB(unit, group).cooldownsSpells[spellid] = false
								end
							end
						end
						GladiusEx:UpdateFrames()
					end,
					disabled = function() return not self:IsUnitEnabled(unit) end,
					order = 21,
				},
			}
		}
		pargs[cat] = option
	end


	-- fill spell list
	local function getSpell(info)
		return self:GetGroupDB(unit, group).cooldownsSpells[info.arg]
	end

	local function setSpell(info, value)
		self:GetGroupDB(unit, group).cooldownsSpells[info.arg] = value
		GladiusEx:UpdateFrames()
	end

	local args = group_options.args.cooldowns.args
	for spellid, spelldata in pairs(CT:GetCooldownsData()) do
		if type(spelldata) == "table" and (not spelldata.cooldown or spelldata.cooldown < 600) then
			local cats = {}
			if spelldata.pvp_trinket then tinsert(cats, L["cat:pvp_trinket"]) end
			if spelldata.cc then tinsert(cats, L["cat:cc"]) end
			if spelldata.offensive then tinsert(cats, L["cat:offensive"]) end
			if spelldata.defensive then tinsert(cats, L["cat:defensive"]) end
			if spelldata.silence then tinsert(cats, L["cat:silence"]) end
			if spelldata.interrupt then tinsert(cats, L["cat:interrupt"]) end
			if spelldata.dispel then tinsert(cats, L["cat:dispel"]) end
			if spelldata.mass_dispel then tinsert(cats, L["cat:mass_dispel"]) end
			if spelldata.heal then tinsert(cats, L["cat:heal"]) end
			if spelldata.knockback then tinsert(cats, L["cat:knockback"]) end
			if spelldata.stun then tinsert(cats, L["cat:stun"]) end
			if spelldata.immune then tinsert(cats, L["cat:immune"]) end
			local catstr
			if #cats > 0 then
				catstr = "|cff7f7f7f(" .. strjoin(", ", unpack(cats)) .. ")|r"
			end

			if GladiusEx:IsDebugging() then
				local basecd = GetSpellBaseCooldown(spellid)
				if basecd and basecd / 1000 ~= spelldata.cooldown then
					local str = string.format("%s: |T%s:20|t %s [%ss/Base: %ss] %s", spelldata.class, spelldata.icon, spelldata.name, spelldata.cooldown or "??", basecd and basecd/1000 or "??", catstr or "")
					if not self.debuglog then self.debuglog = {} end
					if not self.debuglog[str] then
						self.debuglog[str] = true
						GladiusEx:Log(str)
					end
				end
			end

			local namestr = string.format(L[" |T%s:20|t %s [%ss] %s"], spelldata.icon, spelldata.name, spelldata.cooldown or "??", catstr or "")

			local function MakeSpellDesc()
				local spelldesc = FormatSpellDescription(spellid)
				local extradesc = {}
				if spelldata.duration then table.insert(extradesc, string.format(L["Duration: %is"], spelldata.duration)) end
				if spelldata.replaces then table.insert(extradesc, string.format(L["Replaces: %s"], GetSpellInfo(spelldata.replaces))) end
				if spelldata.requires_aura then table.insert(extradesc, string.format(L["Required aura: %s"], GetSpellInfo(spelldata.requires_aura))) end
				if spelldata.sets_cooldown then table.insert(extradesc, string.format(L["Shared cooldown: %s (%is)"], GetSpellInfo(spelldata.sets_cooldown.spellid), spelldata.sets_cooldown.cooldown)) end
				if spelldata.cooldown_starts_on_aura_fade then table.insert(extradesc, L["Cooldown starts when aura fades"]) end
				if spelldata.cooldown_starts_on_dispel then table.insert(extradesc, L["Cooldown starts on dispel"]) end
				local SYMBIOSIS_SPELLID = 110309
				if spelldata.symbiosis then table.insert(extradesc, "|cff00ff00" .. GetSpellInfo(SYMBIOSIS_SPELLID)) end
				if spelldata.resets then table.insert(extradesc, string.format(L["Resets: %s"], table.concat(fn.sort(fn.map(spelldata.resets, GetSpellInfo)), ", "))) end
				if spelldata.charges then table.insert(extradesc, string.format(L["Charges: %i"], spelldata.charges)) end
				if #extradesc > 0 then
					spelldesc = spelldesc .. "\n|cff9f9f9f" .. table.concat(fn.sort(extradesc), "\n|cff9f9f9f")
				end
				return spelldesc
			end

			local spellconfig = {
				type = "toggle",
				name = namestr,
				desc = GladiusEx:IsDebugging() and MakeSpellDesc() or MakeSpellDesc,
				descStyle = "inline",
				width = "full",
				arg = spellid,
				get = getSpell,
				set = setSpell,
				disabled = function() return not self:IsUnitEnabled(unit) end,
				order = spelldata.name:byte(1) * 0xff + spelldata.name:byte(2),
			}
			if spelldata.class then
				if not args[spelldata.class] then
					args[spelldata.class] = {
						type = "group",
						name = LOCALIZED_CLASS_NAMES_MALE[spelldata.class],
						icon = [[Interface\ICONS\ClassIcon_]] .. spelldata.class,
						disabled = function() return not self:IsUnitEnabled(unit) end,
						order = 1,
						args = {}
					}
				end
				if spelldata.specID then
					-- spec
					for _, specID in ipairs(spelldata.specID) do
						if not args[spelldata.class].args["spec" .. specID] then
							local _, name, description, icon, background, role, class = GetSpecializationInfoByID(specID)
							args[spelldata.class].args["spec" .. specID] = {
								type = "group",
								name = name,
								icon = icon,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 3 + specID,
								args = {}
							}
						end
						args[spelldata.class].args["spec" .. specID].args["spell" .. spellid] = spellconfig
					end
				elseif spelldata.talent then
					-- talent
					if not args[spelldata.class].args.talents then
						args[spelldata.class].args.talents = {
							type = "group",
							name = L["Talent"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 2,
							args = {}
						}
					end
					args[spelldata.class].args.talents.args["spell" .. spellid] = spellconfig
				elseif spelldata.pet then
					-- pet
					if not args[spelldata.class].args.pets then
						args[spelldata.class].args.pets = {
							type = "group",
							name = L["Pet"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 1000,
							args = {}
						}
					end
					args[spelldata.class].args.pets.args["spell" .. spellid] = spellconfig
				else
					-- baseline
					if not args[spelldata.class].args.base then
						args[spelldata.class].args.base = {
							type = "group",
							name = "Baseline",
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 1,
							args = {}
						}
					end
					args[spelldata.class].args.base.args["spell" .. spellid] = spellconfig
				end
			elseif spelldata.race then
				-- racial
				if not args[spelldata.race] then
					args[spelldata.race] = {
						type = "group",
						name = spelldata.race,
						icon = function() return [[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT]] .. (random(0, 1) == 0 and "-FEMALE-" or "-MALE-") .. spelldata.race end,
						disabled = function() return not self:IsUnitEnabled(unit) end,
						order = 3,
						args = {}
					}
				end
				args[spelldata.race].args["spell" .. spellid] = spellconfig
			elseif spelldata.item then
				-- item
				if not args.items then
					args.items = {
						type = "group",
						name = L["Items"],
						icon = [[Interface\Icons\Trade_Engineering]],
						disabled = function() return not self:IsUnitEnabled(unit) end,
						order = 5,
						args = {}
					}
				end
				args.items.args["spell" .. spellid] = spellconfig
			else
				GladiusEx:Print("Bad spelldata for", spellid, ": could not find type")
			end
		end
	end

	return group_options
end

-- Follows a ridiculous parser for GetSpellDescription()
local function parse_desc(desc)
	local input = desc
	local output = ""
	local pos = 1
	local char

	local emit, read, unread, read_number,
		read_until, read_choice, read_muldiv, read_if, read_spelldesc, read_id, read_tag

	emit = function(c)
		output = output .. c
	end

	read = function(n)
		if pos > #input then return nil end
		n = n or 1
		local str = string.sub(input, pos, pos + n  - 1)
		pos = pos + n
		return str
	end

	unread = function()
		pos = pos - 1
	end

	read_number = function()
		local accum = ""
		while true do
			local ch = read()
			if ch and ch:match("%d") then
				accum = accum .. ch
			else
				if ch then unread() end
				return tonumber(accum)
			end
		end
	end

	read_until = function(u)
		local accum = ""
		while true do
			local char = read()
			if not char or char == u then
				return accum
			else
				accum = accum .. char
			end
		end
	end

	read_choice = function()
		local c1 = read_until(":")
		local c2 = read_until(";")
		return string.format("%s or %s", c1, c2)
	end

	read_muldiv = function()
		read_until(";")
		return read_tag()
	end

	read_if = function()
		local op
		while true do
			local id = read()
			if id == "!" or id == "?" then
				id = read()
			end
			local id2 = read_number()
			op = read()
			if op ~= "&" and op ~= "|" then
				break
			end
		end

		if op == "[" then
			local c1 = parse_desc(read_until("]"))
			op = read()
			local c2
			if op == "[" then
				c2 = parse_desc(read_until("]"))
			elseif op ~= nil then
				unread()
				c2 = read_tag()
			end
			if c1 == c2 then
				return c1
			elseif c1 == "" then
				return string.format("[%s]", c2)
			elseif c2 == "" then
				return string.format("[%s]", c1)
			else
				return string.format("{[%s] or [%s]}", c1, c2)
			end
		else
			assert(false, "read_if: op " .. op)
		end
	end

	read_spelldesc = function()
		local op = read(9)
		local spellid = read_number()
		if op == "spelldesc" then
			return FormatSpellDescription(spellid)
		elseif op == "spellicon" then
			local _, _, icon = GetSpellInfo(spellid)
			return string.format("|T%s:24|t", icon)
		elseif op == "spellname" then
			local name = GetSpellInfo(spellid)
			return name
		else
			assert(op, "op failed me once again")
		end
	end

	read_id = function()
		unread()
		local id = read_number()
		return read_tag()
	end

	local op_table = {
		["0"] = read_id,
		["1"] = read_id,
		["2"] = read_id,
		["3"] = read_id,
		["4"] = read_id,
		["5"] = read_id,
		["6"] = read_id,
		["7"] = read_id,
		["8"] = read_id,
		["9"] = read_id,

		["{"] = function() read_until("}") return "?" end, -- expr
		["<"] = function() read_until(">") return "?" end, -- variable name

		["g"] = read_choice, -- gender
		["G"] = read_choice, -- gender
		["l"] = read_choice, -- singular/plural
		["L"] = read_choice, -- singular/plural

		["?"] = read_if, -- if
		["*"] = read_muldiv,
		["/"] = read_muldiv,
		["@"] = read_spelldesc, -- spelldesc

		["m"] = function() read() return "?" end, -- followed by a single digit, ends there
		["M"] = function() read() return "?" end, -- like m
		["a"] = function() read() return "?" end, -- like m
		["A"] = function() read() return "?" end, -- like m
		["o"] = function() read() return "?" end, -- like m
		["s"] = function() read() return "?" end, -- like m
		["t"] = function() read() return "?" end, -- like m
		["T"] = function() read() return "?" end, -- like m
		["x"] = function() read() return "?" end, -- like m

		["d"] = function() return "?" end, -- ends there
		["D"] = function() return "?" end, -- same as d
		["i"] = function() return "?" end, -- same as d
		["u"] = function() return "?" end, -- same as d
		["n"] = function() return "?" end, -- same as d
	}

	read_tag = function()
		local op = read()
		assert(op, "op is a faggot")

		local fn = op_table[op]
		assert(fn, "no fn for " .. tostring(op))

		return fn(op)
	end

	while true do
		local ch = read()
		if not ch then
			break
		elseif ch == "$" then
			emit(read_tag())
		else
			emit(ch)
		end
	end

	return output
end

FormatSpellDescription = function (spellid)
	local text = GetSpellDescription(spellid)

	if GladiusEx:IsDebugging() then
		text = parse_desc(text)
	else
		pcall(function() text = parse_desc(text) end)
	end
	return text
end
