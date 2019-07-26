local BuffBase = require("app.buff.BuffBase")
local SkillBuff = class("SkillBuff", BuffBase)
function SkillBuff:ctor(pActor, info, callBackFunc)
  SkillBuff.super.ctor(self, pActor, info, callBackFunc)
end
function SkillBuff:IsTriggered()
  local randNum = math.random(100)
  if randNum <= self:GetValue(1) then
    return true
  end
  return false
end
function SkillBuff:GetTriggerSkillId()
  return self:GetValue(2)
end
return SkillBuff
