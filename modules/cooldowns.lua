local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM
local CT = LibStub("LibCooldownTracker-1.0")
local fn = LibStub("LibFunctional-1.0")

-- global functions
local tinsert, tremove, tsort = table.insert, table.remove, table.sort
local pairs, ipairs, select, type, unpack = pairs, ipairs, select, type, unpack
local min, max, ceil, random = math.min, math.max, math.ceil, math.random
local GetTime, UnitExists, UnitFactionGroup, UnitRace, UnitGUID = GetTime, UnitExists, UnitFactionGroup, UnitRace, UnitGUID

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
		cooldownsPerColumn = 9,
		cooldownsMax = 40,
		cooldownsSize = 23,
		cooldownsCrop = true,
		cooldownsSpells = {},
		cooldownsCatPriority = {
			"pvp_trinket",
			"dispel",
			"mass_dispel",
			"immune",
			"interrupt",
			"silence",
			"stun",
			"knockback",
			"cc",
			"offensive",
			"defensive",
			"heal",
			"uncat"
		},
		cooldownsCatColors = {
			["pvp_trinket"] =  { r = 1.0, g = 1.0, b = 1.0 },
			["dispel"] =       { r = 1.0, g = 1.0, b = 1.0 },
			["mass_dispel"] =  { r = 1.0, g = 1.0, b = 1.0 },
			["immune"] =       { r = 0.0, g = 0.0, b = 1.0 },
			["interrupt"] =    { r = 1.0, g = 0.0, b = 1.0 },
			["silence"] =      { r = 1.0, g = 0.0, b = 1.0 },
			["stun"] =         { r = 0.0, g = 1.0, b = 1.0 },
			["knockback"] =    { r = 0.0, g = 1.0, b = 1.0 },
			["cc"] =           { r = 0.0, g = 1.0, b = 1.0 },
			["offensive"] =    { r = 1.0, g = 0.0, b = 0.0 },
			["defensive"] =    { r = 0.0, g = 1.0, b = 0.0 },
			["heal"] =         { r = 0.0, g = 1.0, b = 0.0 },
			["uncat"] =        { r = 1.0, g = 1.0, b = 1.0 },
		},
		cooldownsCatGroups = {
			["pvp_trinket"] =  1,
			["dispel"] =       1,
			["mass_dispel"] =  1,
			["immune"] =       1,
			["interrupt"] =    1,
			["silence"] =      1,
			["stun"] =         1,
			["knockback"] =    1,
			["cc"] =           1,
			["offensive"] =    1,
			["defensive"] =    1,
			["heal"] =         1,
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
		["group_1"] =  MakeGroupDb {
			cooldownsGroupId = 1,
			cooldownsAttachTo = "CastBarIcon",
			cooldownsAnchor = "TOPLEFT",
			cooldownsRelativePoint = "BOTTOMLEFT",
			cooldownsGrow = "DOWNRIGHT",
			cooldownsPerColumn = 9,
			cooldownsMax = 40,
			cooldownsSize = 23,
			cooldownsCrop = true,
			cooldownsSpells = (function()
				local r = {}
				for spellid, spelldata in pairs(CT:GetCooldownsData()) do
					if (type(spelldata) == "table") and not (spelldata.dispel or spelldata.mass_dispel or spelldata.pvp_trinket) then r[spellid] = true end
				end
				return r
			end)(),
		},
		["group_2"] = MakeGroupDb {
			cooldownsGroupId = 2,
			cooldownsAttachTo = "ClassIcon",
			cooldownsAnchor = "BOTTOMRIGHT",
			cooldownsRelativePoint = "BOTTOMLEFT",
			cooldownsGrow = "UPLEFT",
			cooldownsPerColumn = 1,
			cooldownsMax = 10,
			cooldownsSize = 40,
			cooldownsCrop = false,
			cooldownsSpells = (function()
				local r = {}
				for spellid, spelldata in pairs(CT:GetCooldownsData()) do
					if (type(spelldata) == "table") and (spelldata.dispel or spelldata.mass_dispel or spelldata.pvp_trinket) then r[spellid] = true end
				end
				return r
			end)(),
		}
	}
})

local MAX_ICONS = 40

local group_state = {}
local function GetGroupState(group)
	local gs = group_state[group]
	if not gs then
		gs = { frame = {} }
		group_state[group] = gs
	end
	return gs
end

local function MakeGroupId()
	-- not ideal, but should be good enough for its purpose
	return math.random(2^31-1)
end

local function GetNumGroups()
	return Cooldowns.db.num_groups
end

local function GetGroupDB(group)
	local k = Cooldowns.db.group_table[group]
	return Cooldowns.db.groups[k]
end

local function GetGroupById(gid)
	for group = 1, GetNumGroups() do
		local gdb = GetGroupDB(group)
		if gdb.cooldownsGroupId == gid then
			return gdb, group
		end
	end
end

local function AddGroup(groupdb)
	local group = GetNumGroups() + 1
	Cooldowns.db.num_groups = group
	Cooldowns.db.groups["group_" .. groupdb.cooldownsGroupId] = groupdb
	Cooldowns.db.group_table[group] = "group_" .. groupdb.cooldownsGroupId
	return GetNumGroups()
end

local function RemoveGroup(group)
	local groupdb = GetGroupDB(group)
	Cooldowns.db.num_groups = GetNumGroups() - 1
	tremove(Cooldowns.db.group_table, group)
	Cooldowns.db.groups["group_" .. groupdb.cooldownsGroupId] = nil
end

function Cooldowns:OnEnable()
	CT.RegisterCallback(self, "LCT_CooldownUsed")
	CT.RegisterCallback(self, "LCT_CooldownsReset")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterMessage("GLADIUS_SPEC_UPDATE")

	LSM = GladiusEx.LSM
end

function Cooldowns:OnDisable()
	CT.UnregisterAllCallbacks(self)
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()
end

function Cooldowns:OnProfileChanged()
	self.super.OnProfileChanged(self)
	self:SpellSortingChanged()
end

function Cooldowns:GetModuleAttachPoints()
	local t = {}
	for group = 1, GetNumGroups() do
		local db = GetGroupDB(group)
		t["Cooldowns_" .. db.cooldownsGroupId] = string.format(L["Cooldowns Group %i"], group)
	end
	return t
end

function Cooldowns:GetAttachFrame(unit, point)
	local gid = string.match(point, "^Cooldowns_(%d+)$")
	if not gid then return nil end

	local group, gidx = GetGroupById(tonumber(gid))
	if not group then return nil end

	return GetGroupState(gidx).frame[unit]
end

function Cooldowns:GLADIUS_SPEC_UPDATE(event, unit)
	self:UpdateIcons(unit)
end

function Cooldowns:UNIT_NAME_UPDATE(event, unit)
	-- hopefully at this point the opponent's faction is known
	self:UpdateIcons(unit)
end

function Cooldowns:LCT_CooldownsReset(event, unit)
	GladiusEx:Log(event, unit)

	self:UpdateIcons(unit)
end

function Cooldowns:LCT_CooldownUsed(event, unit, spellid)
	GladiusEx:Log(event, unit, spellid)

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

				frame.border:SetVertexColor(frame.color.r, frame.color.g, frame.color.b, 1.0)
				frame:SetAlpha(1)
				frame.state = 1
			end
			return
		end
		if tracked.used_start and not tracked.cooldown_start and frame.spelldata.active_until_cooldown_start then
			-- waiting to be used (inner focus)
			if frame.state ~= 2 then
				frame.border:SetVertexColor(frame.color.r, frame.color.g, frame.color.b, 1.0)
				frame:SetAlpha(1)
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
				frame.border:SetVertexColor(frame.color.r, frame.color.g, frame.color.b, 0.3)
				frame:SetAlpha(0.8)
				frame.cooldown:Show()
				frame.state = 3
			end
			return
		end
	end

	-- not on cooldown or being used
	frame.tracked = nil
	frame.cooldown:Hide()
	frame.border:SetVertexColor(frame.color.r, frame.color.g, frame.color.b, 0.3)
	frame:SetAlpha(1)
	frame:SetScript("OnUpdate", nil)
end

local group_sortscore = {}
function Cooldowns:SpellSortingChanged()
	-- remove cached sorting info from spells
	group_sortscore = {}
end

local function GetSpellSortScore(group, spellid)
	local db = GetGroupDB(group)
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
	for group = 1, GetNumGroups() do
		self:UpdateGroupIcons(group, unit)
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
local function GetCooldownList(group, unit)
	local db = GetGroupDB(group)

	local specID, class, race = GetUnitInfo(unit)

	-- generate list of cooldowns available (and enabled) for this unit
	--[[
	local eq = fn.equal(
		fn.sort(fn.from_iterator(CT:IterateCooldowns(class, specID, race, true)), function(a,b) return a[1] < b[1] end),
		fn.sort(fn.from_iterator(CT:IterateCooldowns(class, specID, race, false)), function(a,b) return a[1] < b[1] end), true
	)
	if not eq then
		print(specID, class, race)
	end
	]]

	wipe(spell_list)
	for spellid, spelldata in CT:IterateCooldowns(class, specID, race) do
		if db.cooldownsSpells[spellid] then
			local tracked = CT:GetUnitCooldownInfo(unit, spellid)

			if (not spelldata.glyph and not spelldata.talent) or (tracked and tracked.detected) or not db.cooldownsHideTalentsUntilDetected then
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
			return GetSpellSortScore(group, a) > GetSpellSortScore(group, b)
		end)

	return sorted_spells
end

local function UpdateGroupIconFrames(group, unit, sorted_spells)
	local gs = GetGroupState(group)
	local db = GetGroupDB(group)
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
					gs.frame[unit][sidx]:Hide()
					sidx = sidx + 1
					if sidx > #gs.frame[unit] then
						-- ran out of space
						return
					end
				end
			end
		end
		prev_group = group
		local frame = gs.frame[unit][sidx]

		if spelldata.icon_alliance and faction == "Alliance" then
			icon = spelldata.icon_alliance
		elseif spelldata.icon_horde and faction == "Horde" then
			icon = spelldata.icon_horde
		else
			icon = spelldata.icon
		end

		-- set border color
		local c

		-- for _, key in ipairs(cat_priority) do
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
		frame:Show()

		sidx = sidx + 1
		shown = shown + 1
		if sidx > #gs.frame[unit] or shown >= db.cooldownsMax then
			break
		end
	end

	-- hide unused icons
	for i = sidx, #gs.frame[unit] do
		gs.frame[unit][i]:Hide()
	end
end

function Cooldowns:UpdateGroupIcons(group, unit)
	local gs = GetGroupState(group)
	local db = GetGroupDB(group)
	if not gs.frame[unit] then return end

	local _debugstart = GladiusEx:IsDebugging() and debugprofilestop()

	-- get spells lists
	local sorted_spells = GetCooldownList(group, unit)

	-- update icon frames
	UpdateGroupIconFrames(group, unit, sorted_spells)

	if GladiusEx:IsDebugging() then
		local _debugstop = GladiusEx:IsDebugging() and debugprofilestop()
		GladiusEx:Log("UpdateIcons for", group, "/", unit, "done in", _debugstop - _debugstart)
	end
end

local function CreateCooldownFrame(name, parent)
	local frame = CreateFrame("Frame", name, parent)
	frame.icon = frame:CreateTexture(nil, "BORDER") -- bg
	frame.icon:SetPoint("CENTER")

	frame.border = frame:CreateTexture(nil, "BACKGROUND") -- overlay
	frame.border:SetPoint("CENTER")
	frame.border:SetTexture(1, 1, 1, 1)

	frame.cooldown = CreateFrame("Cooldown", nil, frame)
	frame.cooldown:SetAllPoints(frame.icon)
	frame.cooldown:SetReverse(true)
	frame.cooldown:Hide()

	frame.count = frame:CreateFontString(nil, "OVERLAY")
	frame.count:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.globalFont), 10, "OUTLINE")
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

local function UpdateCooldownFrame(frame, size, crop)
	local border_size = crop and 3 or 2
	frame:SetSize(size, size)
	frame.icon:SetSize(size - border_size - 0.5, size - border_size - 0.5)
	if crop then
		frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	else
		frame.icon:SetTexCoord(0, 1, 0, 1)
	end
	frame.border:SetSize(size, size)
end

function Cooldowns:CreateFrame(unit)
	for group = 1, GetNumGroups() do
		self:CreateGroupFrame(group, unit)
	end
end

function Cooldowns:CreateGroupFrame(group, unit)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	local gs = GetGroupState(group)
	
	-- create cooldown frame
	if not gs.frame[unit] then
		gs.frame[unit] = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. "frame" .. unit, button)
		gs.frame[unit]:EnableMouse(false)

		for i = 1, MAX_ICONS do
			gs.frame[unit][i] = CreateCooldownFrame("GladiusEx" .. self:GetName() .. "frameIcon" .. i .. unit, gs.frame[unit])
			gs.frame[unit][i]:SetScript("OnUpdate", CooldownFrame_OnUpdate)
			gs.frame[unit][i]:Hide()
		end
	end
end

-- yeah this parameter list sucks
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
	cooldownSpacingX,
	cooldownSpacingY,
	cooldownMax,
	cooldownCrop)

	-- anchor point
	local parent = GladiusEx:GetAttachFrame(unit, cooldownAttachTo)
	cooldownFrame:ClearAllPoints()
	cooldownFrame:SetPoint(cooldownAnchor, parent, cooldownRelativePoint, cooldownOffsetX, cooldownOffsetY)

	-- size
	cooldownFrame:SetWidth(cooldownSize*cooldownPerColumn+cooldownSpacingX*cooldownPerColumn)
	cooldownFrame:SetHeight(cooldownSize*ceil(cooldownMax/cooldownPerColumn)+(cooldownSpacingY*(ceil(cooldownMax/cooldownPerColumn)+1)))

	-- backdrop
	-- cooldownFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,})
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
				anchor, parent, relativePoint, offsetX, offsetY = grow1, cooldownFrame[i-1], grow3, string.find(cooldownGrow, "LEFT") and -cooldownSpacingX or cooldownSpacingX, 0
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
		UpdateCooldownFrame(cooldownFrame[i], cooldownSize, cooldownCrop)
	end
end

function Cooldowns:Update(unit)
	for group = 1, GetNumGroups() do
		self:UpdateGroup(group, unit)
	end
	-- hide excess groups after one is deleted
	for group = GetNumGroups() + 1, #group_state do
		if group_state[group].frame[unit] then
			group_state[group].frame[unit]:Hide()
		end
	end
end

function Cooldowns:UpdateGroup(group, unit)
	-- create frame
	self:CreateGroupFrame(group, unit)

	local db = GetGroupDB(group)
	local gs = GetGroupState(group)

	-- update cooldown frame
	UpdateCooldownGroup(gs.frame[unit], unit,
		db.cooldownsAttachTo,
		db.cooldownsAnchor,
		db.cooldownsRelativePoint,
		db.cooldownsOffsetX,
		db.cooldownsOffsetY,
		db.cooldownsPerColumn,
		db.cooldownsGrow,
		db.cooldownsSize,
		db.cooldownsSpacingX,
		db.cooldownsSpacingY,
		db.cooldownsMax,
		db.cooldownsCrop)

	-- update icons
	self:UpdateIcons(unit)

	-- hide
	gs.frame[unit]:Hide()
end

function Cooldowns:Show(unit)
	for group = 1, GetNumGroups() do
		local gs = GetGroupState(group)
		if gs.frame[unit] and not gs.frame[unit]:IsShown() then
			gs.frame[unit]:Show()
			CT:RegisterUnit(unit)
		end
	end
end

function Cooldowns:Reset(unit)
	for group = 1, GetNumGroups() do
		local gs = GetGroupState(group)
		if gs.frame[unit] then
			if gs.frame[unit]:IsShown() then
				CT:UnregisterUnit(unit)
			end

			-- hide cooldown frame
			gs.frame[unit]:Hide()

			for i = 1, #gs.frame[unit] do
				gs.frame[unit][i]:Hide()
			end
		end
	end
end

function Cooldowns:Test(unit)
	self:UpdateIcons(unit)
end

function Cooldowns:GetOptions()
	local options = {}

	options.sep = {
		type = "description",
		name = "",
		width = "full",
		order = 1,
	}
	options.addgroup = {
		type = "execute",
		name = L["Add Cooldowns Group"],
		desc = L["Add Cooldowns Group"],
		func = function()
			local gdb = MakeGroupDb({
				cooldownsGroupId = MakeGroupId(),
				cooldownsSpells = { [42292] = true },
			})
			local group_idx = AddGroup(gdb)
			options["group" .. group_idx] = self:MakeGroupOptions(group_idx)
			GladiusEx:UpdateFrames()
		end,
		order = 2,
	}

	-- fill groups so that even if the module is reset there are enough
	-- options tables created (unsed ones are hidden)
	for group = 1, max(2, GetNumGroups()) do
		options["group" .. group] = self:MakeGroupOptions(group)
	end

	return options
end

local FormatSpellDescription

function Cooldowns:MakeGroupOptions(group)
	local group_options = {
		type = "group",
		name = L["Group"] .. group,
		childGroups = "tab",
		order = 10 + group,
		hidden = function() return GetNumGroups() < group end,
		get = function(info)
			return (info.arg and GetGroupDB(group)[info.arg] or GetGroupDB(group)[info[#info]])
		end,
		set = function(info, value)
			local key = info[#info]
			GetGroupDB(group)[key] = value
			GladiusEx:UpdateFrames()
		end,
		args = {
		general = {
			type = "group",
			name = L["General"],
			order = 1,
			args = {
					remgroup = {
						type = "execute",
						name = L["Remove This Group"],
						desc = L["Remove This Group"],
						func = function()
							RemoveGroup(group)
							GladiusEx:UpdateFrames()
						end,
						order = 0,
					},
					widget = {
						type = "group",
						name = L["Widget"],
						desc = L["Widget settings"],
						inline = true,
						order = 1,
						args = {
							cooldownsGrow = {
								type = "select",
								name = L["Cooldowns Column Grow"],
								desc = L["Grow direction of the cooldowns"],
								values = function() return {
										["UPLEFT"] = L["Up Left"],
										["UPRIGHT"] = L["Up Right"],
										["DOWNLEFT"] = L["Down Left"],
										["DOWNRIGHT"] = L["Down Right"],
								}
								end,
								disabled = function() return not self:IsEnabled() end,
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
								name = L["Crop Borders"],
								desc = L["Toggle if the class icon borders should be cropped or not."],
								disabled = function() return not self:IsEnabled() end,
								hidden = function() return not GladiusEx.db.advancedOptions end,
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
								name = L["Cooldown Icons Per Column"],
								desc = L["Number of cooldown icons per column"],
								min = 1, max = 50, step = 1,
								disabled = function() return not self:IsEnabled() end,
								order = 15,
							},
							cooldownsMax = {
								type = "range",
								name = L["Cooldown Icons Max"],
								desc = L["Number of max cooldowns"],
								min = 1, max = MAX_ICONS, step = 1,
								disabled = function() return not self:IsEnabled() end,
								order = 20,
							},
							sep3 = {
								type = "description",
								name = "",
								width = "full",
								order = 23,
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
									name = L["Cooldown Icon Size"],
									desc = L["Size of the cooldown icons"],
									min = 10, max = 100, step = 1,
									disabled = function() return not self:IsEnabled() end,
									order = 5,
								},
								sep = {
									type = "description",
									name = "",
									width = "full",
									order = 13,
								},
								cooldownsSpacingY = {
									type = "range",
									name = L["Cooldowns Spacing Vertical"],
									desc = L["Vertical spacing of the cooldowns"],
									min = 0, max = 30, step = 1,
									disabled = function() return not self:IsEnabled() end,
									order = 15,
								},
								cooldownsSpacingX = {
									type = "range",
									name = L["Cooldowns Spacing Horizontal"],
									desc = L["Horizontal spacing of the cooldowns"],
									disabled = function() return not self:IsEnabled() end,
									min = 0, max = 30, step = 1,
									order = 20,
								},
							},
						},
						position = {
							type = "group",
							name = L["Position"],
							desc = L["Position settings"],
							inline = true,
							hidden = function() return not GladiusEx.db.advancedOptions end,
							order = 3,
							args = {
								cooldownsAttachTo = {
									type = "select",
									name = L["Cooldowns Attach To"],
									desc = L["Attach cooldowns to the given frame"],
									values = function() return Cooldowns:GetAttachPoints() end,
									disabled = function() return not self:IsEnabled() end,
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
									name = L["Cooldowns Anchor"],
									desc = L["Anchor of the cooldowns"],
									values = function() return GladiusEx:GetPositions() end,
									disabled = function() return not self:IsEnabled() end,
									order = 10,
								},
								cooldownsRelativePoint = {
									type = "select",
									name = L["Cooldowns Relative Point"],
									desc = L["Relative point of the cooldowns"],
									values = function() return GladiusEx:GetPositions() end,
									disabled = function() return not self:IsEnabled() end,
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
									name = L["Cooldowns Offset X"],
									desc = L["X offset of the cooldowns"],
									min = -100, max = 100, step = 1,
									disabled = function() return not self:IsEnabled() end,
									order = 20,
								},
								cooldownsOffsetY = {
									type = "range",
									name = L["Cooldowns Offset Y"],
									desc = L["Y offset of the cooldowns"],
									disabled = function() return not self:IsEnabled() end,
									min = -50, max = 50, step = 1,
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
					cooldownsHideTalentsUntilDetected = {
						type = "toggle",
						name = L["Hide talents until detected"],
						width = "full",
						order = 1
					},
					priorities = {
						type = "group",
						name = L["Categories"],
						inline = true,
						order = 4,
						args = {},
					},
				},
			},
			cooldowns = {
				type = "group",
				name = L["Cooldowns"],
				order = 3,
				args = {
					enableall = {
						type = "execute",
						name = L["Enable all"],
						desc = L["Enable all the spells"],
						func = function()
							for spellid, spelldata in pairs(CT:GetCooldownsData()) do
								if type(spelldata) == "table" then
									GetGroupDB(group).cooldownsSpells[spellid] = true
								end
							end
							GladiusEx:UpdateFrames()
						end,
						order = 0,
					},
					disableall = {
						type = "execute",
						name = L["Disable all"],
						desc = L["Disable all the spells"],
						func = function()
							for spellid, spelldata in pairs(CT:GetCooldownsData()) do
								if type(spelldata) == "table" then
									GetGroupDB(group).cooldownsSpells[spellid] = false
								end
							end
							GladiusEx:UpdateFrames()
						end,
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

	-- fill spell priority list
	-- yeah, all of this sucks
	local pargs = group_options.args.category_options.args.priorities.args
	for i = 1, #GetGroupDB(group).cooldownsCatPriority do
		local cat = GetGroupDB(group).cooldownsCatPriority[i]
		local option = {
			type = "group",
			name = L["cat:" .. cat],
			order = function()
				for i = 1, #GetGroupDB(group).cooldownsCatPriority do
					if GetGroupDB(group).cooldownsCatPriority[i] == cat then return i end
				end
			end,
			inline = true,
			args = {
				color = {
					type = "color",
					name = L["Color"],
					desc = L["Border color for spells in this category"],
					get = function()
						local c = GetGroupDB(group).cooldownsCatColors[cat]
						return c.r, c.g, c.b
					end,
					set = function(self, r, g, b)
						GetGroupDB(group).cooldownsCatColors[cat] = { r = r, g = g, b = b }
						GladiusEx:UpdateFrames()
					end,
					order = 0,
				},
				group = {
					type = "range",
					min = 1,
					max = 20,
					step = 1,
					name = L["Group"],
					desc = L["Spells in each group have their own row or column"],
					get = function() return GetGroupDB(group).cooldownsCatGroups[cat] end,
					set = function(self, value)
						GetGroupDB(group).cooldownsCatGroups[cat] = value
						GladiusEx:UpdateFrames()
					end,
					order = 1,
				},
				moveup = {
					type = "execute",
					name = L["Up"],
					desc = L["Increase the priority of spells in this category"],
					func = function()
						for i = 1, #GetGroupDB(group).cooldownsCatPriority do
							if GetGroupDB(group).cooldownsCatPriority[i] == cat then
								if i ~= 1 then
									local tmp = GetGroupDB(group).cooldownsCatPriority[i - 1]
									GetGroupDB(group).cooldownsCatPriority[i - 1] = GetGroupDB(group).cooldownsCatPriority[i]
									GetGroupDB(group).cooldownsCatPriority[i] = tmp

									self:SpellSortingChanged()
									GladiusEx:UpdateFrames()
								end
								return
							end
						end
					end,
					order = 10,
				},
				movedown = {
					type = "execute",
					name = L["Down"],
					desc = L["Decrease the priority of spells in this category"],
					func = function()
						for i = 1, #GetGroupDB(group).cooldownsCatPriority do
							if GetGroupDB(group).cooldownsCatPriority[i] == cat then
								if i ~= #GetGroupDB(group).cooldownsCatPriority then
									local tmp = GetGroupDB(group).cooldownsCatPriority[i + 1]
									GetGroupDB(group).cooldownsCatPriority[i + 1] = GetGroupDB(group).cooldownsCatPriority[i]
									GetGroupDB(group).cooldownsCatPriority[i] = tmp

									self:SpellSortingChanged()
									GladiusEx:UpdateFrames()
								end
								return
							end
						end
					end,
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
									GetGroupDB(group).cooldownsSpells[spellid] = true
								end
							end
						end
						GladiusEx:UpdateFrames()
					end,
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
									GetGroupDB(group).cooldownsSpells[spellid] = false
								end
							end
						end
						GladiusEx:UpdateFrames()
					end,
					order = 21,
				},
			}
		}
		pargs[cat] = option
	end


	-- fill spell data
	local function getSpell(info)
		return GetGroupDB(group).cooldownsSpells[info.arg]
	end

	local function setSpell(info, value)
		GetGroupDB(group).cooldownsSpells[info.arg] = value
		GladiusEx:UpdateFrames()
	end

	local lclasses = {}
	FillLocalizedClassList(lclasses)

	local args = group_options.args.cooldowns.args
	for spellid, spelldata in pairs(CT:GetCooldownsData()) do
		if type(spelldata) == "table" then
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
				order = spelldata.name:byte(1) * 0xff + spelldata.name:byte(2),
			}
			if spelldata.class then
				if not args[spelldata.class] then
					args[spelldata.class] = {
						type = "group",
						name = lclasses[spelldata.class],
						icon = [[Interface\ICONS\ClassIcon_]] .. spelldata.class,
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
								order = 3 + specID,
								args = {}
							}
						end
						args[spelldata.class].args["spec" .. specID].args["spell"..spellid] = spellconfig
					end
				elseif spelldata.talent then
					-- talent
					if not args[spelldata.class].args.talents then
						args[spelldata.class].args.talents = {
							type = "group",
							name = "Talents",
							order = 2,
							args = {}
						}
					end
					args[spelldata.class].args.talents.args["spell"..spellid] = spellconfig
				else
					-- baseline
					if not args[spelldata.class].args.base then
						args[spelldata.class].args.base = {
							type = "group",
							name = "Baseline",
							order = 1,
							args = {}
						}
					end
					args[spelldata.class].args.base.args["spell"..spellid] = spellconfig
				end
			elseif spelldata.race then
				-- racial
				if not args[spelldata.race] then
					args[spelldata.race] = {
						type = "group",
						name = spelldata.race,
						icon = function() return [[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT]] .. (random(0, 1) == 0 and "-FEMALE-" or "-MALE-") .. spelldata.race end,
						order = 3,
						args = {}
					}
				end
				args[spelldata.race].args["spell"..spellid] = spellconfig
			elseif spelldata.item then
				-- item
				if not args.items then
					args.items = {
						type = "group",
						name = L["Items"],
						icon = [[Interface\Icons\Trade_Engineering]],
						order = 5,
						args = {}
					}
				end
				args.items.args["spell"..spellid] = spellconfig
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
		assert(read(9) == "spelldesc")
		local spellid = read_number()
		return FormatSpellDescription(spellid)
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
