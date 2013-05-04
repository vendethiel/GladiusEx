local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM

-- global functions
local strfind = string.find
local pairs = pairs
local GetTime = GetTime
local GetSpellInfo, UnitAura, UnitClass, UnitBuff, UnitDebuff = GetSpellInfo, UnitAura, UnitClass, UnitBuff, UnitDebuff
local CLASS_BUTTONS = CLASS_BUTTONS

local ClassIcon = GladiusEx:NewGladiusExModule("ClassIcon", false, {
	classIconAttachTo = "Frame",
	classIconAnchor = "TOPRIGHT",
	classIconRelativePoint = "TOPLEFT",
	classIconMode = "SPEC",
	classIconAdjustSize = false,
	classIconSize = 40,
	classIconOffsetX = -1,
	classIconOffsetY = 0,
	classIconFrameLevel = 2,
	classIconGloss = true,
	classIconGlossColor = { r = 1, g = 1, b = 1, a = 0.4 },
	classIconImportantAuras = true,
	classIconCrop = false,
	classIconCooldown = true,
	classIconCooldownReverse = false,

	-- NOTE: this list can be modified from the ClassIcon module options, no need to edit it here
	-- Nonetheless, if you think that we missed an important aura, please post it on the addon site at curse or wowace
	classIconAuras = {
		-- Spell Name			Priority (higher = more priority)
		-- Crowd control
		[GetSpellInfo(108194)] 	= 4,    -- Asphyxiate
		[GetSpellInfo(115001)] 	= 4,    -- Remorseless Winter
		[GetSpellInfo(91800)] 	= 4,    -- Gnaw
		[GetSpellInfo(91797)] 	= 4,    -- Monstrous Blow (Dark Transformation)
		[GetSpellInfo(113801)] 	= 4,    -- Bash (Force of Nature - Feral Treants)
		[GetSpellInfo(102795)] 	= 4,    -- Bear Hug
		[GetSpellInfo(33786)] 	= 4,    -- Cyclone
		[GetSpellInfo(99)] 		= 4,    -- Disorienting Roar
		[GetSpellInfo(2637)] 	= 4,    -- Hibernate
		[GetSpellInfo(22570)] 	= 4,    -- Maim
		[GetSpellInfo(5211)] 	= 4,    -- Mighty Bash
		[GetSpellInfo(9005)] 	= 4,    -- Pounce
		[GetSpellInfo(102546)] 	= 4,    -- Pounce (Incarnation)
		[GetSpellInfo(110698)] 	= 4,    -- Hammer of Justice (Paladin)
		[GetSpellInfo(113004)] 	= 4,    -- Intimidating Roar [Fleeing in fear] (Warrior)
		[GetSpellInfo(113056)] 	= 4,    -- Intimidating Roar [Cowering in fear] (Warrior)
		[GetSpellInfo(117526)] 	= 4,    -- Binding Shot
		[GetSpellInfo(3355)] 	= 4,    -- Freezing Trap
		[GetSpellInfo(1513)] 	= 4,    -- Scare Beast
		[GetSpellInfo(19503)] 	= 4,    -- Scatter Shot
		[GetSpellInfo(19386)] 	= 4,    -- Wyvern Sting
		[GetSpellInfo(90337)] 	= 4,    -- Bad Manner (Monkey)
		[GetSpellInfo(24394)] 	= 4,    -- Intimidation
		[GetSpellInfo(126246)] 	= 4,    -- Lullaby (Crane)
		[GetSpellInfo(126355)] 	= 4,    -- Paralyzing Quill (Porcupine)
		[GetSpellInfo(126423)] 	= 4,    -- Petrifying Gaze (Basilisk)
		[GetSpellInfo(50519)] 	= 4,    -- Sonic Blast (Bat)
		[GetSpellInfo(56626)] 	= 4,    -- Sting (Wasp)
		[GetSpellInfo(96201)] 	= 4,    -- Web Wrap (Shale Spider)
		[GetSpellInfo(118271)] 	= 4,    -- Combustion Impact
		[GetSpellInfo(44572)] 	= 4,    -- Deep Freeze
		[GetSpellInfo(31661)] 	= 4,    -- Dragon's Breath
		[GetSpellInfo(118)] 	= 4,    -- Polymorph
		[GetSpellInfo(61305)] 	= 4,    -- Polymorph: Black Cat
		[GetSpellInfo(28272)] 	= 4,    -- Polymorph: Pig
		[GetSpellInfo(61721)] 	= 4,    -- Polymorph: Rabbit
		[GetSpellInfo(61780)] 	= 4,    -- Polymorph: Turkey
		[GetSpellInfo(28271)] 	= 4,    -- Polymorph: Turtle
		[GetSpellInfo(82691)] 	= 4,    -- Ring of Frost
		[GetSpellInfo(123393)] 	= 4,    -- Breath of Fire (Glyph of Breath of Fire)
		[GetSpellInfo(126451)] 	= 4,    -- Clash
		[GetSpellInfo(122242)] 	= 4,    -- Clash (not sure which one is right)
		[GetSpellInfo(119392)] 	= 4,    -- Charging Ox Wave
		[GetSpellInfo(120086)] 	= 4,    -- Fists of Fury
		[GetSpellInfo(119381)] 	= 4,    -- Leg Sweep
		[GetSpellInfo(115078)] 	= 4,    -- Paralysis
		[GetSpellInfo(105421)] 	= 4,    -- Blinding Light
		[GetSpellInfo(115752)] 	= 4,    -- Blinding Light (Glyph of Blinding Light)
		[GetSpellInfo(105593)] 	= 4,    -- Fist of Justice
		[GetSpellInfo(853)] 	= 4,    -- Hammer of Justice
		[GetSpellInfo(119072)] 	= 4,    -- Holy Wrath
		[GetSpellInfo(20066)] 	= 4,    -- Repentance
		[GetSpellInfo(10326)] 	= 4,    -- Turn Evil
		[GetSpellInfo(113506)] 	= 4,    -- Cyclone (Symbiosis)
		[GetSpellInfo(605)] 	= 4,    -- Dominate Mind
		[GetSpellInfo(88625)] 	= 4,    -- Holy Word: Chastise
		[GetSpellInfo(64044)] 	= 4,    -- Psychic Horror
		[GetSpellInfo(8122)] 	= 4,    -- Psychic Scream
		[GetSpellInfo(113792)] 	= 4,    -- Psychic Terror (Psyfiend)
		[GetSpellInfo(9484)] 	= 4,    -- Shackle Undead
		[GetSpellInfo(87204)] 	= 4,    -- Sin and Punishment
		[GetSpellInfo(2094)] 	= 4,    -- Blind
		[GetSpellInfo(1833)] 	= 4,    -- Cheap Shot
		[GetSpellInfo(1776)] 	= 4,    -- Gouge
		[GetSpellInfo(408)] 	= 4,    -- Kidney Shot
		[GetSpellInfo(113953)] 	= 4,    -- Paralysis (Paralytic Poison)
		[GetSpellInfo(6770)] 	= 4,    -- Sap
		[GetSpellInfo(76780)] 	= 4,    -- Bind Elemental
		[GetSpellInfo(77505)] 	= 4,    -- Earthquake
		[GetSpellInfo(51514)] 	= 4,    -- Hex
		[GetSpellInfo(118905)] 	= 4,    -- Static Charge (Capacitor Totem)
		[GetSpellInfo(710)] 	= 4,    -- Banish
		[GetSpellInfo(137143)] 	= 4,    -- Blood Horror
		[GetSpellInfo(54786)] 	= 4,    -- Demonic Leap (Metamorphosis)
		[GetSpellInfo(5782)] 	= 4,    -- Fear
		[GetSpellInfo(118699)] 	= 4,    -- Fear
		[GetSpellInfo(130616)] 	= 4,    -- Fear (Glyph of Fear)
		[GetSpellInfo(5484)] 	= 4,    -- Howl of Terror
		[GetSpellInfo(22703)] 	= 4,    -- Infernal Awakening
		[GetSpellInfo(6789)] 	= 4,    -- Mortal Coil
		[GetSpellInfo(132412)] 	= 4,    -- Seduction (Grimoire of Sacrifice)
		[GetSpellInfo(30283)] 	= 4,    -- Shadowfury
		[GetSpellInfo(104045)] 	= 4,    -- Sleep (Metamorphosis)
		[GetSpellInfo(7922)] 	= 4,    -- Charge Stun
		[GetSpellInfo(118895)] 	= 4,    -- Dragon Roar
		[GetSpellInfo(5246)] 	= 4,    -- Intimidating Shout (aoe)
		[GetSpellInfo(20511)] 	= 4,    -- Intimidating Shout (targeted)
		[GetSpellInfo(132168)] 	= 4,    -- Shockwave
		[GetSpellInfo(107570)] 	= 4,    -- Storm Bolt
		[GetSpellInfo(105771)] 	= 4,    -- Warbringer
		[GetSpellInfo(107079)] 	= 4,    -- Quaking Palm
		[GetSpellInfo(20549)] 	= 4,    -- War Stomp
		[GetSpellInfo(118345)] 	= 4,    -- Pulverize
		[GetSpellInfo(89766)] 	= 4,    -- Axe Toss (Felguard/Wrathguard)
		[GetSpellInfo(115268)] 	= 4,    -- Mesmerize (Shivarra)
		[GetSpellInfo(6358)] 	= 4,    -- Seduction (Succubus)

		-- Roots
		[GetSpellInfo(96294)] 	= 2,    -- Chains of Ice (Chilblains)
		[GetSpellInfo(91807)] 	= 2,    -- Shambling Rush (Dark Transformation)
		[GetSpellInfo(339)] 	= 2,    -- Entangling Roots
		[GetSpellInfo(113770)] 	= 2,    -- Entangling Roots (Force of Nature - Balance Treants)
		[GetSpellInfo(19975)] 	= 2,    -- Entangling Roots (Nature's Grasp)
		[GetSpellInfo(45334)] 	= 2,    -- Immobilized (Wild Charge - Bear)
		[GetSpellInfo(102359)] 	= 2,    -- Mass Entanglement
		[GetSpellInfo(110693)] 	= 2,    -- Frost Nova (Mage)
		[GetSpellInfo(19185)] 	= 2,    -- Entrapment
		[GetSpellInfo(128405)] 	= 2,    -- Narrow Escape
		[GetSpellInfo(90327)] 	= 2,    -- Lock Jaw (Dog)
		[GetSpellInfo(50245)] 	= 2,    -- Pin (Crab)
		[GetSpellInfo(54706)] 	= 2,    -- Venom Web Spray (Silithid)
		[GetSpellInfo(4167)] 	= 2,    -- Web (Spider)
		[GetSpellInfo(122)] 	= 2,    -- Frost Nova
		[GetSpellInfo(111340)] 	= 2,    -- Ice Ward
		[GetSpellInfo(33395)] 	= 2,    -- Freeze
		[GetSpellInfo(116706)] 	= 2,    -- Disable
		[GetSpellInfo(113275)] 	= 2,    -- Entangling Roots (Symbiosis)
		[GetSpellInfo(123407)] 	= 2,    -- Spinning Fire Blossom
		[GetSpellInfo(113275)] 	= 2,    -- Entangling Roots (Symbiosis)
		[GetSpellInfo(87194)] 	= 2,    -- Glyph of Mind Blast
		[GetSpellInfo(114404)] 	= 2,    -- Void Tendril's Grasp
		[GetSpellInfo(115197)] 	= 2,    -- Partial Paralysis
		[GetSpellInfo(64695)] 	= 2,    -- Earthgrab (Earthgrab Totem)
		[GetSpellInfo(63685)] 	= 2,    -- Freeze (Frozen Power)
		[GetSpellInfo(107566)] 	= 2,    -- Staggering Shout

		-- Silences
		[GetSpellInfo(47476)] 	= 3,    -- Strangulate
		[GetSpellInfo(114238)] 	= 3,    -- Fae Silence (Glyph of Fae Silence)
		[GetSpellInfo(81261)] 	= 3,    -- Solar Beam
		[GetSpellInfo(34490)] 	= 3,    -- Silencing Shot
		[GetSpellInfo(102051)] 	= 3,    -- Frostjaw (also a root)
		[GetSpellInfo(55021)] 	= 3,    -- Silenced - Improved Counterspell
		[GetSpellInfo(116709)] 	= 3,    -- Spear Hand Strike
		[GetSpellInfo(31935)] 	= 3,    -- Avenger's Shield
		[GetSpellInfo(15487)] 	= 3,    -- Silence
		[GetSpellInfo(1330)] 	= 3,    -- Garrote - Silence
		[GetSpellInfo(113287)] 	= 3,    -- Solar Beam (Symbiosis)
		[GetSpellInfo(132409)] 	= 3,    -- Spell Lock (Grimoire of Sacrifice)
		[GetSpellInfo(31117)] 	= 3,    -- Unstable Affliction
		[GetSpellInfo(115782)] 	= 3,    -- Optical Blast (Observer)
		[GetSpellInfo(24259)] 	= 3,    -- Spell Lock (Felhunter
		[GetSpellInfo(25046)] 	= 3,    -- Arcane Torrent (Energy)
		[GetSpellInfo(28730)] 	= 3,    -- Arcane Torrent (Mana)
		[GetSpellInfo(50613)] 	= 3,    -- Arcane Torrent (Runic Power)
		[GetSpellInfo(69179)] 	= 3,    -- Arcane Torrent (Rage)
		[GetSpellInfo(80483)] 	= 3,    -- Arcane Torrent (Focus)
		[GetSpellInfo(129597)] 	= 3,    -- Arcane Torrent (Chi)

		-- Disarms
		[GetSpellInfo(126458)] 	= 1,    -- Grapple Weapon (Monk)
		[GetSpellInfo(50541)] 	= 1,    -- Clench (Scorpid)
		[GetSpellInfo(91644)] 	= 1,    -- Snatch (Bird of Prey)
		[GetSpellInfo(117368)] 	= 1,    -- Grapple Weapon
		[GetSpellInfo(64058)] 	= 1,    -- Psychic Horror
		[GetSpellInfo(51722)] 	= 1,    -- Dismantle
		[GetSpellInfo(118093)] 	= 1,    -- Disarm (Voidwalker/Voidlord)
		[GetSpellInfo(676)] 	= 1,    -- Disarm

		-- Buffs
		[GetSpellInfo(48792)] 	= 1,    -- Icebound Fortitude
		[GetSpellInfo(49039)] 	= 1,    -- Lichborne
		[GetSpellInfo(110575)] 	= 1,    -- Icebound Fortitude (Death Knight)
		[GetSpellInfo(122291)] 	= 1,    -- Unending Resolve (Warlock)
		[GetSpellInfo(31821)] 	= 1,    -- Aura Mastery
		[GetSpellInfo(113002)] 	= 1,    -- Spell Reflection (Warrior)
		[GetSpellInfo(8178)] 	= 1,    -- Grounding Totem Effect (Grounding Totem)
		[GetSpellInfo(104773)] 	= 1,    -- Unending Resolve
		[GetSpellInfo(23920)] 	= 1,    -- Spell Reflection
		[GetSpellInfo(114028)] 	= 1,    -- Mass Spell Reflection
		[GetSpellInfo(131557)] 	= 1,    -- Spiritwalker's Aegis
		[GetSpellInfo(89485)] 	= 1,    -- Inner Focus
		[GetSpellInfo(6940)] 	= 1,    -- Hand of Sacrifice
		[GetSpellInfo(110913)] 	= 1,    -- Dark Bargain

		-- Immunities
		[GetSpellInfo(115018)] 	= 1,    -- Desecrated Ground
		[GetSpellInfo(48707)] 	= 1,    -- Anti-Magic Shell
		[GetSpellInfo(110617)] 	= 1,    -- Deterrence (Hunter)
		[GetSpellInfo(110715)] 	= 1,    -- Dispersion (Priest)
		[GetSpellInfo(110700)] 	= 1,    -- Divine Shield (Paladin)
		[GetSpellInfo(110696)] 	= 1,    -- Ice Block (Mage)
		[GetSpellInfo(110570)] 	= 1,    -- Anti-Magic Shell (Death Knight)
		[GetSpellInfo(110788)] 	= 1,    -- Cloak of Shadows (Rogue)
		[GetSpellInfo(19263)] 	= 1,    -- Deterrence
		[GetSpellInfo(45438)] 	= 1,    -- Ice Block
		[GetSpellInfo(115760)] 	= 1,    -- Glyph of Ice Block
		[GetSpellInfo(131523)] 	= 1,    -- Zen Meditation
		[GetSpellInfo(642)] 	= 1,    -- Divine Shield
		[GetSpellInfo(47585)] 	= 1,    -- Dispersion
		[GetSpellInfo(31224)] 	= 1,    -- Cloak of Shadows
		[GetSpellInfo(46924)] 	= 1,    -- Bladestorm
	}
})

function ClassIcon:OnEnable()
	self:RegisterEvent("UNIT_AURA")
	self:RegisterMessage("GLADIUS_SPEC_UPDATE")

	LSM = GladiusEx.LSM

	if not self.frame then
		self.frame = {}
	end
end

function ClassIcon:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()

	for unit in pairs(self.frame) do
		self.frame[unit]:SetAlpha(0)
	end
end

function ClassIcon:GetAttachTo(unit)
	return self.db[unit].classIconAttachTo
end

function ClassIcon:GetModuleAttachPoints()
	return {
		["ClassIcon"] = L["ClassIcon"],
	}
end

function ClassIcon:GetAttachFrame(unit)
	if not self.frame[unit] then
		self:CreateFrame(unit)
	end

	return self.frame[unit]
end

function ClassIcon:UNIT_AURA(event, unit)
	if not GladiusEx:IsHandledUnit(unit) then return end

	-- important auras
	self:UpdateAura(unit)
end

function ClassIcon:GLADIUS_SPEC_UPDATE(event, unit)
	self:UpdateAura(unit)
end

function ClassIcon:ScanAuras(unit)
	local best_priority = 0
	local best_name, best_icon, best_duration, best_expires

	local function handle_aura(name, icon, duration, expires)
		local prio = self:GetImportantAura(unit, name)
		if prio and prio >= best_priority then
			best_name = name
			best_icon = icon
			best_duration = duration
			best_expires = expires
			best_priority = prio
		end
	end

	-- debuffs
	for index = 1, 40 do
		local name, _, icon, _, _, duration, expires, _, _ = UnitDebuff(unit, index)
		if (not name) then break end
		handle_aura(name, icon, duration, expires)
	end

	-- buffs
	for index = 1, 40 do
		local name, _, icon, _, _, duration, expires, _, _ = UnitBuff(unit, index)
		if (not name) then break end
		handle_aura(name, icon, duration, expires)
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
	self.frame[unit].texture:SetTexture(icon)

	if self.db[unit].classIconCrop then
		self.frame[unit].texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	else
		self.frame[unit].texture:SetTexCoord(0, 1, 0, 1)
	end

	if self.db[unit].classIconCooldown then
		self.frame[unit].cooldown:SetCooldown(expires - duration, duration)
		self.frame[unit].cooldown:Show()
	end
end

function ClassIcon:SetClassIcon(unit)
	if (not self.frame[unit]) then return end

	-- get unit class
	local class, specID
	if not GladiusEx:IsTesting(unit) then
		class = select(2, UnitClass(unit))
		-- check for arena prep info
		if not class then
			class = GladiusEx.buttons[unit].class
		end
		specID = GladiusEx.buttons[unit].specID
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
		texture =[[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]]
		left, right, top, bottom = unpack(CLASS_BUTTONS[class])
		needs_crop = true
	end

	-- crop class icon borders
	if self.db[unit].classIconCrop and needs_crop then
		left = left + (right - left) * 0.07
		right = right - (right - left) * 0.07
		top = top + (bottom - top) * 0.07
		bottom = bottom - (bottom - top) * 0.07
	end

	-- set texture
	self.frame[unit].texture:SetTexture(texture)
	self.frame[unit].texture:SetTexCoord(left, right, top, bottom)

	-- hide cooldown frame
	self.frame[unit].cooldown:Hide()
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
end

function ClassIcon:Update(unit)
	-- create frame
	if (not self.frame[unit]) then
		self:CreateFrame(unit)
	end

	-- update frame
	self.frame[unit]:ClearAllPoints()

	local parent = GladiusEx:GetAttachFrame(unit, self.db[unit].classIconAttachTo)
	self.frame[unit]:SetPoint(self.db[unit].classIconAnchor, parent, self.db[unit].classIconRelativePoint, self.db[unit].classIconOffsetX, self.db[unit].classIconOffsetY)

	-- frame level
	self.frame[unit]:SetFrameLevel(self.db[unit].classIconFrameLevel)

	-- size
	if self.db[unit].classIconAdjustSize then
		self.frame[unit]:SetWidth(GladiusEx.buttons[unit].frameHeight)
		self.frame[unit]:SetHeight(GladiusEx.buttons[unit].frameHeight)
	else
		self.frame[unit]:SetWidth(self.db[unit].classIconSize)
		self.frame[unit]:SetHeight(self.db[unit].classIconSize)
	end

	-- set frame mouse-interactable area
	if self:GetAttachTo(unit) == "Frame" then
		local left, right, top, bottom = GladiusEx.buttons[unit]:GetHitRectInsets()

		if strfind(self.db[unit].classIconRelativePoint, "LEFT") then
			left = -self.frame[unit]:GetWidth() + self.db[unit].classIconOffsetX
		else
			right = -self.frame[unit]:GetWidth() + -self.db[unit].classIconOffsetX
		end

		-- top / bottom
		if self.frame[unit]:GetHeight() > GladiusEx.buttons[unit]:GetHeight() then
			bottom = -(self.frame[unit]:GetHeight() - GladiusEx.buttons[unit]:GetHeight()) + self.db[unit].classIconOffsetY
		end

		GladiusEx.buttons[unit]:SetHitRectInsets(left, right, top, bottom)
		GladiusEx.buttons[unit].secure:SetHitRectInsets(left, right, top, bottom)
	end

	-- style action button
	self.frame[unit].normalTexture:SetHeight(self.frame[unit]:GetHeight() + self.frame[unit]:GetHeight() * 0.4)
	self.frame[unit].normalTexture:SetWidth(self.frame[unit]:GetWidth() + self.frame[unit]:GetWidth() * 0.4)

	self.frame[unit].normalTexture:ClearAllPoints()
	self.frame[unit].normalTexture:SetPoint("CENTER")
	self.frame[unit]:SetNormalTexture([[Interface\AddOns\GladiusEx\images\gloss]])

	self.frame[unit].texture:ClearAllPoints()
	self.frame[unit].texture:SetPoint("TOPLEFT", self.frame[unit], "TOPLEFT")
	self.frame[unit].texture:SetPoint("BOTTOMRIGHT", self.frame[unit], "BOTTOMRIGHT")

	self.frame[unit].normalTexture:SetVertexColor(self.db[unit].classIconGlossColor.r, self.db[unit].classIconGlossColor.g,
		self.db[unit].classIconGlossColor.b, self.db[unit].classIconGloss and self.db[unit].classIconGlossColor.a or 0)

	self.frame[unit].cooldown:SetReverse(self.db[unit].classIconCooldownReverse)

	-- hide
	self.frame[unit]:SetAlpha(0)
end

function ClassIcon:Show(unit)
	-- show frame
	self.frame[unit]:SetAlpha(1)

	-- set class icon
	self:SetClassIcon(unit)
	self:UpdateAura(unit)
end

function ClassIcon:Reset(unit)
	if not self.frame[unit] then return end

	-- hide
	self.frame[unit]:SetAlpha(0)
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
							values = { ["CLASS"] = L["Class"], ["SPEC"] = L["Spec"], ["ROLE"] = L["Role"] },
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
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 6,
						},
						classIconCooldown = {
							type = "toggle",
							name = L["Cooldown spiral"],
							desc = L["Display the cooldown spiral for the important auras"],
							width = "full",
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 10,
						},
						classIconCooldownReverse = {
							type = "toggle",
							name = L["Cooldown reverse"],
							desc = L["Invert the dark/bright part of the cooldown spiral"],
							width = "full",
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 15,
						},
						sep2 = {
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
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
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
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 25,
						},
						sep3 = {
							type = "description",
							name = "",
							width = "full",
							order = 27,
						},
						classIconFrameLevel = {
							type = "range",
							name = L["Frame level"],
							desc = L["Frame level of the frame"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							min = 1, max = 5, step = 1,
							width = "double",
							order = 30,
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
						classIconAdjustSize = {
							type = "toggle",
							name = L["Adjust size"],
							desc = L["Adjust size to the frame size"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 5,
						},
						classIconSize = {
							type = "range",
							name = L["Icon size"],
							desc = L["Size of the icon"],
							min = 10, max = 100, step = 1,
							disabled = function() return self.db[unit].classIconAdjustSize or not self:IsUnitEnabled(unit) end,
							order = 10,
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
						classIconAttachTo = {
							type = "select",
							name = L["Attach to"],
							desc = L["Attach to the given frame"],
							values = function() return self:GetOtherAttachPoints(unit) end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							width = "double",
							order = 5,
						},
						classIconPosition = {
							type = "select",
							name = L["Position"],
							desc = L["Position of the frame"],
							values = { ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"] },
							get = function() return strfind(self.db[unit].classIconAnchor, "RIGHT") and "LEFT" or "RIGHT" end,
							set = function(info, value)
								if value == "LEFT" then
									self.db[unit].classIconAnchor = "TOPRIGHT"
									self.db[unit].classIconRelativePoint = "TOPLEFT"
								else
									self.db[unit].classIconAnchor = "TOPLEFT"
									self.db[unit].classIconRelativePoint = "TOPRIGHT"
								end

								GladiusEx:UpdateFrames()
							end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return GladiusEx.db.base.advancedOptions end,
							order = 6,
						},
						sep = {
							type = "description",
							name = "",
							width = "full",
							order = 7,
						},
						classIconAnchor = {
							type = "select",
							name = L["Anchor"],
							desc = L["Anchor of the frame"],
							values = function() return GladiusEx:GetPositions() end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 10,
						},
						classIconRelativePoint = {
							type = "select",
							name = L["Relative point"],
							desc = L["Relative point of the frame"],
							values = function() return GladiusEx:GetPositions() end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 15,
						},
						sep2 = {
							type = "description",
							name = "",
							width = "full",
							order = 17,
						},
						classIconOffsetX = {
							type = "range",
							name = L["Offset X"],
							desc = L["X offset of the frame"],
							min = -100, max = 100, step = 1,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 20,
						},
						classIconOffsetY = {
							type = "range",
							name = L["Offset Y"],
							desc = L["Y offset of the frame"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							min = -50, max = 50, step = 1,
							order = 25,
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
							get = function() return self.newAuraName or "" end,
							set = function(info, value) self.newAuraName = value end,
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
								options.auraList.args[self.newAuraName] = self:SetupAuraOptions(self.newAuraName)
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
		options.auraList.args[aura] = self:SetupAuraOptions(options, unit, aura)
	end

	return options
end

function ClassIcon:SetupAuraOptions(options, unit, aura)
	local function setAura(info, value)
		if (info[#(info)] == "name") then
			local old_name = info[#(info) - 1]

			-- create new aura
			self.db[unit].classIconAuras[value] = self.db[unit].classIconAuras[old_name]
			options.auraList.args[value] = self:SetupAuraOptions(value)

			-- delete old aura
			self.db[unit].classIconAuras[old_name] = nil
			options.auraList.args[old_name] = nil
		else
			self.db[unit].classIconAuras[info[#(info) - 1]] = value
		end

		GladiusEx:UpdateFrames()
	end

	local function getAura(info)
		if (info[#(info)] == "name") then
			return info[#(info) - 1]
		else
			return self.db[unit].classIconAuras[info[#(info) - 1]]
		end
	end

	return {
		type = "group",
		name = aura,
		desc = aura,
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
				min = 0,
				max = 5,
				step = 1,
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
