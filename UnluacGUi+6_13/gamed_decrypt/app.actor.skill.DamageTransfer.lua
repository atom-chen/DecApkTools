local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local ActorManager = require("app.actor.ActorManager")
local DamageTransfer = class("DamageTransfer", SkillBase)
function DamageTransfer:ctor(pActor, id, pData)
  DamageTransfer.super.ctor(self, pActor, id, pData)
  self.m_pTarget = nil
end
function DamageTransfer:Update(dt)
  DamageTransfer.super.Update(self, dt)
end
function DamageTransfer:Execute(endCallback)
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  local actorPos = cc.p(self.m_pActor:getPosition())
  if self.m_pTarget and self.m_pTarget:IsCanAttacked() then
    DamageTransfer.super.Execute(self, endCallback)
    self.m_pTarget:setColor(display.COLOR_BLUE)
    local BuffManager = require("app.buff.BuffManager")
    self.m_pTarget:ChangeHp(self.m_pTarget:GetCurHp() * 0.1, true)
    for i, id in ipairs(pData.get_buff_id) do
      BuffManager:GetInstance():AddBuff(self.m_pActor, id, nil, self.m_pTarget)
    end
  else
    endCallback()
  end
  self.m_pTarget = nil
end
function DamageTransfer:IsTriggered()
  local supCondition = DamageTransfer.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local actorPos = cc.p(self.m_pActor:getPosition())
  local enemyInView = ActorManager:GetInstance():FindActorByFunc(function(v)
    if nil == v then
      return false
    elseif not table.indexof({
      td.ActorType.Soldier,
      td.ActorType.Monster,
      td.ActorType.Hero
    }, v:GetType()) then
      return false
    end
    if cc.pDistanceSQ(cc.p(v:getPosition()), actorPos) <= self.m_iAtkRangeSQ then
      return true
    else
      return false
    end
  end, self.m_pActor:GetGroupType() == td.GroupType.Self)
  if #enemyInView > 0 then
    table.sort(enemyInView, function(a, b)
      return a:GetCurHp() > b:GetCurHp()
    end)
    self.m_pTarget = enemyInView[1]
    return true
  end
  return false
end
return DamageTransfer
