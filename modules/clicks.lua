local GladiusEx = _G.GladiusEx
local L = GladiusEx.L

-- global functions
local tinsert, tsort = table.insert, table.sort

local Clicks = GladiusEx:NewGladiusExModule("Clicks", false, {
	clickAttributes = {
		["Left"] = { button = "1", modifier = "", action = "target", macro = "" },
		["Right"] = { button = "2", modifier = "", action = "focus", macro = "" },
	},
})

function Clicks:OnEnable()
	-- Table that holds all of the secure frames to apply click actions to.
end

function Clicks:OnDisable()
	-- todo: restore attributes ?
end

-- Finds all the secure frames belonging to a specific unit and return them
function Clicks:GetSecureFrames(unit)
	local frames = {}

	-- Find secure frames
	for point, _ in pairs(self:GetAttachPoints()) do
		local frame = GladiusEx:GetAttachFrame(unit, point)
		if (frame and frame.secure) then
			tinsert(frames, frame.secure)
		end
	end

	return frames
end

function Clicks:Update(unit)
	-- Update secure frame table
	local frames = self:GetSecureFrames(unit)

	-- Apply attributes to the frames
	for _, frame in ipairs(frames) do
		self:ApplyAttributes(unit, frame)
	end
end

-- Applies attributes to a specific frame
function Clicks:ApplyAttributes(unit, frame)
	-- todo: remove previous attributes ..
	for _, attr in pairs(GladiusEx.dbi.profile.clickAttributes) do
		frame:SetAttribute(attr.modifier .. "type" .. attr.button, attr.action)
		if (attr.action == "macro" and attr.macro ~= "") then
			frame:SetAttribute(attr.modifier .. "macrotext" .. attr.button, string.gsub(attr.macro, "*unit", unit))
		elseif (attr.action == "spell" and attr.macro ~= "") then
			frame:SetAttribute(attr.modifier .. "spell" .. attr.button, attr.macro)
		end
	end
end

function Clicks:Test(unit)
end

local function getOption(info)
	local key = info[#info - 2]
	return GladiusEx.dbi.profile.clickAttributes[key][info[#info]]
end

local function setOption(info, value)
	local key = info[#info - 2]
	GladiusEx.dbi.profile.clickAttributes[key][info[#info]] = value
	GladiusEx:UpdateFrames()
end

local CLICK_BUTTONS = {["1"] = L["Left"], ["2"] = L["Right"], ["3"] = L["Middle"], ["4"] = L["Button 4"], ["5"] = L["Button 5"]}
local CLICK_MODIFIERS = {[""] = L["None"], ["ctrl-"] = L["ctrl-"], ["shift-"] = L["shift-"], ["alt-"] = L["alt-"]}

function Clicks:GetOptions()
	local addAttrButton = "1"
	local addAttrMod = ""

	local options = {
		attributeList = {
			type="group",
			name=L["Click Actions"],
			order=1,
			args={
				add = {
					type="group",
					name=L["Add click action"],
					inline=true,
					order=1,
					args = {
						button = {
							type="select",
							name=L["Mouse button"],
							desc=L["Select which mouse button this click action uses"],
							values=CLICK_BUTTONS,
							get=function(info) return addAttrButton end,
							set=function(info, value) addAttrButton = value end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=10,
						},
						modifier = {
							type="select",
							name=L["Modifier"],
							desc=L["Select a modifier for this click action"],
							values=CLICK_MODIFIERS,
							get=function(info) return addAttrMod end,
							set=function(info, value) addAttrMod = value end,
							disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
							order=20,
						},
						add = {
							type="execute",
							name=L["Add"],
							func=function()
								local attr = addAttrMod ~= "" and CLICK_MODIFIERS[addAttrMod] .. CLICK_BUTTONS[addAttrButton] or CLICK_BUTTONS[addAttrButton]
								if (not GladiusEx.db.clickAttributes[attr]) then
									-- add to db
									GladiusEx.db.clickAttributes[attr] = {
									button = addAttrButton,
										modifier = addAttrMod,
										action = "target",
										macro = ""
									}
									GladiusEx.options.args[self:GetName()].args.attributeList.args[attr] = self:GetAttributeOptionTable(attr, order)
									-- update
									GladiusEx:UpdateFrames()
								end
							end,
							order=30,
						},
					},
				}
			},
		}
	}

	-- attributes
	local order = 1
	for attr, _ in pairs(GladiusEx.dbi.profile.clickAttributes) do
		options.attributeList.args[attr] = self:GetAttributeOptionTable(attr, order)
		order = order + 1
	end

	return options
end

function Clicks:GetAttributeOptionTable(attribute, order)
	return {
		type="group",
		name=attribute,
		childGroups="tree",
		order=order,
		disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
		args = {
			delete = {
				type="execute",
				name=L["Delete Click Action"],
				func=function()
					-- remove from db
					GladiusEx.db.clickAttributes[attribute] = nil

					-- remove from options
					GladiusEx.options.args[self:GetName()].args.attributeList.args[attribute] = nil

					-- update
					GladiusEx:UpdateFrames()
				end,
				order=1,
			},
			action = {
				type="group",
				name=L["Action"],
				inline=true,
				get=getOption,
				set=setOption,
				order=2,
				args = {
					action = {
						type="select",
						name=L["Action"],
						desc=L["Select what this Click Action does"],
						values={["macro"] = MACRO, ["target"] = TARGET, ["focus"] = FOCUS, ["spell"] = L["Cast Spell"]},
						order=10,
					},
					sep = {
						type = "description",
						name="",
						width="full",
						order=15,
					},
					macro = {
						type="input",
						multiline=true,
						name=L["Spell Name / Macro Text"],
						desc=L["Select what this Click Action does"],
						width="double",
						order=20,
					},
				},
			},
		},
	}
end
