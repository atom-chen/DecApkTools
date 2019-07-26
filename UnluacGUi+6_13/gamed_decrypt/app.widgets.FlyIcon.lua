local GameDataManager = require("app.GameDataManager")
local FlyIcon = class("FlyIcon", function(itemId, file, bEnd)
  if file then
    return display.newSprite(file)
  else
    return td.CreateItemIcon(itemId)
  end
end)
local Types = {
  GOLD = 1,
  STAMINA = 2,
  DIAMOND = 3,
  OTHER = 4,
  HERO = 5,
  Liveness = 6,
  Honor = 7,
  Force = 8
}
function FlyIcon:ctor(itemId, file, bEnd, num)
  self.m_bHaveEndEffect = bEnd
  self.m_itemId = itemId
  self.m_soundHandle = nil
  self.m_iNum = num or 1
  self:setNodeEventEnabled(true)
end
function FlyIcon:onExit()
  if self.m_soundHandle then
    G_SoundUtil:StopSound(self.m_soundHandle)
    self.m_soundHandle = nil
  end
end
function FlyIcon:GetType(itemId)
  if itemId == td.ItemID_Gold then
    return Types.GOLD
  elseif itemId == td.ItemID_Stamina then
    return Types.STAMINA
  elseif itemId == td.ItemID_Diamond then
    return Types.DIAMOND
  elseif itemId == 1 then
    return Types.HERO
  elseif itemId == 70000 then
    return Types.Liveness
  elseif itemId == 20002 then
    return Types.Honor
  elseif itemId == td.ItemID_Force then
    return Types.Force
  else
    return Types.OTHER
  end
end
function FlyIcon:SetParentUIRoot(uiRoot)
  self.m_parentUIRoot = uiRoot
end
function FlyIcon:GetFlyPos(itemId)
  local _type = self:GetType(itemId)
  local uiRoot = display.getRunningScene():GetUIRoot()
  local pos, target = cc.p(0, 0), nil
  if _type == Types.GOLD then
    target = cc.uiloader:seekNodeByName(uiRoot, "icon_gold")
  elseif _type == Types.Force then
    target = cc.uiloader:seekNodeByName(uiRoot, "icon_force")
  elseif _type == Types.STAMINA then
    target = cc.uiloader:seekNodeByName(uiRoot, "icon_strength")
  elseif _type == Types.DIAMOND then
    target = cc.uiloader:seekNodeByName(uiRoot, "icon_diamond")
  elseif _type == Types.HERO then
    target = cc.uiloader:seekNodeByName(uiRoot, "Button_op")
  elseif _type == Types.Liveness then
    target = cc.uiloader:seekNodeByName(self.m_parentUIRoot, "LivenessBar")
  elseif _type == Types.Honor then
    target = cc.uiloader:seekNodeByName(uiRoot, "Button_head")
  else
    target = cc.uiloader:seekNodeByName(uiRoot, "Node_3")
  end
  pos = target:getParent():convertToWorldSpace(cc.p(target:getPosition()))
  return pos
end
function FlyIcon:Fly()
  self:addTo(display.getRunningScene(), td.ZORDER.Info)
  local flyPos = self:GetFlyPos(self.m_itemId)
  local selfPos = cc.p(self:getPosition())
  local conPos1 = cc.p(selfPos.x + (flyPos.x - selfPos.x) * math.random(4) / 10, selfPos.y)
  local conPos2 = cc.p(selfPos.x + (flyPos.x - selfPos.x) * (math.random(4) + 5) / 10, selfPos.y + (flyPos.y - selfPos.y) * (math.random(4) + 5) / 10)
  local autoScale = td.GetAutoScale()
  local time = math.max(cc.pGetDistance(selfPos, flyPos) / (800 * autoScale), 0.5)
  if self.m_bHaveEndEffect then
    G_SoundUtil:PlaySound(56, false)
  end
  local randomPos = cc.p(math.random(100) - 50, math.random(100) - 50)
  self:runAction(cca.seq({
    cca.delay(0.2),
    cca.cb(function()
      if self.m_bHaveEndEffect then
        self.m_soundHandle = G_SoundUtil:PlaySound(58, true)
      end
      if self.m_bHaveEndEffect then
        local particle = ParticleManager:GetInstance():CreateParticle("Effect/shoujibao.plist")
        particle:setScale(2)
        td.AddRelaPos(self, particle)
      end
    end),
    cc.EaseSineOut:create(cca.moveBy(0.5, randomPos.x, randomPos.y)),
    cca.cb(function()
      self.m_particle = ParticleManager:GetInstance():CreateParticle("Effect/shouji.plist")
      td.AddRelaPos(self, self.m_particle, -1)
    end),
    cc.EaseSineIn:create(cca.moveTo(time, flyPos.x, flyPos.y)),
    cca.cb(function()
      self:setOpacity(0)
      self.m_particle:stopSystem()
      if self.m_bHaveEndEffect then
        G_SoundUtil:StopSound(self.m_soundHandle)
        self.m_soundHandle = nil
        G_SoundUtil:PlaySound(59, false)
        local endEffect = SkeletonUnit:create("Spine/UI_effect/EFT_shoujiguang_01")
        endEffect:setScale(0.5 * td.GetAutoScale())
        endEffect:setPosition(self:getPosition())
        endEffect:addTo(self:getParent(), self:getLocalZOrder())
        endEffect:PlayAni("animation", false)
      end
    end),
    cca.delay(1),
    cca.removeSelf()
  }))
  return time + 0.7
end
return FlyIcon
