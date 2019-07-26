local Monster = import(".Monster")
local GameDataManager = require("app.GameDataManager")
local StateManager = require("app.actor.state.StateManager")
local EffectManager = require("app.effect.EffectManager")
local Patrol = class("Patrol", Monster)
Patrol.FlyHeight = 200
function Patrol:ctor(eType, pData)
  Patrol.super.ctor(self, eType, pData)
  self.m_bIsMoving = false
end
function Patrol:CreateAnimation(strFileName)
  Patrol.super.CreateAnimation(self, strFileName)
  self.m_pSkeleton:setPositionY(Patrol.FlyHeight)
  local bones = {"bone_eft", "bone_eft1"}
  for i = 1, 2 do
    local fire = SkeletonUnit:create("Spine/skill/EFT_penshe_01")
    self:FindBoneNode(bones[i]):addChild(fire)
    fire:PlayAni("animation", true, false)
  end
  self.m_pShadow = display.newSprite("#Effect/shadow.png")
  self.m_pShadow:setScale(3)
  self:addChild(self.m_pShadow, -1)
end
function Patrol:InitState()
  self.m_pStateManager = StateManager.new(self)
  self.m_pStateManager:AddStates(td.StatesType.ResMonster)
  self.m_pStateManager:ChangeState(td.StateType.Idle)
end
function Patrol:MoveAction(nextPos)
  if not self.m_bIsMoving then
    self.m_pSkeleton:runAction(cca.repeatForever(cca.seq({
      cca.moveBy(1, 0, 20),
      cca.moveBy(1, 0, -20)
    })))
    self.m_pShadow:runAction(cca.repeatForever(cca.seq({
      cca.scaleTo(1, 2.8),
      cca.scaleTo(1, 3.2)
    })))
    self.m_bIsMoving = true
  end
end
function Patrol:StopMove()
end
function Patrol:FindBonePos(boneName)
  local p = Patrol.super.FindBonePos(self, boneName)
  p.y = p.y + Patrol.FlyHeight * self:getScaleY()
  return p
end
function Patrol:FindPath(endPos)
  return {endPos}
end
function Patrol:IsCanBuffed()
  return false
end
function Patrol:IsCanBeMoved()
  return false
end
function Patrol:IsCanAttacked()
  return false
end
return Patrol
