local GladiusEx = _G.GladiusEx
local L = GladiusEx.L
local LSM

-- global functions
local strfind = string.find
local pairs = pairs
local UnitPower, UnitPowerMax, UnitPowerType = UnitPower, UnitPowerMax, UnitPowerType

local PowerBar = GladiusEx:NewGladiusExModule("PowerBar", true, {
   powerBarAttachTo = "HealthBar",
   
   powerBarHeight = 15,
   powerBarAdjustWidth = true,
   powerBarWidth = 200,
   
   powerBarInverse = false,
   powerBarDefaultColor = true,
   powerBarColor = { r = 1, g = 1, b = 1, a = 1 },
   powerBarBackgroundColor = { r = 1, g = 1, b = 1, a = 0.3 },
   powerBarTexture = "Minimalist",   
   
   powerBarOffsetX = 0,
   powerBarOffsetY = 0, 
   
   powerBarAnchor = "TOPLEFT",
   powerBarRelativePoint = "BOTTOMLEFT",  
})

function PowerBar:OnEnable()
   self:RegisterEvent("UNIT_POWER")
   self:RegisterEvent("UNIT_POWER_FREQUENT", "UNIT_POWER")
   self:RegisterEvent("UNIT_MAXPOWER", "UNIT_POWER")
   
   self:RegisterEvent("UNIT_MANA", "UNIT_POWER")
   self:RegisterEvent("UNIT_RAGE", "UNIT_POWER")
   self:RegisterEvent("UNIT_ENERGY", "UNIT_POWER")
   self:RegisterEvent("UNIT_FOCUS", "UNIT_POWER")
   self:RegisterEvent("UNIT_RUNIC_POWER", "UNIT_POWER")
   self:RegisterEvent("UNIT_MAXMANA", "UNIT_POWER")
   self:RegisterEvent("UNIT_MAXRAGE", "UNIT_POWER")
   self:RegisterEvent("UNIT_MAXENERGY", "UNIT_POWER")
   self:RegisterEvent("UNIT_MAXFOCUS", "UNIT_POWER")
   self:RegisterEvent("UNIT_MAXRUNIC_POWER", "UNIT_POWER")
   self:RegisterEvent("UNIT_DISPLAYPOWER", "UNIT_POWER")
   
   LSM = GladiusEx.LSM
   
   -- set frame type
   if (GladiusEx.db.healthBarAttachTo == "Frame" or strfind(GladiusEx.db.powerBarRelativePoint, "BOTTOM")) then
      self.isBar = true
   else
      self.isBar = false
   end
   
   if (not self.frame) then
      self.frame = {}
   end
end

function PowerBar:OnDisable()
   self:UnregisterAllEvents()
   
   for unit in pairs(self.frame) do
      self.frame[unit]:SetAlpha(0)
   end
end

function PowerBar:GetAttachTo()
   return GladiusEx.db.powerBarAttachTo
end

function PowerBar:GetModuleAttachPoints()
   return {
      ["PowerBar"] = L["PowerBar"],
   }
end

function PowerBar:GetAttachFrame(unit)
   if not self.frame[unit] then
      self:CreateBar(unit)
   end

   return self.frame[unit]
end

function PowerBar:UNIT_POWER(event, unit)
   if not GladiusEx:IsHandledUnit(unit) then return end

   local power, maxPower, powerType = UnitPower(unit), UnitPowerMax(unit), UnitPowerType(unit)
   self:UpdatePower(unit, power, maxPower, powerType)
end

function PowerBar:UpdatePower(unit, power, maxPower, powerType)
   if (not self.frame[unit]) then return end   
   
   if (not self.frame[unit]) then
      if (not GladiusEx.buttons[unit]) then
         GladiusEx:UpdateUnit(unit)
      else
         self:Update(unit)
      end
   end

   -- update min max values
   self.frame[unit]:SetMinMaxValues(0, maxPower)
   
   -- inverse bar
   if (GladiusEx.db.powerBarInverse) then
      self.frame[unit]:SetValue(maxPower - power)
   else
      self.frame[unit]:SetValue(power)
   end
   
   -- update bar color
   if (GladiusEx.db.powerBarDefaultColor) then		
      local color = self:GetBarColor(powerType)
      self.frame[unit]:SetStatusBarColor(color.r, color.g, color.b)
   end
end

function PowerBar:CreateBar(unit)
   local button = GladiusEx.buttons[unit]
   if (not button) then return end      
   
   -- create bar + text
   self.frame[unit] = CreateFrame("STATUSBAR", "GladiusEx" .. self:GetName() .. unit, button) 
   self.frame[unit].background = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. unit .. "Background", "BACKGROUND") 
   self.frame[unit].highlight = self.frame[unit]:CreateTexture("GladiusEx" .. self:GetName() .. "Highlight" .. unit, "OVERLAY")
end

function PowerBar:Update(unit)
   local testing = GladiusEx:IsTesting(unit)

   -- check parent module
   if (not GladiusEx:GetModule(GladiusEx.db.castBarAttachTo)) then
      if (self.frame[unit]) then
         self.frame[unit]:Hide()
      end
      return
   end

   -- get unit powerType
   local powerType
   if (not testing) then
      powerType = UnitPowerType(unit)
   else
      powerType = GladiusEx.testing[unit].powerType
   end

   -- create power bar
   if (not self.frame[unit]) then 
      self:CreateBar(unit)
   end
     
   -- set bar type 
   local parent = GladiusEx:GetAttachFrame(unit, GladiusEx.db.powerBarAttachTo)
     
   if (GladiusEx.db.healthBarAttachTo == "Frame" or strfind(GladiusEx.db.powerBarRelativePoint, "BOTTOM")) then
      self.isBar = true
   else
      self.isBar = false
   end
      
   -- update power bar   
   self.frame[unit]:ClearAllPoints()

   local width = GladiusEx.db.powerBarAdjustWidth and GladiusEx.db.barWidth or GladiusEx.db.powerBarWidth
	
	-- add width of the widget if attached to an widget
	if (GladiusEx.db.healthBarAttachTo ~= "Frame" and not strfind(GladiusEx.db.powerBarRelativePoint, "BOTTOM") and GladiusEx.db.powerBarAdjustWidth) then
      if (not GladiusEx:GetModule(GladiusEx.db.powerBarAttachTo).frame[unit]) then
         GladiusEx:GetModule(GladiusEx.db.powerBarAttachTo):Update(unit)
      end
      
      width = width + GladiusEx:GetModule(GladiusEx.db.powerBarAttachTo).frame[unit]:GetWidth()
	end
		 
	self.frame[unit]:SetHeight(GladiusEx.db.powerBarHeight)    
   self.frame[unit]:SetWidth(width) 
   	
	self.frame[unit]:SetPoint(GladiusEx.db.powerBarAnchor, parent, GladiusEx.db.powerBarRelativePoint, GladiusEx.db.powerBarOffsetX, GladiusEx.db.powerBarOffsetY)
	self.frame[unit]:SetMinMaxValues(0, 100)
	self.frame[unit]:SetValue(100)
	self.frame[unit]:SetStatusBarTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, GladiusEx.db.powerBarTexture))
	
	-- disable tileing
	self.frame[unit]:GetStatusBarTexture():SetHorizTile(false)
   self.frame[unit]:GetStatusBarTexture():SetVertTile(false)
   
   -- update power bar background
   self.frame[unit].background:ClearAllPoints()
	self.frame[unit].background:SetAllPoints(self.frame[unit])
	
	self.frame[unit].background:SetWidth(self.frame[unit]:GetWidth())
	self.frame[unit].background:SetHeight(self.frame[unit]:GetHeight())	
	
	self.frame[unit].background:SetTexture(LSM:Fetch(LSM.MediaType.STATUSBAR, GladiusEx.db.powerBarTexture))
	
	self.frame[unit].background:SetVertexColor(GladiusEx.db.powerBarBackgroundColor.r, GladiusEx.db.powerBarBackgroundColor.g,
      GladiusEx.db.powerBarBackgroundColor.b, GladiusEx.db.powerBarBackgroundColor.a)
	
	-- disable tileing
	self.frame[unit].background:SetHorizTile(false)
   self.frame[unit].background:SetVertTile(false)
   
   -- set color
   if (not GladiusEx.db.powerBarDefaultColor) then
      local color = GladiusEx.db.powerBarColor
      self.frame[unit]:SetStatusBarColor(color.r, color.g, color.b, color.a)
   else        
      local color = self:GetBarColor(powerType)
      self.frame[unit]:SetStatusBarColor(color.r, color.g, color.b)
   end
	
	-- update highlight texture
	self.frame[unit].highlight:SetAllPoints(self.frame[unit])
	self.frame[unit].highlight:SetTexture([=[Interface\QuestFrame\UI-QuestTitleHighlight]=])
   self.frame[unit].highlight:SetBlendMode("ADD")   
   self.frame[unit].highlight:SetVertexColor(1.0, 1.0, 1.0, 1.0)
   self.frame[unit].highlight:SetAlpha(0)
   
	-- hide frame
   self.frame[unit]:SetAlpha(0)
end

function PowerBar:GetBarColor(powerType)
   return PowerBarColor[powerType]
end

function PowerBar:GetBarHeight()
   return GladiusEx.db.powerBarHeight
end

function PowerBar:Show(unit)
   -- show frame
   self.frame[unit]:SetAlpha(1)

   if (not GladiusEx:IsTesting()) then
      self:UNIT_POWER("UNIT_POWER", unit)
   end
end

function PowerBar:Reset(unit)
   -- reset bar
   self.frame[unit]:SetMinMaxValues(0, 1)
   self.frame[unit]:SetValue(1)
   
   -- hide
	self.frame[unit]:SetAlpha(0)
end

function PowerBar:Test(unit)     
   -- set test values
   local maxPower, power
   
   -- power type
   local powerType = GladiusEx.testing[unit].powerType
   
   maxPower = GladiusEx.testing[unit].maxPower  
   power = GladiusEx.testing[unit].power
   
   self:UpdatePower(unit, power, maxPower, powerType)
end

function PowerBar:GetOptions()
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
                  powerBarDefaultColor = {
                     type="toggle",
                     name=L["Power Bar Default Color"],
                     desc=L["Toggle power bar default color"],
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     order=5,
                  },
                  sep = {                     
                     type = "description",
                     name="",
                     width="full",
                     hidden=function() return not GladiusEx.db.advancedOptions end,
                     order=7,
                  },
                  powerBarColor = {
                     type="color",
                     name=L["Power Bar Color"],
                     desc=L["Color of the power bar"],
                     hasAlpha=true,
                     get=function(info) return GladiusEx:GetColorOption(info) end,
                     set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
                     disabled=function() return GladiusEx.dbi.profile.powerBarDefaultColor or not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     order=10,
                  },                  
                  powerBarBackgroundColor = {
                     type="color",
                     name=L["Power Bar Background Color"],
                     desc=L["Color of the power bar background"],
                     hasAlpha=true,
                     get=function(info) return GladiusEx:GetColorOption(info) end,
                     set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     hidden=function() return not GladiusEx.db.advancedOptions end,
                     order=15,
                  }, 
                  sep2 = {                     
                     type = "description",
                     name="",
                     width="full",
                     order=17,
                  }, 
                  powerBarInverse = {
                     type="toggle",
                     name=L["Power Bar Inverse"],
                     desc=L["Inverse the power bar"],
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     hidden=function() return not GladiusEx.db.advancedOptions end,
                     order=20,
                  },         
                  powerBarTexture = {
                     type="select",
                     name=L["Power Bar Texture"],
                     desc=L["Texture of the power bar"],
                     dialogControl = "LSM30_Statusbar",
                     values = AceGUIWidgetLSMlists.statusbar,
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
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
                  powerBarAdjustWidth = {
                     type="toggle",
                     name=L["Power Bar Adjust Width"],
                     desc=L["Adjust power bar width to the frame width"],
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     order=5,
                  },
                  sep = {                     
                     type = "description",
                     name="",
                     width="full",
                     order=13,
                  },
                  powerBarWidth = {
                     type="range",
                     name=L["Power Bar Width"],
                     desc=L["Width of the power bar"],
                     min=10, max=500, step=1,
                     disabled=function() return GladiusEx.dbi.profile.powerBarAdjustWidth or not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     order=15,
                  },
                  powerBarHeight = {
                     type="range",
                     name=L["Power Bar Height"],
                     desc=L["Height of the power bar"],
                     min=10, max=200, step=1,
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     order=20,
                  },
               },
            },
            position = {
               type="group",
               name=L["Position"],
               desc=L["Position settings"],  
               inline=true,    
               hidden=function() return not GladiusEx.db.advancedOptions end,            
               order=3,
               args = {
                  powerBarAttachTo = {
                     type="select",
                     name=L["Power Bar Attach To"],
                     desc=L["Attach power bar to the given frame"],
                     values=function() return PowerBar:GetAttachPoints() end,
                     set=function(info, value) 
                        local key = info.arg or info[#info]
                        
                        if (strfind(GladiusEx.db.powerBarRelativePoint, "BOTTOM")) then
                           self.isBar = true
                        else
                           self.isBar = false
                        end

                        GladiusEx.dbi.profile[key] = value
                        GladiusEx:UpdateFrame()
                     end,
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     width="double",
                     order=5,
                  },
                  sep = {                     
                     type = "description",
                     name="",
                     width="full",
                     order=7,
                  },
                  powerBarAnchor = {
                     type="select",
                     name=L["Power Bar Anchor"],
                     desc=L["Anchor of the power bar"],
                     values=function() return GladiusEx:GetPositions() end,
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     order=10,
                  },
                  powerBarRelativePoint = {
                     type="select",
                     name=L["Power Bar Relative Point"],
                     desc=L["Relative point of the power bar"],
                     values=function() return GladiusEx:GetPositions() end,
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     order=15,               
                  },
                  sep2 = {                     
                     type = "description",
                     name="",
                     width="full",
                     order=17,
                  },
                  powerBarOffsetX = {
                     type="range",
                     name=L["Power Bar Offset X"],
                     desc=L["X offset of the power bar"],
                     min=-100, max=100, step=1,
                     disabled=function() return  not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     order=20,
                  },
                  powerBarOffsetY = {
                     type="range",
                     name=L["Power Bar Offset Y"],
                     desc=L["X offset of the power bar"],
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     min=-100, max=100, step=1,
                     order=25,
                  },
               },
            },
         },
      },
   }
end
