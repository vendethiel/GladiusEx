local Gladius = _G.Gladius
if not Gladius then
  DEFAULT_CHAT_FRAME:AddMessage(format("Module %s requires Gladius", "Health Bar"))
end
local L = Gladius.L
local LSM

-- global functions
local strfind = string.find
local pairs = pairs
local UnitHealth, UnitHealthMax, UnitClass = UnitHealth, UnitHealthMax, UnitClass

local HealthBar = Gladius:NewGladiusModule("HealthBar", true, {
   healthBarAttachTo = "Frame",
   
   healthBarHeight = 25,
   healthBarAdjustWidth = true,
   healthBarWidth = 200,
   
   healthBarInverse = false,
   healthBarColor = { r = 1, g = 1, b = 1, a = 1 },
   healthBarClassColor = true,
   healthBarBackgroundColor = { r = 1, g = 1, b = 1, a = 0.3 },
   healthBarTexture = "Minimalist", 
   
   healthBarOffsetX = 0,
   healthBarOffsetY = 0,  
   
   healthBarAnchor = "TOPLEFT",
   healthBarRelativePoint = "TOPLEFT",
})

function HealthBar:OnEnable()   
   self:RegisterEvent("UNIT_HEALTH")
   self:RegisterEvent("UNIT_MAXHEALTH", "UNIT_HEALTH")
   
   LSM = Gladius.LSM
   
   -- set frame type
   if (Gladius.db.healthBarAttachTo == "Frame" or strfind(Gladius.db.healthBarRelativePoint, "BOTTOM")) then
      self.isBar = true
   else
      self.isBar = false
   end
   
   if (not self.frame) then
      self.frame = {}
   end
end

function HealthBar:OnDisable()
   self:UnregisterAllEvents()
   
   for unit in pairs(self.frame) do
      self.frame[unit]:SetAlpha(0)
   end
end

function HealthBar:GetAttachTo()
   return Gladius.db.healthBarAttachTo
end

function HealthBar:GetModuleAttachPoints()
   return {
      ["HealthBar"] = L["HealthBar"],
   }
end

function HealthBar:GetAttachFrame(unit)
   if not self.frame[unit] then
      self:CreateBar(unit)
   end

   return self.frame[unit]
end

function HealthBar:UNIT_HEALTH(event, unit)
   if not Gladius:IsHandledUnit(unit) then return end
   
   local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
   self:UpdateHealth(unit, health, maxHealth)
end

function HealthBar:UpdateHealth(unit, health, maxHealth)
   if (not self.frame[unit]) then
      if (not Gladius.buttons[unit]) then
         return
      else
         self:Update(unit)
      end
   end
  
   -- update min max values
   self.frame[unit]:SetMinMaxValues(0, maxHealth)

   -- inverse bar
   if (Gladius.db.healthBarInverse) then
      self.frame[unit]:SetValue(maxHealth - health)
   else
      self.frame[unit]:SetValue(health)
   end
end

function HealthBar:CreateBar(unit)
   local button = Gladius.buttons[unit]
   if (not button) then return end       

   -- create bar + text
   self.frame[unit] = CreateFrame("STATUSBAR", "Gladius" .. self.name .. unit, button) 
   self.frame[unit].background = self.frame[unit]:CreateTexture("Gladius" .. self.name .. unit .. "Background", "BACKGROUND") 
   self.frame[unit].highlight = self.frame[unit]:CreateTexture("Gladius" .. self.name .. "Highlight" .. unit, "OVERLAY")
end

function HealthBar:Update(unit)
   -- check parent module
   if (not Gladius:GetModule(Gladius.db.castBarAttachTo)) then
      if (self.frame[unit]) then
         self.frame[unit]:Hide()
      end
      return
   end

   -- create power bar
   if (not self.frame[unit]) then 
      self:CreateBar(unit)
   end
   
   -- set bar type 
   local parent = Gladius:GetAttachFrame(unit, Gladius.db.healthBarAttachTo)
     
   if (Gladius.db.healthBarAttachTo == "Frame" or strfind(Gladius.db.healthBarRelativePoint, "BOTTOM")) then
      self.isBar = true
   else
      self.isBar = false
   end
      
   -- update health bar   
   self.frame[unit]:ClearAllPoints()

   local width = Gladius.db.healthBarAdjustWidth and Gladius.db.barWidth or Gladius.db.healthBarWidth
	
	-- add width of the widget if attached to an widget
	if (Gladius.db.healthBarAttachTo ~= "Frame" and not strfind(Gladius.db.healthBarRelativePoint,"BOTTOM") and Gladius.db.healthBarAdjustWidth) then
      if (not Gladius:GetModule(Gladius.db.healthBarAttachTo).frame[unit]) then
         Gladius:GetModule(Gladius.db.healthBarAttachTo):Update(unit)
      end
      
      width = width + Gladius:GetModule(Gladius.db.healthBarAttachTo).frame[unit]:GetWidth()
	end
		 
   self.frame[unit]:SetHeight(Gladius.db.healthBarHeight)   
   self.frame[unit]:SetWidth(width) 
   	
	self.frame[unit]:SetPoint(Gladius.db.healthBarAnchor, parent, Gladius.db.healthBarRelativePoint, Gladius.db.healthBarOffsetX, Gladius.db.healthBarOffsetY)
	self.frame[unit]:SetMinMaxValues(0, 100)
	self.frame[unit]:SetValue(100)
	self.frame[unit]:SetStatusBarTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, Gladius.db.healthBarTexture))
	
	-- disable tileing
	self.frame[unit]:GetStatusBarTexture():SetHorizTile(false)
   self.frame[unit]:GetStatusBarTexture():SetVertTile(false)
   
   -- update health bar background
   self.frame[unit].background:ClearAllPoints()
	self.frame[unit].background:SetAllPoints(self.frame[unit])
	
	self.frame[unit].background:SetWidth(self.frame[unit]:GetWidth())
	self.frame[unit].background:SetHeight(self.frame[unit]:GetHeight())	
	
	self.frame[unit].background:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, Gladius.db.healthBarTexture))
	
	self.frame[unit].background:SetVertexColor(Gladius.db.healthBarBackgroundColor.r, Gladius.db.healthBarBackgroundColor.g,
      Gladius.db.healthBarBackgroundColor.b, Gladius.db.healthBarBackgroundColor.a)
	
	-- disable tileing
	self.frame[unit].background:SetHorizTile(false)
   self.frame[unit].background:SetVertTile(false)
	
	-- update highlight texture
	self.frame[unit].highlight:SetAllPoints(self.frame[unit])
	self.frame[unit].highlight:SetTexture([=[Interface\QuestFrame\UI-QuestTitleHighlight]=])
   self.frame[unit].highlight:SetBlendMode("ADD")   
   self.frame[unit].highlight:SetVertexColor(1.0, 1.0, 1.0, 1.0)
   self.frame[unit].highlight:SetAlpha(0)
	
	-- hide frame
	self.frame[unit]:SetAlpha(0)
end

function HealthBar:GetBarColor(class)
   return RAID_CLASS_COLORS[class] or { r = 1, g = 1, b = 1, a = 1}
end

function HealthBar:GetBarHeight()
   return Gladius.db.healthBarHeight
end

function HealthBar:Show(unit)
   local testing = Gladius.test
   
   -- show frame
   self.frame[unit]:SetAlpha(1)
   
   -- get unit class
   local class
   if (not testing) then
      class = select(2, UnitClass(unit))
   else
      class = Gladius.testing[unit].unitClass
   end 
   
   -- set color
   if (not Gladius.db.healthBarClassColor) then
      local color = Gladius.db.healthBarColor
      self.frame[unit]:SetStatusBarColor(color.r, color.g, color.b, color.a)
   else			
      local color = self:GetBarColor(class)
      self.frame[unit]:SetStatusBarColor(color.r, color.g, color.b, color.a or 1)
   end

   -- call event
   if (not Gladius.test) then
      self:UNIT_HEALTH("UNIT_HEALTH", unit)
   end
end

function HealthBar:Reset(unit)
   if (not self.frame[unit]) then return end

   -- reset bar
   self.frame[unit]:SetMinMaxValues(0, 1)
   self.frame[unit]:SetValue(1)
   
   -- hide
	self.frame[unit]:SetAlpha(0)
end

function HealthBar:Test(unit)   
   -- set test values
   local maxHealth = Gladius.testing[unit].maxHealth
   local health = Gladius.testing[unit].health
   self:UpdateHealth(unit, health, maxHealth)
end

function HealthBar:GetOptions()
   return {
      general = {  
         type="group",
         name=L["General"],
         order=1,
         args = {
            bar = {
               type="group",
               name=L["Bar"],
               desc=L["Bar settings"],  
               inline=true,                
               order=1,
               args = {      
                  healthBarClassColor = {
                     type="toggle",
                     name=L["Health bar class color"],
                     desc=L["Toggle health bar class color"],
                     disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
                     order=5,
                  },
                  sep = {                     
                     type = "description",
                     name="",
                     width="full",
                     hidden=function() return not Gladius.db.advancedOptions end,
                     order=7,
                  },
                  healthBarColor = {
                     type="color",
                     name=L["Health bar color"],
                     desc=L["Color of the health bar"],
                     hasAlpha=true,
                     get=function(info) return Gladius:GetColorOption(info) end,
                     set=function(info, r, g, b, a) return Gladius:SetColorOption(info, r, g, b, a) end,
                     disabled=function() return Gladius.dbi.profile.healthBarClassColor or not Gladius.dbi.profile.modules[self.name] end,
                     order=10,
                  },
                  healthBarBackgroundColor = {
                     type="color",
                     name=L["Health bar background color"],
                     desc=L["Color of the health bar background"],
                     hasAlpha=true,
                     get=function(info) return Gladius:GetColorOption(info) end,
                     set=function(info, r, g, b, a) return Gladius:SetColorOption(info, r, g, b, a) end,
                     disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
                     hidden=function() return not Gladius.db.advancedOptions end,
                     order=15,
                  },
                  sep2 = {                     
                     type = "description",
                     name="",
                     width="full",
                     order=17,
                  },
                  healthBarInverse = {
                     type="toggle",
                     name=L["Health bar inverse"],
                     desc=L["Inverse the health bar"],
                     disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
                     hidden=function() return not Gladius.db.advancedOptions end,
                     order=20,
                  },
                  healthBarTexture = {
                     type="select",
                     name=L["Health bar texture"],
                     desc=L["Texture of the health bar"],
                     dialogControl = "LSM30_Statusbar",
                     values = AceGUIWidgetLSMlists.statusbar,
                     disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
                     order=25,
                  }, 
               },
            },
            size = {
               type="group",
               name=L["Size"],
               desc=L["Size settings"],  
               inline=true,                
               order=2,
               args = {
                  healthBarAdjustWidth = {
                     type="toggle",
                     name=L["Health bar adjust width"],
                     desc=L["Adjust health bar width to the frame width"],
                     disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
                     order=5,
                  },
                  sep = {                     
                     type = "description",
                     name="",
                     width="full",
                     order=13,
                  },                  
                  healthBarWidth = {
                     type="range",
                     name=L["Health bar width"],
                     desc=L["Width of the health bar"],
                     min=10, max=500, step=1,
                     disabled=function() return Gladius.dbi.profile.healthBarAdjustWidth or not Gladius.dbi.profile.modules[self.name] end,
                     order=15,
                  },
                  healthBarHeight = {
                     type="range",
                     name=L["Health bar height"],
                     desc=L["Height of the health bar"],
                     min=10, max=200, step=1,
                     disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
                     order=20,
                  },
               },
            },
            position = {
               type="group",
               name=L["Position"],
               desc=L["Position settings"],  
               inline=true, 
               hidden=function() return not Gladius.db.advancedOptions end,               
               order=3,
               args = {
                  healthBarAttachTo = {
                     type="select",
                     name=L["Health Bar Attach To"],
                     desc=L["Attach health bar to the given frame"],
                     values=function() return HealthBar:GetAttachPoints() end,
                     set=function(info, value) 
                        local key = info.arg or info[#info]
                        
                        if (strfind(Gladius.db.healthBarRelativePoint, "BOTTOM")) then
                           self.isBar = true
                        else
                           self.isBar = false
                        end
                        
                        Gladius.dbi.profile[key] = value
                        Gladius:UpdateFrame()
                     end,
                     disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
                     width="double",
                     order=5,
                  },
                  sep = {                     
                     type = "description",
                     name="",
                     width="full",
                     order=7,
                  },
                  healthBarAnchor = {
                     type="select",
                     name=L["Health Bar Anchor"],
                     desc=L["Anchor of the health bar"],
                     values=function() return Gladius:GetPositions() end,
                     disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
                     order=10,
                  },
                  healthBarRelativePoint = {
                     type="select",
                     name=L["Health Bar Relative Point"],
                     desc=L["Relative point of the health bar"],
                     values=function() return Gladius:GetPositions() end,
                     disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
                     order=15,               
                  },
                  sep2 = {                     
                     type = "description",
                     name="",
                     width="full",
                     order=17,
                  },
                  healthBarOffsetX = {
                     type="range",
                     name=L["Health bar offset X"],
                     desc=L["X offset of the health bar"],
                     min=-100, max=100, step=1,
                     disabled=function() return  not Gladius.dbi.profile.modules[self.name] end,
                     order=20,
                  },
                  healthBarOffsetY = {
                     type="range",
                     name=L["Health bar offset Y"],
                     desc=L["Y offset of the health bar"],
                     disabled=function() return not Gladius.dbi.profile.modules[self.name] end,
                     min=-100, max=100, step=1,
                     order=25,
                  },  
               },
            },             
         },
      },
   }
end
