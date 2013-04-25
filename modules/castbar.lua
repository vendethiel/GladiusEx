local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM

-- global functions
local strfind = string.find
local pairs = pairs
local min = math.min
local GetTime = GetTime
local GetSpellInfo, UnitCastingInfo, UnitChannelInfo = GetSpellInfo, UnitCastingInfo, UnitChannelInfo

local CastBar = GladiusEx:NewGladiusExModule("CastBar", true, {
	castBarAttachTo = "ClassIcon",

	castBarHeight = 12,
	castBarAdjustWidth = true,
	castBarWidth = 150,

	castBarOffsetX = 0,
	castBarOffsetY = 0,

	castBarAnchor = "TOPLEFT",
	castBarRelativePoint = "BOTTOMLEFT",

	castBarInverse = false,
	castBarColor = { r = 1, g = 1, b = 0, a = 1 },
	castBarBackgroundColor = { r = 1, g = 1, b = 1, a = 0.3 },
	castBarTexture = "Minimalist",

	castIcon = true,
	castIconPosition = "LEFT",

	castText = true,
	castTextSize = 11,
	castTextColor = { r = 2.55, g = 2.55, b = 2.55, a = 1 },
	castTextAlign = "LEFT",
	castTextOffsetX = 0,
	castTextOffsetY = 0,

	castTimeText = true,
	castTimeTextSize = 11,
	castTimeTextColor = { r = 2.55, g = 2.55, b = 2.55, a = 1 },
	castTimeTextAlign = "RIGHT",
	castTimeTextOffsetX = 0,
	castTimeTextOffsetY = 0,
})

function CastBar:OnEnable()
	self:RegisterEvent("UNIT_SPELLCAST_START")
	self:RegisterEvent("UNIT_SPELLCAST_STOP")
	self:RegisterEvent("UNIT_SPELLCAST_DELAYED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_STOP")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_STOP")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_DELAYED")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_STOP")

	LSM = GladiusEx.LSM

	--[[ set frame type
	if (GladiusEx.db.castBarAttachTo == "Frame" or GladiusEx:GetModule(GladiusEx.db.castBarAttachTo).isBar) then
		self.isBar = true
	else
		self.isBar = false
	end]]
	self.isBar = true

	if (not self.frame) then
		self.frame = {}
	end
end

function CastBar:OnDisable()
	self:UnregisterAllEvents()

	for unit in pairs(self.frame) do
		self.frame[unit]:SetAlpha(0)
	end
end

function CastBar:GetAttachTo()
	return GladiusEx.db.castBarAttachTo
end

function CastBar:GetModuleAttachPoints()
	return {
		["CastBar"] = L["CastBar"],
		["CastBarIcon"] = L["CastBar Icon"],
	}
end

function CastBar:GetAttachFrame(unit, point)
	if not self.frame[unit] then
		self:CreateBar(unit)
	end

	if point == "CastBar" then
		return self.frame[unit]
	else
		return self.frame[unit].icon
	end
end

function CastBar:UNIT_SPELLCAST_START(event, unit)
	if not self.frame[unit] then return end

	local spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitCastingInfo(unit)
	if (spell) then
		self.frame[unit].isChanneling = false
		self.frame[unit].isCasting = true
		self.frame[unit].startTime = startTime / 1000
		self.frame[unit].endTime = endTime / 1000
		self.frame[unit].delay = nil
		self.frame[unit]:SetMinMaxValues(0, (endTime - startTime) / 1000)
		self.frame[unit].icon:SetTexture(icon)

		if( rank ~= "" ) then
			self.frame[unit].castText:SetFormattedText("%s (%s)", spell, rank)
		else
			self.frame[unit].castText:SetText(spell)
		end
	end
end

function CastBar:UNIT_SPELLCAST_CHANNEL_START(event, unit)
	if not self.frame[unit] then return end

	local spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitChannelInfo(unit)
	if (spell) then
		self.frame[unit].isChanneling = true
		self.frame[unit].isCasting = false
		self.frame[unit].startTime = startTime / 1000
		self.frame[unit].endTime = endTime / 1000
		self.frame[unit].delay = nil
		self.frame[unit]:SetMinMaxValues(0, (endTime - startTime) / 1000)
		self.frame[unit].icon:SetTexture(icon)

		if( rank ~= "" ) then
			self.frame[unit].castText:SetFormattedText("%s (%s)", spell, rank)
		else
			self.frame[unit].castText:SetText(spell)
		end
	end
end

function CastBar:UNIT_SPELLCAST_STOP(event, unit)
	if not self.frame[unit] then return end

	self:CastEnd(self.frame[unit])
end

function CastBar:UNIT_SPELLCAST_DELAYED(event, unit)
	if not self.frame[unit] then return end
	if not self.frame[unit].isCasting or self.frame[unit].isChanneling then return end

	local spell, rank, displayName, icon, startTime, endTime, isTradeSkill
	if event == "UNIT_SPELLCAST_DELAYED" then
		spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitCastingInfo(unit)
	else
		spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitChannelInfo(unit)
	end

	if not startTime or not endTime then return end

	if event == "UNIT_SPELLCAST_DELAYED" then
		self.frame[unit].delay = (self.frame[unit].delay or 0) + (startTime / 1000 - self.frame[unit].startTime)
	else
		self.frame[unit].delay = (self.frame[unit].delay or 0) + (self.startTime - startTime / 1000)
	end

	self.frame[unit].startTime = startTime / 1000
	self.frame[unit].endTime = endTime / 1000
	self.frame[unit]:SetMinMaxValues(0, (endTime - startTime) / 1000)
end

local function CastUpdate(self)
	if self.isCasting or self.isChanneling then
		local currentTime = min(self.endTime, GetTime())
		local value = self.endTime - currentTime

		if (self.isChanneling and not GladiusEx.db.castBarInverse) or (self.isCasting and GladiusEx.db.castBarInverse) then
			self:SetValue(value)
		else
			self:SetValue(self.endTime - self.startTime - value)
		end

		if self.delay then
			self.timeText:SetFormattedText("+%.2f %.2f", self.delay, value)
		else
			self.timeText:SetFormattedText("%.2f", value)
		end
	end
end

function CastBar:CastEnd(bar)
	bar.isCasting = nil
	bar.isChanneling = nil
	bar.timeText:SetText("")
	bar.castText:SetText("")
	bar.icon:SetTexture("")
	bar:SetValue(0)
end

function CastBar:CreateBar(unit)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	-- create bar + text
	self.frame[unit] = CreateFrame("STATUSBAR", "GladiusEx" .. self:GetName() .. unit, button)
	self.frame[unit].background = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. unit .. "Background", "BACKGROUND")
	self.frame[unit].highlight = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. "Highlight" .. unit, "OVERLAY")
	self.frame[unit].castText = self.frame[unit]:CreateFontString("GladiusEx" .. self:GetName() .. "CastText" .. unit, "OVERLAY")
	self.frame[unit].timeText = self.frame[unit]:CreateFontString("GladiusEx" .. self:GetName() .. "TimeText" .. unit, "OVERLAY")
	self.frame[unit].icon = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. "IconFrame" .. unit, "ARTWORK")
	self.frame[unit].icon.bg = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. "IconFrameBackground" .. unit, "BACKGROUND")
end

function CastBar:GetBarHeight()
	return GladiusEx.db.castBarHeight
end

function CastBar:Update(unit)
	-- check parent module
	if (not GladiusEx:GetAttachFrame(unit, GladiusEx.db.castBarAttachTo)) then
		if (self.frame[unit]) then
			self.frame[unit]:Hide()
		end
		return
	end

	-- create power bar
	if (not self.frame[unit]) then
		self:CreateBar(unit)
	end

	-- set bar type
	local parent = GladiusEx:GetAttachFrame(unit, GladiusEx.db.castBarAttachTo)

  --[[ if (GladiusEx.db.castBarAttachTo == "Frame" or GladiusEx:GetModule(GladiusEx.db.castBarAttachTo).isBar) then
		self.isBar = true
	else
		self.isBar = false
	end]]

	-- update power bar
	self.frame[unit]:ClearAllPoints()

	local width = GladiusEx.db.castBarAdjustWidth and GladiusEx.db.barWidth or GladiusEx.db.castBarWidth
	if (GladiusEx.db.castIcon) then
		width = width - GladiusEx.db.castBarHeight
	end

	-- add width of the widget if attached to an widget
	if (GladiusEx.db.castBarAttachTo ~= "Frame" and not GladiusEx:GetModule(GladiusEx.db.castBarAttachTo).isBar and GladiusEx.db.castBarAdjustWidth) then
		if (not GladiusEx:GetModule(GladiusEx.db.castBarAttachTo).frame or not GladiusEx:GetModule(GladiusEx.db.castBarAttachTo).frame[unit]) then
			GladiusEx:GetModule(GladiusEx.db.castBarAttachTo):Update(unit)
		end

		width = width + GladiusEx:GetModule(GladiusEx.db.castBarAttachTo).frame[unit]:GetWidth()

		-- hack: needed for whatever reason, must be a bug elsewhere
		width = width + 1
	end

	self.frame[unit]:SetHeight(GladiusEx.db.castBarHeight)
	self.frame[unit]:SetWidth(width)

	local offsetX
	if (not strfind(GladiusEx.db.castBarAnchor, "RIGHT") and strfind(GladiusEx.db.castBarRelativePoint, "RIGHT")) then
		offsetX = GladiusEx.db.castIcon and GladiusEx.db.castIconPosition == "LEFT" and self.frame[unit]:GetHeight() or 0
	elseif (not strfind(GladiusEx.db.castBarAnchor, "LEFT") and strfind(GladiusEx.db.castBarRelativePoint, "LEFT")) then
		offsetX = GladiusEx.db.castIcon and GladiusEx.db.castIconPosition == "RIGHT" and -self.frame[unit]:GetHeight() or 0
	elseif (strfind(GladiusEx.db.castBarAnchor, "LEFT") and strfind(GladiusEx.db.castBarRelativePoint, "LEFT")) then
		offsetX = GladiusEx.db.castIcon and GladiusEx.db.castIconPosition == "LEFT" and self.frame[unit]:GetHeight() or 0
	elseif (strfind(GladiusEx.db.castBarAnchor, "RIGHT") and strfind(GladiusEx.db.castBarRelativePoint, "RIGHT")) then
		offsetX = GladiusEx.db.castIcon and GladiusEx.db.castIconPosition == "RIGHT" and -self.frame[unit]:GetHeight() or 0
	end

	self.frame[unit]:SetPoint(GladiusEx.db.castBarAnchor, parent, GladiusEx.db.castBarRelativePoint, GladiusEx.db.castBarOffsetX + (offsetX or 0), GladiusEx.db.castBarOffsetY)
	self.frame[unit]:SetMinMaxValues(0, 100)
	self.frame[unit]:SetValue(0)
	self.frame[unit]:SetStatusBarTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, GladiusEx.db.castBarTexture))

	-- updating
	self.frame[unit]:SetScript("OnUpdate", CastUpdate)

	-- disable tileing
	self.frame[unit]:GetStatusBarTexture():SetHorizTile(false)
	self.frame[unit]:GetStatusBarTexture():SetVertTile(false)

	-- set color
	local color = GladiusEx.db.castBarColor
	self.frame[unit]:SetStatusBarColor(color.r, color.g, color.b, color.a)

	-- update cast text
	self.frame[unit].castText:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.globalFont), GladiusEx.db.castTextSize)

	local color = GladiusEx.db.castTextColor
	self.frame[unit].castText:SetTextColor(color.r, color.g, color.b, color.a)

	self.frame[unit].castText:SetShadowOffset(1, -1)
	self.frame[unit].castText:SetShadowColor(0, 0, 0, 1)
	self.frame[unit].castText:SetJustifyH(GladiusEx.db.castTextAlign)
	self.frame[unit].castText:SetPoint(GladiusEx.db.castTextAlign, GladiusEx.db.castTextOffsetX, GladiusEx.db.castTextOffsetY)

	-- update cast time text
	self.frame[unit].timeText:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.globalFont), GladiusEx.db.castTimeTextSize)

	local color = GladiusEx.db.castTimeTextColor
	self.frame[unit].timeText:SetTextColor(color.r, color.g, color.b, color.a)

	self.frame[unit].timeText:SetShadowOffset(1, -1)
	self.frame[unit].timeText:SetShadowColor(0, 0, 0, 1)
	self.frame[unit].timeText:SetJustifyH(GladiusEx.db.castTimeTextAlign)
	self.frame[unit].timeText:SetPoint(GladiusEx.db.castTimeTextAlign, GladiusEx.db.castTimeTextOffsetX, GladiusEx.db.castTimeTextOffsetY)

	-- update icon
	self.frame[unit].icon:ClearAllPoints()
	self.frame[unit].icon:SetPoint(GladiusEx.db.castIconPosition == "LEFT" and "RIGHT" or "LEFT", self.frame[unit], GladiusEx.db.castIconPosition)

	self.frame[unit].icon:SetWidth(self.frame[unit]:GetHeight())
	self.frame[unit].icon:SetHeight(self.frame[unit]:GetHeight())

	self.frame[unit].icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

	self.frame[unit].icon.bg:ClearAllPoints()
	self.frame[unit].icon.bg:SetAllPoints(self.frame[unit].icon)
	self.frame[unit].icon.bg:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, GladiusEx.db.castBarTexture))
	self.frame[unit].icon.bg:SetVertexColor(GladiusEx.db.castBarBackgroundColor.r, GladiusEx.db.castBarBackgroundColor.g,
		GladiusEx.db.castBarBackgroundColor.b, GladiusEx.db.castBarBackgroundColor.a)


	if (not GladiusEx.db.castIcon) then
		self.frame[unit].icon:SetAlpha(0)
	else
		self.frame[unit].icon:SetAlpha(1)
	end

	-- update cast bar background
	self.frame[unit].background:ClearAllPoints()
	self.frame[unit].background:SetAllPoints(self.frame[unit])

	-- Maybe it looks better if the background covers the whole castbar
	--[[
	if (GladiusEx.db.castIcon) then
		self.frame[unit].background:SetWidth(self.frame[unit]:GetWidth() + self.frame[unit].icon:GetWidth())
	else
		self.frame[unit].background:SetWidth(self.frame[unit]:GetWidth())
	end
	--]]

	self.frame[unit].background:SetHeight(self.frame[unit]:GetHeight())

	self.frame[unit].background:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, GladiusEx.db.castBarTexture))

	self.frame[unit].background:SetVertexColor(GladiusEx.db.castBarBackgroundColor.r, GladiusEx.db.castBarBackgroundColor.g,
		GladiusEx.db.castBarBackgroundColor.b, GladiusEx.db.castBarBackgroundColor.a)

	-- disable tileing
	self.frame[unit].background:SetHorizTile(false)
	self.frame[unit].background:SetVertTile(false)

	-- update highlight texture
	self.frame[unit].highlight:SetAllPoints(self.frame[unit])
	self.frame[unit].highlight:SetTexture([=[Interface\QuestFrame\UI-QuestTitleHighlight]=])
	self.frame[unit].highlight:SetBlendMode("ADD")
	self.frame[unit].highlight:SetVertexColor(1.0, 1.0, 1.0, 1.0)
	self.frame[unit].highlight:SetAlpha(0)

	-- hide
	self.frame[unit]:SetAlpha(0)
end

function CastBar:Show(unit)
	-- show frame
	self.frame[unit]:SetAlpha(1)
end

function CastBar:Reset(unit)
	-- reset bar
	self.frame[unit]:SetMinMaxValues(0, 1)
	self.frame[unit]:SetValue(0)

	-- reset text
	if (self.frame[unit].castText:GetFont()) then
		self.frame[unit].castText:SetText("")
	end

	if (self.frame[unit].timeText:GetFont()) then
		self.frame[unit].timeText:SetText("")
	end

	-- hide
	self.frame[unit]:SetAlpha(0)
end

function CastBar:Test(unit)
		self.frame[unit]:SetMinMaxValues(0, 100)
		self.frame[unit]:SetValue(70)

		if (GladiusEx.db.castTimeText) then
			self.frame[unit].timeText:SetFormattedText("+1.5 %.1f", 1.379)
		else
			self.frame[unit].timeText:SetText("")
		end

		local texture = select(3, GetSpellInfo(1))
		self.frame[unit].icon:SetTexture(texture)

		if (GladiusEx.db.castText) then
			self.frame[unit].castText:SetText(L["Example Spell Name"])
		else
			self.frame[unit].castText:SetText("")
		end
end

function CastBar:GetOptions()
	return {
		general = {
			type="group",
			name=L["General"],
			order=1,
			args = {
				bar = {
					type="group",
					name=L["Bar"],
					desc=L["Bar settings"],
					inline=true,
					order=1,
					args = {
						castBarColor = {
							type="color",
							name=L["Cast Bar Color"],
							desc=L["Color of the cast bar"],
							hasAlpha=true,
							get=function(info) return GladiusEx:GetColorOption(info) end,
							set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						castBarBackgroundColor = {
							type="color",
							name=L["Cast Bar Background Color"],
							desc=L["Color of the cast bar background"],
							hasAlpha=true,
							get=function(info) return GladiusEx:GetColorOption(info) end,
							set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=10,
						},
						sep = {
							type = "description",
							name="",
							width="full",
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=13,
						},
						castBarInverse = {
							type="toggle",
							name=L["Cast Bar Inverse"],
							desc=L["Inverse the cast bar"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=15,
						},
						castBarTexture = {
							type="select",
							name=L["Cast Bar Texture"],
							desc=L["Texture of the cast bar"],
							dialogControl = "LSM30_Statusbar",
							values = AceGUIWidgetLSMlists.statusbar,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=20,
						},
						sep2 = {
							type = "description",
							name="",
							width="full",
							order=23,
						},
						castIcon = {
							type="toggle",
							name=L["Cast Bar Icon"],
							desc=L["Toggle the cast icon"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=25,
						},
						castIconPosition = {
							type="select",
							name=L["Cast Bar Icon Position"],
							desc=L["Position of the cast bar icon"],
							values={ ["LEFT"] = L["LEFT"], ["RIGHT"] = L["RIGHT"] },
							disabled=function() return not GladiusEx.dbi.profile.castIcon or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=30,
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
						castBarAdjustWidth = {
							type="toggle",
							name=L["Cast Bar Adjust Width"],
							desc=L["Adjust cast bar width to the frame width"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						sep = {
							type = "description",
							name="",
							width="full",
							order=13,
						},
						castBarWidth = {
							type="range",
							name=L["Cast Bar Width"],
							desc=L["Width of the cast bar"],
							min=10, max=500, step=1,
							disabled=function() return GladiusEx.dbi.profile.castBarAdjustWidth or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=15,
						},
						castBarHeight = {
							type="range",
							name=L["Cast Bar Height"],
							desc=L["Height of the cast bar"],
							min=10, max=200, step=1,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=20,
						},
					},
				},
				position = {
					type="group",
					name=L["Position"],
					desc=L["Position settings"],
					inline=true,
					hidden=function() return not GladiusEx.db.advancedOptions end,
					order=3,
					args = {
						castBarAttachTo = {
							type="select",
							name=L["Cast Bar Attach To"],
							desc=L["Attach cast bar to the given frame"],
							values=function() return CastBar:GetAttachPoints() end,
							set=function(info, value)
								local key = info.arg or info[#info]

								--[[if (GladiusEx.db.castBarAttachTo == "Frame" or GladiusEx:GetModule(GladiusEx.db.castBarAttachTo).isBar) then
									self.isBar = true
								else
									self.isBar = false
								end]]

								GladiusEx.dbi.profile[key] = value
								GladiusEx:UpdateFrame()
							end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							width="double",
							order=5,
						},
						sep = {
							type = "description",
							name="",
							width="full",
							order=7,
						},
						castBarAnchor = {
							type="select",
							name=L["Cast Bar Anchor"],
							desc=L["Anchor of the cast bar"],
							values=function() return GladiusEx:GetPositions() end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
						castBarRelativePoint = {
							type="select",
							name=L["Cast Bar Relative Point"],
							desc=L["Relative point of the cast bar"],
							values=function() return GladiusEx:GetPositions() end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=15,
						},
						sep2 = {
							type = "description",
							name="",
							width="full",
							order=17,
						},
						castBarOffsetX = {
							type="range",
							name=L["Cast Bar Offset X"],
							desc=L["X offset of the cast bar"],
							min=-100, max=100, step=1,
							disabled=function() return  not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=20,
						},
						castBarOffsetY = {
							type="range",
							name=L["Cast Bar Offset Y"],
							desc=L["Y offset of the castbar"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							min=-100, max=100, step=1,
							order=25,
						},
					},
				},
			},
		},
		castText = {
			type="group",
			name=L["Cast Text"],
			order=2,
			args = {
				text = {
					type="group",
					name=L["Text"],
					desc=L["Text settings"],
					inline=true,
					order=1,
					args = {
						castText = {
							type="toggle",
							name=L["Cast Text"],
							desc=L["Toggle cast text"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						sep = {
							type = "description",
							name="",
							width="full",
							order=7,
						},
						castTextColor = {
							type="color",
							name=L["Cast Text Color"],
							desc=L["Text color of the cast text"],
							hasAlpha=true,
							get=function(info) return GladiusEx:GetColorOption(info) end,
							set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
							disabled=function() return not GladiusEx.dbi.profile.castText or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
						castTextSize = {
							type="range",
							name=L["Cast Text Size"],
							desc=L["Text size of the cast text"],
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
					hidden=function() return not GladiusEx.db.advancedOptions end,
					order=2,
					args = {
						castTextAlign = {
							type="select",
							name=L["Cast Text Align"],
							desc=L["Text align of the cast text"],
							values={ ["LEFT"] = L["LEFT"], ["CENTER"] = L["CENTER"], ["RIGHT"] = L["RIGHT"] },
							disabled=function() return not GladiusEx.dbi.profile.castText or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							width="double",
							order=5,
						},
						sep = {
							type = "description",
							name="",
							width="full",
							order=7,
						},
						castTextOffsetX = {
							type="range",
							name=L["Cast Text Offset X"],
							desc=L["X offset of the cast text"],
							min=-100, max=100, step=1,
							disabled=function() return not GladiusEx.dbi.profile.castText or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
						castTextOffsetY = {
							type="range",
							name=L["Cast Text Offset Y"],
							desc=L["Y offset of the cast text"],
							disabled=function() return not GladiusEx.dbi.profile.castText or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							min=-100, max=100, step=1,
							order=15,
						},
					},
				},
			},
		},
		castTimeText = {
			type="group",
			name=L["Cast Time Text"],
			order=3,
			args = {
				text = {
					type="group",
					name=L["Text"],
					desc=L["Text settings"],
					inline=true,
					order=1,
					args = {
						castTimeText = {
							type="toggle",
							name=L["Cast Time Text"],
							desc=L["Toggle cast time text"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						sep = {
							type = "description",
							name="",
							width="full",
							order=7,
						},
						castTimeTextColor = {
							type="color",
							name=L["Cast Time Text Color"],
							desc=L["Text color of the cast time text"],
							hasAlpha=true,
							get=function(info) return GladiusEx:GetColorOption(info) end,
							set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
							disabled=function() return not GladiusEx.dbi.profile.castTimeText or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
						castTimeTextSize = {
							type="range",
							name=L["Cast Time Text Size"],
							desc=L["Text size of the cast time text"],
							min=1, max=20, step=1,
							disabled=function() return not GladiusEx.dbi.profile.castTimeText or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=15,
						},

					},
				},
				position = {
					type="group",
					name=L["Position"],
					desc=L["Position settings"],
					inline=true,
					hidden=function() return not GladiusEx.db.advancedOptions end,
					order=2,
					args = {
						castTimeTextAlign = {
							type="select",
							name=L["Cast Time Text Align"],
							desc=L["Text align of the cast time text"],
							values={ ["LEFT"] = L["LEFT"], ["CENTER"] = L["CENTER"], ["RIGHT"] = L["RIGHT"] },
							disabled=function() return not GladiusEx.dbi.profile.castTimeText or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							width="double",
							order=5,
						},
						sep = {
							type = "description",
							name="",
							width="full",
							order=7,
						},
						castTimeTextOffsetX = {
							type="range",
							name=L["Cast Time Offset X"],
							desc=L["X Offset of the cast time text"],
							min=-100, max=100, step=1,
							disabled=function() return not GladiusEx.dbi.profile.castTimeText or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
						castTimeTextOffsetY = {
							type="range",
							name=L["Cast Time Offset Y"],
							desc=L["Y Offset of the cast time text"],
							disabled=function() return not GladiusEx.dbi.profile.castTimeText or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							min=-100, max=100, step=1,
							order=15,
						},
					},
				},
			},
		},
	}
end
