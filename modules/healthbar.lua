local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM

-- global functions
local strfind = string.find
local pairs = pairs
local UnitHealth, UnitHealthMax, UnitClass = UnitHealth, UnitHealthMax, UnitClass

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
})

function HealthBar:OnEnable()
	self:RegisterEvent("UNIT_HEALTH", "UpdateHealthEvent")
	self:RegisterEvent("UNIT_HEALTH_FREQUENT", "UpdateHealthEvent")
	self:RegisterEvent("UNIT_MAXHEALTH", "UpdateHealthEvent")
	self:RegisterEvent("UNIT_NAME_UPDATE", "UpdateColorEvent")

	LSM = GladiusEx.LSM

	-- set frame type
	if (self.db.healthBarAttachTo == "Frame" or strfind(self.db.healthBarRelativePoint, "BOTTOM")) then
		self.isBar = true
	else
		self.isBar = false
	end

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

function HealthBar:GetAttachTo()
	return self.db.healthBarAttachTo
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

function HealthBar:UpdateColor(unit)
	if (not self.frame[unit]) then return end

	local class
	if GladiusEx:IsTesting(unit) then
		class = GladiusEx.testing[unit].unitClass
	else
		class = select(2, UnitClass(unit))
	end
	
	-- set color
	local color
	if self.db.healthBarClassColor then
		color = self:GetBarColor(class)
	else
		color = self.db.healthBarColor
	end
	self.frame[unit]:SetStatusBarColor(color.r, color.g, color.b, color.a or 1)
end

function HealthBar:UpdateHealth(unit, health, maxHealth)
	if (not self.frame[unit]) then return end

	-- update min max values
	self.frame[unit]:SetMinMaxValues(0, maxHealth)

	-- inverse bar
	if (self.db.healthBarInverse) then
		self.frame[unit]:SetValue(maxHealth - health)
	else
		self.frame[unit]:SetValue(health)
	end
end

function HealthBar:CreateBar(unit)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	-- create bar + text
	self.frame[unit] = CreateFrame("STATUSBAR", "GladiusEx" .. self:GetName() .. unit, button)
	self.frame[unit].background = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. unit .. "Background", "BACKGROUND")
	self.frame[unit].highlight = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. "Highlight" .. unit, "OVERLAY")
end

function HealthBar:Update(unit)
	-- create power bar
	if (not self.frame[unit]) then
		self:CreateBar(unit)
	end

	-- set bar type
	local parent = GladiusEx:GetAttachFrame(unit, self.db.healthBarAttachTo)

	if (self.db.healthBarAttachTo == "Frame" or strfind(self.db.healthBarRelativePoint, "BOTTOM")) then
		self.isBar = true
	else
		self.isBar = false
	end

	-- update health bar
	self.frame[unit]:ClearAllPoints()

	local width = self.db.healthBarAdjustWidth and GladiusEx.db.barWidth or self.db.healthBarWidth

	-- add width of the widget if attached to an widget
	if (self.db.healthBarAttachTo ~= "Frame" and not strfind(self.db.healthBarRelativePoint,"BOTTOM") and self.db.healthBarAdjustWidth) then
		if (not GladiusEx:GetModule(self.db.healthBarAttachTo).frame[unit]) then
			GladiusEx:GetModule(self.db.healthBarAttachTo):Update(unit)
		end

		width = width + GladiusEx:GetModule(self.db.healthBarAttachTo).frame[unit]:GetWidth()
	end

	self.frame[unit]:SetHeight(self.db.healthBarHeight)
	self.frame[unit]:SetWidth(width)

	self.frame[unit]:SetPoint(self.db.healthBarAnchor, parent, self.db.healthBarRelativePoint, self.db.healthBarOffsetX, self.db.healthBarOffsetY)
	self.frame[unit]:SetMinMaxValues(0, 100)
	self.frame[unit]:SetValue(100)
	self.frame[unit]:SetStatusBarTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, self.db.healthBarTexture))

	-- disable tileing
	self.frame[unit]:GetStatusBarTexture():SetHorizTile(false)
	self.frame[unit]:GetStatusBarTexture():SetVertTile(false)

	-- update health bar background
	self.frame[unit].background:ClearAllPoints()
	self.frame[unit].background:SetAllPoints(self.frame[unit])

	self.frame[unit].background:SetWidth(self.frame[unit]:GetWidth())
	self.frame[unit].background:SetHeight(self.frame[unit]:GetHeight())

	self.frame[unit].background:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, self.db.healthBarTexture))

	self.frame[unit].background:SetVertexColor(self.db.healthBarBackgroundColor.r, self.db.healthBarBackgroundColor.g,
		self.db.healthBarBackgroundColor.b, self.db.healthBarBackgroundColor.a)

	-- disable tileing
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

function HealthBar:GetBarHeight()
	return self.db.healthBarHeight
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
	if (not self.frame[unit]) then return end

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
	self:UpdateHealth(unit, health, maxHealth)
	self:UpdateColorEvent("Test", unit)
end

function HealthBar:GetOptions()
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
							disabled = function() return not self:IsEnabled() end,
							order = 5,
						},
						sep = {
							type = "description",
							name = "",
							width = "full",
							hidden = function() return not GladiusEx.db.advancedOptions end,
							order = 7,
						},
						healthBarColor = {
							type = "color",
							name = L["Color"],
							desc = L["Color of the health bar"],
							hasAlpha = true,
							get = function(info) return GladiusEx:GetColorOption(self.db, info) end,
							set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db, info, r, g, b, a) end,
							disabled = function() return self.db.healthBarClassColor or not self:IsEnabled() end,
							order = 10,
						},
						healthBarBackgroundColor = {
							type = "color",
							name = L["Background color"],
							desc = L["Color of the health bar background"],
							hasAlpha = true,
							get = function(info) return GladiusEx:GetColorOption(self.db, info) end,
							set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db, info, r, g, b, a) end,
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
						healthBarInverse = {
							type = "toggle",
							name = L["Inverse"],
							desc = L["Invert the bar colors"],
							disabled = function() return not self:IsEnabled() end,
							hidden = function() return not GladiusEx.db.advancedOptions end,
							order = 20,
						},
						healthBarTexture = {
							type = "select",
							name = L["Texture"],
							desc = L["Texture of the health bar"],
							dialogControl = "LSM30_Statusbar",
							values = AceGUIWidgetLSMlists.statusbar,
							disabled = function() return not self:IsEnabled() end,
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
							disabled = function() return not self:IsEnabled() end,
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
							disabled = function() return self.db.healthBarAdjustWidth or not self:IsEnabled() end,
							order = 15,
						},
						healthBarHeight = {
							type = "range",
							name = L["Height"],
							desc = L["Height of the health bar"],
							min = 10, max = 200, step = 1,
							disabled = function() return not self:IsEnabled() end,
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
						healthBarAttachTo = {
							type = "select",
							name = L["Attach to"],
							desc = L["Attach health bar to the given frame"],
							values = function() return HealthBar:GetAttachPoints() end,
							set = function(info, value)
								local key = info.arg or info[#info]

								if (strfind(self.db.healthBarRelativePoint, "BOTTOM")) then
									self.isBar = true
								else
									self.isBar = false
								end

								self.db[key] = value
								GladiusEx:UpdateFrames()
							end,
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
						healthBarAnchor = {
							type = "select",
							name = L["Anchor"],
							desc = L["Anchor of the health bar"],
							values = function() return GladiusEx:GetPositions() end,
							disabled = function() return not self:IsEnabled() end,
							order = 10,
						},
						healthBarRelativePoint = {
							type = "select",
							name = L["Relative point"],
							desc = L["Relative point of the health bar"],
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
						healthBarOffsetX = {
							type = "range",
							name = L["Offset X"],
							desc = L["X offset of the health bar"],
							min = -100, max = 100, step = 1,
							disabled = function() return  not self:IsEnabled() end,
							order = 20,
						},
						healthBarOffsetY = {
							type = "range",
							name = L["Offset Y"],
							desc = L["Y offset of the health bar"],
							disabled = function() return not self:IsEnabled() end,
							min = -100, max = 100, step = 1,
							order = 25,
						},
					},
				},
			},
		},
	}
end
