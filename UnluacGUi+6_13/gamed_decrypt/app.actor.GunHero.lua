local Hero = import(".Hero")
local GameDataManager = require("app.GameDataManager")
local GunHero = class("GunHero", Hero)
function GunHero:ctor(eType, pData)
  GunHero.super.ctor(self, eType, pData)
end
function GunHero:BeforeAttack(callback)
  self:UpdateEnemyAzimuth()
  self:PlayAnimation("BFfire_0" .. self.m_pEnemyAzimuth, false, callback, sp.EventType.ANIMATION_COMPLETE)
end
function GunHero:AfterAttack(callback)
  self:PlayAnimation("AFfire_0" .. self.m_pEnemyAzimuth, false, callback, sp.EventType.ANIMATION_COMPLETE)
end
return GunHero
