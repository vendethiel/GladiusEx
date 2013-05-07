local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM
local CT = LibStub("LibCooldownTracker-1.0")
local fn = LibStub("LibFunctional-1.0")

-- global functions
local tinsert, tremove, tsort = table.insert, table.remove, table.sort
local pairs, ipairs, select, type, unpack = pairs, ipairs, select, type, unpack
local min, max, ceil, random = math.min, math.max, math.ceil, math.random
local GetTime, UnitExists, UnitFactionGroup, UnitClass, UnitRace = GetTime, UnitExists, UnitFactionGroup, UnitClass, UnitRace

local function GetDefaultSpells()
	return {
		{ -- group 1
			[69070] = true, -- GOBLIN/Rocket Jump
			[7744] = true, -- UNDEAD/Will of the Forsaken
			[48707] = true, -- DEATHKNIGHT/Anti-Magic Shell
			[42650] = true, -- DEATHKNIGHT/Army of the Dead
			[108194] = true, -- DEATHKNIGHT/Asphyxiate
			[49576] = true, -- DEATHKNIGHT/Death Grip
			[48743] = true, -- DEATHKNIGHT/Death Pact
			[108201] = true, -- DEATHKNIGHT/Desecrated Ground
			[47568] = true, -- DEATHKNIGHT/Empower Rune Weapon
			[48792] = true, -- DEATHKNIGHT/Icebound Fortitude
			[49039] = true, -- DEATHKNIGHT/Lichborne
			[47528] = true, -- DEATHKNIGHT/Mind Freeze
			[51271] = true, -- DEATHKNIGHT/Pillar of Frost
			[61999] = true, -- DEATHKNIGHT/Raise Ally
			[108200] = true, -- DEATHKNIGHT/Remorseless Winter
			[47476] = true, -- DEATHKNIGHT/Strangulate
			[49206] = true, -- DEATHKNIGHT/Summon Gargoyle
			[22812] = true, -- DRUID/Barkskin
			[99] = true, -- DRUID/Disorienting Roar
			[102280] = true, -- DRUID/Displacer Beast
			[108288] = true, -- DRUID/Heart of the Wild
			[106731] = true, -- DRUID/Incarnation
			[102342] = true, -- DRUID/Ironbark
			[102359] = true, -- DRUID/Mass Entanglement
			[5211] = true, -- DRUID/Mighty Bash
			[88423] = true, -- DRUID/Nature's Cure
			[132158] = true, -- DRUID/Nature's Swiftness
			[2782] = true, -- DRUID/Remove Corruption
			[106839] = true, -- DRUID/Skull Bash
			[78675] = true, -- DRUID/Solar Beam
			[132469] = true, -- DRUID/Typhoon
			[102793] = true, -- DRUID/Ursol's Vortex
			[19574] = true, -- HUNTER/Bestial Wrath
			[19263] = true, -- HUNTER/Deterrence
			[781] = true, -- HUNTER/Disengage
			[1499] = true, -- HUNTER/Freezing Trap
			[19577] = true, -- HUNTER/Intimidation
			[126246] = true, -- HUNTER/Lullaby
			[50479] = true, -- HUNTER/Nether Shock
			[26090] = true, -- HUNTER/Pummel
			[23989] = true, -- HUNTER/Readiness
			[19503] = true, -- HUNTER/Scatter Shot
			[34490] = true, -- HUNTER/Silencing Shot
			[50519] = true, -- HUNTER/Sonic Blast
			[121818] = true, -- HUNTER/Stampede
			[96201] = true, -- HUNTER/Web Wrap
			[19386] = true, -- HUNTER/Wyvern Sting
			[108843] = true, -- MAGE/Blazing Speed
			[1953] = true, -- MAGE/Blink
			[11958] = true, -- MAGE/Cold Snap
			[2139] = true, -- MAGE/Counterspell
			[44572] = true, -- MAGE/Deep Freeze
			[102051] = true, -- MAGE/Frostjaw
			[45438] = true, -- MAGE/Ice Block
			[115450] = true, -- MONK/Detox
			[122783] = true, -- MONK/Diffuse Magic
			[113656] = true, -- MONK/Fists of Fury
			[115203] = true, -- MONK/Fortifying Brew
			[119381] = true, -- MONK/Leg Sweep
			[116849] = true, -- MONK/Life Cocoon
			[115078] = true, -- MONK/Paralysis
			[115310] = true, -- MONK/Revival
			[116844] = true, -- MONK/Ring of Peace
			[116705] = true, -- MONK/Spear Hand Strike
			[116841] = true, -- MONK/Tiger's Lust
			[122470] = true, -- MONK/Touch of Karma
			[119996] = true, -- MONK/Transcendence: Transfer
			[115176] = true, -- MONK/Zen Meditation
			[115750] = true, -- PALADIN/Blinding Light
			[4987] = true, -- PALADIN/Cleanse
			[498] = true, -- PALADIN/Divine Protection
			[642] = true, -- PALADIN/Divine Shield
			[105593] = true, -- PALADIN/Fist of Justice
			[86698] = true, -- PALADIN/Guardian of Ancient Kings
			[853] = true, -- PALADIN/Hammer of Justice
			[96231] = true, -- PALADIN/Rebuke
			[20066] = true, -- PALADIN/Repentance
			[47585] = true, -- PRIEST/Dispersion
			[47788] = true, -- PRIEST/Guardian Spirit
			[89485] = true, -- PRIEST/Inner Focus
			[96267] = true, -- PRIEST/Inner Focus
			[73325] = true, -- PRIEST/Leap of Faith
			[33206] = true, -- PRIEST/Pain Suppression
			[8122] = true, -- PRIEST/Psychic Scream
			[108921] = true, -- PRIEST/Psyfiend
			[527] = true, -- PRIEST/Purify
			[15487] = true, -- PRIEST/Silence
			[112833] = true, -- PRIEST/Spectral Guise
			[108968] = true, -- PRIEST/Void Shift
			[108920] = true, -- PRIEST/Void Tendrils
			[13750] = true, -- ROGUE/Adrenaline Rush
			[2094] = true, -- ROGUE/Blind
			[31224] = true, -- ROGUE/Cloak of Shadows
			[1766] = true, -- ROGUE/Kick
			[137619] = true, -- ROGUE/Marked for Death
			[14185] = true, -- ROGUE/Preparation
			[121471] = true, -- ROGUE/Shadow Blades
			[51713] = true, -- ROGUE/Shadow Dance
			[76577] = true, -- ROGUE/Smoke Bomb
			[1856] = true, -- ROGUE/Vanish
			[79140] = true, -- ROGUE/Vendetta
			[114049] = true, -- SHAMAN/Ascendance
			[51886] = true, -- SHAMAN/Cleanse Spirit
			[8177] = true, -- SHAMAN/Grounding Totem
			[108280] = true, -- SHAMAN/Healing Tide Totem
			[51514] = true, -- SHAMAN/Hex
			[16190] = true, -- SHAMAN/Mana Tide Totem
			[77130] = true, -- SHAMAN/Purify Spirit
			[30823] = true, -- SHAMAN/Shamanistic Rage
			[98008] = true, -- SHAMAN/Spirit Link Totem
			[79206] = true, -- SHAMAN/Spiritwalker's Grace
			[51490] = true, -- SHAMAN/Thunderstorm
			[8143] = true, -- SHAMAN/Tremor Totem
			[57994] = true, -- SHAMAN/Wind Shear
			[89766] = true, -- WARLOCK/Axe Toss
			[111397] = true, -- WARLOCK/Blood Horror
			[103967] = true, -- WARLOCK/Carrion Swarm
			[110913] = true, -- WARLOCK/Dark Bargain
			[108359] = true, -- WARLOCK/Dark Regeneration
			[113858] = true, -- WARLOCK/Dark Soul: Instability
			[113861] = true, -- WARLOCK/Dark Soul: Knowledge
			[113860] = true, -- WARLOCK/Dark Soul: Misery
			[48020] = true, -- WARLOCK/Demonic Circle: Teleport
			[5484] = true, -- WARLOCK/Howl of Terror
			[6789] = true, -- WARLOCK/Mortal Coil
			[30283] = true, -- WARLOCK/Shadowfury
			[19647] = true, -- WARLOCK/Spell Lock
			[104773] = true, -- WARLOCK/Unending Resolve
			[118038] = true, -- WARRIOR/Die by the Sword
			[5246] = true, -- WARRIOR/Intimidating Shout
			[6552] = true, -- WARRIOR/Pummel
			[1719] = true, -- WARRIOR/Recklessness
			[871] = true, -- WARRIOR/Shield Wall
			[46968] = true, -- WARRIOR/Shockwave
			[23920] = true, -- WARRIOR/Spell Reflection
		},
		{ -- group 2	
			[42292] = true, -- ITEMS/PvP Trinket
		} 
	}
end

local function MakeGroupDb(settings)
	local db = {
		cooldownsAttachTo = "Frame",
		cooldownsAnchor = "TOPLEFT",
		cooldownsRelativePoint = "BOTTOMLEFT",
		cooldownsOffsetX = 0,
		cooldownsOffsetY = 0,
		cooldownsGrow = "DOWNRIGHT",
		cooldownsSpacingX = 0,
		cooldownsSpacingY = 0,
		cooldownsPerColumn = 8,
		cooldownsMax = 8,
		cooldownsSize = 24,
		cooldownsCrop = true,
		cooldownsSpells = {},
		cooldownsBorderSize = 1,
		cooldownsBorderAvailAlpha = 1.0,
		cooldownsBorderUsingAlpha = 1.0,
		cooldownsBorderCooldownAlpha = 0.2,
		cooldownsIconAvailAlpha = 1.0,
		cooldownsIconUsingAlpha = 1.0,
		cooldownsIconCooldownAlpha = 0.2,
		cooldownsCatPriority = { "pvp_trinket", "dispel", "mass_dispel", "immune",
			"interrupt", "silence", "stun", "knockback", "cc",
			"offensive", "defensive", "heal", "uncat"
		},
		cooldownsCatColors = {
			["pvp_trinket"] =  { r = 1.0, g = 1.0, b = 1.0 }, ["dispel"] =       { r = 1.0, g = 1.0, b = 1.0 },
			["mass_dispel"] =  { r = 1.0, g = 1.0, b = 1.0 }, ["immune"] =       { r = 0.0, g = 0.0, b = 1.0 },
			["interrupt"] =    { r = 1.0, g = 0.0, b = 1.0 }, ["silence"] =      { r = 1.0, g = 0.0, b = 1.0 },
			["stun"] =         { r = 0.0, g = 1.0, b = 1.0 }, ["knockback"] =    { r = 0.0, g = 1.0, b = 1.0 },
			["cc"] =           { r = 0.0, g = 1.0, b = 1.0 }, ["offensive"] =    { r = 1.0, g = 0.0, b = 0.0 },
			["defensive"] =    { r = 0.0, g = 1.0, b = 0.0 }, ["heal"] =         { r = 0.0, g = 1.0, b = 0.0 },
			["uncat"] =        { r = 1.0, g = 1.0, b = 1.0 },
		},
		cooldownsCatGroups = {
			["pvp_trinket"] =  1, ["dispel"] =       1, ["mass_dispel"] =  1,
			["immune"] =       1, ["interrupt"] =    1, ["silence"] =      1,
			["stun"] =         1, ["knockback"] =    1, ["cc"] =           1,
			["offensive"] =    1, ["defensive"] =    1, ["heal"] =         1,
			["uncat"] =        1,
		},
		cooldownsHideTalentsUntilDetected = true,
	}
	if settings then
		for k, v in pairs(settings) do
			db[k] = v
		end
	end
	return db
end

local Cooldowns = GladiusEx:NewGladiusExModule("Cooldowns", false, {
		num_groups = 2,
		group_table = {
			[1] = "group_1",
			[2] = "group_2",
		},
		groups = {
			["*"] = MakeGroupDb(),
			["group_1"] = MakeGroupDb {
				cooldownsGroupId = 1,
				cooldownsAttachTo = "CastBar",
				cooldownsAnchor = "TOPLEFT",
				cooldownsRelativePoint = "BOTTOMLEFT",
				cooldownsGrow = "DOWNRIGHT",
				cooldownsBorderSize = 0,
				cooldownsSpacingX = 2,
				cooldownsSpacingY = 2,
				cooldownsSpells = GetDefaultSpells()[1],
			},
			["group_2"] = MakeGroupDb {
				cooldownsGroupId = 2,
				cooldownsAttachTo = "Frame",
				cooldownsAnchor = "TOPLEFT",
				cooldownsRelativePoint = "TOPRIGHT",
				cooldownsGrow = "DOWNRIGHT",
				cooldownsPerColumn = 5,
				cooldownsMax = 10,
				cooldownsSize = 40,
				cooldownsCrop = false,
				cooldownsBorderSize = 0,
				cooldownsBorderAvailAlpha = 1.0,
				cooldownsBorderUsingAlpha = 1.0,
				cooldownsBorderCooldownAlpha = 1.0,
				cooldownsIconAvailAlpha = 1.0,
				cooldownsIconUsingAlpha = 1.0,
				cooldownsIconCooldownAlpha = 1.0,
				cooldownsSpells = GetDefaultSpells()[2],
			}
		},
	},
	{
		num_groups = 2,
		group_table = {
			[1] = "group_1",
			[2] = "group_2",
		},
		groups = {
			["*"] = MakeGroupDb(),
			["group_1"] = MakeGroupDb {
				cooldownsGroupId = 1,
				cooldownsAttachTo = "CastBar",
				cooldownsAnchor = "TOPRIGHT",
				cooldownsRelativePoint = "BOTTOMRIGHT",
				cooldownsGrow = "DOWNLEFT",
				cooldownsBorderSize = 0,
				cooldownsSpacingX = 2,
				cooldownsSpacingY = 2,
				cooldownsSpells = GetDefaultSpells()[1],
			},
			["group_2"] = MakeGroupDb {
				cooldownsGroupId = 2,
				cooldownsAttachTo = "Frame",
				cooldownsAnchor = "TOPRIGHT",
				cooldownsRelativePoint = "TOPLEFT",
				cooldownsGrow = "DOWNLEFT",
				cooldownsPerColumn = 5,
				cooldownsMax = 10,
				cooldownsSize = 40,
				cooldownsCrop = false,
				cooldownsBorderSize = 0,
				cooldownsBorderAvailAlpha = 1.0,
				cooldownsBorderUsingAlpha = 1.0,
				cooldownsBorderCooldownAlpha = 1.0,
				cooldownsIconAvailAlpha = 1.0,
				cooldownsIconUsingAlpha = 1.0,
				cooldownsIconCooldownAlpha = 1.0,
				cooldownsSpells = GetDefaultSpells()[2],
			}
		}
	})

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

function Cooldowns:OnEnable()
	CT.RegisterCallback(self, "LCT_CooldownUsed")
	CT.RegisterCallback(self, "LCT_CooldownsReset")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterMessage("GLADIUS_SPEC_UPDATE")

	LSM = GladiusEx.LSM
end

function Cooldowns:OnDisable()
	for unit in pairs(unit_state) do
		self:Reset(unit)
	end

	CT.UnregisterAllCallbacks(self)
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()
end

function Cooldowns:OnProfileChanged()
	self.super.OnProfileChanged(self)
	self:SpellSortingChanged()
end

function Cooldowns:GetModuleAttachPoints(unit)
	local t = {}
	for group = 1, self:GetNumGroups(unit) do
		local db = self:GetGroupDB(unit, group)
		t["Cooldowns_" .. db.cooldownsGroupId] = string.format(L["Cooldowns group %i"], group)
	end
	return t
end

function Cooldowns:GetAttachFrame(unit, point)
	local gid = string.match(point, "^Cooldowns_(%d+)$")
	if not gid then return nil end

	local group, gidx = self:GetGroupById(unit, tonumber(gid))
	if not group then return nil end

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

	if tracked then
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
	frame.tracked = nil
	frame.cooldown:Hide()
	local a = Cooldowns:GetGroupDB(frame.unit, frame.group).cooldownsIconAvailAlpha
	local ab = Cooldowns:GetGroupDB(frame.unit, frame.group).cooldownsBorderAvailAlpha
	frame:SetBackdropBorderColor(frame.color.r, frame.color.g, frame.color.b, ab)
	frame.icon_frame:SetAlpha(a)
	frame:SetScript("OnUpdate", nil)
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
	else
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
local sorted_spells = {}
local function GetCooldownList(unit, group)
	local db = Cooldowns:GetGroupDB(unit, group)

	local specID, class, race = GetUnitInfo(unit)

	-- generate list of cooldowns available (and enabled) for this unit
	wipe(spell_list)
	for spellid, spelldata in CT:IterateCooldowns(class, specID, race) do
		if db.cooldownsSpells[spellid] then
			local tracked = CT:GetUnitCooldownInfo(unit, spellid)

			if (not spelldata.cooldown or spelldata.cooldown < 600) and ((not spelldata.glyph and not spelldata.talent and not spelldata.pet) or (tracked and tracked.detected) or not db.cooldownsHideTalentsUntilDetected) then
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

	-- sort spells
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

local function ShowIcon(frame)
	frame:Show()
end

local function HideIcon(frame)
	frame:Hide()
end

local function UpdateGroupIconFrames(unit, group, sorted_spells)
	local gs = Cooldowns:GetGroupState(unit, group)
	local db = Cooldowns:GetGroupDB(unit, group)
	local faction = GetUnitFaction(unit)

	local cat_priority = db.cooldownsCatPriority
	local border_color = db.cooldownsCatColors
	local cat_groups = db.cooldownsCatGroups
	local cooldownsPerColumn = db.cooldownsPerColumn

	local sidx = 1
	local shown = 0
	local prev_group
	for i = 1, #sorted_spells do
		local spellid = sorted_spells[i]
		local spelldata = CT:GetCooldownData(spellid)
		local tracked = CT:GetUnitCooldownInfo(unit, spellid)
		local icon

		-- icon grouping
		local cat, group
		for i = 1, #cat_priority do
			local key = cat_priority[i]
			if spelldata[key] then
				cat = key
				group = cat_groups[cat]
				break
			end
		end
		if not cat and not group then
			cat = "uncat"
			group = cat_groups["uncat"]
		end

		if prev_group and group ~= prev_group and sidx ~= 1 then
			local skip = cooldownsPerColumn - ((sidx - 1) % cooldownsPerColumn)
			if skip ~= cooldownsPerColumn then
				for i = 1, skip do
					HideIcon(gs.frame[sidx])
					sidx = sidx + 1
					if sidx > #gs.frame then
						-- ran out of space
						return
					end
				end
			end
		end
		prev_group = group
		local frame = gs.frame[sidx]

		if spelldata.icon_alliance and faction == "Alliance" then
			icon = spelldata.icon_alliance
		elseif spelldata.icon_horde and faction == "Horde" then
			icon = spelldata.icon_horde
		else
			icon = spelldata.icon
		end

		-- set border color
		local c

		for i = 1, #cat_priority do
			local key = cat_priority[i]
			if spelldata[key] then
				c = border_color[key]
				break
			end
		end

		frame.icon:SetTexture(icon)

		frame.spellid = spellid
		frame.spelldata = spelldata
		frame.state = 0
		frame.tracked = tracked
		frame.color = c or border_color["uncat"]

		-- refresh
		frame:SetScript("OnUpdate", CooldownFrame_OnUpdate)
		ShowIcon(frame)

		sidx = sidx + 1
		shown = shown + 1
		if sidx > #gs.frame or shown >= db.cooldownsMax then
			break
		end
	end

	-- hide unused icons
	for i = sidx, #gs.frame do
		HideIcon(gs.frame[i])
	end
end

function Cooldowns:UpdateGroupIcons(unit, group)
	local gs = self:GetGroupState(unit, group)
	if not gs.frame then return end

	-- get spells lists
	local sorted_spells = GetCooldownList(unit, group)

	-- update icon frames
	UpdateGroupIconFrames(unit, group, sorted_spells)
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

	frame.count = frame:CreateFontString(nil, "OVERLAY")
	frame.count:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.base.globalFont), 10, "OUTLINE")
	frame.count:SetTextColor(1, 1, 1, 1)
	frame.count:SetShadowColor(0, 0, 0, 1.0)
	frame.count:SetShadowOffset(0.50, -0.50)
	frame.count:SetHeight(1)
	frame.count:SetWidth(1)
	frame.count:SetAllPoints()
	frame.count:SetJustifyV("BOTTOM")
	frame.count:SetJustifyH("RIGHT")

	frame:EnableMouse(false)
	frame:SetScript("OnEnter", function(self)
		if self.spellid then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetSpellByID(self.spellid)
		end
	end)
	frame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

	return frame
end

local perfect_scale
local function GetPerfectScale()
	if not perfect_scale then
		perfect_scale = 768 / string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
	end
	return perfect_scale
end

local function AdjustPixels(frame, size)
	while not frame.GetEffectiveScale do frame = frame:GetParent() end
	local frameScale = frame:GetEffectiveScale()
	local perfectScale = GetPerfectScale()
	local size_adjusted = size / (frameScale / perfectScale)
	return size_adjusted
end

local function AdjustPositionOffset(frame, p, pos)
	while not frame.GetEffectiveScale do frame = frame:GetParent() end
	local frameScale = frame:GetEffectiveScale()
	local perfectScale = GetPerfectScale()
	local pp = p * frameScale / perfectScale
	local pa = pos and (math.ceil(pp) - pp) or (pp - math.floor(pp))
	return p + pa * perfectScale / frameScale
end

local function AdjustFrameOffset(frame, relative_point)
	local x, y
	local ax, ay

	if strfind(relative_point, "LEFT") then
		x = frame:GetRight() or 0
		ax = x - AdjustPositionOffset(frame, x, false)
	else
		x = frame:GetLeft() or 0
		ax = AdjustPositionOffset(frame, x, true) - x
	end
	if strfind(relative_point, "TOP") then
		y = frame:GetTop() or 0
		ay = AdjustPositionOffset(frame, y, true) - y
	else
		y = frame:GetBottom() or 0
		ay = y - AdjustPositionOffset(frame, y, false)
	end

	return ax, ay
end

function Cooldowns:CreateFrame(unit)
	for group = 1, self:GetNumGroups(unit) do
		self:CreateGroupFrame(unit, group)
	end
end

function Cooldowns:CreateGroupFrame(unit, group)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	local gs = self:GetGroupState(unit, group)

	-- create cooldown frame
	if not gs.frame then
		gs.frame = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. "frame" .. unit, button)
		gs.frame:EnableMouse(false)

		for i = 1, MAX_ICONS do
			gs.frame[i] = CreateCooldownFrame("GladiusEx" .. self:GetName() .. "frameIcon" .. i .. unit, gs.frame)
			gs.frame[i]:SetScript("OnUpdate", CooldownFrame_OnUpdate)
			gs.frame[i].unit = unit
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
		frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	else
		frame.icon:SetTexCoord(0, 1, 0, 1)
	end
end

local function UpdateCooldownGroup(
	cooldownFrame, unit,
	cooldownAttachTo,
	cooldownAnchor,
	cooldownRelativePoint,
	cooldownOffsetX,
	cooldownOffsetY,
	cooldownPerColumn,
	cooldownGrow,
	cooldownSize,
	cooldownBorderSize,
	cooldownSpacingX,
	cooldownSpacingY,
	cooldownMax,
	cooldownCrop)

	-- anchor point
	local parent = GladiusEx:GetAttachFrame(unit, cooldownAttachTo)

	local xo, yo = AdjustFrameOffset(parent, cooldownRelativePoint)
	cooldownSpacingX = AdjustPositionOffset(parent, cooldownSpacingX)
	cooldownSpacingY = AdjustPositionOffset(parent, cooldownSpacingY)
	cooldownOffsetX = AdjustPositionOffset(parent, cooldownOffsetX)
	cooldownOffsetY = AdjustPositionOffset(parent, cooldownOffsetY)
	cooldownSize = AdjustPositionOffset(parent, cooldownSize)
	cooldownBorderSize = AdjustPixels(parent, cooldownBorderSize)

	cooldownFrame:ClearAllPoints()
	cooldownFrame:SetPoint(cooldownAnchor, parent, cooldownRelativePoint, cooldownOffsetX + xo, cooldownOffsetY + yo)

	-- size
	cooldownFrame:SetWidth(cooldownSize * cooldownPerColumn + cooldownSpacingX * cooldownPerColumn)
	cooldownFrame:SetHeight(cooldownSize * ceil(cooldownMax / cooldownPerColumn) + (cooldownSpacingY * (ceil(cooldownMax / cooldownPerColumn) + 1)))

	-- backdrop
	-- cooldownFrame:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tile = true, tileSize = 16})
	-- cooldownFrame:SetBackdropColor(0, 0, 1, 1)

	-- icon points
	local anchor, parent, relativePoint, offsetX, offsetY

	-- grow anchor
	local grow1, grow2, grow3, startRelPoint
	if (cooldownGrow == "DOWNRIGHT") then
		grow1, grow2, grow3, startRelPoint = "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT", "TOPLEFT"
	elseif (cooldownGrow == "DOWNLEFT") then
		grow1, grow2, grow3, startRelPoint = "TOPRIGHT", "BOTTOMRIGHT", "TOPLEFT", "TOPRIGHT"
	elseif (cooldownGrow == "UPRIGHT") then
		grow1, grow2, grow3, startRelPoint = "BOTTOMLEFT", "TOPLEFT", "BOTTOMRIGHT", "BOTTOMLEFT"
	elseif (cooldownGrow == "UPLEFT") then
		grow1, grow2, grow3, startRelPoint = "BOTTOMRIGHT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"
	end

	local start, startAnchor = 1, cooldownFrame
	for i = 1, #cooldownFrame do
		if (cooldownMax >= i) then
			if (start == 1) then
				anchor, parent, relativePoint, offsetX, offsetY = grow1, startAnchor, startRelPoint, 0, string.find(cooldownGrow, "DOWN") and -cooldownSpacingY or cooldownSpacingY
			else
				anchor, parent, relativePoint, offsetX, offsetY = grow1, cooldownFrame[i - 1], grow3, string.find(cooldownGrow, "LEFT") and -cooldownSpacingX or cooldownSpacingX, 0
			end

			if (start == cooldownPerColumn) then
				start = 0
				startAnchor = cooldownFrame[i - cooldownPerColumn + 1]
				startRelPoint = grow2
			end

			start = start + 1
		end

		cooldownFrame[i]:ClearAllPoints()
		cooldownFrame[i]:SetPoint(anchor, parent, relativePoint, offsetX, offsetY)
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
	end
end

function Cooldowns:UpdateGroup(unit, group)
	-- create frame
	self:CreateGroupFrame(unit, group)

	local db = self:GetGroupDB(unit, group)
	local gs = self:GetGroupState(unit, group)

	-- update cooldown frame
	UpdateCooldownGroup(gs.frame, unit,
		db.cooldownsAttachTo,
		db.cooldownsAnchor,
		db.cooldownsRelativePoint,
		db.cooldownsOffsetX,
		db.cooldownsOffsetY,
		db.cooldownsPerColumn,
		db.cooldownsGrow,
		db.cooldownsSize,
		db.cooldownsBorderSize,
		db.cooldownsSpacingX,
		db.cooldownsSpacingY,
		db.cooldownsMax,
		db.cooldownsCrop)

	-- update icons
	self:UpdateIcons(unit)

	-- hide group
	gs.frame:Hide()
end

function Cooldowns:Show(unit)
	for group = 1, self:GetNumGroups(unit) do
		local gs = self:GetGroupState(unit, group)
		if gs.frame and not gs.frame:IsShown() then
			gs.frame:Show()
			CT:RegisterUnit(unit)
		end
	end
end

function Cooldowns:Reset(unit)
	for group = 1, self:GetNumGroups(unit) do
		local gs = self:GetGroupState(unit, group)
		if gs.frame then
			if gs.frame:IsShown() then
				CT:UnregisterUnit(unit)
			end

			-- hide cooldown frame
			gs.frame:Hide()

			for i = 1, #gs.frame do
				gs.frame[i]:Hide()
			end
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
							cooldownsGrow = {
								type = "select",
								name = L["Grow direction"],
								desc = L["Grow direction of the cooldowns"],
								values = function() return {
										["UPLEFT"] = L["Up left"],
										["UPRIGHT"] = L["Up right"],
										["DOWNLEFT"] = L["Down left"],
										["DOWNRIGHT"] = L["Down right"],
								}
								end,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 10,
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
								hidden = function() return not GladiusEx.db.base.advancedOptions end,
								order = 14,
							},
							sep2 = {
								type = "description",
								name = "",
								width = "full",
								order = 14.5,
							},
							cooldownsPerColumn = {
								type = "range",
								name = L["Icons per column"],
								desc = L["Number of icons per column"],
								min = 1, max = MAX_ICONS, step = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 15,
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
							cooldownsSpacingY = {
								type = "range",
								name = L["Vertical spacing"],
								desc = L["Vertical spacing of the icons"],
								min = 0, softMax = 30, step = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 15,
							},
							cooldownsSpacingX = {
								type = "range",
								name = L["Horizontal spacing"],
								desc = L["Horizontal spacing of the icons"],
								disabled = function() return not self:IsUnitEnabled(unit) end,
								min = 0, softMax = 30, step = 1,
								order = 20,
							},
						},
					},
					position = {
						type = "group",
						name = L["Position"],
						desc = L["Position settings"],
						inline = true,
						hidden = function() return not GladiusEx.db.base.advancedOptions end,
						order = 3,
						args = {
							cooldownsAttachTo = {
								type = "select",
								name = L["Attach to"],
								desc = L["Attach to the given frame"],
								values = function() return self:GetOtherAttachPoints(unit) end,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								width = "double",
								order = 5,
							},
							sep = {
								type = "description",
								name = "",
								width = "full",
								order = 7,
							},
							cooldownsAnchor = {
								type = "select",
								name = L["Anchor"],
								desc = L["Anchor of the frame"],
								values = function() return GladiusEx:GetPositions() end,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 10,
							},
							cooldownsRelativePoint = {
								type = "select",
								name = L["Relative point"],
								desc = L["Relative point of the frame"],
								values = function() return GladiusEx:GetPositions() end,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 15,
							},
							sep2 = {
								type = "description",
								name = "",
								width = "full",
								order = 17,
							},
							cooldownsOffsetX = {
								type = "range",
								name = L["Offset X"],
								desc = L["X offset of the frame"],
								softMin = -100, softMax = 100, bigStep = 1,
								disabled = function() return not self:IsUnitEnabled(unit) end,
								order = 20,
							},
							cooldownsOffsetY = {
								type = "range",
								name = L["Offset Y"],
								desc = L["Y offset of the frame"],
								disabled = function() return not self:IsUnitEnabled(unit) end,
								softMin = -100, softMax = 100, bigStep = 1,
								order = 25,
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
				name = L["Cooldowns"],
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
					order = 0,
				},
				color = {
					type = "color",
					name = L["Color"],
					desc = L["Border color for spells in this category"],
					get = function()
						local c = self:GetGroupDB(unit, group).cooldownsCatColors[cat]
						return c.r, c.g, c.b
					end,
					set = function(self, r, g, b)
						self:GetGroupDB(unit, group).cooldownsCatColors[cat] = { r = r, g = g, b = b }
						GladiusEx:UpdateFrames()
					end,
					disabled = function() return not self:IsUnitEnabled(unit) end,
					order = 0.5,
				},
				group = {
					type = "range",
					softMin = 1, softMax = 20, step = 1,
					name = L["Group"],
					desc = L["Spells in each group have their own row or column"],
					get = function() return self:GetGroupDB(unit, group).cooldownsCatGroups[cat] end,
					set = function(self, value)
						self:GetGroupDB(unit, group).cooldownsCatGroups[cat] = value
						GladiusEx:UpdateFrames()
					end,
					disabled = function() return not self:IsUnitEnabled(unit) end,
					order = 1,
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

			local namestr
			local basecd = GetSpellBaseCooldown(spellid)
			if GladiusEx:IsDebugging() then
				namestr = string.format(" |T%s:20|t %s [%ss/Base: %ss] %s", spelldata.icon, spelldata.name, spelldata.cooldown or "??", basecd and basecd/1000 or "??", catstr or "")
				if basecd and basecd/1000 ~= spelldata.cooldown then
					GladiusEx:Log(namestr)
				end
			else
				namestr = string.format(" |T%s:20|t %s [%ss] %s", spelldata.icon, spelldata.name, spelldata.cooldown or "??", catstr or "")
			end
			local spellconfig = {
				type = "toggle",
				name = namestr,
				desc = FormatSpellDescription(spellid),
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
