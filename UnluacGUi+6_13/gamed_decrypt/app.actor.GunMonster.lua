local Monster = import(".Monster")
local GameDataManager = require("app.GameDataManager")
local GunMonster = class("GunMonster", Monster)
function GunMonster:ctor(eType, pData)
  GunMonster.super.ctor(self, eType, pData)
end
function GunMonster:BeforeAttack(callback)
  self:UpdateEnemyAzimuth()
  callback()
end
function GunMonster:AfterAttack(callback)
  callback()
end
return GunMonster
