local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM

local DRData = LibStub("DRData-1.0")

-- global functions
local strfind = string.find
local pairs = pairs
local GetTime = GetTime
local UnitGUID = UnitGUID

local DRTracker = GladiusEx:NewGladiusExModule("DRTracker", false, {
	drTrackerAttachTo = "ClassIcon",
	drTrackerAnchor = "TOPRIGHT",
	drTrackerRelativePoint = "TOPLEFT",
	drTrackerGrowDirection = "DOWN",
	drTrackerAdjustSize = false,
	drTrackerMargin = 0,
	drTrackerSize = 20,
	drTrackerOffsetX = 0,
	drTrackerOffsetY = 0,
	drTrackerFrameLevel = 2,
	drTrackerGloss = true,
	drTrackerGlossColor = { r = 1, g = 1, b = 1, a = 0.4 },
	drTrackerCooldown = false,
	drTrackerCooldownReverse = false,

	drFontSize = 18,
	drFontColor = { r = 0, g = 1, b = 0, a = 1 },

	drCategories = {},
})

function DRTracker:OnInitialize()
	-- init frames
	self.frame = {}
end


function DRTracker:OnEnable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	LSM = GladiusEx.LSM

	if (not self.frame) then
		self.frame = {}
	end
end

function DRTracker:OnDisable()
	self:UnregisterAllEvents()

	for _, frame in pairs(self.frame) do
		frame:SetAlpha(0)
	end
end

function DRTracker:GetAttachTo()
	return GladiusEx.db.drTrackerAttachTo
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

function DRTracker:UpdateIcon(unit, drCat)
	local tracked = self.frame[unit].tracker[drCat]

	tracked:EnableMouse(false)
	tracked.reset = 0

	tracked:SetWidth(self.frame[unit]:GetHeight())
	tracked:SetHeight(self.frame[unit]:GetHeight())

	tracked:SetNormalTexture("Interface\\AddOns\\GladiusEx\\images\\gloss")
	tracked.texture = _G[tracked:GetName().."Icon"]
	tracked.normalTexture = _G[tracked:GetName().."NormalTexture"]
	tracked.cooldown = _G[tracked:GetName().."Cooldown"]

	-- cooldown
	if (GladiusEx.db.drTrackerCooldown) then
		tracked.cooldown:Show()
	else
		tracked.cooldown:Hide()
	end

	tracked.cooldown:SetReverse(GladiusEx.db.drTrackerCooldownReverse)

	tracked.text = tracked:CreateFontString(nil, "OVERLAY")
	tracked.text:SetDrawLayer("OVERLAY")
	tracked.text:SetJustifyH("RIGHT")
	tracked.text:SetPoint("BOTTOMRIGHT", tracked, -2, 0)
	tracked.text:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.globalFont), GladiusEx.db.drFontSize, "OUTLINE")
	tracked.text:SetTextColor(GladiusEx.db.drFontColor.r, GladiusEx.db.drFontColor.g, GladiusEx.db.drFontColor.b, GladiusEx.db.drFontColor.a)

	-- style action button
	tracked.normalTexture:SetHeight(self.frame[unit]:GetHeight() + self.frame[unit]:GetHeight() * 0.4)
	tracked.normalTexture:SetWidth(self.frame[unit]:GetWidth() + self.frame[unit]:GetWidth() * 0.4)

	tracked.normalTexture:ClearAllPoints()
	tracked.normalTexture:SetPoint("CENTER", 0, 0)
	tracked:SetNormalTexture("Interface\\AddOns\\GladiusEx\\images\\gloss")

	tracked.texture:ClearAllPoints()
	tracked.texture:SetPoint("TOPLEFT", tracked, "TOPLEFT")
	tracked.texture:SetPoint("BOTTOMRIGHT", tracked, "BOTTOMRIGHT")
	tracked.texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
end

function DRTracker:DRFaded(unit, spellID)
	local drCat = DRData:GetSpellCategory(spellID)
	if (GladiusEx.db.drCategories[drCat] == false) then return end

	local drTexts = {
		[1] = { "\194\189", 0, 1, 0 },
		[0.5] = { "\194\188", 1, 0.65,0 },
		[0.25] = { "%", 1, 0, 0 },
		[0] = { "%", 1, 0, 0 },
	}

	if (not self.frame[unit].tracker[drCat]) then
		self.frame[unit].tracker[drCat] = CreateFrame("CheckButton", "GladiusEx" .. self:GetName() .. "FrameCat" .. drCat .. unit, self.frame[unit], "ActionButtonTemplate")
		self:UpdateIcon(unit, drCat)
	end

	local tracked = self.frame[unit].tracker[drCat]

	tracked.active = true
	if (tracked and tracked.reset <= GetTime()) then
		tracked.diminished = 1
	else
		tracked.diminished = DRData:NextDR(tracked.diminished)
	end

	if (GladiusEx:IsTesting() and tracked.diminished == 0) then
		tracked.diminished = 1
	end

	tracked.timeLeft = DRData:GetResetTime()
	tracked.reset = tracked.timeLeft + GetTime()

	local text, r, g, b = unpack(drTexts[tracked.diminished])
	tracked.text:SetText(text)
	tracked.text:SetTextColor(r,g,b)

	tracked.texture:SetTexture(GetSpellTexture(spellID))
	tracked.cooldown:SetCooldown(GetTime(), tracked.timeLeft)


	-- todo: this is so retarded i don't even have words for it
	tracked:SetScript("OnUpdate", function(f, elapsed)
		f.timeLeft = f.timeLeft - elapsed
		if (f.timeLeft <= 0) then
			if (GladiusEx:IsTesting()) then return end

			f.active = false

			-- position icons
			self:SortIcons(unit)
		end
	end)

	tracked:SetAlpha(1)
	self:SortIcons(unit)
end

function DRTracker:SortIcons(unit)
	local lastFrame

	for cat, frame in pairs(self.frame[unit].tracker) do
		frame:ClearAllPoints()
		frame:SetAlpha(0)

		if (frame.active) then
			if not lastFrame then
				-- frame:SetPoint(GladiusEx.db.drTrackerAnchor, self.frame[unit], GladiusEx.db.drTrackerRelativePoint, GladiusEx.db.drTrackerOffsetX, GladiusEx.db.drTrackerOffsetY)
				frame:SetPoint("TOPLEFT", self.frame[unit])
			elseif GladiusEx.db.drTrackerGrowDirection == "RIGHT" then
				frame:SetPoint("TOPLEFT", lastFrame, "TOPRIGHT", GladiusEx.db.drTrackerMargin, 0)
			elseif GladiusEx.db.drTrackerGrowDirection == "LEFT" then
				frame:SetPoint("TOPRIGHT", lastFrame, "TOPLEFT", -GladiusEx.db.drTrackerMargin, 0)
			elseif GladiusEx.db.drTrackerGrowDirection == "UP" then
				frame:SetPoint("BOTTOMLEFT", lastFrame, "TOPLEFT", 0, GladiusEx.db.drTrackerMargin)
			elseif GladiusEx.db.drTrackerGrowDirection == "DOWN" then
				frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -GladiusEx.db.drTrackerMargin)
			end

			lastFrame = frame

			frame:SetAlpha(1)
		end
	end
end

function DRTracker:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, auraType)
	local unit
	for u, _ in pairs(GladiusEx.buttons) do
		if (UnitGUID(u) == destGUID) then
			unit = u
		end
	end
	if (not unit) then return end

	-- Enemy had a debuff refreshed before it faded, so fade + gain it quickly
	if (eventType == "SPELL_AURA_REFRESH") then
		if (auraType == "DEBUFF" and DRData:GetSpellCategory(spellID)) then
			self:DRFaded(unit, spellID)
		end
	-- Buff or debuff faded from an enemy
	elseif (eventType == "SPELL_AURA_REMOVED") then
		if (auraType == "DEBUFF" and DRData:GetSpellCategory(spellID)) then
			self:DRFaded(unit, spellID)
		end
	end
end

function DRTracker:CreateFrame(unit)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	-- create frame
	self.frame[unit] = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. "Frame" .. unit, button, "ActionButtonTemplate")
end

function DRTracker:Update(unit)
	-- create frame
	if (not self.frame[unit]) then
		self:CreateFrame(unit)
	end

	-- update frame
	self.frame[unit]:ClearAllPoints()

	-- anchor point
	local parent = GladiusEx:GetAttachFrame(unit, GladiusEx.db.drTrackerAttachTo)
	self.frame[unit]:SetPoint(GladiusEx.db.drTrackerAnchor, parent, GladiusEx.db.drTrackerRelativePoint, GladiusEx.db.drTrackerOffsetX, GladiusEx.db.drTrackerOffsetY)

	-- frame level
	self.frame[unit]:SetFrameLevel(GladiusEx.db.drTrackerFrameLevel)

	if (GladiusEx.db.drTrackerAdjustSize) then
		if (self:GetAttachTo() == "Frame") then
			local height = false
			--[[ need to rethink that
			for _, module in pairs(GladiusEx.modules) do
				if (module:GetAttachTo() == self:GetName()) then
					height = false
				end
			end]]

			if (height) then
				self.frame[unit]:SetWidth(GladiusEx.buttons[unit].height)
				self.frame[unit]:SetHeight(GladiusEx.buttons[unit].height)
			else
				self.frame[unit]:SetWidth(GladiusEx.buttons[unit].frameHeight)
				self.frame[unit]:SetHeight(GladiusEx.buttons[unit].frameHeight)
			end
		else
			self.frame[unit]:SetWidth(GladiusEx:GetModule(self:GetAttachTo()).frame[unit]:GetHeight() or 1)
			self.frame[unit]:SetHeight(GladiusEx:GetModule(self:GetAttachTo()).frame[unit]:GetHeight() or 1)
		end
	else
		self.frame[unit]:SetWidth(GladiusEx.db.drTrackerSize)
		self.frame[unit]:SetHeight(GladiusEx.db.drTrackerSize)
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
	self.frame[unit]:SetAlpha(0)
end

function DRTracker:Show(unit)
	-- show frame
	self.frame[unit]:SetAlpha(1)
end

function DRTracker:Reset(unit)
	if (not self.frame[unit]) then return end

	-- hide icons
	for _, frame in pairs(self.frame[unit].tracker) do
		frame.active = false
		frame.diminished = 1

		frame:SetScript("OnUpdate", nil)

		frame:SetAlpha(0)
	end

	-- hide
	self.frame[unit]:SetAlpha(0)
end

function DRTracker:Test(unit)
	if (not self.frame[unit].tracker[DRData:GetSpellCategory(64058)] or self.frame[unit].tracker[DRData:GetSpellCategory(64058)].active == false) then
		self:DRFaded(unit, 64058)
		self:DRFaded(unit, 118)
		self:DRFaded(unit, 118)
	end

	if (not self.frame[unit].tracker[DRData:GetSpellCategory(33786)] or self.frame[unit].tracker[DRData:GetSpellCategory(33786)].active == false) then
		self:DRFaded(unit, 33786)
		self:DRFaded(unit, 33786)
		self:DRFaded(unit, 33786)
	end
end

function DRTracker:GetOptions()
	local t = {
		general = {
			type="group",
			name=L["General"],
			order=1,
			args = {
				widget = {
					type="group",
					name=L["Widget"],
					desc=L["Widget settings"],
					inline=true,
					order=1,
					args = {
						drTrackerMargin = {
							type="range",
							name=L["DRTracker Space"],
							desc=L["Space between the icons"],
							min=0, max=100, step=1,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						sep = {
							type = "description",
							name="",
							width="full",
							order=7,
						},
						drTrackerCooldown = {
							type="toggle",
							name=L["DRTracker Cooldown Spiral"],
							desc=L["Display the cooldown spiral for important auras"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=10,
						},
						drTrackerCooldownReverse = {
							type="toggle",
							name=L["DRTracker Cooldown Reverse"],
							desc=L["Invert the dark/bright part of the cooldown spiral"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=15,
						},
						sep2 = {
							type = "description",
							name="",
							width="full",
							order=17,
						},
						drTrackerGloss = {
							type="toggle",
							name=L["DRTracker Gloss"],
							desc=L["Toggle gloss on the drTracker icon"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=25,
						},
						drTrackerGlossColor = {
							type="color",
							name=L["DRTracker Gloss Color"],
							desc=L["Color of the drTracker icon gloss"],
							get=function(info) return GladiusEx:GetColorOption(info) end,
							set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
							hasAlpha=true,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=30,
						},
						sep3 = {
							type = "description",
							name="",
							width="full",
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=33,
						},
						drTrackerFrameLevel = {
							type="range",
							name=L["DRTracker Frame Level"],
							desc=L["Frame level of the drTracker"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							min=1, max=5, step=1,
							width="double",
							order=35,
						},
					},
				},
				size = {
					type="group",
					name=L["Size"],
					desc=L["Size settings"],
					inline=true,
					order=2,
					args = {
						drTrackerAdjustSize = {
							type="toggle",
							name=L["DRTracker Adjust Size"],
							desc=L["Adjust drTracker size to the frame size"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						drTrackerSize = {
							type="range",
							name=L["DRTracker Size"],
							desc=L["Size of the drTracker"],
							min=10, max=100, step=1,
							disabled=function() return GladiusEx.dbi.profile.drTrackerAdjustSize or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
					},
				},
				font = {
					type="group",
					name=L["Font"],
					desc=L["Font settings"],
					inline=true,
					hidden=function() return not GladiusEx.db.advancedOptions end,
					order=3,
					args = {
						drFontColor = {
							type="color",
							name=L["DR Text Color"],
							desc=L["Text color of the DR text"],
							hasAlpha=true,
							get=function(info) return GladiusEx:GetColorOption(info) end,
							set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
							disabled=function() return not GladiusEx.dbi.profile.castText or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
						drFontSize = {
							type="range",
							name=L["DR Text Size"],
							desc=L["Text size of the DR text"],
							min=1, max=20, step=1,
							disabled=function() return not GladiusEx.dbi.profile.castText or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=15,
						},
					},
				},
				position = {
					type="group",
					name=L["Position"],
					desc=L["Position settings"],
					inline=true,
					order=4,
					args = {
						drTrackerAttachTo = {
							type="select",
							name=L["DRTracker Attach To"],
							desc=L["Attach drTracker to the given frame"],
							values=function() return DRTracker:GetAttachPoints() end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						drTrackerPosition = {
							type="select",
							name=L["DRTracker Position"],
							desc=L["Position of the class icon"],
							values={ ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"] },
							get=function() return strfind(GladiusEx.db.drTrackerAnchor, "RIGHT") and "LEFT" or "RIGHT" end,
							set=function(info, value)
								if (value == "LEFT") then
									GladiusEx.db.drTrackerAnchor = "TOPRIGHT"
									GladiusEx.db.drTrackerRelativePoint = "TOPLEFT"
								else
									GladiusEx.db.drTrackerAnchor = "TOPLEFT"
									GladiusEx.db.drTrackerRelativePoint = "TOPRIGHT"
								end

								GladiusEx:UpdateFrame(info[1])
							end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return GladiusEx.db.advancedOptions end,
							order=6,
						},
						sep = {
							type = "description",
							name="",
							width="full",
							order=7,
						},
						drTrackerGrowDirection = {
							type="select",
							name=L["Grow Direction"],
							values = {
								["LEFT"]  = L["Left"],
								["RIGHT"] = L["Right"],
								["UP"]    = L["Up"],
								["DOWN"]  = L["Down"],
							},
						},
						drTrackerAnchor = {
							type="select",
							name=L["DRTracker Anchor"],
							desc=L["Anchor of the drTracker"],
							values=function() return GladiusEx:GetPositions() end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=10,
						},
						drTrackerRelativePoint = {
							type="select",
							name=L["DRTracker Relative Point"],
							desc=L["Relative point of the drTracker"],
							values=function() return GladiusEx:GetPositions() end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=15,
						},
						sep2 = {
							type = "description",
							name="",
							width="full",
							order=17,
						},
						drTrackerOffsetX = {
							type="range",
							name=L["DRTracker Offset X"],
							desc=L["X offset of the drTracker"],
							min=-100, max=100, step=1,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=20,
						},
						drTrackerOffsetY = {
							type="range",
							name=L["DRTracker Offset Y"],
							desc=L["Y offset of the drTracker"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							min=-50, max=50, step=1,
							order=25,
						},
					},
				},
			},
		},
	}

	t.categories = {
		type="group",
		name=L["Categories"],
		order=2,
		args = {
			categories = {
				type="group",
				name=L["Categories"],
				desc=L["Category settings"],
				inline=true,
				order=1,
				args = {
				},
			},
		},
	}

	local index = 1
	for key, name in pairs(DRData.categoryNames) do
		t.categories.args.categories.args[key] = {
			type="toggle",
			name=name,
			get=function(info)
				if (GladiusEx.dbi.profile.drCategories[info[#info]] == nil) then
					return true
				else
					return GladiusEx.dbi.profile.drCategories[info[#info]]
				end
			end,
			set=function(info, value)
				GladiusEx.dbi.profile.drCategories[info[#info]] = value
			end,
			disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
			order=index * 5,
		}

		index = index + 1
	end

	return t
end
