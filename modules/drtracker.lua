local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM
local DRData = LibStub("DRData-1.0")

-- global functions
local strfind = string.find
local pairs, unpack = pairs, unpack
local GetTime, GetSpellTexture, UnitGUID = GetTime, GetSpellTexture, UnitGUID

local DRTracker = GladiusEx:NewGladiusExModule("DRTracker", false, {
		drTrackerAttachTo = "ClassIcon",
		drTrackerAnchor = "TOPRIGHT",
		drTrackerRelativePoint = "TOPLEFT",
		drTrackerGrowDirection = "LEFT",
		drTrackerAdjustSize = false,
		drTrackerMargin = 2,
		drTrackerSize = 40,
		drTrackerCrop = false,
		drTrackerOffsetX = -2,
		drTrackerOffsetY = 0,
		drTrackerFrameLevel = 2,
		drTrackerGloss = false,
		drTrackerGlossColor = { r = 1, g = 1, b = 1, a = 0.4 },
		drTrackerCooldown = true,
		drTrackerCooldownReverse = false,
		drFontSize = 18,
		drFontColor = { r = 0, g = 1, b = 0, a = 1 },
		drCategories = {},
	}, {
		drTrackerAttachTo = "ClassIcon",
		drTrackerAnchor = "TOPLEFT",
		drTrackerRelativePoint = "TOPRIGHT",
		drTrackerGrowDirection = "RIGHT",
		drTrackerAdjustSize = false,
		drTrackerMargin = 2,
		drTrackerSize = 40,
		drTrackerCrop = false,
		drTrackerOffsetX = 2,
		drTrackerOffsetY = 0,
		drTrackerFrameLevel = 2,
		drTrackerGloss = false,
		drTrackerGlossColor = { r = 1, g = 1, b = 1, a = 0.4 },
		drTrackerCooldown = true,
		drTrackerCooldownReverse = false,
		drFontSize = 18,
		drFontColor = { r = 0, g = 1, b = 0, a = 1 },
		drCategories = {},
	})

local drTexts = {
	[1] =    { "½", 0, 1, 0 },
	[0.5] =  { "¼", 1, 0.65,0 },
	[0.25] = { "Ø", 1, 0, 0 },
	[0] =    { "Ø", 1, 0, 0 },
}

function DRTracker:OnEnable()
	LSM = GladiusEx.LSM

	if not self.frame then
		self.frame = {}
	end

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function DRTracker:OnDisable()
	self:UnregisterAllEvents()

	for _, frame in pairs(self.frame) do
		frame:Hide()
	end
end

function DRTracker:GetAttachTo(unit)
	return self.db[unit].drTrackerAttachTo
end

function DRTracker:GetModuleAttachPoints()
	return {
		["DRTracker"] = L["DRTracker"],
	}
end

function DRTracker:GetAttachFrame(unit)
	if not self.frame[unit] then
		self:CreateFrame(unit)
	end

	return self.frame[unit]
end

function DRTracker:CreateIcon(unit, drCat)
	local f = CreateFrame("CheckButton", "GladiusEx" .. self:GetName() .. "FrameCat" .. drCat .. unit, self.frame[unit], "ActionButtonTemplate")
	f.texture = _G[f:GetName().."Icon"]
	f.normalTexture = _G[f:GetName().."NormalTexture"]
	f.cooldown = _G[f:GetName().."Cooldown"]

	self.frame[unit].tracker[drCat] = f
end

function DRTracker:UpdateIcon(unit, drCat)
	local tracked = self.frame[unit].tracker[drCat]

	tracked:EnableMouse(false)
	tracked.reset_time = 0

	tracked:SetWidth(self.frame[unit]:GetHeight())
	tracked:SetHeight(self.frame[unit]:GetHeight())

	tracked:SetNormalTexture([[Interface\AddOns\GladiusEx\images\gloss]])
	tracked.normalTexture:SetVertexColor(self.db[unit].drTrackerGlossColor.r, self.db[unit].drTrackerGlossColor.g,
		self.db[unit].drTrackerGlossColor.b, self.db[unit].drTrackerGloss and self.db[unit].drTrackerGlossColor.a or 0)

	-- cooldown
	tracked.cooldown:SetReverse(self.db[unit].drTrackerCooldownReverse)
	if self.db[unit].drTrackerCooldown then
		tracked.cooldown:Show()
	else
		tracked.cooldown:Hide()
	end

	-- text
	tracked.text = tracked:CreateFontString(nil, "OVERLAY")
	tracked.text:SetDrawLayer("OVERLAY")
	tracked.text:SetJustifyH("RIGHT")
	tracked.text:SetPoint("BOTTOMRIGHT", tracked, -2, 0)
	tracked.text:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.base.globalFont), self.db[unit].drFontSize, "OUTLINE")
	tracked.text:SetTextColor(self.db[unit].drFontColor.r, self.db[unit].drFontColor.g, self.db[unit].drFontColor.b, self.db[unit].drFontColor.a)

	-- style action button
	tracked.normalTexture:SetHeight(self.frame[unit]:GetHeight() + self.frame[unit]:GetHeight() * 0.4)
	tracked.normalTexture:SetWidth(self.frame[unit]:GetWidth() + self.frame[unit]:GetWidth() * 0.4)

	tracked.normalTexture:ClearAllPoints()
	tracked.normalTexture:SetPoint("CENTER", 0, 0)

	tracked.texture:ClearAllPoints()
	tracked.texture:SetPoint("TOPLEFT", tracked, "TOPLEFT")
	tracked.texture:SetPoint("BOTTOMRIGHT", tracked, "BOTTOMRIGHT")
	if self.db[unit].drTrackerCrop then
		local n = 5
		tracked.texture:SetTexCoord(n / 64, 1 - n / 64, n / 64, 1 - n / 64)
	else
		tracked.texture:SetTexCoord(0, 1, 0, 1)
	end
end

function DRTracker:DRFaded(unit, spellID)
	local drCat = DRData:GetSpellCategory(spellID)
	if self.db[unit].drCategories[drCat] == false then return end

	if not self.frame[unit].tracker[drCat] then
		self:CreateIcon(unit, drCat)
		self:UpdateIcon(unit, drCat)
	end

	local tracked = self.frame[unit].tracker[drCat]

	if tracked.active then
		tracked.diminished = DRData:NextDR(tracked.diminished)
	else
		tracked.active = true
		tracked.diminished = 1
	end

	local time_left = DRData:GetResetTime()
	tracked.reset_time = time_left + GetTime()

	local text, r, g, b = unpack(drTexts[tracked.diminished])
	tracked.text:SetText(text)
	tracked.text:SetTextColor(r,g,b)
	tracked.texture:SetTexture(GetSpellTexture(spellID))

	if self.db[unit].drTrackerCooldown then
		tracked.cooldown:SetCooldown(GetTime(), time_left)
	end

	tracked:SetScript("OnUpdate", function(f, elapsed)
		if GetTime() >= f.reset_time then
			tracked.active = false
			self:SortIcons(unit)
			f:SetScript("OnUpdate", nil)
		end
	end)

	tracked:Show()
	self:SortIcons(unit)
end

function DRTracker:SortIcons(unit)
	local lastFrame

	for cat, frame in pairs(self.frame[unit].tracker) do
		frame:ClearAllPoints()

		if frame.active then
			if not lastFrame then
				-- frame:SetPoint(self.db[unit].drTrackerAnchor, self.frame[unit], self.db[unit].drTrackerRelativePoint, self.db[unit].drTrackerOffsetX, self.db[unit].drTrackerOffsetY)
				frame:SetPoint("TOPLEFT", self.frame[unit])
			elseif self.db[unit].drTrackerGrowDirection == "RIGHT" then
				frame:SetPoint("TOPLEFT", lastFrame, "TOPRIGHT", self.db[unit].drTrackerMargin, 0)
			elseif self.db[unit].drTrackerGrowDirection == "LEFT" then
				frame:SetPoint("TOPRIGHT", lastFrame, "TOPLEFT", -self.db[unit].drTrackerMargin, 0)
			elseif self.db[unit].drTrackerGrowDirection == "UP" then
				frame:SetPoint("BOTTOMLEFT", lastFrame, "TOPLEFT", 0, self.db[unit].drTrackerMargin)
			elseif self.db[unit].drTrackerGrowDirection == "DOWN" then
				frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -self.db[unit].drTrackerMargin)
			end

			lastFrame = frame

			frame:Show()
		else
			frame:Hide()
		end
	end
end

function DRTracker:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, auraType)
	-- Enemy had a debuff refreshed before it faded
	-- Buff or debuff faded from an enemy
	if eventType == "SPELL_AURA_REFRESH" or eventType == "SPELL_AURA_REMOVED" then
		if auraType == "DEBUFF" and DRData:GetSpellCategory(spellID) then
			local unit = GladiusEx:GetUnitIdByGUID(destGUID)
			if unit and self.frame[unit] then
				self:DRFaded(unit, spellID)
			end
		end
	end
end

function DRTracker:CreateFrame(unit)
	local button = GladiusEx.buttons[unit]
	if not button then return end

	-- create frame
	self.frame[unit] = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. "Frame" .. unit, button, "ActionButtonTemplate")
end

function DRTracker:Update(unit)
	-- create frame
	if not self.frame[unit] then
		self:CreateFrame(unit)
	end

	-- update frame
	self.frame[unit]:ClearAllPoints()

	-- anchor point
	local parent = GladiusEx:GetAttachFrame(unit, self.db[unit].drTrackerAttachTo)
	self.frame[unit]:SetPoint(self.db[unit].drTrackerAnchor, parent, self.db[unit].drTrackerRelativePoint, self.db[unit].drTrackerOffsetX, self.db[unit].drTrackerOffsetY)

	-- frame level
	self.frame[unit]:SetFrameLevel(self.db[unit].drTrackerFrameLevel)

	if self.db[unit].drTrackerAdjustSize then
		if self:GetAttachTo(unit) == "Frame" then
			self.frame[unit]:SetWidth(GladiusEx.buttons[unit].frameHeight)
			self.frame[unit]:SetHeight(GladiusEx.buttons[unit].frameHeight)
		else
			local f = GladiusEx:GetAttachFrame(unit, self.db[unit].drTrackerAttachTo)
			self.frame[unit]:SetWidth(f and f:GetHeight() or 1)
			self.frame[unit]:SetHeight(f and f:GetHeight() or 1)
		end
	else
		self.frame[unit]:SetWidth(self.db[unit].drTrackerSize)
		self.frame[unit]:SetHeight(self.db[unit].drTrackerSize)
	end

	-- update icons
	if (not self.frame[unit].tracker) then
		self.frame[unit].tracker = {}
	else
		for cat, frame in pairs(self.frame[unit].tracker) do
			frame:SetWidth(self.frame[unit]:GetHeight())
			frame:SetHeight(self.frame[unit]:GetHeight())

			frame.normalTexture:SetHeight(self.frame[unit]:GetHeight() + self.frame[unit]:GetHeight() * 0.4)
			frame.normalTexture:SetWidth(self.frame[unit]:GetWidth() + self.frame[unit]:GetWidth() * 0.4)

			self:UpdateIcon(unit, cat)
		end
		self:SortIcons(unit)
	end

	-- hide
	self.frame[unit]:Hide()
end

function DRTracker:Show(unit)
	-- show frame
	self.frame[unit]:Show()
end

function DRTracker:Reset(unit)
	if not self.frame[unit] then return end

	-- hide icons
	for _, frame in pairs(self.frame[unit].tracker) do
		frame.active = false
		frame.diminished = 1
		frame:SetScript("OnUpdate", nil)
		frame:Hide()
	end

	-- hide
	self.frame[unit]:Hide()
end

function DRTracker:Test(unit)
	self:DRFaded(unit, 64058)
	self:DRFaded(unit, 118)
	self:DRFaded(unit, 118)

	self:DRFaded(unit, 33786)
	self:DRFaded(unit, 33786)
	self:DRFaded(unit, 33786)
end

function DRTracker:GetOptions(unit)
	local options = {
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
						drTrackerGrowDirection = {
							type = "select",
							name = L["Grow direction"],
							values = {
								["LEFT"]  = L["Left"],
								["RIGHT"] = L["Right"],
								["UP"]    = L["Up"],
								["DOWN"]  = L["Down"],
							},
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 1,
						},
						sep2 = {
							type = "description",
							name = "",
							width = "full",
							order = 7,
						},
						drTrackerCooldown = {
							type = "toggle",
							name = L["Cooldown spiral"],
							desc = L["Display the cooldown spiral for the drTracker icons"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 10,
						},
						drTrackerCooldownReverse = {
							type = "toggle",
							name = L["Cooldown reverse"],
							desc = L["Invert the dark/bright part of the cooldown spiral"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 15,
						},
						drTrackerCrop = {
							type = "toggle",
							name = L["Crop borders"],
							desc = L["Toggle if the icon borders should be cropped or not"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 16,
						},
						sep3 = {
							type = "description",
							name = "",
							width = "full",
							order = 17,
						},
						drTrackerGloss = {
							type = "toggle",
							name = L["Gloss"],
							desc = L["Toggle gloss on the icon"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 25,
						},
						drTrackerGlossColor = {
							type = "color",
							name = L["Gloss color"],
							desc = L["Color of the gloss"],
							get = function(info) return GladiusEx:GetColorOption(self.db[unit], info) end,
							set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db[unit], info, r, g, b, a) end,
							hasAlpha = true,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 30,
						},
						sep4 = {
							type = "description",
							name = "",
							width = "full",
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 33,
						},
						drTrackerFrameLevel = {
							type = "range",
							name = L["Frame level"],
							desc = L["Frame level of the frame"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							min = 1, max = 5, step = 1,
							width = "double",
							order = 35,
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
						drTrackerMargin = {
							type = "range",
							name = L["Spacing"],
							desc = L["Space between the icons"],
							min = 0, max = 100, step = 1,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 5,
						},
						sep = {
							type = "description",
							name = "",
							width = "full",
							order = 6,
						},
						drTrackerAdjustSize = {
							type = "toggle",
							name = L["Adjust size"],
							desc = L["Adjust size to the frame size"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 7,
						},
						drTrackerSize = {
							type = "range",
							name = L["Icon size"],
							desc = L["Size of the icons"],
							min = 10, max = 100, step = 1,
							disabled = function() return self.db[unit].drTrackerAdjustSize or not self:IsUnitEnabled(unit) end,
							order = 10,
						},
					},
				},
				font = {
					type = "group",
					name = L["Font"],
					desc = L["Font settings"],
					inline = true,
					hidden = function() return not GladiusEx.db.base.advancedOptions end,
					order = 3,
					args = {
						drFontColor = {
							type = "color",
							name = L["Text color"],
							desc = L["Text color of the DR text"],
							hasAlpha = true,
							get = function(info) return GladiusEx:GetColorOption(self.db[unit], info) end,
							set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db[unit], info, r, g, b, a) end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 10,
						},
						drFontSize = {
							type = "range",
							name = L["Text size"],
							desc = L["Text size of the DR text"],
							min = 1, max = 20, step = 1,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 15,
						},
					},
				},
				position = {
					type = "group",
					name = L["Position"],
					desc = L["Position settings"],
					inline = true,
					order = 4,
					args = {
						drTrackerAttachTo = {
							type = "select",
							name = L["Attach to"],
							desc = L["Attach drTracker to the given frame"],
							values = function() return self:GetOtherAttachPoints(unit) end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							width = "double",
							order = 5,
						},
						drTrackerPosition = {
							type = "select",
							name = L["Position"],
							desc = L["Position of the drTracker"],
							values = { ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"] },
							get = function() return strfind(self.db[unit].drTrackerAnchor, "RIGHT") and "LEFT" or "RIGHT" end,
							set = function(info, value)
								if value == "LEFT" then
									self.db[unit].drTrackerAnchor = "TOPRIGHT"
									self.db[unit].drTrackerRelativePoint = "TOPLEFT"
								else
									self.db[unit].drTrackerAnchor = "TOPLEFT"
									self.db[unit].drTrackerRelativePoint = "TOPRIGHT"
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
						drTrackerAnchor = {
							type = "select",
							name = L["Anchor"],
							desc = L["Anchor of the frame"],
							values = function() return GladiusEx:GetPositions() end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 10,
						},
						drTrackerRelativePoint = {
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
						drTrackerOffsetX = {
							type = "range",
							name = L["Offset X"],
							desc = L["X offset of the frame"],
							softMin = -100, softMax = 100, bigStep = 1,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 20,
						},
						drTrackerOffsetY = {
							type = "range",
							name = L["Offset Y"],
							desc = L["Y offset of the frame"],
							softMin = -100, softMax = 100, bigStep = 1,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 25,
						},
					},
				},
			},
		},
	}

	options.categories = {
		type = "group",
		name = L["Categories"],
		order = 2,
		args = {
			categories = {
				type = "group",
				name = L["Categories"],
				desc = L["Category settings"],
				inline = true,
				order = 1,
				args = {
				},
			},
		},
	}

	local index = 1
	for key, name in pairs(DRData:GetCategories()) do
		options.categories.args.categories.args[key] = {
			type = "toggle",
			name = name,
			get = function(info)
				if self.db[unit].drCategories[info[#info]] == nil then
					return true
				else
					return self.db[unit].drCategories[info[#info]]
				end
			end,
			set = function(info, value)
				self.db[unit].drCategories[info[#info]] = value
			end,
			disabled = function() return not self:IsUnitEnabled(unit) end,
			order = index * 5,
		}

		index = index + 1
	end

	return options
end
