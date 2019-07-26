local GameDataManager = require("app.GameDataManager")
local AttributeBase = import(".AttributeBase")
local WalkAttribute = class("WalkAttribute", AttributeBase)
function WalkAttribute:ctor(pEffect, fNextAttributeTime, data)
  WalkAttribute.super.ctor(self, td.AttributeType.Walk, pEffect, fNextAttributeTime)
  self.m_posList = data.posList
  self.m_repeatCnt = data.repeatCnt or 1
  self.m_speed = data.speed or 200
  self.m_hasTurnAnim = false
  self.m_runAnim = data.runAnim or "run"
  if data.hasTurnAnim then
    self.m_hasTurnAnim = true
  end
  self.m_randomCnt = data.randomCnt
  if data.randomCnt then
    self.m_repeatCnt = math.random(self.m_randomCnt[1], self.m_randomCnt[2])
  end
  self.m_freeAnim = data.freeAnim
  self.m_needFreeState = false
  self.m_isFreeState = false
  self.m_maxRate = 0
  self.m_overRemove = false
  if data.overRemove == true then
    self.m_overRemove = true
  end
  if data.overNewEffectId then
    self.m_overNewEffectId = data.overNewEffectId
  end
  self.m_cnt = 0
  self.m_posIndex = 1
  self.m_lastAnim = nil
  self.m_freeTime = 0
end
function WalkAttribute:Active()
  WalkAttribute.super.Active(self)
  if self.m_freeAnim then
    self.m_needFreeState = true
    self.m_freeTime = math.random(4, 8)
    for _, value in pairs(self.m_freeAnim) do
      self.m_maxRate = self.m_maxRate + value[2]
    end
  end
  if self.m_repeatCnt == -1 then
    self:SetOver()
  end
end
function WalkAttribute:Update(dt)
  WalkAttribute.super.Update(self, dt)
  if self.m_overRemove and self:IsOver() then
    self.m_pEffect:SetRemove()
    if self.m_overNewEffectId then
      local EffectManager = require("app.effect.EffectManager")
      local pMap = GameDataManager:GetInstance():GetGameMap()
      local newEffect = EffectManager:GetInstance():CreateEffect(self.m_overNewEffectId)
      if newEffect then
        newEffect:AddToMap(pMap, self.m_iZOrder)
      end
    end
  end
  if self:IsOver() and self.m_repeatCnt ~= -1 then
    return
  end
  if self.m_needFreeState then
    self.m_freeTime = self.m_freeTime - dt
    if self.m_freeTime <= 0 then
      if self.m_isFreeState then
        self.m_isFreeState = false
        self.m_freeTime = math.random(6, 10)
      else
        self.m_isFreeState = true
        self.m_freeTime = math.random(3, 5)
        local animName
        local rate = math.random(1, self.m_maxRate)
        local tmpRate = 0
        for _, value in pairs(self.m_freeAnim) do
          tmpRate = tmpRate + value[2]
          if rate <= tmpRate then
            animName = value[1]
            break
          end
        end
        self.m_lastAnim = animName
        self.m_pEffect:GetContentNode():PlayAni(animName, true, false)
        return
      end
    end
    if self.m_isFreeState then
      return
    end
  end
  local pos = self.m_posList[self.m_posIndex]
  local curPos = cc.p(self.m_pEffect:getPosition())
  local normalizePos = cc.pNormalize(cc.pSub(pos, curPos))
  local tempPos = cc.pAdd(curPos, cc.pMul(normalizePos, self.m_speed * dt))
  if PulibcFunc:GetInstance():GetDirection(curPos, pos) == PulibcFunc:GetInstance():GetDirection(tempPos, pos) and not cc.pFuzzyEqual(normalizePos, cc.p(0, 0), 0) then
    self:MoveAction(tempPos)
    self.m_pEffect:setPosition(tempPos)
  else
    tempPos = pos
    self:MoveAction(tempPos)
    self.m_pEffect:setPosition(tempPos)
    self.m_posIndex = self.m_posIndex + 1
    if self.m_posIndex > table.nums(self.m_posList) then
      self.m_cnt = self.m_cnt + 1
      self.m_posIndex = 1
      if self.m_cnt >= self.m_repeatCnt then
        self:SetOver()
      end
    end
  end
end
function WalkAttribute:MoveAction(nextPos)
  local animName
  local tempPos = cc.pNormalize(cc.pSub(nextPos, cc.p(self.m_pEffect:getPosition())))
  if self.m_hasTurnAnim and math.abs(tempPos.y) > math.abs(tempPos.x) and math.abs(tempPos.x) < 0.5 then
    if tempPos.y > 0 then
      animName = "BMrun"
    else
      animName = "ZMrun"
    end
  else
    animName = self.m_runAnim
  end
  if animName ~= self.m_lastAnim then
    self.m_pEffect:GetContentNode():PlayAni(animName, true, false)
    self.m_lastAnim = animName
  end
  if tempPos.x > 0 then
    self:SetDirType(td.DirType.Right)
  else
    self:SetDirType(td.DirType.Left)
  end
end
function WalkAttribute:SetDirType(eType)
  if eType == td.DirType.Left then
    self.m_pEffect:GetContentNode():setScaleX(-1)
  else
    self.m_pEffect:GetContentNode():setScaleX(1)
  end
end
function WalkAttribute:ForceSetOver()
  self:SetOver()
  self.m_repeatCnt = 0
end
return WalkAttribute
