local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local fn = LibStub("LibFunctional-1.0")
local timer



-- V: heavily inspired by Jaxington's Gladius-With-Interrupts
-- K: Improved

local defaults = {
	interruptPrio = 3.0,
}

local Interrupt = GladiusEx:NewGladiusExModule("Interrupts", defaults, defaults)
	
INTERRUPTS = {
	[6552] = {duration=4},    -- [Warrior] Pummel
	[96231] = {duration=4},   -- [Paladin] Rebuke
	[231665] = {duration=3},  -- [Paladin] Avengers Shield
	[147362] = {duration=3},  -- [Hunter] Countershot
	[187707] = {duration=3},  -- [Hunter] Muzzle
	[1766] = {duration=5},    -- [Rogue] Kick
	[183752] = {duration=3},  -- [DH] Consume Magic
	[47528] = {duration=3},   -- [DK] Mind Freeze
	[91802] = {duration=2},   -- [DK] Shambling Rush
	[57994] = {duration=3},   -- [Shaman] Wind Shear
	[115781] = {duration=6},  -- [Warlock] Optical Blast
	[19647] = {duration=6},   -- [Warlock] Spell Lock
	[212619] = {duration=6},  -- [Warlock] Call Felhunter
	[132409] = {duration=6},  -- [Warlock] Spell Lock
	[171138] = {duration=6},  -- [Warlock] Shadow Lock
	[2139] = {duration=6},    -- [Mage] Counterspell
	[116705] = {duration=4},  -- [Monk] Spear Hand Strike
	[106839] = {duration=4},  -- [Feral] Skull Bash
	[93985] = {duration=4},   -- [Feral] Skull Bash
	[97547] = {duration=5},   -- [Moonkin] Solar Beam
}

CLASS_INTERRUPT_MODIFIERS = {
	["Calming Waters"] = 0.5,
}

function Interrupt:OnEnable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	if not self.frame then
		self.frame = {}
	end
	self.interrupts = {}
end

function Interrupt:OnDisable()
	self:UnregisterAllEvents()
	for unit in pairs(self.frame) do
		self.frame[unit]:SetAlpha(0)
	end
end

function Interrupt:COMBAT_LOG_EVENT_UNFILTERED(event)
	Interrupt:CombatLogEvent(event, CombatLogGetCurrentEventInfo())
end

function Interrupt:CombatLogEvent(_, ...)
	local subEvent = select(2, ...)
	local destGUID = select(8, ...)
	local spellID = select(12, ...)

	local unit = GladiusEx:GetUnitIdByGUID(destGUID)
	if not unit then return end

	if subEvent ~= "SPELL_CAST_SUCCESS" and subEvent ~= "SPELL_INTERRUPT" then
		return
	end
	-- it is necessary to check ~= false, as if the unit isn't casting a channeled spell, it will be nil
	if subEvent == "SPELL_CAST_SUCCESS" and select(8, UnitChannelInfo(unit)) ~= false then
		-- not interruptible
		return
	end
	if INTERRUPTS[spellID] == nil then return end
   	local duration = INTERRUPTS[spellID].duration
   	if not duration then return end
   	local button = GladiusEx.buttons[unit]
   	if not button then return end

   	-- V: can they stack? if not, add some kind of "break"
	-- K: Calming Waters does, but it doesnt increase the stack count. In order to track it we would need to register UNIT_AURA and look for applications/reapplications & store no. stacks for each unit
	local _, _, class = UnitClass(unit)
	if class == 7 then -- Shaman
		for buff, mult in ipairs(CLASS_INTERRUPT_MODIFIERS) do
			if AuraUtil.FindAuraByName(buff, unit, "HELPFUL") then
				duration = duration * mult
			end
		end
	end
   	self:UpdateInterrupt(unit, spellID, duration)
   	
end

function Interrupt:UpdateInterrupt(unit, spellid, duration)
	if spellid then
		self.interrupts[unit] = { spellid, GetTime(), duration}
	else
		self.interrupts[unit] = nil
	end
	
	-- force update now, rather than at next tick
	-- K: sending message is more modular than calling the function directly
	self:SendMessage("GLADIUSEX_INTERRUPT", unit)
	
	-- K: Clears the interrupt after end of duration (in case no new UNIT_AURA ticks)
	--if self.interrupts[unit] then
		--GladiusEx:ScheduleTimer(self.UpdateInterrupt, duration+0.1, self, unit)
	--end
end

function Interrupt:GetInterruptFor(unit)
	local int = self.interrupts and self.interrupts[unit]
	if not int then return end

	local spellid, startedAt, duration = unpack(int)
	local endsAt = startedAt + duration
	if GetTime() > endsAt then
		self.interrupts[unit] = nil
	else
		local name, _, icon = GetSpellInfo(spellid)
		return name, icon, duration, endsAt, self.db[unit].interruptPrio
	end
end

function Interrupt:GetOptions(unit)
	-- TODO: enable/disable INTERRUPT_SPEC_MODIFIER, since they are talents, we're just guessing
	return {
		general = {
			type = "group",
			name = L["General"],
			order = 1,
			args = {
                sep2 = {
                    type = "description",
                    name = "This module shows interrupt durations over the Arena Enemy Class Icons when they are interrupted.",
                    width = "full",
                    order = 17,
                },
				interruptPrio = {
					type = "range",
					name = "InterruptPrio",
					desc = "Sets the priority of interrupts (as compared to regular Class Icon auras)",
					disabled = function() return not self:IsUnitEnabled(unit) end,
					softMin = 0.0, softMax = 10, step = 0.1,
					order = 19,
				},
			},
        },
    }
end
