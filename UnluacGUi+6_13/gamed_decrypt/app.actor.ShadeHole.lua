local ActorManager = require("app.actor.ActorManager")
local BuffManager = require("app.buff.BuffManager")
local GameDataManager = require("app.GameDataManager")
local ActorBase = import(".ActorBase")
local ShadeHole = class("ShadeHole", ActorBase)
function ShadeHole:ctor(eType, fileNmae)
  ShadeHole.super.ctor(self, eType, fileNmae)
  self.m_eResource = td.ResourceType.Non
  self.m_iSingleNum = 0
  self.m_iMaxNum = 0
  self.m_fCaptureTime = 0
  self.m_fCaptureSpaceTime = 0
  self.m_inHole = {}
  self:setNodeEventEnabled(true)
end
function ShadeHole:onEnter()
  ShadeHole.super.onEnter(self)
  self:Init()
end
function ShadeHole:onExit()
  ShadeHole.super.onExit(self)
end
function ShadeHole:Init()
  self:ShowTip()
end
function ShadeHole:Update(dt)
  if self.m_eResource == td.ResourceType.ZiYuan or self.m_eResource == td.ResourceType.DanYao or self.m_eResource == td.ResourceType.ShuiJing or self.m_eResource == td.ResourceType.ShiYou then
    local inCount = self:Detection(ActorManager:GetInstance():GetSelfVec())
    if inCount > 0 then
      self:PlayAnimation("caiji_02", true)
    else
      self:PlayAnimation("caiji_01", true)
    end
  end
  if self.m_eResource == td.ResourceType.Non then
    self:Detection(ActorManager:GetInstance():GetSelfVec())
    self:Detection(ActorManager:GetInstance():GetEnemyVec())
  end
end
function ShadeHole:Detection(vec)
  local inCount = 0
  local rect = {}
  local size = self:getContentSize()
  rect.x = self:getPositionX() - size.width / 2
  rect.y = self:getPositionY() - size.height / 2
  rect.width = size.width
  rect.height = size.height
  for i, v in pairs(vec) do
    local tag = v:getTag()
    if cc.rectContainsPoint(rect, cc.p(v:getPosition())) then
      if not self.m_inHole[tag] then
        local buff = BuffManager:GetInstance():AddBuff(v, 3)
        self.m_inHole[tag] = buff
      end
      if v:GetType() ~= td.ActorType.Hero then
        inCount = inCount + 1
      end
    elseif self.m_inHole[tag] then
      self.m_inHole[tag]:SetRemove()
      self.m_inHole[tag] = nil
    end
  end
  return inCount
end
function ShadeHole:SetResource(eResource, singleNum, maxNum)
  self.m_eResource = eResource
  self.m_iSingleNum = singleNum
  self.m_iMaxNum = maxNum
end
function ShadeHole:SetCapturetime(time)
  self.m_fCaptureTime = time
end
function ShadeHole:GetResourceType()
  return self.m_eResource
end
function ShadeHole:GetSingleNum()
  return self.m_iSingleNum
end
function ShadeHole:GetMaxNum()
  return self.m_iMaxNum
end
function ShadeHole:ShowTip()
  local pArrow
  if self:_GetResName() then
    local label = td.CreateLabel(self:_GetResName(), td.YELLOW, 16, td.OL_BROWN, 2)
    local labelSize = label:getContentSize()
    local bgSize = cc.size(labelSize.width + 20, labelSize.height + 20)
    pArrow = display.newScale9Sprite("UI/scale9/paopaokuang2.png", 0, 0, bgSize)
    pArrow:setRotation(180)
    label:setRotation(-180)
    td.AddRelaPos(pArrow, label)
    local spr = display.newSprite("UI/scale9/paopaokuang1.png")
    spr:setAnchorPoint(0.5, 0)
    spr:setPosition(bgSize.width / 2, bgSize.height - 4)
    pArrow:addChild(spr)
    pArrow:setScale(0.01)
    pArrow:runAction(cca.seq({
      cca.delay(math.random(10) / 10),
      cca.scaleTo(0.2, 1.2),
      cca.scaleTo(0.2, 0.85),
      cca.scaleTo(0.2, 1),
      cca.cb(function()
        pArrow:runAction(cca.repeatForever(cca.seq({
          cca.moveBy(0.5, 0, 10),
          cca.moveBy(1, 0, -20),
          cca.moveBy(0.5, 0, 10)
        })))
      end)
    }))
  elseif self:_GetResFile() then
    pArrow = SkeletonUnit:create(self:_GetResFile())
    pArrow:setScale(1.5)
    pArrow:PlayAni("animation01", true)
    pArrow:runAction(cca.repeatForever(cca.seq({
      cca.moveBy(1, 0, 25),
      cca.moveBy(1, 0, -25)
    })))
  end
  if pArrow then
    td.AddRelaPos(self, pArrow, 2, cc.p(0, 0.7))
    self.m_tipSkeleton = pArrow
  end
end
function ShadeHole:_GetResName()
  if self.m_eResource == td.ResourceType.DanYao then
    return "\233\135\135\233\155\134\229\188\185\232\141\175\232\191\135\229\133\179"
  elseif self.m_eResource == td.ResourceType.ShuiJing then
    return "\233\135\135\233\155\134\230\176\180\230\153\182\232\191\135\229\133\179"
  elseif self.m_eResource == td.ResourceType.ShiYou then
    return "\233\135\135\233\155\134\231\159\179\230\178\185\232\191\135\229\133\179"
  elseif self.m_eResource == td.ResourceType.ZiYuan then
    return "\233\135\135\233\155\134\229\142\159\229\138\155\229\135\186\229\133\181"
  end
end
function ShadeHole:_GetResFile()
  if self.m_eResource == td.ResourceType.EnergyBall_s then
    return td.UI_energy1
  elseif self.m_eResource == td.ResourceType.EnergyBall_m then
    return td.UI_energy2
  elseif self.m_eResource == td.ResourceType.EnergyBall_l then
    return td.UI_energy3
  elseif self.m_eResource == td.ResourceType.Medal_s then
    return td.UI_medal1
  elseif self.m_eResource == td.ResourceType.Medal_m then
    return td.UI_medal2
  elseif self.m_eResource == td.ResourceType.Medal_l then
    return td.UI_medal3
  elseif self.m_eResource == td.ResourceType.StarStone_s then
    return td.UI_star1
  elseif self.m_eResource == td.ResourceType.StarStone_m then
    return td.UI_star2
  elseif self.m_eResource == td.ResourceType.StarStone_l then
    return td.UI_star3
  end
end
return ShadeHole
