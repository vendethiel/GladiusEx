local GladiusEx = _G.GladiusEx
if not GladiusEx then
  DEFAULT_CHAT_FRAME:AddMessage(format("Module %s requires Gladius", "Auras"))
end
local L = GladiusEx.L
local LSM

-- global functions
local strfind = string.find
local pairs = pairs
local UnitAura, GetSpellInfo = UnitAura, GetSpellInfo
local ceil = math.ceil

local Auras = GladiusEx:NewGladiusExModule("Auras", false, {
   aurasBuffsAttachTo = "ClassIcon",
   aurasBuffsAnchor = "BOTTOMLEFT",
   aurasBuffsRelativePoint = "TOPLEFT",
   aurasBuffsGrow = "UPRIGHT",
   aurasBuffs = true,
   aurasBuffsOnlyDispellable = false,
   aurasDebuffsOnlyMine = false,
   aurasBuffsSpacingX = 0,
   aurasBuffsSpacingY = 0,
   aurasBuffsPerColumn = 6,
   aurasBuffsMax = 18,
   aurasBuffsSize = 16,
   aurasBuffsOffsetX = 0,
   aurasBuffsOffsetY = 0,
   
   aurasDebuffsAttachTo = "Frame",
   aurasDebuffsAnchor = "BOTTOMRIGHT",
   aurasDebuffsRelativePoint = "TOPRIGHT",
   aurasDebuffsGrow = "UPLEFT",
   aurasDebuffsWithBuffs = false,
   aurasDebuffs = true,
   aurasDebuffsOnlyDispellable = false,
   aurasDebuffsOnlyMine = false,
   aurasDebuffsSpacingX = 0,
   aurasDebuffsSpacingY = 0,
   aurasDebuffsPerColumn = 6,
   aurasDebuffsMax = 18,
   aurasDebuffsSize = 16,
   aurasDebuffsOffsetX = 0,
   aurasDebuffsOffsetY = 0,
   
   aurasImportantAuras = true,
})

function Auras:OnEnable()   
   self:RegisterEvent("UNIT_AURA", "UpdateUnitAuras")
   
   LSM = GladiusEx.LSM   
   
   self.buffFrame = self.buffFrame or {}
   self.debuffFrame = self.debuffFrame or {}
   
   -- set auras
   GladiusEx.db.aurasFrameAuras = GladiusEx.db.aurasFrameAuras or self:GetAuraList()
end

function Auras:OnDisable()
   self:UnregisterAllEvents()
   
   for unit in pairs(self.debuffFrame) do
      self.debuffFrame[unit]:Hide()
   end
   
   for unit in pairs(self.buffFrame) do
      self.buffFrame[unit]:Hide()
   end
end

function Auras:GetAttachTo()
   return GladiusEx.db.aurasAttachTo
end

function Auras:GetModuleAttachPoints()
   return {
      ["Buffs"] = L["Buffs"],
      ["Debuffs"] = L["Debuffs"],
   }
end

function Auras:GetAttachFrame(unit, point)
   if point == "Buffs" then
      if not self.buffFrame[unit] then
         self:CreateFrame(unit)
      end
      return self.buffFrame[unit]
   else
      if not self.debuffFrame[unit] then
         self:CreateFrame(unit)
      end
      return self.debuffFrame[unit]
   end
end

local function SetBuff(buffFrame, unit, i)
   local name, rank, icon, count, debuffType, duration, expires, caster, isStealable = UnitBuff(unit, i)

   buffFrame:SetID(i)
   buffFrame.icon:SetTexture(icon)
   if duration > 0 then
      buffFrame.cooldown:SetCooldown(expires - duration, duration)
      buffFrame.cooldown:Show()
   else
      buffFrame.cooldown:Hide()
   end
   buffFrame.count:SetText(count > 1 and count or nil)

   --if isStealable then
   if true then
      local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"]
      buffFrame.border:SetVertexColor(color.r, color.g, color.b)
      buffFrame.border:Show()
   else
      buffFrame.border:Hide()
   end


   buffFrame:Show()
end

local function SetDebuff(debuffFrame, unit, i)
   local name, rank, icon, count, debuffType, duration, expires, caster, isStealable = UnitDebuff(unit, i)

   debuffFrame:SetID(i)
   debuffFrame.icon:SetTexture(icon)

   if duration > 0 then
      debuffFrame.cooldown:SetCooldown(expires - duration, duration)
      debuffFrame.cooldown:Show()
   else
      debuffFrame.cooldown:Hide()
   end

   debuffFrame.count:SetText(count > 1 and count or nil)
   color = debuffType and DebuffTypeColor[debuffType] or DebuffTypeColor["none"]
   debuffFrame.border:SetVertexColor(color.r, color.g, color.b)
end

function Auras:UpdateUnitAuras(event, unit)
   local color
   local sidx = 1

   if self.buffFrame[unit] and GladiusEx.db.aurasBuffs then
      -- buff frame
      for i = 1, 40 do
         local name, rank, icon, count, debuffType, duration, expires, caster, isStealable = UnitBuff(unit, i)      

         if name then
            if not GladiusEx.db.aurasBuffsOnlyDispellable or isStealable then
               SetBuff(self.buffFrame[unit][sidx], unit, i)
               sidx = sidx + 1
            end
         else
            break
         end
      end

      -- hide unused aura frames
      for i = sidx, 40 do
         self.buffFrame[unit][i]:Hide()
      end
   end

   if self.debuffFrame[unit] and GladiusEx.db.aurasDebuffs then
      local debuffFrame

      if GladiusEx.db.aurasBuffs and GladiusEx.db.aurasDebuffsWithBuffs then
         debuffFrame = self.buffFrame[unit]
      else
         debuffFrame = self.debuffFrame[unit]
         sidx = 1
      end

      -- debuff frame
      for i = 1, 40 do
         local name, rank, icon, count, debuffType, duration, expires, caster, isStealable = UnitDebuff(unit, i)

         if name then
            if not GladiusEx.db.aurasDebuffsOnlyDispellable or isStealable then
               SetDebuff(debuffFrame[sidx], unit, i)
               debuffFrame[sidx]:Show()
               sidx = sidx + 1
            end
         else
            break
         end
      end

      for i = sidx, 40 do
         debuffFrame[i]:Hide()
      end
   end
end

local function CreateAuraFrame(name, parent)
   local frame = CreateFrame("Frame", name, parent)
   frame.icon = frame:CreateTexture(nil, "BORDER") -- bg
   -- frame.icon:SetAllPoints()
   frame.icon:SetPoint("CENTER")
   frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

   frame.border = frame:CreateTexture(nil, "BACKGROUND") -- overlay
   frame.border:SetPoint("CENTER")
   frame.border:SetTexture(1, 1, 1, 1)
   -- frame.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
   -- frame.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)

   frame.cooldown =  CreateFrame("Cooldown", nil, frame)
   frame.cooldown:SetAllPoints(frame.icon)
   frame.cooldown:SetReverse(true)
   frame.cooldown:Hide()

   frame.count = frame:CreateFontString(nil, "OVERLAY")
   frame.count:SetFont(LSM:Fetch(LSM.MediaType.FONT, GladiusEx.db.globalFont), 10, "OUTLINE")
   frame.count:SetTextColor(1, 1, 1, 1)
   frame.count:SetShadowColor(0, 0, 0, 1.0)
   frame.count:SetShadowOffset(0.50, -0.50)
   frame.count:SetHeight(1)
   frame.count:SetWidth(1)
   frame.count:SetAllPoints()
   frame.count:SetJustifyV("BOTTOM")
   frame.count:SetJustifyH("RIGHT")

   return frame
end

local function UpdateAuraFrame(frame, size)
   frame:SetSize(size, size)
   frame.icon:SetSize(size - 1.5, size - 1.5)
   frame.border:SetSize(size, size)
end

function Auras:CreateFrame(unit)
   local button = GladiusEx.buttons[unit]
   if (not button) then return end       
   
   -- create buff frame
   if (not self.buffFrame[unit] and GladiusEx.db.aurasBuffs) then
      self.buffFrame[unit] = CreateFrame("Frame", "Gladius" .. self.name .. "BuffFrame" .. unit, button)
      self.buffFrame[unit]:EnableMouse(false)
            
      for i=1, 40 do
         self.buffFrame[unit][i] = CreateAuraFrame("Gladius" .. self.name .. "BuffFrameIcon" .. i .. unit, self.buffFrame[unit])
         self.buffFrame[unit][i]:Hide()
      end
   end
   
   -- create debuff frame
   if (not self.debuffFrame[unit] and GladiusEx.db.aurasDebuffs) then
      self.debuffFrame[unit] = CreateFrame("Frame", "Gladius" .. self.name .. "DebuffFrame" .. unit, button)
      self.debuffFrame[unit]:EnableMouse(false)
      
      for i=1, 40 do
         self.debuffFrame[unit][i] = CreateAuraFrame("Gladius" .. self.name .. "DebuffFrameIcon" .. i .. unit, self.debuffFrame[unit])
         self.debuffFrame[unit][i]:Hide()
      end
   end
end

-- yeah this parameter list sucks
function Auras:UpdateAuraGroup(
   auraFrame, unit,
   aurasBuffsAttachTo,
   aurasBuffsAnchor,
   aurasBuffsRelativePoint,
   aurasBuffsOffsetX,
   aurasBuffsOffsetY,
   aurasBuffsPerColumn,
   aurasBuffsGrow,
   aurasBuffsSize,
   aurasBuffsSpacingX,
   aurasBuffsSpacingY,
   aurasBuffsMax)

   auraFrame:ClearAllPoints()
   
   -- anchor point 
   local parent = GladiusEx:GetAttachFrame(unit, aurasBuffsAttachTo)
   auraFrame:SetPoint(aurasBuffsAnchor, parent, aurasBuffsRelativePoint, aurasBuffsOffsetX, aurasBuffsOffsetY)

   -- size
   auraFrame:SetWidth(aurasBuffsSize*aurasBuffsPerColumn+aurasBuffsSpacingX*aurasBuffsPerColumn)
   auraFrame:SetHeight(aurasBuffsSize*math.ceil(aurasBuffsMax/aurasBuffsPerColumn)+(aurasBuffsSpacingY*(math.ceil(aurasBuffsMax/aurasBuffsPerColumn)+1)))
   
   -- icon points
   local anchor, parent, relativePoint, offsetX, offsetY
   local start, startAnchor = 1, auraFrame
   
   -- grow anchor
   local grow1, grow2, grow3, startRelPoint
   if (aurasBuffsGrow == "DOWNRIGHT") then
      grow1, grow2, grow3, startRelPoint = "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT", "TOPLEFT"
   elseif (aurasBuffsGrow == "DOWNLEFT") then
      grow1, grow2, grow3, startRelPoint = "TOPRIGHT", "BOTTOMRIGHT", "TOPLEFT", "TOPRIGHT"
   elseif (aurasBuffsGrow == "UPRIGHT") then
      grow1, grow2, grow3, startRelPoint = "BOTTOMLEFT", "TOPLEFT", "BOTTOMRIGHT", "BOTTOMLEFT"
   elseif (aurasBuffsGrow == "UPLEFT") then
      grow1, grow2, grow3, startRelPoint = "BOTTOMRIGHT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"
   end
         
   for i=1, 40 do
      auraFrame[i]:ClearAllPoints()
      
      if (aurasBuffsMax >= i) then
         if (start == 1) then
            anchor, parent, relativePoint, offsetX, offsetY = grow1, startAnchor, startRelPoint, 0, strfind(aurasBuffsGrow, "DOWN") and -aurasBuffsSpacingY or aurasBuffsSpacingY                  
         else
            anchor, parent, relativePoint, offsetX, offsetY = grow1, auraFrame[i-1], grow3, strfind(aurasBuffsGrow, "LEFT") and -aurasBuffsSpacingX or aurasBuffsSpacingX, 0                                
            
            if (start == aurasBuffsPerColumn) then
               start = 0
               startAnchor = auraFrame[i - aurasBuffsPerColumn + 1]
               startRelPoint = grow2
            end
         end
         
         start = start + 1
      end
   
      auraFrame[i]:SetPoint(anchor, parent, relativePoint, offsetX, offsetY)

      UpdateAuraFrame(auraFrame[i], aurasBuffsSize)
   end
end

function Auras:Update(unit)
   GladiusEx.db.aurasFrameAuras = GladiusEx.db.aurasFrameAuras or self:GetAuraList()

   -- create frame
   if (not self.buffFrame[unit] or not self.debuffFrame[unit]) then 
      self:CreateFrame(unit)
   end
   
   -- update buff frame 
   if (GladiusEx.db.aurasBuffs) then
      self:UpdateAuraGroup(self.buffFrame[unit], unit,
         GladiusEx.db.aurasBuffsAttachTo,
         GladiusEx.db.aurasBuffsAnchor,
         GladiusEx.db.aurasBuffsRelativePoint,
         GladiusEx.db.aurasBuffsOffsetX,
         GladiusEx.db.aurasBuffsOffsetY,
         GladiusEx.db.aurasBuffsPerColumn,
         GladiusEx.db.aurasBuffsGrow,
         GladiusEx.db.aurasBuffsSize,
         GladiusEx.db.aurasBuffsSpacingX,
         GladiusEx.db.aurasBuffsSpacingY,
         GladiusEx.db.aurasBuffsMax)

      -- hide
      self.buffFrame[unit]:Hide()
   end  
   
   -- update debuff frame 
   if (GladiusEx.db.aurasDebuffs) then  
      self:UpdateAuraGroup(self.debuffFrame[unit], unit,
         GladiusEx.db.aurasDebuffsAttachTo,
         GladiusEx.db.aurasDebuffsAnchor,
         GladiusEx.db.aurasDebuffsRelativePoint,
         GladiusEx.db.aurasDebuffsOffsetX,
         GladiusEx.db.aurasDebuffsOffsetY,
         GladiusEx.db.aurasDebuffsPerColumn,
         GladiusEx.db.aurasDebuffsGrow,
         GladiusEx.db.aurasDebuffsSize,
         GladiusEx.db.aurasDebuffsSpacingX,
         GladiusEx.db.aurasDebuffsSpacingY,
         GladiusEx.db.aurasDebuffsMax)

      -- hide
      self.debuffFrame[unit]:Hide()
   end
   
   -- event
   if (not GladiusEx.db.aurasDebuffs and not GladiusEx.db.aurasBuffs) then
      self:UnregisterAllEvents()
   else
      self:RegisterEvent("UNIT_AURA", "UpdateUnitAuras")
   end
end

function Auras:Show(unit)
   -- show buff frame
   if GladiusEx.db.aurasBuffs and self.buffFrame[unit] then 
      self.buffFrame[unit]:Show()
   end
   
   -- show debuff frame
   if GladiusEx.db.aurasDebuffs and self.debuffFrame[unit] and not GladiusEx.db.aurasDebuffsWithBuffs then
      self.debuffFrame[unit]:Show()
   end

   self:UpdateUnitAuras("Show", unit)
end

function Auras:Reset(unit) 
   if (self.buffFrame[unit]) then 
      -- hide buff frame
      self.buffFrame[unit]:Hide()
      
      for i = 1, 40 do
         self.buffFrame[unit][i]:Hide()
      end
   end
   
   if (self.debuffFrame[unit]) then 
      -- hide debuff frame
      self.debuffFrame[unit]:Hide()
      
      for i=1, 40 do
         self.debuffFrame[unit][i]:Hide()
      end
   end
end

function Auras:Test(unit)
   -- test buff frame
   if (self.buffFrame[unit]) then
      for i=1, GladiusEx.db.aurasBuffsMax do
         self.buffFrame[unit][i].icon:SetTexture(GetSpellTexture(21562))
         self.buffFrame[unit][i]:Show()
      end
   end
   
   -- test debuff frame
   if (self.debuffFrame[unit]) then
      for i=1, GladiusEx.db.aurasDebuffsMax do
         self.debuffFrame[unit][i].icon:SetTexture(GetSpellTexture(589))
         self.debuffFrame[unit][i]:Show()
      end
   end
end

function Auras:GetOptions()
   GladiusEx.db.aurasFrameAuras = GladiusEx.db.aurasFrameAuras or self:GetAuraList()
   
   local options = {
      buffs = {  
         type="group",
         name=L["Buffs"],
         childGroups="tab",
         order=1,
         args = {
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
                        aurasBuffs = {
                           type="toggle",
                           name=L["Auras Buffs"],
                           desc=L["Toggle aura buffs"],
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=5,
                        },
                        aurasBuffsGrow = {
                           type="select",
                           name=L["Auras Column Grow"],
                           desc=L["Grow direction of the auras"],
                           values=function() return {
                              ["UPLEFT"] = L["Up Left"],
                              ["UPRIGHT"] = L["Up Right"],
                              ["DOWNLEFT"] = L["Down Left"],
                              ["DOWNRIGHT"] = L["Down Right"],
                           }
                           end,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=10,
                        }, 
                        sep = {                     
                           type = "description",
                           name="",
                           width="full",
                           order=13,
                        },
                        aurasBuffsOnlyDispellable = {
                           type="toggle",
                           width="full",
                           name=L["Show only dispellable"],
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=14,
                        },   
                        aurasBuffsOnlyMine = {
                           type="toggle",
                           width="full",
                           name=L["Show only mine"],
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=14.1,
                        },
                        aurasBuffsPerColumn = {
                           type="range",
                           name=L["Aura Icons Per Column"],
                           desc=L["Number of aura icons per column"],
                           min=1, max=50, step=1,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=15,
                        },
                        aurasBuffsMax = {
                           type="range",
                           name=L["Aura Icons Max"],
                           desc=L["Number of max buffs"],
                           min=1, max=40, step=1,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=20,
                        },  
                        sep2 = {                     
                           type = "description",
                           name="",
                           width="full",
                           order=23,
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
                        aurasBuffsSize = {
                           type="range",
                           name=L["Aura Icon Size"],
                           desc=L["Size of the aura icons"],
                           min=10, max=100, step=1,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=5,
                        },
                        sep = {                     
                           type = "description",
                           name="",
                           width="full",
                           order=13,
                        },
                        aurasBuffsSpacingY = {
                           type="range",
                           name=L["Auras Spacing Vertical"],
                           desc=L["Vertical spacing of the auras"],
                           min=0, max=30, step=1,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=15,
                        },
                        aurasBuffsSpacingX = {
                           type="range",
                           name=L["Auras Spacing Horizontal"],
                           desc=L["Horizontal spacing of the auras"],
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           min=0, max=30, step=1,
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
                        aurasBuffsAttachTo = {
                           type="select",
                           name=L["Auras Attach To"],
                           desc=L["Attach auras to the given frame"],
                           values=function() return Auras:GetAttachPoints() end,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           width="double",
                           order=5,
                        },
                        sep = {                     
                           type = "description",
                           name="",
                           width="full",
                           order=7,
                        },
                        aurasBuffsAnchor = {
                           type="select",
                           name=L["Auras Anchor"],
                           desc=L["Anchor of the auras"],
                           values=function() return GladiusEx:GetPositions() end,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=10,
                        },
                        aurasBuffsRelativePoint = {
                           type="select",
                           name=L["Auras Relative Point"],
                           desc=L["Relative point of the auras"],
                           values=function() return GladiusEx:GetPositions() end,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=15,               
                        },
                        sep2 = {                     
                           type = "description",
                           name="",
                           width="full",
                           order=17,
                        },
                        aurasBuffsOffsetX = {
                           type="range",
                           name=L["Auras Offset X"],
                           desc=L["X offset of the auras"],
                           min=-100, max=100, step=1,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=20,
                        },
                        aurasBuffsOffsetY = {
                           type="range",
                           name=L["Auras Offset Y"],
                           desc=L["Y  offset of the auras"],
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           min=-50, max=50, step=1,
                           order=25,
                        },
                     },
                  },
               },
            },
            --[[filter = {  
               type="group",
               name=L["Filter"],
               childGroups="tree",
               hidden=function() return not GladiusEx.db.advancedOptions end,
               order=2,
               args = {
                  whitelist = {  
                     type="group",
                     name=L["Whitelist"],
                     order=1,
                     args = {
                     },
                  },
                  blacklist = {  
                     type="group",
                     name=L["Blacklist"],
                     order=2,
                     args = {
                     },
                  },
                  filterFunction = {  
                     type="group",
                     name=L["Filter Function"],
                     order=3,
                     args = {
                     },
                  },
               },
            },]]
         },
      },
      debuffs = {  
         type="group",
         name=L["Debuffs"],
         childGroups="tab",
         order=2,
         args = {
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
                        aurasDebuffs = {
                           type="toggle",
                           name=L["Auras Debuffs"],
                           desc=L["Toggle aura debuffs"],
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=5,
                        },
                        aurasDebuffsWithBuffs = {
                           type="toggle",
                           width="full",
                           name=L["Show Debuffs with Buffs"],
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] or not GladiusEx.dbi.profile.aurasBuffs end,
                           order=6,
                        },
                        aurasDebuffsGrow = {
                           type="select",
                           name=L["Auras Column Grow"],
                           desc=L["Grow direction of the auras"],
                           values=function() return {
                              ["UPLEFT"] = L["Up Left"],
                              ["UPRIGHT"] = L["Up Right"],
                              ["DOWNLEFT"] = L["Down Left"],
                              ["DOWNRIGHT"] = L["Down Right"],
                           }
                           end,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=10,
                        }, 
                        sep = {                     
                           type = "description",
                           name="",
                           width="full",
                           order=13,
                        },
                        aurasDebuffsOnlyDispellable = {
                           type="toggle",
                           width="full",
                           name=L["Show only dispellable"],
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=14,
                        },   
                        aurasDebuffsOnlyMine = {
                           type="toggle",
                           width="full",
                           name=L["Show only mine"],
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=14.1,
                        },
                        aurasDebuffsPerColumn = {
                           type="range",
                           name=L["Aura Icons Per Column"],
                           desc=L["Number of aura icons per column"],
                           min=1, max=50, step=1,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=15,
                        },
                        aurasDebuffsMax = {
                           type="range",
                           name=L["Aura Icons Max"],
                           desc=L["Number of max Debuffs"],
                           min=1, max=40, step=1,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=20,
                        },  
                        sep2 = {                     
                           type = "description",
                           name="",
                           width="full",
                           order=23,
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
                        aurasDebuffsSize = {
                           type="range",
                           name=L["Aura Icon Size"],
                           desc=L["Size of the aura icons"],
                           min=10, max=100, step=1,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=5,
                        },
                        sep = {                     
                           type = "description",
                           name="",
                           width="full",
                           order=13,
                        },
                        aurasDebuffsSpacingY = {
                           type="range",
                           name=L["Auras Spacing Vertical"],
                           desc=L["Vertical spacing of the auras"],
                           min=0, max=30, step=1,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=15,
                        },
                        aurasDebuffsSpacingX = {
                           type="range",
                           name=L["Auras Spacing Horizontal"],
                           desc=L["Horizontal spacing of the auras"],
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           min=0, max=30, step=1,
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
                        aurasDebuffsAttachTo = {
                           type="select",
                           name=L["Auras Attach To"],
                           desc=L["Attach auras to the given frame"],
                           values=function() return Auras:GetAttachPoints() end,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           width="double",
                           order=5,
                        },
                        sep = {                     
                           type = "description",
                           name="",
                           width="full",
                           order=7,
                        },
                        aurasDebuffsAnchor = {
                           type="select",
                           name=L["Auras Anchor"],
                           desc=L["Anchor of the auras"],
                           values=function() return GladiusEx:GetPositions() end,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=10,
                        },
                        aurasDebuffsRelativePoint = {
                           type="select",
                           name=L["Auras Relative Point"],
                           desc=L["Relative point of the auras"],
                           values=function() return GladiusEx:GetPositions() end,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=15,               
                        },
                        sep2 = {                     
                           type = "description",
                           name="",
                           width="full",
                           order=17,
                        },
                        aurasDebuffsOffsetX = {
                           type="range",
                           name=L["Auras Offset X"],
                           desc=L["X offset of the auras"],
                           min=-100, max=100, step=1,
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           order=20,
                        },
                        aurasDebuffsOffsetY = {
                           type="range",
                           name=L["Auras Offset Y"],
                           desc=L["Y  offset of the auras"],
                           disabled=function() return not GladiusEx.dbi.profile.modules[self.name] end,
                           min=-50, max=50, step=1,
                           order=25,
                        },
                     },
                  },
               },
            },
            --[[filter = {  
               type="group",
               name=L["Filter"],
               childGroups="tree",
               hidden=function() return not GladiusEx.db.advancedOptions end,
               order=2,
               args = {
                  whitelist = {  
                     type="group",
                     name=L["Whitelist"],
                     order=1,
                     args = {
                     },
                  },
                  blacklist = {  
                     type="group",
                     name=L["Blacklist"],
                     order=2,
                     args = {
                     },
                  },
                  filterFunction = {  
                     type="group",
                     name=L["Filter Function"],
                     order=3,
                     args = {
                     },
                  },
               },
            },]]
         },
      },      
      auraList = {  
         type="group",
         name=L["Auras"],
         childGroups="tree",
         order=3,
         args = {      
            newAura = {
               type = "group",
               name = L["New Aura"],
               desc = L["New Aura"],
               inline=true,
               order = 1,
               args = {
                  name = {
                     type = "input",
                     name = L["Name"],
                     desc = L["Name of the aura"],
                     get=function() return Auras.newAuraName or "" end,
                     set=function(info, value) Auras.newAuraName = value end,
                     order=1,
                  },
                  priority = {
                     type= "range",
                     name = L["Priority"],
                     desc = L["Select what priority the aura should have - higher equals more priority"],
                     get=function() return Auras.newAuraPriority or "" end,
                     set=function(info, value) Auras.newAuraPriority = value end,
                     min=0,
                     max=5,
                     step=1,
                     order=2,
                  },
                  add = {
                     type = "execute",
                     name = L["Add new Aura"],
                     func = function(info)
                        GladiusEx.dbi.profile.aurasFrameAuras[Auras.newAuraName] = Auras.newAuraPriority 
                        GladiusEx.options.args[self:GetName()].args.auraList.args[Auras.newAuraName] = Auras:SetupAura(Auras.newAuraName, Auras.newAuraPriority)
                     end,
                     order=3,
                  },
               },
            },
         },
      },
   }
   
   -- set auras
   if (not GladiusEx.db.aurasFrameAuras) then
      GladiusEx.db.aurasFrameAuras = self:GetAuraList()
   end
  
   for aura, priority in pairs(GladiusEx.db.aurasFrameAuras) do
      options.auraList.args[aura] = self:SetupAura(aura, priority)
   end
   
   return options
end

local function setAura(info, value)
	if (info[#(info)] == "name") then   
      -- create new aura
      GladiusEx.options.args["ClassIcon"].args.auraList.args[value] = ClassIcon:SetupAura(value, GladiusEx.dbi.profile.aurasFrameAuras[info[#(info) - 1]])
		GladiusEx.dbi.profile.aurasFrameAuras[value] = GladiusEx.dbi.profile.aurasFrameAuras[info[#(info) - 1]]
		
		-- delete old aura
		GladiusEx.dbi.profile.aurasFrameAuras[info[#(info) - 1]] = nil 
		GladiusEx.options.args["ClassIcon"].args.auraList.args = {}
		
		for aura, priority in pairs(GladiusEx.dbi.profile.aurasFrameAuras) do
         GladiusEx.options.args["ClassIcon"].args.auraList.args[aura] = ClassIcon:SetupAura(aura, priority)
      end
   else
      GladiusEx.dbi.profile.aurasFrameAuras[info[#(info) - 1]] = value
	end
end

local function getAura(info)
   if (info[#(info)] == "name") then
      return info[#(info) - 1]
   else      
      return GladiusEx.dbi.profile.aurasFrameAuras[info[#(info) - 1]]
   end
end

function Auras:SetupAura(aura, priority)
   return {
      type = "group",
      name = aura,
      desc = aura,
      get = getAura,
      set = setAura,
      args = {
         name = {
            type = "input",
            name = L["Name"],
            desc = L["Name of the aura"],
            order=1,
         },
         priority = {
            type= "range",
            name = L["Priority"],
            desc = L["Select what priority the aura should have - higher equals more priority"],
            min=0,
            max=5,
            step=1,
            order=2,
         },
         delete = {
            type = "execute",
            name = L["Delete"],
            func = function(info)
               GladiusEx.dbi.profile.aurasFrameAuras[info[#(info) - 1]] = nil 
               
               local newAura = GladiusEx.options.args["Auras"].args.auraList.args.newAura
               GladiusEx.options.args["Auras"].args.auraList.args = {
                  newAura = newAura,
               }
               
               for aura, priority in pairs(GladiusEx.dbi.profile.aurasFrameAuras) do
                  GladiusEx.options.args["Auras"].args.auraList.args[aura] = self:SetupAura(aura, priority)
               end
            end,
            order=3,
         },
      },
   }
end

function Auras:GetAuraList()
	local auraTable = setmetatable({
		-- Spell Name			Priority (higher = more priority)
		-- Crowd control
		[GetSpellInfo(33786)] 	= 3, 	-- Cyclone
		[GetSpellInfo(2637)] 	= 3,	-- Hibernate
		[GetSpellInfo(55041)] 	= 3, 	-- Freezing Trap Effect
		[GetSpellInfo(3355)]    = 3, -- Freezing Trap (from trap launcher)
		[GetSpellInfo(6770)]	   = 3, 	-- Sap
		[GetSpellInfo(2094)]	   = 3, 	-- Blind
		[GetSpellInfo(5782)]	   = 3, 	-- Fear
		[GetSpellInfo(6789)]	   = 3,	-- Death Coil Warlock
		[GetSpellInfo(64044)]   = 3, -- Psychic Horror
		[GetSpellInfo(6358)]    = 3, 	-- Seduction
		[GetSpellInfo(5484)]    = 3, 	-- Howl of Terror
		[GetSpellInfo(5246)]    = 3, 	-- Intimidating Shout
		[GetSpellInfo(8122)]    = 3,	-- Psychic Scream
		[GetSpellInfo(118)]     = 3,	-- Polymorph
		[GetSpellInfo(28272)] 	= 3,	-- Polymorph pig
		[GetSpellInfo(28271)] 	= 3,	-- Polymorph turtle
		[GetSpellInfo(61305)] 	= 3,	-- Polymorph black cat
		[GetSpellInfo(61025)] 	= 3,	-- Polymorph serpent
		[GetSpellInfo(51514)]	= 3,	-- Hex
		[GetSpellInfo(710)]		= 3,	-- Banish
		[GetSpellInfo(1499)]    = 3, -- Freezing Trap Effect
      [GetSpellInfo(60192)]   = 3, -- Freezing Trap (from trap launcher)
		
		-- Roots
		[GetSpellInfo(339)] 	= 3, 	-- Entangling Roots
		[GetSpellInfo(122)]		= 3,	-- Frost Nova
		[GetSpellInfo(16979)] 	= 3, 	-- Feral Charge
		[GetSpellInfo(13809)] 	= 1, 	-- Frost Trap
		[GetSpellInfo(113724)]  = 3, -- Ring of Frost
		[GetSpellInfo(120)]     = 1, -- Cone of Cold
		
		-- Stuns and incapacitates
		[GetSpellInfo(5211)] 	= 3, 	-- Bash
		[GetSpellInfo(1833)] 	= 3,	-- Cheap Shot
		[GetSpellInfo(408)] 	= 3, 	-- Kidney Shot
		[GetSpellInfo(1776)]	= 3, 	-- Gouge
		[GetSpellInfo(44572)]	= 3, 	-- Deep Freeze
		[GetSpellInfo(19386)]	= 3, 	-- Wyvern Sting
		[GetSpellInfo(19503)] 	= 3, 	-- Scatter Shot
		[GetSpellInfo(9005)]	= 3, 	-- Pounce
		[GetSpellInfo(22570)]	= 3, 	-- Maim
		[GetSpellInfo(853)]		= 3, 	-- Hammer of Justice
		[GetSpellInfo(20066)] 	= 3, 	-- Repentance
		[GetSpellInfo(46968)] 	= 3, 	-- Shockwave
		--[GetSpellInfo(49203)] 	= 3,	-- Hungering Cold
		[GetSpellInfo(47481)]	= 3,	-- Gnaw (dk pet stun)
		[GetSpellInfo(90337)]  = 3, -- Bad Manner (monkey blind)
		[GetSpellInfo(118905) = 3, -- Static Charge - Capacitor Totem
		
		-- Silences
		[GetSpellInfo(55021)] 	= 1,	-- Improved Counterspell
		[GetSpellInfo(15487)] 	= 1, 	-- Silence
		[GetSpellInfo(34490)] 	= 1, 	-- Silencing Shot	
		--[GetSpellInfo(18425)]	= 1,	-- Improved Kick GONE
		[GetSpellInfo(47476)]	= 1,	-- Strangulate
		[GetSpellInfo(96231)]   = 1,  -- Rebuke                unsure
		--[GetSpellInfo(85388)]   = 1,  -- Throwdown GONE
		[GetSpellInfo(80964)]   = 1,  -- Skull Bash
		[GetSpellInfo(703)]     = 1,  -- Garrote
				
		-- Disarms
		[GetSpellInfo(676)] 	   = 1, 	-- Disarm
		[GetSpellInfo(51722)] 	= 1,	-- Dismantle
						
		-- Buffs
		[GetSpellInfo(1022)] 	= 1,	-- Blessing of Protection
		[GetSpellInfo(1044)] 	= 1, 	-- Blessing of Freedom
--		[GetSpellInfo(2825)] 	= 1, 	-- Bloodlust   old school shit
--		[GetSpellInfo(32182)] 	= 1, 	-- Heroism     lets roll
		[GetSpellInfo(33206)] 	= 1, 	-- Pain Suppression
		[GetSpellInfo(29166)] 	= 1,	-- Innervate
		--[GetSpellInfo(18708)]  	= 1,	-- Fel Domination GONE
		[GetSpellInfo(54428)]	= 1,	-- Divine Plea
		[GetSpellInfo(31821)]	= 1,	-- Aura mastery
		[GetSpellInfo(118009)]  = 1, -- Desecrated Ground (DK lvl90 anti-CC)
		[GetSpellInfo(12292)] = 1, -- Death Wish
      [GetSpellInfo(49016)] = 1, -- Unholy Frenzy
		
		-- Turtling abilities
		[GetSpellInfo(871)]		= 1,	-- Shield Wall
		[GetSpellInfo(48707)]	= 1,	-- Anti-Magic Shell
		[GetSpellInfo(31224)]	= 1,	-- Cloak of Shadows
		[GetSpellInfo(19263)]	= 1,	-- Deterrence
		[GetSpellInfo(76577)]   = 1, -- Smoke Bomb
		[GetSpellInfo(74001)]   = 1, -- Combat Readiness
		[GetSpellInfo(49039)]   = 1, -- Lichborn
		[GetSpellInfo(47585)]   = 1, -- Dispersion
		
		-- Immunities
		[GetSpellInfo(34692)] 	= 1, 	-- The Beast Within
		[GetSpellInfo(45438)] 	= 2, 	-- Ice Block
		[GetSpellInfo(642)] 	   = 2,	-- Divine Shield
	}, {
      __index = function(t, index) 
         if (index ~= nil) then
            return rawget(t, index)
         else
            return nil
         end            
      end
   })
   
   return auraTable
end
