local Actor = import(".Actor")
local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local StateManager = require("app.actor.state.StateManager")
local SummonUnit = class("SummonUnit", Actor)
function SummonUnit:ctor(eType, pData)
  self.summonerTag = nil
  self.life = 0
  SummonUnit.super.ctor(self, eType, pData)
end
function SummonUnit:onEnter()
  SummonUnit.super.onEnter(self)
end
function SummonUnit:SetData(pData)
  SummonUnit.super.SetData(self, pData)
  self.life = pData.life or self.life
  self.summonerTag = pData.summonerTag
end
function SummonUnit:InitState()
  self.m_pStateManager = StateManager.new(self)
  self.m_pStateManager:AddStates(td.StatesType.Soldier)
  self.m_pStateManager:ChangeState(td.StateType.Idle)
end
function SummonUnit:Update(dt)
  SummonUnit.super.Update(self, dt)
  local summoner = ActorManager:GetInstance():FindActorByTag(self.summonerTag)
  self.life = self.life - dt
  if self.life <= 0 or summoner and summoner:IsDead() then
    self:SetRemove(true)
  end
end
function SummonUnit:IsCanBuffed()
  return false
end
function SummonUnit:AddTouch()
end
return SummonUnit
