local GameControl = require("app.GameControl")
require("app.config.EffectConfig")
local EffectManager = class("EffectManager", GameControl)
EffectManager.instance = nil
function EffectManager:ctor(eType)
  EffectManager.super.ctor(self, eType)
  self:Init()
end
function EffectManager:GetInstance()
  if EffectManager.instance == nil then
    EffectManager.instance = EffectManager.new(td.GameControlType.EnterMap)
  end
  return EffectManager.instance
end
function EffectManager:Init()
  self.m_vLogTime = {}
  self.m_vEffects = {}
  self.m_bPause = false
end
function EffectManager:ClearValue()
  self:ClearAllEffect()
  self:Init()
end
function EffectManager:CreateEffect(iID, pSelfActor, pTargetActor, pos)
  pos = pos or cc.p(0, 0)
  local pEffectInfo = GetEffectConfig(iID)
  if nil == pEffectInfo then
    return nil
  end
  local iSelfActorTag = pSelfActor and pSelfActor:getTag() or nil
  local iTargetActorTag = pTargetActor and pTargetActor:getTag() or nil
  local pEffect
  if pEffectInfo.type == td.EffectType.Spine then
    if iID == 83 then
      local AirshipEffect = require("app.effect.AirshipEffect")
      pEffect = AirshipEffect.new(iSelfActorTag, iTargetActorTag, pEffectInfo)
    elseif iID == 114 then
      local ClickBombEffect = require("app.effect.ClickBombEffect")
      pEffect = ClickBombEffect.new(iSelfActorTag, iTargetActorTag, pEffectInfo)
    else
      local SpineEffect = require("app.effect.SpineEffect")
      pEffect = SpineEffect.new(iSelfActorTag, iTargetActorTag, pEffectInfo)
    end
  elseif pEffectInfo.type == td.EffectType.Particle then
    local ParticleEffect = require("app.effect.ParticleEffect")
    pEffect = ParticleEffect.new(iSelfActorTag, iTargetActorTag, pEffectInfo)
  elseif pEffectInfo.type == td.EffectType.Image then
    local ImageEffect = require("app.effect.ImageEffect")
    pEffect = ImageEffect.new(iSelfActorTag, iTargetActorTag, pEffectInfo)
  elseif pEffectInfo.type == td.EffectType.Frames then
    local FrameEffect = require("app.effect.FrameEffect")
    pEffect = FrameEffect.new(iSelfActorTag, iTargetActorTag, pEffectInfo)
  end
  if nil ~= pEffect then
    if pSelfActor then
      pEffect:SetSelfActorParams(td.CreateActorParams(pSelfActor))
    end
    pEffect:setPosition(pos)
    if type(pEffectInfo.scale) == "table" then
      pEffect:setScaleX(pEffectInfo.scale.x)
      pEffect:setScaleY(pEffectInfo.scale.y)
    else
      pEffect:setScale(pEffectInfo.scale)
    end
    self:CreateAttribute(pEffect, pEffectInfo)
    pEffect:retain()
    table.insert(self.m_vEffects, pEffect)
    return pEffect
  end
  return nil
end
function EffectManager:GetEffectById(effectId)
  for _, value in ipairs(self.m_vEffects) do
    if effectId == value:GetID() then
      return value
    end
  end
  return nil
end
function EffectManager:RemoveEffect(pEffect)
  pEffect:SetRemove(true)
end
function EffectManager:RemoveEffectForID(id)
  for i, v in ipairs(self.m_vEffects) do
    if v:GetID() == id then
      v:SetRemove(true)
    end
  end
end
function EffectManager:ClearAllEffect()
  for i, v in ipairs(self.m_vEffects) do
    v:removeFromParent()
  end
  self.m_vEffects = {}
end
function EffectManager:Update(dt)
  if self.m_bPause then
    return
  end
  local i = #self.m_vEffects
  while i > 0 do
    local v = self.m_vEffects[i]
    if v and v:IsRemove() then
      if v:getParent() then
        v:removeFromParent()
      end
      table.remove(self.m_vEffects, i)
      v:release()
    end
    i = i - 1
  end
  for i, v in ipairs(self.m_vEffects) do
    if v:IsEntered() then
      v:Update(dt)
    end
  end
end
function EffectManager:CreateAttribute(pEffect, pInfo)
  if not pInfo.attrs then
    return
  end
  for i, v in ipairs(pInfo.attrs) do
    local pAttributeBase, pos
    if v.x and v.y then
      pos = cc.p(v.x, v.y)
    end
    if v.type == td.AttributeType.Move then
      local MoveAttribute = require("app.effect.attribute.MoveAttribute")
      pAttributeBase = MoveAttribute.new(pEffect, v.timeNext, v.moveType, v.speed, pos, v.rotate, v.random, v.acc, v.adjustDir)
    elseif v.type == td.AttributeType.Attack then
      local AttackAttribute = require("app.effect.attribute.AttackAttribute")
      pAttributeBase = AttackAttribute.new(pEffect, v.timeNext, v.damage, v.fixedDamage)
    elseif v.type == td.AttributeType.RangeAttack then
      local RangeAttackAttribute = require("app.effect.attribute.RangeAttackAttribute")
      pAttributeBase = RangeAttackAttribute.new(pEffect, v.timeNext, v.damage, v.fixedDamage, v.width, v.height)
    elseif v.type == td.AttributeType.Animate then
      local AnimateAttribute = require("app.effect.attribute.AnimateAttribute")
      pAttributeBase = AnimateAttribute.new(pEffect, v.timeNext, v.animation, v.loop, v.random, v.cnt, v.frames)
    elseif v.type == td.AttributeType.Place then
      local PlaceAttribute = require("app.effect.attribute.PlaceAttribute")
      pAttributeBase = PlaceAttribute.new(pEffect, v.timeNext, v.placeType, pos, v.range)
    elseif v.type == td.AttributeType.Fade then
      local FadeAttribute = require("app.effect.attribute.FadeAttribute")
      pAttributeBase = FadeAttribute.new(pEffect, v.timeNext, v.time, v.fromOpacity, v.toOpacity)
    elseif v.type == td.AttributeType.Collide then
      local CollideAttribute = require("app.effect.attribute.CollideAttribute")
      pAttributeBase = CollideAttribute.new(pEffect, v.timeNext, v.groupType, v.overType, v.value, v.width, v.height)
    elseif v.type == td.AttributeType.RemoveEffect then
      local RemoveEffectAttribute = require("app.effect.attribute.RemoveEffectAttribute")
      pAttributeBase = RemoveEffectAttribute.new(pEffect, v.timeNext, v.id)
    elseif v.type == td.AttributeType.Parabola then
      local ParabolaAttribute = require("app.effect.attribute.ParabolaAttribute")
      local ccpRandom = cc.p(v.randX or 0, v.randY or 0)
      pAttributeBase = ParabolaAttribute.new(pEffect, v.timeNext, v.fixedType, v.value, v.rotate, pos, v.moveType, ccpRandom, v.gravity)
    elseif v.type == td.AttributeType.Visible then
      local VisibleAttribute = require("app.effect.attribute.VisibleAttribute")
      pAttributeBase = VisibleAttribute.new(pEffect, v.timeNext, v.visible)
    elseif v.type == td.AttributeType.Delay then
      local DelayAttribute = require("app.effect.attribute.DelayAttribute")
      pAttributeBase = DelayAttribute.new(pEffect, v.timeNext, v.range)
    elseif v.type == td.AttributeType.Revolve then
      local RevolveAttribute = require("app.effect.attribute.RevolveAttribute")
      pAttributeBase = RevolveAttribute.new(pEffect, v.timeNext, v.revolveType, v.speed, v.angle, pos, v.rotate)
    elseif v.type == td.AttributeType.Turn then
      local TurnAttribute = require("app.effect.attribute.TurnAttribute")
      pAttributeBase = TurnAttribute.new(pEffect, v.timeNext, v.speed, v.radius, v.rotate)
    elseif v.type == td.AttributeType.SinMove then
      local SinMoveAttribute = require("app.effect.attribute.SinMoveAttribute")
      pAttributeBase = SinMoveAttribute.new(pEffect, v.timeNext, v.speed, pos, v.rotate)
    elseif v.type == td.AttributeType.NewEffect then
      local NewEffectAttribute = require("app.effect.attribute.NewEffectAttribute")
      pAttributeBase = NewEffectAttribute.new(pEffect, v.timeNext, v.newID, v.inherit, v.zorder, v.count)
    elseif v.type == td.AttributeType.Rotate then
      local RotateAttribute = require("app.effect.attribute.RotateAttribute")
      pAttributeBase = RotateAttribute.new(pEffect, v.timeNext, v.rotateType, v.angle, v.speed)
    elseif v.type == td.AttributeType.Link then
      local LinkAttribute = require("app.effect.attribute.LinkAttribute")
      pAttributeBase = LinkAttribute.new(pEffect, v.timeNext, v.baseBone, v.targetBone, v.offset)
    elseif v.type == td.AttributeType.Follow then
      local FollowAttribute = require("app.effect.attribute.FollowAttribute")
      pAttributeBase = FollowAttribute.new(pEffect, v.timeNext, v.zorder, v.time, v.offsetX, v.offsetY, v.bTarget)
    elseif v.type == td.AttributeType.Scale then
      local ScaleAttribute = require("app.effect.attribute.ScaleAttribute")
      pAttributeBase = ScaleAttribute.new(pEffect, v.timeNext, v.scaleType, v.time, v.x, v.y)
    elseif v.type == td.AttributeType.Track then
      local TrackAttribute = require("app.effect.attribute.TrackAttribute")
      pAttributeBase = TrackAttribute.new(pEffect, v.timeNext, v.speed, v.rotate, v.refind, v.random)
    elseif v.type == td.AttributeType.PathTrack then
      local PathTrackAttribute = require("app.effect.attribute.PathTrackAttribute")
      pAttributeBase = PathTrackAttribute.new(pEffect, v.timeNext, v.speed, v.rotate, v.refind)
    elseif v.type == td.AttributeType.Click then
      local ClickAttribute = require("app.effect.attribute.ClickAtrribute")
      pAttributeBase = ClickAttribute.new(pEffect, v.timeNext, v)
    elseif v.type == td.AttributeType.OverAchievement then
      local AddAchievementAttribute = require("app.effect.attribute.AddAchievementAttribute")
      pAttributeBase = AddAchievementAttribute.new(pEffect, v.timeNext, v)
    elseif v.type == td.AttributeType.TurnAuto then
      local TurnAutoAttribute = require("app.effect.attribute.TurnAutoAttribute")
      pAttributeBase = TurnAutoAttribute.new(pEffect, v.timeNext, v)
    elseif v.type == td.AttributeType.AnimSwitch then
      local AnimateSwitchAttribute = require("app.effect.attribute.AnimateSwitchAttribute")
      pAttributeBase = AnimateSwitchAttribute.new(pEffect, v.timeNext, v)
    elseif v.type == td.AttributeType.RemoveAttri then
      local RemoveAttribute = require("app.effect.attribute.RemoveAttribute")
      pAttributeBase = RemoveAttribute.new(pEffect, v.timeNext, v)
    elseif v.type == td.AttributeType.Sleep then
      local SleepAttribute = require("app.effect.attribute.SleepAttribute")
      pAttributeBase = SleepAttribute.new(pEffect, v.timeNext, v)
    elseif v.type == td.AttributeType.Walk then
      local WalkAttribute = require("app.effect.attribute.WalkAttribute")
      pAttributeBase = WalkAttribute.new(pEffect, v.timeNext, v)
    elseif v.type == td.AttributeType.SendPyramidState then
      local SendPyraidStateAttribute = require("app.effect.attribute.SendPyraidStateAttribute")
      pAttributeBase = SendPyraidStateAttribute.new(pEffect, v.timeNext, v)
    elseif v.type == td.AttributeType.AnimateOther then
      local AnimateOtherAttribute = require("app.effect.attribute.AnimateOtherAttribute")
      pAttributeBase = AnimateOtherAttribute.new(pEffect, v.timeNext, v)
    elseif v.type == td.AttributeType.PlaySound then
      local SoundPlayAttribute = require("app.effect.attribute.SoundPlayAttribute")
      pAttributeBase = SoundPlayAttribute.new(pEffect, v.timeNext, v.sound, v.loop)
    elseif v.type == td.AttributeType.StopSound then
      local SoundStopAttribute = require("app.effect.attribute.SoundStopAttribute")
      pAttributeBase = SoundStopAttribute.new(pEffect, v.timeNext)
    elseif v.type == td.AttributeType.Talk then
      local TalkAttribute = require("app.effect.attribute.TalkAttribute")
      pAttributeBase = TalkAttribute.new(pEffect, v.timeNext, v)
    end
    if nil ~= pAttributeBase then
      pAttributeBase:SetTag(v.tag)
      pEffect:AddAttribute(pAttributeBase)
    end
  end
end
function EffectManager:SetPause(bPause)
  self.m_bPause = bPause
end
function EffectManager:IsPause()
  return self.m_bPause
end
function EffectManager.GetEffectRes(iID, supEffectId)
  local vRes, vSounds = {}, {}
  local pEffectInfo = GetEffectConfig(iID)
  if pEffectInfo then
    local res = {}
    res.type = pEffectInfo.type
    res.file = pEffectInfo.file
    table.insert(vRes, res)
    if pEffectInfo.members then
      for i, member in ipairs(pEffectInfo.members) do
        local subRes, subSound = EffectManager.GetEffectRes(member.id, iID)
        for j, res in ipairs(subRes) do
          table.insert(vRes, res)
        end
        for j, sound in ipairs(subSound) do
          table.insert(vSounds, sound)
        end
      end
    end
    for i, attr in ipairs(pEffectInfo.attrs) do
      if attr.type == td.AttributeType.NewEffect then
        if attr.newID ~= iID and attr.newID ~= supEffectId then
          local subRes, subSound = EffectManager.GetEffectRes(attr.newID, iID)
          for j, res in ipairs(subRes) do
            table.insert(vRes, res)
          end
          for j, sound in ipairs(subSound) do
            table.insert(vSounds, sound)
          end
        end
      elseif attr.type == td.AttributeType.PlaySound then
        table.insert(vSounds, attr.sound)
      end
    end
  end
  return vRes, vSounds
end
function EffectManager:LogTime()
  if table.nums(self.m_vLogTime) > 0 then
    dump(self.m_vLogTime)
  end
end
return EffectManager
