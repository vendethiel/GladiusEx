local GladiusEx = _G.GladiusEx
local L = GladiusEx.L

-- global functions
local strfind = string.find
local GetTime = GetTime
local UnitName, UnitClass = UnitName, UnitClass
local SendChatMessage = SendChatMessage
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local GetSpellInfo = GetSpellInfo
local GetRealNumPartyMembers, GetRealNumRaidMembers, IsRaidLeader, IsRaidOfficer = GetRealNumPartyMembers, GetRealNumRaidMembers, IsRaidLeader, IsRaidOfficer

local Announcements = GladiusEx:NewGladiusExModule("Announcements", false, {
   announcements = {
      drinks = true,
      health = true,
      resurrect = true,
      spec = true,
      healthThreshold = 25,
      dest = "party",
   }
})

function Announcements:OnEnable()
   -- Register events
   self:RegisterEvent("UNIT_HEALTH")
   self:RegisterEvent("UNIT_AURA")
   self:RegisterEvent("UNIT_SPELLCAST_START")
   
   -- register custom events
   self:RegisterMessage("GLADIUS_SPEC_UPDATE")
   
   -- Table holding messages to throttle
   self.throttled = {}
end

function Announcements:OnDisable()
   self:UnregisterAllEvents()
end

-- Reset throttled messages
function Announcements:Reset(unit)
   self.throttled = {}
end

-- New enemy announcement, could be broken.
function Announcements:Show(unit)
end

function Announcements:GLADIUS_SPEC_UPDATE(event, unit)
   if (not strfind(unit, "arena") or strfind(unit, "pet") or not GladiusEx.db.announcements.spec) then return end
   
   if GladiusEx.buttons[unit].spec then
      self:Send(string.format(L["SPEC DETECTED: %s (%s/%s)"], UnitName(unit) or unit, GladiusEx.buttons[unit].class, GladiusEx.buttons[unit].spec), 2, unit)
   end
end

function Announcements:UNIT_HEALTH(event, unit)
   if (not strfind(unit, "arena") or strfind(unit, "pet") or not GladiusEx.db.announcements.health) then return end
   
   local healthPercent = math.floor((UnitHealth(unit) / UnitHealthMax(unit)) * 100)
   if (healthPercent < GladiusEx.db.announcements.healthThreshold) then
      self:Send(string.format(L["LOW HEALTH: %s (%s)"], UnitName(unit), UnitClass(unit)), 10, unit)
   end
end

local DRINK_SPELL = GetSpellInfo(57073)
function Announcements:UNIT_AURA(event, unit)
   if (not strfind(unit, "arena") or strfind(unit, "pet") or not GladiusEx.db.announcements.drinks) then return end
   
   if (UnitAura(unit, DRINK_SPELL)) then
      self:Send(string.format(L["DRINKING: %s (%s)"], UnitName(unit), UnitClass(unit)), 2, unit)
   end 
end

local RES_SPELLS = { 
	[GetSpellInfo(2008)] = true, -- Ancestral Spirit
	[GetSpellInfo(50769)] = true, -- Revive
	[GetSpellInfo(2006)] = true, -- Resurrection
	[GetSpellInfo(7328)] = true -- Redemption
}
function Announcements:UNIT_SPELLCAST_START(event, unit, spell, rank)
   if (not strfind(unit, "arena") or strfind(unit, "pet") or not GladiusEx.db.announcements.resurrect) then return end
   
   if (RES_SPELLS[spell]) then
      self:Send(string.format(L["RESURRECTING: %s (%s)"], UnitName(unit), UnitClass(unit)), 2, unit)
   end
end

-- Sends an announcement
-- Param unit is only used for class coloring of messages
function Announcements:Send(msg, throttle, unit)
   local color = unit and RAID_CLASS_COLORS[UnitClass(unit)] or { r=0, g=1, b=0 }
   local dest = GladiusEx.db.announcements.dest

   -- only send announcements inside arenas
   if select(2, IsInInstance()) ~= "arena" then return end
   
   if (not self.throttled) then
      self.throttled = {}
   end
   
   -- Throttling of messages
   if (throttle and throttle > 0) then
      if (not self.throttled[msg]) then
         self.throttled[msg] = GetTime()+throttle
      elseif (self.throttled[msg] < GetTime()) then
         self.throttled[msg] = nil
      else
         return
      end
   end
   
   if (dest == "self") then
      GladiusEx:Print(msg)
   end
	
	-- change destination to party if not raid leader/officer.
	if(dest == "rw" and not IsRaidLeader() and not IsRaidOfficer() and GetNumGroupMembers() > 0) then
		dest = "party"
	end
	
	-- party chat
	if (dest == "party" and (GetNumGroupMembers() > 0)) then
		SendChatMessage(msg, "PARTY")
	
	-- say
	elseif (dest == "say") then
		SendChatMessage(msg, "SAY")
		
	-- raid warning
	elseif (dest == "rw") then
		SendChatMessage(msg, "RAID_WARNING")
		
	-- floating combat text
	elseif (dest == "fct" and IsAddOnLoaded("Blizzard_CombatText")) then
		CombatText_AddMessage(msg, COMBAT_TEXT_SCROLL_FUNCTION, color.r, color.g, color.b)
		
	-- MikScrollingBattleText	
	elseif (dest == "msbt" and IsAddOnLoaded("MikScrollingBattleText")) then 
		MikSBT.DisplayMessage(msg, MikSBT.DISPLAYTYPE_NOTIFICATION, false, color.r * 255, color.g * 255, color.b * 255)
		
	-- Scrolling Combat Text
	elseif (dest == "sct" and IsAddOnLoaded("sct")) then
		SCT:DisplayText(msg, color, nil, "event", 1)
	
	-- Parrot
	elseif (dest == "parrot" and IsAddOnLoaded("parrot")) then
      Parrot:ShowMessage(msg, "Notification", false, color.r, color.g, color.b)
	end
end

local function getOption(info)
   return GladiusEx.dbi.profile.announcements[info[#info]]
end

local function setOption(info, value)
   GladiusEx.dbi.profile.announcements[info[#info]] = value
end

function Announcements:GetOptions()
   local destValues = {
      ["self"] = L["Self"],
      ["party"] = L["Party"],
      ["say"] = L["Say"],
      ["rw"] = L["Raid Warning"],
      ["sct"] = L["Scrolling Combat Text"],
      ["msbt"] = L["MikScrollingBattleText"],
      ["fct"] = L["Blizzard's Floating Combat Text"],
      ["parrot"] = L["Parrot"]
   }
   
   return {
      general = {
         type="group",
         name=L["General"],
         order=1,
         get=getOption,
         set=setOption,
         disabled=function() return not GladiusEx.db.modules[self:GetName()] end,
         args = {
            options = {
               type="group",
               name=L["Options"],
               inline=true,
               order=1,
               args = {
                  dest = {
                     type="select",
                     name=L["Destination"],
                     desc=L["Choose how your announcements are displayed."],
                     values=destValues,
                     order=5,
                  },
                  healthThreshold = {
                     type="range",
                     name=L["Low health threshold"],
                     desc=L["Choose how low an enemy must be before low health is announced."],
                     disabled=function() return not GladiusEx.db.announcements.health end,
                     min=1,
                     max=100,
                     step=1,
                     order=10,
                  },
               },
            },
            announcements = {
               type="group",
               name=L["Announcement toggles"],
               inline=true,
               order=5,
               args = {
                  drinks = {
                     type="toggle",
                     name=L["Drinking"],
                     desc=L["Announces when enemies sit down to drink."],
                     order=20,
                  },
                  health = {
                     type="toggle",
                     name=L["Low health"],
                     desc=L["Announces when an enemy drops below a certain health threshold."],
                     order=30,
                  },
                  resurrect = {
                     type="toggle",
                     name=L["Resurrection"],
                     desc=L["Announces when an enemy tries to resurrect a teammate."],
                     order=40,
                  },
                  spec = {
                     type="toggle",
                     name=L["Spec Detection"],
                     desc=L["Announces when the spec of an enemy was detected."],
                     order=40,
                  },
               },
            },
         },
      }
   }
end
