local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local PoisonRain = class("PoisonRain", SkillBase)
function PoisonRain:ctor(pActor, id, pData)
  PoisonRain.super.ctor(self, pActor, id, pData)
end
function PoisonRain:Execute(endCallback)
  PoisonRain.super.Execute(self, endCallback)
  local startPos = cc.pAdd(cc.p(self.m_pActor:getPosition()), self.m_pActor:FindBonePos("bone_shoot"))
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local actorMng = ActorManager:GetInstance()
  local targets = self.m_pActor:GetGroupType() == td.GroupType.Self and actorMng:GetEnemyVec() or actorMng:GetSelfVec()
  for key, pActor in pairs(targets) do
    if not pActor:IsDead() then
      pMap:runAction(cca.seq({
        cca.delay(0.7),
        cca.cb(function()
          local pEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.track_effect, self.m_pActor, pActor, startPos)
          pEffect:SetSkill(self)
          pEffect:AddToMap(pMap)
        end)
      }))
    end
  end
end
return PoisonRain
