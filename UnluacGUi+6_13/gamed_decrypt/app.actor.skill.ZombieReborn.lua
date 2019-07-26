local SkillBase = import(".SkillBase")
local ZombieReborn = class("ZombieReborn", SkillBase)
function ZombieReborn:ctor(pActor, id, pData)
  ZombieReborn.super.ctor(self, pActor, id, pData)
  self.m_pTarget = nil
end
function ZombieReborn:Update(dt)
  ZombieReborn.super.Update(self, dt)
end
function ZombieReborn:Execute(endCallback)
  if self.m_pTarget then
    ZombieReborn.super.Execute(self, endCallback)
    do
      local SkillInfoManager = require("app.info.SkillInfoManager")
      local EffectManager = require("app.effect.EffectManager")
      local BuffManager = require("app.buff.BuffManager")
      local GameDataManager = require("app.GameDataManager")
      local pMap = GameDataManager:GetInstance():GetGameMap()
      local pos = cc.p(self.m_pTarget:getPosition())
      local pEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.atk_effect, self.m_pActor, self.m_pTarget, pos)
      pEffect:setPosition(self.m_pTarget:getPosition())
      pEffect:AddToMap(pMap, pMap:GetPiexlSize().height - pos.y + 1)
      self.m_pTarget.m_pStateManager:GetCurState().m_fStartTime = 0
      pMap:runAction(cca.seq({
        cca.delay(0.5),
        cca.cb(function()
          self.m_pTarget:Alive(self.m_pTarget:GetMaxHp(), td.GroupType.Enemy)
          for j, id in ipairs(self.m_pData.buff_id[1]) do
            BuffManager:GetInstance():AddBuff(self.m_pTarget, id)
          end
          self.m_pTarget = nil
        end)
      }))
    end
  end
end
function ZombieReborn:IsTriggered()
  local supCondition = ZombieReborn.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local ActorManager = require("app.actor.ActorManager")
  local actorPos = cc.p(self.m_pActor:getPosition())
  local selfVec = ActorManager:GetInstance():GetSelfVec()
  for key, var in pairs(selfVec) do
    if var:IsDead() and (var:GetType() == td.ActorType.Monster or var:GetType() == td.ActorType.Soldier) and not var:IsZombie() and cc.pDistanceSQ(actorPos, cc.p(var:getPosition())) <= self.m_iAtkRangeSQ then
      self.m_pTarget = var
      return true
    end
  end
  local enemyVec = ActorManager:GetInstance():GetEnemyVec()
  for key, var in pairs(enemyVec) do
    if var:IsDead() and (var:GetType() == td.ActorType.Monster or var:GetType() == td.ActorType.Soldier) and not var:IsZombie() and cc.pDistanceSQ(actorPos, cc.p(var:getPosition())) <= self.m_iAtkRangeSQ then
      self.m_pTarget = var
      return true
    end
  end
  self.m_iCheckTime = 0
  return false
end
return ZombieReborn
