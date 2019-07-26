local GameDataManager = require("app.GameDataManager")
local EffectBase = class("EffectBase", function()
  return display.newNode()
end)
EffectBase.ZType = {
  Top = 0,
  Bottom = 1,
  Y = 2
}
function EffectBase:ctor(iSelfActorTag, iTargetActorTag, pEffectInfo)
  self.m_pContentNode = nil
  self.m_iSelfActorTag = iSelfActorTag
  self.m_pActorParams = nil
  self.m_iTargetActorTag = iTargetActorTag
  self.m_iID = pEffectInfo.id
  self.m_eType = pEffectInfo.type
  self.m_bAttrOverRemoveSelf = pEffectInfo.overRemove
  self.m_pBindingBone = pEffectInfo.bone
  self.m_pActorColor = pEffectInfo.color
  self.m_pActorScale = pEffectInfo.actorScale
  self.m_eZorderType = pEffectInfo.zType or EffectBase.ZType.Top
  self.m_bRemove = false
  self.m_bAllAttrOver = false
  self.m_targetActorPos = nil
  self.m_direction = cc.p(0, 0)
  self.m_bIsEntered = false
  self.m_endCallback = nil
  self.m_clickCallback = nil
  self.m_vAttributes = {}
  self.m_vMembers = {}
  self.m_pSkill = nil
  self:setNodeEventEnabled(true)
end
function EffectBase:onEnter()
  for i, v in ipairs(self.m_vAttributes) do
    v:Active()
    if not v:IsExecuteNextAttribute() then
      break
    end
  end
  local parent = self:getParent()
  for i, member in ipairs(self.m_vMembers) do
    member.effect:setPosition(cc.pAdd(cc.p(self:getPosition()), member.pos))
    parent:addChild(member.effect, self:getLocalZOrder() + member.zorder)
  end
  self:UpdateTargetPos()
  self.m_bIsEntered = true
end
function EffectBase:onExit()
  if self.m_endCallback then
    self.m_endCallback()
  end
  self:ClearAllAttribute()
  self:RemoveMembers()
end
function EffectBase:Update(dt)
  if self:IsRemove() then
    return
  end
  local bAllAttrOver = true
  local lastPos = cc.p(self:getPosition())
  for i, v in ipairs(self.m_vAttributes) do
    if not v:IsActive() then
      v:Active()
    end
    if not v:IsRemove() then
      v:Update(dt)
    end
    if bAllAttrOver and not v:IsOver() then
      bAllAttrOver = false
    end
    if not v:IsExecuteNextAttribute() then
      break
    end
  end
  if bAllAttrOver then
    local mapId = require("app.GameDataManager").GetInstance():GetGameMapInfo().id
    self.m_bAllAttrOver = true
    if self.m_bAttrOverRemoveSelf then
      self:SetRemove()
      return
    end
  end
  if not cc.pFuzzyEqual(cc.p(self:getPosition()), lastPos, 0) then
    self.m_direction = cc.pNormalize(cc.pSub(cc.p(self:getPosition()), lastPos))
  end
  if self.m_eZorderType == EffectBase.ZType.Y then
    local pMap = GameDataManager:GetInstance():GetGameMap()
    self:setLocalZOrder(pMap:GetPiexlSize().height - self:getPositionY())
  end
  for i, member in ipairs(self.m_vMembers) do
    if not member.noPos then
      local nowPos = cc.p(self:getPosition())
      local posDt = cc.pSub(nowPos, lastPos)
      member.effect:setPosition(cc.pAdd(cc.p(member.effect:getPosition()), posDt))
      member.m_direction = self.m_direction
    end
    if not member.noRotate then
      member.effect:setRotation(self:getRotation())
    end
  end
end
function EffectBase:UpdateTargetPos()
  local targetActor = self:GetTargetActor()
  if targetActor then
    if self.m_targetActorPos == nil then
      self.m_targetActorPos = targetActor:GetBeHitPos()
    elseif not targetActor:IsDead() and targetActor:GetType() ~= td.ActorType.Home then
      self.m_targetActorPos = targetActor:GetBeHitPos()
    end
  elseif self.m_targetActorPos == nil then
    self.m_targetActorPos = cc.p(self:getPosition())
  end
  return clone(self.m_targetActorPos)
end
function EffectBase:AddAttribute(pAttribute)
  table.insert(self.m_vAttributes, pAttribute)
end
function EffectBase:RemoveAttribute(pAttribute)
  table.removebyvalue(self.m_vAttributes, pAttribute, true)
end
function EffectBase:RemoveAttributeByType(attributeType)
  for k, value in ipairs(self.m_vAttributes) do
    if value:GetType() == attributeType then
      value:SetRemove(true)
      break
    end
  end
end
function EffectBase:GetAttributeByType(attributeType)
  for _, value in ipairs(self.m_vAttributes) do
    if value:GetType() == attributeType then
      return value
    end
  end
  return nil
end
function EffectBase:ClearAllAttribute()
  self.m_vAttributes = {}
end
function EffectBase:IsAllAttributeOver()
  return self.m_bAllAttrOver
end
function EffectBase:GetID()
  return self.m_iID
end
function EffectBase:GetType()
  return self.m_eType
end
function EffectBase:SetRemove()
  self.m_bRemove = true
  require("app.trigger.TriggerManager").GetInstance():SendEvent({
    eType = td.ConditionType.EffectEnd,
    effectID = self:GetID()
  })
end
function EffectBase:IsRemove()
  return self.m_bRemove
end
function EffectBase:IsAutoRemove()
  return self.m_bAttrOverRemoveSelf
end
function EffectBase:SetSelfActorParams(params)
  self.m_pActorParams = params
end
function EffectBase:GetSelfActorParams()
  return self.m_pActorParams
end
function EffectBase:GetSelfActor()
  local ActorManager = require("app.actor.ActorManager")
  return ActorManager:GetInstance():FindActorByTag(self.m_iSelfActorTag)
end
function EffectBase:SetTargetActor(pActor)
  if pActor then
    self.m_iTargetActorTag = pActor:getTag()
  end
end
function EffectBase:GetTargetActor()
  local ActorManager = require("app.actor.ActorManager")
  return ActorManager:GetInstance():FindActorByTag(self.m_iTargetActorTag)
end
function EffectBase:SetEndCallback(cb)
  self.m_endCallback = cb
end
function EffectBase:SetClickCallback(cb)
  self.m_clickCallback = cb
end
function EffectBase:OnClicked()
  if self.m_clickCallback then
    self.m_clickCallback()
  end
end
function EffectBase:GetBindingBone()
  return self.m_pBindingBone
end
function EffectBase:GetActorColor()
  return self.m_pActorColor
end
function EffectBase:GetActorScale()
  return self.m_pActorScale
end
function EffectBase:SetSkill(pSkill)
  self.m_pSkill = pSkill
end
function EffectBase:GetSkill()
  return self.m_pSkill
end
function EffectBase:GetBoundingBox()
  local rect
  if self.m_pSkill then
    local px, py = self:getPosition()
    local width, height = self.m_pSkill:GetDamageRange()
    rect = cc.rect(px - width / 2, py - height / 2, width, height)
  else
    rect = self:getBoundingBox()
  end
  return rect
end
function EffectBase:GetDirection()
  return self.m_direction
end
function EffectBase:IsEntered()
  return self.m_bIsEntered
end
function EffectBase:Reset()
  for i, v in ipairs(self.m_vAttributes) do
    v:Reset()
  end
end
function EffectBase:AddToActor(target, zorder, tag)
  local boneName = self:GetBindingBone()
  if boneName then
    local boneNode = target:FindBoneNode(boneName)
    if boneNode then
      boneNode:addChild(self, zorder or self:getLocalZOrder(), tag or self:getTag())
      return
    end
  end
  local boneNode = target:FindBoneNode("root")
  if boneNode then
    boneNode:addChild(self, zorder or self:getLocalZOrder(), tag or self:getTag())
    return
  end
  target:addChild(self, zorder or self:getLocalZOrder(), tag or self:getTag())
end
function EffectBase:AddToMap(pMap, zorder, tag)
  if not zorder then
    if self.m_eZorderType == EffectBase.ZType.Y then
      zorder = pMap:GetPiexlSize().height - self:getPositionY()
    elseif self.m_eZorderType == EffectBase.ZType.Top then
      zorder = td.InMapZOrder.Top
    elseif self.m_eZorderType == EffectBase.ZType.Bottom then
      zorder = td.InMapZOrder.Bottom
    end
  end
  pMap:addChild(self, zorder or self:getLocalZOrder(), tag or self:getTag())
end
function EffectBase:AddMembers(memberInfo)
  if not memberInfo then
    return
  end
  local EffectManager = require("app.effect.EffectManager")
  local effMng = EffectManager:GetInstance()
  for i, v in ipairs(memberInfo) do
    local count = v.count or 1
    for i = 1, count do
      local member = {}
      member.effect = effMng:CreateEffect(v.id)
      if member.effect then
        member.id = v.id
        member.noPos = v.noPos
        member.noRotate = v.noRotate
        member.zorder = v.zorder
        member.delayRemove = v.delayRemove
        if v.posRange then
          local x, y = v.posRange.x, v.posRange.y
          member.pos = cc.p(math.random(x) - x / 2, math.random(y) - y / 2)
        else
          local x = v.x or 0
          local y = v.y or 0
          member.pos = cc.p(x, y)
        end
        member.effect:retain()
        table.insert(self.m_vMembers, member)
      end
    end
  end
end
function EffectBase:RemoveMembers()
  for i, member in ipairs(self.m_vMembers) do
    if member.delayRemove then
      member.effect:performWithDelay(function()
        member.effect:SetRemove()
      end, member.delayRemove)
      if member.effect:GetType() == td.EffectType.Particle and member.effect:GetContentNode() then
        member.effect:GetContentNode():stopSystem()
      end
    else
      member.effect:SetRemove()
    end
    member.effect:release()
  end
  self.m_vMembers = {}
end
function EffectBase:GetContentSize()
  return cc.size(1, 1)
end
function EffectBase:GetBoundingBox()
  return self:getBoundingBox()
end
function EffectBase:GetContentNode()
  return self.m_pContentNode
end
return EffectBase
