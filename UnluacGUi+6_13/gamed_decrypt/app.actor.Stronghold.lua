local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local EffectManager = require("app.effect.EffectManager")
local ShadeHole = import(".ShadeHole")
local Stronghold = class("Stronghold", ShadeHole)
function Stronghold:ctor(eType, fileNmae)
  Stronghold.super.ctor(self, eType, fileNmae)
  self.m_iCurNum = 0
  self.m_bIsStart = false
  self.m_bIsOccupying = false
  self.m_bIsFinished = false
end
function Stronghold:onEnter()
  Stronghold.super.onEnter(self)
end
function Stronghold:onExit()
  Stronghold.super.onExit(self)
end
function Stronghold:Init()
  local conSize = self:getContentSize()
  local center = cc.p(conSize.width / 2, conSize.height / 2)
  local progressTimer = cc.ProgressTimer:create(display.newSprite("#UI/battle/neiquan.png"))
  self.m_pProgress1 = progressTimer
  progressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
  progressTimer:setPercentage(0)
  progressTimer:setScaleX(1.1)
  progressTimer:setScaleY(0.63)
  progressTimer:setPosition(cc.p(center.x, center.y - 6))
  self:addChild(progressTimer, 1)
  progressTimer = cc.ProgressTimer:create(display.newSprite("#UI/battle/waiquan.png"))
  self.m_pProgress2 = progressTimer
  progressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
  progressTimer:setPercentage(0)
  progressTimer:setScaleY(0.63)
  progressTimer:setPosition(cc.p(center.x, center.y - 9))
  self:addChild(progressTimer, 2)
  self.m_pOccupyEffect = EffectManager:GetInstance():CreateEffect(2048, nil, nil, center)
  self.m_pOccupyEffect:setVisible(false)
  self:addChild(self.m_pOccupyEffect, 3)
  self:ShowTip()
end
function Stronghold:ShowTip()
  local label = td.CreateLabel(g_LM:getBy("t00018"), td.YELLOW, 16, td.OL_BROWN, 2)
  local labelSize = label:getContentSize()
  local bgSize = cc.size(labelSize.width + 20, labelSize.height + 20)
  local pArrow = display.newScale9Sprite("UI/scale9/paopaokuang2.png", 0, 0, bgSize)
  pArrow:setRotation(180)
  label:setRotation(-180)
  td.AddRelaPos(pArrow, label)
  local spr = display.newSprite("UI/scale9/paopaokuang1.png")
  spr:setAnchorPoint(0.5, 0)
  spr:setPosition(bgSize.width / 2, bgSize.height - 4)
  pArrow:addChild(spr)
  pArrow:setScale(0.01)
  pArrow:runAction(cca.seq({
    cca.delay(math.random(10) / 10),
    cca.scaleTo(0.2, 1.2),
    cca.scaleTo(0.2, 0.85),
    cca.scaleTo(0.2, 1),
    cca.cb(function()
      pArrow:runAction(cca.repeatForever(cca.seq({
        cca.moveBy(0.5, 0, 10),
        cca.moveBy(1, 0, -20),
        cca.moveBy(0.5, 0, 10)
      })))
    end)
  }))
  td.AddRelaPos(self, pArrow, 2, cc.p(0.5, 0.7))
  self.m_tipSkeleton = pArrow
end
function Stronghold:IsActorInRange(vec)
  local iCount = 0
  local rect = self:getBoundingBox()
  for i, v in pairs(vec) do
    if not v:IsRemove() and not v:IsDead() and v:GetType() ~= td.ActorType.Hero and cc.rectContainsPoint(rect, cc.p(v:getPosition())) then
      return true
    end
  end
  return false
end
function Stronghold:Update(dt)
  if self.m_bIsFinished then
    return
  end
  if self.m_eResource == td.ResourceType.ZhanLingShiYou or self.m_eResource == td.ResourceType.ZhanLingShuiJing or self.m_eResource == td.ResourceType.ZhanLingDanYao then
    local selfInRange = self:IsActorInRange(ActorManager:GetInstance():GetSelfVec())
    local enemyInRange = self:IsActorInRange(ActorManager:GetInstance():GetEnemyVec())
    if selfInRange and not enemyInRange then
      if not self.m_bIsStart then
        self.m_bIsStart = true
        self.m_pOccupyEffect:GetContentNode():PlayAni("animation", true)
        self.m_pOccupyEffect:setVisible(true)
        if self.m_tipSkeleton then
          self.m_tipSkeleton:removeFromParent()
          self.m_tipSkeleton = nil
        end
      end
      self.m_fTime = self.m_fTime + dt
      if self.m_fTime >= self.m_fCaptureTime then
        self.m_fCaptureSpaceTime = self.m_fCaptureSpaceTime + dt
        if self.m_fCaptureSpaceTime >= 1 then
          if not self.m_bIsOccupying then
            self.m_bIsOccupying = true
            self.m_pOccupyEffect:GetContentNode():PlayAni("animation_01", true)
            local conSize = self:getContentSize()
            local center = cc.p(conSize.width / 2, conSize.height / 2)
            local pEffect = EffectManager:GetInstance():CreateEffect(2049, nil, nil, center)
            self:addChild(pEffect, 4)
          end
          local eType = 0
          if self.m_eResource == td.ResourceType.ZhanLingShiYou then
            eType = td.ResourceType.ShiYou
          elseif self.m_eResource == td.ResourceType.ZhanLingShuiJing then
            eType = td.ResourceType.ShuiJing
          elseif self.m_eResource == td.ResourceType.ZhanLingDanYao then
            eType = td.ResourceType.DanYao
          end
          GameDataManager:GetInstance():UpdateNeedResCount(eType, self.m_iSingleNum)
          self.m_iCurNum = self.m_iCurNum + self.m_iSingleNum
          self.m_pProgress2:setPercentage(self.m_iCurNum / self.m_iMaxNum * 100)
          if self.m_iCurNum >= self.m_iMaxNum then
            self.m_bIsFinished = true
            self.m_pOccupyEffect:setVisible(false)
            local conSize = self:getContentSize()
            local center = cc.p(conSize.width / 2, conSize.height / 2)
            local pEffect = EffectManager:GetInstance():CreateEffect(2050, nil, nil, center)
            self:addChild(pEffect, 4)
            pEffect = EffectManager:GetInstance():CreateEffect(2051, nil, nil, center)
            self:addChild(pEffect, 4)
          end
          self.m_fCaptureSpaceTime = 0
        end
      end
      self.m_pProgress1:setPercentage(self.m_fTime / self.m_fCaptureTime * 100)
    else
      if self.m_bIsStart then
        self.m_pOccupyEffect:setVisible(false)
        self.m_bIsOccupying = false
        self.m_bIsStart = false
        self.m_pProgress1:setPercentage(0)
      end
      self.m_fTime = 0
    end
  end
end
return Stronghold
