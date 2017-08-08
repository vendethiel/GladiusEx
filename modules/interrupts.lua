local GladiusEx = _G.GladiusEx
local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")
local fn = LibStub("LibFunctional-1.0")

Interrupt = GladiusEx:NewGladiusExModule("Interrupts", {}, {})

-- V: heavily inspired by Jaxington's Gladius-With-Interrupts

INTERRUPTS = {
	[6552] = 4,   -- [Warrior] Pummel
	[96231] = 4,  -- [Paladin] Rebuke
	[231665] = 3, -- [Paladin] Avengers Shield
	[147362] = 3, -- [Hunter] Countershot
	[187707] = 3, -- [Hunter] Muzzle
	[1766] = 5,   -- [Rogue] Kick
	[183752] = 3, -- [DH] Consume Magic
	[47528] = 3,  -- [DK] Mind Freeze
	[91802] = 2,  -- [DK] Shambling Rush
	[57994] = 3,  -- [Shaman] Wind Shear
	[115781] = 6, -- [Warlock] Optical Blast
	[19647] = 6,  -- [Warlock] Spell Lock
	[212619] = 6, -- [Warlock] Call Felhunter
	[132409] = 6, -- [Warlock] Spell Lock
	[171138] = 6, -- [Warlock] Shadow Lock
	[2139] = 6,   -- [Mage] Counterspell
	[116705] = 4, -- [Monk] Spear Hand Strike
	[106839] = 4, -- [Feral] Skull Bash
	[93985] = 4,  -- [Feral] Skull Bash
	[97547] = 5,  -- [Moonkin] Solar Beam
}

INTERRUPT_SPEC_MODIFIER = {
	[264] = 0.7, -- Shaman, Restoration
	[258] = 0.7, -- Priest, Shadow
	[265] = 0.7, -- Warlock, Affliction
	[266] = 0.7, -- Warlock, Demonology
	[267] = 0.7, -- Warlock, Destruction
}

INTERRUPT_BUFF_MODIFIER = {
	["Burning Determination"] = 0.3,
	["Calming Waters"] = 0.3,
	["Casting Circle"] = 0.3,
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

function Interrupt:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local sub_event = select(2, ...)
	local destGUID = select(8, ...)
	local spellID = select(12, ...)

	local unit = GladiusEx:GetUnitIdByGUID(destGUID)
	if not unit then return end

	if sub_event ~= "SPELL_CAST_SUCCESS" and sub_event ~= "SPELL_INTERRUPT" then
		return
	end
	if sub_event == "SPELL_CAST_SUCCESS" and select(8,UnitChannelInfo(unit)) then
		-- not interruptible
		return
	end

   	local duration = INTERRUPTS[spellID]
   	if not duration then return end
   	local button = GladiusEx.buttons[unit]
   	if not button then return end
   	if button.specID and INTERRUPT_SPEC_MODIFIER[button.specID] then
   		duration = duration * INTERRUPT_SPEC_MODIFIER[button.specID]
   	end
   	-- V: can they stack? if not, add some kind of "break"
   	for i = 1, #INTERRUPT_BUFF_MODIFIER do
   		local mod = INTERRUPT_BUFF_MODIFIER[i]
   		if UnitBuff(unit, mod) then
   			duration = duration * mod
   		end
   	end
   	self:UpdateInterrupt(unit, spellID, duration)
end

function Interrupt:UpdateInterrupt(unit, spellid, duration)
	self.interrupts[unit] = { spellid, GetTime(), duration }
	-- force update now, rather than at next tick
	if not ClassIcon then return end
	ClassIcon:UpdateAura(unit)
end

function Interrupt:GetInterruptFor(unit)
	local int = self.interrupts[unit]
	if not int then return end

	local spellid, startedAt, duration = unpack(int)
	local endsAt = startedAt + duration
	if GetTime() > endsAt then
		self.interrupts[unit] = nil
	else
		local name, _, icon = GetSpellInfo(spellid)
		return name, icon, duration, endsAt
	end
end

function Interrupt:GetOptions(unit)
	-- TODO: enable/disable INTERRUPT_SPEC_MODIFIER, since they are talents
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
                }},
        },
    }
end