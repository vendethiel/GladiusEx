-- globals
local type, pairs = type, pairs
local strfind, max = string.find, math.max
local abs = math.abs
local UnitIsDeadOrGhost, UnitGUID = UnitIsDeadOrGhost, UnitGUID

GladiusEx = LibStub("AceAddon-3.0"):NewAddon("GladiusEx", "AceEvent-3.0")

local arena_units = {
	["arena1"] = true,
	["arena2"] = true,
	["arena3"] = true,
	["arena4"] = true,
	["arena5"] = true,
}

local party_units = {
	["player"] = true,
	["party1"] = true,
	["party2"] = true,
	["party3"] = true,
	["party4"] = true,
}

local anchor_width = 220
local anchor_height = 20

local LSR = LibStub("LibSpecRoster-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")

-- debugging output
local log_frame
local log_table
local logging = false
local function log(...)
	if not GladiusEx:IsDebugging() then return end
	if not log_frame then
		log_frame = CreateFrame("ScrollingMessageFrame", "GladiusExLogFrame")

		log_frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -50)

		log_frame:SetScript("OnMouseWheel", FloatingChatFrame_OnMouseScroll)
		log_frame:EnableMouseWheel(true)

		log_frame:SetSize(500, 600)
		log_frame:SetFont(STANDARD_TEXT_FONT, 9, "NONE")
		log_frame:SetShadowColor(0, 0, 0, 1)
		log_frame:SetShadowOffset(1, -1)
		log_frame:SetFading(false)
		log_frame:SetJustifyH("LEFT")
		log_frame:SetIndentedWordWrap(true)
		log_frame:SetMaxLines(10000)
		log_frame:SetBackdropColor(1, 1, 1, 0.2)
		log_frame.starttime = GetTime()

		log_frame:SetScale(0.6)
	end
	local p = ...
	if p == "ENABLE LOGGING" then
		GladiusEx.db.log = GladiusEx.db.log or {}
		log_table = { date("%c", time()) }
		table.insert(GladiusEx.db.log, log_table)
		logging = true
		log_frame.starttime = GetTime()
	elseif p == "DISABLE LOGGING" then
		logging = false
	end

	local msg = string.format("[%.1f] %s", GetTime() - log_frame.starttime, strjoin(" ", tostringall(...)))

	if logging then
		table.insert(log_table, msg)
	end

	log_frame:AddMessage(msg)
end

function GladiusEx:IsDebugging()
	return GladiusEx.db.debug
end

function GladiusEx:Log(...)
	log(...)
end

function GladiusEx:Debug(...)
	print("|cff33ff99GladiusEx|r:", ...)
end

function GladiusEx:Print(...)
	print("|cff33ff99GladiusEx|r:", ...)
end

local modulePrototype = {}

function modulePrototype:GetAttachPoints()
	-- get module list for frame anchor
	local t = { ["Frame"] = L["Frame"] }
	for name, m in GladiusEx:IterateModules() do
		if m ~= self and m:IsEnabled() then
			local points = m.GetModuleAttachPoints and m:GetModuleAttachPoints()
			if points then
				for point, name  in pairs(points) do
					t[point] = name
				end
			end
		end
	end

	return t
end

function modulePrototype:OnInitialize()
	self.dbi = GladiusEx.dbi:RegisterNamespace(self:GetName(), { profile = self.defaults })
	self.dbi.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.dbi.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.dbi.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	self.db = self.dbi.profile
end

function modulePrototype:OnProfileChanged()
	self.db = self.dbi.profile
end

GladiusEx:SetDefaultModulePrototype(modulePrototype)
GladiusEx:SetDefaultModuleLibraries("AceEvent-3.0")
GladiusEx:SetDefaultModuleState(false)

function GladiusEx:NewGladiusExModule(name, isbar, defaults, ...)
	local module = self:NewModule(name, ...)
	module.super = modulePrototype
	module.defaults = defaults
	module.isBarOption = isbar
	return module
end

function GladiusEx:GetAttachFrame(unit, point, nodefault)
	-- get parent frame
	if (point == "Frame") then
		return self.buttons[unit]
	else
		for name, m in self:IterateModules() do
			if m:IsEnabled() then
				local points = m.GetModuleAttachPoints and m:GetModuleAttachPoints()
				if points and points[point] then
					local f = m:GetAttachFrame(unit, point)
					return f
				end
			end
		end
	end
	-- default to frame
	return not nodefault and self.buttons[unit]
end

function GladiusEx:OnInitialize()
	-- init db
	self.dbi = LibStub("AceDB-3.0"):New("GladiusExDB", self.defaults)
	self.dbi.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.dbi.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.dbi.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	self.db = self.dbi.profile

	-- libsharedmedia
	self.LSM = LibStub("LibSharedMedia-3.0")
	self.LSM:Register("statusbar", "Minimalist", "Interface\\Addons\\GladiusEx\\images\\Minimalist")

	-- test environment
	self.test = false
	self.testing = setmetatable({
		["arena1"] = { health = 320000, maxHealth = 320000, power = 18000, maxPower = 18000, powerType = 0, unitClass = "MAGE", unitRace = "Scourge", unitSpec = "Frost", specID = 64 },
		["arena2"] = { health = 300000, maxHealth = 320000, power = 10000, maxPower = 12000, powerType = 2, unitClass = "HUNTER", unitRace = "NightElf", unitSpec = "Beast Mastery", specID = 253 },
		["arena3"] = { health = 240000, maxHealth = 350000, power = 90, maxPower = 120, powerType = 3, unitClass = "ROGUE", unitRace = "Human", unitSpec = "Subtlety", specID = 261 },
		["arena4"] = { health = 200000, maxHealth = 400000, power = 80, maxPower = 130, powerType = 6, unitClass = "DEATHKNIGHT", unitRace = "Dwarf", unitSpec = "Unholy", specID = 252 },
		["arena5"] = { health = 100000, maxHealth = 300000, power = 10, maxPower = 100, powerType = 1, unitClass = "WARRIOR", unitRace = "Gnome", unitSpec = "Arms", specID = 71 },

		["player"] = { health = 320000, maxHealth = 320000, power = 18000, maxPower = 18000, powerType = 0, unitClass = "PRIEST", unitRace = "Draenei", unitSpec = "Discipline" },
		["party1"] = { health = 300000, maxHealth = 320000, power = 10000, maxPower = 12000, powerType = 3, unitClass = "MONK", unitRace = "Pandaren", unitSpec = "Windwalker", specID = 269 },
		["party2"] = { health = 100000, maxHealth = 300000, power = 10, maxPower = 100, powerType = 1, unitClass = "WARRIOR", unitRace = "Gnome", unitSpec = "Arms", specID = 71 },
		["party3"] = { health = 200000, maxHealth = 400000, power = 80, maxPower = 130, powerType = 6, unitClass = "DEATHKNIGHT", unitRace = "Dwarf", unitSpec = "Unholy", specID = 252 },
		["party4"] = { health = 100000, maxHealth = 300000, power = 10, maxPower = 100, powerType = 1, unitClass = "WARRIOR", unitRace = "Gnome", unitSpec = "Arms", specID = 71 },

	}, {
		__index = function(t, k)
			return t["arena1"]
		end
	})

	-- buttons
	self.buttons = {}
end

function GladiusEx:EnableModules()
	for module_name in self:IterateModules() do
		if self.db.modules[module_name] then
			self:EnableModule(module_name)
		else
			self:DisableModule(module_name)
		end
	end
end

function GladiusEx:OnEnable()
	-- create frames
	-- anchor & background
	self.party_parent = CreateFrame("Frame", "GladiusExPartyFrame", UIParent)
	self.arena_parent = CreateFrame("Frame", "GladiusExArenaFrame", UIParent)

	self.arena_anchor, self.arena_background = self:CreateAnchor("arena")
	self.party_anchor, self.party_background = self:CreateAnchor("party")

	-- enable modules
	self:EnableModules()

	-- init options
	self:SetupOptions()

	-- update roster
	self:UpdateAllGUIDs()

	-- register the appropriate events
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ARENA_OPPONENT_UPDATE")
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	self:RegisterEvent("SCRIPT_ARENA_PREP_OPPONENT_SPECIALIZATIONS", "ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("UNIT_MAXHEALTH", "UNIT_HEALTH")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("UNIT_PET", "UpdateUnitGUID")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "UpdateUnitGUID")
	LSR.RegisterMessage(self, "LSR_SpecializationChanged")

	-- wait until the first frame because some functions are not available until then
	-- i expect a raptor will eat me at any moment now for creating a frame just for this..
	local f = CreateFrame("Frame")
	f:SetScript("OnUpdate", function()
		f:SetScript("OnUpdate", nil)
		-- display help message
		if (not self.db.locked and not self.db.x["arena1"] and not self.db.y["arena1"] and not self.db.x["anchor_arena"] and not self.db.y["anchor_arena"]) then
			self:Print(L["Welcome to GladiusEx!"])
			self:Print(L["First run has been detected, displaying test frame"])
			self:Print(L["Valid slash commands are:"])
			self:Print("/gex ui")
			self:Print("/gex test 2-5")
			self:Print("/gex hide")
			self:Print("/gex reset")
			self:Print(L["** If this is not your first run please lock or move the frame to prevent this from happening **"])

			self:SetTesting(3)
		elseif self.db.debug then
			self:SetTesting(3)
		end

		-- see if we are already in arena
		if IsLoggedIn() then
			GladiusEx:PLAYER_ENTERING_WORLD()
		end
	end)
end

function GladiusEx:OnDisable()
	self:HideFrames()
	self:UnregisterAllEvents()
end

function GladiusEx:OnProfileChanged(event, database, newProfileKey)
	-- update frame and modules on profile change
	self.db = self.dbi.profile

	self:EnableModules()
	self:UpdateFrames()
end

function GladiusEx:SetTesting(count)
	log("SetTesting", count)
	self.test = count

	if count then
		self:ShowFrames()
	else
		self:HideFrames()
	end
end

function GladiusEx:IsTesting(unit)
	if not self.test then
		return false
	elseif unit then
		return not UnitExists(unit)
	else
		return self.test
	end
end

function GladiusEx:GetArenaSize(min)
	-- try to guess the current arena size
	local guess = max(min or 0, 2, GetNumArenaOpponents(), GetNumArenaOpponentSpecs(), GetNumGroupMembers(), self:IsTesting() or 0)

	if guess >= 4 then
		guess = 5
	end

	log("GetArenaSize", GetNumArenaOpponents(), GetNumArenaOpponentSpecs(), GetNumGroupMembers(), " => ", guess)

	return guess
end

function GladiusEx:UpdatePartyFrames()
	if InCombatLockdown() then
		self:QueueUpdate()
	end
	local group_members = self:GetArenaSize()

	log("UpdatePartyFrames", group_members)

	for i = 1, 5 do
		local unit = i == 1 and "player" or ("party" .. (i - 1))
		if group_members >= i then
			self:UpdateUnit(unit)
			self:ShowUnit(unit)

			if not self:IsTesting() and not UnitExists(unit) then
				self:HideUnit(unit)
			end

			-- test environment
			if self:IsTesting(unit) then
				self:TestUnit(unit)
			else
				self:RefreshUnit(unit)
			end
		else
			self:HideUnit(unit)
		end
	end

	self:UpdateAnchor("party")
end

function GladiusEx:UpdateArenaFrames()
	if InCombatLockdown() then
		self:QueueUpdate()
	end

	local numOpps = self:GetArenaSize()

	log("UpdateArenaFrames:", numOpps, GetNumArenaOpponents(), GetNumArenaOpponentSpecs())

	for i = 1, 5 do
		local unit = "arena" .. i
		if numOpps >= i then
			self:UpdateUnit(unit)
			self:ShowUnit(unit)

			-- test environment
			if self:IsTesting(unit) then
				self:TestUnit(unit)
			else
				self:RefreshUnit(unit)
			end
		else
			self:HideUnit(unit)
		end
	end

	self:UpdateAnchor("arena")
end

function GladiusEx:UpdateFrames()
	log("UpdateFrames")

	self:UpdatePartyFrames()
	self:UpdateArenaFrames()

	if not InCombatLockdown() then
		self:ClearUpdateQueue()
	end
end

function GladiusEx:CheckArenaSize(unit)
	local min_size = 0
	if unit then
		local an = string.match(unit, "^arena(%d+)$")
		if an then
			min_size = tonumber(an)
		else
			local pn = string.match(unit, "^party(%d+)$")
			if pn then
				min_size = tonumber(pn) + 1
			end
		end
	end

	local size = self:GetArenaSize(min_size)
	log("CheckArenaSize", unit, size, self:GetArenaSize())
end

function GladiusEx:ShowFrames()
	log("ShowFrames")

	if InCombatLockdown() then
		self:QueueUpdate()
	end

	-- background
	if (self.db.groupButtons) then
		self.arena_background:Show()
		self.party_background:Show()

		if (not self.db.locked) then
			self.arena_anchor:Show()
			self.party_anchor:Show()
		end
	end

	self.arena_parent:Show()

	if self.db.showParty then
		self.party_parent:Show()
	end

	self:UpdateFrames()
end

function GladiusEx:HideFrames()
	log("HideFrames")

	if InCombatLockdown() then
		self:QueueUpdate()
	end

	-- hide frames instead of just setting alpha to 0
	for unit, button in pairs(self.buttons) do
		-- hide frames
		self:HideUnit(unit)
		button:Hide()
		-- reset spec data
		button.class = nil
		button.spec = nil
		button.specID = nil
	end

	self.arena_parent:Hide()
	self.party_parent:Hide()
end

function GladiusEx:IsPartyShown()
	return self.party_parent:IsShown()
end

function GladiusEx:IsArenaShown()
	return self.arena_parent:IsShown()
end

function GladiusEx:PLAYER_ENTERING_WORLD()
	local instanceType = select(2, IsInInstance())
	log("PLAYER_ENTERING_WORLD", instanceType)

	-- check if we are entering or leaving an arena
	if instanceType == "arena" then
		self:SetTesting(false)
		self:ShowFrames()
		self:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
		log("ENABLE LOGGING")
	else
		if not self:IsTesting() then
			self:HideFrames()
		end
		if logging then log("DISABLE LOGGING") end
	end
end

function GladiusEx:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
	local numOpps = GetNumArenaOpponentSpecs()

	log("ARENA_PREP_OPPONENT_SPECIALIZATIONS", numOpps)

	for i = 1, numOpps do
		local specID = GetArenaOpponentSpec(i)
		local unitid = "arena" .. i

		self:UpdateUnitSpecialization(unitid, specID)
	end

	self:UpdateArenaFrames()
end

function GladiusEx:ARENA_OPPONENT_UPDATE(event, unit, type)
	log(event, unit, type)
	self:RefreshUnit(unit)
	if type == "seen" or type == "destroyed" then
		self:UpdateUnitState(unit, false)
		self:CheckArenaSize(unit)
	elseif type == "unseen" then
		self:UpdateUnitState(unit, true)
	elseif type == "cleared" then
		if not self:IsTesting() then
			self:HideUnit(unit)
		end
	end
end

function GladiusEx:GROUP_ROSTER_UPDATE()
	--if self:IsPartyShown() then
	--	self:UpdatePartyFrames()
	--end
	log("GROUP_ROSTER_UPDATE")
	self:UpdateAllGUIDs()
	self:UpdateFrames()
end

function GladiusEx:QueueUpdate()
	log("QueueUpdate")
	self.update_pending = true
end

function GladiusEx:IsUpdatePending()
	return self.update_pending
end

function GladiusEx:ClearUpdateQueue()
	self.update_pending = false
end

function GladiusEx:PLAYER_REGEN_ENABLED()
	log("PLAYER_REGEN_ENABLED")
	if self:IsUpdatePending() then
		self:UpdateFrames()
	end
end

function GladiusEx:UNIT_NAME_UPDATE(event, unit)
	if not self:IsHandledUnit(unit) then return end

	log("UNIT_NAME_UPDATE", unit)

	self:UpdateUnitGUID(event, unit)
	self:CheckArenaSize(unit)
	self:UpdateUnitState(unit)
end

local guid_to_unitid = {}

function GladiusEx:GetUnitIdByGUID(guid)
	return guid_to_unitid[guid]
end

function GladiusEx:UpdateAllGUIDs()
	for unit in pairs(party_units) do self:UpdateUnitGUID("UpdateAllGUIDs", unit) end
	for unit in pairs(arena_units) do self:UpdateUnitGUID("UpdateAllGUIDs", unit) end
end

function GladiusEx:UpdateUnitGUID(event, unit)
	if self:IsHandledUnit(unit) then
		-- find and delete old reference to that unit
		for guid, unitid in pairs(guid_to_unitid) do
			if unitid == unit then
				guid_to_unitid[guid] = nil
				break
			end
		end
		-- add guid
		local guid = UnitGUID(unit)
		if guid then
			guid_to_unitid[guid] = unit
		end
	end
end

function GladiusEx:UNIT_HEALTH(event, unit)
	if not self.buttons[unit] then return end

	self:UpdateUnitState(unit, false)
end

function GladiusEx:UpdateUnitState(unit, stealth)
	if not self.buttons[unit] then
		log("UpdateUnitState", unit, "NO BUTTON")
		return
	end

	if UnitIsDeadOrGhost(unit) then
		self.buttons[unit]:SetAlpha(self.db.deadAlpha)
		log("UpdateUnitState", unit, "DEAD")
	elseif stealth then
		self.buttons[unit]:SetAlpha(self.db.stealthAlpha)
		log("UpdateUnitState", unit, "STEALTH")
	else
		self.buttons[unit]:SetAlpha(1)
		log("UpdateUnitState", unit, "NORMAL")
	end
end

function GladiusEx:LSR_SpecializationChanged(event, guid, unitID, specID)
	for u, _ in pairs(party_units) do
		if UnitGUID(u) == guid then
			self:UpdateUnitSpecialization(u, specID)
			break
		end
	end
end

function GladiusEx:CheckUnitSpecialization(unit)
	local _, specID = LSR:getSpecialization(UnitGUID(unit))

	self:UpdateUnitSpecialization(unit, specID)
end

function GladiusEx:UpdateUnitSpecialization(unitid, specID)
	local _, class, spec

	if specID and specID > 0 then
		_, spec, _, _, _, _, class = GetSpecializationInfoByID(specID)
	end

	specID = (specID and specID > 0) and specID or nil

	if self.buttons[unitid] and self.buttons[unitid].specID ~= specID then
		self.buttons[unitid].class = class
		self.buttons[unitid].spec = spec
		self.buttons[unitid].specID = specID

		log("UpdateUnitSpecialization", unitid, "is", class, "/", spec)

		self:SendMessage("GLADIUS_SPEC_UPDATE", unitid)
	end
end

function GladiusEx:IsHandledUnit(unit)
	return arena_units[unit] or party_units[unit]
end

function GladiusEx:IsArenaUnit(unit)
	return arena_units[unit]
end

function GladiusEx:IsPartyUnit(unit)
	return party_units[unit]
end

function GladiusEx:TestUnit(unit)
	if not self:IsHandledUnit(unit) then return end

	-- test modules
	for name, m in self:IterateModules() do
		if (m:IsEnabled()) then
			if m.Test then
				m:Test(unit)
			end
		end
	end

	-- lower secure frame in test mode so we can move the frame
	self.buttons[unit]:SetFrameStrata("LOW")
	self.buttons[unit].secure:SetFrameStrata("BACKGROUND")
end

function GladiusEx:RefreshUnit(unit)
	if not self.buttons[unit] then return end

	-- show modules
	for n, m in self:IterateModules() do
		if m:IsEnabled() and m.Refresh then
			m:Refresh(unit)
		end
	end
end

function GladiusEx:ShowUnit(unit)
	if not self.buttons[unit] then return end

	-- show modules
	for n, m in self:IterateModules() do
		if m:IsEnabled() and m.Show then
			m:Show(unit)
		end
	end

	-- show button
	self.buttons[unit]:SetAlpha(1)
	if not self.buttons[unit]:IsShown() then
		if not InCombatLockdown() then
			self.buttons[unit]:Show()
		else
			self:QueueUpdate()
			log("ShowUnit: tried to show, but InCombatLockdown")
		end
	end

	-- update spec
	if self:IsPartyUnit(unit) and not self.buttons[unit].spec then
		self:CheckUnitSpecialization(unit)
	end
end

function GladiusEx:HideUnit(unit)
	if (not self.buttons[unit]) then return end

	if InCombatLockdown() then
		self:QueueUpdate()
	end

	-- hide modules
	for name, m in self:IterateModules() do
		if m:IsEnabled() then
			if m.Reset then
				m:Reset(unit)
			end
		end
	end

	-- hide the button
	self.buttons[unit]:SetAlpha(0)
	self.buttons[unit]:Hide()
end

function GladiusEx:CreateUnit(unit)
	local button = CreateFrame("Frame", "GladiusExButtonFrame" .. unit, self:IsArenaUnit(unit) and self.arena_parent or self.party_parent)
	self.buttons[unit] = button

	-- hide
	self.buttons[unit]:SetAlpha(0)
	self.buttons[unit]:Hide()

	button:SetClampedToScreen(true)
	button:EnableMouse(true)
	button:SetMovable(true)

	button:RegisterForDrag("LeftButton")

	local dragparentunit = self:IsArenaUnit(unit) and "anchor_arena" or "anchor_party"
	local dragparent = self:IsArenaUnit(unit) and self.arena_anchor or self.party_anchor

	button:SetScript("OnMouseDown", function(f, button)
		if button == "RightButton" then
			self:ShowOptionsDialog()
		end
	end)

	button:SetScript("OnDragStart", function(f)
		if (not InCombatLockdown() and not self.db.locked) then
			local f = self.db.groupButtons and dragparent or f
			f:StartMoving()
		end
	end)

	button:SetScript("OnDragStop", function(f)
		if (not InCombatLockdown()) then
			local f = self.db.groupButtons and dragparent or f
			local unit = self.db.groupButtons and dragparentunit or unit

			f:StopMovingOrSizing()
			local scale = f:GetEffectiveScale()
			self.db.x[unit] = f:GetLeft() * scale
			self.db.y[unit] = f:GetTop() * scale
		end
	end)

	-- secure button
	button.secure = CreateFrame("Button", "GladiusExSecureButton" .. unit, button, "SecureActionButtonTemplate")
	button.secure:SetAttribute("unit", unit)
	button.secure:RegisterForClicks("AnyDown")
	button.secure:SetAttribute("*type1", "target")
	button.secure:SetAttribute("*type2", "focus")

	-- clique support
	ClickCastFrames = ClickCastFrames or {}
	ClickCastFrames[button.secure] = true
end

function GladiusEx:CreateAnchor(anchor_type)
	-- background
	local background = CreateFrame("Frame", "GladiusExButtonBackground" .. anchor_type, anchor_type == "party" and self.party_parent or self.arena_parent)
	background:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,})
	background:SetFrameStrata("BACKGROUND")

	-- anchor
	local anchor = CreateFrame("Frame", "GladiusExButtonAnchor" .. anchor_type, anchor_type == "party" and self.party_parent or self.arena_parent)
	anchor:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,})
	anchor:SetBackdropColor(0, 0, 0, 1)
	anchor:SetFrameStrata("MEDIUM")
	anchor:Raise()

	anchor:SetClampedToScreen(true)
	anchor:EnableMouse(true)
	anchor:SetMovable(true)
	anchor:RegisterForDrag("LeftButton")

	anchor:SetScript("OnMouseDown", function(f, button)
		if button == "LeftButton" then
			if IsShiftKeyDown() then
				-- center horizontally
			end
		elseif button == "RightButton" then
			self:ShowOptionsDialog()
		end
	end)

	anchor:SetScript("OnDragStart", function(f)
		if (not InCombatLockdown() and not self.db.locked) then
			anchor:StartMoving()
		end
	end)

	anchor:SetScript("OnDragStop", function(f)
		anchor:StopMovingOrSizing()
		local scale = f:GetEffectiveScale()
		self.db.x["anchor_" .. anchor_type] = f:GetLeft() * scale
		self.db.y["anchor_" .. anchor_type] = f:GetTop() * scale
		-- save all unit positions so that they stay at the same place if the buttons are ungrouped
		for unit, button in pairs(self.buttons) do
			self.db.x[unit] = button:GetLeft() * scale
			self.db.y[unit] = button:GetTop() * scale
		end
	end)

	anchor.text = anchor:CreateFontString("GladiusExButtonAnchorText", "OVERLAY")

	background.background_type = anchor_type
	anchor.anchor_type = anchor_type

	return anchor, background
end

function GladiusEx:GetUnitIndex(unit)
	local unit_index
	if unit == "player" then
		unit_index = 0
	else
		local utype, n = string.match(unit, "^(%a+)(%d+)$")
		if utype == "party" then
			unit_index = tonumber(n)
		elseif utype == "arena" then
			unit_index = tonumber(n) - 1
		else
			assert(false, "Unknown unit")
		end
	end
	return unit_index
end

function GladiusEx:GetUnitAnchor(unit)
	return self:IsArenaUnit(unit) and self.arena_anchor or self.party_anchor
end

function GladiusEx:UpdateUnitPosition(unit)
	--local left, right, top, bottom = -20, 20, 20, -20-- self.buttons[unit]:GetHitRectInsets()
	local left, right, top, bottom = self.buttons[unit]:GetHitRectInsets()
	self.buttons[unit]:ClearAllPoints()

	if self.db.groupButtons then
		local unit_index = self:GetUnitIndex(unit)
		local num_frames = self:GetArenaSize()
		local anchor = self:GetUnitAnchor(unit)
		local frameWidth = self.buttons[unit].frameWidth
		local frameHeight = self.buttons[unit].frameHeight
		local real_width = frameWidth + abs(left) + abs(right)
		local real_height = frameHeight + abs(top) + abs(bottom)
		local margin_x = (real_width + self.db.margin) * unit_index
		local margin_y = (real_height + self.db.margin) * unit_index

		if self.db.growDirection == "UP" then
			self.buttons[unit]:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", abs(left), margin_y + abs(top))
		
		elseif self.db.growDirection == "DOWN" then
			self.buttons[unit]:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", abs(left), -margin_y - abs(top))
		
		elseif self.db.growDirection == "LEFT" then
			self.buttons[unit]:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", -margin_x - abs(right), -abs(top))
		
		elseif self.db.growDirection == "RIGHT" then
			self.buttons[unit]:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", margin_x + abs(left), -abs(top))
		
		elseif self.db.growDirection == "HCENTER" then
			local offset = (real_width * (num_frames - 1) + self.db.margin * (num_frames - 1) - abs(left) - abs(right)) / 2
			self.buttons[unit]:SetPoint("TOP", anchor, "BOTTOM", -offset + margin_x, -abs(top))
		elseif self.db.growDirection == "VCENTER" then
			local offset = (real_height * (num_frames - 1) + self.db.margin * (num_frames - 1)) / 2
			self.buttons[unit]:SetPoint("LEFT", anchor, "LEFT", abs(left) + abs(right), offset - margin_y)
		end
	else
		local eff = self.buttons[unit]:GetEffectiveScale()
		self.buttons[unit]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.x[unit] / eff, self.db.y[unit] / eff)
	end
end

function GladiusEx:UpdateUnit(unit, module)
	if not self:IsHandledUnit(unit) then return end

	if InCombatLockdown() then
		self:QueueUpdate()
		return
	end

	if not self.buttons[unit] then
		self:CreateUnit(unit)
	end

	local height = 0
	local frameWidth = self.db.barWidth
	local frameHeight = 0

	-- reset hit rect
	self.buttons[unit]:SetHitRectInsets(0, 0, 0, 0)
	self.buttons[unit].secure:SetHitRectInsets(0, 0, 0, 0)

	-- update modules (bars first, because we need the height)
	for _, m in self:IterateModules() do
		if (m:IsEnabled()) then
			-- update and get bar height
			if (m.isBarOption) then
				m:Update(unit)

				local attachTo = m:GetAttachTo()
				if (attachTo == "Frame" or m.isBar) then
					frameHeight = frameHeight + m:GetBarHeight()
				end
			end
		end
	end

	self.buttons[unit].frameWidth = frameWidth
	self.buttons[unit].frameHeight = frameHeight

	-- update button
	self.buttons[unit]:SetScale(self.db.frameScale)
	self.buttons[unit]:SetSize(frameWidth, frameHeight)

	-- update modules (indicator)
	for _, m in self:IterateModules() do
		if (m:IsEnabled() and not m.isBarOption and m.Update) then
			m:Update(unit)
		end
	end

	-- update position
	self:UpdateUnitPosition(unit)

	-- update secure frame
	self.buttons[unit].secure:ClearAllPoints()
	self.buttons[unit].secure:SetAllPoints(self.buttons[unit])

	-- show the secure frame
	if not self:IsTesting() then
		self.buttons[unit].secure:Show()
		self.buttons[unit].secure:SetAlpha(1)
	end

	self.buttons[unit]:SetFrameStrata("LOW")
	self.buttons[unit].secure:SetFrameStrata("MEDIUM")
end


function GladiusEx:UpdateAnchor(anchor_type)
	local anchor = anchor_type == "party" and self.party_anchor or self.arena_anchor
	local background = anchor_type == "party" and self.party_background or self.arena_background

	-- anchor
	anchor:ClearAllPoints()
	anchor:SetSize(anchor_width, anchor_height)
	anchor:SetScale(self.db.frameScale)
	if (not self.db.x and not self.db.y) or (not self.db.x["anchor_" .. anchor.anchor_type] and not self.db.y["anchor_" .. anchor.anchor_type]) then
		if anchor.anchor_type == "party" then
			anchor:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
		else
			anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
		end
	else
		local eff = anchor:GetEffectiveScale()
		anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.x["anchor_" .. anchor.anchor_type] / eff, self.db.y["anchor_" .. anchor.anchor_type] / eff)
	end

	anchor.text:SetPoint("CENTER", anchor, "CENTER")
	anchor.text:SetFont(self.LSM:Fetch(self.LSM.MediaType.FONT, self.db.globalFont), (self.db.useGlobalFontSize and self.db.globalFontSize or 11))
	anchor.text:SetTextColor(1, 1, 1, 1)

	anchor.text:SetShadowOffset(1, -1)
	anchor.text:SetShadowColor(0, 0, 0, 1)

	anchor.text:SetText(anchor.anchor_type == "party" and L["GladiusEx Party Anchor - click to move"] or L["GladiusEx Enemy Anchor - click to move"])

	if self.db.groupButtons and not self.db.locked then
		anchor:Show()
	else
		anchor:Hide()
	end

	-- background
	local unit = background.background_type == "party" and "player" or "arena1"
	local left, right, top, bottom = self.buttons[unit]:GetHitRectInsets()
	local frame_width = self.buttons[unit].frameWidth
	local frame_height = self.buttons[unit].frameHeight

	local num_frames = self:GetArenaSize()
	local width, height = self.db.backgroundPadding * 2, self.db.backgroundPadding * 2
	local real_frame_width = frame_width + abs(right) + abs(left)
	local real_frame_height = frame_height + abs(top) + abs(bottom)
	if self.db.growDirection == "UP" or self.db.growDirection == "DOWN" or self.db.growDirection == "VCENTER" then
		width = width + real_frame_width
		height = height + real_frame_height * num_frames + self.db.margin * (num_frames - 1)
	else
		width = width + real_frame_width * num_frames + self.db.margin * (num_frames - 1)
		height = height + real_frame_height
	end

	background:ClearAllPoints()
	background:SetSize(width, height)
	background:SetScale(self.db.frameScale)

	if self.db.growDirection == "UP" then
		background:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", -self.db.backgroundPadding, -self.db.backgroundPadding)
	elseif self.db.growDirection == "DOWN" then
		background:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -self.db.backgroundPadding, self.db.backgroundPadding)
	elseif self.db.growDirection == "LEFT" then
		background:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", self.db.backgroundPadding, self.db.backgroundPadding)
	elseif self.db.growDirection == "RIGHT" then
		background:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -self.db.backgroundPadding, self.db.backgroundPadding)
	elseif self.db.growDirection == "HCENTER" then
		background:SetPoint("TOP", anchor, "BOTTOM", 0, self.db.backgroundPadding)
	elseif self.db.growDirection == "VCENTER" then
		background:SetPoint("LEFT", anchor, "LEFT", -self.db.backgroundPadding, 0)
	end

	background:SetBackdropColor(self.db.backgroundColor.r, self.db.backgroundColor.g, self.db.backgroundColor.b, self.db.backgroundColor.a)

	if self.db.groupButtons then
		background:Show()
	else
		background:Hide()
	end
end

function GladiusEx:CenterUnitPosition(unit, numFrames)
end
