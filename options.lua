-- global functions
local pairs = pairs
local type = type

local L = GladiusEx.L

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
		margin = 25,
		useGlobalFontSize = true,
		globalFontSize = 11,
		globalFont = "Friz Quadrata TT",
		barWidth = 160,
		frameScale = 1,
		log = {},
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
	return (info.arg and GladiusEx.dbi.profile[info.arg] or GladiusEx.dbi.profile[info[#info]])
end

local function setOption(info, value)
	local key = info[#info]
	GladiusEx.dbi.profile[key] = value
	
	info = info.arg and info.arg or info[1]  
	
	GladiusEx:HideFrames()
	GladiusEx:UpdateFrames()
	GladiusEx:ShowFrames()
end

local AceDialog
local AceRegistry
function GladiusEx:ShowOptionsDialog()
	AceDialog = AceDialog or LibStub("AceConfigDialog-3.0")
	AceRegistry = AceRegistry or LibStub("AceConfigRegistry-3.0")
	
	if (not GladiusEx.options) then
		GladiusEx:SetupOptions()
		AceDialog:SetDefaultSize("GladiusEx", 830, 530)
	end
	
	AceDialog:Open("GladiusEx")
end

function GladiusEx:GetColorOption(info)
	local key = info.arg or info[#info]
	return self.dbi.profile[key].r, self.dbi.profile[key].g, self.dbi.profile[key].b, self.dbi.profile[key].a
end

function GladiusEx:SetColorOption(info, r, g, b, a) 
	local key = info.arg or info[#info]
	self.dbi.profile[key].r, self.dbi.profile[key].g, self.dbi.profile[key].b, self.dbi.profile[key].a = r, g, b, a
	
	GladiusEx:HideFrames()
	GladiusEx:UpdateFrames()
	GladiusEx:ShowFrames()
end

function GladiusEx:GetPositions()
	return {
		["TOPLEFT"] = L["Top Left"],
		["TOPRIGHT"] = L["Top Right"],
		["LEFT"] = L["Center Left"],
		["RIGHT"] = L["Center Right"],
		["BOTTOMLEFT"] = L["Bottom Left"],
		["BOTTOMRIGHT"] = L["Bottom Right"],
	}
end

function GladiusEx:SetupModule(key, module, order)
	self.options.args[key] = {
		type="group",
		name=L[key],
		desc=L[key .. " settings"],
		childGroups="tab",
		order=order,
		args={},
	}
	
	-- set additional module options
	local options = module:GetOptions()
	
	if (type(options) == "table") then
		self.options.args[key].args = options
	end
	
	-- set enable module option
	self.options.args[key].args.enable = {
		type="toggle",
		name=L["Enable Module"],
		set=function(info, v) 
			local module = info[1]
			self.dbi.profile.modules[module] = v
			
			if (v) then
				self:EnableModule(module)
			else
				self:DisableModule(module)
			end 
			
			self:UpdateFrames()
		end, 
		get=function(info) 
			local module = info[1]
			return self.dbi.profile.modules[module]
		end,
		order=0,
	}
	
	-- set reset module option
	self.options.args[key].args.reset = {
		type="execute",
		name=L["Reset Module"],
		func=function()
			for k,v in pairs(module.defaults) do
				self.dbi.profile[k] = v
			end
			
			self:UpdateFrames()
		end,
		order=0.5,
	}
end

function GladiusEx:SetupOptions()
	self.options = {
		type = "group",
		name = "GladiusEx",
		plugins = {},
		get=getOption,
		set=setOption,
		args = {
			general = {
				type="group",
				name=L["General"],
				desc=L["General settings"],
				order=1,
				args = {
					general = {
						type="group",
						name=L["General"],
						desc=L["General settings"],
						inline=true,
						order=1,
						args = {
							locked = {
								type="toggle",
								name=L["Lock frame"],
								desc=L["Toggle if the frame can be moved"],
								order=1,
							},
						  growDirection = {
								order = 5,
								type = "select",
								name = "Direction",
								desc = L["The Direction you want the frame to go in."],
								name=L["Grow Direction"],
								values = {
									["HCENTER"]= L["Left and right"],
									["LEFT"]	= L["Left"],
									["RIGHT"]  = L["Right"],
									["UP"]	  = L["Up"],
									["DOWN"]	= L["Down"],
								},
							},
							sep = {
								type = "description",
								name="",
								width="full",
								order=7,
							},
							groupButtons = {
								type="toggle",
								name=L["Group Buttons"],
								desc=L["If this is toggle buttons can be moved separately"],
								order=10,
							},
							showParty = {
								type="toggle",
								name=L["Show party frames"],
								order=11,
							},
							advancedOptions = {
								type="toggle",
								name=L["Advanced Options"],
								desc=L["Toggle advanced options"],
								order=15,
							},
						},
					},
					frame = {
						type="group",
						name=L["Frame"],
						desc=L["Frame settings"],
						inline=true,
						order=2,
						args = {
							backgroundColor = {
								type="color",
								name=L["Background Color"],
								desc=L["Color of the frame background"],
								hasAlpha=true,
								get=function(info) return GladiusEx:GetColorOption(info) end,
								set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
								disabled=function() return not self.dbi.profile.groupButtons end,
								order=1,
							},
							backgroundPadding = {
								type="range",
								name=L["Background Padding"],
								desc=L["Padding of the background"],
								min=0, max=100, step=1,
								disabled=function() return not self.dbi.profile.groupButtons end,
								order=5,
							},
							sep = {
								type = "description",
								name="",
								width="full",
								order=7,
							},
							margin = {
								type="range",
								name=L["Margin"],
								desc=L["Margin between each button"],
								min=0, max=300, step=1,
								disabled=function() return not self.dbi.profile.groupButtons end,
								width="double",
								order=10,
							},
						},
					},
					size = {
						type="group",
						name=L["Size"],
						desc=L["Size settings"],
						inline=true,
						order=3,
						args = {
							barWidth = {
								type="range",
								name=L["Bar width"],
								desc=L["Width of the module bars"],
								min=10, max=500, step=1,
								order=1,
							},
							frameScale = {
								type="range",
								name=L["Frame scale"],
								desc=L["Scale of the frame"],
								min=.1,
								max=2,
								step=.1,
								order=5,
							},
						},
					},
					font = {
						type="group",
						name=L["Font"],
						desc=L["Font settings"],
						inline=true,
						order=4,
						args = {
							globalFont = {
								type="select",
								name=L["Global Font"],
								desc=L["Global font, used by the modules"],
								dialogControl = "LSM30_Font",
								values = AceGUIWidgetLSMlists.font,
								order=1,
							},
							globalFontSize = {
								type="range",
								name=L["Global Font Size"],
								desc=L["Text size of the power info text"],
								disabled=function() return not self.db.useGlobalFontSize end,
								min=1, max=20, step=1,
								order=5,
							},
							sep = {
								type = "description",
								name="",
								width="full",
								order=7,
							},
							useGlobalFontSize = {
								type="toggle",
								name=L["Use Global Font Size"],
								desc=L["Toggle if you want to use the global font size"],
								order=10,
							},
						},
					},
				},
			},
		},
	}

	local order = 10
	for moduleName, module in self:IterateModules() do
		self:SetupModule(moduleName, module, order)
		order = order + 5
	end

	self.options.plugins.profiles = { profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.dbi) }
	LibStub("AceConfig-3.0"):RegisterOptionsTable("GladiusEx", self.options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GladiusEx", "GladiusEx")
end
