local ActorBase = import(".ActorBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local GameDataManager = require("app.GameDataManager")
local Door = class("Actor", ActorBase)
function Door:ctor(eType, pData)
  Door.super.ctor(self, eType, "Spine/skill/EFT_chuansongmen_01")
  self.m_iMaxHp = 200
  self.m_iCurHp = 200
  self.m_pSkill = nil
  self:setScale(2)
  self:CreateHPBar()
end
function Door:onEnter()
  Door.super.onEnter(self)
  self:PlayIdle()
end
function Door:onExit()
  Door.super.onExit(self)
end
function Door:Update(dt)
  Door.super.Update(self, dt)
end
function Door:SetBelongSkill(pSkill)
  self.m_pSkill = pSkill
end
function Door:PlayIdle()
  self:PlayAnimation("animation", true)
end
function Door:CreateHPBar()
  local height = self.m_pSkeleton:GetContentSize().height
  local BloodBar = require("app.widgets.BloodBar")
  self.m_pHpBar = BloodBar.new(1, self.m_eGroupType)
  self.m_pHpBar:setScale(1 / self:getScale())
  self.m_pHpBar:setPosition(cc.p(0, height))
  self:addChild(self.m_pHpBar, 1)
end
function Door:ChangeHp(iHp)
  self.m_iCurHp = cc.clampf(self.m_iCurHp + iHp, 0, self:GetMaxHp())
  if self.m_iCurHp <= 0 then
    self:OnDead()
    td.dispatchEvent(td.ACTOR_DIED, self:getTag())
  end
  self.m_pHpBar:SetPercentage(self:GetCurHp() / self:GetMaxHp() * 100)
end
function Door:OnDead()
  local disapearAction = cc.EaseSineInOut:create(cca.scaleTo(1, 0))
  self:runAction(cca.seq({
    disapearAction,
    cca.cb(function()
      self:SetRemove(true)
    end)
  }))
  if self.m_pSkill then
    self.m_pSkill:OnDoorDisapear()
    self.m_pSkill = nil
  end
end
function Door:IsDead()
  return self.m_iCurHp <= 0
end
function Door:SetCurHp(iHp)
  self.m_iCurHp = iHp
end
function Door:GetCurHp()
  return self.m_iCurHp
end
function Door:GetMaxHp()
  return self.m_iMaxHp
end
function Door:GetDodgeRate()
  return 0
end
function Door:GetDefense()
  return 0
end
function Door:IsCanBuffed()
  return false
end
function Door:IsCanBeMoved()
  return false
end
return Door
