local Soldier = import(".Soldier")
local GameDataManager = require("app.GameDataManager")
local GunSoldier = class("GunSoldier", Soldier)
function GunSoldier:ctor(eType, pData)
  GunSoldier.super.ctor(self, eType, pData)
end
function GunSoldier:BeforeAttack(callback)
  self:UpdateEnemyAzimuth()
  if self.m_pData.id == 404 or self.m_pData.id == 406 then
    callback()
  else
    self:PlayAnimation("BFfire_0" .. self.m_pEnemyAzimuth, false, callback, sp.EventType.ANIMATION_COMPLETE)
  end
end
function GunSoldier:AfterAttack(callback)
  if self.m_pData.id == 404 or self.m_pData.id == 406 then
    callback()
  else
    self:PlayAnimation("AFfire_0" .. self.m_pEnemyAzimuth, false, callback, sp.EventType.ANIMATION_COMPLETE)
  end
end
return GunSoldier
