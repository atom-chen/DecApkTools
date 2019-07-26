local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local BandageTwine = class("BandageTwine", SkillBase)
function BandageTwine:ctor(pActor, id, pData)
  BandageTwine.super.ctor(self, pActor, id, pData)
  local monsterMap = string.split(pData.custom_data, "#")
  self.m_iMonsterID = tonumber(monsterMap[1]) or 6010
  self.m_iMonsterNum = tonumber(monsterMap[2]) or 1
  self.m_pTarget = nil
end
function BandageTwine:Update(dt)
  BandageTwine.super.Update(self, dt)
end
function BandageTwine:Execute(endCallback)
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local bhurt = self.m_pTarget:IsHurtless()
  if self.m_pTarget and self.m_pTarget:IsCanAttacked() and not self.m_pTarget:IsHurtless() then
    do
      local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
      local t = string.split(pData.skill_name, "#")
      local aniName = t[1]
      self.m_pActor:PlayAnimation(aniName, true)
      local BuffManager = require("app.buff.BuffManager")
      for i, v in ipairs(pData.buff_id[1]) do
        BuffManager:GetInstance():AddBuff(self.m_pTarget, v, nil)
      end
      local ePos = cc.p(self.m_pTarget:getPosition())
      local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
      local pEffect = EffectManager:GetInstance():CreateEffect(pData.atk_effect, self.m_pActor, self.m_pTarget, ePos)
      pEffect:AddToMap(pMap)
      pMap:runAction(cca.seq({
        cca.delay(0.1),
        cca.cb(function()
          self.m_pTarget:setVisible(false)
          self.m_pTarget:ChangeHp(-self.m_pTarget:GetCurHp())
        end),
        cca.delay(1.9),
        cca.cb(function()
          for i = 0, self.m_iMonsterNum - 1 do
            local monster = ActorManager:GetInstance():CreateActor(td.ActorType.Monster, self.m_iMonsterID, true)
            monster:SetEnterEffect(17)
            local angle = -90 + i * (360 / self.m_iMonsterNum)
            local mPos = cc.pAdd(ePos, cc.p(30 * math.cos(math.rad(angle)), 30 * math.sin(math.rad(angle))))
            mPos = td.GetValidPos(pMap, monster:GetCanMoveBlocks(), mPos)
            monster:setPosition(mPos)
            local mTilePos = pMap:GetTilePosFromPixelPos(mPos)
            GameDataManager:GetInstance():SetActorInTile(PulibcFunc:GetInstance():GetIntForPoint(mTilePos), PulibcFunc:GetInstance():GetIntForPoint(mTilePos), monster)
            local iPathID = self.m_pActor:GetPathId()
            monster:SetPathId(iPathID, self.m_pActor:GetInverted())
            monster:SetPath(self.m_pActor:GetPath())
            monster:SetCurPathCount(self.m_pActor:GetCurPathCount())
            monster:SetFinalTargetPos(self.m_pActor:GetFinalTargetPos())
            monster:SetDirType(self.m_pActor:GetDirType())
            pMap:addChild(monster, pMap:GetPiexlSize().height - monster:getPositionY(), monster:getTag())
            endCallback()
            self.m_fStartTime = 0
          end
        end)
      }))
      G_SoundUtil:PlaySound(316, false)
    end
  else
    endCallback()
  end
end
function BandageTwine:IsTriggered()
  local supCondition = BandageTwine.super.IsTriggered(self)
  if not supCondition then
    return false
  end
  local enemy = self.m_pActor:GetEnemy()
  if enemy and (enemy:GetType() == td.ActorType.Monster or enemy:GetType() == td.ActorType.Soldier) and enemy:IsCanAttacked() and not enemy:IsHurtless() then
    self.m_pTarget = enemy
    return true
  end
  return false
end
return BandageTwine
