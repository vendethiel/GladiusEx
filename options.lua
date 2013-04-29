-- global functions
local fn = LibStub("LibFunctional-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")

GladiusEx.defaults = {
	profile = {
		x = {},
		y = {},
		modules = {
			["*"] = true,
			["TargetBar"] = false,
			["Clicks"] = false,
		},
		locked = false,
		growDirection = "HCENTER",
		groupButtons = true,
		showParty = true,
		stealthAlpha = 0.7,
		deadAlpha = 0.5,
		advancedOptions = true,
		backgroundColor = { r = 0, g = 0, b = 0, a = 0.4 },
		backgroundPadding = 5,
		margin = 50,
		useGlobalFontSize = true,
		globalFontSize = 11,
		globalFont = "Friz Quadrata TT",
		barWidth = 166,
		frameScale = 1,
		--@debug@
		debug = true,
		--@end-debug@
	},
}

SLASH_GLADIUSEX1 = "/gladiusex"
SLASH_GLADIUSEX2 = "/gex"
SlashCmdList["GLADIUSEX"] = function(msg)
	if msg:find("test") then
		local test = false

		if (msg == "test2") then
			test = 2
		elseif (msg == "test3") then
			test = 3
		elseif (msg == "test5") then
			test = 5
		else
			test = tonumber(msg:match("^test (.+)"))

			if test and (test > 5 or test < 2 or test == 4) then
				test = 5
			end
		end

		GladiusEx:SetTesting(test)
	elseif (msg == "" or msg == "options" or msg == "config" or msg == "ui") then
		GladiusEx:ShowOptionsDialog()
	elseif msg == "hide" then
		-- hide buttons
		GladiusEx:HideFrames()
	elseif (msg == "reset") then
		-- reset profile
		GladiusEx.dbi:ResetProfile()
	end
end

local function getOption(info)
	return (info.arg and GladiusEx.db[info.arg] or GladiusEx.db[info[#info]])
end

local function setOption(info, value)
	local key = info.arg or info[#info]
	GladiusEx.db[key] = value
	GladiusEx:UpdateFrames()
end

local function getModuleOption(module, info)
	return (info.arg and module.db[info.arg] or module.db[info[#info]])
end

local function setModuleOption(module, info, value)
	local key = info.arg or info[#info]
	module.db[key] = value
	GladiusEx:UpdateFrames()
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

function GladiusEx:SetupModule(key, module, order)
	self.options.args[key] = {
		type = "group",
		name = L[key],
		desc = string.format(L["%s settings"], key),
		childGroups = "tab",
		order = order,
		get = fn.bind(getModuleOption, module),
		set = fn.bind(setModuleOption, module),
		args = {},
	}

	-- set additional module options
	local options = module:GetOptions()

	if (type(options) == "table") then
		self.options.args[key].args = options
	end

	-- set enable module option
	self.options.args[key].args.enable = {
		type = "toggle",
		name = L["Enable module"],
		set = function(info, v)
			local module = info[1]
			self.db.modules[module] = v

			if (v) then
				self:EnableModule(module)
			else
				self:DisableModule(module)
			end

			self:UpdateFrames()
		end,
		get = function(info)
			local module = info[1]
			return self.db.modules[module]
		end,
		order = 0,
	}

	-- set reset module option
	self.options.args[key].args.reset = {
		type = "execute",
		name = L["Reset module"],
		func = function()
			module.dbi:ResetProfile()
			self:UpdateFrames()
		end,
		order = 0.5,
	}
end

function GladiusEx:SetupOptions()
	self.options = {
		type = "group",
		name = "GladiusEx",
		get = getOption,
		set = setOption,
		args = {
			test = {
				type = "group",
				name = "", --L["Test frames"],
				inline = true,
				order = 0,
				args = {
					test2 = {
						type = "execute",
						name = L["Test 2v2"],
						order = 0.2,
						width = "half",
						func = function() self:SetTesting(2) end,
						disabled = function() return self:IsTesting() == 2 end,
					},
					test3 = {
						type = "execute",
						name = L["Test 3v3"],
						width = "half",
						order = 0.3,
						func = function() self:SetTesting(3) end,
						disabled = function() return self:IsTesting() == 3 end,
					},
					test5 = {
						type = "execute",
						name = L["Test 5v5"],
						width = "half",
						order = 0.5,
						func = function() self:SetTesting(5) end,
						disabled = function() return self:IsTesting() == 5 end,
					},
					hide = {
						type = "execute",
						name = L["Stop testing"],
						order = 1,
						func = function() self:SetTesting() end,
						disabled = function() return not self:IsTesting() end,
					},
				},
			},
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
								name = L["Lock frame"],
								desc = L["Toggle if the frame can be moved"],
								order = 1,
							},
							growDirection = {
								order = 5,
								type = "select",
								name = "Direction",
								name = L["Grow direction"],
								desc = L["The direction you want the frames to grow in"],
								values = {
									["HCENTER"] = L["Left and right"],
									["LEFT"]    = L["Left"],
									["RIGHT"]   = L["Right"],
									["UP"]      = L["Up"],
									["DOWN"]    = L["Down"],
								},
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
								order = 10,
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
					units = {
						type = "group",
						name = L["Units"],
						desc = L["Unit settings"],
						inline = true,
						order = 1.5,
						args = {
							stealthAlpha = {
								type = "range",
								name = L["Stealth alpha"],
								desc = L["Transparency for units in stealth"],
								min = 0, max = 1, step = 0.1,
								order = 1,
							},
							deadAlpha = {
								type = "range",
								name = L["Dead alpha"],
								desc = L["Transparency for dead units"],
								min = 0, max = 1, step = 0.1,
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
								get = function(info) return GladiusEx:GetColorOption(self.db, info) end,
								set = function(info, r, g, b, a) return GladiusEx:SetColorOption(self.db, info, r, g, b, a) end,
								disabled = function() return not self.db.groupButtons end,
								order = 1,
							},
							backgroundPadding = {
								type = "range",
								name = L["Background padding"],
								desc = L["Padding of the background"],
								min = 0, max = 100, step = 1,
								disabled = function() return not self.db.groupButtons end,
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
								disabled = function() return not self.db.groupButtons end,
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
								desc = L["Text size of the power info text"],
								disabled = function() return not self.db.useGlobalFontSize end,
								min = 1, max = 20, step = 1,
								order = 5,
							},
							sep = {
								type = "description",
								name = "",
								width = "full",
								order = 7,
							},
							useGlobalFontSize = {
								type = "toggle",
								name = L["Use global font size"],
								desc = L["Toggle if you want to use the global font size"],
								order = 10,
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
		self:SetupModule(mod[1], mod[2], order + 10)
	end

	-- Add profile options
	self.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.dbi)

	-- Add dual-spec support
	local LibDualSpec = LibStub("LibDualSpec-1.0")
	LibDualSpec:EnhanceDatabase(self.dbi, "GladiusEx")
	LibDualSpec:EnhanceOptions(self.options.args.profiles, self.dbi)

	LibStub("AceConfig-3.0"):RegisterOptionsTable("GladiusEx", self.options)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("GladiusEx", 830, 530)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GladiusEx", "GladiusEx")
end

function GladiusEx:ShowOptionsDialog()
	-- InterfaceOptionsFrame_OpenToCategory("GladiusEx")
	LibStub("AceConfigDialog-3.0"):Open("GladiusEx")
end
