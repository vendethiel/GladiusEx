local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM

-- global functions
local strfind = string.find
local pairs = pairs
local GetTime = GetTime
local GetSpellInfo, UnitAura, UnitClass = GetSpellInfo, UnitAura, UnitClass
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
	classIconCooldown = false,
	classIconCooldownReverse = false,

	-- NOTE: this list can be modified from the ClassIcon module options, no need to edit it here
	-- Nonetheless, if you think that we missed an important aura, please post it on the addon site at curse or wowace
	classIconAuras = {
		-- Spell NamePriority (higher = more priority)
		-- Crowd control
		[GetSpellInfo(33786)] = 3, -- Cyclone
		[GetSpellInfo(2637)] = 3, -- Hibernate
		[GetSpellInfo(55041)] = 3, -- Freezing Trap Effect
		[GetSpellInfo(3355)] = 3, -- Freezing Trap (from trap launcher)
		[GetSpellInfo(6770)] = 3, -- Sap
		[GetSpellInfo(2094)] = 3, -- Blind
		[GetSpellInfo(5782)] = 3, -- Fear
		[GetSpellInfo(6789)] = 3, -- Death Coil Warlock
		[GetSpellInfo(64044)] = 3, -- Psychic Horror
		[GetSpellInfo(6358)] = 3, -- Seduction
		[GetSpellInfo(5484)] = 3, -- Howl of Terror
		[GetSpellInfo(5246)] = 3, -- Intimidating Shout
		[GetSpellInfo(8122)] = 3, -- Psychic Scream
		[GetSpellInfo(118)]  = 3, -- Polymorph
		[GetSpellInfo(28272)] = 3, -- Polymorph pig
		[GetSpellInfo(28271)] = 3, -- Polymorph turtle
		[GetSpellInfo(61305)] = 3, -- Polymorph black cat
		[GetSpellInfo(61025)] = 3, -- Polymorph serpent
		[GetSpellInfo(51514)] = 3, -- Hex
		[GetSpellInfo(710)] = 3, -- Banish
		[GetSpellInfo(1499)] = 3, -- Freezing Trap Effect
		[GetSpellInfo(60192)] = 3, -- Freezing Trap (from trap launcher)

		-- Roots
		[GetSpellInfo(339)] = 3, -- Entangling Roots
		[GetSpellInfo(122)] = 3, -- Frost Nova
		[GetSpellInfo(16979)] = 3, -- Feral Charge
		[GetSpellInfo(13809)] = 1, -- Frost Trap
		[GetSpellInfo(113724)]  = 3, -- Ring of Frost
		[GetSpellInfo(120)]  = 1, -- Cone of Cold

		-- Stuns and incapacitates
		[GetSpellInfo(5211)] = 3, -- Bash
		[GetSpellInfo(1833)] = 3, -- Cheap Shot
		[GetSpellInfo(408)] = 3, -- Kidney Shot
		[GetSpellInfo(1776)] = 3, -- Gouge
		[GetSpellInfo(44572)] = 3, -- Deep Freeze
		[GetSpellInfo(19386)] = 3, -- Wyvern Sting
		[GetSpellInfo(126246)]  = 3,    -- Lullaby
		[GetSpellInfo(19503)] = 3, -- Scatter Shot
		[GetSpellInfo(9005)] = 3, -- Pounce
		[GetSpellInfo(22570)] = 3, -- Maim
		[GetSpellInfo(853)] = 3, -- Hammer of Justice
		[GetSpellInfo(20066)] = 3, -- Repentance
		[GetSpellInfo(46968)] = 3, -- Shockwave
		[GetSpellInfo(47481)] = 3, -- Gnaw (dk pet stun)
		[GetSpellInfo(90337)]  = 3, -- Bad Manner (monkey blind)
		[GetSpellInfo(118905)] = 3, -- Static Charge - Capacitor Totem

		-- Silences
		[GetSpellInfo(55021)] = 1, -- Improved Counterspell
		[GetSpellInfo(15487)] = 1, -- Silence
		[GetSpellInfo(34490)] = 1, -- Silencing Shot
		[GetSpellInfo(47476)] = 1, -- Strangulate
		[GetSpellInfo(96231)] = 1, -- Rebuke unsure
		[GetSpellInfo(80964)] = 1, -- Skull Bash
		[GetSpellInfo(703)]  = 1, -- Garrote

		-- Disarms
		[GetSpellInfo(676)] = 1, -- Disarm
		[GetSpellInfo(51722)] = 1, -- Dismantle

		-- Buffs
		[GetSpellInfo(1022)] = 1, -- Blessing of Protection
		[GetSpellInfo(1044)] = 1, -- Blessing of Freedom
		[GetSpellInfo(33206)] = 1, -- Pain Suppression
		[GetSpellInfo(29166)] = 1, -- Innervate
		[GetSpellInfo(54428)] = 1, -- Divine Plea
		[GetSpellInfo(31821)] = 1, -- Aura mastery
		[GetSpellInfo(118009)] = 1, -- Desecrated Ground (DK lvl90 anti-CC)
		[GetSpellInfo(12292)] = 1, -- Death Wish
		[GetSpellInfo(49016)] = 1, -- Unholy Frenzy

		-- Turtling abilities
		[GetSpellInfo(871)] = 1, -- Shield Wall
		[GetSpellInfo(48707)] = 1, -- Anti-Magic Shell
		[GetSpellInfo(31224)] = 1, -- Cloak of Shadows
		[GetSpellInfo(19263)] = 1, -- Deterrence
		[GetSpellInfo(76577)] = 1, -- Smoke Bomb
		[GetSpellInfo(74001)] = 1, -- Combat Readiness
		[GetSpellInfo(49039)] = 1, -- Lichborn
		[GetSpellInfo(47585)] = 1, -- Dispersion

		-- Immunities
		[GetSpellInfo(34692)] = 1, -- The Beast Within
		[GetSpellInfo(45438)] = 2, -- Ice Block
		[GetSpellInfo(642)] = 2, -- Divine Shield
	}	
})

function ClassIcon:OnEnable()
	self:RegisterEvent("UNIT_AURA")
	self:RegisterMessage("GLADIUS_SPEC_UPDATE")

	self.dbi.RegisterCallback(self, "OnProfileChanged", "SetupAllAurasOptions")
	self.dbi.RegisterCallback(self, "OnProfileCopied", "SetupAllAurasOptions")
	self.dbi.RegisterCallback(self, "OnProfileReset", "SetupAllAurasOptions")

	LSM = GladiusEx.LSM

	if (not self.frame) then
		self.frame = {}
	end
end

function ClassIcon:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()
	self.dbi.UnregisterAllCallbacks(self)

	for unit in pairs(self.frame) do
		self.frame[unit]:SetAlpha(0)
	end
end

function ClassIcon:GetAttachTo()
	return self.db.classIconAttachTo
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
	self:SetClassIcon(unit)
	self:UpdateAura(unit)
end

function ClassIcon:ScanAuras(unit)
	local best_priority = 0
	local best_name, best_icon, best_duration, best_expires

	local function handle_aura(name, icon, duration, expires)
		local prio = self:GetImportantAura(name)
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
	if (not self.frame[unit] or not self.db.classIconImportantAuras) then return end

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

	if (self.db.classIconCrop) then
		self.frame[unit].texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	else
		self.frame[unit].texture:SetTexCoord(0, 1, 0, 1)
	end

	self.frame[unit].cooldown:SetCooldown(expires - duration, duration)
	self.frame[unit].cooldown:Show()
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
		texture = "Interface\\Icons\\INV_Misc_QuestionMark"
		left, right, top, bottom = 0, 1, 0, 1
		needs_crop = true
	elseif self.db.classIconMode == "ROLE" and specID then
		local _, _, _, _, _, role = GetSpecializationInfoByID(specID)
		texture = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES"
		left, right, top, bottom = GetTexCoordsForRole(role)
		needs_crop = false
	elseif self.db.classIconMode == "SPEC" and specID then
		texture = select(4, GetSpecializationInfoByID(specID))
		left, right, top, bottom = 0, 1, 0, 1
		needs_crop = true
	else
		texture ="Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
		left, right, top, bottom = unpack(CLASS_BUTTONS[class])
		needs_crop = true
	end

	-- crop class icon borders
	if self.db.classIconCrop and needs_crop then
		left = left + (right - left) * 0.07
		right = right - (right - left) * 0.07
		top = top + (bottom - top) * 0.07
		bottom = bottom - (bottom - top) * 0.07
	end

	self.frame[unit].texture:SetTexture(texture)
	self.frame[unit].texture:SetTexCoord(left, right, top, bottom)

	self.frame[unit].cooldown:Hide()
end

function ClassIcon:CreateFrame(unit)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	-- create frame
	self.frame[unit] = CreateFrame("CheckButton", "GladiusEx" .. self:GetName() .. "Frame" .. unit, button, "ActionButtonTemplate")
	self.frame[unit]:EnableMouse(false)
	self.frame[unit]:SetNormalTexture("Interface\\AddOns\\GladiusEx\\images\\gloss")
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

	local parent = GladiusEx:GetAttachFrame(unit, self.db.classIconAttachTo)
	self.frame[unit]:SetPoint(self.db.classIconAnchor, parent, self.db.classIconRelativePoint, self.db.classIconOffsetX, self.db.classIconOffsetY)

	-- frame level
	self.frame[unit]:SetFrameLevel(self.db.classIconFrameLevel)

	if (self.db.classIconAdjustSize) then
		self.frame[unit]:SetWidth(GladiusEx.buttons[unit].frameHeight)
		self.frame[unit]:SetHeight(GladiusEx.buttons[unit].frameHeight)
	else
		self.frame[unit]:SetWidth(self.db.classIconSize)
		self.frame[unit]:SetHeight(self.db.classIconSize)
	end

	-- set frame mouse-interactable area
	if (self:GetAttachTo() == "Frame") then
		local left, right, top, bottom = GladiusEx.buttons[unit]:GetHitRectInsets()

		if (strfind(self.db.classIconRelativePoint, "LEFT")) then
			left = -self.frame[unit]:GetWidth() + self.db.classIconOffsetX
		else
			right = -self.frame[unit]:GetWidth() + -self.db.classIconOffsetX
		end

		-- top / bottom
		if (self.frame[unit]:GetHeight() > GladiusEx.buttons[unit]:GetHeight()) then
			bottom = -(self.frame[unit]:GetHeight() - GladiusEx.buttons[unit]:GetHeight()) + self.db.classIconOffsetY
		end

		GladiusEx.buttons[unit]:SetHitRectInsets(left, right, 0, 0)
		GladiusEx.buttons[unit].secure:SetHitRectInsets(left, right, 0, 0)
	end

	-- style action button
	self.frame[unit].normalTexture:SetHeight(self.frame[unit]:GetHeight() + self.frame[unit]:GetHeight() * 0.4)
	self.frame[unit].normalTexture:SetWidth(self.frame[unit]:GetWidth() + self.frame[unit]:GetWidth() * 0.4)

	self.frame[unit].normalTexture:ClearAllPoints()
	self.frame[unit].normalTexture:SetPoint("CENTER", 0, 0)
	self.frame[unit]:SetNormalTexture("Interface\\AddOns\\GladiusEx\\images\\gloss")

	self.frame[unit].texture:ClearAllPoints()
	self.frame[unit].texture:SetPoint("TOPLEFT", self.frame[unit], "TOPLEFT")
	self.frame[unit].texture:SetPoint("BOTTOMRIGHT", self.frame[unit], "BOTTOMRIGHT")

	self.frame[unit].normalTexture:SetVertexColor(self.db.classIconGlossColor.r, self.db.classIconGlossColor.g,
		self.db.classIconGlossColor.b, self.db.classIconGloss and self.db.classIconGlossColor.a or 0)

	-- cooldown
	if (self.db.classIconCooldown) then
		self.frame[unit].cooldown:Show()
	else
		self.frame[unit].cooldown:Hide()
	end

	self.frame[unit].cooldown:SetReverse(self.db.classIconCooldownReverse)

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
	-- reset cooldown
	self.frame[unit].cooldown:SetCooldown(GetTime(), 0)

	-- reset texture
	self.frame[unit].texture:SetTexture("")

	-- hide
	self.frame[unit]:SetAlpha(0)
end

function ClassIcon:Test(unit)
	local aura
end

function ClassIcon:GetImportantAura(name)
	return self.db.classIconAuras[name]
end

local function HasAuraEditBox()
	return not not LibStub("AceGUI-3.0").WidgetVersions["Aura_EditBox"]
end

local options
function ClassIcon:GetOptions()
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
							disabled = function() return not self:IsEnabled() end,
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
							name = L["Important Auras"],
							desc = L["Show important auras instead of the class icon"],
							disabled = function() return not self:IsEnabled() end,
							order = 5,
						},
						classIconCrop = {
							type = "toggle",
							name = L["Crop Borders"],
							desc = L["Toggle if the class icon borders should be cropped or not."],
							disabled = function() return not self:IsEnabled() end,
							hidden = function() return not GladiusEx.db.advancedOptions end,
							order = 6,
						},
						classIconCooldown = {
							type = "toggle",
							name = L["Class Icon Cooldown Spiral"],
							desc = L["Display the cooldown spiral for important auras"],
							width = "full",
							disabled = function() return not self:IsEnabled() end,
							hidden = function() return not GladiusEx.db.advancedOptions end,
							order = 10,
						},
						classIconCooldownReverse = {
							type = "toggle",
							name = L["Class Icon Cooldown Reverse"],
							desc = L["Invert the dark/bright part of the cooldown spiral"],
							width = "full",
							disabled = function() return not self:IsEnabled() end,
							hidden = function() return not GladiusEx.db.advancedOptions end,
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
							name = L["Class Icon Gloss"],
							desc = L["Toggle gloss on the class icon"],
							disabled = function() return not self:IsEnabled() end,
							hidden = function() return not GladiusEx.db.advancedOptions end,
							order = 20,
						},
						classIconGlossColor = {
							type = "color",
							name = L["Class Icon Gloss Color"],
							desc = L["Color of the class icon gloss"],
							get = function(info) return GladiusEx:GetColorOption(self.db, info) end,
							set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db, info, r, g, b, a) end,
							hasAlpha = true,
							disabled = function() return not self:IsEnabled() end,
							hidden = function() return not GladiusEx.db.advancedOptions end,
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
							name = L["Class Icon Frame Level"],
							desc = L["Frame level of the class icon"],
							disabled = function() return not self:IsEnabled() end,
							hidden = function() return not GladiusEx.db.advancedOptions end,
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
							name = L["Class Icon Adjust Size"],
							desc = L["Adjust class icon size to the frame size"],
							disabled = function() return not self:IsEnabled() end,
							order = 5,
						},
						classIconSize = {
							type = "range",
							name = L["Class Icon Size"],
							desc = L["Size of the class icon"],
							min = 10, max = 100, step = 1,
							disabled = function() return self.db.classIconAdjustSize or not self:IsEnabled() end,
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
							name = L["Class Icon Attach To"],
							desc = L["Attach class icon to given frame"],
							values = function() return ClassIcon:GetAttachPoints() end,
							disabled = function() return not self:IsEnabled() end,
							hidden = function() return not GladiusEx.db.advancedOptions end,
							order = 5,
						},
						classIconPosition = {
							type = "select",
							name = L["Class Icon Position"],
							desc = L["Position of the class icon"],
							values = { ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"] },
							get = function() return strfind(self.db.classIconAnchor, "RIGHT") and "LEFT" or "RIGHT" end,
							set = function(info, value)
								if (value == "LEFT") then
									self.db.classIconAnchor = "TOPRIGHT"
									self.db.classIconRelativePoint = "TOPLEFT"
								else
									self.db.classIconAnchor = "TOPLEFT"
									self.db.classIconRelativePoint = "TOPRIGHT"
								end

								GladiusEx:UpdateFrame(info[1])
							end,
							disabled = function() return not self:IsEnabled() end,
							hidden = function() return GladiusEx.db.advancedOptions end,
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
							name = L["Class Icon Anchor"],
							desc = L["Anchor of the class icon"],
							values = function() return GladiusEx:GetPositions() end,
							disabled = function() return not self:IsEnabled() end,
							hidden = function() return not GladiusEx.db.advancedOptions end,
							order = 10,
						},
						classIconRelativePoint = {
							type = "select",
							name = L["Class Icon Relative Point"],
							desc = L["Relative point of the class icon"],
							values = function() return GladiusEx:GetPositions() end,
							disabled = function() return not self:IsEnabled() end,
							hidden = function() return not GladiusEx.db.advancedOptions end,
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
							name = L["Class Icon Offset X"],
							desc = L["X offset of the class icon"],
							min = -100, max = 100, step = 1,
							disabled = function() return not self:IsEnabled() end,
							order = 20,
						},
						classIconOffsetY = {
							type = "range",
							name = L["Class Icon Offset Y"],
							desc = L["Y offset of the class icon"],
							disabled = function() return not self:IsEnabled() end,
							min = -50, max = 50, step = 1,
							order = 25,
						},
					},
				},
			},
		},
		auraList = {
			type = "group",
			name = L["Important Auras"],
			childGroups = "tree",
			order = 3,
			args = {
				newAura = {
					type = "group",
					name = L["New Aura"],
					desc = L["New Aura"],
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
							order = 1,
						},
						priority = {
							type= "range",
							name = L["Priority"],
							desc = L["Select what priority the aura should have - higher equals more priority"],
							get = function() return self.newAuraPriority or "" end,
							set = function(info, value) self.newAuraPriority = value end,
							min = 0,
							max = 10,
							step = 1,
							order = 2,
						},
						add = {
							type = "execute",
							name = L["Add new Aura"],
							func = function(info)
								self.db.classIconAuras[self.newAuraName] = self.newAuraPriority
								options.auraList.args[self.newAuraName] = self:SetupAuraOptions(self.newAuraName)
								self.newAuraName = nil
								GladiusEx:UpdateFrames()
							end,
							disabled = function() return not (self.newAuraName and self.newAuraPriority) end,
							order = 3,
						},
					},
				},
			},
		},
	}

	-- put some initial value for the auras priority
	self.newAuraPriority = 5

	-- set auras
	self:SetupAllAurasOptions()

	return options
end

function ClassIcon:SetupAllAurasOptions()
	local tmp = options.auraList.args.newAura
	options.auraList.args = { newAura = tmp }
	for aura, priority in pairs(self.db.classIconAuras) do
		options.auraList.args[aura] = self:SetupAuraOptions(aura)
	end
end

function ClassIcon:SetupAuraOptions(aura)
	local function setAura(info, value)
		if (info[#(info)] == "name") then
			local old_name = info[#(info) - 1]

			-- create new aura
			self.db.classIconAuras[value] = self.db.classIconAuras[old_name]
			options.auraList.args[value] = self:SetupAuraOptions(value)

			-- delete old aura
			self.db.classIconAuras[old_name] = nil
			options.auraList.args[old_name] = nil
		else
			self.db.classIconAuras[info[#(info) - 1]] = value
		end

		GladiusEx:UpdateFrames()
	end

	local function getAura(info)
		if (info[#(info)] == "name") then
			return info[#(info) - 1]
		else
			return self.db.classIconAuras[info[#(info) - 1]]
		end

		GladiusEx:UpdateFrames()
	end

	return {
		type = "group",
		name = aura,
		desc = aura,
		get = getAura,
		set = setAura,
		args = {
			name = {
				type = "input",
				dialogControl = HasAuraEditBox() and "Aura_EditBox" or nil,
				name = L["Name"],
				desc = L["Name of the aura"],
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
					self.db.classIconAuras[aura] = nil
					options.auraList.args[aura] = nil

					GladiusEx:UpdateFrames()
				end,
				order = 3,
			},
		},
	}
end
