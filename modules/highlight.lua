local GladiusEx = _G.GladiusEx
local L = GladiusEx.L
local LSM

-- global functions
local strfind = string.find
local pairs = pairs
local GetRealNumRaidMembers, GetPartyAssignment, GetRaidTargetIndex = GetRealNumRaidMembers, GetPartyAssignment, GetRaidTargetIndex
local UnitGUID = UnitGUID

local Highlight = GladiusEx:NewGladiusExModule("Highlight", false, {
	highlightBorderWidth = 3,

	highlightHover = true,
	highlightHoverColor = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },

	highlightTarget = true,
	highlightTargetColor = { r = 1, g = .7, b = 0, a = 1 },
	highlightTargetPriority = 10,

	highlightFocus = true,
	highlightFocusColor = { r = 0, g = 0, b = 1, a = 1 },
	highlightFocusPriority = 0,

	highlightAssist = true,
	highlightAssistColor = { r = 0, g = 1, b = 0, a = 1 },
	highlightAssistPriority = 9,

	highlightRaidIcon1 = false,
	highlightRaidIcon1Color = { r = 1, g = 1, b = 0, a = 1 },
	highlightRaidIcon1Priority = 8,

	highlightRaidIcon2 = false,
	highlightRaidIcon2Color = { r = 1, g = 0.55, b = 0, a = 1 },
	highlightRaidIcon2Priority = 7,

	highlightRaidIcon3 = false,
	highlightRaidIcon3Color = { r = 1, g = 0.08, b = 0.58, a = 1 },
	highlightRaidIcon3Priority = 6,

	highlightRaidIcon4 = false,
	highlightRaidIcon4Color = { r = 0.13, g = 0.55, b = 0.13, a = 1 },
	highlightRaidIcon4Priority = 5,

	highlightRaidIcon5 = false,
	highlightRaidIcon5Color = { r = 0.86, g = 0.86, b = 0.86, a = 1 },
	highlightRaidIcon5Priority = 4,

	highlightRaidIcon6 = false,
	highlightRaidIcon6Color = { r = 0.12, g = 0.56, b = 1.0, a = 1 },
	highlightRaidIcon6Priority = 3,

	highlightRaidIcon7 = false,
	highlightRaidIcon7Color = { r = 1, g = 0.27, b = 0, a = 1 },
	highlightRaidIcon7Priority = 2,

	highlightRaidIcon8 = true,
	highlightRaidIcon8Color = { r = 1, g = 0, b = 0, a = 1 },
	highlightRaidIcon8Priority = 1,
})

function Highlight:OnEnable()
	self:RegisterEvent("UNIT_TARGET")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED", "UNIT_TARGET")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UNIT_TARGET")
	self:RegisterEvent("RAID_TARGET_UPDATE", "UNIT_TARGET")

	LSM = GladiusEx.LSM

	-- frame
	if (not self.frame) then
		self.frame = {}
	end
end

function Highlight:OnDisable()
	for unit in pairs(self.frame) do
		self.frame[unit]:SetAlpha(0)
	end
end

function Highlight:UNIT_TARGET(event, unit)
	local unit = unit or ""

	local playerTargetGUID = UnitGUID("target")
	local focusGUID = UnitGUID("focus")
	local targetGUID = UnitGUID(unit .. "target")

	for arenaUnit, frame in pairs(self.frame) do
		-- reset
		self:Reset(arenaUnit)

		if (targetGUID and UnitGUID(arenaUnit) == targetGUID and unit ~= "") then
			-- main assist
			if (GladiusEx.db.highlightAssist and GetPartyAssignment("MAINASSIST", unit) == 1) then
				if (frame.priority < GladiusEx.db.highlightTargetPriority) then
					frame.priority = GladiusEx.db.highlightTargetPriority
					frame:SetBackdropBorderColor(GladiusEx.db.highlightTargetColor.r, GladiusEx.db.highlightTargetColor.g, GladiusEx.db.highlightTargetColor.b, GladiusEx.db.highlightTargetColor.a)
				end
			end
		end

		-- raid target icon
		local icon = GetRaidTargetIndex(arenaUnit)
		if (icon and GladiusEx.db["highlightRaidIcon" .. icon]) then
			if (frame.priority < GladiusEx.db["highlightRaidIcon" .. icon .. "Priority"]) then
				frame.priority = GladiusEx.db["highlightRaidIcon" .. icon .. "Priority"]
				frame:SetBackdropBorderColor(GladiusEx.db["highlightRaidIcon" .. icon .. "Color"].r, GladiusEx.db["highlightRaidIcon" .. icon .. "Color"].g,
					GladiusEx.db["highlightRaidIcon" .. icon .. "Color"].b, GladiusEx.db["highlightRaidIcon" .. icon .. "Color"].a)
			end
		end

		-- focus
		if (focusGUID and UnitGUID(arenaUnit) == focusGUID) then
			if (frame.priority < GladiusEx.db.highlightFocusPriority) then
				frame.priority = GladiusEx.db.highlightFocusPriority
				frame:SetBackdropBorderColor(GladiusEx.db.highlightFocusColor.r, GladiusEx.db.highlightFocusColor.g, GladiusEx.db.highlightFocusColor.b, GladiusEx.db.highlightFocusColor.a)
			end
		end

		-- player target
		if (playerTargetGUID and UnitGUID(arenaUnit) == playerTargetGUID) then
			if (frame.priority < GladiusEx.db.highlightTargetPriority) then
				frame.priority = GladiusEx.db.highlightTargetPriority
				frame:SetBackdropBorderColor(GladiusEx.db.highlightTargetColor.r, GladiusEx.db.highlightTargetColor.g, GladiusEx.db.highlightTargetColor.b, GladiusEx.db.highlightTargetColor.a)
			end
		end
	end
end

function Highlight:CreateFrame(unit)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	-- create frame
	self.frame[unit] = CreateFrame("Frame", "GladiusEx" .. self:GetName() .. unit, button)

	self.frame[unit]:SetFrameLevel(20)

	-- set priority
	self.frame[unit].priority = -1
end

function Highlight:Update(unit)
	-- create frame
	if (not self.frame[unit]) then
		self:CreateFrame(unit)
	end

	-- update frame
	local left, right, top, bottom = GladiusEx.buttons[unit]:GetHitRectInsets()

	self.frame[unit]:ClearAllPoints()
	self.frame[unit]:SetPoint("TOPLEFT", GladiusEx.buttons[unit], "TOPLEFT", left - 3, top + 3)

	self.frame[unit]:SetWidth(GladiusEx.buttons[unit]:GetWidth() + abs(left) + abs(right) + 3)
	self.frame[unit]:SetHeight(GladiusEx.buttons[unit]:GetHeight() + abs(bottom) + abs(top) + 3)

	self.frame[unit]:SetBackdrop({edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = GladiusEx.db.highlightBorderWidth,})
	self.frame[unit]:SetBackdropBorderColor(0, 0, 0, 0)

	self.frame[unit]:SetFrameStrata("LOW")

	-- update highlight
	local button = GladiusEx.buttons[unit]
	local secure = button.secure

	if (GladiusEx.db.highlightHover) then
		-- set scripts
		if not button.highlight_hooked then
			button.highlight_hooked = true

			local onenterhook = function(f, motion)
				if (motion and f:GetAlpha() > 0) then
					for _, m in pairs(GladiusEx.modules) do
						if (m:IsEnabled() and m.frame and m.frame[unit].highlight) then
							-- set color
							m.frame[unit].highlight:SetVertexColor(GladiusEx.db.highlightHoverColor.r, GladiusEx.db.highlightHoverColor.g,
								GladiusEx.db.highlightHoverColor.b, GladiusEx.db.highlightHoverColor.a)

							-- set alpha
							m.frame[unit].highlight:SetAlpha(0.5)
						end
					end
				end
			end

			local onleavehook = function(f, motion)
				if (motion) then
					for _, m in pairs(GladiusEx.modules) do
						if (m:IsEnabled() and m.frame and m.frame[unit].highlight) then
							m.frame[unit].highlight:SetAlpha(0)
						end
					end
				end
			end

			button:HookScript("OnEnter", onenterhook)
			button:HookScript("OnLeave", onleavehook)

			secure:HookScript("OnEnter", onenterhook)
			secure:HookScript("OnLeave", onleavehook)
		end
	end

	-- hide
	self.frame[unit]:SetAlpha(0)

	-- update
	self:UNIT_TARGET("UNIT_TARGET", unit)
end

function Highlight:Show(unit)
	-- show
	self.frame[unit]:SetAlpha(1)

	local left, right, top, bottom = GladiusEx.buttons[unit]:GetHitRectInsets()

	self.frame[unit]:ClearAllPoints()
	self.frame[unit]:SetPoint("TOPLEFT", GladiusEx.buttons[unit], "TOPLEFT", left - 3, top + 3)

	self.frame[unit]:SetWidth(GladiusEx.buttons[unit]:GetWidth() + abs(left) + abs(right) + 3)
	self.frame[unit]:SetHeight(GladiusEx.buttons[unit]:GetHeight() + abs(bottom) + abs(top) + 3)
end

function Highlight:Reset(unit)
	if (not self.frame[unit]) then return end

	-- set priority
	self.frame[unit].priority = -1

	-- hide border
	self.frame[unit]:SetBackdropBorderColor(0, 0, 0, 0)
end

function Highlight:Test(unit)
	-- test
end

function Highlight:GetOptions()
	local options = {
		general = {
			type="group",
			name=L["General"],
			order=1,
			args = {
				highlightBorderWidth = {
					type="range",
					name=L["Highlight border width"],
					min=1, max=10, step=1,
					disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
					width="double",
					order=0.1,
				},
				hover = {
					type="group",
					name=L["Hover"],
					desc=L["Hover settings"],
					inline=true,
					order=1,
					args = {
						highlightHover = {
							type="toggle",
							name=L["Highlight On Mouseover"],
							desc=L["Highlight frame on mouseover"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						highlightHoverColor = {
							type="color",
							name=L["Highlight Color"],
							desc=L["Color of the highlight frame"],
							hasAlpha=true,
							get=function(info) return GladiusEx:GetColorOption(info) end,
							set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
					},
				},
				target = {
					type="group",
					name=L["Player Target"],
					desc=L["Player target settings"],
					inline=true,
					order=2,
					args = {
						highlightTarget = {
							type="toggle",
							name=L["Highlight Target"],
							desc=L["Show border around player target"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						highlightTargetColor = {
							type="color",
							name=L["Highlight Target Color"],
							desc=L["Color of the target border"],
							hasAlpha=true,
							get=function(info) return GladiusEx:GetColorOption(info) end,
							set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
						highlightTargetPriority = {
							type="range",
							name=L["Highlight Target Priority"],
							desc=L["Priority of the target border"],
							min=0, max=10, step=1,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							width="double",
							order=15,
						},
					},
				},
				focus = {
					type="group",
					name=L["Player Focus Target"],
					desc=L["Player focus target settings"],
					inline=true,
					order=2,
					args = {
						highlightFocus = {
							type="toggle",
							name=L["Highlight Focus Target"],
							desc=L["Show border around player target"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						highlightFocusColor = {
							type="color",
							name=L["Highlight Focus Target Color"],
							desc=L["Color of the focus target border"],
							hasAlpha=true,
							get=function(info) return GladiusEx:GetColorOption(info) end,
							set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
						highlightFocusPriority = {
							type="range",
							name=L["Highlight Focus Target Priority"],
							desc=L["Priority of the focus target border"],
							min=0, max=10, step=1,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							width="double",
							order=15,
						},
					},
				},
				assist = {
					type="group",
					name=L["Raid Assist Target"],
					desc=L["Raid assist settings"],
					inline=true,
					order=2,
					args = {
						highlightAssist = {
							type="toggle",
							name=L["Highlight Raid Assist"],
							desc=L["Show border around raid assist"],
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						highlightAssistColor = {
							type="color",
							name=L["Highlight Raid Assist Color"],
							desc=L["Color of the raid assist border"],
							hasAlpha=true,
							get=function(info) return GladiusEx:GetColorOption(info) end,
							set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
						highlightAssistPriority = {
							type="range",
							name=L["Highlight Raid Assist Priority"],
							desc=L["Priority of the raid assist border"],
							min=0, max=10, step=1,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							hidden=function() return not GladiusEx.db.advancedOptions end,
							width="double",
							order=15,
						},
					},
				},
			},
		},
		raidTargets = {
			type="group",
			name=L["Raid Icon Targets"],
			hidden=function() return not GladiusEx.db.advancedOptions end,
			order=2,
			args = {
			},
		},
	}

	-- raid targets
	for i=1, 8 do
		options.raidTargets.args["raidTarget" .. i] = {
			type="group",
			name="|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i .. ".blp:0|t " .. L["Raid Icon Target " .. i],
			inline=true,
			order=i,
			args = {
				highlightRaidIcon = {
					type="toggle",
					name=L["Highlight"],
					desc=L["Show border around raid target " .. i],
					disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
					arg="highlightRaidIcon" .. i,
					order=5,
				},
				highlightRaidIconColor = {
					type="color",
					name=L["Highlight Color"],
					desc=L["Color of the raid assist border"],
					hasAlpha=true,
					get=function(info) return GladiusEx:GetColorOption(info) end,
					set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
					disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
					arg="highlightRaidIcon" .. i .. "Color",
					order=10,
				},
				highlightRaidIconPriority = {
					type="range",
					name=L["Highlight Priority"],
					desc=L["Priority of the raid assist border"],
					min=0, max=10, step=1,
					disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
					hidden=function() return not GladiusEx.db.advancedOptions end,
					arg="highlightRaidIcon" .. i .. "Priority",
					width="double",
					order=15,
				},
			},
		}
	end

	return options
end
