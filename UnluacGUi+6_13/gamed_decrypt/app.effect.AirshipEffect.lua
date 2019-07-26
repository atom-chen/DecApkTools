local SpineEffect = import(".SpineEffect")
local EffectManager = import(".EffectManager")
local AirshipEffect = class("AirshipEffect", SpineEffect)
AirshipEffect.MoveSpeed = 100
AirshipEffect.AttackCD = 0.2
AirshipEffect.ShadowScale = 1
AirshipEffect.FlyHeight = 0
AirshipEffect.Life = 5
function AirshipEffect:ctor(pActorBase, pTargetActor, pEffectInfo)
  AirshipEffect.super.ctor(self, pActorBase, pTargetActor, pEffectInfo)
  self.m_iSpeed = AirshipEffect.MoveSpeed
  self.m_iDir = 1
  self.m_iTimeInterval = AirshipEffect.AttackCD
  self.m_iTime = 0
  self.m_iCount = 3
  self.m_iRangeWidth = 100
  self.m_iRangeHeight = 100
  self.m_bStopShoot = true
  self.m_pCircleEffect = nil
  self:AddMembers(pEffectInfo.members)
end
function AirshipEffect:onEnter()
  AirshipEffect.super.onEnter(self)
  self.m_pContentNode:setPositionY(AirshipEffect.FlyHeight)
  if self.m_iDir == 1 then
    local GameDataManager = require("app.GameDataManager")
    local pMap = GameDataManager:GetInstance():GetGameMap()
  end
  if self.m_pSkill then
    self.m_iRangeWidth, self.m_iRangeHeight = self.m_pSkill:GetDamageRange()
  end
  self:runAction(cca.seq({
    cca.scaleTo(0.5, 3.5 * self.m_iDir, 3.5),
    cca.scaleTo(0.2, 3 * self.m_iDir, 3),
    cca.cb(function()
      self.m_pCircleEffect = EffectManager:GetInstance():CreateEffect(193)
      self.m_pCircleEffect:addTo(self, 1)
      self.m_bStopShoot = false
    end)
  }))
end
function AirshipEffect:Update(dt)
  AirshipEffect.super.Update(self, dt)
  if self:IsRemove() then
    return
  end
  if self.m_bStopShoot then
    return
  end
  self.m_iTimeInterval = self.m_iTimeInterval + dt
  if self.m_iTimeInterval >= AirshipEffect.AttackCD then
    self:Shoot()
    self.m_iTimeInterval = 0
  end
  self.m_iTime = self.m_iTime + dt
  if self.m_iTime >= AirshipEffect.Life then
    self.m_pCircleEffect:SetRemove()
    self.m_bStopShoot = true
    self:runAction(cca.seq({
      cca.delay(1),
      cc.EaseBackIn:create(cca.moveBy(2, self.m_iDir * 3000, 0)),
      cca.cb(function()
        self:SetRemove()
      end)
    }))
  elseif self.m_iTime >= AirshipEffect.Life - 1 and self.m_iAttackCD == AirshipEffect.AttackCD then
    self.m_iCount = 1
  end
end
function AirshipEffect:SetDir(eDir)
  if eDir == td.DirType.Left then
    self.m_iDir = -1
  else
    self.m_iDir = 1
  end
end
function AirshipEffect:Shoot()
  local pMap = require("app.GameDataManager"):GetInstance():GetGameMap()
  local mapHeight = math.ceil(pMap:GetPiexlSize().height * 0.75)
  local selfPos = cc.p(self:getPosition())
  local rangeWidth = self.m_iRangeWidth
  for i = 1, self.m_iCount do
    pMap:performWithDelay(function()
      local randX = math.random(rangeWidth) - rangeWidth / 2
      local startPos = cc.p(selfPos.x + randX, selfPos.y + AirshipEffect.FlyHeight * self:getScaleY())
      local pEffect = EffectManager:GetInstance():CreateEffect(84, nil, nil, startPos)
      pEffect:SetSelfActorParams(self:GetSelfActorParams())
      pEffect:SetSkill(self.m_pSkill)
      local movePos = cc.pAdd(selfPos, cc.p(randX, math.random(self.m_iRangeHeight) - self.m_iRangeHeight / 2))
      for j, v in ipairs(pEffect.m_vAttributes) do
        if v:GetType() == td.AttributeType.Move then
          v.m_pos = movePos
          break
        end
      end
      pEffect:AddToMap(pMap)
    end, i * 0.1)
  end
end
return AirshipEffect
