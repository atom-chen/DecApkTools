local AttributeBase = import(".AttributeBase")
local GameDataManager = require("app.GameDataManager")
local NewEffectAttribute = class("NewEffectAttribute", AttributeBase)
function NewEffectAttribute:ctor(pEffect, fNextAttributeTime, id, bInherit, zOrder, iCount)
  NewEffectAttribute.super.ctor(self, td.AttributeType.NewEffect, pEffect, fNextAttributeTime)
  self.m_iNextId = id
  self.m_iZOrder = bInherit and (zOrder or 0)
  self.m_iCount = iCount or 1
end
function NewEffectAttribute:Active()
  NewEffectAttribute.super.Active(self)
  if self.m_iZOrder then
    self.m_iZOrder = self.m_pEffect:getLocalZOrder() + self.m_iZOrder
  end
  for i = 1, self.m_iCount do
    local EffectManager = require("app.effect.EffectManager")
    local selfActor = self.m_pEffect:GetSelfActor()
    local targetActor = self.m_pEffect:GetTargetActor()
    local newEffect = EffectManager:GetInstance():CreateEffect(self.m_iNextId, selfActor, targetActor)
    newEffect:setPosition(self.m_pEffect:getPosition())
    newEffect:SetSkill(self.m_pEffect:GetSkill())
    newEffect:SetSelfActorParams(self.m_pEffect:GetSelfActorParams())
    local pParent = self.m_pEffect:getParent()
    local pMap = GameDataManager:GetInstance():GetGameMap()
    if pParent == pMap:GetTileMap() then
      newEffect:AddToMap(pMap, self.m_iZOrder)
    else
      newEffect:AddToActor(targetActor, self.m_iZOrder)
    end
  end
  self:SetOver()
end
return NewEffectAttribute
