local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local LSM

-- global functions
local pairs = pairs
local next = next
local type = type
local strformat = string.format
--[[

local Layout = GladiusEx:NewGladiusExModule("Layout", false, {
})

function Layout:OnEnable()
	LSM = GladiusEx.LSM
end

function Layout:OnDisable()
	self:UnregisterAllEvents()
end

local function SerializeTable(table, defaults)
	for key, value in pairs(table) do
		if (type(value) == "table") then
			if (defaults[key] ~= nil) then
				local t = SerializeTable(value, defaults[key])

				if (next(t) ~= nil) then
					table[key] = t
				else
					table[key] = nil
				end
			end
		else
			if (defaults[key] == value) then
				table[key] = nil
			end
		end
	end

	return table
end

function Layout:GetOptions()
	self.layout = ""

	local t = {
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
						layoutInput = {
							type = "input",
							name = L["Layout code"],
							desc = L["Code of your layout"],
							get = function() return self.layout end,
							set = function(info, value) self.layout = value end,
							disabled = function() return not self:IsEnabled() end,
							multiline = true,
							width = "full",
							order = 5,
						},
						layoutImport = {
							type = "execute",
							name = L["Import layout"],
							desc = L["Import your layout code"],
							disabled = function() return not self:IsEnabled() end,
							func = function()
								if (self.layout == nil or self.layout == "") then return end

								local err, layout = LibStub("AceSerializer-3.0"):Deserialize(self.layout)

								if (not err) then
									GladiusEx:Print(strformat(L["Error while importing layout: %s"], layout))
									return
								end

								local currentLayout = GladiusEx.dbi:GetCurrentProfile()
								GladiusEx.dbi:SetProfile("Import Backup")
								GladiusEx.dbi:CopyProfile(currentLayout)
								GladiusEx.dbi:SetProfile(currentLayout)
								GladiusEx.dbi:ResetProfile()

								GladiusEx.db.modules["*"] = true
								for key, data in pairs(layout) do
									if (type(data) == "table") then
										GladiusEx.dbi.profile[key] = CopyTable(data)
									else
										GladiusEx.dbi.profile[key] = data
									end
								end

								GladiusEx:UpdateFrames()
							end,
							order = 10,
						},
						layoutExport = {
							type = "execute",
							name = L["Export layout"],
							desc = L["Export your layout code"],
							disabled = function() return not self:IsEnabled() end,
							func = function()
								local t = CopyTable(GladiusEx.dbi.profile)
								self.layout = LibStub("AceSerializer-3.0"):Serialize(SerializeTable(t, GladiusEx.defaults.profile))
							end,
							order = 15,
						},
					},
				},
			},
		},
	}

	return t
end
]]
