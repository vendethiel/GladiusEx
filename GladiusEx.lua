-- globals
local select, type, pairs, tonumber, wipe = select, type, pairs, tonumber, wipe
local strfind, strmatch, max, abs = string.find, string.match, math.max, math.abs
local UnitIsDeadOrGhost, UnitGUID, UnitExists = UnitIsDeadOrGhost, UnitGUID, UnitExists
local InCombatLockdown = InCombatLockdown
local GetNumArenaOpponents, GetNumArenaOpponentSpecs, GetNumGroupMembers = GetNumArenaOpponents, GetNumArenaOpponentSpecs, GetNumGroupMembers

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

GladiusEx.party_units = party_units
GladiusEx.arena_units = arena_units

local anchor_width = 220
local anchor_height = 20

local STATE_NORMAL = 0
local STATE_DEAD = 1
local STATE_STEALTH = 2
local RANGE_UPDATE_INTERVAL = 1 / 5

local LSR = LibStub("LibSpecRoster-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local RC = LibStub("LibRangeCheck-2.0")

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
	return self.db.base.debug
end

function GladiusEx:SetDebugging(enabled)
	self.db.base.debug = enabled
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

-- Module prototype
local modulePrototype = {}

function modulePrototype:GetOtherAttachPoints(unit)
	return GladiusEx:GetAttachPoints(unit, self)
end

function modulePrototype:InitializeDB(name, defaults)
	local dbi = GladiusEx.dbi:RegisterNamespace(name, { profile = defaults })
	dbi.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	dbi.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	dbi.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	return dbi
end

function modulePrototype:OnInitialize()
	self.dbi_arena = self:InitializeDB(self:GetName(), self.defaults_arena)
	self.dbi_party = self:InitializeDB("party_" .. self:GetName(), self.defaults_party)
	self.db = setmetatable({}, {
		__index = function(t, k)
			local v
			if GladiusEx:IsPartyUnit(k) then
				v = self.dbi_party.profile
			elseif GladiusEx:IsArenaUnit(k) then
				v = self.dbi_arena.profile
			else
				error("Bad module DB usage: not an unit (" .. tostring(k) .. ")", 2)
			end
			rawset(t, k, v)
			return v
		end
	})
end

function modulePrototype:OnProfileChanged()
	wipe(self.db)
end

function modulePrototype:IsBar()
	return false
end

function modulePrototype:IsUnitEnabled(unit)
	return GladiusEx:IsModuleEnabled(unit, self:GetName())
end

GladiusEx:SetDefaultModulePrototype(modulePrototype)
GladiusEx:SetDefaultModuleLibraries("AceEvent-3.0")
GladiusEx:SetDefaultModuleState(false)

function GladiusEx:NewGladiusExModule(name, isbar, defaults_arena, defaults_party, ...)
	local module = self:NewModule(name, ...)
	module.super = modulePrototype
	module.defaults_arena = defaults_arena
	module.defaults_party = defaults_party or defaults_arena
	module.isBarOption = isbar
	return module
end

function GladiusEx:GetAttachPoints(unit, skip)
	-- get module list for frame anchor
	local t = { ["Frame"] = L["Frame"] }
	for name, m in GladiusEx:IterateModules() do
		if m ~= skip and self:IsModuleEnabled(unit, name) then
			local points = m.GetModuleAttachPoints and m:GetModuleAttachPoints(unit)
			if points then
				for point, name  in pairs(points) do
					t[point] = name
				end
			end
		end
	end

	return t
end

function GladiusEx:GetAttachFrame(unit, point, nodefault)
	-- get parent frame
	if point == "Frame" then
		return self.buttons[unit]
	else
		for name, m in self:IterateModules() do
			if self:IsModuleEnabled(unit, name) then
				local points = m.GetModuleAttachPoints and m:GetModuleAttachPoints(unit)
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
	-- init db+
	self.dbi = LibStub("AceDB-3.0"):New("GladiusExDB", self.defaults)
	self.dbi_arena = self.dbi:RegisterNamespace("arena", self.defaults_arena)
	self.dbi_party = self.dbi:RegisterNamespace("party", self.defaults_party)
	self.db = setmetatable({}, {
		__index = function(t, k)
			local v
			if k == "party" or GladiusEx:IsPartyUnit(k) then
				v = self.dbi_party.profile
			elseif k == "arena" or GladiusEx:IsArenaUnit(k) then
				v = self.dbi_arena.profile
			elseif k == "base" then
				v = self.dbi.profile
			else
				error("Bad DB usage: not an unit (" .. tostring(k) .. ")", 2)
			end
			rawset(t, k, v)
			return v
		end
	})

	-- libsharedmedia
	self.LSM = LibStub("LibSharedMedia-3.0")
	self.LSM:Register("statusbar", "Minimalist", "Interface\\Addons\\GladiusEx\\images\\Minimalist")

	-- test environment
	self.test = false
	self.testing = setmetatable({}, {
		__index = function(t, k)
				return self.db.base.testUnits[k]
			end
		})

	-- buttons
	self.buttons = {}
end

function GladiusEx:IsModuleEnabled(unit, name)
	return self.db[unit].modules[name]
end

function GladiusEx:CheckEnableDisableModule(name)
	local mod = self:GetModule(name)

	-- hide module if it is being disabled
	if mod:IsEnabled() and mod.Reset then
		if not self:IsModuleEnabled("party", name) then
			for unit, button in pairs(self.buttons) do
				if self:IsPartyUnit(unit) then
					mod:Reset(unit)
				end
			end
		end
		if not self:IsModuleEnabled("arena", name) then
			for unit, button in pairs(self.buttons) do
				if self:IsArenaUnit(unit) then
					mod:Reset(unit)
				end
			end
		end
	end

	if self:IsModuleEnabled("party", name) or self:IsModuleEnabled("arena", name) then
		self:EnableModule(name)
	else
		self:DisableModule(name)
	end
end

function GladiusEx:EnableModules()
	for module_name in self:IterateModules() do
		self:CheckEnableDisableModule(module_name)
	end
end

function GladiusEx:OnEnable()
	-- create frames
	-- anchor & background
	self.party_parent = CreateFrame("Frame", "GladiusExPartyFrame", UIParent)
	self.arena_parent = CreateFrame("Frame", "GladiusExArenaFrame", UIParent)

	self.arena_anchor, self.arena_background = self:CreateAnchor("arena")
	self.party_anchor, self.party_background = self:CreateAnchor("party")

	-- update roster
	self:UpdateAllGUIDs()

	-- update range checkers
	self:UpdateRangeCheckers()

	-- enable modules
	self:EnableModules()

	-- init options
	self:SetupOptions()

	-- register the appropriate events
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ARENA_OPPONENT_UPDATE")
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("UNIT_MAXHEALTH", "UNIT_HEALTH")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("UNIT_PET", "UpdateUnitGUID")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "UpdateUnitGUID")
	LSR.RegisterMessage(self, "LSR_SpecializationChanged")
	RC.RegisterCallback(self, RC.CHECKERS_CHANGED, "UpdateRangeCheckers")
	self.dbi.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.dbi.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.dbi.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

	-- wait until the first frame because some functions are not available until then
	-- i expect a raptor will eat me at any moment now for creating a frame just for this..
	local f = CreateFrame("Frame")
	f:SetScript("OnUpdate", function()
		f:SetScript("OnUpdate", nil)
		-- display help message
		if (not self.db.base.locked and not self.db.arena.x["arena1"] and not self.db.arena.y["arena1"] and not self.db.arena.x["anchor_arena"] and not self.db.arena.y["anchor_arena"]) then
			self:Print(L["Welcome to GladiusEx!"])
			self:Print(L["First run has been detected, displaying test frame"])
			self:Print(L["Valid slash commands are:"])
			self:Print("/gex ui")
			self:Print("/gex test 2-5")
			self:Print("/gex hide")
			self:Print("/gex reset")
			self:Print(L["** If this is not your first run please lock or move the frame to prevent this from happening **"])

			self:SetTesting(3)
		elseif self:IsDebugging() then
			self:SetTesting(3)
		end

		-- see if we are already in arena
		if IsLoggedIn() then
			GladiusEx:PLAYER_ENTERING_WORLD()
		end
	end)
end

function GladiusEx:OnDisable()
	self:UnregisterAllEvents()
	LSR.UnregisterAllMessages(self)
	self.dbi.UnregisterAllEvents(self)
	self:HideFrames()
end

function GladiusEx:OnProfileChanged(event, database, newProfileKey)
	-- update frame and modules on profile change
	wipe(self.db)

	self:SetupOptions()
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

			self:UpdateUnitState(unit, false)
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

			self:UpdateUnitState(unit, self.buttons[unit].unit_state == STATE_STEALTH)
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
		min_size = self:GetUnitIndex(unit)
	end

	local size = self:GetArenaSize(min_size)
	log("CheckArenaSize", unit, size, self:GetArenaSize())
end

function GladiusEx:ShowFrames()
	log("ShowFrames")

	if InCombatLockdown() then
		self:QueueUpdate()
	end

	local function show_anchor(anchor_type)
		if self.db[anchor_type].groupButtons then
			local anchor, background = self:GetAnchorFrames(anchor_type)
			background:Show()

			if not self.db.base.locked then
				anchor:Show()
			end
		end
	end

	show_anchor("arena")
	self.arena_parent:Show()

	if self.db.base.showParty then
		show_anchor("party")
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

function GladiusEx:CheckOpponentSpecialization(unit)
	local id = strmatch(unit, "^arena(%d+)$")
	if id then
		local specID = GetArenaOpponentSpec(tonumber(id))
		if specID and specID > 0 then
			self:UpdateUnitSpecialization(unit, specID)
		end
	end
end

function GladiusEx:ARENA_OPPONENT_UPDATE(event, unit, type)
	log(event, unit, type)
	self:RefreshUnit(unit)
	self:CheckOpponentSpecialization(unit)
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
	-- update arena as well since the group size is used as a clue of the arena size
	if self:IsArenaShown() or self:IsPartyShown() then
		self:UpdateAllGUIDs()
		self:UpdateFrames()
	end
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

local range_check
function GladiusEx:UpdateRangeCheckers()
	range_check = RC:GetSmartMinChecker(40)
end


local function FrameRangeChecker_OnUpdate(f, elapsed)
	f.elapsed = f.elapsed + elapsed

	if f.elapsed >= RANGE_UPDATE_INTERVAL then
		f.elapsed = 0
		local unit = f.unit
		if GladiusEx:IsTesting(unit) or range_check(unit) then
			f:SetAlpha(1)
		else
			f:SetAlpha(GladiusEx.db[unit].oorAlpha)
		end
	end
end

function GladiusEx:UpdateUnitState(unit, stealth)
	if not self.buttons[unit] then
		log("UpdateUnitState", unit, "NO BUTTON")
		return
	end

	if UnitIsDeadOrGhost(unit) then
		self.buttons[unit].unit_state = STATE_DEAD
		self.buttons[unit]:SetScript("OnUpdate", nil)
		self.buttons[unit]:SetAlpha(self.db[unit].deadAlpha)
	elseif stealth then
		self.buttons[unit].unit_state = STATE_STEALTH
		self.buttons[unit]:SetScript("OnUpdate", nil)
		self.buttons[unit]:SetAlpha(self.db[unit].stealthAlpha)
	else
		self.buttons[unit].unit_state = STATE_NORMAL
		self.buttons[unit]:SetScript("OnUpdate", FrameRangeChecker_OnUpdate)
		FrameRangeChecker_OnUpdate(self.buttons[unit], RANGE_UPDATE_INTERVAL + 1)
	end

	log("UpdateUnitState", unit, self.buttons[unit].unit_state)
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

function GladiusEx:UpdateUnitSpecialization(unit, specID)
	local _, class, spec

	if specID and specID > 0 then
		_, spec, _, _, _, _, class = GetSpecializationInfoByID(specID)
	end

	specID = (specID and specID > 0) and specID or nil

	if self.buttons[unit] and self.buttons[unit].specID ~= specID then
		self.buttons[unit].class = class
		self.buttons[unit].spec = spec
		self.buttons[unit].specID = specID

		log("UpdateUnitSpecialization", unit, "is", class, "/", spec)

		self:SendMessage("GLADIUS_SPEC_UPDATE", unit)
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
	for n, m in self:IterateModules() do
		if self:IsModuleEnabled(unit, n) then
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
	if not self.buttons[unit] or self:IsTesting(unit) then return end

	-- show modules
	for n, m in self:IterateModules() do
		if self:IsModuleEnabled(unit, n) and m.Refresh then
			m:Refresh(unit)
		end
	end
end

function GladiusEx:ShowUnit(unit)
	if not self.buttons[unit] then return end

	-- show modules
	for n, m in self:IterateModules() do
		if self:IsModuleEnabled(unit, n) and m.Show then
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
	if not self.buttons[unit] then return end

	if InCombatLockdown() then
		self:QueueUpdate()
	end

	-- hide modules
	for n, m in self:IterateModules() do
		if self:IsModuleEnabled(unit, n) then
			if m.Reset then
				m:Reset(unit)
			end
		end
	end

	-- hide the button
	self.buttons[unit]:SetAlpha(0)

	if not InCombatLockdown() then
		self.buttons[unit]:Hide()
	end
end

function GladiusEx:CreateUnit(unit)
	local button = CreateFrame("Frame", "GladiusExButtonFrame" .. unit, self:IsArenaUnit(unit) and self.arena_parent or self.party_parent)
	self.buttons[unit] = button

	button.elapsed = 0
	button.unit = unit

	button:SetClampedToScreen(true)
	button:EnableMouse(true)
	button:SetMovable(true)

	button:RegisterForDrag("LeftButton")

	local drag_anchor_type = self:GetUnitAnchorType(unit)
	local drag_anchor_frame = self:GetUnitAnchor(unit)

	button:SetScript("OnMouseDown", function(f, button)
		if button == "RightButton" then
			self:ShowOptionsDialog()
		end
	end)

	button:SetScript("OnDragStart", function(f)
		if not InCombatLockdown() and not self.db.base.locked then
			local f = self.db[unit].groupButtons and drag_anchor_frame or f
			f:StartMoving()
		end
	end)

	button:SetScript("OnDragStop", function(f)
		local f = self.db[unit].groupButtons and drag_anchor_frame or f
		f:StopMovingOrSizing()

		if self.db[unit].groupButtons then
			self:SaveAnchorPosition(drag_anchor_type)
		else
			local scale = f:GetEffectiveScale()
			self.db[unit].x[unit] = f:GetLeft() * scale
			self.db[unit].y[unit] = f:GetTop() * scale
		end
	end)

	-- hide
	button:SetAlpha(0)
	button:Hide()

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

function GladiusEx:SaveAnchorPosition(anchor_type)
	local anchor = self:GetAnchorFrames(anchor_type)
	local scale = anchor:GetEffectiveScale() or 1
	self.db[anchor_type].x["anchor_" .. anchor_type] = (anchor:GetLeft() or 0) * scale
	self.db[anchor_type].y["anchor_" .. anchor_type] = (anchor:GetTop() or 0) * scale
	-- save all unit positions so that they stay at the same place if the buttons are ungrouped
	for unit, button in pairs(self.buttons) do
		self.db[unit].x[unit] = (button:GetLeft() or 0) * scale
		self.db[unit].y[unit] = (button:GetTop() or 0) * scale
	end
end

function GladiusEx:CreateAnchor(anchor_type)
	-- background
	local background = CreateFrame("Frame", "GladiusExButtonBackground" .. anchor_type, anchor_type == "party" and self.party_parent or self.arena_parent)
	background:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
	background:SetFrameStrata("BACKGROUND")

	-- anchor
	local anchor = CreateFrame("Frame", "GladiusExButtonAnchor" .. anchor_type, anchor_type == "party" and self.party_parent or self.arena_parent)
	anchor:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
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
				anchor:ClearAllPoints()
				anchor:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, f:GetBottom())
				self:SaveAnchorPosition(anchor_type)
			elseif IsAltKeyDown() then
				-- center vertically
				anchor:ClearAllPoints()
				anchor:SetPoint("LEFT", UIParent, "LEFT", f:GetLeft(), 0)
				self:SaveAnchorPosition(anchor_type)
			elseif IsControlKeyDown() then
				local other_anchor = self:GetAnchorFrames(anchor_type == "party" and "arena" or "party")
				if self.db[anchor_type].growDirection == "UP" or self.db[anchor_type].growDirection == "DOWN" or self.db[anchor_type].growDirection == "VCENTER" then
					-- set same y as the other anchor
					anchor:ClearAllPoints()
					anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", anchor:GetLeft(), other_anchor:GetTop())
				else
					-- set same x as the other anchor
					anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", other_anchor:GetLeft(), anchor:GetTop())
				end
				self:SaveAnchorPosition(anchor_type)
			end
		elseif button == "RightButton" then
			self:ShowOptionsDialog()
		end
	end)

	anchor:SetScript("OnDragStart", function(f)
		if not InCombatLockdown() and not self.db.base.locked then
			anchor:StartMoving()
		end
	end)

	anchor:SetScript("OnDragStop", function(f)
		anchor:StopMovingOrSizing()
		self:SaveAnchorPosition(anchor_type)
	end)

	anchor.text = anchor:CreateFontString("GladiusExButtonAnchorText", "OVERLAY")

	background.background_type = anchor_type
	anchor.anchor_type = anchor_type

	return anchor, background
end

function GladiusEx:GetUnitIndex(unit)
	local unit_index
	if unit == "player" or unit == "playerpet" then
		unit_index = 1
	else
		local utype, n = strmatch(unit, "^(%a+)(%d+)$")
		if utype == "party" or utype == "partypet" then
			unit_index = tonumber(n) + 1
		elseif utype == "arena" or utype == "arenapet" then
			unit_index = tonumber(n)
		else
			assert(false, "Unknown unit " .. tostring(unit))
		end
	end
	return unit_index
end

function GladiusEx:GetUnitAnchorType(unit)
	return self:IsArenaUnit(unit) and "arena" or "party"
end

function GladiusEx:GetUnitAnchor(unit)
	return self:IsArenaUnit(unit) and self.arena_anchor or self.party_anchor
end

function GladiusEx:UpdateUnitPosition(unit)
	local left, right, top, bottom = self.buttons[unit]:GetHitRectInsets()
	self.buttons[unit]:ClearAllPoints()

	if self.db[unit].groupButtons then
		local unit_index = self:GetUnitIndex(unit) - 1
		local num_frames = self:GetArenaSize()
		local anchor = self:GetUnitAnchor(unit)
		local frame_width = self.buttons[unit].frameWidth
		local frame_height = self.buttons[unit].frameHeight
		local real_width = frame_width + abs(left) + abs(right)
		local real_height = frame_height + abs(top) + abs(bottom)
		local margin_x = (real_width + self.db[unit].margin) * unit_index
		local margin_y = (real_height + self.db[unit].margin) * unit_index

		if self.db[unit].growDirection == "UP" then
			self.buttons[unit]:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", abs(left), margin_y + abs(top))
		elseif self.db[unit].growDirection == "DOWN" then
			self.buttons[unit]:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", abs(left), -margin_y - abs(top))
		elseif self.db[unit].growDirection == "LEFT" then
			self.buttons[unit]:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", -margin_x - abs(right), -abs(top))
		elseif self.db[unit].growDirection == "RIGHT" then
			self.buttons[unit]:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", margin_x + abs(left), -abs(top))
		elseif self.db[unit].growDirection == "HCENTER" then
			local offset = (real_width * (num_frames - 1) + self.db[unit].margin * (num_frames - 1) - abs(left) - abs(right)) / 2
			self.buttons[unit]:SetPoint("TOP", anchor, "BOTTOM", -offset + margin_x, -abs(top))
		elseif self.db[unit].growDirection == "VCENTER" then
			local offset = (real_height * (num_frames - 1) + self.db[unit].margin * (num_frames - 1)) / 2
			self.buttons[unit]:SetPoint("LEFT", anchor, "LEFT", abs(left), offset - margin_y)
		end
	else
		local x, y = self.db[unit].x[unit], self.db[unit].y[unit]
		if x and y then
			local eff = self.buttons[unit]:GetEffectiveScale()
			self.buttons[unit]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db[unit].x[unit] / eff, self.db[unit].y[unit] / eff)
		else
			self.buttons[unit]:SetPoint("CENTER", UIParent, "CENTER")
		end
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
	local frameWidth = self.db[unit].barWidth
	local frameHeight = 0

	-- reset hit rect
	self.buttons[unit]:SetHitRectInsets(0, 0, 0, 0)
	self.buttons[unit].secure:SetHitRectInsets(0, 0, 0, 0)

	-- update modules (bars first, because we need the height)
	for n, m in self:IterateModules() do
		if self:IsModuleEnabled(unit, n) then
			-- update and get bar height
			if m.isBarOption then
				m:Update(unit)

				local attachTo = m:GetAttachTo(unit)
				if attachTo == "Frame" or m:IsBar(unit) then
					frameHeight = frameHeight + m:GetBarHeight(unit)
				end
			end
		end
	end

	self.buttons[unit].frameWidth = frameWidth
	self.buttons[unit].frameHeight = frameHeight

	-- update button
	self.buttons[unit]:SetScale(self.db[unit].frameScale)
	self.buttons[unit]:SetSize(frameWidth, frameHeight)

	-- update modules (indicator)
	for n, m in self:IterateModules() do
		if self:IsModuleEnabled(unit, n) and not m.isBarOption and m.Update then
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

function GladiusEx:GetAnchorFrames(anchor_type)
	local anchor = anchor_type == "party" and self.party_anchor or self.arena_anchor
	local background = anchor_type == "party" and self.party_background or self.arena_background
	return anchor, background
end

function GladiusEx:UpdateAnchor(anchor_type)
	local anchor, background = self:GetAnchorFrames(anchor_type)

	-- anchor
	anchor:ClearAllPoints()
	anchor:SetSize(anchor_width, anchor_height)
	anchor:SetScale(self.db[anchor_type].frameScale)
	if (not self.db[anchor_type].x and not self.db[anchor_type].y) or (not self.db[anchor_type].x["anchor_" .. anchor.anchor_type] and not self.db[anchor_type].y["anchor_" .. anchor.anchor_type]) then
		if anchor.anchor_type == "party" then
			anchor:SetPoint("CENTER", UIParent, "CENTER", -300, 0)
		else
			anchor:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
		end
	else
		local eff = anchor:GetEffectiveScale()
		anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db[anchor_type].x["anchor_" .. anchor.anchor_type] / eff, self.db[anchor_type].y["anchor_" .. anchor.anchor_type] / eff)
	end

	anchor.text:SetPoint("CENTER", anchor, "CENTER")
	anchor.text:SetFont(self.LSM:Fetch(self.LSM.MediaType.FONT, self.db[anchor_type].globalFont), (self.db[anchor_type].useGlobalFontSize and self.db[anchor_type].globalFontSize or 11))
	anchor.text:SetTextColor(1, 1, 1, 1)
	anchor.text:SetShadowOffset(1, -1)
	anchor.text:SetShadowColor(0, 0, 0, 1)
	anchor.text:SetText(anchor.anchor_type == "party" and L["GladiusEx Party Anchor - click to move"] or L["GladiusEx Enemy Anchor - click to move"])

	if self.db[anchor_type].groupButtons and not self.db.base.locked then
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
	local width, height = self.db[anchor_type].backgroundPadding * 2, self.db[anchor_type].backgroundPadding * 2
	local real_frame_width = frame_width + abs(right) + abs(left)
	local real_frame_height = frame_height + abs(top) + abs(bottom)
	if self.db[anchor_type].growDirection == "UP" or self.db[anchor_type].growDirection == "DOWN" or self.db[anchor_type].growDirection == "VCENTER" then
		width = width + real_frame_width
		height = height + real_frame_height * num_frames + self.db[anchor_type].margin * (num_frames - 1)
	else
		width = width + real_frame_width * num_frames + self.db[anchor_type].margin * (num_frames - 1)
		height = height + real_frame_height
	end

	background:ClearAllPoints()
	background:SetSize(width, height)
	background:SetScale(self.db[anchor_type].frameScale)

	if self.db[anchor_type].growDirection == "UP" then
		background:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", -self.db[anchor_type].backgroundPadding, -self.db[anchor_type].backgroundPadding)
	elseif self.db[anchor_type].growDirection == "DOWN" then
		background:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -self.db[anchor_type].backgroundPadding, self.db[anchor_type].backgroundPadding)
	elseif self.db[anchor_type].growDirection == "LEFT" then
		background:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", self.db[anchor_type].backgroundPadding, self.db[anchor_type].backgroundPadding)
	elseif self.db[anchor_type].growDirection == "RIGHT" then
		background:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -self.db[anchor_type].backgroundPadding, self.db[anchor_type].backgroundPadding)
	elseif self.db[anchor_type].growDirection == "HCENTER" then
		background:SetPoint("TOP", anchor, "BOTTOM", 0, self.db[anchor_type].backgroundPadding)
	elseif self.db[anchor_type].growDirection == "VCENTER" then
		background:SetPoint("LEFT", anchor, "LEFT", -self.db[anchor_type].backgroundPadding, 0)
	end

	background:SetBackdropColor(self.db[anchor_type].backgroundColor.r, self.db[anchor_type].backgroundColor.g, self.db[anchor_type].backgroundColor.b, self.db[anchor_type].backgroundColor.a)

	if self.db[anchor_type].groupButtons then
		background:Show()
	else
		background:Hide()
	end
end
