local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local BarrageShot = class("BarrageShot", SkillBase)
BarrageShot.ShotDis = 300
function BarrageShot:ctor(pActor, id, pData)
  BarrageShot.super.ctor(self, pActor, id, pData)
  self.m_iBarrageNum = tonumber(pData.custom_data)
end
function BarrageShot:Update(dt)
  BarrageShot.super.Update(self, dt)
end
function BarrageShot:Execute(endCallback)
  BarrageShot.super.Execute(self, endCallback)
  G_SoundUtil:PlaySound(205, false)
end
function BarrageShot:Shoot()
  local startPos = cc.pAdd(cc.p(self.m_pActor:getPosition()), self.m_pActor:FindBonePos("bone_shoot"))
  local pMap = GameDataManager:GetInstance():GetGameMap()
  for i = 1, self.m_iBarrageNum do
    do
      local targetActor = self.m_vTargets[i]
      if not targetActor:IsDead() then
        pMap:runAction(cca.seq({
          cca.delay(i * 0.2 - 0.2),
          cca.cb(function()
            local pEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.track_effect, self.m_pActor, targetActor, startPos)
            local dir = self.m_pActor:GetDirType()
            local radian = math.rad(15 + i * 15)
            local movePos = cc.p(dir * BarrageShot.ShotDis * math.cos(radian), BarrageShot.ShotDis * math.sin(radian))
            for j, v in ipairs(pEffect.m_vAttributes) do
              if v:GetType() == td.AttributeType.Move and v:GetTag() == 1 then
                v.m_pos = cc.pAdd(startPos, movePos)
                break
              end
            end
            pEffect:SetSkill(self)
            pEffect:AddToMap(pMap)
          end)
        }))
      end
    end
  end
  for i, var in ipairs(self.m_vTargets) do
    var:release()
  end
  self.m_vTargets = {}
end
function BarrageShot:IsTriggered()
  for i, var in ipairs(self.m_vTargets) do
    var:release()
  end
  self.m_vTargets = {}
  local supCondition = BarrageShot.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local vec = {}
  if self.m_pActor:GetGroupType() == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetEnemyVec()
  elseif self.m_pActor:GetGroupType() == td.GroupType.Enemy then
    vec = ActorManager:GetInstance():GetSelfVec()
  end
  local selfPos = cc.p(self.m_pActor:getPosition())
  local count = 0
  local rangeSQ = self.m_pActor:GetViewRange() * self.m_pActor:GetViewRange()
  local targets = {}
  for key, v in pairs(vec) do
    if v:IsCanAttacked() then
      local actorPos = cc.p(v:getPosition())
      if rangeSQ >= cc.pDistanceSQ(actorPos, selfPos) then
        v:retain()
        table.insert(targets, v)
        count = count + 1
        if count >= self.m_iBarrageNum then
          self.m_vTargets = targets
          for i, var in ipairs(self.m_vTargets) do
            var:retain()
          end
          return true
        end
      end
    end
  end
  self.m_iCheckTime = 0
  return false
end
return BarrageShot
