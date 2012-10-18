-- globals
local type, pairs = type, pairs
local strfind, max = string.find, math.max
local UnitIsDeadOrGhost, UnitGUID = UnitIsDeadOrGhost, UnitGUID

GladiusEx = LibStub("AceAddon-3.0"):NewAddon("GladiusEx", "AceEvent-3.0")

GladiusEx.defaults = {}

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

local L

-- debugging output
local log_frame
local logging = false
local function log(...)
	if not GladiusEx.db.debug then return end
	if not log_frame then
		log_frame = CreateFrame("ScrollingMessageFrame", "GladiusExLogFrame")

		log_frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -50)

		log_frame:SetScript("OnMouseWheel", FloatingChatFrame_OnMouseScroll)
		log_frame:EnableMouseWheel(true)

		log_frame:SetSize(500, 400)
		log_frame:SetFont(STANDARD_TEXT_FONT, 9, "NONE")
		log_frame:SetShadowColor(0, 0, 0, 1)
		log_frame:SetShadowOffset(1, -1)  
		log_frame:SetFading(false)
		log_frame:SetJustifyH("LEFT")
		log_frame:SetIndentedWordWrap(true)
		log_frame:SetMaxLines(10000)
		log_frame:SetBackdropColor(1,1,1,0.2)
		log_frame.starttime = GetTime()
	end
	local p = ...
	if p == "ENABLE LOGGING" then
		GladiusEx.db.log = {}
		logging = true
		log_frame.starttime = GetTime()
	elseif p == "DISABLE LOGGING" then
		logging = false
	end

	local msg = string.format("[%.1f] %s", GetTime() - log_frame.starttime, strjoin(" ", tostringall(...)))

	if logging then
		table.insert(GladiusEx.db.log, msg)
	end

	log_frame:AddMessage(msg)
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

GladiusEx:SetDefaultModulePrototype(modulePrototype)
GladiusEx:SetDefaultModuleLibraries("AceEvent-3.0")

function GladiusEx:NewGladiusExModule(name, isbar, defaults, ...)
	local module = self:NewModule(name, ...)
	module.defaults = defaults
	module.isBarOption = isbar

	-- todo: fix this crap someday
	-- set db defaults
	for k, v in pairs(defaults) do
		self.defaults.profile[k] = v
	end
	
	return module
end

function GladiusEx:GetAttachFrame(unit, point)
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
	-- log("Attach point", point, "not found")
	return nil
end

function GladiusEx:OnInitialize()
	-- setup db
	self.dbi = LibStub("AceDB-3.0"):New("GladiusExDB", self.defaults)
	self.dbi.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.dbi.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.dbi.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	self.db = setmetatable(self.dbi.profile, {
		__newindex = function(t, index, value)
			if (type(value) == "table") then
				rawset(self.defaults.profile, index, value)
			end
			rawset(t, index, value)
		end
	})
	
	-- localization
	L = self.L
	
	-- libsharedmedia
	self.LSM = LibStub("LibSharedMedia-3.0")
	self.LSM:Register("statusbar", "Minimalist", "Interface\\Addons\\GladiusEx\\images\\Minimalist")
		
	-- test environment
	self.test = false
	self.testing = setmetatable({
		["arena1"] = { health = 32000, maxHealth = 32000, power = 18000, maxPower = 18000, powerType = 0, unitClass = "MAGE", unitRace = "Scourge", unitSpec = "Frost", specID = 64 },
		["arena2"] = { health = 30000, maxHealth = 32000, power = 10000, maxPower = 12000, powerType = 2, unitClass = "HUNTER", unitRace = "NightElf", unitSpec = "Marksmanship", specID = 254 },
		["arena3"] = { health = 24000, maxHealth = 35000, power = 90, maxPower = 120, powerType = 3, unitClass = "ROGUE", unitRace = "Human", unitSpec = "Combat", specID = 260 },
		["arena4"] = { health = 20000, maxHealth = 40000, power = 80, maxPower = 130, powerType = 6, unitClass = "DEATHKNIGHT", unitRace = "Dwarf", unitSpec = "Unholy", specID = 252 },
		["arena5"] = { health = 10000, maxHealth = 30000, power = 10, maxPower = 100, powerType = 1, unitClass = "WARRIOR", unitRace = "Gnome", unitSpec = "Arms", specID = 71 },

		["player"] = { health = 32000, maxHealth = 32000, power = 18000, maxPower = 18000, powerType = 0, unitClass = "PRIEST", unitRace = "Draenei", unitSpec = "Discipline" },
		["party1"] = { health = 30000, maxHealth = 32000, power = 10000, maxPower = 12000, powerType = 3, unitClass = "MONK", unitRace = "Pandaren", unitSpec = "Windwalker", specID = 269 },
		["party2"] = { health = 10000, maxHealth = 30000, power = 10, maxPower = 100, powerType = 1, unitClass = "WARRIOR", unitRace = "Gnome", unitSpec = "Arms", specID = 71 },
		["party3"] = { health = 20000, maxHealth = 40000, power = 80, maxPower = 130, powerType = 6, unitClass = "DEATHKNIGHT", unitRace = "Dwarf", unitSpec = "Unholy", specID = 252 },
		["party4"] = { health = 10000, maxHealth = 30000, power = 10, maxPower = 100, powerType = 1, unitClass = "WARRIOR", unitRace = "Gnome", unitSpec = "Arms", specID = 71 },

	}, { 
		__index = function(t, k)
			return t["arena1"]
		end
	})
	
	-- buttons
	self.buttons = {}
end

function GladiusEx:OnEnable()
	-- register the appropriate events
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ARENA_OPPONENT_UPDATE")
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	self:RegisterEvent("SCRIPT_ARENA_PREP_OPPONENT_SPECIALIZATIONS", "ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("INSPECT_READY")
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")

	-- enable modules
	for moduleName, module in self:IterateModules() do
		if (self.db.modules[moduleName]) then
			module:Enable()
		else
			module:Disable()
		end
	end
	
	-- create frames
	if #self.buttons == 0 then
		self:InitializeUnit("player")
		for i = 1, 4 do self:InitializeUnit("party" .. i) end
		for i = 1, 5 do self:InitializeUnit("arena" .. i) end
	end

	-- display help message
	if (not self.db.locked and not self.db.x["arena1"] and not self.db.y["arena1"] and not self.db.x["anchor_arena"] and not self.db.y["anchor_arena"]) then
		self:Print(L["Welcome to GladiusEx!"])
		self:Print(L["First run has been detected, displaying test frame."])
		self:Print(L["Valid slash commands are:"])
		self:Print(L["/gladius ui"])
		self:Print(L["/gladius test 2-5"])
		self:Print(L["/gladius hide"])
		self:Print(L["/gladius reset"])
		self:Print(L["If this is not your first run please lock or move the frame to prevent this from happening."])

		self:SetTesting(3)
	end
	
	-- see if we are already in arena
	if IsLoggedIn() then
		GladiusEx:PLAYER_ENTERING_WORLD()
	end
end

function GladiusEx:OnDisable()
	self:HideFrames()
	self:UnregisterAllEvents()
end

function GladiusEx:OnProfileChanged(event, database, newProfileKey)
	-- update frame on profile change
	self.db = self.dbi.profile

	self:UpdateFrames()
end

function GladiusEx:SetTesting(count)
	self.test = count

	if count then
		self:ShowFrames()
	else
		self:HideFrames()
	end
end

function GladiusEx:IsTesting()
	return self.test
end

function GladiusEx:GetArenaSize()
	-- try to guess the current arena size
	local guess = max(2, GetNumArenaOpponents(), GetNumArenaOpponentSpecs(), GetNumGroupMembers())
	
	if guess >= 4 then
		guess = 5
	end
	
	return guess
end

function GladiusEx:UpdatePartyFrames()
	local group_members = self:IsTesting() or self:GetArenaSize()

	log("UpdatePartyFrames", group_members)

	for i = 1, 4 do
		local unit = "party" .. i
		if group_members > i then
			self:UpdateUnit(unit)
			self:ShowUnit(unit)

			if not self:IsTesting() and not UnitExists(unit) then
				self:HideUnit(unit)
			end

			-- test environment
			if self:IsTesting() then
				self:TestUnit(unit)
			end
		else
			self:HideUnit(unit)
		end
	end

	if self.db.growDirection == "HCENTER" then
		self:CenterUnitPosition("player", group_members)
	end

	self:UpdateBackground(group_members)
end

function GladiusEx:UpdateArenaFrames()
	local numOpps = self:IsTesting() or self:GetArenaSize()

	log("UpdateArenaFrames:", numOpps, GetNumArenaOpponents(), GetNumArenaOpponentSpecs())

	for i = 1, 5 do
		local unit = "arena" .. i
		if numOpps >= i then
			self:UpdateUnit(unit)
			self:ShowUnit(unit)

			--[[
			if not self:IsTesting() and not UnitGUID(unit) then
				self:HideUnit(unit)
			end
			]]

			-- test environment
			if self:IsTesting() then
				self:TestUnit(unit)
			end
		else
			self:HideUnit(unit)
		end
	end

	if self.db.growDirection == "HCENTER" then
		self:CenterUnitPosition("arena1", numOpps)
	end

	self:UpdateBackground(numOpps)
end

function GladiusEx:UpdateFrames()
	log("UpdateFrames")

	self:UpdateUnit("player")
	self:ShowUnit("player")
	
	self:UpdatePartyFrames()
	self:UpdateArenaFrames()
end

function GladiusEx:ShowFrames()
	log("ShowFrames")

	-- background
	if (self.db.groupButtons) then
		self.background_arena:Show()
		self.background_party:Show()
		
		if (not self.db.locked) then
			self.anchor_arena:Show()
			self.anchor_party:Show()
		end
	end

	self:UpdateFrames()

	self.arena_parent:Show()

	if self.db.showParty then
		self.party_parent:Show()
	end
end

function GladiusEx:HideFrames()
	log("HideFrames")

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
	if type == "seen" or type == "destroyed" then
		self:UpdateShowUnit(unit)
		if self.db.growDirection == "HCENTER" then
			self:CenterUnitPosition("arena1", GetNumArenaOpponents())
		end
	elseif type == "unseen" then
		if self.buttons[unit] then
			self.buttons[unit]:SetAlpha(self.db.stealthAlpha)
		end
	elseif type == "cleared" then
		if not self:IsTesting() then
			self:HideUnit(unit)
		end
	end
end

function GladiusEx:GROUP_ROSTER_UPDATE()
	--if self:IsPartyShown() then
	--   self:UpdatePartyFrames()
	--end
	self:UpdateFrames()
end

function GladiusEx:PLAYER_REGEN_ENABLED()
	log("PLAYER_REGEN_ENABLED")
	self:UpdateFrames()
end

function GladiusEx:UNIT_NAME_UPDATE(event, unit)
	if not self.buttons[unit] then return end

	log("UNIT_NAME_UPDATE", unit)

	self:UpdateShowUnit(unit)
end

function GladiusEx:UNIT_HEALTH(event, unit)
	if not self.buttons[unit] then return end
	
	if UnitIsDeadOrGhost(unit) then
		self.buttons[unit]:SetAlpha(self.db.deadAlpha)
	end
end

local last_inspect = {}
function GladiusEx:INSPECT_READY(event, guid)
	for u, _ in pairs(party_units) do
		if UnitGUID(u) == guid then
			log("INSPECT_READY", u)
			self:UpdateUnitSpecialization(u, GetInspectSpecialization(u))
			break
		end
	end

	if self:IsPartyShown() then
		for u, _ in pairs(party_units) do
			if UnitExists(u) and UnitLevel(u) >= 10 and (not last_inspect[u] or (last_inspect[u] + 10) < GetTime()) then
				last_inspect[u] = GetTime()
				NotifyInspect(u)
				return
			end
		end
	end
end

function GladiusEx:PLAYER_SPECIALIZATION_CHANGED(event, unit)
	log(event, unit)

	self:CheckUnitSpecialization(unit or "player")
end

function GladiusEx:CheckUnitSpecialization(unit)
	log("CheckUnitSpecialization", unit)

	if unit == "player" then
		local spec = GetSpecialization()
		specID = GetSpecializationInfo(spec)
	else
		specID = GetInspectSpecialization(unit)
		if specID == 0 then
			NotifyInspect(unit)
		end
	end
	self:UpdateUnitSpecialization(unit, specID)
end

function GladiusEx:UpdateUnitSpecialization(unitid, specID)
	log("UpdateUnitSpecialization", unitid, specID)

	local _, class, spec

	if specID > 0 then 
		_, spec, _, _, _, _, class = GetSpecializationInfoByID(specID)
	end

	specID = specID > 0 and specID or nil

	if self.buttons[unitid] and self.buttons[unitid].specID ~= specID then
		self.buttons[unitid].class = class
		self.buttons[unitid].spec = spec
		self.buttons[unitid].specID = specID

		log(unitid, "is", class, "/", spec)
		
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

function GladiusEx:InitializeUnit(unit)
	self:CreateUnit(unit)
	self:UpdateUnit(unit)
end

function GladiusEx:TestUnit(unit)
	if not self:IsHandledUnit(unit) then return end

	log("TestUnit", unit)
	
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

function GladiusEx:UpdateShowUnit(unit)
	if UnitGUID(unit) then
		self:ShowUnit(unit)
	end
end

function GladiusEx:ShowUnit(unit)
	if (not self.buttons[unit]) then return end

	log("ShowUnit", unit, self.buttons[unit]:GetAlpha(), self.buttons[unit]:IsShown())

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
			log("ShowUnit: tried to show, but InCombatLockdown")
		end
	end

	-- update spec
	if self:IsPartyUnit(unit) and not self.buttons[unit].spec then
		local specID = 0
		self:CheckUnitSpecialization(unit)
	end
end

function GladiusEx:HideUnit(unit)
	if (not self.buttons[unit]) then return end

	log("HideUnit", unit)
	
	for name, m in self:IterateModules() do
		if (m:IsEnabled()) then
			if m.Reset then
				m:Reset(unit)
			end
		end
	end
	
	-- hide the button
	self.buttons[unit]:SetAlpha(0)
	
	--[[
	if not InCombatLockdown() then
		self.buttons[unit]:Hide()
		self.buttons[unit].secure:Hide()
	else
		log("hideunit: not calling Hide due to InCombatLockdown")
	end
	]]
end

function GladiusEx:CreateUnit(unit)
	if not self.party_parent then
		self.party_parent = CreateFrame("Frame", "GladiusExPartyFrame", UIParent)
		self.arena_parent = CreateFrame("Frame", "GladiusExArenaFrame", UIParent)

		self.party_parent:SetSize(1, 1)
		self.arena_parent:SetSize(1, 1)

		self.party_parent:Hide()
		self.arena_parent:Hide()
	end

	-- anchor & background
	if (unit == "arena1") then
		local anchor, background = self:CreateAnchor(unit)
		self.anchor_arena = anchor
		self.background_arena = background
	elseif (unit == "player") then
		local anchor, background = self:CreateAnchor(unit)
		self.anchor_party = anchor
		self.background_party = background
	end

	local button = CreateFrame("Frame", "GladiusExButtonFrame" .. unit, self:IsArenaUnit(unit) and self.arena_parent or self.party_parent)
	self.buttons[unit] = button

	-- hide
	self.buttons[unit]:SetAlpha(0)
	self.buttons[unit]:Hide()
	
	-- Commenting this out as it messes up the look of the bar backgrounds.
	-- Should leave the background color to the actual background frame 
	-- and the bar backgrounds imo - Proditor
	--[[
	button:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,})
	button:SetBackdropColor(0, 0, 0, 0.4)
	--]]
	 
	button:SetClampedToScreen(true)
	button:EnableMouse(true)
	button:SetMovable(true)

	button:RegisterForDrag("LeftButton")

	local dragparentunit = self:IsArenaUnit(unit) and "anchor_arena" or "anchor_party"
	local dragparent = self:IsArenaUnit(unit) and self.anchor_arena or self.anchor_party
	
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
	button.secure:RegisterForClicks("AnyUp")
	button.secure:SetAttribute("*type1", "target")
	button.secure:SetAttribute("*type2", "focus")
	
	-- clique support
	ClickCastFrames = ClickCastFrames or {}
	ClickCastFrames[button.secure] = true
end

function GladiusEx:CreateAnchor(unit)
	-- background
	local background = CreateFrame("Frame", "GladiusExButtonBackground" .. unit, self:IsArenaUnit(unit) and self.arena_parent or self.party_parent)
	background:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,})
	background:SetBackdropColor(self.db.backgroundColor.r, self.db.backgroundColor.g, self.db.backgroundColor.b, self.db.backgroundColor.a)
	
	background:SetFrameStrata("BACKGROUND")

	local anchor = CreateFrame("Frame", "GladiusExButtonAnchor" .. unit, self:IsArenaUnit(unit) and self.arena_parent or self.party_parent)
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
			SlashCmdList["GLADIUS"]("options")
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
		self.db.x[self:IsArenaUnit(unit) and "anchor_arena" or "anchor_party"] = f:GetLeft() * scale
		self.db.y[self:IsArenaUnit(unit) and "anchor_arena" or "anchor_party"] = f:GetTop() * scale
	end)
	
	anchor.text = anchor:CreateFontString("GladiusExButtonAnchorText", "OVERLAY")

	return anchor, background
end

function GladiusEx:UpdateBackground(maxUnits)
	-- update background size
	if self.db.growDirection == "UP" or self.db.growDirection == "DOWN" then
		-- vertical
		local h = self.buttons["player"].frameHeight * maxUnits + self.db.margin * (maxUnits - 1) + self.db.backgroundPadding * 2
		self.background_arena:SetHeight(h)
		self.background_party:SetHeight(h)
	else
		-- horizontal
		local left, right = self.buttons["player"]:GetHitRectInsets()
		local w = (self.db.barWidth + abs(left) + abs(right)) * maxUnits + self.db.margin * (maxUnits - 1) + self.db.backgroundPadding * 2
		self.background_arena:SetWidth(w)
		self.background_party:SetWidth(w)
	end
end

function GladiusEx:UpdateUnit(unit, module)
	if not self:IsHandledUnit(unit) then return end

	log("UpdateUnit", unit)

	-- todo: handle this properly
	if (InCombatLockdown()) then 
		log("UpdateUnit aborted due to InCombatLockdown")
		return 
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

	-- set point
	local left, right = self.buttons[unit]:GetHitRectInsets()
	self.buttons[unit]:ClearAllPoints()
	if (unit == "arena1" or unit == "player" or not self.db.groupButtons) then
		local anchor = unit == "arena1" and self.anchor_arena or self.anchor_party

		if self.db.growDirection == "UP" then
			self.buttons[unit]:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", abs(left), 0)
		elseif self.db.growDirection == "DOWN" or self.db.growDirection == "RIGHT"  then
			self.buttons[unit]:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", abs(left), 0)
		elseif self.db.growDirection == "LEFT" then
			self.buttons[unit]:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", -abs(right), 0)
		elseif self.db.growDirection == "HCENTER" then
			self:CenterUnitPosition(unit, self:IsTesting() or 3)
		end
	else
		local base, n = string.match(unit, "^(%a+)(%d+)$")
		local parentUnit = unit == "party1" and "player" or (base .. (n - 1))
		local parentButton = self.buttons[parentUnit] 
		
		if self.db.growDirection == "UP" then
			self.buttons[unit]:SetPoint("BOTTOMLEFT", parentButton, "TOPLEFT", 0, self.db.margin)
		elseif self.db.growDirection == "DOWN" then
			self.buttons[unit]:SetPoint("TOPLEFT", parentButton, "BOTTOMLEFT", 0, -self.db.margin)
		elseif self.db.growDirection == "LEFT" then
			self.buttons[unit]:SetPoint("TOPLEFT", parentButton, "TOPLEFT", -frameWidth - abs(left) - abs(right) - self.db.margin, 0)
		elseif self.db.growDirection == "RIGHT" or self.db.growDirection == "HCENTER" then
			self.buttons[unit]:SetPoint("TOPLEFT", parentButton, "TOPLEFT", frameWidth + abs(left) + abs(right) + self.db.margin, 0)
	  end
	end   
	
	-- update secure frame
	self.buttons[unit].secure:ClearAllPoints()
	self.buttons[unit].secure:SetAllPoints(self.buttons[unit])
	
	-- show the secure frame
	self.buttons[unit].secure:Show()
	self.buttons[unit].secure:SetAlpha(1)
	
	self.buttons[unit]:SetFrameStrata("LOW")
	self.buttons[unit].secure:SetFrameStrata("MEDIUM")
	
	-- update background and anchor
	if (unit == "arena1" or unit == "player") then
		local left, right, top, bottom = self.buttons[unit]:GetHitRectInsets()
		local anchor_type = unit == "arena1" and "anchor_arena" or "anchor_party"
		local anchor = unit == "arena1" and self.anchor_arena or self.anchor_party
		local background = unit == "arena1" and self.background_arena or self.background_party

		-- anchor
		anchor:ClearAllPoints()
		anchor:SetSize(220, 20)
		anchor:SetScale(self.db.frameScale)
		if (not self.db.x and not self.db.y) or (not self.db.x[anchor_type] and not self.db.y[anchor_type]) then
			if unit == "player" then
				anchor:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
			else
				anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
			end
		else
			local eff = anchor:GetEffectiveScale()
			anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.x[anchor_type] / eff, self.db.y[anchor_type] / eff)
		end
	  
		anchor.text:SetPoint("CENTER", anchor, "CENTER")
		anchor.text:SetFont(self.LSM:Fetch(self.LSM.MediaType.FONT, self.db.globalFont), (self.db.useGlobalFontSize and self.db.globalFontSize or 11))
		anchor.text:SetTextColor(1, 1, 1, 1)
		
		anchor.text:SetShadowOffset(1, -1)
		anchor.text:SetShadowColor(0, 0, 0, 1)   
		
		anchor.text:SetText(unit == "player" and L["GladiusEx Party Anchor - click to move"] or L["GladiusEx Enemy Anchor - click to move"])
		
		if (self.db.groupButtons and not self.db.locked) then
			anchor:Show()
		else         
			anchor:Hide()
		end

		-- background
		background:SetBackdropColor(self.db.backgroundColor.r, self.db.backgroundColor.g, self.db.backgroundColor.b, self.db.backgroundColor.a)         
		if self.db.growDirection == "UP" or self.db.growDirection == "DOWN" then
			-- vertical
			background:SetWidth(self.db.barWidth + self.db.backgroundPadding * 2 + abs(right) + abs(left))
		else
			-- horizontal
			background:SetHeight(frameHeight + self.db.backgroundPadding * 2 + abs(top) + abs(bottom))
		end


		background:ClearAllPoints()      
		if self.db.growDirection == "UP" then
			background:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT")
		elseif self.db.growDirection == "DOWN" or self.db.growDirection == "RIGHT"  then
			background:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT")
		elseif self.db.growDirection == "LEFT" then
			background:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT")
		end
		
		background:SetScale(self.db.frameScale)
		
		if (self.db.groupButtons) then
			background:Show()
		else         
			background:Hide()
		end
	end
end

function GladiusEx:CenterUnitPosition(unit, numFrames)
	if InCombatLockdown() then
		log("CenterUnitPosition: aborting due to InCombatLockdown")
		return
	end

	local anchor = self:IsArenaUnit(unit)  and self.anchor_arena or self.anchor_party
	local frameWidth = self.buttons[unit].frameWidth
	local left, right = self.buttons[unit]:GetHitRectInsets()

	local offset = (frameWidth + abs(left) + abs(right) + self.db.margin) * (numFrames - 1) / 2
	self.buttons[unit]:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -offset + abs(left) , 0)
end
