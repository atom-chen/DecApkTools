local BuffBase = require("app.buff.BuffBase")
local ActorManager = require("app.actor.ActorManager")
local ObjectiveBuff = class("ObjectiveBuff", BuffBase)
function ObjectiveBuff:ctor(pActor, info, callBackFunc, iActorObjectTag)
  ObjectiveBuff.super.ctor(self, pActor, info, callBackFunc)
  self.m_iObjectTag = iActorObjectTag
end
function ObjectiveBuff:OnEnter()
  ObjectiveBuff.super.OnEnter(self)
end
function ObjectiveBuff:OnExit()
  ObjectiveBuff.super.OnExit(self)
end
function ObjectiveBuff:Update(dt)
  ObjectiveBuff.super.Update(self, dt)
  if self:IsRemove() then
    return
  end
  local actorObj = ActorManager:GetInstance():FindActorByTag(self.m_iObjectTag)
  if actorObj == nil or actorObj:IsDead() then
    self:SetRemove()
  end
end
function ObjectiveBuff:GetObject()
  local actorObj = ActorManager:GetInstance():FindActorByTag(self.m_iObjectTag)
  if not actorObj or actorObj:IsDead() then
    return nil
  else
    return actorObj
  end
end
return ObjectiveBuff
