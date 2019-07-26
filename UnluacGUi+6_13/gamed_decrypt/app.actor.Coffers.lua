local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local EffectManager = require("app.effect.EffectManager")
local ActorBase = import(".ActorBase")
local Coffers = class("Coffers", ActorBase)
function Coffers:ctor(eType, fileNmae)
  Coffers.super.ctor(self, eType, fileNmae)
  self:Init()
end
function Coffers:onEnter()
  Coffers.super.onEnter(self)
end
function Coffers:onExit()
  Coffers.super.onExit(self)
end
function Coffers:Init()
  local robData = GameDataManager:GetInstance():GetRobData()
  self:CreateAnimation("Spine/bingying/caijiqi_01")
  self:PlayAnimation("animation")
  local label = td.CreateLabel(robData.name, td.WHITE, 30, td.OL_BLACK, 2)
  local labelSize = label:getContentSize()
  local nameBg = display.newScale9Sprite("UI/scale9/lvse_tishikuang.png", 0, 0, cc.size(labelSize.width + 50, labelSize.height * 1.5), cc.rect(24, 20, 5, 10))
  nameBg:pos(0, 220):addTo(self)
  td.AddRelaPos(nameBg, label)
end
return Coffers
