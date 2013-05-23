local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM = LibStub("LibSharedMedia-3.0")

-- global functions
local strfind = string.find
local pairs = pairs
local UnitAura, UnitBuff, UnitDebuff, GetSpellInfo = UnitAura, UnitBuff, UnitDebuff, GetSpellInfo
local ceil = math.ceil

local FILTER_TYPE_DISABLED = 0
local FILTER_TYPE_WHITELIST = 1
local FILTER_TYPE_BLACKLIST = 2

local Auras = GladiusEx:NewGladiusExModule("Auras", {
		aurasBuffsAttachTo = "ClassIcon",
		aurasBuffsAnchor = "BOTTOMLEFT",
		aurasBuffsRelativePoint = "TOPLEFT",
		aurasBuffsGrow = "UPRIGHT",
		aurasBuffs = true,
		aurasBuffsOnlyDispellable = false,
		aurasDebuffsOnlyMine = false,
		aurasBuffsSpacingX = 0,
		aurasBuffsSpacingY = 0,
		aurasBuffsPerColumn = 6,
		aurasBuffsMax = 18,
		aurasBuffsSize = 16,
		aurasBuffsOffsetX = 0,
		aurasBuffsOffsetY = 0,
		aurasBuffsCrop = true,

		aurasDebuffsAttachTo = "Frame",
		aurasDebuffsAnchor = "BOTTOMRIGHT",
		aurasDebuffsRelativePoint = "TOPRIGHT",
		aurasDebuffsGrow = "UPLEFT",
		aurasDebuffsWithBuffs = false,
		aurasDebuffs = true,
		aurasDebuffsOnlyDispellable = false,
		aurasDebuffsOnlyMine = false,
		aurasDebuffsSpacingX = 0,
		aurasDebuffsSpacingY = 0,
		aurasDebuffsPerColumn = 6,
		aurasDebuffsMax = 18,
		aurasDebuffsSize = 16,
		aurasDebuffsOffsetX = 0,
		aurasDebuffsOffsetY = 0,
		aurasDebuffsCrop = true,

		aurasFilterType = FILTER_TYPE_DISABLED,
		aurasFilterAuras = {},
	},
	{
		aurasBuffsAttachTo = "ClassIcon",
		aurasBuffsAnchor = "BOTTOMRIGHT",
		aurasBuffsRelativePoint = "TOPRIGHT",
		aurasBuffsGrow = "UPLEFT",
		aurasBuffs = true,
		aurasBuffsOnlyDispellable = false,
		aurasDebuffsOnlyMine = false,
		aurasBuffsSpacingX = 0,
		aurasBuffsSpacingY = 0,
		aurasBuffsPerColumn = 6,
		aurasBuffsMax = 18,
		aurasBuffsSize = 16,
		aurasBuffsOffsetX = 0,
		aurasBuffsOffsetY = 0,
		aurasBuffsCrop = true,

		aurasDebuffsAttachTo = "Frame",
		aurasDebuffsAnchor = "BOTTOMLEFT",
		aurasDebuffsRelativePoint = "TOPLEFT",
		aurasDebuffsGrow = "UPRIGHT",
		aurasDebuffsWithBuffs = false,
		aurasDebuffs = true,
		aurasDebuffsOnlyDispellable = false,
		aurasDebuffsOnlyMine = false,
		aurasDebuffsSpacingX = 0,
		aurasDebuffsSpacingY = 0,
		aurasDebuffsPerColumn = 6,
		aurasDebuffsMax = 18,
		aurasDebuffsSize = 16,
		aurasDebuffsOffsetX = 0,
		aurasDebuffsOffsetY = 0,
		aurasDebuffsCrop = true,

		aurasFilterType = FILTER_TYPE_DISABLED,
		aurasFilterAuras = {},
	})

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

local function SetBuff(buffFrame, unit, i)
	local name, rank, icon, count, debuffType, duration, expires, caster, isStealable = UnitBuff(unit, i)

	buffFrame:SetID(i)
	buffFrame.icon:SetTexture(icon)
	if duration > 0 then
		buffFrame.cooldown:SetCooldown(expires - duration, duration)
		buffFrame.cooldown:Show()
	else
		buffFrame.cooldown:Hide()
	end
	buffFrame.count:SetText(count > 1 and count or nil)

	--if isStealable then
	if true then
		local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"]
		buffFrame.border:SetVertexColor(color.r, color.g, color.b)
		buffFrame.border:Show()
	else
		buffFrame.border:Hide()
	end


	buffFrame:Show()
end

local function SetDebuff(debuffFrame, unit, i)
	local name, rank, icon, count, debuffType, duration, expires, caster, isStealable = UnitDebuff(unit, i)

	debuffFrame:SetID(i)
	debuffFrame.icon:SetTexture(icon)

	if duration > 0 then
		debuffFrame.cooldown:SetCooldown(expires - duration, duration)
		debuffFrame.cooldown:Show()
	else
		debuffFrame.cooldown:Hide()
	end

	debuffFrame.count:SetText(count > 1 and count or nil)
	local color = debuffType and DebuffTypeColor[debuffType] or DebuffTypeColor["none"]
	debuffFrame.border:SetVertexColor(color.r, color.g, color.b)
end

function Auras:IsAuraFiltered(unit, name)
	if self.db[unit].aurasFilterType == FILTER_TYPE_DISABLED then
		return true
	elseif self.db[unit].aurasFilterType == FILTER_TYPE_WHITELIST then
		return self.db[unit].aurasFilterAuras[name]
	elseif self.db[unit].aurasFilterType == FILTER_TYPE_BLACKLIST then
		return not self.db[unit].aurasFilterAuras[name]
	end
end

function Auras:UpdateUnitAuras(event, unit)
	local color
	local sidx = 1

	if self.buffFrame[unit] and self.db[unit].aurasBuffs then
		-- buff frame
		for i = 1, 40 do
			local name, rank, icon, count, debuffType, duration, expires, caster, isStealable = UnitBuff(unit, i)

			if name then
				if self:IsAuraFiltered(unit, name) and (not self.db[unit].aurasBuffsOnlyDispellable or isStealable) then
					SetBuff(self.buffFrame[unit][sidx], unit, i)
					sidx = sidx + 1
				end
			else
				break
			end
		end

		-- hide unused aura frames
		for i = sidx, 40 do
			self.buffFrame[unit][i]:Hide()
		end
	end

	if self.debuffFrame[unit] and self.db[unit].aurasDebuffs then
		local debuffFrame

		if self.db[unit].aurasBuffs and self.db[unit].aurasDebuffsWithBuffs then
			debuffFrame = self.buffFrame[unit]
		else
			debuffFrame = self.debuffFrame[unit]
			sidx = 1
		end

		-- debuff frame
		for i = 1, 40 do
			local name, rank, icon, count, debuffType, duration, expires, caster, isStealable = UnitDebuff(unit, i)

			if name then
				if self:IsAuraFiltered(unit, name) and (not self.db[unit].aurasDebuffsOnlyDispellable or isStealable) then
					SetDebuff(debuffFrame[sidx], unit, i)
					debuffFrame[sidx]:Show()
					sidx = sidx + 1
				end
			else
				break
			end
		end

		-- hide unused aura frames
		for i = sidx, 40 do
			debuffFrame[i]:Hide()
		end
	end
end

local function CreateAuraFrame(name, parent)
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
	frame.count:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.base.globalFont), 10, "OUTLINE")
	frame.count:SetTextColor(1, 1, 1, 1)
	frame.count:SetShadowColor(0, 0, 0, 1.0)
	frame.count:SetShadowOffset(0.50, -0.50)
	frame.count:SetHeight(1)
	frame.count:SetWidth(1)
	frame.count:SetAllPoints()
	frame.count:SetJustifyV("BOTTOM")
	frame.count:SetJustifyH("RIGHT")

	return frame
end

local function UpdateAuraFrame(frame, size, crop)
	frame:SetSize(size, size)
	frame.icon:SetSize(size - 1.5, size - 1.5)
	if crop then
		local n = 5
		frame.icon:SetTexCoord(n / 64, 1 - n / 64, n / 64, 1 - n / 64)
	else
		frame.icon:SetTexCoord(0, 1, 0, 1)
	end
	frame.border:SetSize(size, size)
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
		end
	end

	-- create debuff frame
	if (not self.debuffFrame[unit] and self.db[unit].aurasDebuffs) then
		self.debuffFrame[unit] = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. "DebuffFrame" .. unit, button)
		self.debuffFrame[unit]:EnableMouse(false)

		for i = 1, 40 do
			self.debuffFrame[unit][i] = CreateAuraFrame("GladiusEx" .. self:GetName() .. "DebuffFrameIcon" .. i .. unit, self.debuffFrame[unit])
			self.debuffFrame[unit][i]:Hide()
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
	aurasBuffsCrop)

	-- anchor point
	local parent = GladiusEx:GetAttachFrame(unit, aurasBuffsAttachTo)
	auraFrame:ClearAllPoints()
	auraFrame:SetPoint(aurasBuffsAnchor, parent, aurasBuffsRelativePoint, aurasBuffsOffsetX, aurasBuffsOffsetY)

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
		UpdateAuraFrame(auraFrame[i], aurasBuffsSize, aurasBuffsCrop)
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
			self.db[unit].aurasBuffsCrop)
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
			self.db[unit].aurasDebuffsCrop)
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
								sep3 = {
									type = "description",
									name = "",
									width = "full",
									order = 7,
								},
								aurasBuffsGrow = {
									type = "select",
									name = L["Column grow"],
									desc = L["Grow direction of the icons"],
									values = function() return {
										["UPLEFT"] = L["Up left"],
										["UPRIGHT"] = L["Up right"],
										["DOWNLEFT"] = L["Down left"],
										["DOWNRIGHT"] = L["Down right"],
									}
									end,
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 10,
								},
								sep = {
									type = "description",
									name = "",
									width = "full",
									order = 13,
								},
								aurasBuffsCrop = {
									type = "toggle",
									name = L["Crop borders"],
									desc = L["Toggle if the icon borders should be cropped or not"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
									hidden = function() return not GladiusEx.db.base.advancedOptions end,
									order = 14,
								},
								aurasBuffsOnlyDispellable = {
									type = "toggle",
									width = "full",
									name = L["Show only dispellable"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 14,
								},
								aurasBuffsOnlyMine = {
									type = "toggle",
									width = "full",
									name = L["Show only mine"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 14.1,
								},
								aurasBuffsPerColumn = {
									type = "range",
									name = L["Icons per column"],
									desc = L["Number of aura icons per column"],
									min = 1, max = 50, step = 1,
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 15,
								},
								aurasBuffsMax = {
									type = "range",
									name = L["Icons max"],
									desc = L["Number of max buffs"],
									min = 1, max = 40, step = 1,
									disabled = function() return not self:IsUnitEnabled(unit) end,
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
									disabled = function() return not self:IsUnitEnabled(unit) end,
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
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 15,
								},
								aurasBuffsSpacingX = {
									type = "range",
									name = L["Horizontal spacing"],
									desc = L["Horizontal spacing of the icons"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
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
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 3,
							args = {
								aurasBuffsAttachTo = {
									type = "select",
									name = L["Attach to"],
									desc = L["Attach to the given frame"],
									values = function() return self:GetOtherAttachPoints(unit) end,
									disabled = function() return not self:IsUnitEnabled(unit) end,
									width = "double",
									order = 5,
								},
								sep = {
									type = "description",
									name = "",
									width = "full",
									order = 7,
								},
								aurasBuffsAnchor = {
									type = "select",
									name = L["Anchor"],
									desc = L["Anchor of the frame"],
									values = function() return GladiusEx:GetPositions() end,
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 10,
								},
								aurasBuffsRelativePoint = {
									type = "select",
									name = L["Relative point"],
									desc = L["Relative point of the frame"],
									values = function() return GladiusEx:GetPositions() end,
									disabled = function() return not self:IsUnitEnabled(unit) end,
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
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 20,
								},
								aurasBuffsOffsetY = {
									type = "range",
									name = L["Offset Y"],
									desc = L["Y offset of the frame"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
									softMin = -100, softMax = 100, bigStep = 1,
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
								sep3 = {
									type = "description",
									name = "",
									width = "full",
									order = 7,
								},
								aurasDebuffsGrow = {
									type = "select",
									name = L["Column grow"],
									desc = L["Grow direction"],
									values = function() return {
										["UPLEFT"] = L["Up left"],
										["UPRIGHT"] = L["Up right"],
										["DOWNLEFT"] = L["Down left"],
										["DOWNRIGHT"] = L["Down right"],
									}
									end,
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 10,
								},
								sep = {
									type = "description",
									name = "",
									width = "full",
									order = 13,
								},
								aurasDebuffsCrop = {
									type = "toggle",
									name = L["Crop borders"],
									desc = L["Toggle if the icon borders should be cropped or not"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
									hidden = function() return not GladiusEx.db.base.advancedOptions end,
									order = 14,
								},
								aurasDebuffsOnlyDispellable = {
									type = "toggle",
									width = "full",
									name = L["Show only dispellable"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 14,
								},
								aurasDebuffsOnlyMine = {
									type = "toggle",
									width = "full",
									name = L["Show only mine"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 14.1,
								},
								aurasDebuffsPerColumn = {
									type = "range",
									name = L["Icons per column"],
									desc = L["Number of icons per column"],
									min = 1, max = 50, step = 1,
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 15,
								},
								aurasDebuffsMax = {
									type = "range",
									name = L["Icons max"],
									desc = L["Number of max icons"],
									min = 1, max = 40, step = 1,
									disabled = function() return not self:IsUnitEnabled(unit) end,
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
									disabled = function() return not self:IsUnitEnabled(unit) end,
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
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 15,
								},
								aurasDebuffsSpacingX = {
									type = "range",
									name = L["Horizontal spacing"],
									desc = L["Horizontal spacing of the icons"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
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
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 3,
							args = {
								aurasDebuffsAttachTo = {
									type = "select",
									name = L["Attach to"],
									desc = L["Attach to the given frame"],
									values = function() return self:GetOtherAttachPoints(unit) end,
									disabled = function() return not self:IsUnitEnabled(unit) end,
									width = "double",
									order = 5,
								},
								sep = {
									type = "description",
									name = "",
									width = "full",
									order = 7,
								},
								aurasDebuffsAnchor = {
									type = "select",
									name = L["Anchor"],
									desc = L["Anchor of the frame"],
									values = function() return GladiusEx:GetPositions() end,
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 10,
								},
								aurasDebuffsRelativePoint = {
									type = "select",
									name = L["Relative point"],
									desc = L["Relative point of the frame"],
									values = function() return GladiusEx:GetPositions() end,
									disabled = function() return not self:IsUnitEnabled(unit) end,
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
									disabled = function() return not self:IsUnitEnabled(unit) end,
									order = 20,
								},
								aurasDebuffsOffsetY = {
									type = "range",
									name = L["Offset Y"],
									desc = L["Y offset"],
									disabled = function() return not self:IsUnitEnabled(unit) end,
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
				newAura = {
					type = "group",
					name = L["Add new aura filter"],
					desc = L["Add new aura filter"],
					inline = true,
					order = 2,
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
							name = L["Add new aura"],
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
				disabled = function() return not self:IsUnitEnabled(unit) end,
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
				disabled = function() return not self:IsUnitEnabled(unit) end,
				order = 3,
			},
		},
	}
end
