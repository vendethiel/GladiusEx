local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local fn = LibStub("LibFunctional-1.0")
local LSM = LibStub("LibSharedMedia-3.0")

-- upvalues
local strfind = string.find
local pairs, select, unpack = pairs, select, unpack
local GetTime, SetPortraitTexture = GetTime, SetPortraitTexture
local GetSpellInfo, UnitAura, UnitClass, UnitGUID, UnitBuff, UnitDebuff = GetSpellInfo, UnitAura, UnitClass, UnitGUID, UnitBuff, UnitDebuff
local UnitIsVisible, UnitIsConnected, GetSpecializationInfoByID, GetTexCoordsForRole = UnitIsVisible, UnitIsConnected, GetSpecializationInfoByID, GetTexCoordsForRole

--local CLASS_BUTTONS = CLASS_BUTTONS

-- NOTE: this list can be modified from the ClassIcon module options, no need to edit it here
-- Nonetheless, if you think that we missed an important aura, please post it on the addon site at curse or wowace
-- V: list imported from Gladius 5.1.6
local function GetDefaultImportantAuras()
	return {
		-- Higher Number is More Priority
		-- Priority List by P0rkz
		-- Unpurgable long lasting buffs
		--[GladiusEx:SafeGetSpellName(108292)]	= 0,	-- Heart of the Wild
		-- Mobility Auras (0)
		[GladiusEx:SafeGetSpellName(108843)]	= 0,	-- Blazing Speed
		[GladiusEx:SafeGetSpellName(65081)]	= 0,	-- Body and Soul
		[GladiusEx:SafeGetSpellName(108212)]	= 0,	-- Burst of Speed
		[GladiusEx:SafeGetSpellName(68992)]	= 0,	-- Darkflight
		[GladiusEx:SafeGetSpellName(1850)]	= 0,	-- Dash
		[GladiusEx:SafeGetSpellName(137452)]	= 0,	-- Displacer Beast
		[GladiusEx:SafeGetSpellName(114239)]	= 0,	-- Phantasm
		[GladiusEx:SafeGetSpellName(118922)]	= 0,	-- Posthaste
		[GladiusEx:SafeGetSpellName(85499)]	= 0,	-- Speed of Light
		[GladiusEx:SafeGetSpellName(2983)]	= 0,	-- Sprint
		[GladiusEx:SafeGetSpellName(06898)]	= 0,	-- Stampeding Roar
		[GladiusEx:SafeGetSpellName(116841)]	= 0, 	-- Tiger's Lust
		-- Movement Reduction Auras (1)
		[GladiusEx:SafeGetSpellName(5116)]	= 1,	-- Concussive Shot
		[GladiusEx:SafeGetSpellName(120)]		= 1,	-- Cone of Cold
		[GladiusEx:SafeGetSpellName(13809)]	= 1,	-- Frost Trap
		-- Purgable Buffs (2)
		[GladiusEx:SafeGetSpellName(31842)]	= 2,	-- Divine Favor
		[GladiusEx:SafeGetSpellName(112965)]	= 2,	-- Fingers of Frost
		[GladiusEx:SafeGetSpellName(1044)]	= 2,	-- Hand of Freedom
		[GladiusEx:SafeGetSpellName(1022)]	= 2,	-- Hand of Protection
		[GladiusEx:SafeGetSpellName(6940)]	= 2,	-- Hand of Sacrifice
		[GladiusEx:SafeGetSpellName(11426)]	= 2,	-- Ice Barrier
		[GladiusEx:SafeGetSpellName(53271)]	= 2,	-- Master's Call
		[GladiusEx:SafeGetSpellName(48108)]	= 2,	-- Pyroblast!
		-- Defensive - Damage Redution Auras (3)
		[GladiusEx:SafeGetSpellName(108271)]	= 3,	-- Astral Shift
		[GladiusEx:SafeGetSpellName(22812)]	= 3,	-- Barkskin
		[GladiusEx:SafeGetSpellName(18499)]	= 3,	-- Berserker Rage
		[GladiusEx:SafeGetSpellName(74001)]	= 3,	-- Combat Readiness
		[GladiusEx:SafeGetSpellName(31224)]	= 3,	-- Cloak of Shadows
		[GladiusEx:SafeGetSpellName(108359)]	= 3,	-- Dark Regeneration
		[GladiusEx:SafeGetSpellName(118038)]	= 3,	-- Die by the Sword
		[GladiusEx:SafeGetSpellName(498)]		= 3,	-- Divine Protection
		[GladiusEx:SafeGetSpellName(5277)]	= 3,	-- Evasion
		[GladiusEx:SafeGetSpellName(47788)]	= 3,	-- Guardian Spirit
		[GladiusEx:SafeGetSpellName(48792)]	= 3,	-- Icebound Fortitude
		[GladiusEx:SafeGetSpellName(66)]		= 3,	-- Invisibility
		[GladiusEx:SafeGetSpellName(102342)]	= 3,	-- Ironbark
		[GladiusEx:SafeGetSpellName(12975)]	= 3,	-- Last Stand
		[GladiusEx:SafeGetSpellName(49039)]	= 3,	-- Lichborne
		[GladiusEx:SafeGetSpellName(116849)]	= 3,	-- Life Cocoon
		[GladiusEx:SafeGetSpellName(114028)]	= 3,	-- Mass Spell Reflection
		[GladiusEx:SafeGetSpellName(124974)]	= 3,	-- Nature's Vigil
		[GladiusEx:SafeGetSpellName(33206)]	= 3,	-- Pain Suppression
		[GladiusEx:SafeGetSpellName(53480)]	= 3,	-- Roar of Sacrifice
		[GladiusEx:SafeGetSpellName(871)]		= 3,	-- Shield Wall
		[GladiusEx:SafeGetSpellName(112833)]	= 3,	-- Spectral Guise
		[GladiusEx:SafeGetSpellName(23920)]	= 3,	-- Spell Reflection
		[GladiusEx:SafeGetSpellName(122470)]	= 3,	-- Touch of Karma
		[GladiusEx:SafeGetSpellName(61336)]	= 3,	-- Survival Instincts
		-- Offensive - Melee Auras (4)
		[GladiusEx:SafeGetSpellName(13750)]	= 4,	-- Adrenaline Rush
		[GladiusEx:SafeGetSpellName(152151)]	= 4,	-- Shadow Reflection
		[GladiusEx:SafeGetSpellName(107574)]	= 4,	-- Avatar
		[GladiusEx:SafeGetSpellName(12292)]	= 4,	-- Bloodbath
		[GladiusEx:SafeGetSpellName(51271)]	= 4,	-- Pillar of Frost
		[GladiusEx:SafeGetSpellName(1719)]	= 4,	-- Recklessness
		[GladiusEx:SafeGetSpellName(185313)]	= 4,	-- Shadow Dance
		-- Roots (5)
		[GladiusEx:SafeGetSpellName(91807)]	= 5,	-- Shambling Rush (Ghoul)
		[GladiusEx:SafeGetSpellName(61685)]	= 5,	-- Charge (Druid)
		[GladiusEx:SafeGetSpellName(105771)]	= 5,	-- Charge (Warrior)
		[GladiusEx:SafeGetSpellName(116706)]	= 5,	-- Disable
		[GladiusEx:SafeGetSpellName(114404)]	= 5,	-- Void Tendrils
		[GladiusEx:SafeGetSpellName(64695)]	= 5,	-- Earthgrab
		[GladiusEx:SafeGetSpellName(64803)]	= 5,	-- Entrapment
		[GladiusEx:SafeGetSpellName(107566)]	= 5,	-- Staggering Shout
		[GladiusEx:SafeGetSpellName(339)]		= 5,	-- Entangling Roots
		[GladiusEx:SafeGetSpellName(33395)]	= 5,	-- Freeze (Water Elemental)
		[GladiusEx:SafeGetSpellName(122)]		= 5,	-- Frost Nova
		[GladiusEx:SafeGetSpellName(102359)]	= 5,	-- Mass Entanglement
		[GladiusEx:SafeGetSpellName(136634)]	= 5,	-- Narrow Escape
		-- See Invis (also 5)
		[GladiusEx:SafeGetSpellName(188501)]	= 5,	-- Spectral Sight
		-- Offensive - Ranged / Spell Auras (6)
		[GladiusEx:SafeGetSpellName(12042)]	= 6,	-- Arcane Power
		[GladiusEx:SafeGetSpellName(114049)]	= 6,	-- Ascendance
		[GladiusEx:SafeGetSpellName(31884)]	= 6,	-- Avenging Wrath
		[GladiusEx:SafeGetSpellName(16166)]	= 6,	-- Elemental Mastery
		[GladiusEx:SafeGetSpellName(12472)]	= 6,	-- Icy Veins
		[GladiusEx:SafeGetSpellName(33891)]	= 6,	-- Incarnation: Tree of Life
		[GladiusEx:SafeGetSpellName(102560)]	= 6,	-- Incarnation: Chosen of Elune
		[GladiusEx:SafeGetSpellName(102543)]	= 6,	-- Incarnation: King of the Jungle
		[GladiusEx:SafeGetSpellName(102558)]	= 6,	-- Incarnation: Son of Ursoc
		[GladiusEx:SafeGetSpellName(10060)]	= 6,	-- Power Infusion
		[GladiusEx:SafeGetSpellName(3045)]	= 6,	-- Rapid Fire
		-- Silence and Spell Immunities Auras (7)
		[GladiusEx:SafeGetSpellName(31821)]	= 7,	-- Devotion Aura
		[GladiusEx:SafeGetSpellName(8178)]	= 7,	-- Grounding Totem Effect
		[GladiusEx:SafeGetSpellName(131558)]	= 7,	-- Spiritwalker's Aegis
		[GladiusEx:SafeGetSpellName(104773)]	= 7,	-- Unending Resolve
		[GladiusEx:SafeGetSpellName(124488)]	= 7,	-- Zen Focus
		-- Silence Auras (8)
		[GladiusEx:SafeGetSpellName(1330)]	= 8,	-- Garrote (Silence)
		[GladiusEx:SafeGetSpellName(15487)]	= 8,	-- Silence
		[GladiusEx:SafeGetSpellName(47476)]	= 8,	-- Strangulate
		[GladiusEx:SafeGetSpellName(31935)]	= 8,	-- Avenger's Shield
		[GladiusEx:SafeGetSpellName(28730)]	= 8,	-- Arcane Torrent (Mana version)
		[GladiusEx:SafeGetSpellName(80483)]	= 8,	-- Arcane Torrent (Focus version)
		[GladiusEx:SafeGetSpellName(25046)]	= 8,	-- Arcane Torrent (Energy version)
		[GladiusEx:SafeGetSpellName(50613)]	= 8,	-- Arcane Torrent (Runic Power version)
		[GladiusEx:SafeGetSpellName(69179)]	= 8,	-- Arcane Torrent (Rage version)
		-- Disorients & Stuns Auras (9)
		[GladiusEx:SafeGetSpellName(108194)]	= 9,	-- Asphyxiate
		[GladiusEx:SafeGetSpellName(91800)]	= 9,	-- Gnaw (Ghoul)
		[GladiusEx:SafeGetSpellName(91797)]	= 9,	-- Monstrous Blow (Dark Transformation Ghoul)
		[GladiusEx:SafeGetSpellName(89766)]	= 9,	-- Axe Toss (Felguard)
		[GladiusEx:SafeGetSpellName(117526)]	= 9,	-- Binding Shot
		[GladiusEx:SafeGetSpellName(224729)]	= 9,	-- Bursting Shot
		[GladiusEx:SafeGetSpellName(213691)]	= 9,	-- Scatter Shot
		[GladiusEx:SafeGetSpellName(24394)]	= 9,	-- Intimidation
		[GladiusEx:SafeGetSpellName(105421)]	= 9,	-- Blinding Light
		[GladiusEx:SafeGetSpellName(7922)]	= 9,	-- Charge Stun
		[GladiusEx:SafeGetSpellName(1833)]	= 9,	-- Cheap Shot
		[GladiusEx:SafeGetSpellName(77505)]	= 9,	-- Earthquake
		[GladiusEx:SafeGetSpellName(120086)]	= 9,	-- Fist of Fury
		[GladiusEx:SafeGetSpellName(99)]		= 9,	-- Disorienting Roar
		[GladiusEx:SafeGetSpellName(31661)]	= 9,	-- Dragon's Breath
		[GladiusEx:SafeGetSpellName(47481)]	= 9,	-- Gnaw
		[GladiusEx:SafeGetSpellName(1776)]	= 9,	-- Gouge
		[GladiusEx:SafeGetSpellName(853)]		= 9,	-- Hammer of Justice
		[GladiusEx:SafeGetSpellName(88625)]	= 9,	-- Holy Word: Chastise
		[GladiusEx:SafeGetSpellName(19577)]	= 9,	-- Intimidation
		[GladiusEx:SafeGetSpellName(408)]		= 9,	-- Kidney Shot
		[GladiusEx:SafeGetSpellName(119381)]	= 9,	-- Leg Sweep
		[GladiusEx:SafeGetSpellName(22570)]	= 9,	-- Maim
		[GladiusEx:SafeGetSpellName(5211)]	= 9,	-- Mighty Bash
		[GladiusEx:SafeGetSpellName(118345)]	= 9,	-- Pulverize (Primal Earth Elemental)
		[GladiusEx:SafeGetSpellName(30283)]	= 9,	-- Shadowfury
		[GladiusEx:SafeGetSpellName(22703)]	= 9,	-- Summon Infernal
		[GladiusEx:SafeGetSpellName(46968)]	= 9,	-- Shockwave
		[GladiusEx:SafeGetSpellName(118905)]	= 9,	-- Static Charge (Capacitor Totem Stun)
		[GladiusEx:SafeGetSpellName(132169)]	= 9,	-- Storm Bolt
		[GladiusEx:SafeGetSpellName(20549)]	= 9,	-- War Stomp
		[GladiusEx:SafeGetSpellName(16979)]	= 9,	-- Wild Charge
		[GladiusEx:SafeGetSpellName(117526)]  = 9,    -- Binding Shot
		[GladiusEx:SafeGetSpellName(163505)]              = 9,    -- Rake
		-- Crowd Controls Auras (10)
		[GladiusEx:SafeGetSpellName(710)]		= 10,	-- Banish
		[GladiusEx:SafeGetSpellName(2094)]	= 10,	-- Blind
		[GladiusEx:SafeGetSpellName(33786)]	= 10,	-- Cyclone
		[GladiusEx:SafeGetSpellName(605)]		= 10,	-- Dominate Mind
		[GladiusEx:SafeGetSpellName(118699)]	= 10,	-- Fear
		[GladiusEx:SafeGetSpellName(3355)]	= 10,	-- Freezing Trap
		[GladiusEx:SafeGetSpellName(51514)]	= 10,	-- Hex
		[GladiusEx:SafeGetSpellName(5484)]	= 10,	-- Howl of Terror
		[GladiusEx:SafeGetSpellName(5246)]	= 10,	-- Intimidating Shout
		[GladiusEx:SafeGetSpellName(115268)]	= 10,	-- Mesmerize (Shivarra)
		[GladiusEx:SafeGetSpellName(6789)]	= 10,	-- Mortal Coil
		[GladiusEx:SafeGetSpellName(115078)]	= 10,	-- Paralysis
		[GladiusEx:SafeGetSpellName(118)]		= 10,	-- Polymorph
		[GladiusEx:SafeGetSpellName(8122)]	= 10,	-- Psychic Scream
		[GladiusEx:SafeGetSpellName(64044)]	= 10,	-- Psychic Horror
		[GladiusEx:SafeGetSpellName(20066)]	= 10,	-- Repentance
		[GladiusEx:SafeGetSpellName(82691)]	= 10,	-- Ring of Frost
		[GladiusEx:SafeGetSpellName(6770)]	= 10,	-- Sap
		[GladiusEx:SafeGetSpellName(107079)]	= 10,	-- Quaking Palm
		[GladiusEx:SafeGetSpellName(6358)]	= 10,	-- Seduction (Succubus)
		[GladiusEx:SafeGetSpellName(9484)]	= 10,	-- Shackle Undead
		[GladiusEx:SafeGetSpellName(19386)]	= 10,	-- Wyvern Sting
		-- Immunity Auras (11)
		[GladiusEx:SafeGetSpellName(48707)]	= 11,	-- Anti-Magic Shell
		[GladiusEx:SafeGetSpellName(46924)]	= 11,	-- Bladestorm
		[GladiusEx:SafeGetSpellName(19263)]	= 11,	-- Deterrence
		[GladiusEx:SafeGetSpellName(47585)]	= 11,	-- Dispersion
		[GladiusEx:SafeGetSpellName(642)]		= 11,	-- Divine Shield
		[GladiusEx:SafeGetSpellName(45438)]	= 11,	-- Ice Block
		-- Drink (12)
		[GladiusEx:SafeGetSpellName(118358)]	= 12,	-- Drink
	}
end

local defaults = {
	classIconMode = "SPEC",
	classIconGloss = false,
	classIconGlossColor = { r = 1, g = 1, b = 1, a = 0.4 },
	classIconImportantAuras = true,
	classIconCrop = true,
	classIconCooldown = true,
	classIconCooldownReverse = true,
	classIconAuras = GetDefaultImportantAuras()
}

local ClassIcon = GladiusEx:NewGladiusExModule("ClassIcon",
	fn.merge(defaults, {
		classIconPosition = "LEFT",
	}),
	fn.merge(defaults, {
		classIconPosition = "RIGHT",
	}))

function ClassIcon:OnEnable()
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "UNIT_AURA")
	self:RegisterEvent("UNIT_MODEL_CHANGED")
	self:RegisterMessage("GLADIUS_SPEC_UPDATE", "UNIT_AURA")

	if not self.frame then
		self.frame = {}
	end
end

function ClassIcon:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()

	for unit in pairs(self.frame) do
		self.frame[unit]:Hide()
	end
end

function ClassIcon:GetAttachType(unit)
	return "InFrame"
end

function ClassIcon:GetAttachPoint(unit)
	return self.db[unit].classIconPosition
end

function ClassIcon:GetAttachSize(unit)
	return GladiusEx:GetBarsHeight(unit)
end

function ClassIcon:GetModuleAttachPoints()
	return {
		["ClassIcon"] = L["ClassIcon"],
	}
end

function ClassIcon:GetModuleAttachFrame(unit)
	if not self.frame[unit] then
		self:CreateFrame(unit)
	end

	return self.frame[unit]
end

function ClassIcon:UNIT_AURA(event, unit)
	if not self.frame[unit] then return end

	-- important auras
	self:UpdateAura(unit)
end

function ClassIcon:UNIT_MODEL_CHANGED(event, unit)
	if not self.frame[unit] then return end

	-- force model update
	if self.frame[unit].portrait3d then
		self.frame[unit].portrait3d.guid = false
	end

	self:UpdateAura(unit)
end

function ClassIcon:ScanAuras(unit)
	local best_priority = 0
	local best_name, best_icon, best_duration, best_expires

	local interrupt = {Interrupt:GetInterruptFor(unit)}
	if interrupt[1] then
		return unpack(interrupt) 
	end

	local function handle_aura(name, spellid, icon, duration, expires)
		local prio = self:GetImportantAura(unit, name) or self:GetImportantAura(unit, spellid)
		-- V: make sure we have a best_expires before comparing it
		if prio and prio > best_priority or (prio == best_priority and best_expires and expires < best_expires) then
			best_name = name
			best_icon = icon
			best_duration = duration
			best_expires = expires
			best_priority = prio
		end
	end

	-- debuffs
	for index = 1, 40 do
		local name, _, icon, _, _, duration, expires, _, _, _, spellid = UnitDebuff(unit, index)
		if not name then break end
		handle_aura(name, spellid, icon, duration, expires)
	end

	-- buffs
	for index = 1, 40 do
		local name, _, icon, _, _, duration, expires, _, _, _, spellid = UnitBuff(unit, index)
		if not name then break end
		handle_aura(name, spellid, icon, duration, expires)
	end

	return best_name, best_icon, best_duration, best_expires
end

function ClassIcon:UpdateAura(unit)
	if not self.frame[unit] or not self.db[unit].classIconImportantAuras then return end

	local name, icon, duration, expires = self:ScanAuras(unit)

	if name then
		self:SetAura(unit, name, icon, duration, expires)
	else
		self:SetClassIcon(unit)
	end
end

function ClassIcon:SetAura(unit, name, icon, duration, expires)
	-- display aura
	self:SetTexture(unit, icon, true, 0, 1, 0, 1)

	if self.db[unit].classIconCooldown then
		CooldownFrame_Set(self.frame[unit].cooldown, expires - duration, duration, 1)
		self.frame[unit].cooldown:Show()
	end
end

function ClassIcon:SetTexture(unit, texture, needs_crop, left, right, top, bottom)
	-- so the user wants a border, but the borders in the blizzard icons are
	-- messed up in random ways (some are missing the alpha at the corners, some contain
	-- random blocks of colored pixels there)
	-- so instead of using the border already present in the icons, we crop them and add
	-- our own (this would have been a lot easier if wow allowed alpha mask textures)
	local needs_border = needs_crop and not self.db[unit].classIconCrop
	local size = self:GetAttachSize(unit)
	if needs_border then
		self.frame[unit].texture:ClearAllPoints()
		self.frame[unit].texture:SetPoint("CENTER")
		self.frame[unit].texture:SetWidth(size * (1 - 6 / 64))
		self.frame[unit].texture:SetHeight(size * (1 - 6 / 64))
		self.frame[unit].texture_border:Show()
	else
		self.frame[unit].texture:ClearAllPoints()
		self.frame[unit].texture:SetPoint("CENTER")
		self.frame[unit].texture:SetWidth(size)
		self.frame[unit].texture:SetHeight(size)
		self.frame[unit].texture_border:Hide()
	end

	if needs_crop then
		local n
		if self.db[unit].classIconCrop then n = 5 else n = 3 end
		left = left + (right - left) * (n / 64)
		right = right - (right - left) * (n / 64)
		top = top + (bottom - top) * (n / 64)
		bottom = bottom - (bottom - top) * (n / 64)
	end

	-- set texture
	self.frame[unit].texture:SetTexture(texture)
	self.frame[unit].texture:SetTexCoord(left, right, top, bottom)

	-- hide portrait
	if self.frame[unit].portrait3d then
		self.frame[unit].portrait3d:Hide()
	end
	if self.frame[unit].portrait2d then
		self.frame[unit].portrait2d:Hide()
	end
end

function ClassIcon:SetClassIcon(unit)
	if not self.frame[unit] then return end

	-- hide cooldown frame
	self.frame[unit].cooldown:Hide()

	if self.db[unit].classIconMode == "PORTRAIT2D" then
		-- portrait2d
		if not self.frame[unit].portrait2d then
			self.frame[unit].portrait2d = self.frame[unit]:CreateTexture(nil, "OVERLAY")
			self.frame[unit].portrait2d:SetAllPoints()
			local n = 9 / 64
			self.frame[unit].portrait2d:SetTexCoord(n, 1 - n, n, 1 - n)
		end
		if false then -- and not UnitIsVisible(unit) or not UnitIsConnected(unit) then
			self.frame[unit].portrait2d:Hide()
		else
			SetPortraitTexture(self.frame[unit].portrait2d, unit)
			self.frame[unit].portrait2d:Show()
			if self.frame[unit].portrait3d then
				self.frame[unit].portrait3d:Hide()
			end
			self.frame[unit].texture:SetTexture(0, 0, 0, 1)
			return
		end
	elseif self.db[unit].classIconMode == "PORTRAIT3D" then
		-- portrait3d
		local zoom = 1.0
		if not self.frame[unit].portrait3d then
			self.frame[unit].portrait3d = CreateFrame("PlayerModel", nil, self.frame[unit])
			self.frame[unit].portrait3d:SetAllPoints()
			self.frame[unit].portrait3d:SetScript("OnShow", function(f) f:SetPortraitZoom(zoom) end)
			self.frame[unit].portrait3d:SetScript("OnHide", function(f) f.guid = nil end)
		end
		if not UnitIsVisible(unit) or not UnitIsConnected(unit) then
			self.frame[unit].portrait3d:Hide()
		else
			local guid = UnitGUID(unit)
			if self.frame[unit].portrait3d.guid ~= guid then
				self.frame[unit].portrait3d.guid = guid
				self.frame[unit].portrait3d:SetUnit(unit)
				self.frame[unit].portrait3d:SetPortraitZoom(zoom)
				self.frame[unit].portrait3d:SetPosition(0, 0, 0)
			end
			self.frame[unit].portrait3d:Show()
			self.frame[unit].texture:SetTexture(0, 0, 0, 1)
			if self.frame[unit].portrait2d then
				self.frame[unit].portrait2d:Hide()
			end
			return
		end
	end

	-- get unit class
	local class, specID
	if not GladiusEx:IsTesting(unit) then
		class = select(2, UnitClass(unit))
		specID = GladiusEx.buttons[unit].specID
		-- check for arena prep info
		if not class then
			if GladiusEx.buttons[unit].class then
				class = GladiusEx.buttons[unit].class
			end
		end
	else
		class = GladiusEx.testing[unit].unitClass
		specID = GladiusEx.testing[unit].specID
	end

	local texture
	local left, right, top, bottom
	local needs_crop

	if not class then
		texture = [[Interface\Icons\INV_Misc_QuestionMark]]
		left, right, top, bottom = 0, 1, 0, 1
		needs_crop = true
	elseif self.db[unit].classIconMode == "ROLE" and specID then
		local _, _, _, _, _, role = GetSpecializationInfoByID(specID)
		texture = [[Interface\LFGFrame\UI-LFG-ICON-ROLES]]
		left, right, top, bottom = GetTexCoordsForRole(role)
		needs_crop = false
	elseif self.db[unit].classIconMode == "SPEC" and specID then
		texture = select(4, GetSpecializationInfoByID(specID))
		left, right, top, bottom = 0, 1, 0, 1
		needs_crop = true
	else
		texture = [[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]]
		left, right, top, bottom = unpack(CLASS_ICON_TCOORDS[class])
		needs_crop = true
	end

	self:SetTexture(unit, texture, needs_crop, left, right, top, bottom)
end

function ClassIcon:CreateFrame(unit)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	-- create frame
	self.frame[unit] = CreateFrame("CheckButton", "GladiusEx" .. self:GetName() .. "Frame" .. unit, button, "ActionButtonTemplate")
	self.frame[unit]:EnableMouse(false)
	self.frame[unit].texture = _G[self.frame[unit]:GetName().."Icon"]
	self.frame[unit].normalTexture = _G[self.frame[unit]:GetName().."NormalTexture"]
	self.frame[unit].cooldown = _G[self.frame[unit]:GetName().."Cooldown"]
	self.frame[unit].texture_border = self.frame[unit]:CreateTexture(nil, "BACKGROUND", nil, -1)
	self.frame[unit].texture_border:SetTexture([[Interface\AddOns\GladiusEx\media\icon_border]])
	self.frame[unit].texture_border:SetAllPoints()
end

function ClassIcon:Update(unit)
	-- create frame
	if not self.frame[unit] then
		self:CreateFrame(unit)
	end

	-- style action button
	self.frame[unit].normalTexture:SetHeight(self.frame[unit]:GetHeight() + self.frame[unit]:GetHeight() * 0.4)
	self.frame[unit].normalTexture:SetWidth(self.frame[unit]:GetWidth() + self.frame[unit]:GetWidth() * 0.4)

	self.frame[unit].normalTexture:ClearAllPoints()
	self.frame[unit].normalTexture:SetPoint("CENTER")
	self.frame[unit]:SetNormalTexture([[Interface\AddOns\GladiusEx\media\gloss]])

	self.frame[unit].texture:ClearAllPoints()
	self.frame[unit].texture:SetPoint("TOPLEFT", self.frame[unit], "TOPLEFT")
	self.frame[unit].texture:SetPoint("BOTTOMRIGHT", self.frame[unit], "BOTTOMRIGHT")

	self.frame[unit].normalTexture:SetVertexColor(self.db[unit].classIconGlossColor.r, self.db[unit].classIconGlossColor.g,
		self.db[unit].classIconGlossColor.b, self.db[unit].classIconGloss and self.db[unit].classIconGlossColor.a or 0)

	self.frame[unit].cooldown:SetReverse(self.db[unit].classIconCooldownReverse)

	-- hide
	self.frame[unit]:Hide()
end

function ClassIcon:Refresh(unit)
	self:SetClassIcon(unit)
	self:UpdateAura(unit)
end

function ClassIcon:Show(unit)
	-- show frame
	self.frame[unit]:Show()

	-- set class icon
	self:SetClassIcon(unit)
	self:UpdateAura(unit)
end

function ClassIcon:Reset(unit)
	if not self.frame[unit] then return end

	-- hide
	self.frame[unit]:Hide()
end

function ClassIcon:Test(unit)
end

function ClassIcon:GetImportantAura(unit, name)
	return self.db[unit].classIconAuras[name]
end

local function HasAuraEditBox()
	return not not LibStub("AceGUI-3.0").WidgetVersions["Aura_EditBox"]
end

function ClassIcon:GetOptions(unit)
	local options
	options = {
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
						classIconMode = {
							type = "select",
							name = L["Show"],
							values = {
								["CLASS"] = L["Class"],
								["SPEC"] = L["Spec"],
								["ROLE"] = L["Role"],
								["PORTRAIT2D"] = L["Portrait 2D"],
								["PORTRAIT3D"] = L["Portrait 3D"],
							},
							desc = L["When available, show specialization instead of class icons"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 3,
						},
						sep = {
							type = "description",
							name = "",
							width = "full",
							order = 4,
						},
						classIconImportantAuras = {
							type = "toggle",
							name = L["Important auras"],
							desc = L["Show important auras instead of the class icon"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 5,
						},
						classIconCrop = {
							type = "toggle",
							name = L["Crop borders"],
							desc = L["Toggle if the icon borders should be cropped or not"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 6,
						},
						sep2 = {
							type = "description",
							name = "",
							width = "full",
							order = 7,
						},
						classIconCooldown = {
							type = "toggle",
							name = L["Cooldown spiral"],
							desc = L["Display the cooldown spiral for the important auras"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 10,
						},
						classIconCooldownReverse = {
							type = "toggle",
							name = L["Cooldown reverse"],
							desc = L["Invert the dark/bright part of the cooldown spiral"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 15,
						},
						sep3 = {
							type = "description",
							name = "",
							width = "full",
							order = 17,
						},
						classIconGloss = {
							type = "toggle",
							name = L["Gloss"],
							desc = L["Toggle gloss on the icon"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 20,
						},
						classIconGlossColor = {
							type = "color",
							name = L["Gloss color"],
							desc = L["Color of the gloss"],
							get = function(info) return GladiusEx:GetColorOption(self.db[unit], info) end,
							set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db[unit], info, r, g, b, a) end,
							hasAlpha = true,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 25,
						},
					},
				},
				position = {
					type = "group",
					name = L["Position"],
					desc = L["Position settings"],
					inline = true,
					order = 3,
					args = {
						classIconPosition = {
							type = "select",
							name = L["Position"],
							desc = L["Position of the frame"],
							values = { ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"] },
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 1,
						},
					},
				},
			},
		},
		auraList = {
			type = "group",
			name = L["Important auras"],
			childGroups = "tree",
			order = 3,
			args = {
				newAura = {
					type = "group",
					name = L["New aura"],
					desc = L["New aura"],
					inline = true,
					order = 1,
					args = {
						name = {
							type = "input",
							dialogControl = HasAuraEditBox() and "Aura_EditBox" or nil,
							name = L["Name"],
							desc = L["Name of the aura"],
							get = function() return self.newAuraName and tostring(self.newAuraName) or "" end,
							set = function(info, value)
								if tonumber(value) and GetSpellInfo(value) then
									value = tonumber(value)
								end
								self.newAuraName = value
							end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 1,
						},
						priority = {
							type= "range",
							name = L["Priority"],
							desc = L["Select what priority the aura should have - higher equals more priority"],
							get = function() return self.newAuraPriority or "" end,
							set = function(info, value) self.newAuraPriority = value end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							min = 0,
							max = 10,
							step = 1,
							order = 2,
						},
						add = {
							type = "execute",
							name = L["Add new aura"],
							func = function(info)
								self.db[unit].classIconAuras[self.newAuraName] = self.newAuraPriority
								options.auraList.args[tostring(self.newAuraName)] = self:SetupAuraOptions(options, unit, self.newAuraName)
								self.newAuraName = nil
								GladiusEx:UpdateFrames()
							end,
							disabled = function() return not self:IsUnitEnabled(unit) or not (self.newAuraName and self.newAuraPriority) end,
							order = 3,
						},
					},
				},
			},
		},
	}

	-- set some initial value for the auras priority
	self.newAuraPriority = 5

	-- setup auras
	for aura, priority in pairs(self.db[unit].classIconAuras) do
		options.auraList.args[tostring(aura)] = self:SetupAuraOptions(options, unit, aura)
	end

	return options
end

function ClassIcon:SetupAuraOptions(options, unit, aura)
	local function setAura(info, value)
		if (info[#(info)] == "name") then
			local new_name = value
			if tonumber(new_name) and GetSpellInfo(new_name) then
				new_name = tonumber(new_name)
			end

			-- create new aura
			self.db[unit].classIconAuras[new_name] = self.db[unit].classIconAuras[aura]
			options.auraList.args[new_name] = self:SetupAuraOptions(options, unit, new_name)

			-- delete old aura
			self.db[unit].classIconAuras[aura] = nil
			options.auraList.args[aura] = nil
		else
			self.db[unit].classIconAuras[info[#(info) - 1]] = value
		end

		GladiusEx:UpdateFrames()
	end

	local function getAura(info)
		if (info[#(info)] == "name") then
			return tostring(aura)
		else
			return self.db[unit].classIconAuras[aura]
		end
	end

	local name = aura
	if type(aura) == "number" then
		name = string.format("%s [%s]", GladiusEx:SafeGetSpellName(aura), aura)
	end

	return {
		type = "group",
		name = name,
		desc = name,
		get = getAura,
		set = setAura,
		disabled = function() return not self:IsUnitEnabled(unit) end,
		args = {
			name = {
				type = "input",
				dialogControl = HasAuraEditBox() and "Aura_EditBox" or nil,
				name = L["Name"],
				desc = L["Name of the aura"],
				disabled = function() return not self:IsUnitEnabled(unit) end,
				order = 1,
			},
			priority = {
				type= "range",
				name = L["Priority"],
				desc = L["Select what priority the aura should have - higher equals more priority"],
				min = 0, softMax = 10, step = 1,
				order = 2,
			},
			delete = {
				type = "execute",
				name = L["Delete"],
				func = function(info)
					local aura = info[#(info) - 1]
					self.db[unit].classIconAuras[aura] = nil
					options.auraList.args[aura] = nil
					GladiusEx:UpdateFrames()
				end,
				disabled = function() return not self:IsUnitEnabled(unit) end,
				order = 3,
			},
		},
	}
end
