local GladiusEx = _G.GladiusEx
local L = GladiusEx.L
local LSM

-- global functions
local strfind = string.find
local pairs = pairs
local GetTime = GetTime
local GetSpellInfo, UnitAura, UnitClass = GetSpellInfo, UnitAura, UnitClass
local CLASS_BUTTONS = CLASS_BUTTONS

local ClassIcon = GladiusEx:NewGladiusExModule("ClassIcon", false, {
   classIconAttachTo = "Frame",
   classIconAnchor = "TOPRIGHT",
   classIconRelativePoint = "TOPLEFT",
   classIconSpecIcons = true,
   classIconAdjustSize = false,
   classIconSize = 40,
   classIconOffsetX = -1,
   classIconOffsetY = 0,
   classIconFrameLevel = 2,
   classIconGloss = true,
   classIconGlossColor = { r = 1, g = 1, b = 1, a = 0.4 },
   classIconImportantAuras = true,
   classIconCrop = false,
   classIconCooldown = false,
   classIconCooldownReverse = false,
})

function ClassIcon:OnEnable()   
   self:RegisterEvent("UNIT_AURA")
   self:RegisterMessage("GLADIUS_SPEC_UPDATE")
   
   self.version = 1
   
   LSM = GladiusEx.LSM   
   
   if (not self.frame) then
      self.frame = {}
   end

   GladiusEx.db.auraVersion = self.version
   GladiusEx.db.aurasFrameAuras = GladiusEx.db.aurasFrameAuras or GladiusEx.modules["Auras"]:GetAuraList()
end

function ClassIcon:OnDisable()
   self:UnregisterAllEvents()
   self:UnregisterAllMessages()
   
   for unit in pairs(self.frame) do
      self.frame[unit]:SetAlpha(0)
   end
end

function ClassIcon:GetAttachTo()
   return GladiusEx.db.classIconAttachTo
end

function ClassIcon:GetModuleAttachPoints()
   return {
      ["ClassIcon"] = L["ClassIcon"],
   }
end

function ClassIcon:GetAttachFrame(unit)
   if not self.frame[unit] then
      self:CreateFrame(unit)
   end

   return self.frame[unit]
end

function ClassIcon:UNIT_AURA(event, unit)
   if not GladiusEx:IsHandledUnit(unit) then return end
   
   -- important auras
   self:UpdateAura(unit)
end

function ClassIcon:GLADIUS_SPEC_UPDATE(event, unit)
   self:SetClassIcon(unit)
   self:UpdateAura(unit)
end

function ClassIcon:UpdateAura(unit)  
   if (not self.frame[unit] or not GladiusEx.db.classIconImportantAuras) then return end 

   if (not GladiusEx.db.aurasFrameAuras) then
      GladiusEx:Debug("ClassIcon:UpdateAura missing GladiusEx.db.aurasFrameAuras")
      return
   end
      
   -- default priority
   if (not self.frame[unit].priority) then
      self.frame[unit].priority = 0
   end
   
   local aura
   local index = 1
   
   -- debuffs
   while (true) do
      local name, _, icon, _, _, duration, expires, _, _ = UnitAura(unit, index, "HARMFUL")
      if (not name) then break end  
      
      if (GladiusEx.db.aurasFrameAuras[name] and GladiusEx.db.aurasFrameAuras[name] >= self.frame[unit].priority) then
         aura = name
         self.frame[unit].icon = icon
         self.frame[unit].duration = duration
         self.frame[unit].expires = expires
         self.frame[unit].priority = GladiusEx.db.aurasFrameAuras[name]
      end
      
      index = index + 1     
   end
   
   -- buffs
   index = 1
   
   while (true) do
      local name, _, icon, _, _, duration, expires, _, _ = UnitAura(unit, index, "HELPFUL")
      if (not name) then break end  
      
      if (GladiusEx.db.aurasFrameAuras[name] and GladiusEx.db.aurasFrameAuras[name] >= self.frame[unit].priority) then
         aura = name
         self.frame[unit].icon = icon
         self.frame[unit].duration = duration
         self.frame[unit].expires = expires
         self.frame[unit].priority = GladiusEx.db.aurasFrameAuras[name]
      end
      
      index = index + 1     
   end
   
   if (aura) then      
      -- display aura   
      self.frame[unit].texture:SetTexture(self.frame[unit].icon)
      
      if (GladiusEx.db.classIconCrop) then
         self.frame[unit].texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
      else
         self.frame[unit].texture:SetTexCoord(0, 1, 0, 1)
      end
      
      -- local timeLeft = self.frame[unit].expires > 0 and self.frame[unit].expires - GetTime() or 0
      -- local start = GetTime() - (self.frame[unit].timeleft - timeLeft)      
      --self.frame[unit].timeleft = timeLeft
      
      -- GladiusEx:Call(GladiusEx.modules.Timer, "SetTimer", self.frame[unit], self.frame[unit].timeleft, start)
      self.frame[unit].cooldown:SetCooldown(self.frame[unit].expires - self.frame[unit].duration, self.frame[unit].duration)
   elseif (not aura and self.frame[unit].priority > 0) then
      -- reset
      self.frame[unit].priority = 0 
      self:SetClassIcon(unit)
   elseif (not aura) then
      self:SetClassIcon(unit)
   end
end

function ClassIcon:SetClassIcon(unit)
   if (not self.frame[unit]) then return end
   
   -- GladiusEx:Call(GladiusEx.modules.Timer, "HideTimer", self.frame[unit])

   -- get unit class
   local class, specID
   if not GladiusEx:IsTesting() or UnitExists(unit) then
      class = select(2, UnitClass(unit))
      -- check for arena prep info
      if not class then
         class = GladiusEx.buttons[unit].class
      end
      specID = GladiusEx.buttons[unit].specID
   else
      class = GladiusEx.testing[unit].unitClass
      specID = GladiusEx.testing[unit].specID
   end

   if (class) then
      local left, right, top, bottom 

      if GladiusEx.db.classIconSpecIcons and specID then
         local icon = select(4, GetSpecializationInfoByID(specID))
         self.frame[unit].texture:SetTexture(icon)
         left, right, top, bottom  = 0, 1, 0, 1
      else
         self.frame[unit].texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
         left, right, top, bottom = unpack(CLASS_BUTTONS[class])
      end
      
   
      -- Crop class icon borders
      if (GladiusEx.db.classIconCrop) then
         left = left + (right - left) * 0.07
         right = right - (right - left) * 0.07
         
         top = top + (bottom - top) * 0.07
         bottom = bottom - (bottom - top) * 0.07
      end
      
      self.frame[unit].texture:SetTexCoord(left, right, top, bottom)
   end
end

function ClassIcon:CreateFrame(unit)
   local button = GladiusEx.buttons[unit]
   if (not button) then return end       
   
   -- create frame   
   self.frame[unit] = CreateFrame("CheckButton", "Gladius" .. self:GetName() .. "Frame" .. unit, button, "ActionButtonTemplate")
   self.frame[unit]:EnableMouse(false)
   self.frame[unit]:SetNormalTexture("Interface\\AddOns\\GladiusEx\\images\\gloss")
   self.frame[unit].texture = _G[self.frame[unit]:GetName().."Icon"]
   self.frame[unit].normalTexture = _G[self.frame[unit]:GetName().."NormalTexture"]
   self.frame[unit].cooldown = _G[self.frame[unit]:GetName().."Cooldown"]
end

function ClassIcon:Update(unit)
   -- create frame
   if (not self.frame[unit]) then 
      self:CreateFrame(unit)
   end
      
   -- update frame   
   self.frame[unit]:ClearAllPoints()
    
   local parent = GladiusEx:GetAttachFrame(unit, GladiusEx.db.classIconAttachTo)     
   self.frame[unit]:SetPoint(GladiusEx.db.classIconAnchor, parent, GladiusEx.db.classIconRelativePoint, GladiusEx.db.classIconOffsetX, GladiusEx.db.classIconOffsetY)
   
   -- frame level
   self.frame[unit]:SetFrameLevel(GladiusEx.db.classIconFrameLevel)
   
   if (GladiusEx.db.classIconAdjustSize) then
      local height = false
      --[[ need to rethink that
      for _, module in pairs(GladiusEx.modules) do
         if (module:GetAttachTo() == self.name) then
            height = false
         end
      end]]
   
      if (height) then
         self.frame[unit]:SetWidth(GladiusEx.buttons[unit].height)  
         self.frame[unit]:SetHeight(GladiusEx.buttons[unit].height)   
      else
         self.frame[unit]:SetWidth(GladiusEx.buttons[unit].frameHeight) 
         self.frame[unit]:SetHeight(GladiusEx.buttons[unit].frameHeight)   
      end 
   else
      self.frame[unit]:SetWidth(GladiusEx.db.classIconSize)        
      self.frame[unit]:SetHeight(GladiusEx.db.classIconSize)  
   end  

   self.frame[unit].texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
   
   -- set frame mouse-interactable area
   if (self:GetAttachTo() == "Frame") then
      local left, right, top, bottom = GladiusEx.buttons[unit]:GetHitRectInsets()
      
      if (strfind(GladiusEx.db.classIconRelativePoint, "LEFT")) then
         left = -self.frame[unit]:GetWidth() + GladiusEx.db.classIconOffsetX
      else
         right = -self.frame[unit]:GetWidth() + -GladiusEx.db.classIconOffsetX
      end
      
      --[[ search for an attached frame
      for _, module in pairs(GladiusEx.modules) do
         if (module.attachTo and module:GetAttachTo() == self.name and module.frame and module.frame[unit]) then
            local attachedPoint = module.frame[unit]:GetPoint()
            
            if (strfind(GladiusEx.db.classIconRelativePoint, "LEFT") and (not attachedPoint or (attachedPoint and strfind(attachedPoint, "RIGHT")))) then
               left = left - module.frame[unit]:GetWidth()
            elseif (strfind(GladiusEx.db.classIconRelativePoint, "LEFT") and (not attachedPoint or (attachedPoint and strfind(attachedPoint, "LEFT")))) then
               right = right - module.frame[unit]:GetWidth() 
            end
         end
      end]]
      
      -- top / bottom
      if (self.frame[unit]:GetHeight() > GladiusEx.buttons[unit]:GetHeight()) then
         bottom = -(self.frame[unit]:GetHeight() - GladiusEx.buttons[unit]:GetHeight()) + GladiusEx.db.classIconOffsetY
      end

      GladiusEx.buttons[unit]:SetHitRectInsets(left, right, 0, 0) 
      GladiusEx.buttons[unit].secure:SetHitRectInsets(left, right, 0, 0) 
   end
   
   -- style action button   
   self.frame[unit].normalTexture:SetHeight(self.frame[unit]:GetHeight() + self.frame[unit]:GetHeight() * 0.4)
	self.frame[unit].normalTexture:SetWidth(self.frame[unit]:GetWidth() + self.frame[unit]:GetWidth() * 0.4)
	
	self.frame[unit].normalTexture:ClearAllPoints()
	self.frame[unit].normalTexture:SetPoint("CENTER", 0, 0)
	self.frame[unit]:SetNormalTexture("Interface\\AddOns\\GladiusEx\\images\\gloss")
	
	self.frame[unit].texture:ClearAllPoints()
	self.frame[unit].texture:SetPoint("TOPLEFT", self.frame[unit], "TOPLEFT")
	self.frame[unit].texture:SetPoint("BOTTOMRIGHT", self.frame[unit], "BOTTOMRIGHT")
	
	self.frame[unit].normalTexture:SetVertexColor(GladiusEx.db.classIconGlossColor.r, GladiusEx.db.classIconGlossColor.g, 
      GladiusEx.db.classIconGlossColor.b, GladiusEx.db.classIconGloss and GladiusEx.db.classIconGlossColor.a or 0)
            
   self.frame[unit].texture:SetTexCoord(left, right, top, bottom)
   
   -- cooldown
   if (GladiusEx.db.classIconCooldown) then
      self.frame[unit].cooldown:Show()
   else
      self.frame[unit].cooldown:Hide()
   end
   
   self.frame[unit].cooldown:SetReverse(GladiusEx.db.classIconCooldownReverse)
         
   -- hide
   self.frame[unit]:SetAlpha(0)
end

function ClassIcon:Show(unit)
   local testing = GladiusEx.test
   
   -- show frame
   self.frame[unit]:SetAlpha(1)
   
   -- set class icon
   self:SetClassIcon(unit)
   self:UpdateAura(unit)
end

function ClassIcon:Reset(unit)
   -- reset frame
   self.frame[unit].active = false
   self.frame[unit].aura = nil
   self.frame[unit].expires = 0
   self.frame[unit].priority = 0
   
   -- reset cooldown
   self.frame[unit].cooldown:SetCooldown(GetTime(), 0)
   
   -- reset texture
   self.frame[unit].texture:SetTexture("")
   
   -- hide
	self.frame[unit]:SetAlpha(0)
end

function ClassIcon:Test(unit)   
   GladiusEx.db.aurasFrameAuras = GladiusEx.db.aurasFrameAuras or GladiusEx.modules["Auras"]:GetAuraList()
  
   local aura
  
   if (unit == "arena1" or unit == "player") then
      aura = "Ice Block"
   
      self.frame[unit].icon = select(3, GetSpellInfo(45438))
      self.frame[unit].timeleft = 10
      self.frame[unit].priority = GladiusEx.db.aurasFrameAuras[name]
      self.frame[unit].active = true
      self.frame[unit].aura = aura
   
      self.frame[unit].texture:SetTexture(self.frame[unit].icon)
      
      if (GladiusEx.db.classIconCrop) then
         self.frame[unit].texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
      else
         self.frame[unit].texture:SetTexCoord(0, 1, 0, 1)
      end
      
      -- GladiusEx:Call(GladiusEx.modules.Timer, "SetTimer", self.frame[unit], self.frame[unit].timeleft)
      self.frame[unit].cooldown:SetCooldown(GetTime(), self.frame[unit].timeleft)
   elseif (unit == "arena2" or unit == "party1") then
      aura = "Pain Suppression"
   
      self.frame[unit].icon = select(3, GetSpellInfo(33206))
      self.frame[unit].timeleft = 8
      self.frame[unit].priority = GladiusEx.db.aurasFrameAuras[name]
      self.frame[unit].active = true
      self.frame[unit].aura = aura
   
      self.frame[unit].texture:SetTexture(self.frame[unit].icon)
      
      if (GladiusEx.db.classIconCrop) then
         self.frame[unit].texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
      else
         self.frame[unit].texture:SetTexCoord(0, 1, 0, 1)
      end
      
      -- GladiusEx:Call(GladiusEx.modules.Timer, "SetTimer", self.frame[unit], self.frame[unit].timeleft)
      self.frame[unit].cooldown:SetCooldown(GetTime(), self.frame[unit].timeleft)
   elseif (unit == "arena3" or unit == "party2") then
      aura = "Smoke Bomb"
      
      self.frame[unit].timeleft = 5
      self.frame[unit].icon = select(3, GetSpellInfo(76577))      
      self.frame[unit].priority = GladiusEx.db.aurasFrameAuras[name]
      self.frame[unit].active = true
      self.frame[unit].aura = aura
   
      self.frame[unit].texture:SetTexture(self.frame[unit].icon)
      
      if (GladiusEx.db.classIconCrop) then
         self.frame[unit].texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
      else
         self.frame[unit].texture:SetTexCoord(0, 1, 0, 1)
      end
      
      -- GladiusEx:Call(GladiusEx.modules.Timer, "SetTimer", self.frame[unit], self.frame[unit].timeleft, GetTime())
      self.frame[unit].cooldown:SetCooldown(GetTime(), self.frame[unit].timeleft)
   end
end

function ClassIcon:GetOptions()
   return {
      general = {  
         type="group",
         name=L["General"],
         order=1,
         args = {
            widget = {
               type="group",
               name=L["Widget"],
               desc=L["Widget settings"],  
               inline=true,                
               order=1,
               args = {
                  classIconImportantAuras = {
                     type="toggle",
                     name=L["Important Auras"],
                     desc=L["Show important auras instead of the class icon"],
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     order=5,
                  },
                  classIconCrop = {
                     type="toggle",
                     name=L["Crop Borders"],
                     desc=L["Toggle if the class icon borders should be cropped or not."],
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     hidden=function() return not GladiusEx.db.advancedOptions end,
                     order=6,
                  },
                  classIconSpecIcons = {
                     type="toggle",
                     name=L["Spec Icons"],
                     desc=L["When available, show specialization instead of class icons"],
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     order=7,
                  },
                  sep = {                     
                     type = "description",
                     name="",
                     width="full",
                     order=8,
                  },                  
                  classIconCooldown = {
                     type="toggle",
                     name=L["Class Icon Cooldown Spiral"],
                     desc=L["Display the cooldown spiral for important auras"],
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     hidden=function() return not GladiusEx.db.advancedOptions end,
                     order=10,
                  },
                  classIconCooldownReverse = {
                     type="toggle",
                     name=L["Class Icon Cooldown Reverse"],
                     desc=L["Invert the dark/bright part of the cooldown spiral"],
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
                  classIconGloss = {
                     type="toggle",
                     name=L["Class Icon Gloss"],
                     desc=L["Toggle gloss on the class icon"],
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     hidden=function() return not GladiusEx.db.advancedOptions end,
                     order=20,
                  },
                  classIconGlossColor = {
                     type="color",
                     name=L["Class Icon Gloss Color"],
                     desc=L["Color of the class icon gloss"],
                     get=function(info) return GladiusEx:GetColorOption(info) end,
                     set=function(info, r, g, b, a) return GladiusEx:SetColorOption(info, r, g, b, a) end,
                     hasAlpha=true,
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     hidden=function() return not GladiusEx.db.advancedOptions end,
                     order=25,
                  },
                  sep3 = {                     
                     type = "description",
                     name="",
                     width="full",
                     order=27,
                  },
                  classIconFrameLevel = {
                     type="range",
                     name=L["Class Icon Frame Level"],
                     desc=L["Frame level of the class icon"],
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     hidden=function() return not GladiusEx.db.advancedOptions end,
                     min=1, max=5, step=1,
                     width="double",
                     order=30,
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
                  classIconAdjustSize = {
                     type="toggle",
                     name=L["Class Icon Adjust Size"],
                     desc=L["Adjust class icon size to the frame size"],
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     order=5,
                  },
                  classIconSize = {
                     type="range",
                     name=L["Class Icon Size"],
                     desc=L["Size of the class icon"],
                     min=10, max=100, step=1,
                     disabled=function() return GladiusEx.dbi.profile.classIconAdjustSize or not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     order=10,
                  },       
               },
            },
            position = {
               type="group",
               name=L["Position"],
               desc=L["Position settings"],  
               inline=true,                            
               order=3,
               args = {
                  classIconAttachTo = {
                     type="select",
                     name=L["Class Icon Attach To"],
                     desc=L["Attach class icon to given frame"],
                     values=function() return ClassIcon:GetAttachPoints() end,
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     hidden=function() return not GladiusEx.db.advancedOptions end,                       
                     order=5,
                  },
                  classIconPosition = {
                     type="select",
                     name=L["Class Icon Position"],
                     desc=L["Position of the class icon"],
                     values={ ["LEFT"] = L["Left"], ["RIGHT"] = L["Right"] },
                     get=function() return strfind(GladiusEx.db.classIconAnchor, "RIGHT") and "LEFT" or "RIGHT" end,
                     set=function(info, value)
                        if (value == "LEFT") then
                           GladiusEx.db.classIconAnchor = "TOPRIGHT"
                           GladiusEx.db.classIconRelativePoint = "TOPLEFT"
                        else
                           GladiusEx.db.classIconAnchor = "TOPLEFT"
                           GladiusEx.db.classIconRelativePoint = "TOPRIGHT"
                        end
                        
                        GladiusEx:UpdateFrame(info[1])
                     end,
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     hidden=function() return GladiusEx.db.advancedOptions end,
                     order=6,
                  },
                  sep = {                     
                     type = "description",
                     name="",
                     width="full",
                     order=7,
                  },
                  classIconAnchor = {
                     type="select",
                     name=L["Class Icon Anchor"],
                     desc=L["Anchor of the class icon"],
                     values=function() return GladiusEx:GetPositions() end,
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     hidden=function() return not GladiusEx.db.advancedOptions end,   
                     order=10,
                  },
                  classIconRelativePoint = {
                     type="select",
                     name=L["Class Icon Relative Point"],
                     desc=L["Relative point of the class icon"],
                     values=function() return GladiusEx:GetPositions() end,
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
                  classIconOffsetX = {
                     type="range",
                     name=L["Class Icon Offset X"],
                     desc=L["X offset of the class icon"],
                     min=-100, max=100, step=1,
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     order=20,
                  },
                  classIconOffsetY = {
                     type="range",
                     name=L["Class Icon Offset Y"],
                     desc=L["Y offset of the class icon"],
                     disabled=function() return not GladiusEx.dbi.profile.modules[self:GetName()] end,
                     min=-50, max=50, step=1,
                     order=25,
                  },
               },
            },            
         },
      },      
   }
end