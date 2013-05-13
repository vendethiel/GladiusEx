-- global functions
local fn = LibStub("LibFunctional-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")

GladiusEx.defaults = {
	profile = {
		locked = false,
		advancedOptions = true,
		globalFont = "2002",
		globalFontSize = 11,
		globalBarTexture = "Minimalist",
		showParty = true,
		testUnits = {
			["arena1"] = { health = 320000, maxHealth = 320000, power = 18000, maxPower = 18000, powerType = 0, unitClass = "MAGE", unitRace = "Scourge", unitSpec = "Frost", specID = 64 },
			["arena2"] = { health = 300000, maxHealth = 320000, power = 10000, maxPower = 12000, powerType = 2, unitClass = "HUNTER", unitRace = "NightElf", unitSpec = "Beast Mastery", specID = 253 },
			["arena3"] = { health = 240000, maxHealth = 350000, power = 90, maxPower = 120, powerType = 3, unitClass = "ROGUE", unitRace = "Human", unitSpec = "Subtlety", specID = 261 },
			["arena4"] = { health = 200000, maxHealth = 400000, power = 80, maxPower = 130, powerType = 6, unitClass = "DEATHKNIGHT", unitRace = "Dwarf", unitSpec = "Unholy", specID = 252 },
			["arena5"] = { health = 100000, maxHealth = 300000, power = 10, maxPower = 100, powerType = 1, unitClass = "WARRIOR", unitRace = "Gnome", unitSpec = "Arms", specID = 71 },

			["player"] = { health = 320000, maxHealth = 320000, power = 18000, maxPower = 18000, powerType = 0, unitClass = "PRIEST", unitRace = "Draenei", unitSpec = "Discipline", specID = 256 },
			["party1"] = { health = 300000, maxHealth = 320000, power = 10000, maxPower = 12000, powerType = 3, unitClass = "MONK", unitRace = "Pandaren", unitSpec = "Windwalker", specID = 269 },
			["party2"] = { health = 100000, maxHealth = 300000, power = 10, maxPower = 100, powerType = 1, unitClass = "WARRIOR", unitRace = "Gnome", unitSpec = "Arms", specID = 71 },
			["party3"] = { health = 200000, maxHealth = 400000, power = 80, maxPower = 130, powerType = 6, unitClass = "DEATHKNIGHT", unitRace = "Dwarf", unitSpec = "Unholy", specID = 252 },
			["party4"] = { health = 100000, maxHealth = 300000, power = 10, maxPower = 100, powerType = 1, unitClass = "WARRIOR", unitRace = "Gnome", unitSpec = "Arms", specID = 71 },
		},
		--@debug@
		debug = true,
		--@end-debug@
	}
}

GladiusEx.defaults_arena = {
	profile = {
		x = {},
		y = {},
		modules = {
			["*"] = true,
			["TargetBar"] = false,
			["Clicks"] = false,
			["Auras"] = false,
		},
		growDirection = "VCENTER",
		groupButtons = true,
		oorAlpha = 0.7,
		stealthAlpha = 0.4,
		deadAlpha = 0.2,
		backgroundColor = { r = 0, g = 0, b = 0, a = 0 },
		backgroundPadding = 5,
		margin = 35,
		barWidth = 173,
		frameScale = 1,
	},
}

GladiusEx.defaults_party = {
	profile = {
		x = {},
		y = {},
		modules = {
			["*"] = true,
			["TargetBar"] = false,
			["Clicks"] = false,
			["Announcements"] = false,
			["Auras"] = false,
		},
		growDirection = "VCENTER",
		groupButtons = true,
		oorAlpha = 0.7,
		stealthAlpha = 0.4,
		deadAlpha = 0.2,
		backgroundColor = { r = 0, g = 0, b = 0, a = 0 },
		backgroundPadding = 5,
		margin = 35,
		barWidth = 173,
		frameScale = 1,
	},
}

SLASH_GLADIUSEX1 = "/gladiusex"
SLASH_GLADIUSEX2 = "/gex"
SlashCmdList["GLADIUSEX"] = function(msg)
	if msg:find("test") then
		local test = false

		if msg == "test2" then
			test = 2
		elseif msg == "test3" then
			test = 3
		elseif msg == "test5" then
			test = 5
		else
			test = tonumber(msg:match("^test (.+)"))

			if test and (test > 5 or test < 2 or test == 4) then
				test = 5
			end
		end

		GladiusEx:SetTesting(test)
	elseif msg == "" or msg == "options" or msg == "config" or msg == "ui" then
		GladiusEx:ShowOptionsDialog()
	elseif msg == "hide" then
		-- hide buttons
		GladiusEx:HideFrames()
	elseif msg == "reset" then
		-- reset profile
		GladiusEx.dbi:ResetProfile()
	end
end

function GladiusEx:GetColorOption(db, info)
	local key = info.arg or info[#info]
	return db[key].r, db[key].g, db[key].b, db[key].a
end

function GladiusEx:SetColorOption(db, info, r, g, b, a)
	local key = info.arg or info[#info]
	db[key].r, db[key].g, db[key].b, db[key].a = r, g, b, a

	GladiusEx:UpdateFrames()
end

function GladiusEx:GetPositions()
	return {
		["TOPLEFT"] = L["Top left"],
		["TOPRIGHT"] = L["Top right"],
		["LEFT"] = L["Center left"],
		["RIGHT"] = L["Center right"],
		["BOTTOMLEFT"] = L["Bottom left"],
		["BOTTOMRIGHT"] = L["Bottom right"],
	}
end

function GladiusEx:SetupModuleOptions(unit, key, module, order)
	local function getModuleOption(module, info)
		return (info.arg and module.db[unit][info.arg] or module.db[unit][info[#info]])
	end

	local function setModuleOption(module, info, value)
		local key = info.arg or info[#info]
		module.db[unit][key] = value
		self:UpdateFrames()
	end

	local options = {
		type = "group",
		name = function() return (self:IsModuleEnabled(unit, key) and "" or "|cff7f7f7f") .. L[key]  end,
		desc = string.format(L["%s settings"], L[key]),
		childGroups = "tab",
		order = order,
		get = fn.bind(getModuleOption, module),
		set = fn.bind(setModuleOption, module),
		args = {},
	}

	-- set additional module options
	local mod_options = module:GetOptions(unit)

	if type(options) == "table" then
		options.args = mod_options
	end

	-- add enable module option
	options.args.enable = {
		type = "toggle",
		name = L["Enable module"],
		set = function(info, v)
			self.db[unit].modules[key] = v

			self:CheckEnableDisableModule(key)

			self:UpdateFrames()
		end,
		get = function(info)
			return self.db[unit].modules[key]
		end,
		order = 0,
	}

	-- add reset module option
	options.args.reset = {
		type = "execute",
		name = L["Reset module"],
		func = function()
			if self:IsArenaUnit(unit) then
				module.dbi_arena:ResetProfile()
			else
				module.dbi_party:ResetProfile()
			end
			self:SetupOptions()
			self:UpdateFrames()
		end,
		order = 0.5,
	}

	-- add copy from other group option
	options.args.copy = {
		type = "execute",
		name = self:IsArenaUnit(unit) and L["Copy from party"] or L["Copy from arena"],
		func = function()
			if self:IsArenaUnit(unit) then
				self:CopyGroupModuleSettings(module, "arena", "party")
			else
				self:CopyGroupModuleSettings(module, "party", "arena")
			end
		end,
		order = 0.75,
	}

	return options
end

function GladiusEx:MakeGroupOptions(group, unit, order)
	local function getOption(info)
		return (info.arg and GladiusEx.db[unit][info.arg] or GladiusEx.db[unit][info[#info]])
	end

	local function setOption(info, value)
		local key = info.arg or info[#info]
		GladiusEx.db[unit][key] = value
		GladiusEx:UpdateFrames()
	end

	local options = {
		type = "group",
		name = L[group],
		get = getOption,
		set = setOption,
		order = order,
		args = {
			general = {
				type = "group",
				name = L["General"],
				desc = L["General settings"],
				order = 1,
				args = {
					general = {
						type = "group",
						name = L["General"],
						desc = L["General settings"],
						inline = true,
						order = 1,
						args = {
							growDirection = {
								order = 5,
								type = "select",
								name = L["Grow direction"],
								desc = L["The direction you want the frames to grow in"],
								values = {
									["HCENTER"] = L["Left and right"],
									["VCENTER"] = L["Up and down"],
									["LEFT"]    = L["Left"],
									["RIGHT"]   = L["Right"],
									["UP"]      = L["Up"],
									["DOWN"]    = L["Down"],
								},
								disabled = function() return not self.db[unit].groupButtons end,
							},
							sep = {
								type = "description",
								name = "",
								width = "full",
								order = 7,
							},
							groupButtons = {
								type = "toggle",
								name = L["Group frames"],
								desc = L["Disable this to be able to move the frames separately"],
								set = function(info, value)
									if not value then
										-- if ungrouping, save current frame positions
										self:SaveAnchorPosition(self:GetUnitAnchorType(unit))
									end
									setOption(info, value)
								end,
								order = 10,
							},
						},
					},
					units = {
						type = "group",
						name = L["Units"],
						desc = L["Unit settings"],
						inline = true,
						order = 1.5,
						args = {
							oorAlpha = {
								type = "range",
								name = L["Out of range alpha"],
								desc = L["Transparency for units out of range"],
								min = 0, max = 1, bigStep = 0.1,
								order = 0,
							},
							stealthAlpha = {
								type = "range",
								name = L["Stealth alpha"],
								desc = L["Transparency for units in stealth"],
								min = 0, max = 1, bigStep = 0.1,
								hidden = function() return self:IsPartyUnit(unit) end,
								order = 1,
							},
							deadAlpha = {
								type = "range",
								name = L["Dead alpha"],
								desc = L["Transparency for dead units"],
								min = 0, max = 1, bigStep = 0.1,
								order = 2,
							},
						},
					},
					frame = {
						type = "group",
						name = L["Frame"],
						desc = L["Frame settings"],
						inline = true,
						order = 2,
						args = {
							backgroundColor = {
								type = "color",
								name = L["Background color"],
								desc = L["Color of the frame background"],
								hasAlpha = true,
								get = function(info) return GladiusEx:GetColorOption(self.db[unit], info) end,
								set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db[unit], info, r, g, b, a) end,
								disabled = function() return not self.db[unit].groupButtons end,
								order = 1,
							},
							backgroundPadding = {
								type = "range",
								name = L["Background padding"],
								desc = L["Padding of the background"],
								min = 0, max = 100, step = 1,
								disabled = function() return not self.db[unit].groupButtons end,
								order = 5,
							},
							sep = {
								type = "description",
								name = "",
								width = "full",
								order = 7,
							},
							margin = {
								type = "range",
								name = L["Margin"],
								desc = L["Margin between each button"],
								min = 0, max = 300, step = 1,
								disabled = function() return not self.db[unit].groupButtons end,
								width = "double",
								order = 10,
							},
						},
					},
					size = {
						type = "group",
						name = L["Size"],
						desc = L["Size settings"],
						inline = true,
						order = 3,
						args = {
							barWidth = {
								type = "range",
								name = L["Bar width"],
								desc = L["Width of the module bars"],
								min = 10, max = 500, step = 1,
								order = 1,
							},
							frameScale = {
								type = "range",
								name = L["Frame scale"],
								desc = L["Scale of the frame"],
								min = .1,
								max = 2,
								step = .1,
								order = 5,
							},
						},
					},
				},
			},
		},
	}

	-- Add module options
	local mods = fn.sort(fn.from_iterator(self:IterateModules()), function(x, y) return x[1] < y[1] end)
	for order, mod in ipairs(mods) do
		options.args[mod[1]] = self:SetupModuleOptions(unit, mod[1], mod[2], order + 10)
	end

	return options
end

function GladiusEx:SetupOptions()
	local function getOption(info)
		return (info.arg and GladiusEx.db.base[info.arg] or GladiusEx.db.base[info[#info]])
	end

	local function setOption(info, value)
		local key = info.arg or info[#info]
		GladiusEx.db.base[key] = value
		GladiusEx:UpdateFrames()
	end

	local options = {
		type = "group",
		name = "GladiusEx",
		get = getOption,
		set = setOption,
		args = {
			general = {
				type = "group",
				name = L["General"],
				desc = L["General settings"],
				order = 1,
				args = {
					general = {
						type = "group",
						name = L["General"],
						desc = L["General settings"],
						inline = true,
						order = 1,
						args = {
							locked = {
								type = "toggle",
								name = L["Lock frames"],
								desc = L["Toggle if the frames can be moved"],
								order = 1,
							},
							showParty = {
								type = "toggle",
								name = L["Show party frames"],
								desc = L["Toggle to show your party frames"],
								set = function(info, value)
									setOption(info, value)
									-- todo: this shouldn't be so.. awkward
									if GladiusEx:IsArenaShown() then
										GladiusEx:HideFrames()
										GladiusEx:ShowFrames()
									end
								end,
								order = 11,
							},
							advancedOptions = {
								type = "toggle",
								name = L["Advanced options"],
								desc = L["Toggle display of advanced options"],
								order = 15,
							},
						},
					},
					font = {
						type = "group",
						name = L["Font"],
						desc = L["Font settings"],
						inline = true,
						order = 4,
						args = {
							globalFont = {
								type = "select",
								name = L["Global font"],
								desc = L["Global font, used by the modules"],
								dialogControl = "LSM30_Font",
								values = AceGUIWidgetLSMlists.font,
								order = 1,
							},
							globalFontSize = {
								type = "range",
								name = L["Global font size"],
								desc = L["Text size of the global font"],
								min = 1, max = 20, step = 1,
								order = 5,
							},
							sep = {
								type = "description",
								name = "",
								width = "full",
								order = 7,
							},
							globalBarTexture = {
								type = "select",
								name = L["Global bar texture"],
								desc = L["Global texture of the bars"],
								dialogControl = "LSM30_Statusbar",
								values = AceGUIWidgetLSMlists.statusbar,
								order = 10,
							},
						},
					},
				},
			},
			testing = {
				type = "group",
				name = L["Testing"],
				desc = L["Testing settings"],
				childGroups = "tree",
				order = 2,
				args = {
					test = {
						type = "header",
						name = L["Test frames"],
						order = 0,
					},
					test2 = {
						type = "execute",
						name = L["Test 2v2"],
						width = "half",
						func = function() self:SetTesting(2) end,
						disabled = function() return self:IsTesting() == 2 end,
						order = 0.2,
					},
					test3 = {
						type = "execute",
						name = L["Test 3v3"],
						width = "half",
						func = function() self:SetTesting(3) end,
						disabled = function() return self:IsTesting() == 3 end,
						order = 0.3,
					},
					test5 = {
						type = "execute",
						name = L["Test 5v5"],
						width = "half",
						func = function() self:SetTesting(5) end,
						disabled = function() return self:IsTesting() == 5 end,
						order = 0.5,
					},
					hide = {
						type = "execute",
						name = L["Stop testing"],
						width = "triple",
						func = function() self:SetTesting() end,
						disabled = function() return not self:IsTesting() end,
						order = 1,
					},
					testunits = {
						type = "header",
						name = L["Test units"],
						order = 3,
					},
				}
			}
		}
	}

	-- add test units
	for _, unit in ipairs(fn.difference(fn.concat(fn.keys(self.party_units), fn.keys(self.arena_units)), { "player" })) do
		local test_frame = {
			type = "group",
			name = unit,
			order = 10,
			inline = true,
			args = {
				race = {
					order = 1,
					type = "select",
					name = L["Race"],
					desc = L["Unit race"],
					get = function() return self.db.base.testUnits[unit].unitRace end,
					set = function(info, value)
						self.db.base.testUnits[unit].unitRace = value
						self:UpdateFrames()
					end,
					values = {
						["BloodElf"] = "BloodElf",
						["Draenei"] = "Draenei",
						["Dwarf"] = "Dwarf",
						["Gnome"] = "Gnome",
						["Goblin"] = "Goblin",
						["Human"] = "Human",
						["NightElf"] = "NightElf",
						["Orc"] = "Orc",
						["Pandaren"] = "Pandaren",
						["Scourge"] = "Scourge",
						["Tauren"] = "Tauren",
						["Troll"] = "Troll",
						["Worgen"] = "Worgen",
					},
				},
				spec = {
					order = 2,
					type = "select",
					name = L["Spec"],
					desc = L["Unit talent specialization"],
					get = function() return self.db.base.testUnits[unit].specID end,
					set = function(info, value)
						self.db.base.testUnits[unit].specID = value
						self.db.base.testUnits[unit].unitSpec = select(2, GetSpecializationInfoByID(value))
						self.db.base.testUnits[unit].unitClass = select(7, GetSpecializationInfoByID(value))
						self:UpdateFrames()
					end,
					values = function()
						local t = {}
						for classID = 1, MAX_CLASSES do
							local classDisplayName, classTag = GetClassInfoByID(classID)
							local color = RAID_CLASS_COLORS[classTag]
							local colorfmt = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
							for specNum = 1, GetNumSpecializationsForClassID(classID) do
								local specID, name, description, icon, background, role = GetSpecializationInfoForClassID(classID, specNum)
								t[specID] = string.format("%s%s/%s", colorfmt, classDisplayName, name)
							end
						end
						return t
					end
				},
				powerType = {
					order = 3,
					type = "select",
					name = L["Power type"],
					desc = L["Unit power type"],
					get = function() return self.db.base.testUnits[unit].powerType end,
					set = function(info, value)
						self.db.base.testUnits[unit].powerType = value
						self:UpdateFrames()
					end,
					values = {
						[0] = MANA,
						[1] = RAGE,
						[2] = FOCUS,
						[3] = ENERGY,
						[4] = CHI,
						[6] = RUNIC_POWER,
					},
				},
			}
		}
		options.args.testing.args[unit] = test_frame
	end


	-- add groups
	options.args.arena = self:MakeGroupOptions("Arena", "arena1", 10)
	options.args.arena.args.copy = {
		type = "group",
		name = L["Copy settings"],
		desc = L["Copy settings"],
		inline = true,
		order = 1,
		args = {
			party_to_arena = {
				type = "execute",
				name = L["Copy from party"],
				desc = L["Copy all settings from party to arena"],
				func = function() self:CopyGroupSettings("arena", "party") end,
				order = 2,
			},
		}
	}
	options.args.arena.args.reset = {
		type = "group",
		name = L["Reset settings"],
		desc = L["Reset settings"],
		inline = true,
		order = 2,
		args = {
			arena_to_party = {
				type = "execute",
				name = L["Reset arena settings"],
				desc = L["Reset all arena settings to their default values"],
				func = function() self:ResetGroupSettings("arena") end,
				order = 1,
			},
		}
	}
	-- party
	options.args.party = self:MakeGroupOptions("Party", "player", 11)
	options.args.party.disabled = function() return not self.db.base.showParty end
	options.args.party.args.copy = {
		type = "group",
		name = L["Copy settings"],
		desc = L["Copy settings"],
		inline = true,
		order = 1,
		args = {
			arena_to_party = {
				type = "execute",
				name = L["Copy from arena"],
				desc = L["Copy all settings from arena to party"],
				func = function() self:CopyGroupSettings("party", "arena") end,
				order = 1,
			},
		}
	}
	options.args.party.args.reset = {
		type = "group",
		name = L["Reset settings"],
		desc = L["Reset settings"],
		inline = true,
		order = 2,
		args = {
			party_to_arena = {
				type = "execute",
				name = L["Reset party settings"],
				desc = L["Reset all party settings to their default values"],
				func = function() self:ResetGroupSettings("party") end,
				order = 2,
			},
		}
	}

	-- add profile options
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.dbi)

	-- add dual-spec support
	local LibDualSpec = LibStub("LibDualSpec-1.0")
	LibDualSpec:EnhanceDatabase(self.dbi, "GladiusEx")
	LibDualSpec:EnhanceOptions(options.args.profiles, self.dbi)

	LibStub("AceConfig-3.0"):RegisterOptionsTable("GladiusEx", options)

	if not self.options then
		LibStub("AceConfigDialog-3.0"):SetDefaultSize("GladiusEx", 860, 550)
		LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GladiusEx", "GladiusEx")
	end

	self.options = options
end

function GladiusEx:ResetGroupSettings(group)
	self["dbi_" .. group]:ResetProfile()

	for name, mod in self:IterateModules() do
		mod["dbi_" .. group]:ResetProfile()
	end

	self:SetupOptions()
	self:EnableModules()
	self:UpdateFrames()
end

-- this may be completely unneccesary, but I want to make sure that I don't
-- overwrite some acedb metatable
local function copy_over_table(dst, src)
	if dst then
		wipe(dst)
	else
		dst = {}
	end
	for k, v in pairs(src) do
		if type(v) == "table" then
			dst[k] = copy_over_table(dst[k], v)
		else
			dst[k] = v
		end
	end
	return dst
end

local function copy_dbi(dst, src)
	for k, v in pairs(src.profile) do
		if type(v) == "table" then
			dst.profile[k] = copy_over_table(dst.profile[k], v)
		else
			dst.profile[k] = v
		end
	end
end

function GladiusEx:CopyGroupSettings(dst_group, src_group)
	copy_dbi(self["dbi_" .. dst_group], self["dbi_" .. src_group])

	for name, mod in self:IterateModules() do
		copy_dbi(mod["dbi_" .. dst_group], mod["dbi_" .. src_group])
	end

	self:SetupOptions()
	self:EnableModules()
	self:UpdateFrames()
end

function GladiusEx:CopyGroupModuleSettings(module, dst_group, src_group)
	copy_dbi(module["dbi_" .. dst_group], module["dbi_" .. src_group])

	self:SetupOptions()
	self:EnableModules()
	self:UpdateFrames()
end

function GladiusEx:ShowOptionsDialog()
	-- InterfaceOptionsFrame_OpenToCategory("GladiusEx")
	LibStub("AceConfigDialog-3.0"):Open("GladiusEx")
end
