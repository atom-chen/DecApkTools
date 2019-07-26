local StateBase = import(".StateBase")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local HexState = class("HexState", StateBase)
function HexState:ctor(pStateManager, pActor)
  HexState.super.ctor(self, pStateManager, pActor)
  self.m_eType = td.StateType.Hex
  self.m_bIsWandering = true
  self.m_selfPos = nil
end
function HexState:OnEnter()
  self.m_pActor:StopMove()
  self.m_selfPos = cc.p(self.m_pActor:getPosition())
  local pEffect = EffectManager:GetInstance():CreateEffect(66, self.m_pActor, nil, cc.p(self.m_pActor:getPosition()))
  local pMap = require("app.GameDataManager"):GetInstance():GetGameMap()
  pEffect:AddToMap(pMap)
  self.m_bIsWandering = true
  pMap:runAction(cca.seq({
    cca.delay(0.3),
    cca.cb(function()
      if not self.m_pActor:IsDead() then
        self.m_pActor:HideBuffEffects()
        self.m_pActor:CreateAnimation("Spine/skill/EFT_bianyang_02")
        self.m_pActor:setScale(0.7)
        self.m_pActor:SetDirType(self.m_pActor:GetDirType())
        self.m_pActor:PlayAnimation("stand")
      end
      self.m_bIsWandering = false
    end)
  }))
end
function HexState:OnExit()
  local pEffect = EffectManager:GetInstance():CreateEffect(66, self.m_pActor, nil, cc.p(self.m_pActor:getPosition()))
  local pMap = require("app.GameDataManager"):GetInstance():GetGameMap()
  pEffect:AddToMap(pMap)
  self.m_pActor:stopAllActions()
  self.m_pActor:CreateAnimation()
  self.m_pActor:setScale(0.5 * self.m_pActor:GetRelativeScale())
  self.m_pActor:ShowBuffEffects()
  self.m_pActor:SetDirType(self.m_pActor:GetDirType())
end
function HexState:Update(dt)
  if self.m_pActor:IsDead() then
    self.m_pStateManager:ChangeState(td.StateType.Dead)
  end
  if not self.m_pActor:IsHex() then
    if self.m_pActor:IsTrapped() then
      self.m_pStateManager:ChangeState(td.StateType.Trapped)
    else
      self.m_pStateManager:ChangeState(td.StateType.Idle)
    end
  end
  if not self.m_bIsWandering and self.m_pActor:GetSpeed() > 0 and not self.m_pActor:IsTrapped() then
    self:Wander()
  end
end
function HexState:Wander()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local nowPos = cc.p(self.m_pActor:getPosition())
  local endPos = self.m_selfPos
  local count = 0
  repeat
    count = count + 1
    local randomPos = cc.p(math.random(50) - 25, math.random(50) - 25)
    endPos = cc.pAdd(self.m_selfPos, randomPos)
  until pMap:IsLineWalkable(nowPos, endPos) or count >= 50
  local moveLength = cc.pGetDistance(endPos, nowPos)
  local time = moveLength / 50
  local jumpCount = math.modf(moveLength / 8)
  if endPos.x >= nowPos.x then
    self.m_pActor:SetDirType(td.DirType.Right)
  else
    self.m_pActor:SetDirType(td.DirType.Left)
  end
  self.m_pActor:runAction(cca.seq({
    cca.jumpTo(time, endPos.x, endPos.y, 5, jumpCount),
    cca.cb(function()
      if self.m_pActor:IsDead() then
        self.m_pActor:PlayAnimation("dead")
      else
        self.m_pActor:PlayAnimation("stand")
      end
    end),
    cca.delay(math.random(10) / 10),
    cca.cb(function()
      self.m_bIsWandering = false
    end)
  }))
  self.m_pActor:PlayAnimation("run")
  self.m_bIsWandering = true
end
return HexState
