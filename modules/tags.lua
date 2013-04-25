local GladiusEx = _G.GladiusEx
local L = GladiusEx.L
local LSM

-- global functions
local strfind = string.find
local pairs = pairs
local strgsub = string.gsub
local strgmatch = string.gmatch
local strformat = string.format

local UnitName, UnitIsDeadOrGhost, LOCALIZED_CLASS_NAMES_MALE = UnitName, UnitIsDeadOrGhost, LOCALIZED_CLASS_NAMES_MALE
local UnitClass, UnitRace = UnitClass, UnitRace
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax

local Tags = GladiusEx:NewGladiusExModule("Tags", false, {
	tags = {},
	tagEvents = {},
	tagsTexts = {
		["HealthBar Left Text"] = {
			attachTo = "HealthBar",
			position = "LEFT",
			offsetX = 2,
			offsetY = 0,

			size = 11,
			color = { r = 1, g = 1, b = 1, a = 1 },

			text = "[name:status]",
		},
		["HealthBar Right Text"] = {
			attachTo = "HealthBar",
			position = "RIGHT",
			offsetX = -2,
			offsetY = 0,

			size = 11,
			color = { r = 1, g = 1, b = 1, a = 1 },

			text = "[health:percentage]",
		},
		["PowerBar Left Text"] = {
			attachTo = "PowerBar",
			position = "LEFT",
			offsetX = 2,
			offsetY = 0,

			size = 11,
			color = { r = 1, g = 1, b = 1, a = 1 },

			text = "[spec]",
		},
		["PowerBar Right Text"] = {
			attachTo = "PowerBar",
			position = "RIGHT",
			offsetX = -2,
			offsetY = 0,

			size = 11,
			color = { r = 1, g = 1, b = 1, a = 1 },

			text = "[power:short]/[maxpower:short]",
		},
		["TargetBar Left Text"] = {
			attachTo = "TargetBar",
			position = "LEFT",
			offsetX = 2,
			offsetY = 0,

			size = 11,
			color = { r = 1, g = 1, b = 1, a = 1 },

			text = "[name:status]",
		},
		["TargetBar Right Text"] = {
			attachTo = "TargetBar",
			position = "RIGHT",
			offsetX = -2,
			offsetY = 0,

			size = 11,
			color = { r = 1, g = 1, b = 1, a = 1 },

			text = "[health:short] / [maxhealth:short] ([health:percentage])",
		},
	},
})

function Tags:OnEnable()
	LSM = GladiusEx.LSM

	self.version = 1

	-- frame
	if (not self.frame) then
		self.frame = {}
	end

	-- cached functions
	self.func = {}

	-- gather events
	self.events = {}

	for k,v in pairs(GladiusEx.db.tagsTexts) do
		-- get tags
		for tag in v.text:gmatch("%[(.-)%]") do
			-- get events
			local tag_events = self:GetTagEvents(tag)
			if tag_events then
				for event in tag_events:gmatch("%S+") do
					if (not self.events[event]) then
						self.events[event] = {}
					end

					self.events[event][k] = true
				end
			end
		end
	end

	-- register events
	for event in pairs(self.events) do
		if (strfind(event, "GLADIUS")) then
			self:RegisterMessage(event, "OnMessage")
		else
			self:RegisterEvent(event, "OnEvent")
		end
	end

	GladiusEx.db.tagsVersion = self.version
end

function Tags:OnDisable()
	self:UnregisterAllEvents()

	for unit in pairs(self.frame) do
		for text in pairs(self.frame[unit]) do
			self.frame[unit][text]:SetAlpha(0)
		end
	end
end

function Tags:GetAttachTo()
	return nil
end

function Tags:OnMessage(event, unit)
	if (self.events[event]) then
		-- update texts
		for text, _ in pairs(self.events[event]) do
			self:UpdateText(unit, text)
		end
	end
end

function Tags:OnEvent(event, unit)
	-- hack
	if event == "PLAYER_TARGET_CHANGED" then unit = "player" end

	if (self.events[event]) then
		-- update texts
		for text, _ in pairs(self.events[event]) do
			self:UpdateText(unit, text)
		end
	end
end

function Tags:CreateFrame(unit, text)
	local button = GladiusEx.buttons[unit]
	if (not button) then return end

	-- create frame
	self.frame[unit][text] = button:CreateFontString("GladiusEx" .. self:GetName() .. unit .. text, "OVERLAY")
end

function Tags:UpdateText(unit, text)
	if not self.frame[unit] or not self.frame[unit][text] then return end

	-- set unit
	local parent = self.frame[unit][text]:GetParent()
	local unit_parameter = parent and parent.unit or unit

	-- update tag
	local tagText = GladiusEx.db.tagsTexts[text].text

	local formattedText = strgsub(GladiusEx.db.tagsTexts[text].text, "%[(.-)%]", function(tag)
		local func = self.func[tag] or self:GetTagFunc(tag)
		if func then
			self.func[tag] = func

			local text = func(unit_parameter)

			return text
		end
	end)

	self.frame[unit][text]:SetText(formattedText or tagText)
end

function Tags:GetTagFunc(tag)
	local builtins = self:GetBuiltinTags()
	if GladiusEx.db.tags[tag] then
		return loadstring("local strformat = string.format; return " .. GladiusEx.db.tags[tag])()
	elseif builtins[tag] then
		return builtins[tag]
	else
		return nil
	end
end

function Tags:GetTagEvents(tag)
	return GladiusEx.db.tagEvents[tag] or self:GetBuiltinTagsEvents()[tag]
end

function Tags:Update(unit)
	if (not self.frame[unit]) then
		self.frame[unit] = {}
	end

	for text, _ in pairs(GladiusEx.db.tagsTexts) do
		local attachframe = GladiusEx:GetAttachFrame(unit, GladiusEx.db.tagsTexts[text].attachTo, true)

		if attachframe then
			-- create frame
			if (not self.frame[unit][text]) then
				self:CreateFrame(unit, text)
			end

			-- update frame
			self.frame[unit][text]:ClearAllPoints()
			self.frame[unit][text]:SetParent(attachframe)
			self.frame[unit][text]:SetPoint(GladiusEx.db.tagsTexts[text].position, attachframe, GladiusEx.db.tagsTexts[text].position, GladiusEx.db.tagsTexts[text].offsetX, GladiusEx.db.tagsTexts[text].offsetY)

			-- limit text bounds
			local invpos = GladiusEx.db.tagsTexts[text].position
			if invpos == "LEFT" then invpos = "RIGHT"
			elseif invpos == "RIGHT" then invpos = "LEFT"
			end
			if invpos ~= GladiusEx.db.tagsTexts[text].position then
				self.frame[unit][text]:SetPoint(invpos, attachframe, invpos, 0, 0)
				self.frame[unit][text]:SetJustifyH(GladiusEx.db.tagsTexts[text].position)
			end

			self.frame[unit][text]:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.globalFont), (GladiusEx.db.useGlobalFontSize and GladiusEx.db.globalFontSize or GladiusEx.db.tagsTexts[text].size))
			self.frame[unit][text]:SetTextColor(GladiusEx.db.tagsTexts[text].color.r, GladiusEx.db.tagsTexts[text].color.g, GladiusEx.db.tagsTexts[text].color.b, GladiusEx.db.tagsTexts[text].color.a)

			self.frame[unit][text]:SetShadowOffset(1, -1)
			self.frame[unit][text]:SetShadowColor(0, 0, 0, 1)

			-- update text
			self:UpdateText(unit, text)

			-- hide
			self.frame[unit][text]:SetAlpha(0)
		end
	end
end

function Tags:Show(unit)
	if (not self.frame[unit]) then
		self.frame[unit] = {}
	end

	-- update text
	for text, _ in pairs(GladiusEx.db.tagsTexts) do
		self:UpdateText(unit, text)
	end

	-- show
	for _, text in pairs(self.frame[unit]) do
		text:SetAlpha(1)
	end
end

function Tags:Reset(unit)
	if (not self.frame[unit]) then
		self.frame[unit] = {}
	end

	-- hide
	for _, text in pairs(self.frame[unit]) do
		text:SetAlpha(0)
	end
end

function Tags:Test(unit)
	-- test
end

local function getOption(info)
	local key = info[#info - 2]
	return GladiusEx.dbi.profile.tagsTexts[key][info[#info]]
end

local function setOption(info, value)
	local key = info[#info - 2]
	GladiusEx.dbi.profile.tagsTexts[key][info[#info]] = value
	GladiusEx:UpdateFrames()
end

local function getColorOption(info)
	local key = info[#info - 2]
	return GladiusEx.dbi.profile.tagsTexts[key][info[#info]].r, GladiusEx.dbi.profile.tagsTexts[key][info[#info]].g,
		GladiusEx.dbi.profile.tagsTexts[key][info[#info]].b, GladiusEx.dbi.profile.tagsTexts[key][info[#info]].a
end

local function setColorOption(info, r, g, b, a)
	local key = info[#info - 2]
	GladiusEx.dbi.profile.tagsTexts[key][info[#info]].r, GladiusEx.dbi.profile.tagsTexts[key][info[#info]].g,
	GladiusEx.dbi.profile.tagsTexts[key][info[#info]].b, GladiusEx.dbi.profile.tagsTexts[key][info[#info]].a = r, g, b, a
	GladiusEx:UpdateFrames()
end

function Tags:GetOptions()
	-- add text values
	self.addTextAttachTo = "HealthBar"
	self.addTextName = ""

	-- add tag values
	self.addTagName = ""

	local options = {
		textList = {
			type="group",
			name=L["Texts"],
			order=1,
			args = {
				add = {
					type="group",
					name=L["Add text"],
					inline=true,
					order=1,
					args = {
						name = {
							type="input",
							name=L["Name"],
							desc=L["Name of the text element"],
							get=function(info)
								return self.addTextName
							end,
							set=function(info, value)
								self.addTextName = value
							end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						attachTo = {
							type="select",
							name=L["Text Attach To"],
							desc=L["Attach text to module bar"],
							values=function()
								local t = {}

								for moduleName, module in pairs(GladiusEx.modules) do
									if (module.isBarOption) then
										t[moduleName] = moduleName
									end
								end

								return t
							end,
							get=function(info)
								return self.addTextAttachTo
							end,
							set=function(info, value)
								self.addTextAttachTo = value
							end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
						add = {
							type="execute",
							name=L["Add Text"],
							func=function()
								local text = self.addTextAttachTo .. " " .. self.addTextName

								if (self.addTextName ~= "" and not GladiusEx.db.tagsTexts[text]) then
									-- add to db
									GladiusEx.db.tagsTexts[text] = {
										attachTo = self.addTextAttachTo,
										position = "LEFT",
										offsetX = 0,
										offsetY = 0,

										size = 11,
										color = { r = 1, g = 1, b = 1, a = 1 },

										text = ""
									}

									-- add to options
									GladiusEx.options.args[self:GetName()].args.textList.args[text] = self:GetTextOptionTable(text, order)

									-- set tags
									GladiusEx.options.args[self:GetName()].args.textList.args[text].args.tag.args = self.optionTags

									-- update
									GladiusEx:UpdateFrames()
								end
							end,
							order=15,
						},
					},
				},
			},
		},
		tagList = {
			type="group",
			name=L["Tags"],
			hidden=function() return not GladiusEx.db.advancedOptions end,
			order=2,
			args = {
				add = {
					type="group",
					name=L["Add tag"],
					inline=true,
					order=1,
					args = {
						name = {
							type="input",
							name=L["Name"],
							desc=L["Name of the tag"],
							get=function(info)
								return self.addTagName
							end,
							set=function(info, value)
								self.addTagName = value
							end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=5,
						},
						add = {
							type="execute",
							name=L["Add Tag"],
							func=function()
								if (self.addTagName ~= "" and not GladiusEx.db.tags[self.addTagName]) then
									-- add to db
									GladiusEx.db.tags[self.addTagName] = "function(unit)\n  return UnitName(unit)\nend"
									GladiusEx.db.tagEvents[self.addTagName] = ""

									-- add to options
									GladiusEx.options.args[self:GetName()].args.tagList.args[self.addTagName] = self:GetTagOptionTable(self.addTagName, order)

									-- add to text option tags
									for text, v in pairs(GladiusEx.options.args[self:GetName()].args.textList.args) do
										if (v.args.tag) then
											local tag = self.addTagName
											local tagName = Tags:FormatTagName(tag)

											GladiusEx.options.args[self:GetName()].args.textList.args[text].args.tag.args[tag] = {
												type="toggle",
												name=tagName,
												get=function(info)
													local key = info[#info - 2]

													-- check if the tag is in the text
													if (strfind(GladiusEx.dbi.profile.tagsTexts[key].text, "%[" .. info[#info] .. "%]")) then
														return true
													else
														return false
													end
												end,
												set=function(info, v)
													local key = info[#info - 2]

													-- add/remove tag to the text
													if (not v) then
														GladiusEx.dbi.profile.tagsTexts[key].text = strgsub(GladiusEx.dbi.profile.tagsTexts[key].text, "%[" .. info[#info] .. "%]", "")

														-- trim right
														GladiusEx.dbi.profile.tagsTexts[key].text = strgsub(GladiusEx.dbi.profile.tagsTexts[key].text, "^(.-)%s*$", "%1")
													else
														GladiusEx.dbi.profile.tagsTexts[key].text = GladiusEx.dbi.profile.tagsTexts[key].text .. " [" .. info[#info] .. "]"
													end

													-- update
													GladiusEx:UpdateFrames()
												end,
												order=order,
											}
										end
									end

									-- update
									GladiusEx:UpdateFrames()
								end
							end,
							order=10,
						},
					},
				},
			},
		},
	}

	-- text option tags
	self.optionTags = {
		text = {
			type="input",
			name=L["Text"],
			desc=L["Text to be displayed"],
			disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
			width="double",
			order=1,
		},
	}

	local order = 2

	local function MakeTagTextOption(tag)
		local tagName = Tags:FormatTagName(tag)

		self.optionTags[tag] = {
			type="toggle",
			name=tagName,
			get=function(info)
				local key = info[#info - 2]

				-- check if the tag is in the text
				if (strfind(GladiusEx.dbi.profile.tagsTexts[key].text, "%[" .. info[#info] .. "%]")) then
					return true
				else
					return false
				end
			end,
			set=function(info, v)
				local key = info[#info - 2]

				-- add/remove tag to the text
				if (not v) then
					GladiusEx.dbi.profile.tagsTexts[key].text = strgsub(GladiusEx.dbi.profile.tagsTexts[key].text, "%[" .. info[#info] .. "%]", "")

					-- trim right
					GladiusEx.dbi.profile.tagsTexts[key].text = strgsub(GladiusEx.dbi.profile.tagsTexts[key].text, "^(.-)%s*$", "%1")
				else
					GladiusEx.dbi.profile.tagsTexts[key].text = GladiusEx.dbi.profile.tagsTexts[key].text .. " [" .. info[#info] .. "]"
				end

				-- update
				GladiusEx:UpdateFrames()
			end,
			order=order,
		}

		order = order + 1
	end

	local tag_names = self:GetTagNames()
	table.sort(tag_names, function(a, b)
		return Tags:FormatTagName(a) < Tags:FormatTagName(b)
	end)
	for _, tag in ipairs(tag_names) do MakeTagTextOption(tag) end

	-- texts
	order = 1
	for text, _ in pairs(GladiusEx.dbi.profile.tagsTexts) do
		options.textList.args[text] = self:GetTextOptionTable(text, order)

		-- set tags
		options.textList.args[text].args.tag.args = self.optionTags

		order = order + 1
	end

	-- tags
	order = 1
	for tag, _ in pairs(GladiusEx.dbi.profile.tags) do
		options.tagList.args[tag] = self:GetTagOptionTable(tag, order)
		order = order + 1
	end

	return options
end

function Tags:GetTextOptionTable(text, order)
	return {
		type="group",
		name=text,
		childGroups="tree",
		get=getOption,
		set=setOption,
		order=order,
		args = {
			delete = {
				type="execute",
				name=L["Delete Text"],
				func=function()
					-- remove from db
					GladiusEx.db.tagsTexts[text] = nil

					-- remove from options
					GladiusEx.options.args[self:GetName()].args.textList.args[text] = nil

					-- update
					GladiusEx:UpdateFrames()
				end,
				order=1,
			},
			tag = {
				type="group",
				name=L["Tag"],
				desc=L["Tag settings"],
				inline=true,
				order=2,
				args = {},
			},
			text = {
				type="group",
				name=L["Text"],
				desc=L["Text settings"],
				inline=true,
				order=3,
				args = {
					color = {
						type="color",
						name=L["Text Color"],
						desc=L["Text color of the text"],
						hasAlpha=true,
						get=getColorOption,
						set=setColorOption,
						disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
						order=5,
					},
					size = {
						type="range",
						name=L["Text Size"],
						desc=L["Text size of the text"],
						min=1, max=20, step=1,
						disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] or GladiusEx.db.useGlobalFontSize end,
						order=10,
					},
				},
			},
			position = {
				type="group",
				name=L["Position"],
				desc=L["Position settings"],
				inline=true,
				order=4,
				args = {
					position = {
						type="select",
						name=L["Text Align"],
						desc=L["Text align of the text"],
						values={ ["LEFT"] = L["LEFT"], ["CENTER"] = L["CENTER"], ["RIGHT"] = L["RIGHT"] },
						disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
						width="double",
						order=5,
					},
					offsetX = {
						type="range",
						name=L["Text Offset X"],
						desc=L["X offset of the text"],
						min=-100, max=100, step=1,
						disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
						hidden=function() return not GladiusEx.db.advancedOptions end,
						order=10,
					},
					offsetY = {
						type="range",
						name=L["Text Offset Y"],
						desc=L["Y offset of the text"],
						disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
						hidden=function() return not GladiusEx.db.advancedOptions end,
						min=-100, max=100, step=1,
						order=15,
					},
				},
			},
		},
	}
end

function Tags:FormatTagName(tag)
	local tag_name = rawget(L, tag .. "Tag") or strformat(L["Tag: %s"], tag)
	return tag_name
end

function Tags:GetTagOptionTable(tag, order)
	local tagName = self:FormatTagName(tag)

	return {
		type="group",
		name=tagName,
		childGroups="tree",
		order=order,
		args = {
			delete = {
				type="execute",
				name=L["Delete Tag"],
				func=function()
					-- remove from db
					GladiusEx.db.tags[tag] = nil
					GladiusEx.db.tagEvents[tag] = nil

					-- remove from options
					GladiusEx.options.args[self:GetName()].args.tagList.args[tag] = nil

					-- remove from text option tags
					for text, v in pairs(GladiusEx.options.args[self:GetName()].args.textList.args) do
						if (v.args.tag and v.args.tag.args[tag]) then
							GladiusEx.options.args[self:GetName()].args.textList.args[text].args.tag.args[tag] = nil
						end
					end

					-- update
					GladiusEx:UpdateFrames()
				end,
				order=1,
			},
			tag = {
				type="group",
				name=L["Tag"],
				desc=L["Tag settings"],
				inline=true,
				order=2,
				args = {
					name = {
						type="input",
						name=L["Name"],
						desc=L["Name of the tag"],
						get=function(info)
							local key = info[#info - 2]
							return key
						end,
						set=function(info, value)
							local key = info[#info - 2]

							-- db
							GladiusEx.db.tags[value] = GladiusEx.db.tags[key]
							GladiusEx.db.tagEvents[value] = GladiusEx.db.tagEvents[key]

							GladiusEx.db.tags[key] = nil
							GladiusEx.db.tagEvents[key] = nil

							-- options
							GladiusEx.options.args[self:GetName()].args.tagList.args[key] = nil
							GladiusEx.options.args[self:GetName()].args.tagList.args[value] = self:GetTagOptionTable(value, order)

							-- update
							GladiusEx:UpdateFrames()
						end,
						disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
						width="double",
						order=5,
					},
					events = {
						type="input",
						name=L["Events"],
						desc=L["Events which update the tag"],
						get=function(info)
							local key = info[#info - 2]
							return GladiusEx.db.tagEvents[key]
						end,
						set=function(info, value)
							local key = info[#info - 2]
							GladiusEx.db.tagEvents[key] = value

							-- update
							GladiusEx:UpdateFrames()
						end,
						disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
						width="double",
						order=10,
					},
					func = {
						type="input",
						name=L["Function"],
						get=function(info)
							local key = info[#info - 2]
							return GladiusEx.db.tags[key]
						end,
						set=function(info, value)
							local key = info[#info - 2]
							GladiusEx.db.tags[key] = value

							-- delete cached function
							self.func[key] = nil

							-- update
							GladiusEx:UpdateFrames()
						end,
						disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
						width="double",
						multiline=true,
						order=15,
					},
				},
			},
		},
	}
end

function Tags:GetBuiltinTags()
	return {
		["name"] = function(unit)
			return UnitName(unit) or unit
		end,
		["name:status"] = function(unit)
			return UnitIsDeadOrGhost(unit) and GladiusEx.L["DEAD"] or (UnitName(unit) or unit)
		end,
		["class"] = function(unit)
			return not GladiusEx:IsTesting(unit) and UnitClass(unit) or LOCALIZED_CLASS_NAMES_MALE[GladiusEx.testing[unit].unitClass]
		end,
		["class:short"] = function(unit)
			return not GladiusEx:IsTesting(unit) and GladiusEx.L[(select(2, UnitClass(unit)) or GladiusEx.buttons[unit].class or "") .. ":short"] or GladiusEx.L[GladiusEx.testing[unit].unitClass .. ":short"]
		end,
		["race"] = function(unit)
			return not GladiusEx:IsTesting(unit) and UnitRace(unit) or GladiusEx.testing[unit].unitRace
		end,
		["spec"] = function(unit)
			return GladiusEx:IsTesting(unit) and GladiusEx.testing[unit].unitSpec or GladiusEx.buttons[unit].spec or ""
		end,
		["spec:short"] = function(unit)
			local spec = GladiusEx:IsTesting(unit) and GladiusEx.testing[unit].specID or GladiusEx.buttons[unit].specID or 0
			if (spec == nil or spec == 0) then
				return ""
			end
			return GladiusEx.L["specID:" .. spec .. ":short"]
		end,
		["health"] = function(unit)
			return not GladiusEx:IsTesting(unit) and UnitHealth(unit) or GladiusEx.testing[unit].health
		end,
		["maxhealth"] = function(unit)
			return not GladiusEx:IsTesting(unit) and UnitHealthMax(unit) or GladiusEx.testing[unit].maxHealth
		end,
		["health:short"] = function(unit)
			local health = not GladiusEx:IsTesting(unit) and UnitHealth(unit) or GladiusEx.testing[unit].health
			if (health > 999) then
				return strformat("%.1fk", (health / 1000))
			else
				return health
			end
		end,
		["maxhealth:short"] = function(unit)
			local health = not GladiusEx:IsTesting(unit) and UnitHealthMax(unit) or GladiusEx.testing[unit].maxHealth
			if (health > 999) then
				return strformat("%.1fk", (health / 1000))
			else
				return health
			end
		end,
		["health:percentage"] = function(unit)
			local health = not GladiusEx:IsTesting(unit) and UnitHealth(unit) or GladiusEx.testing[unit].health
			local maxHealth = not GladiusEx:IsTesting(unit) and UnitHealthMax(unit) or GladiusEx.testing[unit].maxHealth
			return (maxHealth and maxHealth > 0) and strformat("%.1f%%", (health / maxHealth * 100)) or ""
		end,

		["power"] = function(unit)
			return not GladiusEx:IsTesting(unit) and UnitPower(unit) or GladiusEx.testing[unit].power
		end,
		["maxpower"] = function(unit)
			return not GladiusEx:IsTesting(unit) and UnitPowerMax(unit) or GladiusEx.testing[unit].maxPower
		end,
		["power:short"] = function(unit)
			local power = not GladiusEx:IsTesting(unit) and UnitPower(unit) or GladiusEx.testing[unit].power

			if (power > 999) then
				return strformat("%.1fk", (power / 1000))
			else
				return power
			end
		end,
		["maxpower:short"] = function(unit)
			local power = not GladiusEx:IsTesting(unit) and UnitPowerMax(unit) or GladiusEx.testing[unit].maxPower

			if (power > 999) then
				return strformat("%.1fk", (power / 1000))
			else
				return power
			end
		end,
		["power:percentage"] = function(unit)
			local power = not GladiusEx:IsTesting(unit) and UnitPower(unit) or GladiusEx.testing[unit].power
			local maxPower = not GladiusEx:IsTesting(unit) and UnitPowerMax(unit) or GladiusEx.testing[unit].maxPower
			return (maxPower and maxPower > 0) and strformat("%.1f%%", (power / maxPower * 100)) or ""
		end,
	}
end

function Tags:GetTagNames()
	local names = {}
	for tag, _ in pairs(self:GetBuiltinTags()) do table.insert(names, tag) end
	for tag, _ in pairs(GladiusEx.dbi.profile.tags) do table.insert(names, tag) end
	return names
end

function Tags:GetBuiltinTagsEvents()
	return {
		["name"] = "UNIT_NAME_UPDATE UNIT_TARGET PLAYER_TARGET_CHANGED",
		["name:status"] = "UNIT_NAME_UPDATE UNIT_HEALTH UNIT_TARGET PLAYER_TARGET_CHANGED",
		["class"] = "UNIT_NAME_UPDATE UNIT_TARGET PLAYER_TARGET_CHANGED",
		["class:short"] = "UNIT_NAME_UPDATE UNIT_TARGET PLAYER_TARGET_CHANGED",
		["race"] = "UNIT_NAME_UPDATE UNIT_TARGET PLAYER_TARGET_CHANGED",
		["spec"] = "UNIT_NAME_UPDATE GLADIUS_SPEC_UPDATE UNIT_TARGET PLAYER_TARGET_CHANGED",
		["spec:short"] = "UNIT_NAME_UPDATE GLADIUS_SPEC_UPDATE UNIT_TARGET PLAYER_TARGET_CHANGED",

		["health"] = "UNIT_HEALTH UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE",
		["maxhealth"] = "UNIT_HEALTH UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE",
		["health:short"] = "UNIT_HEALTH UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE",
		["maxhealth:short"] = "UNIT_HEALTH UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE",
		["health:percentage"] = "UNIT_HEALTH UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_NAME_UPDATE",

		["power"] = "UNIT_POWER UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_NAME_UPDATE",
		["maxpower"] = "UNIT_MAXPOWER UNIT_DISPLAYPOWER UNIT_NAME_UPDATE",
		["power:short"] = "UNIT_POWER UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_NAME_UPDATE",
		["maxpower:short"] = "UNIT_MAXPOWER UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER UNIT_NAME_UPDATE",
		["power:percentage"] = "UNIT_POWER UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER UNIT_NAME_UPDATE",
	}
end
