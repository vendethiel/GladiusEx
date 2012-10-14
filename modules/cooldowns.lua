local Gladius = _G.Gladius
if not Gladius then
  DEFAULT_CHAT_FRAME:AddMessage(format("Module %s requires Gladius", "Cooldowns"))
end
local L = Gladius.L
local LSM

-- global functions
local strfind = string.find
local pairs = pairs

-- http://www.wowwiki.com/Specialization_IDs
local SpellData = {
	-- Mage
	-- Counterspell
	[2139] = {
		class = "MAGE",
		cooldown = 24,
	},

	-- Priest/all
	-- Hymn of Hope
	[64901] = {
		class = "PRIEST",
		duration = 8,
		cooldown = 360,
	},
	-- Psychic Scream
	[8122] = {
		class = "PRIEST",
		duration = 10,
		cooldown = 27,
	},
	-- Shadowfiend
	[34433] = {
		class = "PRIEST",
		duration = 12,
		cooldown =  180,
	},
	-- Leap of Faith
	[73325] = {
		class = "PRIEST",
		cooldown = 90,
	},
	-- Void Shift
	[108968] = {
		class = "PRIEST",
		cooldown = 360,
	},

	-- Priest/Talents
	-- Void Tendrils
	[108920] = {
		class = "PRIEST",
		talent = true,
		cooldown =  30
	},
	-- Psyfiend
	[108921] = {
		class = "PRIEST",
		talent = true,
		cooldown =  45
	},
	-- Phantasm
	[108942] = {
		class = "PRIEST",
		talent = true,
		cooldown =  30
	},
	-- Mindbender
	[123040] = {
		class = "PRIEST",
		talent = true,
		replaces = 34433,
		cooldown =  60
	},
	-- Desperate Prayer
	[19236] = {
		class = "PRIEST",
		talent = true,
		cooldown =  120
	},
	-- Spectral Guise
	[112833] = {
		class = "PRIEST",
		talent = true,
		cooldown =  30
	},
	-- Angelic Bulwark
	[108945] = {
		class = "PRIEST",
		talent = true,
		cooldown =  90
	},
	-- Power Infusion
	[10060] = {
		class = "PRIEST",
		talent = true,
		cooldown =  120
	},
	-- Cascade
	[121135] = {
		class = "PRIEST",
		talent = true,
		cooldown =  25
	},
	-- Divine Star
	[110744] = {
		class = "PRIEST",
		talent = true,
		cooldown =  15
	},
	-- Halo
	[120517] = {
		class = "PRIEST",
		talent = true,
		cooldown =  40
	},

	-- Priest/Discipline
	-- Glyph of Inner Focus
	[96267] = {
		class = "PRIEST",
		specID = 256,
		duration = 5, -- Glyph
		cooldown = 45,
	},
	-- Inner Focus
	[89485] = {
		class = "PRIEST",
		specID = 256,
		cooldown_starts_after_cast = {
			2061, -- Flash Heal
			2060, -- Greater Heal
			596, -- Prayer of Healing
		},
		cooldown = 45,
	},
	-- Pain Suppression
	[33206] = {
		class = "PRIEST",
		specID = 256,
		duration = 10,
		cooldown = 180,
	},
	-- Power Word: Barrier
	[62618] = {
		class = "PRIEST",
		specID = 256,
		cooldown = 180,
	},
	-- Spirit Shell
	[109964] = {
		class = "PRIEST",
		specID = 256,
		cooldown = 60,
	},
	
	-- Priest/Holy
	-- Guardian Spirit
	[47788] = {
		class = "PRIEST",
		specID = 257,
		duration = 10,
		cooldown = 180,
	},
	-- Lightwell
	[724] = {
		class = "PRIEST",
		specID = 257,
		duration = 180,
		cooldown = 180,
	},
	-- Divine Hymn
	[64843] = {
		class = "PRIEST",
		specID = 257,
		duration = 8,
		cooldown = 18
	},
	-- Holy Word: Chastise
	[88625] = {
		class = "PRIEST",
		specID = 257,
		duration = 3,
		cooldown = 30
	},
	
	-- Priest/Shadow
	-- Dispersion
	[47585] = {
		class = "PRIEST",
		specID = 258,
		duration = 6,
		cooldown = 105, -- 120
	},
	-- Silence
	[15487] = {
		class = "PRIEST",
		specID = 258,
		duration = 10,
		cooldown = 45,
	},

	-- Items
	-- PvP Trinket
	[42292] = {
		item = true,
		icon_alliance = [[Interface\Icons\INV_Jewelry_TrinketPVP_01]],
		icon_horde = [[Interface\Icons\INV_Jewelry_TrinketPVP_02]],
		cooldown = 120,
	},

	-- Racials
	-- Every Man for Himself (Human)
	[59752] = 42292,
	-- Gift of the Naaru (Draenei)
	[59544] = {
		race = "Draenei",
		duration = 15,
		cooldown = 180,
	},
	[59545] = 59544,
	[59543] = 59544,
	[59548] = 59544,
	[121093] = 59544,
	[59542] = 59544,
	[59547] = 59544,
	[28880] = 59544,
	-- Arcane Torrent (Blood Elf)
	[28730] = {
		race = "Blood Elf",
		duration = 2,
		cooldown = 120,
	},
	[50613] = 28730,
	[80483] = 28730,
	[129597] = 28730,
	[25046] = 28730,
	[69179] = 28730,
	-- Blood Fury (Orc)
	[20572] = {
		race = "Orc",
		duration = 15,
		cooldown = 120,
	},
	[33697] = 20572,
	[33702] = 20572,
	-- Cannibalize (Undead)
	[20577] = {
		race = "Undead",
		duration = 10,
		cooldown = 120,
	},
	-- Will of the Forsaken (Undead)
	[7744] = {
		race = "Undead",
		cooldown = 120,
	},
	-- Darkflight (Worgen)
	[68992] = {
		race = "Worgen",
		duration = 10,
		cooldown = 120,
	},
	-- Escape Artist (Gnome)
	[20589] = {
		race = "Gnome",
		cooldown = 90,
	},
	-- Quaking Palm (Pandaren)
	[107079] = {
		race = "Pandaren",
		duration = 4,
		cooldown = 120,
	},
	-- Rocket Barrage (Goblin)
	[69041] = {
		race = "Goblin",
		cooldown = 120,
	},
	-- Rocket Jump (Goblin)
	[69070] = {
		race = "Goblin",
		cooldown = 120,
	},
	-- Shadowmeld (Night Elf)
	[58984] = {
		race = "Night Elf",
		cooldown = 120,
	},
	-- Stoneform (Dwarf)
	[20594] = {
		race = "Dwarf",
		duration = 8,
		cooldown = 120,
	},
	-- War Stomp (Tauren)
	[20549] = {
		race = "Tauren",
		duration = 2,
		cooldown = 120,
	},
	-- Berserking (Troll)
	[26297] = {
		race = "Troll",
		duration = 10,
		cooldown = 180
	},


	-- Dispels
}

local Cooldowns = Gladius:NewGladiusModule("Cooldowns", false, {
	cooldownsAttachTo = "CastBarIcon",
	cooldownsAnchor = "TOPLEFT",
	cooldownsRelativePoint = "BOTTOMLEFT",
	cooldownsGrow = "DOWNRIGHT",
	cooldownsSpacingX = 0,
	cooldownsSpacingY = 0,
	cooldownsPerColumn = 8,
	cooldownsMax = 16,
	cooldownsSize = 23,
	cooldownsOffsetX = 0,
	cooldownsOffsetY = 0,
	cooldownsGloss = false,
	cooldownsGlossColor = { r = 1, g = 1, b = 1, a = 0.4 },
})

function Cooldowns:OnEnable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("SPELL_CAST_SUCCESS")

	LSM = Gladius.LSM

	self.frame = self.frame or {}
end

function Cooldowns:OnDisable()
	self:UnregisterAllEvents()
	self:Reset()
end

function Cooldowns:GetAttachTo()
	return Gladius.db.cooldownsAttachTo
end

function Cooldowns:GetModuleAttachPoints()
	return {
		["Cooldowns"] = L["Cooldowns"],
	}
end

function Cooldowns:GetAttachFrame(unit, point)
	if not self.frame[unit] then
		self:CreateFrame(unit)
	end
	return self.frame[unit]
end

function Cooldowns:SPELL_CAST_SUCCESS(event, unit)
end

function Cooldowns:COMBAT_LOG_EVENT_UNFILTERED(_, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	if event == "SPELL_CAST_SUCCESS" then
		local spellId = ...
		local spelldata = SpellData[spellId]
		if spelldata then
			print(sourceName, "cast", GetSpellInfo(spellId), "cooldown:", spelldata.cooldown)
		end
	end
end

local function CreateCooldownFrame(name, parent)
	local frame = CreateFrame("Frame", name, parent)
	frame.icon = frame:CreateTexture(nil, "BORDER") -- bg
	-- frame.icon:SetAllPoints()
	frame.icon:SetPoint("CENTER")
	frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

	frame.border = frame:CreateTexture(nil, "BACKGROUND") -- overlay
	frame.border:SetPoint("CENTER")
	frame.border:SetTexture(1, 1, 1, 1)
	frame.border:Hide()
	-- frame.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
	-- frame.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)

	frame.cooldown = CreateFrame("Cooldown", nil, frame)
	frame.cooldown:SetAllPoints(frame.icon)
	frame.cooldown:SetReverse(true)
	frame.cooldown:Hide()

	frame.count = frame:CreateFontString(nil, "OVERLAY")
	frame.count:SetFont(LSM:Fetch(LSM.MediaType.FONT, Gladius.db.globalFont), 10, "OUTLINE")
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

local function UpdateCooldownFrame(frame, size)
	frame:SetSize(size, size)
	frame.icon:SetSize(size - 1.5, size - 1.5)
	frame.border:SetSize(size, size)
end

function Cooldowns:CreateFrame(unit)
	local button = Gladius.buttons[unit]
	if (not button) then return end

	-- create cooldown frame
	if not self.frame[unit] then
		self.frame[unit] = CreateFrame("Frame", "Gladius" .. self.name .. "frame" .. unit, button)
		self.frame[unit]:EnableMouse(false)

		for i=1, 40 do
			self.frame[unit][i] = CreateCooldownFrame("Gladius" .. self.name .. "frameIcon" .. i .. unit, self.frame[unit])
			self.frame[unit][i]:Hide()
		end
	end
end

-- yeah this parameter list sucks
function Cooldowns:UpdateCooldownGroup(
	cooldownFrame, unit,
	cooldownAttachTo,
	cooldownAnchor,
	cooldownRelativePoint,
	cooldownOffsetX,
	cooldownOffsetY,
	cooldownPerColumn,
	cooldownGrow,
	cooldownSize,
	cooldownSpacingX,
	cooldownSpacingY,
	cooldownMax)

	cooldownFrame:ClearAllPoints()

	-- anchor point 
	local parent = Gladius:GetAttachFrame(unit, cooldownAttachTo)
	cooldownFrame:SetPoint(cooldownAnchor, parent, cooldownRelativePoint, cooldownOffsetX, cooldownOffsetY)

	-- size
	cooldownFrame:SetWidth(cooldownSize*cooldownPerColumn+cooldownSpacingX*cooldownPerColumn)
	cooldownFrame:SetHeight(cooldownSize*math.ceil(cooldownMax/cooldownPerColumn)+(cooldownSpacingY*(math.ceil(cooldownMax/cooldownPerColumn)+1)))

	-- icon points
	local anchor, parent, relativePoint, offsetX, offsetY
	local start, startAnchor = 1, cooldownFrame

	-- grow anchor
	local grow1, grow2, grow3, startRelPoint
	if (cooldownGrow == "DOWNRIGHT") then
		grow1, grow2, grow3, startRelPoint = "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT", "TOPLEFT"
	elseif (cooldownGrow == "DOWNLEFT") then
		grow1, grow2, grow3, startRelPoint = "TOPRIGHT", "BOTTOMRIGHT", "TOPLEFT", "TOPRIGHT"
	elseif (cooldownGrow == "UPRIGHT") then
		grow1, grow2, grow3, startRelPoint = "BOTTOMLEFT", "TOPLEFT", "BOTTOMRIGHT", "BOTTOMLEFT"
	elseif (cooldownGrow == "UPLEFT") then
		grow1, grow2, grow3, startRelPoint = "BOTTOMRIGHT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"
	end

	for i=1, 40 do
		cooldownFrame[i]:ClearAllPoints()

		if (cooldownMax >= i) then
			if (start == 1) then
			anchor, parent, relativePoint, offsetX, offsetY = grow1, startAnchor, startRelPoint, 0, strfind(cooldownGrow, "DOWN") and -cooldownSpacingY or cooldownSpacingY
			else
			anchor, parent, relativePoint, offsetX, offsetY = grow1, cooldownFrame[i-1], grow3, strfind(cooldownGrow, "LEFT") and -cooldownSpacingX or cooldownSpacingX, 0

			if (start == cooldownPerColumn) then
				start = 0
				startAnchor = cooldownFrame[i - cooldownPerColumn + 1]
				startRelPoint = grow2
			end
			end

			start = start + 1
		end

		cooldownFrame[i]:SetPoint(anchor, parent, relativePoint, offsetX, offsetY)

		UpdateCooldownFrame(cooldownFrame[i], cooldownSize)
	end
end

function Cooldowns:Update(unit)
	-- create frame
	if not self.frame[unit] then 
		self:CreateFrame(unit)
	end

	-- update cooldown frame 
	self:UpdateCooldownGroup(self.frame[unit], unit,
		Gladius.db.cooldownsAttachTo,
		Gladius.db.cooldownsAnchor,
		Gladius.db.cooldownsRelativePoint,
		Gladius.db.cooldownsOffsetX,
		Gladius.db.cooldownsOffsetY,
		Gladius.db.cooldownsPerColumn,
		Gladius.db.cooldownsGrow,
		Gladius.db.cooldownsSize,
		Gladius.db.cooldownsSpacingX,
		Gladius.db.cooldownsSpacingY,
		Gladius.db.cooldownsMax)

	-- hide
	self.frame[unit]:Hide()
end

function Cooldowns:Show(unit)
	-- show buff frame
	if self.frame[unit] then 
		self.frame[unit]:Show()
	end
end

function Cooldowns:Reset(unit) 
	if self.frame[unit] then 
		-- hide cooldown frame
		self.frame[unit]:Hide()

		for i = 1, 40 do
			self.frame[unit][i]:Hide()
		end
	end
end

function Cooldowns:Test(unit)
	-- test cooldown frame
	if (self.frame[unit]) then
		for i=1, Gladius.db.cooldownsMax do
			self.frame[unit][i].icon:SetTexture(GetSpellTexture(2139))
			self.frame[unit][i]:Show()
		end
	end
end

function Cooldowns:GetOptions()
	local options = {
		cooldowns = {  
			type="group",
			name=L["Cooldowns"],
			childGroups="tab",
			order=1,
			args = {
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
						cooldownsGrow = {
							type="select",
							name=L["Cooldowns Column Grow"],
							desc=L["Grow direction of the cooldowns"],
							values=function() return {
									["UPLEFT"] = L["Up Left"],
									["UPRIGHT"] = L["Up Right"],
									["DOWNLEFT"] = L["Down Left"],
									["DOWNRIGHT"] = L["Down Right"],
							}
							end,
							disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
							order=10,
						}, 
						sep = {
							type = "description",
							name="",
							width="full",
							order=13,
						},
						cooldownsPerColumn = {
							type="range",
							name=L["Cooldown Icons Per Column"],
							desc=L["Number of cooldown icons per column"],
							min=1, max=50, step=1,
							disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
							order=15,
						},
						cooldownsMax = {
							type="range",
							name=L["Cooldown Icons Max"],
							desc=L["Number of max cooldowns"],
							min=1, max=40, step=1,
							disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
							order=20,
						},  
						sep2 = {
							type = "description",
							name="",
							width="full",
							order=23,
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
							cooldownsSize = {
								type="range",
								name=L["Cooldown Icon Size"],
								desc=L["Size of the cooldown icons"],
								min=10, max=100, step=1,
								disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
								order=5,
							},
							sep = {
								type = "description",
								name="",
								width="full",
								order=13,
							},
							cooldownsSpacingY = {
								type="range",
								name=L["Cooldowns Spacing Vertical"],
								desc=L["Vertical spacing of the cooldowns"],
								min=0, max=30, step=1,
								disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
								order=15,
							},
							cooldownsSpacingX = {
								type="range",
								name=L["Cooldowns Spacing Horizontal"],
								desc=L["Horizontal spacing of the cooldowns"],
								disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
								min=0, max=30, step=1,
								order=20,
							},
						},
					},
					position = {
						type="group",
						name=L["Position"],
						desc=L["Position settings"],  
						inline=true,
						hidden=function() return not Gladius.db.advancedOptions end,
						order=3,
						args = {
							cooldownsAttachTo = {
								type="select",
								name=L["Cooldowns Attach To"],
								desc=L["Attach cooldowns to the given frame"],
								values=function() return Cooldowns:GetAttachPoints() end,
								disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
								width="double",
								order=5,
							},
							sep = {
								type = "description",
								name="",
								width="full",
								order=7,
							},
							cooldownsAnchor = {
								type="select",
								name=L["Cooldowns Anchor"],
								desc=L["Anchor of the cooldowns"],
								values=function() return Gladius:GetPositions() end,
								disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
								order=10,
							},
							cooldownsRelativePoint = {
								type="select",
								name=L["Cooldowns Relative Point"],
								desc=L["Relative point of the cooldowns"],
								values=function() return Gladius:GetPositions() end,
								disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
								order=15,
							},
							sep2 = {
								type = "description",
								name="",
								width="full",
								order=17,
							},
							cooldownsOffsetX = {
								type="range",
								name=L["Cooldowns Offset X"],
								desc=L["X offset of the cooldowns"],
								min=-100, max=100, step=1,
								disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
								order=20,
							},
							cooldownsOffsetY = {
								type="range",
								name=L["Cooldowns Offset Y"],
								desc=L["Y  offset of the cooldowns"],
								disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
								min=-50, max=50, step=1,
								order=25,
							},
							},
							},
					},
				},
				cooldowns = {  
					type="group",
					name=L["Cooldowns"],
					order=2,
					args = {},
				},
			},
		},
	}

	-- fill spell data
	local lclasses = {}
	FillLocalizedClassList(lclasses)

	local args = options.cooldowns.args.cooldowns.args
	for spellid, spelldata in pairs(SpellData) do
		if type(spelldata) == "table" then
			local name, rank, icon = GetSpellInfo(spellid)
			local basecd = GetSpellBaseCooldown(spellid)
			local spellconfig = {
				type="toggle",
				name=string.format(" |T%s:20|t %s [%ss/%ss]", icon, name, spelldata.cooldown, basecd and basecd/1000 or "??"),
				desc=GetSpellDescription(spellid),
				descStyle="inline",
				width="full",
				order=name:byte(1)*0xff+name:byte(2),
			}			
			if spelldata.class then
				if not args[spelldata.class] then
					args[spelldata.class] = {
						type="group",
						name=lclasses[spelldata.class],
						order=1,
						args={}
					}
				end
				if spelldata.specID then
					-- spec
					if not args[spelldata.class].args["spec" .. spelldata.specID] then
						local _, name, description, icon, background, role, class = GetSpecializationInfoByID(spelldata.specID)
						args[spelldata.class].args["spec" .. spelldata.specID] = {
							type="group",
							name=name,
							icon=icon,
							order=3,
							args={}
						}
					end
					args[spelldata.class].args["spec" .. spelldata.specID].args["spell"..spellid] = spellconfig
				elseif spelldata.talent then
					-- talent
					if not args[spelldata.class].args.talents then
						args[spelldata.class].args.talents = {
							type="group",
							name="Talents",
							order=2,
							args={}
						}
					end
					args[spelldata.class].args.talents.args["spell"..spellid] = spellconfig
				else
					-- base
					if not args[spelldata.class].args.base then
						args[spelldata.class].args.base = {
							type="group",
							name="Base",
							order=1,
							args={}
						}
					end
					args[spelldata.class].args.base.args["spell"..spellid] = spellconfig
				end
			elseif spelldata.race then
				-- racial
				if not args[spelldata.race] then
					args[spelldata.race] = {
						type="group",
						name=spelldata.race,
						args={}
					}
				end
				args[spelldata.race].args["spell"..spellid] = spellconfig
			elseif spelldata.item then
				-- item
			else
				print("Bad spelldata for", spellid, ": could not find type")
			end
		end
	end


	return options
end
