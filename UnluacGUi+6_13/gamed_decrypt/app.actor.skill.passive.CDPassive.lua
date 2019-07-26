local SkillBase = require("app.actor.skill.SkillBase")
local CDPassive = class("CDPassive", SkillBase)
function CDPassive:ctor(pActor, id, pData)
  CDPassive.super.ctor(self, pActor, id, pData)
  self.m_bActive = false
end
function CDPassive:Active()
  self.m_bActive = true
end
function CDPassive:Inactive()
  self.m_bActive = false
end
function CDPassive:Update(dt)
  if self.m_bActive then
    CDPassive.super.Update(self, dt)
    if self:IsCDOver() then
      self:OnWork()
      self.m_fStartTime = 0
    end
  end
end
function CDPassive:OnWork()
end
return CDPassive
