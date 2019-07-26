local BuffBase = require("app.buff.BuffBase")
local LinkageBuff = class("LinkageBuff", BuffBase)
function LinkageBuff:ctor(pActor, info, callBackFunc)
  LinkageBuff.super.ctor(self, pActor, info, callBackFunc)
  self.m_vTriggerBuffId = info.custom_data
end
function LinkageBuff:IsTriggered()
  local randNum = math.random(100)
  if randNum <= self:GetValue(1) then
    return true
  end
  return false
end
function LinkageBuff:GetTriggerBuffId()
  return self.m_vTriggerBuffId
end
return LinkageBuff
