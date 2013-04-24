local GladiusEx = _G.GladiusEx
local L = GladiusEx.L
local LSM

-- global functions
local strfind = string.find
local pairs = pairs
local UnitClass, UnitGUID, UnitHealth, UnitHealthMax = UnitClass, UnitGUID, UnitHealth, UnitHealthMax

local TargetBar = GladiusEx:NewGladiusExModule("TargetBar", false, {
	targetBarAttachTo = "ClassIcon",
	targetBarRelativePoint = "TOPLEFT",
	targetBarAnchor = "BOTTOMLEFT",
	targetBarOffsetX = 0,
	targetBarOffsetY = 0,

	targetBarHeight = 30,
	targetBarWidth = 200,

	targetBarInverse = false,
	targetBarColor = { r = 1, g = 1, b = 1, a = 1 },
	targetBarClassColor = true,
	targetBarBackgroundColor = { r = 1, g = 1, b = 1, a = 0.3 },
	targetBarTexture = "Minimalist",

	targetBarIconPosition = "LEFT",
	targetBarIcon = true,
	targetBarIconCrop = false,
})

function TargetBar:OnInitialize()
	-- init frames
	self.frame = {}
end

function TargetBar:OnEnable()
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("UNIT_HEALTH_FREQUENT", "UNIT_HEALTH")
	self:RegisterEvent("UNIT_MAXHEALTH", "UNIT_HEALTH")
	self:RegisterEvent("UNIT_TARGET")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", function() self:UNIT_TARGET("PLAYER_TARGET_CHANGED", "player") end)

	LSM = GladiusEx.LSM

	if (not self.frame) then
		self.frame = {}
	end
end

function TargetBar:OnDisable()
	self:UnregisterAllEvents()

	for unit in pairs(self.frame) do
		self.frame[unit]:SetAlpha(0)
	end
end

function TargetBar:GetAttachTo()
	return GladiusEx.db.targetBarAttachTo
end

function TargetBar:GetModuleAttachPoints()
	return {
		["TargetBar"] = L["TargetBar"],
	}
end

function TargetBar:GetAttachFrame(unit)
	if not self.frame[unit] then
		self:CreateBar(unit)
	end

	return self.frame[unit].statusbar
end

function TargetBar:SetClassIcon(unit)
	if (not self.frame[unit]) then return end

	-- self.frame[unit]:Hide()
	self.frame[unit].icon:Hide()
	self.frame[unit]:SetAlpha(0)

	-- get unit class
	local class
	if not GladiusEx:IsTesting(unit) then
		class = select(2, UnitClass(unit .. "target"))
	else
		class = GladiusEx.testing[unit].unitClass
	end

	if (class) then
		-- color
		local colorx = self:GetBarColor(class)
		if (colorx == nil) then
			--fallback, when targeting a pet or totem
			colorx = GladiusEx.db.targetBarColor
		end

		self.frame[unit].statusbar:SetStatusBarColor(colorx.r, colorx.g, colorx.b, colorx.a or 1)

		local healthx, maxHealthx = UnitHealth(unit .. "target"), UnitHealthMax(unit .. "target")
		self:UpdateHealth(unit, healthx, maxHealthx)

		self.frame[unit].icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")

		local left, right, top, bottom = unpack(CLASS_BUTTONS[class])

		if (GladiusEx.db.targetBarIconCrop) then
			-- zoom class icon
			left = left + (right - left) * 0.07
			right = right - (right - left) * 0.07
			top = top + (bottom - top) * 0.07
			bottom = bottom - (bottom - top) * 0.07
		end

		-- self.frame[unit]:Show()
		self.frame[unit]:SetAlpha(1)
		self.frame[unit].icon:Show()

		self.frame[unit].icon:SetTexCoord(left, right, top, bottom)
	end
end

function TargetBar:UNIT_TARGET(event, unit)
	if not self.frame[unit] then return end
	if UnitExists(unit .. "target") then
		self:SetClassIcon(unit)
		self.frame[unit]:SetAlpha(1)
	else
		self.frame[unit]:SetAlpha(0)
	end
end

function TargetBar:UNIT_HEALTH(event, unit)
	local foundUnit = nil

	for u, _ in pairs(self.frame) do
		if UnitIsUnit(unit, u .. "target") then
			foundUnit = u
			break
		end
	end

	if (not foundUnit) then return end

	local health, maxHealth = UnitHealth(foundUnit .. "target"), UnitHealthMax(foundUnit .. "target")
	self:UpdateHealth(foundUnit, health, maxHealth)
end

function TargetBar:UpdateHealth(unit, health, maxHealth)
	-- update min max values
	self.frame[unit].statusbar:SetMinMaxValues(0, maxHealth)

	-- inverse bar
	if (GladiusEx.db.targetBarInverse) then
		self.frame[unit].statusbar:SetValue(maxHealth - health)
	else
		self.frame[unit].statusbar:SetValue(health)
	end
end

function TargetBar:CreateBar(unit)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	-- create bar + text
	self.frame[unit] = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. unit, button)
	self.frame[unit].statusbar = CreateFrame("STATUSBAR", "GladiusEx" .. self:GetName() .. "Bar" .. unit, self.frame[unit])
	self.frame[unit].secure = CreateFrame("Button", "GladiusEx" .. self:GetName() .. "Secure" .. unit, self.frame[unit], "SecureActionButtonTemplate")
	self.frame[unit].background = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. unit .. "Background", "BACKGROUND")
	self.frame[unit].highlight = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. "Highlight" .. unit, "OVERLAY")
	self.frame[unit].icon = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. "IconFrame" .. unit, "ARTWORK")
	self.frame[unit].statusbar.unit = unit .. "target"

	ClickCastFrames = ClickCastFrames or {}
	ClickCastFrames[self.frame[unit].secure] = true
end

function TargetBar:Update(unit)
	-- create bar
	if (not self.frame[unit]) then
		self:CreateBar(unit)
	end

	-- update health bar
	local parent = GladiusEx:GetAttachFrame(unit, GladiusEx.db.targetBarAttachTo)

	self.frame[unit]:ClearAllPoints()
	self.frame[unit]:SetPoint(GladiusEx.db.targetBarAnchor, parent, GladiusEx.db.targetBarRelativePoint, GladiusEx.db.targetBarOffsetX, GladiusEx.db.targetBarOffsetY)
	self.frame[unit]:SetWidth(GladiusEx.db.targetBarWidth)
	self.frame[unit]:SetHeight(GladiusEx.db.targetBarHeight)

	-- update icon
	self.frame[unit].icon:ClearAllPoints()
	if GladiusEx.db.targetBarIcon then
		self.frame[unit].icon:SetPoint(GladiusEx.db.targetBarIconPosition, self.frame[unit], GladiusEx.db.targetBarIconPosition)
		self.frame[unit].icon:SetWidth(self.frame[unit]:GetHeight())
		self.frame[unit].icon:SetHeight(self.frame[unit]:GetHeight())
		self.frame[unit].icon:SetTexCoord(0, 1, 0, 1)
		self.frame[unit].icon:Show()
	else
		self.frame[unit].icon:Hide()
	end

	self.frame[unit].statusbar:ClearAllPoints()
	if GladiusEx.db.targetBarIcon then
		self.frame[unit].statusbar:SetPoint("TOPLEFT", self.frame[unit].icon, "TOPRIGHT")
		self.frame[unit].statusbar:SetPoint("BOTTOMRIGHT")
	else
		self.frame[unit].statusbar:SetAllPoints()
	end
	self.frame[unit].statusbar:SetMinMaxValues(0, 100)
	self.frame[unit].statusbar:SetValue(100)
	self.frame[unit].statusbar:SetStatusBarTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, GladiusEx.db.targetBarTexture))
	self.frame[unit].statusbar:GetStatusBarTexture():SetHorizTile(false)
	self.frame[unit].statusbar:GetStatusBarTexture():SetVertTile(false)

	-- update health bar background
	self.frame[unit].background:ClearAllPoints()
	self.frame[unit].background:SetAllPoints(self.frame[unit])
	self.frame[unit].background:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, GladiusEx.db.targetBarTexture))
	self.frame[unit].background:SetVertexColor(GladiusEx.db.targetBarBackgroundColor.r, GladiusEx.db.targetBarBackgroundColor.g,
		GladiusEx.db.targetBarBackgroundColor.b, GladiusEx.db.targetBarBackgroundColor.a)
	self.frame[unit].background:SetHorizTile(false)
	self.frame[unit].background:SetVertTile(false)

	-- update secure frame
	self.frame[unit].secure:ClearAllPoints()
	self.frame[unit].secure:SetAllPoints(self.frame[unit])
	self.frame[unit].secure:SetWidth(self.frame[unit]:GetWidth())
	self.frame[unit].secure:SetHeight(self.frame[unit]:GetHeight())
	self.frame[unit].secure:SetFrameStrata("LOW")
	self.frame[unit].secure:RegisterForClicks("AnyUp")
	self.frame[unit].secure:SetAttribute("unit", unit .. "target")
	self.frame[unit].secure:SetAttribute("type1", "target")

	-- update highlight texture
	self.frame[unit].highlight:ClearAllPoints()
	self.frame[unit].highlight:SetAllPoints(self.frame[unit])
	self.frame[unit].highlight:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	self.frame[unit].highlight:SetBlendMode("ADD")
	self.frame[unit].highlight:SetVertexColor(1.0, 1.0, 1.0, 1.0)
	self.frame[unit].highlight:SetAlpha(0)

	-- hide frame
	self.frame[unit]:Show()
	self.frame[unit]:SetAlpha(0)
end

function TargetBar:GetBarColor(class)
	return RAID_CLASS_COLORS[class]
end

function TargetBar:Show(unit)
	local testing = GladiusEx:IsTesting(unit)

	-- show frame
	self.frame[unit]:SetAlpha(1)

	-- get unit class
	local class
	if (not testing) then
		class = select(2, UnitClass(unit .. "target"))
	else
		class = GladiusEx.testing[unit].unitClass
	end

	-- set color
	if (not GladiusEx.db.targetBarClassColor) then
		local color = GladiusEx.db.targetBarColor
		self.frame[unit].statusbar:SetStatusBarColor(color.r, color.g, color.b, color.a)
	else
		local color = self:GetBarColor(class)
		if (color == nil) then
			-- fallback, when targeting a pet or totem
			color = GladiusEx.db.targetBarColor
		end

		self.frame[unit].statusbar:SetStatusBarColor(color.r, color.g, color.b, color.a or 1)
	end

	-- set class icon
	TargetBar:SetClassIcon(unit)

	-- call event
	if (not testing) then
		if not UnitExists(unit .. "target") then
			self.frame[unit]:SetAlpha(0)
		end
		self:UNIT_HEALTH("UNIT_HEALTH", unit)
	end
end

function TargetBar:Reset(unit)
	if (not self.frame[unit]) then return end

	-- reset bar
	self.frame[unit].statusbar:SetMinMaxValues(0, 1)
	self.frame[unit].statusbar:SetValue(1)

	-- reset texture
	self.frame[unit].icon:SetTexture("")

	-- hide
	self.frame[unit]:SetAlpha(0)
end

function TargetBar:Test(unit)
	-- set test values
	local maxHealth = GladiusEx.testing[unit].maxHealth
	local health = GladiusEx.testing[unit].health
	self:UpdateHealth(unit, health, maxHealth)
end

function TargetBar:GetOptions()
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
						targetBarClassColor = {
							type="toggle",
							name=L["Target bar class color"],
							desc=L["Toggle health bar class color"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						sep2 = {
							type = "description",
							name="",
							width="full",
							order=7,
						},
						targetBarColor = {
							type="color",
							name=L["Target bar color"],
							desc=L["Color of the health bar"],
							hasAlpha=true,
							get=function(info) return GladiusEx:GetColorOption(info) end,
							set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
							disabled=function() return GladiusEx.dbi.profile.targetBarClassColor or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
						targetBarBackgroundColor = {
							type="color",
							name=L["Target bar background color"],
							desc=L["Color of the health bar background"],
							hasAlpha=true,
							get=function(info) return GladiusEx:GetColorOption(info) end,
							set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=15,
						},
						sep3 = {
							type = "description",
							name="",
							width="full",
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=17,
						},
						targetBarInverse = {
							type="toggle",
							name=L["Target bar inverse"],
							desc=L["Inverse the health bar"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=20,
						},
						targetBarTexture = {
							type="select",
							name=L["Target bar texture"],
							desc=L["Texture of the health bar"],
							dialogControl = "LSM30_Statusbar",
							values = AceGUIWidgetLSMlists.statusbar,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=25,
						},
						sep4 = {
							type = "description",
							name="",
							width="full",
							order=27,
						},
						targetBarIcon = {
							type="toggle",
							name=L["Target bar class icon"],
							desc=L["Toggle the target bar class icon"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=30,
						},
						targetBarIconPosition = {
							type="select",
							name=L["Target bar icon position"],
							desc=L["Position of the target bar class icon"],
							values={ ["LEFT"] = L["LEFT"], ["RIGHT"] = L["RIGHT"] },
							disabled=function() return not GladiusEx.dbi.profile.targetBarIcon or not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=35,
						},
						sep6 = {
							type = "description",
							name="",
							width="full",
							order=37,
						},
						targetBarIconCrop = {
							type="toggle",
							name=L["Target Bar Icon Crop Borders"],
							desc=L["Toggle if the target bar icon borders should be cropped or not."],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							order=40,
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
						targetBarWidth = {
							type="range",
							name=L["Target bar width"],
							desc=L["Width of the health bar"],
							min=10, max=500, step=1,
							order=15,
						},
						targetBarHeight = {
							type="range",
							name=L["Target bar height"],
							desc=L["Height of the health bar"],
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
						targetBarAttachTo = {
							type="select",
							name=L["Target Bar Attach To"],
							desc=L["Attach health bar to the given frame"],
							values=function() return TargetBar:GetAttachPoints() end,
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
						targetBarAnchor = {
							type="select",
							name=L["Target Bar Anchor"],
							desc=L["Anchor of the health bar"],
							values=function() return GladiusEx:GetPositions() end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
						targetBarRelativePoint = {
							type="select",
							name=L["Target Bar Relative Point"],
							desc=L["Relative point of the health bar"],
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
						targetBarOffsetX = {
							type="range",
							name=L["Target bar offset X"],
							desc=L["X offset of the health bar"],
							min=-100, max=100, step=1,
							disabled=function() return  not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=20,
						},
						targetBarOffsetY = {
							type="range",
							name=L["Target bar offset Y"],
							desc=L["Y offset of the health bar"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							min=-100, max=100, step=1,
							order=25,
						},
					},
				},
			},
		},
	}
end
