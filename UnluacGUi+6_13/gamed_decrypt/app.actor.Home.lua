local StateManager = require("app.actor.state.StateManager")
local BaseInfoManager = require("app.info.BaseInfoManager")
local IdleState = require("app.actor.state.IdleState")
local AttackState = require("app.actor.state.AttackState")
local ActorManager = require("app.actor.ActorManager")
local BuffManager = require("app.buff.BuffManager")
local EffectManager = require("app.effect.EffectManager")
local ActorBase = import(".ActorBase")
local GameDataManager = require("app.GameDataManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local Home = class("Home", ActorBase)
local s_EllipseWidth = 255
local s_EllipseHeight = 185
local DeputyEffects = {2021, 2022}
function Home:ctor(eType, strFileName)
  Home.super.ctor(self, eType, strFileName)
  self.m_iCurLevel = 1
  self.m_iMaxHp = 0
  self.m_iCurHp = 0
  self.m_iAttack = 0
  self.m_iDefense = 0
  self.m_iAttackSpeed = 0
  self.m_pCurSkill = nil
  self.m_fStartTime = 0
  self.m_pEllipse = nil
  self.m_EllipseTime = 0
  self.m_iDeputy = 0
  self.m_pDeputyEffect = nil
  self.m_bIsShip = false
  self:setScale(0.8)
end
function Home:onEnter()
  Home.super.onEnter(self)
  if self:GetRealGroupType() == td.GroupType.Self then
    self:SetSelfHomeData()
    td.dispatchEvent(td.UPDATE_HOME_HP)
    if self.m_bIsShip then
      self:CreateAnimation(td.HOME_SHIP_FILE .. "1")
    else
      self:CreateAnimation(td.HOME_FILE .. math.min(math.ceil(self.m_iCurLevel / 5), 6))
    end
    self:CreateHPBar()
  else
    if self.m_iDeputy > 0 then
      self:CreateAnimation(td.ENEMY_DEPUTY_HOME_FILE .. tostring(1))
      self.m_pDeputyEffect = EffectManager:GetInstance():CreateEffect(DeputyEffects[self.m_iDeputy])
      self.m_pDeputyEffect:addTo(self.m_pSkeleton, -1)
    else
      self:CreateAnimation(td.ENEMY_HOME_FILE .. tostring(1))
    end
    self:CreateHPBar()
  end
  self:PlayAnimation("dabenying_01")
  if self:GetRealGroupType() == td.GroupType.Self then
    self.m_pEllipse = SkeletonUnit:create("Spine/bingying/baohuzhao")
    self.m_pEllipse:setScale(1.2)
    self.m_pEllipse:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
    self:addChild(self.m_pEllipse)
    self.m_pEllipse:setVisible(false)
    self.m_pEllipse:PlayAni("baohuzhao", true)
  end
end
function Home:onExit()
  Home.super.onExit(self)
end
function Home:Update(dt)
  Home.super.Update(self, dt)
  if not self.m_pCurSkill then
    return
  end
  if self.m_fStartTime < self:GetAttackSpeed() then
    self.m_fStartTime = self.m_fStartTime + dt
    return
  end
  self.m_fStartTime = 0
  local enemy = self:GetEnemy()
  if not enemy or not enemy:IsCanAttacked() or not self:IsInAttackRange(enemy) then
    enemy = self:FindEnemy()
    self:SetEnemy(enemy)
  end
  if self:GetEnemy() then
    self.m_pCurSkill:Execute()
  end
end
function Home:ChangeHp(iHp)
  local bIsDead = false
  if self.m_eGroupType == td.GroupType.Enemy and self.m_iDeputy == 0 and 0 < GameDataManager:GetInstance():GetDeputyNum() then
    return
  end
  self.m_iCurHp = cc.clampf(self.m_iCurHp + iHp, 0, self:GetMaxHp())
  if 0 >= self.m_iCurHp then
    self:OnDead()
    bIsDead = true
  end
  if self:GetRealGroupType() == td.GroupType.Self then
    self.m_pEllipse:setVisible(true)
  end
  if self.m_pEllipse then
    self.m_EllipseTime = 0
    self.m_pEllipse:setOpacity(255)
    self.m_pEllipse:stopAllActions()
    self.m_pEllipse:runAction(cca.seq({
      cc.FadeTo:create(0.5, 0),
      cca.callFunc(function()
        self.m_pEllipse:setVisible(false)
      end)
    }))
  end
  if self:GetGroupType() == td.GroupType.Self then
    GameDataManager:GetInstance():UpdateStarCondition(td.StarLevel.FULL_HP_BASE, 1)
    td.dispatchEvent(td.UPDATE_HOME_HP)
  end
  self.m_pHpBar:SetPercentage(self:GetCurHp() / self:GetMaxHp() * 100)
  return bIsDead
end
function Home:OnDead()
  if self.m_iDeputy == 0 then
    local pMap = GameDataManager:GetInstance():GetGameMap()
    local vPos = {}
    table.insert(vPos, cc.p(pMap:GetMapPosFromWorldPos(cc.p(display.width / 2, display.height / 2))))
    local center = self:GetCenterPos()
    table.insert(vPos, center)
    local scene = display.getRunningScene()
    scene:MapMove(vPos, function()
      if self.m_bIsShip then
        self:OverShip()
      else
        self:PlayOverAni()
      end
    end)
  else
    self:PlayOverAni()
  end
  self:SetRemove(true)
  td.dispatchEvent(td.ACTOR_DIED, self:getTag())
end
function Home:CreateHPBar()
  local y = self.m_pSkeleton:GetContentSize().height * 0.8
  local BloodBar = require("app.widgets.BloodBar")
  self.m_pHpBar = BloodBar.new(2, self.m_eGroupType)
  self.m_pHpBar:setScale(1 / self:getScale())
  self.m_pHpBar:setPosition(cc.p(0, y))
  self.m_pSkeleton:addChild(self.m_pHpBar, 10)
end
function Home:SetDeputy(i)
  self.m_iDeputy = i
end
function Home:SetIsShip(b)
  self.m_bIsShip = b
end
function Home:SetLevel(iLevel)
  self.m_iCurLevel = iLevel
end
function Home:GetLevel()
  return self.m_iCurLevel
end
function Home:IsDead()
  return self.m_iCurHp <= 0
end
function Home:SetCurHp(iHp)
  self.m_iCurHp = iHp
end
function Home:GetCurHp()
  return self.m_iCurHp
end
function Home:SetMaxHp(iMaxHp)
  self.m_iMaxHp = iMaxHp
end
function Home:GetMaxHp()
  return self.m_iMaxHp
end
function Home:SetAttackValue(attack)
  self.m_iAttack = attack
end
function Home:GetAttackValue()
  return self.m_iAttack
end
function Home:SetDefense(defense)
  self.m_iDefense = defense
end
function Home:GetDefense()
  return self.m_iDefense
end
function Home:SetAttackSpeed(attackSpeed)
  self.m_iAttackSpeed = attackSpeed
end
function Home:GetAttackSpeed()
  return self.m_iAttackSpeed
end
function Home:GetCritRate()
  return 0
end
function Home:GetDodgeRate()
  return 0
end
function Home:GetBlockRate()
  return 0
end
function Home:GetHitRate()
  return 100
end
function Home:AddSkill(id)
end
function Home:IsInViewRange(pEnemy)
  return self:IsInAttackRange(pEnemy)
end
function Home:IsInAttackRange(pEnemy)
  if not self.m_pCurSkill then
    return false
  end
  if not pEnemy or not pEnemy.m_pSkeleton then
    return false
  end
  local iRangeSQ = self.m_pCurSkill:GetAttackRange() * self.m_pCurSkill:GetAttackRange()
  local enemyPos = cc.p(pEnemy:getPosition())
  local center = self:GetCenterPos()
  local distanceSQ = cc.pDistanceSQ(center, cc.p(pEnemy:getPosition()))
  if iRangeSQ >= distanceSQ then
    return true, distanceSQ
  end
  return false, distanceSQ
end
function Home:GetEllipseSize()
  return cc.size(s_EllipseWidth * 2, s_EllipseHeight * 2)
end
function Home:GetEllipseRect()
  local curPos = self:GetCenterPos()
  return cc.rect(curPos.x - s_EllipseWidth, curPos.y - s_EllipseHeight, s_EllipseWidth * 2, s_EllipseHeight * 2)
end
function Home:IsInEllipse(pos)
  if self:GetGroupType() == td.GroupType.Self then
    local curPos = self:GetCenterPos()
    return IsInEllipse(curPos.x, curPos.y, s_EllipseWidth, s_EllipseHeight, pos)
  end
  return false
end
function Home:PlayOverAni()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local effectPos = cc.pAdd(cc.p(self:getPosition()), cc.p(self:getContentSize().width / 2, -self:getContentSize().height * 0.25))
  td.CreateUIEffect(pMap, "Spine/mapeffect/EFT_zhujibaozha_01", {
    pos = effectPos,
    scale = 1.5,
    zorder = 5000
  })
  G_SoundUtil:PlaySound(709)
  self:performWithDelay(function()
    self:RemoveAnimation()
    if self:GetRealGroupType() == td.GroupType.Self then
      self:CreateAnimation(td.HOME_FILE .. "7")
    elseif self.m_iDeputy == 0 then
      self:CreateAnimation(td.ENEMY_HOME_FILE .. "2")
    else
      self:CreateAnimation(td.ENEMY_DEPUTY_HOME_FILE .. "2")
    end
    self:PlayAnimation("dabenying_01")
    self:Over()
  end, 1)
end
function Home:OverShip()
  self:performWithDelay(function()
    self:RemoveAnimation()
    self:CreateAnimation(td.HOME_SHIP_FILE .. "2")
    self:PlayAnimation("dabenying_01", false, handler(self, self.Over), sp.EventType.ANIMATION_COMPLETE)
  end, 1)
  G_SoundUtil:PlaySound(709)
end
function Home:Over()
  local isEnemy
  if self:GetRealGroupType() == td.GroupType.Self then
    isEnemy = false
  else
    isEnemy = true
  end
  display.getRunningScene():SetPause(false)
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  if self.m_iDeputy > 0 then
    GameDataManager:GetInstance():UpdateDeputyNum(-1)
    require("app.trigger.TriggerManager"):GetInstance():SendEvent({
      eType = td.ConditionType.DeputyDead,
      deputyId = self.m_iDeputy
    })
    if self.m_pDeputyEffect then
      self.m_pDeputyEffect:SetRemove()
      self.m_pDeputyEffect = nil
    end
  else
    require("app.trigger.TriggerManager"):GetInstance():SendEvent({
      eType = td.ConditionType.HomeState,
      isEnemy = isEnemy
    })
  end
  if self.m_pEllipse then
    self:removeChild(self.m_pEllipse)
    self.m_pEllipse = nil
  end
end
function Home:SetSelfHomeData()
  local info = BaseInfoManager:GetInstance():GetBaseInfo(self.m_iCurLevel)
  self:SetCurHp(tonumber(info.hp))
  self:SetMaxHp(tonumber(info.hp))
  self:SetAttackValue(tonumber(info.attack))
  self:SetDefense(tonumber(info.def))
  self:SetAttackSpeed(tonumber(info.attack_speed))
end
function Home:GetEllipse()
  return self.m_pEllipse
end
function Home:GetBeHitPos()
  local bonePos = cc.p(0, 0)
  if self:GetGroupType() == td.GroupType.Self then
    local ellipse = self:GetEllipse()
    if ellipse then
      bonePos = ellipse:FindBonePos("beijing_0" .. math.random(8))
    end
  else
    bonePos = self:FindBonePos("beiji_0" .. math.random(7))
  end
  local skeletonPos = cc.pAdd(cc.p(self:getPosition()), cc.p(self:getContentSize().width * 0.5 * self:getScaleX(), 0))
  return cc.pAdd(skeletonPos, bonePos)
end
function Home:IsCanBuffed()
  return false
end
function Home:IsCanBeMoved()
  return false
end
function Home:GetCenterPos()
  return cc.p(self:getPositionX() + self:getContentSize().width / 2, self:getPositionY() + self:getContentSize().height / 2)
end
return Home
