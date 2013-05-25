local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM = LibStub("LibSharedMedia-3.0")
local fn = LibStub("LibFunctional-1.0")

-- global functions
local strfind = string.find
local select, pairs, unpack = select, pairs, unpack
local UnitExists, UnitIsUnit, UnitClass = UnitExists, UnitIsUnit, UnitClass
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax

local defaults = {
	targetBarOffsetX = 0,
	targetBarOffsetY = 0,
	targetBarHeight = 20,
	targetBarWidth = 120,
	targetBarInverse = false,
	targetBarColor = { r = 1, g = 1, b = 1, a = 1 },
	targetBarClassColor = true,
	targetBarBackgroundColor = { r = 1, g = 1, b = 1, a = 0.3 },
	targetBarGlobalTexture = true,
	targetBarTexture = GladiusEx.default_bar_texture,
	targetBarIcon = true,
	targetBarIconCrop = true,
}

local TargetBar = GladiusEx:NewGladiusExModule("TargetBar",
	fn.merge(defaults, {
		targetBarAttachTo = "Frame",
		targetBarRelativePoint = "TOPLEFT",
		targetBarAnchor = "BOTTOMLEFT",
		targetBarIconPosition = "LEFT",
	}),
	fn.merge(defaults, {
		targetBarAttachTo = "Frame",
		targetBarRelativePoint = "TOPRIGHT",
		targetBarAnchor = "BOTTOMRIGHT",
		targetBarIconPosition = "RIGHT",
	}))

function TargetBar:OnEnable()
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("UNIT_HEALTH_FREQUENT", "UNIT_HEALTH")
	self:RegisterEvent("UNIT_MAXHEALTH", "UNIT_HEALTH")
	self:RegisterEvent("UNIT_TARGET")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", function() self:UNIT_TARGET("PLAYER_TARGET_CHANGED", "player") end)

	if not self.frame then
		self.frame = {}
	end
end

function TargetBar:OnDisable()
	self:UnregisterAllEvents()

	for unit in pairs(self.frame) do
		self.frame[unit]:Hide()
	end
end

function TargetBar:GetModuleAttachPoints()
	return {
		["TargetBar"] = L["TargetBar"],
	}
end

function TargetBar:GetModuleAttachFrame(unit)
	if not self.frame[unit] then
		self:CreateBar(unit)
	end

	return self.frame[unit].statusbar
end

function TargetBar:SetClassIcon(unit)
	if not self.frame[unit] then return end

	-- get unit class
	local class
	if not GladiusEx:IsTesting(unit) then
		class = select(2, UnitClass(unit .. "target"))
	else
		class = GladiusEx.testing[unit].unitClass
	end

	if class then
		-- color
		-- fallback, when targeting a pet or totem
		local color = self:GetBarColor(class) or self.db[unit].targetBarColor

		self.frame[unit].statusbar:SetStatusBarColor(color.r, color.g, color.b, color.a or 1)
		self.frame[unit].icon:SetTexture([[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]])

		local left, right, top, bottom = unpack(CLASS_BUTTONS[class])
		if self.db[unit].targetBarIconCrop then
			local n = 5
			-- zoom class icon
			left = left + (right - left) * (n / 64)
			right = right - (right - left) * (n / 64)
			top = top + (bottom - top) * (n / 64)
			bottom = bottom - (bottom - top) * (n / 64)
		end

		self.frame[unit].icon:SetTexCoord(left, right, top, bottom)
	end
end

function TargetBar:UNIT_TARGET(event, unit)
	if not self.frame[unit] then return end

	self:Refresh(unit)
end

function TargetBar:UNIT_HEALTH(event, unit)
	-- while the target units are polled, most targets will actually be
	-- a valid unit, so we search for it here
	for owner_unit, frame in pairs(self.frame) do
		if UnitIsUnit(unit, frame.unit) then
			self:UpdateHealth(owner_unit, UnitHealth(unit), UnitHealthMax(unit))
			return
		end
	end
end

function TargetBar:UpdateHealth(unit, health, maxHealth)
	-- update min max values
	self.frame[unit].statusbar:SetMinMaxValues(0, maxHealth)

	-- inverse bar
	if self.db[unit].targetBarInverse then
		self.frame[unit].statusbar:SetValue(maxHealth - health)
	else
		self.frame[unit].statusbar:SetValue(health)
	end
end

function TargetBar:GetBarColor(class)
	return RAID_CLASS_COLORS[class]
end

function TargetBar:Show(unit)
	local testing = GladiusEx:IsTesting(unit)

	if self.frame[unit].unit ~= "target" then
		-- not a real unit so it needs to be polled
		self.frame[unit]:SetScript("OnUpdate", TargetBar_OnUpdate)
	end

	-- show frame
	self.frame[unit]:Show()
end

function TargetBar:Refresh(unit)
	local tunit = self.frame[unit].unit
	if UnitExists(tunit) then
		self:SetClassIcon(unit)
		self:UpdateHealth(unit, UnitHealth(tunit), UnitHealthMax(tunit))
		self.frame[unit]:Show()
	else
		self.frame[unit]:Hide()
	end
end

function TargetBar:Reset(unit)
	if not self.frame[unit] then return end

	-- reset bar
	self.frame[unit].statusbar:SetMinMaxValues(0, 1)
	self.frame[unit].statusbar:SetValue(1)

	-- reset texture
	self.frame[unit].icon:SetTexture("")

	-- hide
	self.frame[unit]:Hide()
	self.frame[unit]:SetScript("OnUpdate", nil)
end

function TargetBar:Test(unit)
	-- set test values
	local maxHealth = GladiusEx.testing[unit].maxHealth
	local health = GladiusEx.testing[unit].health
	self:SetClassIcon(unit)
	self:UpdateHealth(unit, health, maxHealth)
	self.frame[unit]:Show()
	self.frame[unit]:SetScript("OnUpdate", nil)
end

local polling_time = 0.5
local function TargetBar_OnUpdate(frame, elapsed)
	frame.next_update = frame.next_update - elapsed
	if frame.next_update <= 0 then
		frame.next_update = polling_time
		TargetBar:Refresh(frame.owner_unit)
	end
end

function TargetBar:CreateBar(unit)
	local button = GladiusEx.buttons[unit]
	if not button then return end

	local tunit = unit == "player" and "target" or (unit .. "target")

	-- create bar + text
	self.frame[unit] = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. unit, button)
	self.frame[unit].statusbar = CreateFrame("STATUSBAR", "GladiusEx" .. self:GetName() .. "Bar" .. unit, self.frame[unit])
	self.frame[unit].secure = CreateFrame("Button", "GladiusEx" .. self:GetName() .. "Secure" .. unit, button, "SecureActionButtonTemplate")
	self.frame[unit].background = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. unit .. "Background", "BACKGROUND")
	self.frame[unit].icon = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. "IconFrame" .. unit, "ARTWORK")
	self.frame[unit].statusbar.unit = tunit
	self.frame[unit].unit = tunit
	self.frame[unit].owner_unit = unit
	self.frame[unit].next_update = 0

	-- clique support
	ClickCastFrames = ClickCastFrames or {}
	ClickCastFrames[self.frame[unit].secure] = true
end

function TargetBar:Update(unit)
	-- create bar
	if not self.frame[unit] then
		self:CreateBar(unit)
	end

	local parent = GladiusEx:GetAttachFrame(unit, self.db[unit].targetBarAttachTo)
	local width = self.db[unit].targetBarWidth
	local height = self.db[unit].targetBarHeight
	local bar_texture = self.db[unit].targetBarGlobalTexture and LSM:Fetch(LSM.MediaType.STATUSBAR, GladiusEx.db.base.globalBarTexture) or LSM:Fetch(LSM.MediaType.STATUSBAR, self.db[unit].targetBarTexture)

	self.frame[unit]:ClearAllPoints()
	self.frame[unit]:SetPoint(self.db[unit].targetBarAnchor, parent, self.db[unit].targetBarRelativePoint, self.db[unit].targetBarOffsetX, self.db[unit].targetBarOffsetY)
	self.frame[unit]:SetWidth(width)
	self.frame[unit]:SetHeight(height)

	-- update icon
	self.frame[unit].icon:ClearAllPoints()
	if self.db[unit].targetBarIcon then
		self.frame[unit].icon:SetPoint(self.db[unit].targetBarIconPosition, self.frame[unit], self.db[unit].targetBarIconPosition)
		self.frame[unit].icon:SetWidth(height)
		self.frame[unit].icon:SetHeight(height)
		self.frame[unit].icon:SetTexCoord(0, 1, 0, 1)
		self.frame[unit].icon:Show()
	else
		self.frame[unit].icon:Hide()
	end

	-- update health bar
	self.frame[unit].statusbar:ClearAllPoints()
	if self.db[unit].targetBarIcon then
		if self.db[unit].targetBarIconPosition == "LEFT" then
			self.frame[unit].statusbar:SetPoint("LEFT", self.frame[unit].icon, "RIGHT")
			self.frame[unit].statusbar:SetPoint("RIGHT")
		else
			self.frame[unit].statusbar:SetPoint("LEFT")
			self.frame[unit].statusbar:SetPoint("RIGHT", self.frame[unit].icon, "LEFT")
		end
		self.frame[unit].statusbar:SetHeight(height)
	else
		self.frame[unit].statusbar:SetAllPoints()
	end
	self.frame[unit].statusbar:SetMinMaxValues(0, 100)
	self.frame[unit].statusbar:SetValue(100)
	self.frame[unit].statusbar:SetStatusBarTexture(bar_texture)
	self.frame[unit].statusbar:GetStatusBarTexture():SetHorizTile(false)
	self.frame[unit].statusbar:GetStatusBarTexture():SetVertTile(false)

	-- update health bar background
	self.frame[unit].background:ClearAllPoints()
	self.frame[unit].background:SetAllPoints(self.frame[unit])
	self.frame[unit].background:SetTexture(bar_texture)
	self.frame[unit].background:SetVertexColor(self.db[unit].targetBarBackgroundColor.r, self.db[unit].targetBarBackgroundColor.g,
		self.db[unit].targetBarBackgroundColor.b, self.db[unit].targetBarBackgroundColor.a)
	self.frame[unit].background:SetHorizTile(false)
	self.frame[unit].background:SetVertTile(false)

	-- update secure frame
	self.frame[unit].secure:ClearAllPoints()
	self.frame[unit].secure:SetPoint(self.db[unit].targetBarAnchor, parent, self.db[unit].targetBarRelativePoint, self.db[unit].targetBarOffsetX, self.db[unit].targetBarOffsetY)
	self.frame[unit].secure:SetWidth(width)
	self.frame[unit].secure:SetHeight(height)
	self.frame[unit].secure:SetFrameStrata("MEDIUM")
	self.frame[unit].secure:RegisterForClicks("AnyDown")
	self.frame[unit].secure:SetAttribute("unit", unit .. "target")
	self.frame[unit].secure:SetAttribute("type1", "target")

	-- hide frame
	self.frame[unit]:Hide()
end

function TargetBar:GetOptions(unit)
	-- values for simple positioning
	local positions = {
		["TOPLEFT"] = L["Top left"],
		["TOPRIGHT"] = L["Top right"],
		["LEFTTOP"] = L["Left top"],
		["LEFTBOTTOM"] = L["Left bottom"],
		["RIGHTTOP"] = L["Right top"],
		["RIGHTBOTTOM"] = L["Right bottom"],
		["BOTTOMLEFT"] = L["Bottom left"],
		["BOTTOMRIGHT"] = L["Bottom right"],
	}

	local pos_rel = {
		["LEFTTOP"] = "TOPLEFT",
		["LEFTBOTTOM"] = "BOTTOMLEFT",
		["RIGHTTOP"] = "TOPRIGHT",
		["RIGHTBOTTOM"] = "BOTTOMRIGHT",
	}

	local pos_anchor = {
		["TOPLEFT"] = "BOTTOMLEFT",
		["TOPRIGHT"] = "BOTTOMRIGHT",
		["LEFTTOP"] = "TOPRIGHT",
		["LEFTBOTTOM"] = "BOTTOMRIGHT",
		["RIGHTTOP"] = "TOPLEFT",
		["RIGHTBOTTOM"] = "BOTTOMLEFT",
		["BOTTOMLEFT"] = "TOPLEFT",
		["BOTTOMRIGHT"] = "TOPRIGHT",
	}

	local function pos_to_anchor(pos)
		local anchor = pos_anchor[pos]
		local relative = pos_rel[pos] or pos
		return anchor, relative
	end

	local function anchor_to_pos(anchor, relative)
		for pos in pairs(positions) do
			local panchor, prelative = pos_to_anchor(pos)
			if panchor == anchor and prelative == relative then
				return pos
			end
		end
	end

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
						targetBarClassColor = {
							type = "toggle",
							name = L["Class color"],
							desc = L["Toggle health bar class color"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 5,
						},
						targetBarColor = {
							type = "color",
							name = L["Color"],
							desc = L["Color of the health bar"],
							hasAlpha = true,
							get = function(info) return GladiusEx:GetColorOption(self.db[unit], info) end,
							set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db[unit], info, r, g, b, a) end,
							disabled = function() return self.db[unit].targetBarClassColor or not self:IsUnitEnabled(unit) end,
							order = 10,
						},
						targetBarBackgroundColor = {
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
						sep3 = {
							type = "description",
							name = "",
							width = "full",
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 17,
						},
						targetBarInverse = {
							type = "toggle",
							name = L["Inverse"],
							desc = L["Invert the bar colors"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 20,
						},
						sep4 = {
							type = "description",
							name = "",
							width = "full",
							order = 21,
						},
						targetBarGlobalTexture = {
							type = "toggle",
							name = L["Use global texture"],
							desc = L["Use the global bar texture"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 22,
						},
						targetBarTexture = {
							type = "select",
							name = L["Texture"],
							desc = L["Texture of the health bar"],
							dialogControl = "LSM30_Statusbar",
							values = AceGUIWidgetLSMlists.statusbar,
							disabled = function() return self.db[unit].targetBarGlobalTexture or not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 25,
						},
						sep5 = {
							type = "description",
							name = "",
							width = "full",
							order = 27,
						},
						targetBarIcon = {
							type = "toggle",
							name = L["Class icon"],
							desc = L["Toggle the target bar class icon"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 30,
						},
						targetBarIconPosition = {
							type = "select",
							name = L["Icon position"],
							desc = L["Position of the target bar class icon"],
							values = { ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"] },
							disabled = function() return not self.db[unit].targetBarIcon or not self:IsUnitEnabled(unit) end,
							order = 35,
						},
						targetBarIconCrop = {
							type = "toggle",
							name = L["Crop borders"],
							desc = L["Toggle if the icon borders should be cropped or not"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 40,
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
						targetBarWidth = {
							type = "range",
							name = L["Width"],
							desc = L["Frame width"],
							softMin = 10, softMax = 500, bigStep = 1,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 15,
						},
						targetBarHeight = {
							type = "range",
							name = L["Height"],
							desc = L["Frame height"],
							softMin = 10, softMax = 200, bigStep = 1,
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
					order = 3,
					args = {
						targetBarAttachTo = {
							type = "select",
							name = L["Attach to"],
							desc = L["Attach to the given frame"],
							values = function() return self:GetOtherAttachPoints(unit) end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 1,
						},
						targetBarPosition = {
							type = "select",
							name = L["Position"],
							desc = L["Position of the frame"],
							values = positions,
							get = function()
								return anchor_to_pos(self.db[unit].targetBarAnchor, self.db[unit].targetBarRelativePoint)
							end,
							set = function(info, value)
								self.db[unit].targetBarAnchor, self.db[unit].targetBarRelativePoint = pos_to_anchor(value)
								GladiusEx:UpdateFrames()
							end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return GladiusEx.db.base.advancedOptions end,
							order = 2,
						},
						sep = {
							type = "description",
							name = "",
							width = "full",
							order = 7,
						},
						targetBarAnchor = {
							type = "select",
							name = L["Anchor"],
							desc = L["Anchor of the frame"],
							values = GladiusEx:GetPositions(),
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 10,
						},
						targetBarRelativePoint = {
							type = "select",
							name = L["Relative point"],
							desc = L["Relative point of the frame"],
							values = GladiusEx:GetPositions(),
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
						targetBarOffsetX = {
							type = "range",
							name = L["Offset X"],
							desc = L["X offset of the frame"],
							softMin = -100, softMax = 100, bigStep = 1,
							disabled = function() return  not self:IsUnitEnabled(unit) end,
							order = 20,
						},
						targetBarOffsetY = {
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
end
