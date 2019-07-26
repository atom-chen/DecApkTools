local AttributeBase = import(".AttributeBase")
local BuffManager = require("app.buff.BuffManager")
local ActorManager = require("app.actor.ActorManager")
local RangeAttackAttribute = class("RangeAttackAttribute", AttributeBase)
function RangeAttackAttribute:ctor(pEffect, fNextAttributeTime, iDamage, iFixed, iWidth, iHeight)
  RangeAttackAttribute.super.ctor(self, td.AttributeType.RangeAttack, pEffect, fNextAttributeTime)
  self.m_iDamageRatio = iDamage
  self.m_iDamageFixed = iFixed
  self.m_iWidth = iWidth
  self.m_iHeight = iHeight
  self.m_bCanHurtBuild = true
end
function RangeAttackAttribute:Active()
  RangeAttackAttribute.super.Active(self)
  local pSkill = self.m_pEffect:GetSkill()
  local isMustHit = false
  if pSkill then
    if pSkill:GetType() == td.SkillType.RandomMagic or pSkill:GetType() == td.SkillType.FixedMagic then
      self.m_bCanHurtBuild = false
    end
    if self.m_iDamageRatio == nil then
      self.m_iDamageRatio = pSkill:GetSkillRatio()
    end
    if self.m_iDamageFixed == nil then
      self.m_iDamageFixed = pSkill:GetSkillFixed()
    end
    if self.m_iWidth == nil or self.m_iHeight == nil then
      self.m_iWidth, self.m_iHeight = pSkill:GetDamageRange()
    end
    isMustHit = pSkill:IsMustHit()
  end
  local pSelfActor = self.m_pEffect:GetSelfActor()
  local pSelfParams = self.m_pEffect:GetSelfActorParams()
  local vTargetActors = self:FindTargets(pSelfParams.group)
  pSkill:DidHit(nil, self.m_pEffect)
  for i, v in ipairs(vTargetActors) do
    if td.HurtEnemy(pSelfParams, v, self.m_iDamageRatio, self.m_iDamageFixed, isMustHit) and pSkill then
      pSkill:DidHit(v, self.m_pEffect)
    end
  end
  self:SetOver()
end
function RangeAttackAttribute:FindTargets(eSelfGroup)
  local result = {}
  local actorManager = ActorManager:GetInstance()
  local vec = {}
  if eSelfGroup == td.GroupType.Self then
    vec = actorManager:GetEnemyVec()
  elseif eSelfGroup == td.GroupType.Enemy then
    vec = actorManager:GetSelfVec()
  end
  for key, v in pairs(vec) do
    local effectPos = cc.p(self.m_pEffect:getPosition())
    local eActorType = v:GetType()
    if self.m_bCanHurtBuild or eActorType ~= td.ActorType.FangYuTa and eActorType ~= td.ActorType.Home then
      if eActorType == td.ActorType.Home then
        if v:GetRealGroupType() == td.GroupType.Self then
          local leftTop = cc.p(effectPos.x - self.m_iWidth / 2, effectPos.y + self.m_iHeight / 2)
          if v:IsInEllipse(leftTop) then
            table.insert(result, v)
          end
          local leftButtom = cc.p(effectPos.x - self.m_iWidth / 2, effectPos.y - self.m_iHeight / 2)
          if v:IsInEllipse(leftButtom) then
            table.insert(result, v)
          end
          local rightTop = cc.p(effectPos.x + self.m_iWidth / 2, effectPos.y + self.m_iHeight / 2)
          if v:IsInEllipse(rightTop) then
            table.insert(result, v)
          end
          local rightButtom = cc.p(effectPos.x + self.m_iWidth / 2, effectPos.y - self.m_iHeight / 2)
          if v:IsInEllipse(rightButtom) then
            table.insert(result, v)
          end
        else
          local size = v:GetContentSize()
          local rect = {
            x = v:getPositionX(),
            y = v:getPositionY(),
            width = size.width * v:getScaleX(),
            height = size.height * v:getScaleY()
          }
          local effectRect = {
            x = effectPos.x - self.m_iWidth / 2,
            y = effectPos.y - self.m_iHeight / 2,
            width = self.m_iWidth,
            height = self.m_iHeight
          }
          if IsRectCross(rect, effectRect) then
            table.insert(result, v)
          end
        end
      else
        local judgePos
        if v:GetCareerType() == td.CareerType.Fly then
          judgePos = v:GetBeHitPos()
        else
          local dir = v:getPositionX() > effectPos.x and -1 or 1
          judgePos = cc.p(v:getPositionX() + dir * v:GetContentSize().width * v:getScaleX() / 2, v:getPositionY())
        end
        if math.abs(judgePos.x - effectPos.x) <= self.m_iWidth / 2 and math.abs(judgePos.y - effectPos.y) <= self.m_iHeight / 2 then
          table.insert(result, v)
        end
      end
    end
  end
  return result
end
return RangeAttackAttribute
