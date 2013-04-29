local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM

-- global functions
local strfind = string.find
local pairs = pairs
local UnitAura, UnitBuff, UnitDebuff, GetSpellInfo = UnitAura, UnitBuff, UnitDebuff, GetSpellInfo
local ceil = math.ceil

local Auras = GladiusEx:NewGladiusExModule("Auras", false, {
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
})

function Auras:OnEnable()
	self:RegisterEvent("UNIT_AURA", "UpdateUnitAuras")

	LSM = GladiusEx.LSM

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

function Auras:GetAttachTo()
	return self.db.aurasAttachTo
end

function Auras:GetModuleAttachPoints()
	return {
		["Buffs"] = L["Buffs"],
		["Debuffs"] = L["Debuffs"],
	}
end

function Auras:GetAttachFrame(unit, point)
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

function Auras:UpdateUnitAuras(event, unit)
	local color
	local sidx = 1

	if self.buffFrame[unit] and self.db.aurasBuffs then
		-- buff frame
		for i = 1, 40 do
			local name, rank, icon, count, debuffType, duration, expires, caster, isStealable = UnitBuff(unit, i)

			if name then
				if not self.db.aurasBuffsOnlyDispellable or isStealable then
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

	if self.debuffFrame[unit] and self.db.aurasDebuffs then
		local debuffFrame

		if self.db.aurasBuffs and self.db.aurasDebuffsWithBuffs then
			debuffFrame = self.buffFrame[unit]
		else
			debuffFrame = self.debuffFrame[unit]
			sidx = 1
		end

		-- debuff frame
		for i = 1, 40 do
			local name, rank, icon, count, debuffType, duration, expires, caster, isStealable = UnitDebuff(unit, i)

			if name then
				if not self.db.aurasDebuffsOnlyDispellable or isStealable then
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
	frame.count:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.globalFont), 10, "OUTLINE")
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
		frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	else
		frame.icon:SetTexCoord(0, 1, 0, 1)
	end
	frame.border:SetSize(size, size)
end

function Auras:CreateFrame(unit)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	-- create buff frame
	if (not self.buffFrame[unit] and self.db.aurasBuffs) then
		self.buffFrame[unit] = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. "BuffFrame" .. unit, button)
		self.buffFrame[unit]:EnableMouse(false)

		for i = 1, 40 do
			self.buffFrame[unit][i] = CreateAuraFrame("GladiusEx" .. self:GetName() .. "BuffFrameIcon" .. i .. unit, self.buffFrame[unit])
			self.buffFrame[unit][i]:Hide()
		end
	end

	-- create debuff frame
	if (not self.debuffFrame[unit] and self.db.aurasDebuffs) then
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
		if (aurasBuffsMax >= i) then
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
	if (not self.buffFrame[unit] or not self.debuffFrame[unit]) then
		self:CreateFrame(unit)
	end

	-- update buff frame
	if (self.db.aurasBuffs) then
		UpdateAuraGroup(self.buffFrame[unit], unit,
			self.db.aurasBuffsAttachTo,
			self.db.aurasBuffsAnchor,
			self.db.aurasBuffsRelativePoint,
			self.db.aurasBuffsOffsetX,
			self.db.aurasBuffsOffsetY,
			self.db.aurasBuffsPerColumn,
			self.db.aurasBuffsGrow,
			self.db.aurasBuffsSize,
			self.db.aurasBuffsSpacingX,
			self.db.aurasBuffsSpacingY,
			self.db.aurasBuffsMax,
			self.db.aurasBuffsCrop)

		-- hide
		self.buffFrame[unit]:Hide()
	end

	-- update debuff frame
	if (self.db.aurasDebuffs) then
		UpdateAuraGroup(self.debuffFrame[unit], unit,
			self.db.aurasDebuffsAttachTo,
			self.db.aurasDebuffsAnchor,
			self.db.aurasDebuffsRelativePoint,
			self.db.aurasDebuffsOffsetX,
			self.db.aurasDebuffsOffsetY,
			self.db.aurasDebuffsPerColumn,
			self.db.aurasDebuffsGrow,
			self.db.aurasDebuffsSize,
			self.db.aurasDebuffsSpacingX,
			self.db.aurasDebuffsSpacingY,
			self.db.aurasDebuffsMax,
			self.db.aurasDebuffsCrop)

		-- hide
		self.debuffFrame[unit]:Hide()
	end

	-- event
	if (not self.db.aurasDebuffs and not self.db.aurasBuffs) then
		self:UnregisterAllEvents()
	else
		self:RegisterEvent("UNIT_AURA", "UpdateUnitAuras")
	end
end

function Auras:Show(unit)
	-- show buff frame
	if self.db.aurasBuffs and self.buffFrame[unit] then
		self.buffFrame[unit]:Show()
	end

	-- show debuff frame
	if self.db.aurasDebuffs and self.debuffFrame[unit] and not self.db.aurasDebuffsWithBuffs then
		self.debuffFrame[unit]:Show()
	end

	self:UpdateUnitAuras("Show", unit)
end

function Auras:Reset(unit)
	if (self.buffFrame[unit]) then
		-- hide buff frame
		self.buffFrame[unit]:Hide()

		for i = 1, 40 do
			self.buffFrame[unit][i]:Hide()
		end
	end

	if (self.debuffFrame[unit]) then
		-- hide debuff frame
		self.debuffFrame[unit]:Hide()

		for i = 1, 40 do
			self.debuffFrame[unit][i]:Hide()
		end
	end
end

function Auras:Test(unit)
	-- test buff frame
	if (self.buffFrame[unit]) then
		for i = 1, self.db.aurasBuffsMax do
			self.buffFrame[unit][i].icon:SetTexture(GetSpellTexture(21562))
			self.buffFrame[unit][i]:Show()
		end
	end

	-- test debuff frame
	if (self.debuffFrame[unit]) then
		for i = 1, self.db.aurasDebuffsMax do
			self.debuffFrame[unit][i].icon:SetTexture(GetSpellTexture(589))
			self.debuffFrame[unit][i]:Show()
		end
	end
end

function Auras:GetOptions()
	local options = {
		buffs = {
			type = "group",
			name = L["Buffs"],
			childGroups = "tab",
			order = 1,
			args = {
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
								aurasBuffs = {
									type = "toggle",
									name = L["Buffs"],
									desc = L["Toggle aura buffs"],
									disabled = function() return not self:IsEnabled() end,
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
									disabled = function() return not self:IsEnabled() end,
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
									disabled = function() return not self:IsEnabled() end,
									hidden = function() return not GladiusEx.db.advancedOptions end,
									order = 14,
								},
								aurasBuffsOnlyDispellable = {
									type = "toggle",
									width = "full",
									name = L["Show only dispellable"],
									disabled = function() return not self:IsEnabled() end,
									order = 14,
								},
								aurasBuffsOnlyMine = {
									type = "toggle",
									width = "full",
									name = L["Show only mine"],
									disabled = function() return not self:IsEnabled() end,
									order = 14.1,
								},
								aurasBuffsPerColumn = {
									type = "range",
									name = L["Icons per column"],
									desc = L["Number of aura icons per column"],
									min = 1, max = 50, step = 1,
									disabled = function() return not self:IsEnabled() end,
									order = 15,
								},
								aurasBuffsMax = {
									type = "range",
									name = L["Icons max"],
									desc = L["Number of max buffs"],
									min = 1, max = 40, step = 1,
									disabled = function() return not self:IsEnabled() end,
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
									disabled = function() return not self:IsEnabled() end,
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
									disabled = function() return not self:IsEnabled() end,
									order = 15,
								},
								aurasBuffsSpacingX = {
									type = "range",
									name = L["Horizontal spacing"],
									desc = L["Horizontal spacing of the icons"],
									disabled = function() return not self:IsEnabled() end,
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
							hidden = function() return not GladiusEx.db.advancedOptions end,
							order = 3,
							args = {
								aurasBuffsAttachTo = {
									type = "select",
									name = L["Attach to"],
									desc = L["Attach to the given frame"],
									values = function() return Auras:GetAttachPoints() end,
									disabled = function() return not self:IsEnabled() end,
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
									disabled = function() return not self:IsEnabled() end,
									order = 10,
								},
								aurasBuffsRelativePoint = {
									type = "select",
									name = L["Relative point"],
									desc = L["Relative point of the frame"],
									values = function() return GladiusEx:GetPositions() end,
									disabled = function() return not self:IsEnabled() end,
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
									min = -100, max = 100, step = 1,
									disabled = function() return not self:IsEnabled() end,
									order = 20,
								},
								aurasBuffsOffsetY = {
									type = "range",
									name = L["Offset Y"],
									desc = L["Y offset of the frame"],
									disabled = function() return not self:IsEnabled() end,
									min = -50, max = 50, step = 1,
									order = 25,
								},
							},
						},
					},
				},
				--[[filter = {
					type = "group",
					name = L["Filter"],
					childGroups = "tree",
					hidden = function() return not GladiusEx.db.advancedOptions end,
					order = 2,
					args = {
						whitelist = {
							type = "group",
							name = L["Whitelist"],
							order = 1,
							args = {
							},
						},
						blacklist = {
							type = "group",
							name = L["Blacklist"],
							order = 2,
							args = {
							},
						},
						filterFunction = {
							type = "group",
							name = L["Filter function"],
							order = 3,
							args = {
							},
						},
					},
				},]]
			},
		},
		debuffs = {
			type = "group",
			name = L["Debuffs"],
			childGroups = "tab",
			order = 2,
			args = {
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
								aurasDebuffs = {
									type = "toggle",
									name = L["Debuffs"],
									desc = L["Toggle aura debuffs"],
									disabled = function() return not self:IsEnabled() end,
									order = 5,
								},
								aurasDebuffsWithBuffs = {
									type = "toggle",
									name = L["Debuffs with buffs"],
									width = "full",
									disabled = function() return not self:IsEnabled() or not self.db.aurasBuffs end,
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
									disabled = function() return not self:IsEnabled() end,
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
									disabled = function() return not self:IsEnabled() end,
									hidden = function() return not GladiusEx.db.advancedOptions end,
									order = 14,
								},
								aurasDebuffsOnlyDispellable = {
									type = "toggle",
									width = "full",
									name = L["Show only dispellable"],
									disabled = function() return not self:IsEnabled() end,
									order = 14,
								},
								aurasDebuffsOnlyMine = {
									type = "toggle",
									width = "full",
									name = L["Show only mine"],
									disabled = function() return not self:IsEnabled() end,
									order = 14.1,
								},
								aurasDebuffsPerColumn = {
									type = "range",
									name = L["Icons per column"],
									desc = L["Number of icons per column"],
									min = 1, max = 50, step = 1,
									disabled = function() return not self:IsEnabled() end,
									order = 15,
								},
								aurasDebuffsMax = {
									type = "range",
									name = L["Icons max"],
									desc = L["Number of max icons"],
									min = 1, max = 40, step = 1,
									disabled = function() return not self:IsEnabled() end,
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
									disabled = function() return not self:IsEnabled() end,
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
									disabled = function() return not self:IsEnabled() end,
									order = 15,
								},
								aurasDebuffsSpacingX = {
									type = "range",
									name = L["Horizontal spacing"],
									desc = L["Horizontal spacing of the icons"],
									disabled = function() return not self:IsEnabled() end,
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
							hidden = function() return not GladiusEx.db.advancedOptions end,
							order = 3,
							args = {
								aurasDebuffsAttachTo = {
									type = "select",
									name = L["Attach to"],
									desc = L["Attach to the given frame"],
									values = function() return Auras:GetAttachPoints() end,
									disabled = function() return not self:IsEnabled() end,
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
									disabled = function() return not self:IsEnabled() end,
									order = 10,
								},
								aurasDebuffsRelativePoint = {
									type = "select",
									name = L["Relative point"],
									desc = L["Relative point of the frame"],
									values = function() return GladiusEx:GetPositions() end,
									disabled = function() return not self:IsEnabled() end,
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
									min = -100, max = 100, step = 1,
									disabled = function() return not self:IsEnabled() end,
									order = 20,
								},
								aurasDebuffsOffsetY = {
									type = "range",
									name = L["Offset Y"],
									desc = L["Y offset"],
									disabled = function() return not self:IsEnabled() end,
									min = -50, max = 50, step = 1,
									order = 25,
								},
							},
						},
					},
				},
				--[[filter = {
					type = "group",
					name = L["Filter"],
					childGroups = "tree",
					hidden = function() return not GladiusEx.db.advancedOptions end,
					order = 2,
					args = {
						whitelist = {
							type = "group",
							name = L["Whitelist"],
							order = 1,
							args = {
							},
						},
						blacklist = {
							type = "group",
							name = L["Blacklist"],
							order = 2,
							args = {
							},
						},
						filterFunction = {
							type = "group",
							name = L["Filter function"],
							order = 3,
							args = {
							},
						},
					},
				},]]
			},
		},
	}

	return options
end
