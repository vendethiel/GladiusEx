local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM

-- global functions
local strfind = string.find
local pairs = pairs
local min = math.min
local UnitHealth, UnitHealthMax, UnitClass = UnitHealth, UnitHealthMax, UnitClass
local UnitGetIncomingHeals, UnitGetTotalAbsorbs = UnitGetIncomingHeals, UnitGetTotalAbsorbs

local HealthBar = GladiusEx:NewGladiusExModule("HealthBar", true, {
	healthBarAttachTo = "Frame",
	healthBarHeight = 25,
	healthBarAdjustWidth = true,
	healthBarWidth = 200,
	healthBarInverse = false,
	healthBarColor = { r = 1, g = 1, b = 1, a = 1 },
	healthBarClassColor = true,
	healthBarBackgroundColor = { r = 1, g = 1, b = 1, a = 0.3 },
	healthBarTexture = "Minimalist",
	healthBarOffsetX = 0,
	healthBarOffsetY = 0,
	healthBarAnchor = "TOPLEFT",
	healthBarRelativePoint = "TOPLEFT",

	healthBarIncomingHeals = true,
	healthBarIncomingHealsColor = { r = 0, g = 1, b = 0, a = 0.5 },
	healthBarIncomingHealsCap = 0,

	healthBarIncomingAbsorbs = true,
	healthBarIncomingAbsorbsColor = { r = 1, g = 1, b = 1, a = 0.5 },
	healthBarIncomingAbsorbsCap = 0,
})

function HealthBar:OnEnable()
	self:RegisterEvent("UNIT_HEALTH", "UpdateHealthEvent")
	self:RegisterEvent("UNIT_HEALTH_FREQUENT", "UpdateHealthEvent")
	self:RegisterEvent("UNIT_MAXHEALTH", "UpdateHealthEvent")
	self:RegisterEvent("UNIT_NAME_UPDATE", "UpdateColorEvent")
	self:RegisterEvent("UNIT_HEAL_PREDICTION", "UpdateIncomingHealsEvent")
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", "UpdateIncomingAbsorbsEvent")

	LSM = GladiusEx.LSM

	if (not self.frame) then
		self.frame = {}
	end
end

function HealthBar:OnDisable()
	self:UnregisterAllEvents()

	for unit in pairs(self.frame) do
		self.frame[unit]:SetAlpha(0)
	end
end

function HealthBar:IsBar(unit)
	if self.db[unit].healthBarAttachTo == "Frame" or strfind(self.db[unit].healthBarRelativePoint, "BOTTOM") then
		return true
	else
		return false
	end
end

function HealthBar:GetBarHeight(unit)
	return self.db[unit].healthBarHeight
end

function HealthBar:GetAttachTo(unit)
	return self.db[unit].healthBarAttachTo
end

function HealthBar:GetModuleAttachPoints()
	return {
		["HealthBar"] = L["HealthBar"],
	}
end

function HealthBar:GetAttachFrame(unit)
	if not self.frame[unit] then
		self:CreateBar(unit)
	end

	return self.frame[unit]
end

function HealthBar:UpdateColorEvent(event, unit)
	self:UpdateColor(unit)
end

function HealthBar:UpdateHealthEvent(event, unit)
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	self:UpdateHealth(unit, health, maxHealth)
end

function HealthBar:UpdateIncomingHealsEvent(event, unit)
	self:UpdateIncomingHeals(unit)
end

function HealthBar:UpdateIncomingAbsorbsEvent(event, unit)
	self:UpdateIncomingAbsorbs(unit)
end

function HealthBar:UpdateColor(unit)
	if not self.frame[unit] then return end

	local class
	if GladiusEx:IsTesting(unit) then
		class = GladiusEx.testing[unit].unitClass
	else
		class = select(2, UnitClass(unit))
	end
	if not class then
		class = GladiusEx.testing[unit].unitClass
	end

	-- set color
	local color
	if self.db[unit].healthBarClassColor then
		color = self:GetBarColor(class)
	else
		color = self.db[unit].healthBarColor
	end
	self.frame[unit]:SetStatusBarColor(color.r, color.g, color.b, color.a or 1)
end

function HealthBar:UpdateHealth(unit, health, maxHealth)
	if not self.frame[unit] then return end

	self.frame[unit].health = health
	self.frame[unit].maxHealth = maxHealth

	-- update min max values
	self.frame[unit]:SetMinMaxValues(0, maxHealth)

	-- inverse bar
	if (self.db[unit].healthBarInverse) then
		self.frame[unit]:SetValue(maxHealth - health)
	else
		self.frame[unit]:SetValue(health)
	end

	-- update incoming bars
	self:UpdateIncomingHeals(unit)
	self:UpdateIncomingAbsorbs(unit)
end

function HealthBar:SetIncomingBarAmount(unit, bar, incamount, inccap)
	local health = self.frame[unit].health
	local maxHealth = self.frame[unit].maxHealth
	local barWidth = self.frame[unit].barWidth

	-- cap amount
	incamount = min((maxHealth * (1 + inccap)) - health, incamount)

	local parent = self.frame[unit].barParent
	local ox = health / maxHealth * barWidth
	bar:ClearAllPoints()
	bar:SetPoint(self.db[unit].healthBarAnchor, parent, self.db[unit].healthBarRelativePoint, self.db[unit].healthBarOffsetX + ox, self.db[unit].healthBarOffsetY)
	bar:SetMinMaxValues(0, maxHealth)
	bar:SetValue(incamount)
end

function HealthBar:UpdateIncomingHeals(unit)
	if not self.frame[unit] then return end
	if not self.db[unit].healthBarIncomingHeals then return end

	local incamount = UnitGetIncomingHeals(unit) or 0
	self:SetIncomingBarAmount(unit, self.frame[unit].incheals, incamount, self.db[unit].healthBarIncomingHealsCap)
end

function HealthBar:UpdateIncomingAbsorbs(unit)
	if not self.frame[unit] then return end
	if not self.db[unit].healthBarIncomingAbsorbs then return end

	local incamount = UnitGetTotalAbsorbs(unit) or 0
	self:SetIncomingBarAmount(unit, self.frame[unit].incabsorbs, incamount, self.db[unit].healthBarIncomingAbsorbsCap)
end

function HealthBar:CreateBar(unit)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	-- create bar + text
	self.frame[unit] = CreateFrame("STATUSBAR", "GladiusEx" .. self:GetName() .. unit, button)
	self.frame[unit].background = button:CreateTexture("GladiusEx" .. self:GetName() .. unit .. "Background", "BACKGROUND")
	self.frame[unit].highlight = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. "Highlight" .. unit, "OVERLAY")
	self.frame[unit].incheals = CreateFrame("STATUSBAR", "GladiusEx" .. self:GetName() .. unit .. "IncHeals", self.frame[unit])
	self.frame[unit].incabsorbs = CreateFrame("STATUSBAR", "GladiusEx" .. self:GetName() .. unit .. "IncAbsorbs", self.frame[unit])
end

function HealthBar:Refresh(unit)
	self:UpdateColorEvent("Refresh", unit)
	self:UpdateHealthEvent("Refresh", unit)
end

function HealthBar:Update(unit)
	-- create power bar
	if not self.frame[unit] then
		self:CreateBar(unit)
	end

	-- set bar type
	local parent = GladiusEx:GetAttachFrame(unit, self.db[unit].healthBarAttachTo)
	self.frame[unit].barParent = parent

	-- update health bar
	self.frame[unit]:ClearAllPoints()

	local width = self.db[unit].healthBarAdjustWidth and GladiusEx.db[unit].barWidth or self.db[unit].healthBarWidth

	-- add width of the widget if attached to an widget
	-- todo: getmodule will fail
	if (self.db[unit].healthBarAttachTo ~= "Frame" and not strfind(self.db[unit].healthBarRelativePoint,"BOTTOM") and self.db[unit].healthBarAdjustWidth) then
		if (not GladiusEx:GetModule(self.db[unit].healthBarAttachTo).frame[unit]) then
			GladiusEx:GetModule(self.db[unit].healthBarAttachTo):Update(unit)
		end

		width = width + GladiusEx:GetModule(self.db[unit].healthBarAttachTo).frame[unit]:GetWidth()
	end
	self.frame[unit].barWidth = width

	self.frame[unit]:SetHeight(self.db[unit].healthBarHeight)
	self.frame[unit]:SetWidth(width)
	self.frame[unit]:SetPoint(self.db[unit].healthBarAnchor, parent, self.db[unit].healthBarRelativePoint, self.db[unit].healthBarOffsetX, self.db[unit].healthBarOffsetY)
	self.frame[unit]:SetStatusBarTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, self.db[unit].healthBarTexture))
	self.frame[unit]:GetStatusBarTexture():SetHorizTile(false)
	self.frame[unit]:GetStatusBarTexture():SetVertTile(false)
	self.frame[unit]:SetMinMaxValues(0, 1)
	self.frame[unit]:SetValue(1)
	self.frame[unit]:SetFrameLevel(6)

	-- incoming heals
	self.frame[unit].incheals:SetHeight(self.db[unit].healthBarHeight)
	self.frame[unit].incheals:SetWidth(width)
	self.frame[unit].incheals:SetStatusBarTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, self.db[unit].healthBarTexture))
	self.frame[unit].incheals:GetStatusBarTexture():SetHorizTile(false)
	self.frame[unit].incheals:GetStatusBarTexture():SetVertTile(false)
	local color = self.db[unit].healthBarIncomingHealsColor
	self.frame[unit].incheals:SetStatusBarColor(color.r, color.g, color.b, color.a)
	self.frame[unit].incheals:SetMinMaxValues(0, 1)
	self.frame[unit].incheals:SetValue(0)
	self.frame[unit].incheals:SetFrameLevel(5)

	if self.db[unit].healthBarIncomingHeals then
		self.frame[unit].incheals:Show()
	else
		self.frame[unit].incheals:Hide()
	end

	-- incoming absorbs
	self.frame[unit].incabsorbs:SetHeight(self.db[unit].healthBarHeight)
	self.frame[unit].incabsorbs:SetWidth(width)
	self.frame[unit].incabsorbs:SetStatusBarTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, self.db[unit].healthBarTexture))
	self.frame[unit].incabsorbs:GetStatusBarTexture():SetHorizTile(false)
	self.frame[unit].incabsorbs:GetStatusBarTexture():SetVertTile(false)
	local color = self.db[unit].healthBarIncomingAbsorbsColor
	self.frame[unit].incabsorbs:SetStatusBarColor(color.r, color.g, color.b, color.a)
	self.frame[unit].incabsorbs:SetMinMaxValues(0, 1)
	self.frame[unit].incabsorbs:SetValue(0)
	self.frame[unit].incabsorbs:SetFrameLevel(4)

	if self.db[unit].healthBarIncomingAbsorbs then
		self.frame[unit].incabsorbs:Show()
	else
		self.frame[unit].incabsorbs:Hide()
	end

	-- update health bar background
	self.frame[unit].background:ClearAllPoints()
	self.frame[unit].background:SetAllPoints(self.frame[unit])
	self.frame[unit].background:SetWidth(self.frame[unit]:GetWidth())
	self.frame[unit].background:SetHeight(self.frame[unit]:GetHeight())
	self.frame[unit].background:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, self.db[unit].healthBarTexture))
	self.frame[unit].background:SetVertexColor(self.db[unit].healthBarBackgroundColor.r, self.db[unit].healthBarBackgroundColor.g,
		self.db[unit].healthBarBackgroundColor.b, self.db[unit].healthBarBackgroundColor.a)
	self.frame[unit].background:SetHorizTile(false)
	self.frame[unit].background:SetVertTile(false)

	-- update highlight texture
	self.frame[unit].highlight:SetAllPoints(self.frame[unit])
	self.frame[unit].highlight:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	self.frame[unit].highlight:SetBlendMode("ADD")
	self.frame[unit].highlight:SetVertexColor(1.0, 1.0, 1.0, 1.0)
	self.frame[unit].highlight:SetAlpha(0)

	-- hide frame
	self.frame[unit]:SetAlpha(0)
end

function HealthBar:GetBarColor(class)
	return RAID_CLASS_COLORS[class] or { r = 1, g = 1, b = 1, a = 1}
end

function HealthBar:Show(unit)
	-- show frame
	self.frame[unit]:SetAlpha(1)

	-- update color
	self:UpdateColorEvent("Show", unit)

	-- call event
	self:UpdateHealthEvent("Show", unit)
end

function HealthBar:Reset(unit)
	if not self.frame[unit] then return end

	-- reset bar
	self.frame[unit]:SetMinMaxValues(0, 1)
	self.frame[unit]:SetValue(1)

	-- hide
	self.frame[unit]:SetAlpha(0)
end

function HealthBar:Test(unit)
	-- set test values
	local maxHealth = GladiusEx.testing[unit].maxHealth
	local health = GladiusEx.testing[unit].health
	self:UpdateColorEvent("Test", unit)
	self:UpdateHealth(unit, health, maxHealth)
	self:SetIncomingBarAmount(unit, self.frame[unit].incheals, maxHealth * 0.1, self.db[unit].healthBarIncomingHealsCap)
	self:SetIncomingBarAmount(unit, self.frame[unit].incabsorbs, maxHealth * 0.2, self.db[unit].healthBarIncomingAbsorbsCap)
end

function HealthBar:GetOptions(unit)
	return {
		general = {
			type = "group",
			name = L["General"],
			order = 1,
			args = {
				bar = {
					type = "group",
					name = L["Bar"],
					desc = L["Bar settings"],
					inline = true,
					order = 1,
					args = {
						healthBarClassColor = {
							type = "toggle",
							name = L["Class color"],
							desc = L["Toggle health bar class color"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 5,
						},
						sep = {
							type = "description",
							name = "",
							width = "full",
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 7,
						},
						healthBarColor = {
							type = "color",
							name = L["Color"],
							desc = L["Color of the health bar"],
							hasAlpha = true,
							get = function(info) return GladiusEx:GetColorOption(self.db[unit], info) end,
							set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db[unit], info, r, g, b, a) end,
							disabled = function() return self.db[unit].healthBarClassColor or not self:IsUnitEnabled(unit) end,
							order = 10,
						},
						healthBarBackgroundColor = {
							type = "color",
							name = L["Background color"],
							desc = L["Color of the health bar background"],
							hasAlpha = true,
							get = function(info) return GladiusEx:GetColorOption(self.db[unit], info) end,
							set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db[unit], info, r, g, b, a) end,
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
						healthBarInverse = {
							type = "toggle",
							name = L["Inverse"],
							desc = L["Invert the bar colors"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 20,
						},
						healthBarTexture = {
							type = "select",
							name = L["Texture"],
							desc = L["Texture of the health bar"],
							dialogControl = "LSM30_Statusbar",
							values = AceGUIWidgetLSMlists.statusbar,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 25,
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
						healthBarAdjustWidth = {
							type = "toggle",
							name = L["Adjust width"],
							desc = L["Adjust bar width to the frame width"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 5,
						},
						sep = {
							type = "description",
							name = "",
							width = "full",
							order = 13,
						},
						healthBarWidth = {
							type = "range",
							name = L["Width"],
							desc = L["Width of the health bar"],
							min = 10, max = 500, step = 1,
							disabled = function() return self.db[unit].healthBarAdjustWidth or not self:IsUnitEnabled(unit) end,
							order = 15,
						},
						healthBarHeight = {
							type = "range",
							name = L["Height"],
							desc = L["Height of the health bar"],
							min = 10, max = 200, step = 1,
							disabled = function() return not self:IsUnitEnabled(unit) end,
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
						healthBarAttachTo = {
							type = "select",
							name = L["Attach to"],
							desc = L["Attach health bar to the given frame"],
							values = function() return self:GetOtherAttachPoints(unit) end,
							set = function(info, value)
								local key = info.arg or info[#info]

								self.db[unit][key] = value
								GladiusEx:UpdateFrames()
							end,
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
						healthBarAnchor = {
							type = "select",
							name = L["Anchor"],
							desc = L["Anchor of the health bar"],
							values = function() return GladiusEx:GetPositions() end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 10,
						},
						healthBarRelativePoint = {
							type = "select",
							name = L["Relative point"],
							desc = L["Relative point of the health bar"],
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
						healthBarOffsetX = {
							type = "range",
							name = L["Offset X"],
							desc = L["X offset of the health bar"],
							softMin = -100, softMax = 100, bigStep = 1,
							disabled = function() return  not self:IsUnitEnabled(unit) end,
							order = 20,
						},
						healthBarOffsetY = {
							type = "range",
							name = L["Offset Y"],
							desc = L["Y offset of the health bar"],
							softMin = -100, softMax = 100, bigStep = 1,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 25,
						},
					},
				},
			},
		},
		incoming = {
			type = "group",
			name = L["Incoming heals"],
			order = 2,
			args = {
				heals = {
					type = "group",
					name = L["Incoming heals"],
					desc = L["Incoming heals settings"],
					inline = true,
					order = 1,
					args = {
						healthBarIncomingHeals = {
							type = "toggle",
							name = L["Show incoming heals"],
							desc = L["Toggle display of incoming heals in the health bar"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 1,
						},
						healthBarIncomingHealsColor = {
							type = "color",
							name = L["Incoming heals color"],
							desc = L["Incoming heals bar color"],
							hasAlpha = true,
							get = function(info) return GladiusEx:GetColorOption(self.db[unit], info) end,
							set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db[unit], info, r, g, b, a) end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 2,
						},
						healthBarIncomingHealsCap = {
							type = "range",
							name = L["Outside bar limit"],
							desc = L["How much the incoming heals bar can grow outside the health bar, as a proportion of the unit's total health"],
							min = 0, softMax = 1, bigStep = 0.01, isPercent = true,
							width = "double",
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 3,
						},
					}
				},
				absorbs = {
					type = "group",
					name = L["Absorbs"],
					desc = L["Absorbs settings"],
					inline = true,
					order = 2,
					args = {
						healthBarIncomingAbsorbs = {
							type = "toggle",
							name = L["Show absorbs"],
							desc = L["Toggle display of absorbs in the health bar"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 1,
						},
						healthBarIncomingAbsorbsColor = {
							type = "color",
							name = L["Absorbs color"],
							desc = L["Absorbs bar color"],
							hasAlpha = true,
							get = function(info) return GladiusEx:GetColorOption(self.db[unit], info) end,
							set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db[unit], info, r, g, b, a) end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 2,
						},
						healthBarIncomingAbsorbsCap = {
							type = "range",
							name = L["Outside bar limit"],
							desc = L["How much the absorbs bar can grow outside the health bar, as a proportion of the unit's total health"],
							min = 0, softMax = 1, bigStep = 0.01, isPercent = true,
							width = "double",
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 3,
						},
					}
				}
			}
		}
	}
end
