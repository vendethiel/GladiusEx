local GladiusEx = _G.GladiusEx
if not GladiusEx then
  DEFAULT_CHAT_FRAME:AddMessage(format("Module %s requires Gladius", "Cooldowns"))
end
local L = GladiusEx.L
local LSM

-- global functions
local tinsert, tsort = table.insert, table.sort
local pairs, ipairs, select, type = pairs, ipairs, select, type
local min, max = math.min, math.max
local GetTime, UnitExists, UnitFactionGroup, UnitRace = GetTime, UnitExists, UnitFactionGroup, UnitRace
local UnitGUID = UnitGUID
 

local SpellData = GladiusEx.CooldownsSpellData
local guid_to_unitid = {} -- [guid] = unitid
local tracked_players = {} -- [unit][spellid] = cd start time


local Cooldowns = GladiusEx:NewGladiusExModule("Cooldowns", false, {
	cooldownsAttachTo = "CastBarIcon",
	cooldownsAnchor = "TOPLEFT",
	cooldownsRelativePoint = "BOTTOMLEFT",
	cooldownsGrow = "DOWNRIGHT",
	cooldownsSpacingX = 0,
	cooldownsSpacingY = 0,
	cooldownsPerColumn = 8,
	cooldownsMax = 40,
	cooldownsSize = 23,
	cooldownsOffsetX = 0,
	cooldownsOffsetY = 0,
	cooldownsGloss = false,
	cooldownsGlossColor = { r = 1, g = 1, b = 1, a = 0.4 },
	cooldownsSpells = { ["*"] = true },
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
		["uncat"]      =    { r = 1.0, g = 1.0, b = 1.0 },
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
		["uncat"]      =    1,
	},
	cooldownsHideTalentsUntilDetected = true,
})

local MAX_ICONS = 40

function Cooldowns:OnEnable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterMessage("GLADIUS_SPEC_UPDATE")

	LSM = GladiusEx.LSM

	self.frame = self.frame or {}
end

function Cooldowns:OnDisable()
	self:UnregisterAllEvents()
	self:Reset()
end

function Cooldowns:GetAttachTo()
	return GladiusEx.db.cooldownsAttachTo
end

function Cooldowns:GetModuleAttachPoints()
	return {
		["Cooldowns"] = L["Cooldowns"],
	}
end

function Cooldowns:GetAttachFrame(unit, point)
	if not self.frame[unit] then
		self:CreateFrame(unit)
	end
	return self.frame[unit]
end

function Cooldowns:PLAYER_ENTERING_WORLD()
	local instanceType = select(2, IsInInstance())

	-- reset cooldowns when joining an arena
	if instanceType == "arena" then
		tracked_players = {}
		self:UpdateAllIcons()
	end
end

function Cooldowns:UNIT_SPELLCAST_SUCCEEDED(event, unit, spellName, rank, lineaID, spellId)
	self:CooldownUsed("SPELL_CAST_SUCCESS", unit, spellId)
end

function Cooldowns:COMBAT_LOG_EVENT_UNFILTERED(_, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool)
	if not guid_to_unitid[sourceGUID] then return end
	local spelldata = SpellData[spellId]
	if not spelldata then return end

	if event == "SPELL_DISPEL" or
	   event == "SPELL_AURA_REMOVED" or
	   event == "SPELL_AURA_APPLIED" or
	   event == "SPELL_CAST_SUCCESS" then
		self:CooldownUsed(event, guid_to_unitid[sourceGUID], spellId)
	end
end

function Cooldowns:GLADIUS_SPEC_UPDATE(event, unit)
	self:UpdateIcons(unit)
end

function Cooldowns:UNIT_NAME_UPDATE(event, unit)
	-- hopefully at this point the opponent's faction is known
	self:UpdateIcons(unit)
end

function Cooldowns:CooldownUsed(event, unit, spellId)
	local spelldata = SpellData[spellId]
	if not spelldata then return end

	if type(spelldata) == "number" then
		spellId = spelldata
		spelldata = SpellData[spelldata]
	end

	if self.frame[unit] then
		local now = GetTime()

		if not tracked_players[unit] then
			tracked_players[unit] = {}
		end

		local tpu = tracked_players[unit]

		-- check if the same spell cast was detected recently
		-- if so, we assume that the first detection time is more accurate and ignore this one
		if tpu[spellId] then
			if (event == "SPELL_CAST_SUCCESS" or event == "SPELL_AURA_APPLIED") and (
				(tpu[spellId]["SPELL_AURA_APPLIED"] and (tpu[spellId]["SPELL_AURA_APPLIED"] + 3) > now) or
				(tpu[spellId]["SPELL_CAST_SUCCESS"] and (tpu[spellId]["SPELL_CAST_SUCCESS"] + 3) > now))
				then
				return
			end
		else
			tpu[spellId] = { detected = true }
		end

		tpu[spellId][event] = now

		-- find what actions are needed
		local used_start, used_end, cooldown_start

		if spelldata.cooldown_starts_on_dispel then
			if event == "SPELL_DISPEL" then
				used_start = true
				cooldown_start = true
			end
		elseif spelldata.cooldown_starts_on_aura_fade then
			if event == "SPELL_CAST_SUCCESS" or event == "SPELL_AURA_APPLIED" then
				used_start = true
			elseif event == "SPELL_AURA_REMOVED" then
				cooldown_start = true
			end
		else
			if event == "SPELL_CAST_SUCCESS" or event == "SPELL_AURA_APPLIED" then
				used_start = true
				cooldown_start = true
			elseif event == "SPELL_AURA_REMOVED" then
				used_end = true
			end
		end

		-- print(UnitName(unit), "used", spelldata.name, "cooldown:", spelldata.cooldown, used_start, used_end, cooldown_start)
		if used_start then
			tpu[spellId].used_start = now
			tpu[spellId].used_end = spelldata.duration and (now + spelldata.duration)

			-- reset other cooldowns (Cold Snap, Preparation)
			if spelldata.resets then
				for i = 1, #spelldata.resets do
					local rspellid = spelldata.resets[i]
					if tpu[rspellid] then
						tpu[rspellid].cooldown_start = 0
						tpu[rspellid].cooldown_end = 0
					end
				end
			end
		end
		if used_end then
			tpu[spellId].used_end = now
		end

		if cooldown_start then
			tpu[spellId].cooldown_start = spelldata.cooldown and now
			tpu[spellId].cooldown_end = spelldata.cooldown and (now + spelldata.cooldown)

			-- set other cooldowns
			if spelldata.sets_cooldown then
				local cspellid = spelldata.sets_cooldown.spellid
				local cspelldata = SpellData[cspellid]
				if (tpu[cspellid] and tpu[cspellid].detected) or (not cspelldata.talent and not cspelldata.glyph) then
					if not tpu[cspellid] then
						tpu[cspellid] = {}
					end
					if not tpu[cspellid].cooldown_end or (tpu[cspellid].cooldown_end < (now + spelldata.sets_cooldown.cooldown)) then
						tpu[cspellid].cooldown_start = now
						tpu[cspellid].cooldown_end = now + spelldata.sets_cooldown.cooldown
						tpu[cspellid].used_start = tpu[cspellid].used_start or 0
						tpu[cspellid].used_end = tpu[cspellid].used_end or 0
					end
				end
			end
		end

		self:UpdateIcons(unit)
	end
end

local function CooldownFrame_OnUpdate(frame)
	local tracked = frame.tracked
	local now = GetTime()

	if tracked then
		if tracked.used_start and ((not tracked.used_end and not tracked.cooldown_start) or (tracked.used_end and tracked.used_end > now)) then
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
			if frame.state ~= 2 then
				frame.border:SetVertexColor(frame.color.r, frame.color.g, frame.color.b, 1.0)
				frame:SetAlpha(1)
				frame.cooldown:Hide()
				frame.state = 2
			end
			return
		end
		if tracked.cooldown_end and tracked.cooldown_end > now then
			if frame.state ~= 3 then
				frame.cooldown:SetReverse(false)
				frame.cooldown:SetCooldown(tracked.cooldown_start, tracked.cooldown_end - tracked.cooldown_start)
				frame.border:SetVertexColor(frame.color.r, frame.color.g, frame.color.b, 0.5)
				frame:SetAlpha(0.2)
				frame.cooldown:Show()
				frame.state = 3
			end
			return
		end
	end

 	frame.tracked = nil
	frame.cooldown:Hide()
	frame.border:SetVertexColor(frame.color.r, frame.color.g, frame.color.b, 0.3)
	frame:SetAlpha(1)
	frame:SetScript("OnUpdate", nil)
end

local function SpellSortingChanged()
	-- remove cached sorting info from spells
	for spellid, spelldata in pairs(SpellData) do
		if type(spelldata) == "table" then
			spelldata.sortscore = nil
		end
	end
end

local function GetSpellSortScore(spellid)
	local spelldata = SpellData[spellid]
	
	if spelldata.replaces then
		spellid = spelldata.replaces
		spelldata = SpellData[spelldata.replaces]
	end

	if spelldata.sortscore then
		return spelldata.sortscore
	end

	local cat_priority = GladiusEx.db.cooldownsCatPriority

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

	spelldata.sortscore = score

	return score
end

local function UpdateIcons_AddSpell(spell_list, unit, spellid, spelldata)
	if not GladiusEx.db.cooldownsSpells[spellid] then
		return
	end

	if (not spelldata.glyph and not spelldata.talent) or (tracked_players[unit][spellid] and tracked_players[unit][spellid].detected) or not GladiusEx.db.cooldownsHideTalentsUntilDetected then
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

function Cooldowns:UpdateIcons(unit)
	if not self.frame[unit] then return end
	if not tracked_players[unit] then tracked_players[unit] = {} end

	local _debugstart = debugprofilestop()

	local now = GetTime()

	local specID, class, race, faction
	if GladiusEx:IsTesting() and not UnitExists(unit) then
		specID = GladiusEx.testing[unit].specID
		class = GladiusEx.testing[unit].unitClass
		race = GladiusEx.testing[unit].unitRace
		faction = (UnitFactionGroup("player") == "Alliance" and GladiusEx:IsPartyUnit(unit)) and "Alliance" or "Horde"
	else
		specID = GladiusEx.buttons[unit].specID
		class = GladiusEx.buttons[unit].class
		race = select(2, UnitRace(unit))
		faction = UnitFactionGroup(unit)
	end

	-- generate list of cooldowns available for this unit
	local spell_list = {}

	for spellid, spelldata in pairs(SpellData) do
		-- ignore references to other spells
		if type(spelldata) ~= "number" then
			if class and class == spelldata.class then
				if specID and spelldata.specID and spelldata.specID[specID] then
					-- add spec
					UpdateIcons_AddSpell(spell_list, unit, spellid, spelldata)
				elseif not spelldata.specID then
					-- add base
					UpdateIcons_AddSpell(spell_list, unit, spellid, spelldata)
				end
			end

			if race and race == spelldata.race then
				-- add racial
				UpdateIcons_AddSpell(spell_list, unit, spellid, spelldata)
			end

			if spelldata.item then
				-- add item
				UpdateIcons_AddSpell(spell_list, unit, spellid, spelldata)
			end
		end
	end

	-- sort spells
	local sorted_spells = {}
	for spellid, valid in pairs(spell_list) do	
		if valid then
			tinsert(sorted_spells, spellid)
		end
	end

	tsort(sorted_spells,
		function(a, b)
			return GetSpellSortScore(a) > GetSpellSortScore(b)
		end)

	-- update icons
	local cat_priority = GladiusEx.db.cooldownsCatPriority
	local border_color = GladiusEx.db.cooldownsCatColors
	local cat_groups = GladiusEx.db.cooldownsCatGroups
	local cooldownsPerColumn = GladiusEx.db.cooldownsPerColumn

	local sidx = 1
	local shown = 0
	local prev_group
	for i = 1, #sorted_spells do
		local spellid = sorted_spells[i]
		local spelldata = SpellData[spellid]
		local tracked = tracked_players[unit][spellid]
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
					self.frame[unit][sidx]:Hide()
					sidx = sidx + 1
					if sidx > #self.frame[unit] then
						return
					end
				end
			end
		end
		prev_group = group
		local frame = self.frame[unit][sidx]

		if spelldata.icon_alliance and faction == "Alliance" then
			icon = spelldata.icon_alliance
		elseif spelldata.icon_horde and faction == "Horde" then
			icon = spelldata.icon_horde
		else
			icon = spelldata.icon
		end

		-- set border color
		local c
		for _, key in ipairs(cat_priority) do
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
		if sidx > #self.frame[unit] or shown >= GladiusEx.db.cooldownsMax then
			break
		end
	end

	-- hide unused icons
	for i = sidx, #self.frame[unit] do
		local frame = self.frame[unit][i]
		frame:Hide()
	end

	local _debugstop = debugprofilestop()
	-- print("UpdateIcons for", unit, "done in", _debugstop - _debugstart)
end

function Cooldowns:UpdateAllIcons()
	for unitid, _ in pairs(self.frame) do
		self:UpdateIcons(unitid)
	end
end

local function CreateCooldownFrame(name, parent)
	local frame = CreateFrame("Frame", name, parent)
	frame.icon = frame:CreateTexture(nil, "BORDER") -- bg
	frame.icon:SetPoint("CENTER")
	frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

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

local function UpdateCooldownFrame(frame, size)
	local border_size = 3
	frame:SetSize(size, size)
	frame.icon:SetSize(size - border_size - 0.5, size - border_size - 0.5)
	frame.border:SetSize(size, size)
end

function Cooldowns:CreateFrame(unit)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	-- create cooldown frame
	if not self.frame[unit] then
		self.frame[unit] = CreateFrame("Frame", "Gladius" .. self.name .. "frame" .. unit, button)
		self.frame[unit]:EnableMouse(false)

		for i=1, MAX_ICONS do
			self.frame[unit][i] = CreateCooldownFrame("Gladius" .. self.name .. "frameIcon" .. i .. unit, self.frame[unit])
			self.frame[unit][i]:SetScript("OnUpdate", CooldownFrame_OnUpdate)
			self.frame[unit][i]:Hide()
		end
	end
end

-- yeah this parameter list sucks
function Cooldowns:UpdateCooldownGroup(
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
	cooldownMax)

	cooldownFrame:ClearAllPoints()

	-- anchor point 
	local parent = GladiusEx:GetAttachFrame(unit, cooldownAttachTo)
	cooldownFrame:SetPoint(cooldownAnchor, parent, cooldownRelativePoint, cooldownOffsetX, cooldownOffsetY)

	-- size
	cooldownFrame:SetWidth(cooldownSize*cooldownPerColumn+cooldownSpacingX*cooldownPerColumn)
	cooldownFrame:SetHeight(cooldownSize*math.ceil(cooldownMax/cooldownPerColumn)+(cooldownSpacingY*(math.ceil(cooldownMax/cooldownPerColumn)+1)))

	-- icon points
	local anchor, parent, relativePoint, offsetX, offsetY
	local start, startAnchor = 1, cooldownFrame

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

	for i=1, #cooldownFrame do
		cooldownFrame[i]:ClearAllPoints()

		if (cooldownMax >= i) then
			if (start == 1) then
			anchor, parent, relativePoint, offsetX, offsetY = grow1, startAnchor, startRelPoint, 0, string.find(cooldownGrow, "DOWN") and -cooldownSpacingY or cooldownSpacingY
			else
			anchor, parent, relativePoint, offsetX, offsetY = grow1, cooldownFrame[i-1], grow3, string.find(cooldownGrow, "LEFT") and -cooldownSpacingX or cooldownSpacingX, 0

			if (start == cooldownPerColumn) then
				start = 0
				startAnchor = cooldownFrame[i - cooldownPerColumn + 1]
				startRelPoint = grow2
			end
			end

			start = start + 1
		end

		cooldownFrame[i]:SetPoint(anchor, parent, relativePoint, offsetX, offsetY)

		UpdateCooldownFrame(cooldownFrame[i], cooldownSize)
	end
end

function Cooldowns:UpdateGUID(unit)
	-- find and delete old reference to that unit
	for guid, unitid in pairs(guid_to_unitid) do
		if unitid == unit then
			guid_to_unitid[guid] = nil
			break
		end
	end

	local guid = UnitGUID(unit)
	if guid then
		guid_to_unitid[guid] = unit
	end
end

function Cooldowns:Update(unit)
	-- create frame
	if not self.frame[unit] then 
		self:CreateFrame(unit)
	end

	-- update guid
	self:UpdateGUID(unit)

	-- update cooldown frame 
	self:UpdateCooldownGroup(self.frame[unit], unit,
		GladiusEx.db.cooldownsAttachTo,
		GladiusEx.db.cooldownsAnchor,
		GladiusEx.db.cooldownsRelativePoint,
		GladiusEx.db.cooldownsOffsetX,
		GladiusEx.db.cooldownsOffsetY,
		GladiusEx.db.cooldownsPerColumn,
		GladiusEx.db.cooldownsGrow,
		GladiusEx.db.cooldownsSize,
		GladiusEx.db.cooldownsSpacingX,
		GladiusEx.db.cooldownsSpacingY,
		GladiusEx.db.cooldownsMax)

	-- update icons
	self:UpdateIcons(unit)

	-- hide
	self.frame[unit]:Hide()
end

function Cooldowns:Show(unit)
	self:UpdateGUID(unit)

	if self.frame[unit] then 
		self.frame[unit]:Show()
	end
end

function Cooldowns:Reset(unit) 
	self:UpdateGUID(unit)

	if self.frame[unit] then 
		-- hide cooldown frame
		self.frame[unit]:Hide()

		for i = 1, #self.frame[unit] do
			self.frame[unit][i]:Hide()
		end
	end
end

function Cooldowns:Test(unit)
	self:UpdateIcons(unit)
end

function Cooldowns:GetOptions()
	local options = {
		cooldowns = {  
			type="group",
			name=L["Cooldowns"],
			childGroups="tab",
			order=1,
			args = {
			general = {  
				type="group",
				name=L["General"],
				order=1,
				args = {
						widget = {
						type="group",
						name=L["Widget"],
						desc=L["Widget settings"],  
						inline=true,
						order=1,
						args = { 
						cooldownsGrow = {
							type="select",
							name=L["Cooldowns Column Grow"],
							desc=L["Grow direction of the cooldowns"],
							values=function() return {
									["UPLEFT"] = L["Up Left"],
									["UPRIGHT"] = L["Up Right"],
									["DOWNLEFT"] = L["Down Left"],
									["DOWNRIGHT"] = L["Down Right"],
							}
							end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
							order=10,
						}, 
						sep = {
							type = "description",
							name="",
							width="full",
							order=13,
						},
						cooldownsPerColumn = {
							type="range",
							name=L["Cooldown Icons Per Column"],
							desc=L["Number of cooldown icons per column"],
							min=1, max=50, step=1,
							disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
							order=15,
						},
						cooldownsMax = {
							type="range",
							name=L["Cooldown Icons Max"],
							desc=L["Number of max cooldowns"],
							min=1, max=MAX_ICONS, step=1,
							disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
							order=20,
						},  
						sep2 = {
							type = "description",
							name="",
							width="full",
							order=23,
						},
					},
				},
				size = {
					type="group",
					name=L["Size"],
					desc=L["Size settings"],  
					inline=true,
					order=2,
					args = {
							cooldownsSize = {
								type="range",
								name=L["Cooldown Icon Size"],
								desc=L["Size of the cooldown icons"],
								min=10, max=100, step=1,
								disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
								order=5,
							},
							sep = {
								type = "description",
								name="",
								width="full",
								order=13,
							},
							cooldownsSpacingY = {
								type="range",
								name=L["Cooldowns Spacing Vertical"],
								desc=L["Vertical spacing of the cooldowns"],
								min=0, max=30, step=1,
								disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
								order=15,
							},
							cooldownsSpacingX = {
								type="range",
								name=L["Cooldowns Spacing Horizontal"],
								desc=L["Horizontal spacing of the cooldowns"],
								disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
								min=0, max=30, step=1,
								order=20,
							},
						},
					},
					position = {
						type="group",
						name=L["Position"],
						desc=L["Position settings"],  
						inline=true,
						hidden=function() return not GladiusEx.db.advancedOptions end,
						order=3,
						args = {
							cooldownsAttachTo = {
								type="select",
								name=L["Cooldowns Attach To"],
								desc=L["Attach cooldowns to the given frame"],
								values=function() return Cooldowns:GetAttachPoints() end,
								disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
								width="double",
								order=5,
							},
							sep = {
								type = "description",
								name="",
								width="full",
								order=7,
							},
							cooldownsAnchor = {
								type="select",
								name=L["Cooldowns Anchor"],
								desc=L["Anchor of the cooldowns"],
								values=function() return GladiusEx:GetPositions() end,
								disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
								order=10,
							},
							cooldownsRelativePoint = {
								type="select",
								name=L["Cooldowns Relative Point"],
								desc=L["Relative point of the cooldowns"],
								values=function() return GladiusEx:GetPositions() end,
								disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
								order=15,
							},
							sep2 = {
								type = "description",
								name="",
								width="full",
								order=17,
							},
							cooldownsOffsetX = {
								type="range",
								name=L["Cooldowns Offset X"],
								desc=L["X offset of the cooldowns"],
								min=-100, max=100, step=1,
								disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
								order=20,
							},
							cooldownsOffsetY = {
								type="range",
								name=L["Cooldowns Offset Y"],
								desc=L["Y  offset of the cooldowns"],
								disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
								min=-50, max=50, step=1,
								order=25,
							},
							},
							},
					},
				},
				cooldown_options = {
					type="group",
					name=L["Category"],
					order=2,
					args = {
						cooldownsHideTalentsUntilDetected = {
							type="toggle",
							name=L["Hide talents until detected"],
							width="full",
							order=1
						},
						enableall = {
							type="execute",
							name=L["Enable all"],
							desc=L["Enable all the spells"],
							func=function()
								for spellid, spelldata in pairs(SpellData) do
									if type(spelldata) == "table" then
										GladiusEx.db.cooldownsSpells[spellid] = true
									end
								end
								self:UpdateAllIcons()
							end,
							order=2,
						},
						disableall = {
							type="execute",
							name=L["Disable all"],
							desc=L["Disable all the spells"],
							func=function()
								for spellid, spelldata in pairs(SpellData) do
									if type(spelldata) == "table" then
										GladiusEx.db.cooldownsSpells[spellid] = false
									end
								end
								self:UpdateAllIcons()
							end,
							order=3,
						},
						priorities = {
							type="group",
							name=L["Categories"],
							inline=true,
							order=4,
							args={},
						},
					},
				},
				cooldowns = {  
					type="group",
					name=L["Cooldowns"],
					order=3,
					args = {
						preracesep = {
							type="group",
							name="",
							order=2,
							args={}
						},
						preitemsep = {
							type="group",
							name="",
							order=4,
							args={}
						},
					},
				},
			},
		},
	}

	-- fill spell priority list
	-- yeah, all of this sucks
	local pargs = options.cooldowns.args.cooldown_options.args.priorities.args
	for i = 1, #GladiusEx.db.cooldownsCatPriority do
		local cat = GladiusEx.db.cooldownsCatPriority[i]
		local option = {
			type="group",
			name=L[cat],
			order=function()
				for i = 1, #GladiusEx.db.cooldownsCatPriority do
					if GladiusEx.db.cooldownsCatPriority[i] == cat then return i end
				end
			end,
			inline=true,
			args = {
				color = {
					type="color",
					name=L["Color"],
					desc=L["Border color for spells in this category"],
					get=function()
						local c = GladiusEx.db.cooldownsCatColors[cat]
						return c.r, c.g, c.b
					end,
					set=function(self, r, g, b)
						GladiusEx.db.cooldownsCatColors[cat] = { r = r, g = g, b = b }
						Cooldowns:UpdateAllIcons()
					end,
					order = 0,
				},
				group = {
					type="range",
					min=1,
					max=20,
					step=1,
					name=L["Group"],
					desc=L["Spells in each group have their own row or column"],
					get=function() return GladiusEx.db.cooldownsCatGroups[cat] end,
					set=function(self, value)
						GladiusEx.db.cooldownsCatGroups[cat] = value
						Cooldowns:UpdateAllIcons()
					end,
					order = 1,
				},
				moveup = {
					type="execute",
					name=L["Up"],
					desc=L["Increase the priority of spells in this category"],
					func=function()
						for i = 1, #GladiusEx.db.cooldownsCatPriority do
							if GladiusEx.db.cooldownsCatPriority[i] == cat then 
								if i ~= 1 then
									local tmp = GladiusEx.db.cooldownsCatPriority[i - 1]
									GladiusEx.db.cooldownsCatPriority[i - 1] = GladiusEx.db.cooldownsCatPriority[i]
									GladiusEx.db.cooldownsCatPriority[i] = tmp

									SpellSortingChanged()
									Cooldowns:UpdateAllIcons()
								end
								return
							end
						end
					end,
					order=10,
				},
				movedown = {
					type="execute",
					name=L["Down"],
					desc=L["Decrease the priority of spells in this category"],
					func=function()
						for i = 1, #GladiusEx.db.cooldownsCatPriority do
							if GladiusEx.db.cooldownsCatPriority[i] == cat then 
								if i ~= #GladiusEx.db.cooldownsCatPriority then
									local tmp = GladiusEx.db.cooldownsCatPriority[i + 1]
									GladiusEx.db.cooldownsCatPriority[i + 1] = GladiusEx.db.cooldownsCatPriority[i]
									GladiusEx.db.cooldownsCatPriority[i] = tmp

									SpellSortingChanged()
									Cooldowns:UpdateAllIcons()
								end
								return
							end
						end
					end,
					order=11,
				},
				enableall = {
					type="execute",
					name=L["Enable all"],
					desc=L["Enable all the spells in this category"],
					func=function()
						for spellid, spelldata in pairs(SpellData) do
							if type(spelldata) == "table" then
								if spelldata[cat] then
									GladiusEx.db.cooldownsSpells[spellid] = true
								end
							end
						end
						self:UpdateAllIcons()
					end,
					order=20,
				},
				disableall = {
					type="execute",
					name=L["Disable all"],
					desc=L["Disable all the spells in this category"],
					func=function()
						for spellid, spelldata in pairs(SpellData) do
							if type(spelldata) == "table" then
								if spelldata[cat] then
									GladiusEx.db.cooldownsSpells[spellid] = false
								end
							end
						end
						self:UpdateAllIcons()
					end,
					order=21,
				},
			}
		}
		pargs[cat] = option
	end


	-- fill spell data
	local function getSpell(info)
		return GladiusEx.db.cooldownsSpells[info.arg]
	end

	local function setSpell(info, value)
		GladiusEx.db.cooldownsSpells[info.arg] = value
		self:UpdateAllIcons()
	end

	local lclasses = {}
	FillLocalizedClassList(lclasses)

	local args = options.cooldowns.args.cooldowns.args
	for spellid, spelldata in pairs(SpellData) do
		if type(spelldata) == "table" then
			local basecd = GetSpellBaseCooldown(spellid)
			local cats = {}
			if spelldata.pvp_trinket then tinsert(cats, L["pvp_trinket"]) end
			if spelldata.cc then tinsert(cats, L["cc"]) end
			if spelldata.offensive then tinsert(cats, L["offensive"]) end
			if spelldata.defensive then tinsert(cats, L["defensive"]) end
			if spelldata.silence then tinsert(cats, L["silence"]) end
			if spelldata.interrupt then tinsert(cats, L["interrupt"]) end
			if spelldata.dispel then tinsert(cats, L["dispel"]) end
			if spelldata.mass_dispel then tinsert(cats, L["mass_dispel"]) end
			if spelldata.heal then tinsert(cats, L["heal"]) end
			if spelldata.knockback then tinsert(cats, L["knockback"]) end
			if spelldata.stun then tinsert(cats, L["stun"]) end
			if spelldata.immune then tinsert(cats, L["immune"]) end
			local catstr
			if #cats > 0 then
				catstr = "|cff7f7f7f(" .. strjoin(", ", unpack(cats)) .. ")|r"
			end

			local spellconfig = {
				type="toggle",
				name=string.format(" |T%s:20|t %s [%ss/%ss] %s", spelldata.icon, spelldata.name, spelldata.cooldown or "??", basecd and basecd/1000 or "??", catstr or ""),
				desc=GetSpellDescription(spellid),
				descStyle="inline",
				width="full",
				arg=spellid,
				get=getSpell,
				set=setSpell,
				order=spelldata.name:byte(1) * 0xff + spelldata.name:byte(2),
			}			
			if spelldata.class then
				if not args[spelldata.class] then
					args[spelldata.class] = {
						type="group",
						name=lclasses[spelldata.class],
						icon=[[Interface\ICONS\ClassIcon_]] .. spelldata.class,
						order=1,
						args={}
					}
				end
				if spelldata.specID then
					-- spec
					for specID, _ in pairs(spelldata.specID) do
						if not args[spelldata.class].args["spec" .. specID] then
							local _, name, description, icon, background, role, class = GetSpecializationInfoByID(specID)
							args[spelldata.class].args["spec" .. specID] = {
								type="group",
								name=name,
								icon=icon,
								order=3 + specID,
								args={}
							}
						end
						args[spelldata.class].args["spec" .. specID].args["spell"..spellid] = spellconfig
					end
				elseif spelldata.talent then
					-- talent
					if not args[spelldata.class].args.talents then
						args[spelldata.class].args.talents = {
							type="group",
							name="Talents",
							order=2,
							args={}
						}
					end
					args[spelldata.class].args.talents.args["spell"..spellid] = spellconfig
				else
					-- baseline
					if not args[spelldata.class].args.base then
						args[spelldata.class].args.base = {
							type="group",
							name="Baseline",
							order=1,
							args={}
						}
					end
					args[spelldata.class].args.base.args["spell"..spellid] = spellconfig
				end
			elseif spelldata.race then
				-- racial
				if not args[spelldata.race] then
					args[spelldata.race] = {
						type="group",
						name=spelldata.race,
						icon=function() return [[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT]] .. (math.random(0, 1) == 0 and "-FEMALE-" or "-MALE-") .. spelldata.race end, -- because fuck you that's why
						order=3,
						args={}
					}
				end
				args[spelldata.race].args["spell"..spellid] = spellconfig
			elseif spelldata.item then
				-- item
				if not args.items then
					args.items = {
						type="group",
						name=L["Items"],
						icon=[[Interface\Icons\Trade_Engineering]],
						order=5,
						args={}
					}
				end
				args.items.args["spell"..spellid] = spellconfig
			else
				print("Bad spelldata for", spellid, ": could not find type")
			end
		end
	end

	return options
end
