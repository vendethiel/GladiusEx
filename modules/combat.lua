local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local fn = LibStub("LibFunctional-1.0")
local LSM = LibStub("LibSharedMedia-3.0")

-- global functions
local strfind = string.find
local pairs, unpack = pairs, unpack
local GetTime, GetSpellTexture, UnitGUID = GetTime, GetSpellTexture, UnitGUID

local defaults = {
	combatTrackerAdjustSize = true,
	combatTrackerSize = 40,
	combatTrackerCrop = true,
	combatTrackerOffsetX = 0,
	combatTrackerOffsetY = 0,
	combatTrackerFrameLevel = 8,
	combatTrackerGloss = false,
	combatTrackerGlossColor = { r = 1, g = 1, b = 1, a = 0.4 },
	combatTrackerUpdateRate = 0.05,
}

combatTracker = GladiusEx:NewGladiusExModule("CombatTracker",
	fn.merge(defaults, {
		combatTrackerAttachTo = "ClassIcon",
		combatTrackerAnchor = "RIGHT",
		combatTrackerRelativePoint = "LEFT",
		combatTrackerOffsetX = -2,
	}),
	fn.merge(defaults, {
		combatTrackerAttachTo = "ClassIcon",
		combatTrackerAnchor = "LEFT",
		combatTrackerRelativePoint = "RIGHT",
		combatTrackerOffsetX = 2,
	}))


function combatTracker:OnEnable()
	if not self.frame then
		self.frame = {}
	end
	
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:ZONE_CHANGED_NEW_AREA()
end

function combatTracker:OnDisable()
	for _, frame in pairs(self.frame) do
		frame:SetScript("OnUpdate", nil)
	end
	self:UnregisterAllEvents()

	for _, frame in pairs(self.frame) do
		frame:Hide()
	end
end

function combatTracker:GetFrames()
	return nil
end

function combatTracker:GetModuleAttachPoints()
	return {
		["CombatTracker"] = L["CombatTracker"],
	}
end

function combatTracker:GetModuleAttachFrame(unit)
	if not self.frame[unit] then
		self:CreateFrame(unit)
	end

	return self.frame[unit]
end

function combatTracker:ZONE_CHANGED_NEW_AREA()
	if IsActiveBattlefieldArena() then
		for _, frame in pairs(self.frame) do
			frame.timer = frame.timer or 0
			frame:SetScript("OnUpdate", function(f, elapsed)
			    f.timer = f.timer + elapsed
				if f.timer < combatTracker.db[f.unit].combatTrackerUpdateRate then
					return
				end
				f.timer = 0 
				if UnitAffectingCombat(f.unit) then f:SetAlpha(1) else f:SetAlpha(0) end 
			end)
		end
	else
		for _, frame in pairs(self.frame) do
			frame:SetScript("OnUpdate", nil)
		end
	end
end


function combatTracker:UpdateIcon(unit, combatCat)
	local tracked = self.frame[unit]

	tracked:EnableMouse(false)

	tracked:SetWidth(self.frame[unit]:GetHeight())
	tracked:SetHeight(self.frame[unit]:GetHeight())

	tracked.normalTexture:SetTexture([[Interface\AddOns\GladiusEx\media\gloss]])
	tracked.normalTexture:SetVertexColor(self.db[unit].combatTrackerGlossColor.r, self.db[unit].combatTrackerGlossColor.g,
		self.db[unit].combatTrackerGlossColor.b, self.db[unit].combatTrackerGloss and self.db[unit].combatTrackerGlossColor.a or 0)

	-- style action button
	tracked.normalTexture:SetHeight(self.frame[unit]:GetHeight() + self.frame[unit]:GetHeight() * 0.4)
	tracked.normalTexture:SetWidth(self.frame[unit]:GetWidth() + self.frame[unit]:GetWidth() * 0.4)

	tracked.normalTexture:ClearAllPoints()
	tracked.normalTexture:SetPoint("CENTER", 0, 0)

	tracked.texture:ClearAllPoints()
	tracked.texture:SetPoint("TOPLEFT", tracked, "TOPLEFT")
	tracked.texture:SetPoint("BOTTOMRIGHT", tracked, "BOTTOMRIGHT")
	tracked.texture:SetTexture("Interface\\Icons\\ABILITY_DUALWIELD")
	if self.db[unit].combatTrackerCrop then
		local n = 5
		tracked.texture:SetTexCoord(n / 64, 1 - n / 64, n / 64, 1 - n / 64)
	else
		tracked.texture:SetTexCoord(0, 1, 0, 1)
	end
end

function combatTracker:CreateFrame(unit)
	local button = GladiusEx.buttons[unit]
	if not button then return end

	-- create frame
	local f = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. "Frame" .. unit, button)
	
	f.texture = f:CreateTexture(nil, "ARTWORK")
	f.texture:SetAllPoints()

	f.normalTexture = f:CreateTexture(nil, "OVERLAY")
	f.normalTexture:SetAllPoints()
	f.unit = unit
	self.frame[unit] = f
end

function combatTracker:Update(unit)
	-- create frame
	if not self.frame[unit] then
		self:CreateFrame(unit)
	end

	-- update frame
	self.frame[unit]:ClearAllPoints()

	-- anchor point
	local parent = GladiusEx:GetAttachFrame(unit, self.db[unit].combatTrackerAttachTo)
	self.frame[unit]:SetPoint(self.db[unit].combatTrackerAnchor, parent, self.db[unit].combatTrackerRelativePoint, self.db[unit].combatTrackerOffsetX, self.db[unit].combatTrackerOffsetY)

	-- frame level
	self.frame[unit]:SetFrameLevel(self.db[unit].combatTrackerFrameLevel)

	local size = self.db[unit].combatTrackerSize
	if self.db[unit].combatTrackerAdjustSize then
		size = parent:GetHeight()
	end
	self.frame[unit]:SetSize(size, size)

	-- update icons
	self.frame[unit].normalTexture:SetHeight(self.frame[unit]:GetHeight() + self.frame[unit]:GetHeight() * 0.4)
	self.frame[unit].normalTexture:SetWidth(self.frame[unit]:GetWidth() + self.frame[unit]:GetWidth() * 0.4)

	self:UpdateIcon(unit)

	-- hide
	self.frame[unit]:Hide()
end

function combatTracker:Show(unit)
	-- show frame
	self.frame[unit]:Show()
end

function combatTracker:Reset(unit)
	if not self.frame[unit] then return end

	-- hide
	self.frame[unit]:Hide()
end

function combatTracker:Test(unit)
	local ret = math.random()
	self.frame[unit]:SetAlpha(ret >= 0.5 and 1 or 0) 
end

function combatTracker:GetOptions(unit)
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

						combatTrackerCrop = {
							type = "toggle",
							name = L["Crop borders"],
							desc = L["Toggle if the icon borders should be cropped or not"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 16,
						},
						sep3 = {
							type = "description",
							name = "",
							width = "full",
							order = 17,
						},
						combatTrackerGloss = {
							type = "toggle",
							name = L["Gloss"],
							desc = L["Toggle gloss on the icon"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 25,
						},
						combatTrackerGlossColor = {
							type = "color",
							name = L["Gloss color"],
							desc = L["Color of the gloss"],
							get = function(info) return GladiusEx:GetColorOption(self.db[unit], info) end,
							set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db[unit], info, r, g, b, a) end,
							hasAlpha = true,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 30,
						},
						combatTrackerUpdateRate = {
							type = "range",
							name = "Update Rate",
							desc = "Sets the update rate of the combat tracker, lower rate is faster and more precise but more CPU intensive.",
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							softMin = 0.01, softMax = 0.2, step = 0.01,
							order = 30,
						},
						sep4 = {
							type = "description",
							name = "",
							width = "full",
							order = 33,
						},
						combatTrackerFrameLevel = {
							type = "range",
							name = L["Frame level"],
							desc = L["Frame level of the frame"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							softMin = 1, softMax = 100, step = 1,
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
						sep = {
							type = "description",
							name = "",
							width = "full",
							order = 6,
						},
						combatTrackerAdjustSize = {
							type = "toggle",
							name = L["Adjust size"],
							desc = L["Adjust size to the frame size"],
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 7,
						},
						combatTrackerSize = {
							type = "range",
							name = L["Icon size"],
							desc = L["Size of the icons"],
							min = 1, softMin = 10, softMax = 100, bigStep = 1,
							disabled = function() return self.db[unit].combatTrackerAdjustSize or not self:IsUnitEnabled(unit) end,
							order = 10,
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
						combatTrackerAttachTo = {
							type = "select",
							name = L["Attach to"],
							desc = L["Attach to the given frame"],
							values = function() return self:GetOtherAttachPoints(unit) end,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 1,
						},
						combatTrackerPosition = {
							type = "select",
							name = L["Position"],
							desc = L["Position of the frame"],
							values = GladiusEx:GetGrowSimplePositions(),
							get = function()
								return GladiusEx:GrowSimplePositionFromAnchor(
									self.db[unit].combatTrackerAnchor,
									self.db[unit].combatTrackerRelativePoint,
									self.db[unit].combatTrackerGrowDirection)
							end,
							set = function(info, value)
								self.db[unit].combatTrackerAnchor, self.db[unit].combatTrackerRelativePoint =
									GladiusEx:AnchorFromGrowSimplePosition(value, self.db[unit].combatTrackerGrowDirection)
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
							order = 8,
						},
						combatTrackerAnchor = {
							type = "select",
							name = L["Anchor"],
							desc = L["Anchor of the frame"],
							values = GladiusEx:GetPositions(),
							disabled = function() return not self:IsUnitEnabled(unit) end,
							hidden = function() return not GladiusEx.db.base.advancedOptions end,
							order = 10,
						},
						combatTrackerRelativePoint = {
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
						combatTrackerOffsetX = {
							type = "range",
							name = L["Offset X"],
							desc = L["X offset of the frame"],
							softMin = -100, softMax = 100, bigStep = 1,
							disabled = function() return not self:IsUnitEnabled(unit) end,
							order = 20,
						},
						combatTrackerOffsetY = {
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
	return options
end
