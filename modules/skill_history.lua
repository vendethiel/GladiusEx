local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local fn = LibStub("LibFunctional-1.0")

-- globals

local defaults = {
	MaxIcons = 8,
	IconSize = 24,
	Margin = 2,
	Padding = 2,
	OffsetX = 0,
	OffsetY = 0,
	BackgroundColor = { r = 0, g = 0, b = 0, a = 0.5 },
	Crop = true,

	Timeout = 7,
	TimeoutAnimDuration = 0.5,

	EnterAnimDuration = 1.5,
	EnterAnimEase = "IN_OUT",
	EnterAnimEaseMode = "QUAD",
}

local MAX_ICONS = 40

local SkillHistory = GladiusEx:NewGladiusExModule("SkillHistory", false,
	fn.merge(defaults, {
		AttachTo = "ClassIcon",
		Anchor = "BOTTOMLEFT",
		RelativePoint = "TOPLEFT",
		GrowDirection = "RIGHT",
	}),
	fn.merge(defaults, {
		AttachTo = "ClassIcon",
		Anchor = "BOTTOMRIGHT",
		RelativePoint = "TOPRIGHT",
		GrowDirection = "LEFT",

		EnterAnimEase = "OUT",
		EnterAnimEaseMode = "CUBIC",
	}))

function SkillHistory:OnEnable()
	if not self.frame then
		self.frame = {}
	end

	--self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_NAME_UPDATE")
end

function SkillHistory:OnDisable()
	self:UnregisterAllEvents()

	for unit in pairs(self.frame) do
		self.frame[unit]:SetAlpha(0)
	end
end

function SkillHistory:CreateFrame(unit)
	local button = GladiusEx.buttons[unit]
	if not button then return end

	-- create frame
	self.frame[unit] = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. unit, button)
end

function SkillHistory:Update(unit)
	local testing = GladiusEx:IsTesting(unit)

	-- create frame
	if not self.frame[unit] then
		self:CreateFrame(unit)
	end

	-- frame
	local parent = GladiusEx:GetAttachFrame(unit, self.db[unit].AttachTo)
	local left, right, top, bottom = parent:GetHitRectInsets()
	self.frame[unit]:ClearAllPoints()
	self.frame[unit]:SetPoint(self.db[unit].Anchor, parent, self.db[unit].RelativePoint, self.db[unit].OffsetX, self.db[unit].OffsetY)

	-- size
	self.frame[unit]:SetWidth(self.db[unit].MaxIcons * self.db[unit].IconSize + (self.db[unit].MaxIcons - 1) * self.db[unit].Margin + self.db[unit].Padding * 2)
	self.frame[unit]:SetHeight(self.db[unit].IconSize + self.db[unit].Padding * 2)

	-- backdrop
	local bgcolor = self.db[unit].BackgroundColor
	self.frame[unit]:SetBackdrop({ bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tile = true, tileSize = 16 })
	self.frame[unit]:SetBackdropColor(bgcolor.r, bgcolor.g, bgcolor.b, bgcolor.a)

	self.frame[unit]:Hide()
end

function SkillHistory:Show(unit)
	self.frame[unit]:Show()
end

function SkillHistory:Reset(unit)
	if not self.frame[unit] then return end
	-- hide
	self:ClearUnit(unit)
	self.frame[unit]:Hide()
end

function SkillHistory:Test(unit)
	self:ClearUnit(unit)

	-- local spells = { GetSpecializationSpells(GetSpecialization()) }
	-- for i = 1, #spells / 2 do
	-- 	self:QueueSpell(unit, spells[i * 2 - 1], GetTime())
	-- end
	local specID, class, race
	specID = GladiusEx.testing[unit].specID
	class = GladiusEx.testing[unit].unitClass
	race = GladiusEx.testing[unit].unitRace
	local n = self.db[unit].MaxIcons - 1
	for spellid, spelldata in LibStub("LibCooldownTracker-1.0"):IterateCooldowns(class, specID, race) do
		self:QueueSpell(unit, spellid, GetTime() + n * self.db[unit].EnterAnimDuration)
		n = n + 1
	end
end

function SkillHistory:Refresh(unit)
end

function SkillHistory:UNIT_SPELLCAST_SUCCEEDED(event, unit, spellName, rank, lineID, spellId)
	if self.frame[unit] then
		-- casts with lineID = 0 seem to be secondary effects not directly casted by the unit
		if lineID ~= 0 then
			self:QueueSpell(unit, spellId, GetTime())
		else
			GladiusEx:Log("SKIPPING:", event, unit, spellName, rank, lineID, spellId)
		end
	end
end

function SkillHistory:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, auraType)
	if eventType == "SPELL_CAST_SUCCESS" then
		local unit = GladiusEx:GetUnitIdByGUID(sourceGUID)
		if unit and self.frame[unit] then
			self:QueueSpell(unit, spellID, GetTime())
		end
	end
end

function SkillHistory:UNIT_NAME_UPDATE(event, unit)
	if self.frame[unit] then
		self:ClearUnit(unit)
	end
end

local unit_spells = {}
local unit_queue = {}

function SkillHistory:QueueSpell(unit, spellid, time)
	if not unit_queue[unit] then unit_queue[unit] = {} end
	local uq = unit_queue[unit]

	-- avoid duplicate events
	-- if #uq > 0 then
	-- 	local last = uq[#uq]
	-- 	if last.spellid == spellid and (last.time + 1) > time then
	-- 		return
	-- 	end
	-- end

	-- if spellid == 42292 then
	-- 	icon_alliance = [[Interface\Icons\INV_Jewelry_TrinketPVP_01]]
	-- 	icon_horde = [[Interface\Icons\INV_Jewelry_TrinketPVP_02]]
	-- end

	local entry = {
		["spellid"] = spellid,
		["time"] = time
	}

	tinsert(uq, entry)

	if #uq == 1 then
		self:SetupAnimation(unit)
	end
end

local function InverseDirection(direction)
	if direction == "LEFT" then
		return "RIGHT", -1
	elseif direction == "RIGHT" then
		return "LEFT", 1
	else
		assert(false, "Invalid grow direction")
	end
end

local function GetEase(type, mod_type)
	local function linear(t) return t end
	local function quad(t) return t * t end
	local function cubic(t) return t * t * t end
	local function reverse(f) return function(t) return 1 - f(1 - t) end end
	local function reflect(f) return function(t) return .5 * (t < .5 and f(2 * t) or (2 - f(2 - 2 * t))) end end
	
	local mod
	if mod_type == "LINEAR" then mod = linear
	elseif mod_type == "QUAD" then mod = quad
	elseif mod_type == "CUBIC" then mod = cubic end
	assert(mod, "Unknown ease function " .. tostring(mod_type))

	if type == "NONE" then return linear
	elseif type == "IN" then return mod
	elseif type == "OUT" then return reverse(mod)
	elseif type == "IN_OUT" then return reflect(mod) end
	error("Invalid ease type " .. tostring(type))
end

function SkillHistory:SetupAnimation(unit)
	local uq = unit_queue[unit]
	local us = unit_spells[unit]
	local entry = uq[1]

	if not self.frame[unit].enter then
		self:CreateIcon(unit, "enter")
		self:UpdateIcon(unit, "enter")
	end

	local dir = self.db[unit].GrowDirection
	local iconsize = self.db[unit].IconSize
	local margin = self.db[unit].Margin
	local maxicons = self.db[unit].MaxIcons
	local st = GetTime()
	local off = iconsize + margin

	self.frame[unit].enter.entry = entry
	self.frame[unit].enter.icon:SetTexture(GetSpellTexture(entry.spellid))
	--self.frame[unit].enter:SetAlpha(0)
	self.frame[unit].enter:Show()

	local ease = GetEase(self.db[unit].EnterAnimEase, self.db[unit].EnterAnimEaseMode)
	

	local function AnimationFrame()
		local t = (GetTime() - st) / self.db[unit].EnterAnimDuration

		if t < 1 then
			local ox = off * ease(t)
			local oy = 0
			-- move all but the last icon
			for i = 1, maxicons - 1 do
				if self.frame[unit][i] then
					self:UpdateIconPosition(unit, i, ox, oy)
				end
			end

			if self.frame[unit][maxicons] then
				-- leave the last icon with clipping
				self:UpdateIconPosition(unit, maxicons, ox, oy)
				local left, right
				if dir == "LEFT" then
					left = min(iconsize, ox)
					right = 0
				elseif dir == "RIGHT" then
					left = 0
					right = min(iconsize, ox)
				end
				self.frame[unit][maxicons].icon:ClearAllPoints()
				self.frame[unit][maxicons].icon:SetPoint("TOPLEFT", left, 0)
				self.frame[unit][maxicons].icon:SetPoint("BOTTOMRIGHT", -right, 0)
				if self.db[unit].Crop then
					local n = 5
					local range = 1 - (n / 32)
					local texleft = n / 64 + (left / iconsize * range)
					local texright = n / 64 + ((1 - right / iconsize) * range)
					self.frame[unit][maxicons].icon:SetTexCoord(texleft, texright, n / 64, 1 - n / 64)
				else
					self.frame[unit][maxicons].icon:SetTexCoord(left / iconsize, 1 - right / iconsize, 0, 1)
				end

				-- fade last to alpha 0
				--self.frame[unit][maxicons]:SetAlpha(1 - t)
			end

			-- enter new icon with clipping
			self:UpdateIconPosition(unit, "enter", ox, oy)
			local left, right
			if dir == "LEFT" then
				left = 0
				right = iconsize - max(0, ox - margin)
			elseif dir == "RIGHT" then
				left = iconsize - max(0, ox - margin)
				right = 0
			end
			self.frame[unit].enter.icon:ClearAllPoints()
			self.frame[unit].enter.icon:SetPoint("TOPLEFT", left, 0)
			self.frame[unit].enter.icon:SetPoint("BOTTOMRIGHT", -right, 0)
			if self.db[unit].Crop then
				local n = 5
				local range = 1 - (n / 32)
				local texleft = n / 64 + (left / iconsize * range)
				local texright = n / 64 + ((1 - right / iconsize) * range)
				self.frame[unit].enter.icon:SetTexCoord(texleft, texright, n / 64, 1 - n / 64)
			else
				self.frame[unit].enter.icon:SetTexCoord(left / iconsize, 1 - right / iconsize, 0, 1)
			end

			-- fade tmp1 to alpha 1
			--self.frame[unit].enter:SetAlpha(t)
		else
			-- restore last icon
			if self.frame[unit][maxicons] then
				self:UpdateIcon(unit, maxicons)
			end

			-- after:
			--  updatespells, hide tmp1
			tremove(uq, 1)
			if #uq > 0 then
				self:SetupAnimation(unit)
			else
				self:StopAnimation(unit)
			end

			self:AddSpell(unit, entry.spellid, entry.time)
		end
	end

	self.frame[unit]:SetScript("OnUpdate", AnimationFrame)
	AnimationFrame()
end

function SkillHistory:StopAnimation(unit)
	self.frame[unit]:SetScript("OnUpdate", nil)
	if self.frame[unit].enter then
		self.frame[unit].enter:Hide()
	end
end

function SkillHistory:ClearQueue(unit)
	unit_queue[unit] = {}
	self:StopAnimation(unit)
end

function SkillHistory:AddSpell(unit, spellid, time)
	if not unit_spells[unit] then unit_spells[unit] = {} end
	local us = unit_spells[unit]

	local entry = {
		["spellid"] = spellid,
		["time"] = time
	}

	tremove(us, self.db[unit].MaxIcons)
	tinsert(us, 1, entry)

	self:UpdateSpells(unit)
end

function SkillHistory:ClearSpells(unit)
	unit_spells[unit] = {}
	self:UpdateSpells(unit)
end

function SkillHistory:UpdateSpells(unit)
	local us = unit_spells[unit]
	local now = GetTime()

	local timeout = self.db[unit].Timeout

	-- remove timed out spells
	for i = #us, 1, -1 do
		if (us[i].time + timeout) < now then
			tremove(us, i)
		end
	end

	-- update icons
	local n = min(#us, self.db[unit].MaxIcons)
	for i = 1, n do
		if not self.frame[unit][i] then
			self:CreateIcon(unit, i)
			self:UpdateIcon(unit, i)
		end
	
		self:UpdateIconPosition(unit, i, 0, 0)

		local entry = unit_spells[unit][i]
		self.frame[unit][i].entry = entry
		self.frame[unit][i].icon:SetTexture(GetSpellTexture(entry.spellid))
		self.frame[unit][i]:SetAlpha(1)
		self.frame[unit][i]:Show()

		local timeout_duration = self.db[unit].TimeoutAnimDuration
		local function FadeFrame(icon)
			local now = GetTime()
			local t = (now - icon.entry.time - timeout) / timeout_duration
			if t >= 1 then
				icon:Hide()
				icon:SetScript("OnUpdate", nil)
			elseif t > 0 then
				icon:SetAlpha(1 - t)
			end
		end
		self.frame[unit][i]:SetScript("OnUpdate", FadeFrame)
		FadeFrame(self.frame[unit][i])
	end

	-- hide unused icons
	for i = n + 1, MAX_ICONS do
		if not self.frame[unit][i] then break end
		self.frame[unit][i]:Hide()
		self.frame[unit][i]:SetScript("OnUpdate", nil)
		self.frame[unit][i].entry = nil
	end
end

function SkillHistory:ClearUnit(unit)
	self:ClearQueue(unit)
	self:ClearSpells(unit)
end

function SkillHistory:CreateIcon(unit, i)
	self.frame[unit][i] = CreateFrame("Frame", nil, self.frame[unit])
	self.frame[unit][i].icon = self.frame[unit][i]:CreateTexture(nil, "OVERLAY")

	self.frame[unit][i]:EnableMouse(false)
	self.frame[unit][i]:SetScript("OnEnter", function(self)
		if self.entry then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetSpellByID(self.entry.spellid)
		end
	end)
	self.frame[unit][i]:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
end

function SkillHistory:UpdateIcon(unit, index)
	self.frame[unit][index]:ClearAllPoints()
	self.frame[unit][index]:SetSize(self.db[unit].IconSize, self.db[unit].IconSize)
	self.frame[unit][index].icon:SetAllPoints()

	-- crop
	if self.db[unit].Crop then
		local n = 5
		self.frame[unit][index].icon:SetTexCoord(n / 64, 1 - n / 64, n / 64, 1 - n / 64)
	else
		self.frame[unit][index].icon:SetTexCoord(0, 1, 0, 1)
	end
end

function SkillHistory:UpdateIconPosition(unit, index, ox, oy)
	local i = index == "enter" and 0 or index

	-- position
	local dir = self.db[unit].GrowDirection
	local invdir, sign = InverseDirection(dir)

	local posx = self.db[unit].Padding + (self.db[unit].IconSize + self.db[unit].Margin) * (i - 1)
	self.frame[unit][index]:SetPoint(invdir, self.frame[unit], invdir, sign * (posx + ox), oy)
end

function SkillHistory:GetOptions(unit)
	local options
	options = {
	}
	
	return options
end
