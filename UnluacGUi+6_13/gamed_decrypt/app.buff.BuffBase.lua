local BuffManager = require("app.buff.BuffManager")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local BuffBase = class("BuffBase")
function BuffBase:ctor(pActor, info, callBackFunc)
  self.m_pActor = pActor
  self.m_iTag = pActor:getTag()
  self.m_iId = info.id
  self.m_eType = info.type
  self.m_vValue = info.value
  self.m_iEffectId = info.effect_id
  self.m_fTime = info.time
  self.m_pAreaEffect = nil
  self.m_CallBackFunc = callBackFunc
  self.m_fStartTime = 0
  self.m_bRemove = false
end
function BuffBase:OnEnter()
  if self.m_iEffectId == 1048 then
    local pEffect = EffectManager:GetInstance():CreateEffect(self.m_iEffectId)
    pEffect:AddToMap(GameDataManager:GetInstance():GetGameMap())
  else
    self.m_pActor:AddBuffEffect(self.m_iEffectId)
  end
end
function BuffBase:DidEnter()
end
function BuffBase:OnExit()
  self.m_pActor:RemoveBuffEffect(self.m_iEffectId)
  if self.m_CallBackFunc then
    self.m_CallBackFunc()
  end
end
function BuffBase:Update(dt)
  if self.m_fTime == -1 or self:IsRemove() then
    return
  end
  self.m_fStartTime = self.m_fStartTime + dt
  if self.m_fStartTime >= self.m_fTime then
    self:SetRemove()
    return
  end
end
function BuffBase:OnWork()
end
function BuffBase:GetTag()
  return self.m_iTag
end
function BuffBase:GetID()
  return self.m_iId
end
function BuffBase:GetType()
  return self.m_eType
end
function BuffBase:GetValue(index)
  local i = index or 1
  return self.m_vValue[i]
end
function BuffBase:SetRemove()
  self.m_bRemove = true
end
function BuffBase:IsRemove()
  return self.m_bRemove
end
function BuffBase:ResetTime(time)
  self.m_fTime = time
end
function BuffBase:IsAutoRemove()
  return self.m_fTime ~= -1
end
return BuffBase
