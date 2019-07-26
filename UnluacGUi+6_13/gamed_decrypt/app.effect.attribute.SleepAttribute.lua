local AttributeBase = import(".AttributeBase")
local SleepAttribute = class("SleepAttribute", AttributeBase)
local ACTIONTAG = 2121
function SleepAttribute:ctor(pEffect, fNextAttributeTime, data)
  SleepAttribute.super.ctor(self, td.AttributeType.Sleep, pEffect, fNextAttributeTime)
  self.m_isSeep = true
end
function SleepAttribute:Active()
  SleepAttribute.super.Active(self)
end
function SleepAttribute:Update(dt)
  SleepAttribute.super.Update(self, dt)
  if not self.m_isSeep then
    self:SetOver()
  end
end
function SleepAttribute:WakeUp()
  self.m_isSeep = false
end
return SleepAttribute
