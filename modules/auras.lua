local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM = LibStub("LibSharedMedia-3.0")
local fn = LibStub("LibFunctional-1.0")
local LD = LibStub("LibDispellable-1.0")
local MSQ = LibStub("Masque", true)
local MSQ_Buffs
local MSQ_Debuffs
if MSQ then
	MSQ_Buffs = MSQ:Group("GladiusEx", "Buffs")
	MSQ_Debuffs = MSQ:Group("GladiusEx", "Debuffs")
end

-- global functions
local strfind = string.find
local pairs = pairs
local UnitAura, UnitBuff, UnitDebuff, GetSpellInfo = UnitAura, UnitBuff, UnitDebuff, GetSpellInfo
local band = bit.band
local ceil = math.ceil

local FILTER_TYPE_DISABLED = 0
local FILTER_TYPE_WHITELIST = 1
local FILTER_TYPE_BLACKLIST = 2

local FILTER_WHAT_BUFFS = 2
local FILTER_WHAT_DEBUFFS = 4
local FILTER_WHAT_BOTH = 6

local defaults = {
	aurasBuffs = true,
	aurasBuffsOnlyDispellable = false,
	aurasBuffsOnlyMine = false,
	aurasBuffsSpacingX = 1,
	aurasBuffsSpacingY = 1,
	aurasBuffsPerColumn = 6,
	aurasBuffsMax = 6,
	aurasBuffsSize = 16,
	aurasBuffsOffsetX = 0,
	aurasBuffsOffsetY = 0,
	aurasBuffsTooltips = true,

	aurasDebuffs = true,
	aurasDebuffsWithBuffs = false,
	aurasDebuffsOnlyDispellable = false,
	aurasDebuffsOnlyMine = false,
	aurasDebuffsSpacingX = 1,
	aurasDebuffsSpacingY = 1,
	aurasDebuffsPerColumn = 6,
	aurasDebuffsMax = 6,
	aurasDebuffsSize = 16,
	aurasDebuffsOffsetX = 0,
	aurasDebuffsOffsetY = 0,
	aurasDebuffsTooltips = true,

	aurasFilterType = FILTER_TYPE_DISABLED,
	aurasFilterWhat = FILTER_WHAT_BOTH,
	aurasFilterAuras = {},
}

local Auras = GladiusEx:NewGladiusExModule("Auras",
	fn.merge(defaults, {
		aurasBuffsAttachTo = "Frame",
		aurasBuffsAnchor = "BOTTOMLEFT",
		aurasBuffsRelativePoint = "TOPLEFT",
		aurasBuffsGrow = "UPRIGHT",

		aurasDebuffsAttachTo = "Frame",
		aurasDebuffsAnchor = "BOTTOMRIGHT",
		aurasDebuffsRelativePoint = "TOPRIGHT",
		aurasDebuffsGrow = "UPLEFT",
	}),
	fn.merge(defaults, {
		aurasBuffsAttachTo = "Frame",
		aurasBuffsAnchor = "BOTTOMRIGHT",
		aurasBuffsRelativePoint = "TOPRIGHT",
		aurasBuffsGrow = "UPLEFT",

		aurasDebuffsAttachTo = "Frame",
		aurasDebuffsAnchor = "BOTTOMLEFT",
		aurasDebuffsRelativePoint = "TOPLEFT",
		aurasDebuffsGrow = "UPRIGHT",
	}))

function Auras:OnEnable()
	self:RegisterEvent("UNIT_AURA", "UpdateUnitAuras")

	self.buffFrame = self.buffFrame or {}
	self.debuffFrame = self.debuffFrame or {}
end

function Auras:OnDisable()
	self:UnregisterAllEvents()

	for unit in pairs(self.debuffFrame) do
		self.debuffFrame[unit]:Hide()
	end

	for unit in pairs(self.buffFrame) do
		self.buffFrame[unit]:Hide()
	end
end

function Auras:GetFrames(unit)
	return { self.buffFrame[unit], self.debuffFrame[unit] }
end

function Auras:GetModuleAttachPoints(unit)
	return {
		["Buffs"] = L["Buffs"],
		["Debuffs"] = L["Debuffs"],
	}
end

function Auras:GetModuleAttachFrame(unit, point)
	if point == "Buffs" then
		if not self.buffFrame[unit] then
			self:CreateFrame(unit)
		end
		return self.buffFrame[unit]
	else
		if not self.debuffFrame[unit] then
			self:CreateFrame(unit)
		end
		return self.debuffFrame[unit]
	end
end

function Auras:IsAuraFiltered(unit, name, what)
	if self.db[unit].aurasFilterType == FILTER_TYPE_DISABLED then
		return true
	elseif band(self.db[unit].aurasFilterWhat, what) ~= what then
		return true
	elseif self.db[unit].aurasFilterType == FILTER_TYPE_WHITELIST then
		return self.db[unit].aurasFilterAuras[name]
	elseif self.db[unit].aurasFilterType == FILTER_TYPE_BLACKLIST then
		return not self.db[unit].aurasFilterAuras[name]
	end
end

local player_units = {
	["player"] = true,
	["vehicle"] = true,
	["pet"] = true
}

function Auras:UpdateUnitAuras(event, unit)
	if not self.buffFrame[unit] and not self.debuffFrame[unit] then return end

	local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID
	local icon_index = 1
	local frame
	local max

	local function SetAura(index, buff)
		local aura_frame = frame[icon_index]

		aura_frame.unit = unit
		aura_frame.aura_index = index
		aura_frame.aura_buff = buff

		aura_frame.icon:SetTexture(icon)
		if duration > 0 then
			aura_frame.cooldown:SetCooldown(expires - duration, duration)
			aura_frame.cooldown:Show()
		else
			aura_frame.cooldown:Hide()
		end
		aura_frame.count:SetText(count > 1 and count or nil)

		--if isStealable then
		if true then
			local color = DebuffTypeColor[dispelType] or DebuffTypeColor["none"]
			aura_frame.border:SetVertexColor(color.r, color.g, color.b)
			aura_frame.border:Show()
		else
			aura_frame.border:Hide()
		end

		aura_frame:Show()
		icon_index = icon_index + 1
	end

	-- buffs
	if self.db[unit].aurasBuffs then
		frame = self.buffFrame[unit]
		max = self.db[unit].aurasBuffsMax
		local only_mine = self.db[unit].aurasBuffsOnlyMine
		local only_dispellable = self.db[unit].aurasBuffsOnlyDispellable

		for i = 1, 40 do
			name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID = UnitBuff(unit, i)

			if not name then break end

			if self:IsAuraFiltered(unit, name, FILTER_WHAT_BUFFS) and
				(not only_mine or player_units[caster]) and
				(not only_dispellable or LD:CanDispel(unit, true, dispelType, spellID)) then
				SetAura(i, true)
				if icon_index > max then break end
			end
		end

		-- hide unused aura frames
		for i = icon_index, 40 do
			self.buffFrame[unit][i]:Hide()
		end
	end

	-- debuffs
	if self.db[unit].aurasDebuffs then
		local only_mine = self.db[unit].aurasDebuffsOnlyMine
		local only_dispellable = self.db[unit].aurasDebuffsOnlyDispellable

		if self.db[unit].aurasBuffs and not self.db[unit].aurasDebuffsWithBuffs then
			frame = self.debuffFrame[unit]
			max = self.db[unit].aurasDebuffsMax
			icon_index = 1
		end

		if not frame then return end

		for i = 1, 40 do
			name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID = UnitDebuff(unit, i)

			if not name then break end

			if self:IsAuraFiltered(unit, name, FILTER_WHAT_DEBUFFS) and
				(not only_mine or player_units[caster]) and
				(not only_dispellable or LD:CanDispel(unit, false, dispelType, spellID)) then
				SetAura(i, false)
				if icon_index > max then break end
			end
		end

		-- hide unused aura frames
		for i = icon_index, 40 do
			frame[i]:Hide()
		end
	end
end

local function CreateAuraFrame(name, parent)
	local frame = CreateFrame("Button", name, parent, "ActionButtonTemplate")
	frame.icon = _G[name .. "Icon"]
	frame.border = _G[name .. "Border"]
	frame.cooldown = _G[name .. "Cooldown"]
	frame.count = _G[name .. "Count"]
	frame.ButtonData = {
		Highlight = false
	}
	return frame
end

local function UpdateAuraFrame(frame, size)
	frame:SetButtonState("NORMAL", true)
	frame:SetNormalTexture("")
	frame:SetHighlightTexture("")
	frame:SetScale(size / 36)
end

function Auras:CreateFrame(unit)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	-- create buff frame
	if (not self.buffFrame[unit] and self.db[unit].aurasBuffs) then
		self.buffFrame[unit] = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. "BuffFrame" .. unit, button)
		self.buffFrame[unit]:EnableMouse(false)

		for i = 1, 40 do
			self.buffFrame[unit][i] = CreateAuraFrame("GladiusEx" .. self:GetName() .. "BuffFrameIcon" .. i .. unit, self.buffFrame[unit])
			self.buffFrame[unit][i]:Hide()

			if MSQ_Buffs then
				MSQ_Buffs:AddButton(self.buffFrame[unit][i], self.buffFrame[unit][i].ButtonData)
			end
		end
	end

	-- create debuff frame
	if (not self.debuffFrame[unit] and self.db[unit].aurasDebuffs) then
		self.debuffFrame[unit] = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. "DebuffFrame" .. unit, button)
		self.debuffFrame[unit]:EnableMouse(false)

		for i = 1, 40 do
			self.debuffFrame[unit][i] = CreateAuraFrame("GladiusEx" .. self:GetName() .. "DebuffFrameIcon" .. i .. unit, self.debuffFrame[unit])
			self.debuffFrame[unit][i]:Hide()

			if MSQ_Debuffs then
				MSQ_Debuffs:AddButton(self.debuffFrame[unit][i], self.debuffFrame[unit][i].ButtonData)
			end
		end
	end
end

-- yeah this parameter list sucks
local function UpdateAuraGroup(
	auraFrame, unit,
	aurasBuffsAttachTo,
	aurasBuffsAnchor,
	aurasBuffsRelativePoint,
	aurasBuffsOffsetX,
	aurasBuffsOffsetY,
	aurasBuffsPerColumn,
	aurasBuffsGrow,
	aurasBuffsSize,
	aurasBuffsSpacingX,
	aurasBuffsSpacingY,
	aurasBuffsMax,
	aurasBuffsTooltips)

	-- anchor point
	local parent = GladiusEx:GetAttachFrame(unit, aurasBuffsAttachTo)
	auraFrame:ClearAllPoints()
	auraFrame:SetPoint(aurasBuffsAnchor, parent, aurasBuffsRelativePoint, aurasBuffsOffsetX, aurasBuffsOffsetY)
	auraFrame:SetFrameLevel(60)

	-- size
	auraFrame:SetWidth(aurasBuffsSize*aurasBuffsPerColumn+aurasBuffsSpacingX*aurasBuffsPerColumn)
	auraFrame:SetHeight(aurasBuffsSize*ceil(aurasBuffsMax/aurasBuffsPerColumn)+(aurasBuffsSpacingY*(ceil(aurasBuffsMax/aurasBuffsPerColumn)+1)))

	-- icon points
	local anchor, parent, relativePoint, offsetX, offsetY

	-- grow anchor
	local grow1, grow2, grow3, startRelPoint
	if (aurasBuffsGrow == "DOWNRIGHT") then
		grow1, grow2, grow3, startRelPoint = "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT", "TOPLEFT"
	elseif (aurasBuffsGrow == "DOWNLEFT") then
		grow1, grow2, grow3, startRelPoint = "TOPRIGHT", "BOTTOMRIGHT", "TOPLEFT", "TOPRIGHT"
	elseif (aurasBuffsGrow == "UPRIGHT") then
		grow1, grow2, grow3, startRelPoint = "BOTTOMLEFT", "TOPLEFT", "BOTTOMRIGHT", "BOTTOMLEFT"
	elseif (aurasBuffsGrow == "UPLEFT") then
		grow1, grow2, grow3, startRelPoint = "BOTTOMRIGHT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"
	end

	local start, startAnchor = 1, auraFrame
	for i = 1, 40 do
		if aurasBuffsMax >= i then
			if (start == 1) then
				anchor, parent, relativePoint, offsetX, offsetY = grow1, startAnchor, startRelPoint, 0, strfind(aurasBuffsGrow, "DOWN") and -aurasBuffsSpacingY or aurasBuffsSpacingY
			else
				anchor, parent, relativePoint, offsetX, offsetY = grow1, auraFrame[i-1], grow3, strfind(aurasBuffsGrow, "LEFT") and -aurasBuffsSpacingX or aurasBuffsSpacingX, 0
			end

			if (start == aurasBuffsPerColumn) then
				start = 0
				startAnchor = auraFrame[i - aurasBuffsPerColumn + 1]
				startRelPoint = grow2
			end

			start = start + 1
		end

		auraFrame[i]:ClearAllPoints()
		auraFrame[i]:SetPoint(anchor, parent, relativePoint, offsetX, offsetY)
		if aurasBuffsTooltips then
			auraFrame[i]:EnableMouse(true)
			auraFrame[i]:SetScript("OnEnter", function(self)
				if self.aura_index then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					if self.aura_buff then
						GameTooltip:SetUnitBuff(self.unit, self.aura_index)
					else
						GameTooltip:SetUnitDebuff(self.unit, self.aura_index)
					end
				end
			end)
			auraFrame[i]:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
		else
			auraFrame[i]:EnableMouse(false)
			auraFrame[i]:SetScript("OnEnter", nil)
			auraFrame[i]:SetScript("OnLeave", nil)
		end
		UpdateAuraFrame(auraFrame[i], aurasBuffsSize)
	end
end

function Auras:Update(unit)
	-- create frame
	if not self.buffFrame[unit] or not self.debuffFrame[unit] then
		self:CreateFrame(unit)
	end

	-- update buff frame
	if self.db[unit].aurasBuffs then
		UpdateAuraGroup(self.buffFrame[unit], unit,
			self.db[unit].aurasBuffsAttachTo,
			self.db[unit].aurasBuffsAnchor,
			self.db[unit].aurasBuffsRelativePoint,
			self.db[unit].aurasBuffsOffsetX,
			self.db[unit].aurasBuffsOffsetY,
			self.db[unit].aurasBuffsPerColumn,
			self.db[unit].aurasBuffsGrow,
			self.db[unit].aurasBuffsSize,
			self.db[unit].aurasBuffsSpacingX,
			self.db[unit].aurasBuffsSpacingY,
			self.db[unit].aurasBuffsMax,
			self.db[unit].aurasBuffsTooltips)
		if MSQ_Buffs then
			MSQ_Buffs:ReSkin()
		end
	end
	-- hide
	if self.buffFrame[unit] then
		self.buffFrame[unit]:Hide()
	end

	-- update debuff frame
	if self.db[unit].aurasDebuffs then
		UpdateAuraGroup(self.debuffFrame[unit], unit,
			self.db[unit].aurasDebuffsAttachTo,
			self.db[unit].aurasDebuffsAnchor,
			self.db[unit].aurasDebuffsRelativePoint,
			self.db[unit].aurasDebuffsOffsetX,
			self.db[unit].aurasDebuffsOffsetY,
			self.db[unit].aurasDebuffsPerColumn,
			self.db[unit].aurasDebuffsGrow,
			self.db[unit].aurasDebuffsSize,
			self.db[unit].aurasDebuffsSpacingX,
			self.db[unit].aurasDebuffsSpacingY,
			self.db[unit].aurasDebuffsMax,
			self.db[unit].aurasDebuffsTooltips)
		if MSQ_Debuffs then
			MSQ_Debuffs:ReSkin()
		end
	end
	-- hide
	if self.debuffFrame[unit] then
		self.debuffFrame[unit]:Hide()
	end
end

function Auras:Show(unit)
	-- show buff frame
	if self.db[unit].aurasBuffs and self.buffFrame[unit] then
		self.buffFrame[unit]:Show()
	end

	-- show debuff frame
	if self.db[unit].aurasDebuffs and self.debuffFrame[unit] and not self.db[unit].aurasDebuffsWithBuffs then
		self.debuffFrame[unit]:Show()
	end

	self:UpdateUnitAuras("Show", unit)
end

function Auras:Reset(unit)
	if self.buffFrame[unit] then
		-- hide buff frame
		self.buffFrame[unit]:Hide()

		for i = 1, 40 do
			self.buffFrame[unit][i]:Hide()
		end
	end

	if self.debuffFrame[unit] then
		-- hide debuff frame
		self.debuffFrame[unit]:Hide()

		for i = 1, 40 do
			self.debuffFrame[unit][i]:Hide()
		end
	end
end

function Auras:Test(unit)
	-- test buff frame
	if self.buffFrame[unit] then
		local m = math.floor(self.db[unit].aurasBuffsMax / 2)
		for i = 1, m do
			self.buffFrame[unit][i].icon:SetTexture(GetSpellTexture(21562))
			self.buffFrame[unit][i]:Show()
		end

		for i = m + 1, self.db[unit].aurasBuffsMax do
			if self.db[unit].aurasDebuffs and self.db[unit].aurasDebuffsWithBuffs then
				self.buffFrame[unit][i].icon:SetTexture(GetSpellTexture(589))
			else
				self.buffFrame[unit][i].icon:SetTexture(GetSpellTexture(21562))
			end
			self.buffFrame[unit][i]:Show()
		end
	end

	-- test debuff frame
	if self.debuffFrame[unit] then
		for i = 1, self.db[unit].aurasDebuffsMax do
			self.debuffFrame[unit][i].icon:SetTexture(GetSpellTexture(589))
			self.debuffFrame[unit][i]:Show()
		end
	end
end

local function HasAuraEditBox()
	return not not LibStub("AceGUI-3.0").WidgetVersions["Aura_EditBox"]
end

function Auras:GetOptions(unit)
	local options
	options = {
		buffs = {
			type = "group",
			name = L["Buffs"],
			order = 1,
			args = {
				general = {
					type = "group",
					name = L["General"],
					inline = true,
					order = 1,
					args = {
						widget = {
							type = "group",
							name = L["Widget"],
							desc = L["Widget settings"],
							inline = true,
							order = 1,
							args = {
								aurasBuffs = {
									type = "toggle",
									name = L["Buffs"],
									desc = L["Toggle aura buffs"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 5,
								},
								sep = {
									type = "description",
									name = "",
									width = "full",
									order = 13,
								},
								aurasBuffsOnlyDispellable = {
									type = "toggle",
									width = "full",
									name = L["Show only dispellable"],
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
									hidden = function() return GladiusEx:IsPartyUnit(unit) end,
									order = 14,
								},
								aurasBuffsOnlyMine = {
									type = "toggle",
									width = "full",
									name = L["Show only mine"],
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
									hidden = function() return GladiusEx:IsArenaUnit(unit) end,
									order = 14.1,
								},
								aurasBuffsTooltips = {
									type = "toggle",
									name = L["Show tooltips"],
									desc = L["Toggle if the icons should show the spell tooltip when hovered"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 15,
								},								
								aurasBuffsPerColumn = {
									type = "range",
									name = L["Icons per column"],
									desc = L["Number of aura icons per column"],
									min = 1, max = 50, step = 1,
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
									order = 16,
								},
								aurasBuffsMax = {
									type = "range",
									name = L["Icons max"],
									desc = L["Number of max buffs"],
									min = 1, max = 40, step = 1,
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
									order = 20,
								},
								sep2 = {
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
								aurasBuffsSize = {
									type = "range",
									name = L["Icon size"],
									desc = L["Size of the aura icons"],
									min = 10, max = 100, step = 1,
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
									order = 5,
								},
								sep = {
									type = "description",
									name = "",
									width = "full",
									order = 13,
								},
								aurasBuffsSpacingY = {
									type = "range",
									name = L["Vertical spacing"],
									desc = L["Vertical spacing of the icons"],
									min = 0, max = 30, step = 1,
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
									order = 15,
								},
								aurasBuffsSpacingX = {
									type = "range",
									name = L["Horizontal spacing"],
									desc = L["Horizontal spacing of the icons"],
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
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
							order = 3,
							args = {
								aurasBuffsAttachTo = {
									type = "select",
									name = L["Attach to"],
									desc = L["Attach to the given frame"],
									values = function() return self:GetOtherAttachPoints(unit) end,
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
									order = 5,
								},
								aurasBuffsPosition = {
									type = "select",
									name = L["Position"],
									desc = L["Position of the frame"],
									values = GladiusEx:GetGrowSimplePositions(),
									get = function()
										return GladiusEx:GrowSimplePositionFromAnchor(
											self.db[unit].aurasBuffsAnchor,
											self.db[unit].aurasBuffsRelativePoint,
											self.db[unit].aurasBuffsGrow)
									end,
									set = function(info, value)
										self.db[unit].aurasBuffsAnchor, self.db[unit].aurasBuffsRelativePoint =
											GladiusEx:AnchorFromGrowSimplePosition(value, self.db[unit].aurasBuffsGrow)
										GladiusEx:UpdateFrames()
									end,
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
									hidden = function() return GladiusEx.db.base.advancedOptions end,
									order = 6,
								},
								aurasBuffsGrow = {
									type = "select",
									name = L["Grow direction"],
									desc = L["Grow direction of the icons"],
									values = {
										["UPLEFT"] = L["Up left"],
										["UPRIGHT"] = L["Up right"],
										["DOWNLEFT"] = L["Down left"],
										["DOWNRIGHT"] = L["Down right"],
									},
									set = function(info, value)
										if not GladiusEx.db.base.advancedOptions then
											self.db[unit].aurasBuffsAnchor, self.db[unit].aurasBuffsRelativePoint =
												GladiusEx:AnchorFromGrowDirection(
													self.db[unit].aurasBuffsAnchor,
													self.db[unit].aurasBuffsRelativePoint,
													self.db[unit].aurasBuffsGrow,
													value)
										end
										self.db[unit].aurasBuffsGrow = value
										GladiusEx:UpdateFrames()
									end,
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
									order = 7,
								},
								sep = {
									type = "description",
									name = "",
									width = "full",
									order = 8,
								},
								aurasBuffsAnchor = {
									type = "select",
									name = L["Anchor"],
									desc = L["Anchor of the frame"],
									values = GladiusEx:GetPositions(),
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
									hidden = function() return not GladiusEx.db.base.advancedOptions end,
									order = 10,
								},
								aurasBuffsRelativePoint = {
									type = "select",
									name = L["Relative point"],
									desc = L["Relative point of the frame"],
									values = GladiusEx:GetPositions(),
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
									hidden = function() return not GladiusEx.db.base.advancedOptions end,
									order = 15,
								},
								sep2 = {
									type = "description",
									name = "",
									width = "full",
									order = 17,
								},
								aurasBuffsOffsetX = {
									type = "range",
									name = L["Offset X"],
									desc = L["X offset of the frame"],
									softMin = -100, softMax = 100, bigStep = 1,
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
									order = 20,
								},
								aurasBuffsOffsetY = {
									type = "range",
									name = L["Offset Y"],
									desc = L["Y offset of the frame"],
									softMin = -100, softMax = 100, bigStep = 1,
									disabled = function() return not self.db[unit].aurasBuffs or not self:IsUnitEnabled(unit) end,
									order = 25,
								},
							},
						},
					},
				},
			},
		},
		debuffs = {
			type = "group",
			name = L["Debuffs"],
			order = 2,
			args = {
				general = {
					type = "group",
					name = L["General"],
					inline = true,
					order = 1,
					args = {
						widget = {
							type = "group",
							name = L["Widget"],
							desc = L["Widget settings"],
							inline = true,
							order = 1,
							args = {
								aurasDebuffs = {
									type = "toggle",
									name = L["Debuffs"],
									desc = L["Toggle aura debuffs"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 5,
								},
								aurasDebuffsWithBuffs = {
									type = "toggle",
									name = L["Debuffs with buffs"],
									width = "full",
									disabled = function() return not self:IsUnitEnabled(unit) or not self.db[unit].aurasBuffs end,
									order = 6,
								},
								sep = {
									type = "description",
									name = "",
									width = "full",
									order = 13,
								},
								aurasDebuffsOnlyDispellable = {
									type = "toggle",
									width = "full",
									name = L["Show only dispellable"],
									disabled = function() return not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
									hidden = function() return GladiusEx:IsArenaUnit(unit) end,
									order = 14,
								},
								aurasDebuffsOnlyMine = {
									type = "toggle",
									width = "full",
									name = L["Show only mine"],
									disabled = function() return not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
									hidden = function() return GladiusEx:IsPartyUnit(unit) end,
									order = 14.1,
								},
								aurasDebuffsTooltips = {
									type = "toggle",
									name = L["Show tooltips"],
									desc = L["Toggle if the icons should show the spell tooltip when hovered"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 15,
								},
								aurasDebuffsPerColumn = {
									type = "range",
									name = L["Icons per column"],
									desc = L["Number of icons per column"],
									min = 1, max = 50, step = 1,
									disabled = function() return not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
									order = 16,
								},
								aurasDebuffsMax = {
									type = "range",
									name = L["Icons max"],
									desc = L["Number of max icons"],
									min = 1, max = 40, step = 1,
									disabled = function() return not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
									order = 20,
								},
								sep2 = {
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
								aurasDebuffsSize = {
									type = "range",
									name = L["Icon size"],
									desc = L["Size of the icons"],
									min = 10, max = 100, step = 1,
									disabled = function() return not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
									order = 5,
								},
								sep = {
									type = "description",
									name = "",
									width = "full",
									order = 13,
								},
								aurasDebuffsSpacingY = {
									type = "range",
									name = L["Vertical spacing"],
									desc = L["Vertical spacing of the icons"],
									min = 0, max = 30, step = 1,
									disabled = function() return not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
									order = 15,
								},
								aurasDebuffsSpacingX = {
									type = "range",
									name = L["Horizontal spacing"],
									desc = L["Horizontal spacing of the icons"],
									disabled = function() return not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
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
							order = 3,
							args = {
								aurasDebuffsAttachTo = {
									type = "select",
									name = L["Attach to"],
									desc = L["Attach to the given frame"],
									values = function() return self:GetOtherAttachPoints(unit) end,
									disabled = function() return self.db[unit].aurasDebuffsWithBuffs or not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
									order = 5,
								},
								aurasDebuffsPosition = {
									type = "select",
									name = L["Position"],
									desc = L["Position of the frame"],
									values = GladiusEx:GetGrowSimplePositions(),
									get = function()
										return GladiusEx:GrowSimplePositionFromAnchor(
											self.db[unit].aurasDebuffsAnchor,
											self.db[unit].aurasDebuffsRelativePoint,
											self.db[unit].aurasDebuffsGrow)
									end,
									set = function(info, value)
										self.db[unit].aurasDebuffsAnchor, self.db[unit].aurasDebuffsRelativePoint =
											GladiusEx:AnchorFromGrowSimplePosition(value, self.db[unit].aurasDebuffsGrow)
										GladiusEx:UpdateFrames()
									end,
									disabled = function() return self.db[unit].aurasDebuffsWithBuffs or not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
									hidden = function() return GladiusEx.db.base.advancedOptions end,
									order = 6,
								},
								aurasDebuffsGrow = {
									type = "select",
									name = L["Grow direction"],
									desc = L["Grow direction of the icons"],
									values = {
										["UPLEFT"] = L["Up left"],
										["UPRIGHT"] = L["Up right"],
										["DOWNLEFT"] = L["Down left"],
										["DOWNRIGHT"] = L["Down right"],
									},
									set = function(info, value)
										if not GladiusEx.db.base.advancedOptions then
											self.db[unit].aurasDebuffsAnchor, self.db[unit].aurasDebuffsRelativePoint =
												GladiusEx:AnchorFromGrowDirection(
													self.db[unit].aurasDebuffsAnchor,
													self.db[unit].aurasDebuffsRelativePoint,
													self.db[unit].aurasDebuffsGrow,
													value)
										end
										self.db[unit].aurasDebuffsGrow = value
										GladiusEx:UpdateFrames()
									end,
									disabled = function() return not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
									order = 7,
								},
								sep = {
									type = "description",
									name = "",
									width = "full",
									order = 9,
								},
								aurasDebuffsAnchor = {
									type = "select",
									name = L["Anchor"],
									desc = L["Anchor of the frame"],
									values = GladiusEx:GetPositions(),
									disabled = function() return self.db[unit].aurasDebuffsWithBuffs or not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
									hidden = function() return not GladiusEx.db.base.advancedOptions end,
									order = 10,
								},
								aurasDebuffsRelativePoint = {
									type = "select",
									name = L["Relative point"],
									desc = L["Relative point of the frame"],
									values = GladiusEx:GetPositions(),
									disabled = function() return self.db[unit].aurasDebuffsWithBuffs or not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
									hidden = function() return not GladiusEx.db.base.advancedOptions end,
									order = 15,
								},
								sep2 = {
									type = "description",
									name = "",
									width = "full",
									order = 17,
								},
								aurasDebuffsOffsetX = {
									type = "range",
									name = L["Offset X"],
									desc = L["X offset"],
									softMin = -100, softMax = 100, bigStep = 1,
									disabled = function() return self.db[unit].aurasDebuffsWithBuffs or not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
									order = 20,
								},
								aurasDebuffsOffsetY = {
									type = "range",
									name = L["Offset Y"],
									desc = L["Y offset"],
									disabled = function() return self.db[unit].aurasDebuffsWithBuffs or not self.db[unit].aurasDebuffs or not self:IsUnitEnabled(unit) end,
									softMin = -100, softMax = 100, bigStep = 1,
									order = 25,
								},
							},
						},
					},
				},
			},
		},
		filters = {
			type = "group",
			name = L["Filters"],
			childGroups = "tree",
			order = 3,
			args = {
				aurasFilterType = {
					type = "select",
					style = "radio",
					name = L["Filter type"],
					desc = L["Filter type"],
					values = {
						[FILTER_TYPE_DISABLED] = L["Disabled"],
						[FILTER_TYPE_WHITELIST] = L["Whitelist"],
						[FILTER_TYPE_BLACKLIST] = L["Blacklist"],
					},
					disabled = function() return not self:IsUnitEnabled(unit) end,
					order = 1,
				},
				aurasFilterWhat = {
					type = "select",
					style = "radio",
					name = L["Apply filter to"],
					desc = L["What auras to filter"],
					values = {
						[FILTER_WHAT_BUFFS] = L["Buffs"],
						[FILTER_WHAT_DEBUFFS] = L["Debuffs"],
						[FILTER_WHAT_BOTH] = L["Both"],
					},
					disabled = function() return not self:IsUnitEnabled(unit) end,
					order = 2,
				},
				newAura = {
					type = "group",
					name = L["Add new aura filter"],
					desc = L["Add new aura filter"],
					inline = true,
					order = 3,
					args = {
						name = {
							type = "input",
							dialogControl = HasAuraEditBox() and "Aura_EditBox" or nil,
							name = L["Name"],
							desc = L["Name of the aura"],
							get = function() return self.newAuraName or "" end,
							set = function(info, value) self.newAuraName = GetSpellInfo(value) or value end,
							disabled = function() return not self:IsUnitEnabled(unit) or self.db[unit].aurasFilterType == FILTER_TYPE_DISABLED end,
							order = 1,
						},
						add = {
							type = "execute",
							name = L["Add new aura filter"],
							func = function(info)
								self.db[unit].aurasFilterAuras[self.newAuraName] = true
								options.filters.args[self.newAuraName] = self:SetupAuraOptions(options, unit, self.newAuraName)
								self.newAuraName = nil
								GladiusEx:UpdateFrames()
							end,
							disabled = function() return not self:IsUnitEnabled(unit) or not self.newAuraName or self.db[unit].aurasFilterType == FILTER_TYPE_DISABLED end,
							order = 3,
						},
					},
				},
			},
		},
	}

	-- setup auras
	for aura in pairs(self.db[unit].aurasFilterAuras) do
		options.filters.args[aura] = self:SetupAuraOptions(options, unit, aura)
	end

	return options
end

function Auras:SetupAuraOptions(options, unit, aura)
	local function setAura(info, value)
		if (info[#(info)] == "name") then
			local old_name = info[#(info) - 1]

			-- create new aura
			self.db[unit].aurasFilterAuras[value] = true
			options.filters.args[value] = self:SetupAuraOptions(options, unit, value)

			-- delete old aura
			self.db[unit].aurasFilterAuras[old_name] = nil
			options.filters.args[old_name] = nil
		else
			self.db[unit].aurasFilterAuras[info[#(info) - 1]] = value
		end

		GladiusEx:UpdateFrames()
	end

	local function getAura(info)
		if (info[#(info)] == "name") then
			return info[#(info) - 1]
		else
			return self.db[unit].aurasFilterAuras[info[#(info) - 1]]
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
				disabled = function() return not self:IsUnitEnabled(unit)  or self.db[unit].aurasFilterType == FILTER_TYPE_DISABLED end,
				order = 1,
			},
			delete = {
				type = "execute",
				name = L["Delete"],
				func = function(info)
					local aura = info[#(info) - 1]
					self.db[unit].aurasFilterAuras[aura] = nil
					options.filters.args[aura] = nil

					GladiusEx:UpdateFrames()
				end,
				disabled = function() return not self:IsUnitEnabled(unit) or self.db[unit].aurasFilterType == FILTER_TYPE_DISABLED end,
				order = 3,
			},
		},
	}
end
