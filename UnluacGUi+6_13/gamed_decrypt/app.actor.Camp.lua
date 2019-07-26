local ActorBase = import(".ActorBase")
local GameDataManager = require("app.GameDataManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local GuideManager = require("app.GuideManager")
local UnitDataManager = require("app.UnitDataManager")
local Camp = class("Camp", ActorBase)
Camp.Population = 5
function Camp:ctor(eType, strFileName)
  Camp.super.ctor(self, eType, strFileName)
  self.m_iID = -1
  self.m_iSoldierId = 0
  self.m_sCurFile = ""
  self.m_bBuild = false
  self.m_bBuildOver = true
  self.m_bIsLocked = false
  self.m_pBuildBar = nil
  self.m_bShowTip = false
  self.m_vListeners = {}
end
function Camp:onEnter()
  Camp.super.onEnter(self)
  self:AddListeners()
  if self.m_bIsLocked then
    self:CreateAnimation(td.HOME_CAMP_LOCK_FILE)
  else
    self:CreateAnimation(td.HOME_CAMP_DEF_FILE)
  end
  self.m_pSkeleton:PlayAni("animation", true)
end
function Camp:onExit()
  self:RemoveListeners()
  Camp.super.onExit(self)
end
function Camp:AddListeners()
  local eventDispatcher = self:getEventDispatcher()
  local updateListener = cc.EventListenerCustom:create(td.CAMP_UPDATE_EVENT, handler(self, self.UpdateCamp))
  eventDispatcher:addEventListenerWithFixedPriority(updateListener, 1)
  table.insert(self.m_vListeners, updateListener)
  local updateResListener = cc.EventListenerCustom:create(td.UPDATE_RESOURCE, handler(self, self.UpdateUpgradeTip))
  eventDispatcher:addEventListenerWithFixedPriority(updateResListener, 1)
  table.insert(self.m_vListeners, updateResListener)
end
function Camp:RemoveListeners()
  local eventDispatcher = self:getEventDispatcher()
  for i, var in ipairs(self.m_vListeners) do
    eventDispatcher:removeEventListener(var)
  end
  self.m_vListeners = {}
end
function Camp:UpdateCamp(_event)
  local data = string.toTable(_event:getDataString())
  if data.lock then
    self:Lock(true)
    return
  elseif data.unlock then
    self:Lock(false)
    return
  end
  if data.index ~= self.m_iID then
    return
  end
  if data.build and data.bType then
    self:Build(data.bType)
  elseif data.upgrade then
    self:LevelUp(data.branch)
  elseif data.sell then
    self:Sell()
  end
end
function Camp:UpdateUpgradeTip()
end
function Camp:Build(roleId)
  self:SetData(roleId)
  self.m_bBuild = true
  self.m_bBuildOver = false
  local pEffect = SkeletonUnit:create("Spine/bingying/jiaozaotexiao")
  pEffect:PlayAni("jianzaotexiao", true)
  pEffect:setPosition(self:getContentSize().width / 2, 10)
  self:addChild(pEffect, 1)
  if not self.m_pBuildBar then
    local timerSpr = display.newSprite("#UI/battle/buildbar_2.png")
    self.m_pBuildBar = cc.ProgressTimer:create(timerSpr)
    self.m_pBuildBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.m_pBuildBar:setMidpoint(cc.p(0, 0))
    self.m_pBuildBar:setBarChangeRate(cc.p(1, 0))
    self.m_pBuildBar:setPosition(cc.p(self:getContentSize().width / 2, 80))
    self:addChild(self.m_pBuildBar, 3)
    local bg = display.newSprite("#UI/battle/buildbar_1.png")
    bg:setPosition(timerSpr:getContentSize().width / 2, timerSpr:getContentSize().height / 2)
    self.m_pBuildBar:addChild(bg, -1)
  end
  self.m_pBuildBar:setPercentage(0)
  self.m_pBuildBar:setVisible(true)
  self.m_pBuildBar:runAction(cca.seq({
    cca.progressTo(2, 100),
    cca.cb(function()
      self.m_bBuildOver = true
      self.m_pBuildBar:setVisible(false)
      pEffect:removeFromParent()
      self:PlayUpgradeEffect()
      self:performWithDelay(function()
        self:CreateAnimation(self.m_sCurFile)
        self:PlayAnimation("bingying_01")
        if self.m_buildSkeleton then
          self.m_buildSkeleton:removeFromParent()
          self.m_buildSkeleton = nil
        end
        self:UpdateUpgradeTip()
      end, 0.3)
      local gdMng = GameDataManager:GetInstance()
      gdMng:UpdateStarCondition(td.StarLevel.BARRACK_LIMIT, 1)
      require("app.trigger.TriggerManager"):GetInstance():SendEvent({
        eType = td.ConditionType.BuildCamp,
        campId = self.m_iID,
        campType = self.m_iCampType,
        level = 1
      })
    end)
  }))
  if self.m_pSkeleton then
    self.m_pSkeleton:removeFromParent()
    self.m_pSkeleton = nil
  end
  G_SoundUtil:PlaySound(711)
end
function Camp:SetData(roleId)
  self.m_iSoldierId = roleId
  local soldierInfo = ActorInfoManager:GetInstance():GetSoldierInfo(self.m_iSoldierId)
  self.m_sCurFile = soldierInfo.camp_file
end
function Camp:PlayCreateSoldierAni()
  local bonePos = cc.p(self:getContentSize().width / 2, 0)
  local pEffect = require("app.effect.EffectManager"):GetInstance():CreateEffect(2066, nil, nil, bonePos)
  if pEffect then
    self:addChild(pEffect)
  end
end
function Camp:GetBornPos()
  return cc.p(self:getPositionX() + self:getContentSize().width / 2, self:getPositionY() - 40)
end
function Camp:Lock()
  self.m_bIsLocked = true
end
function Camp:PlayUpgradeEffect()
  td.CreateUIEffect(self, "Spine/bingying/bingyingshengji", {
    pos = cc.p(self:getContentSize().width / 2, 10),
    zorder = 2,
    ani = "bingyingshengji"
  })
end
function Camp:SetID(iID)
  self.m_iID = iID
end
function Camp:GetID()
  return self.m_iID
end
function Camp:GetSoldierId()
  return self.m_iSoldierId
end
function Camp:GetRoleBornPos()
  return cc.p(self:getPositionX() + self:getContentSize().width / 2, self:getPositionY() - 30)
end
function Camp:IsPeace()
  return true
end
return Camp
