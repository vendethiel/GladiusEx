local GladiusEx = _G.GladiusEx
local fn = LibStub("LibFunctional-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM

-- global functions
local strfind, strgsub, strgmatch, strformat = string.find, string.gsub, string.gmatch, string.format
local tinsert = table.insert
local pairs, select = pairs, select

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

	-- frame
	if (not self.frame) then
		self.frame = {}
	end

	-- cached functions
	self:ClearTagCache()

	-- gather events
	self:UpdateEvents()
end

function Tags:OnProfileChanged()
	self.super.OnProfileChanged(self)
	-- regenerate options
	self:GetOptions()
end

function Tags:UpdateEvents()
	self.events = {}

	for k,v in pairs(self.db.tagsTexts) do
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
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()

	for event in pairs(self.events) do
		if (strfind(event, "GLADIUS")) then
			self:RegisterMessage(event, "OnMessage")
		else
			self:RegisterEvent(event, "OnEvent")
		end
	end
end

function Tags:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()

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

-- Takes a tag text and returns a function that receives a unit parameter and returns the formatted text
function Tags:ParseText(text)
	local out = {}
	local arg_values = {}
	
	local function output_text(otext)
		if otext ~= "" then
			tinsert(arg_values, otext)
			tinsert(out, "args[" .. tostring(#out + 1) .. "]")
		end
	end

	local function output_tag(tag)
		tinsert(arg_values, self:GetTagFunc(tag))
		tinsert(out, "args[" .. tostring(#out + 1) .. "](unit) or default")
	end

	while true do
		local posb, tag, pose = string.match(text, "()%[(.-)%]()")
		if not posb then
			output_text(text)
			break
		end
		local otext = string.sub(text, 1, posb - 1)
		output_text(otext)
		output_tag(tag)
		text = string.sub(text, pose)
	end

	local fntext = [[local strjoin, default = strjoin, ""; return function(args, unit) ]] ..
		[[ return strjoin("", ]] .. table.concat(out, ", ") .. [[)]] ..
		[[ end]]
	local text_fn = loadstring(fntext)()
	return fn.bind(text_fn, arg_values)
end

function Tags:GetTextFunction(tagText)
	local fn = self.text_cache[tagText]
	if not fn then
		fn = self:ParseText(tagText)
		self.text_cache[tagText] = fn
	end
	return fn
end

function Tags:GetTagFunc(tag)
	local func = self.func_cache[tag]
	if not func then
		local builtins = self:GetBuiltinTags()
		if self.db.tags[tag] then
			func = loadstring("local strformat = string.format; return " .. self.db.tags[tag])()
		elseif builtins[tag] then
			func = builtins[tag]
		else
			func = function() return "[" .. tag .. "]" end
		end
		self.func_cache[tag] = func
	end
	return func
end

function Tags:ClearTagCache()
	self.func_cache = {}
	self.text_cache = {}
end

function Tags:UpdateText(unit, text)
	if not self.frame[unit] or not self.frame[unit][text] then return end

	-- set unit
	local parent = self.frame[unit][text]:GetParent()
	local unit_parameter = parent and parent.unit or unit

	-- update tag
	local tagText = self.db.tagsTexts[text].text

	local fn = self:GetTextFunction(tagText)
	local formattedText = fn(unit)

	--[[
	local formattedText = strgsub(self.db.tagsTexts[text].text, "%[(.-)%]", function(tag)
			return self:GetTagFunc(tag)(unit_parameter)
		end
	end)
	]]

	self.frame[unit][text]:SetText(formattedText or tagText)
end

function Tags:GetTagEvents(tag)
	return self.db.tagEvents[tag] or self:GetBuiltinTagsEvents()[tag]
end

function Tags:Refresh(unit)
	for text, _ in pairs(self.db.tagsTexts) do
		-- update text
		self:UpdateText(unit, text)
	end
end

function Tags:Update(unit)
	if (not self.frame[unit]) then
		self.frame[unit] = {}
	end

	self:ClearTagCache()
	self:UpdateEvents()

	for text, _ in pairs(self.db.tagsTexts) do
		local attachframe = GladiusEx:GetAttachFrame(unit, self.db.tagsTexts[text].attachTo, true)

		if attachframe then
			-- create frame
			if (not self.frame[unit][text]) then
				self:CreateFrame(unit, text)
			end

			-- update frame
			self.frame[unit][text]:ClearAllPoints()
			self.frame[unit][text]:SetParent(attachframe)
			self.frame[unit][text]:SetPoint(self.db.tagsTexts[text].position, attachframe, self.db.tagsTexts[text].position, self.db.tagsTexts[text].offsetX, self.db.tagsTexts[text].offsetY)

			-- limit text bounds
			local invpos = self.db.tagsTexts[text].position
			if invpos == "LEFT" then invpos = "RIGHT"
			elseif invpos == "RIGHT" then invpos = "LEFT"
			end
			if invpos ~= self.db.tagsTexts[text].position then
				self.frame[unit][text]:SetPoint(invpos, attachframe, invpos, 0, 0)
				self.frame[unit][text]:SetJustifyH(self.db.tagsTexts[text].position)
			end

			self.frame[unit][text]:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.globalFont), (GladiusEx.db.useGlobalFontSize and GladiusEx.db.globalFontSize or self.db.tagsTexts[text].size))
			self.frame[unit][text]:SetTextColor(self.db.tagsTexts[text].color.r, self.db.tagsTexts[text].color.g, self.db.tagsTexts[text].color.b, self.db.tagsTexts[text].color.a)

			self.frame[unit][text]:SetShadowOffset(1, -1)
			self.frame[unit][text]:SetShadowColor(0, 0, 0, 1)

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
	for text, _ in pairs(self.db.tagsTexts) do
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
	return Tags.db.tagsTexts[key][info[#info]]
end

local function setOption(info, value)
	local key = info[#info - 2]
	Tags.db.tagsTexts[key][info[#info]] = value
	GladiusEx:UpdateFrames()
end

local function getColorOption(info)
	local key = info[#info - 2]
	return Tags.db.tagsTexts[key][info[#info]].r, Tags.db.tagsTexts[key][info[#info]].g,
		Tags.db.tagsTexts[key][info[#info]].b, Tags.db.tagsTexts[key][info[#info]].a
end

local function setColorOption(info, r, g, b, a)
	local key = info[#info - 2]
	Tags.db.tagsTexts[key][info[#info]].r, Tags.db.tagsTexts[key][info[#info]].g,
	Tags.db.tagsTexts[key][info[#info]].b, Tags.db.tagsTexts[key][info[#info]].a = r, g, b, a
	GladiusEx:UpdateFrames()
end

Tags.options = {}
function Tags:GetOptions()
	-- add text values
	self.addTextAttachTo = "HealthBar"
	self.addTextName = ""

	-- add tag values
	self.addTagName = ""

	self.options.textList = {
		type = "group",
		name = L["Texts"],
		order = 1,
		args = {
			add = {
				type = "group",
				name = L["Add text"],
				inline = true,
				order = 1,
				args = {
					name = {
						type = "input",
						name = L["Name"],
						desc = L["Name of the text element"],
						get = function(info)
							return self.addTextName
						end,
						set = function(info, value)
							self.addTextName = value
						end,
						disabled = function() return not self:IsEnabled() end,
						order = 5,
					},
					attachTo = {
						type = "select",
						name = L["Attach to"],
						desc = L["Attach text to module bar"],
						values = function()
							local t = {}

							for moduleName, module in GladiusEx:IterateModules() do
								if (module.isBarOption) then
									t[moduleName] = moduleName
								end
							end

							return t
						end,
						get = function(info)
							return self.addTextAttachTo
						end,
						set = function(info, value)
							self.addTextAttachTo = value
						end,
						disabled = function() return not self:IsEnabled() end,
						order = 10,
					},
					add = {
						type = "execute",
						name = L["Add text"],
						func = function()
							local text = self.addTextAttachTo .. " " .. self.addTextName

							if (self.addTextName ~= "" and not self.db.tagsTexts[text]) then
								-- add to db
								self.db.tagsTexts[text] = {
									attachTo = self.addTextAttachTo,
									position = "LEFT",
									offsetX = 0,
									offsetY = 0,

									size = 11,
									color = { r = 1, g = 1, b = 1, a = 1 },

									text = ""
								}

								-- add to options
								self.options.textList.args[text] = self:GetTextOptionTable(text, 100)

								-- set tags
								self.options.textList.args[text].args.tag.args = self.optionTags

								-- update
								GladiusEx:UpdateFrames()
							end
						end,
						order = 15,
					},
				},
			},
		}
	}

	self.options.tagList = {
		type = "group",
		name = L["Tags"],
		hidden = function() return not GladiusEx.db.advancedOptions end,
		order = 2,
		args = {
			add = {
				type = "group",
				name = L["Add tag"],
				inline = true,
				order = 1,
				args = {
					name = {
						type = "input",
						name = L["Name"],
						desc = L["Name of the tag"],
						get = function(info)
							return self.addTagName
						end,
						set = function(info, value)
							self.addTagName = value
						end,
						disabled = function() return not self:IsEnabled() end,
						order = 5,
					},
					add = {
						type = "execute",
						name = L["Add tag"],
						func = function()
							if (self.addTagName ~= "" and not self.db.tags[self.addTagName]) then
								-- add to db
								self.db.tags[self.addTagName] = "function(unit)\n  return UnitName(unit)\nend"
								self.db.tagEvents[self.addTagName] = ""

								-- add to options
								self.options.tagList.args[self.addTagName] = self:GetTagOptionTable(self.addTagName, 100)

								-- add to text option tags
								for text, v in pairs(self.options.textList.args) do
									if (v.args.tag) then
										local tag = self.addTagName
										local tagName = Tags:FormatTagName(tag)

										self.options.textList.args[text].args.tag.args[tag] = {
											type = "toggle",
											name = tagName,
											get = function(info)
												local key = info[#info - 2]

												-- check if the tag is in the text
												if (strfind(self.db.tagsTexts[key].text, "%[" .. info[#info] .. "%]")) then
													return true
												else
													return false
												end
											end,
											set = function(info, v)
												local key = info[#info - 2]

												-- add/remove tag to the text
												if (not v) then
													self.db.tagsTexts[key].text = strgsub(self.db.tagsTexts[key].text, "%[" .. info[#info] .. "%]", "")

													-- trim right
													self.db.tagsTexts[key].text = strgsub(self.db.tagsTexts[key].text, "^(.-)%s*$", "%1")
												else
													self.db.tagsTexts[key].text = self.db.tagsTexts[key].text .. " [" .. info[#info] .. "]"
												end

												-- update
												GladiusEx:UpdateFrames()
											end,
											order = 100,
										}
									end
								end

								-- update
								GladiusEx:UpdateFrames()
							end
						end,
						order = 10,
					},
				},
			},
		},
	}

	-- text option tags
	self.optionTags = {
		text = {
			type = "input",
			name = L["Text"],
			desc = L["Text to be displayed"],
			disabled = function() return not self:IsEnabled() end,
			width = "double",
			order = 1,
		},
	}

	local order = 2

	local function MakeTagTextOption(tag)
		local tagName = Tags:FormatTagName(tag)

		self.optionTags[tag] = {
			type = "toggle",
			name = tagName,
			get = function(info)
				local key = info[#info - 2]

				-- check if the tag is in the text
				if (strfind(self.db.tagsTexts[key].text, "%[" .. info[#info] .. "%]")) then
					return true
				else
					return false
				end
			end,
			set = function(info, v)
				local key = info[#info - 2]

				-- add/remove tag to the text
				if (not v) then
					self.db.tagsTexts[key].text = strgsub(self.db.tagsTexts[key].text, "%[" .. info[#info] .. "%]", "")

					-- trim right
					self.db.tagsTexts[key].text = strgsub(self.db.tagsTexts[key].text, "^(.-)%s*$", "%1")
				else
					self.db.tagsTexts[key].text = self.db.tagsTexts[key].text .. " [" .. info[#info] .. "]"
				end

				-- update
				GladiusEx:UpdateFrames()
			end,
			order = order,
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
	local sorted_texts = fn.sort(fn.keys(self.db.tagsTexts))
	for _, text in ipairs(sorted_texts) do
		self.options.textList.args[text] = self:GetTextOptionTable(text, order)

		-- set tags
		self.options.textList.args[text].args.tag.args = self.optionTags

		order = order + 1
	end

	-- tags
	order = 1
	for tag, _ in pairs(self.db.tags) do
		self.options.tagList.args[tag] = self:GetTagOptionTable(tag, order)
		order = order + 1
	end

	return self.options
end

function Tags:GetTextOptionTable(text, order)
	return {
		type = "group",
		name = text,
		childGroups = "tree",
		get = getOption,
		set = setOption,
		order = order,
		args = {
			delete = {
				type = "execute",
				name = L["Delete text"],
				func = function()
					-- remove from db
					self.db.tagsTexts[text] = nil

					-- remove from options
					self.options.textList.args[text] = nil

					-- update
					GladiusEx:UpdateFrames()
				end,
				order = 1,
			},
			tag = {
				type = "group",
				name = L["Tag"],
				desc = L["Tag settings"],
				inline = true,
				order = 2,
				args = {},
			},
			text = {
				type = "group",
				name = L["Text"],
				desc = L["Text settings"],
				inline = true,
				order = 3,
				args = {
					color = {
						type = "color",
						name = L["Text color"],
						desc = L["Color of the text"],
						hasAlpha = true,
						get = getColorOption,
						set = setColorOption,
						disabled = function() return not self:IsEnabled() end,
						order = 5,
					},
					size = {
						type = "range",
						name = L["Text size"],
						desc = L["Size of the text"],
						min = 1, max = 20, step = 1,
						disabled = function() return not self:IsEnabled() or GladiusEx.db.useGlobalFontSize end,
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
					position = {
						type = "select",
						name = L["Text align"],
						desc = L["Align of the text"],
						values = { ["LEFT"] = L["Left"], ["CENTER"] = L["Center"], ["RIGHT"] = L["Right"] },
						disabled = function() return not self:IsEnabled() end,
						width = "double",
						order = 5,
					},
					offsetX = {
						type = "range",
						name = L["Offset X"],
						desc = L["X offset of the frame"],
						min = -100, max = 100, step = 1,
						disabled = function() return not self:IsEnabled() end,
						hidden = function() return not GladiusEx.db.advancedOptions end,
						order = 10,
					},
					offsetY = {
						type = "range",
						name = L["Offset Y"],
						desc = L["Y offset of the frame"],
						disabled = function() return not self:IsEnabled() end,
						hidden = function() return not GladiusEx.db.advancedOptions end,
						min = -100, max = 100, step = 1,
						order = 15,
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
		type = "group",
		name = tagName,
		childGroups = "tree",
		order = order,
		args = {
			delete = {
				type = "execute",
				name = L["Delete tag"],
				func = function()
					-- remove from db
					self.db.tags[tag] = nil
					self.db.tagEvents[tag] = nil

					-- remove from options
					self.options.tagList.args[tag] = nil

					-- remove from text option tags
					for text, v in pairs(self.options.textList.args) do
						if (v.args.tag and v.args.tag.args[tag]) then
							self.options.textList.args[text].args.tag.args[tag] = nil
						end
					end

					-- update
					GladiusEx:UpdateFrames()
				end,
				order = 1,
			},
			tag = {
				type = "group",
				name = L["Tag"],
				desc = L["Tag settings"],
				inline = true,
				order = 2,
				args = {
					name = {
						type = "input",
						name = L["Name"],
						desc = L["Name of the tag"],
						get = function(info)
							local key = info[#info - 2]
							return key
						end,
						set = function(info, value)
							local key = info[#info - 2]

							-- db
							self.db.tags[value] = self.db.tags[key]
							self.db.tagEvents[value] = self.db.tagEvents[key]

							self.db.tags[key] = nil
							self.db.tagEvents[key] = nil

							-- options
							self.options.tagList.args[key] = nil
							self.options.tagList.args[value] = self:GetTagOptionTable(value, order)

							-- update
							GladiusEx:UpdateFrames()
						end,
						disabled = function() return not self:IsEnabled() end,
						width = "double",
						order = 5,
					},
					events = {
						type = "input",
						name = L["Events"],
						desc = L["Events which update the tag"],
						get = function(info)
							local key = info[#info - 2]
							return self.db.tagEvents[key]
						end,
						set = function(info, value)
							local key = info[#info - 2]
							self.db.tagEvents[key] = value

							-- update
							GladiusEx:UpdateFrames()
						end,
						disabled = function() return not self:IsEnabled() end,
						width = "double",
						order = 10,
					},
					func = {
						type = "input",
						name = L["Function"],
						get = function(info)
							local key = info[#info - 2]
							return self.db.tags[key]
						end,
						set = function(info, value)
							local key = info[#info - 2]
							self.db.tags[key] = value

							-- update
							GladiusEx:UpdateFrames()
						end,
						disabled = function() return not self:IsEnabled() end,
						width = "double",
						multiline = true,
						order = 15,
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
			return UnitIsDeadOrGhost(unit) and L["DEAD"] or (UnitName(unit) or unit)
		end,
		["class"] = function(unit)
			return not GladiusEx:IsTesting(unit) and UnitClass(unit) or LOCALIZED_CLASS_NAMES_MALE[GladiusEx.testing[unit].unitClass]
		end,
		["class:short"] = function(unit)
			return not GladiusEx:IsTesting(unit) and L[(select(2, UnitClass(unit)) or GladiusEx.buttons[unit].class or "") .. ":short"] or L[GladiusEx.testing[unit].unitClass .. ":short"]
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
			return L["specID:" .. spec .. ":short"]
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
	for tag, _ in pairs(self.db.tags) do table.insert(names, tag) end
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
