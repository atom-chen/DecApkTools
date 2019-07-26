local Monster = import(".Monster")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local MonsterMachine = class("MonsterMachine", Monster)
function MonsterMachine:ctor(eType, pData)
  MonsterMachine.super.ctor(self, eType, pData)
  self:setVisible(false)
end
function MonsterMachine:onEnter()
  self:setPositionY(self:getPositionY() + display.height * 1.5)
  MonsterMachine.super.onEnter(self)
end
function MonsterMachine:PlayEnterAni()
  self:setVisible(true)
  local pos = cc.p(self:getPosition())
  self:FlyToPos(cc.p(pos.x, pos.y - display.height * 1.5), nil, 1)
end
function MonsterMachine:FlyOut()
  local pos = cc.p(self:getPosition())
  self:FlyToPos(cc.p(pos.x, pos.y + display.height), function()
    self:SetRemove(true)
  end, 1)
end
function MonsterMachine:FlyToPos(endPos, callback, flyDur)
  flyDur = flyDur or 1
  local yOffset = 80
  self:_FlyBefore()
  self:PlayAnimation("qifei_01", false, function()
    self:runAction(cca.seq({
      cca.moveBy(0.1, 0, yOffset),
      cca.cb(function()
        self:PlayAnimation("feixing_01", true)
      end),
      cc.EaseIn:create(cca.moveTo(flyDur, endPos.x, endPos.y), 1),
      cca.moveBy(0.4, 0, yOffset),
      cca.moveTo(0.2, endPos.x, endPos.y),
      cca.cb(function()
        self:PlayAnimations({
          {
            aniName = "zhuolu_01",
            isLoop = false,
            callback = function()
              self:_FlyAfter(callback)
            end
          },
          {aniName = "stand", isLoop = false}
        })
        self:_ShowSmoke()
      end)
    }))
    self:_ShowSmoke()
  end, sp.EventType.ANIMATION_COMPLETE)
end
function MonsterMachine:_ShowSmoke()
  local pos = cc.p(self:getPosition())
  pos.y = pos.y - 20
  local pEffect = EffectManager:GetInstance():CreateEffect(2007, nil, nil, pos)
  pEffect:AddToMap(GameDataManager:GetInstance():GetGameMap())
end
return MonsterMachine
