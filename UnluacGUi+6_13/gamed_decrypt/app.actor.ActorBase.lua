local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local s_setPosition
local ActorBase = class("ActorBase", function()
  local node = display.newNode()
  s_setPosition = node.setPosition
  return node
end)
function ActorBase:ctor(eType, strFileName)
  self.m_eType = eType
  self.m_Id = 0
  self.m_eGroupType = -1
  self.m_bRemove = false
  self.m_bAttack = true
  self.m_bAttacked = true
  self.m_bHurtless = false
  self.m_iTrapped = 0
  self.m_bIsHex = false
  self.m_bIsZombie = false
  self.m_bIsPeace = false
  self.m_bIsHiding = false
  self.m_bIsCharmed = false
  self.m_bIsTaunted = false
  self.m_bBeingHitback = false
  self.m_eBehaveType = td.BehaveType.Non
  self.m_iSkillCDVary = 0
  self.m_iSkillRatioVary = 0
  self.m_bIsNothingnessState = false
  self.m_pSkeleton = nil
  self.m_strSkeletonFile = strFileName
  self.m_bHaveZBMRun = false
  self.m_relativeScale = 1
  self.m_pEnemy = nil
  self.m_iEnemyTag = nil
  self.m_iAttackActorNum = 0
  self.m_vColors = {}
  self.m_vBuffEffects = {}
  self.m_bIsInScene = false
  self:CreateAnimation(strFileName)
  self:setNodeEventEnabled(true)
  self.m_home = ActorManager:GetInstance():FindHome(false)
end
function ActorBase:onEnter()
  self.m_bIsInScene = true
end
function ActorBase:onExit()
  self.m_bIsInScene = false
  if self.m_vBuffEffects then
    for key, var in pairs(self.m_vBuffEffects) do
      local pEffect = var.effect
      if not pEffect:IsAutoRemove() then
        pEffect:release()
      end
    end
  end
end
function ActorBase:Update(dt)
end
function ActorBase:PlayAnimation(aniName, isLoop, callback, eType)
  if isLoop == nil then
    isLoop = true
  end
  if self.m_pSkeleton then
    if not self:FindAnimation(aniName) then
      if callback then
        callback()
      end
      print("Animation: '" .. aniName .. "' not found")
      return
    end
    if callback then
      eType = eType or sp.EventType.ANIMATION_COMPLETE
      self.m_pSkeleton:registerSpineEventHandler(function(event)
        if event.animation == aniName then
          callback()
        end
      end, eType)
    end
    self.m_pSkeleton:PlayAni(aniName, isLoop, false)
  end
end
function ActorBase:PlayAnimations(animations)
  if not self.m_pSkeleton then
    return
  end
  for i, var in ipairs(animations) do
    if self:FindAnimation(var.aniName) then
      if var.callback then
        self.m_pSkeleton:registerSpineEventHandler(function(event)
          if event.animation == var.aniName then
            var.callback()
          end
        end, sp.EventType.ANIMATION_COMPLETE)
      end
      self.m_pSkeleton:PlayAni(var.aniName, var.isLoop, true)
    else
      print("Animation: '" .. var.aniName .. "' not found")
    end
  end
end
function ActorBase:Transform()
end
function ActorBase:CreateAnimation(strFileName)
  strFileName = strFileName or self.m_strSkeletonFile
  self:RemoveAnimation()
  self.m_pSkeleton = SkeletonUnit:create(strFileName)
  if self.m_pSkeleton then
    self.m_pSkeleton:setPositionX(self:getContentSize().width / 2)
    self:addChild(self.m_pSkeleton)
    self.m_bHaveZBMRun = self:FindAnimation("ZMrun")
  end
end
function ActorBase:SetTimeScale(scale)
  if self.m_pSkeleton then
    self.m_pSkeleton:setTimeScale(scale)
  end
end
function ActorBase:FindAnimation(strAnimationName)
  if self.m_pSkeleton == nil then
    return false
  end
  return self.m_pSkeleton:FindAnimation(strAnimationName)
end
function ActorBase:RemoveAnimation()
  if self.m_pSkeleton then
    self:removeChild(self.m_pSkeleton)
    self.m_pSkeleton = nil
  end
end
function ActorBase:FindEnemy(excludeActor)
  local vec = {}
  local eGroupType = self:GetGroupType()
  if eGroupType == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetEnemyVec()
  else
    vec = ActorManager:GetInstance():GetSelfVec()
  end
  local selfType = self:GetType()
  local minDis = -1
  local enemyKey = 0
  local bFindHome = false
  local bFindFangYuTa = false
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local mapType = pMap:GetMapType()
  for key, v in pairs(vec) do
    if self:_CheckCanBeEnemy(v, excludeActor) then
      local enemyType = v:GetType()
      if enemyType == td.ActorType.Hero or enemyType == td.ActorType.Monster or enemyType == td.ActorType.Door or enemyType == td.ActorType.SummonUnit then
        local isIn, disSQ = self:IsInViewRange(v)
        if isIn then
          if enemyKey == 0 or bFindHome or bFindFangYuTa then
            minDis = disSQ
            enemyKey = key
            bFindHome = false
            bFindFangYuTa = false
          else
            local dis = disSQ
            if minDis > dis then
              minDis = dis
              enemyKey = key
            end
          end
        end
      elseif enemyType == td.ActorType.Soldier then
        local b = true
        if mapType ~= td.MapType.PVP and mapType ~= td.MapType.PVPGuild and mapType ~= td.MapType.Rob and mapType ~= td.MapType.Trial then
          b = selfType == td.ActorType.Monster and v:GetAttackActorNum() < 3 or selfType ~= td.ActorType.Monster
        end
        if b then
          local isIn, disSQ = self:IsInViewRange(v)
          if isIn then
            if enemyKey == 0 or bFindHome or bFindFangYuTa then
              minDis = disSQ
              enemyKey = key
              bFindHome = false
              bFindFangYuTa = false
            else
              local dis = disSQ
              if minDis > dis then
                minDis = dis
                enemyKey = key
              end
            end
          end
        end
      elseif enemyType == td.ActorType.FangYuTa then
        if minDis == -1 or bFindHome then
          local isIn, disSQ = self:IsInViewRange(v)
          if isIn then
            if enemyKey == 0 then
              minDis = disSQ
              enemyKey = key
            else
              local dis = disSQ
              if minDis > dis then
                minDis = dis
                enemyKey = key
              end
            end
            bFindFangYuTa = true
          end
        end
      elseif enemyType == td.ActorType.Home and minDis == -1 and self.m_eBehaveType ~= td.BehaveType.Collect and self.m_eBehaveType ~= td.BehaveType.UFO then
        local isIn, disSQ = self:IsInViewRange(v)
        if isIn then
          if enemyKey == 0 then
            minDis = disSQ
            enemyKey = key
          else
            local dis = disSQ
            if minDis > dis then
              minDis = dis
              enemyKey = key
            end
          end
          bFindHome = true
        end
      end
    end
  end
  if enemyKey ~= 0 then
    local pEnemy = vec[enemyKey]
    if self.m_eBehaveType == td.BehaveType.Defend then
      self:CallAssist(pEnemy)
    end
    return pEnemy
  end
  return nil
end
function ActorBase:IsInViewRange(pActor)
  return false
end
function ActorBase:_CheckCanBeEnemy(pActor, excludeActor)
  if self == pActor or pActor == excludeActor then
    return false
  end
  if not pActor:IsCanAttacked() then
    return false
  end
  if self:GetGroupType() == td.GroupType.Enemy and self.m_home and self.m_home ~= pActor and self.m_home:IsInEllipse(cc.p(pActor:getPosition())) then
    return false
  end
  if self:GetCareerType() == td.CareerType.Saber and pActor:GetCareerType() == td.CareerType.Fly then
    return false
  end
  return true
end
function ActorBase:CallAssist(pEnemy)
  if self:IsCharmed() then
    return
  end
  if self.m_eType ~= td.ActorType.Soldier and self.m_eType ~= td.ActorType.Hero then
    return
  end
  local helpDisSQ = self.m_pData.call_range * self.m_pData.call_range
  local enemyPos = cc.p(pEnemy:getPosition())
  local eGroupType = self:GetGroupType()
  local vec = {}
  if eGroupType == td.GroupType.Self then
    vec = ActorManager:GetInstance():GetSelfVec()
  elseif eGroupType == td.GroupType.Enemy then
    vec = ActorManager:GetInstance():GetEnemyVec()
  end
  for key, v in pairs(vec) do
    if v:GetType() == td.ActorType.Soldier and v ~= self and not v:IsCharmed() then
      local disSQ = cc.pDistanceSQ(cc.p(self:getPosition()), cc.p(v:getPosition()))
      if helpDisSQ >= disSQ and v:GetEnemy() == nil then
        v:SetEnemy(pEnemy)
        v:SetTempTargetPos(enemyPos)
        v:ChangeState(td.StateType.Guard)
      end
    end
  end
end
function ActorBase:registerSpineEventHandler(spineCallBack, eventType)
  self.m_pSkeleton:registerSpineEventHandler(spineCallBack, eventType)
end
function ActorBase:SetID(id)
  self.m_Id = id
end
function ActorBase:GetID()
  return self.m_Id
end
function ActorBase:SetType(eType)
  self.m_eType = eType
end
function ActorBase:GetType()
  return self.m_eType
end
function ActorBase:SetGroupType(eType)
  self.m_eGroupType = eType
end
function ActorBase:GetGroupType()
  local eGroupType = self.m_eGroupType
  if self.m_eGroupType == td.GroupType.Self then
    if self.m_bIsCharmed then
      eGroupType = td.GroupType.Enemy
    else
      eGroupType = td.GroupType.Self
    end
  elseif self.m_bIsCharmed then
    eGroupType = td.GroupType.Self
  else
    eGroupType = td.GroupType.Enemy
  end
  return eGroupType
end
function ActorBase:GetRealGroupType()
  return self.m_eGroupType
end
function ActorBase:SetRemove(bRemove)
  self.m_bRemove = bRemove
end
function ActorBase:IsRemove()
  return self.m_bRemove
end
function ActorBase:IsInScene()
  return self.m_bIsInScene
end
function ActorBase:SetCanAttack(bAttack)
  self.m_bAttack = bAttack
end
function ActorBase:IsCanAttack()
  return self.m_bAttack and not self:IsTrapped()
end
function ActorBase:SetCanAttacked(bAttacked)
  self.m_bAttacked = bAttacked
end
function ActorBase:IsCanAttacked()
  return self.m_bAttacked and not self:IsRemove()
end
function ActorBase:SetTrapped(bTrapped)
  self.m_iTrapped = bTrapped and self.m_iTrapped + 1 or self.m_iTrapped - 1
end
function ActorBase:IsTrapped()
  return self.m_iTrapped > 0
end
function ActorBase:SetIsHex(b)
  self.m_bIsHex = b
end
function ActorBase:IsHex()
  return self.m_bIsHex
end
function ActorBase:SetIsZombie(b)
  self.m_bIsZombie = b
end
function ActorBase:IsZombie()
  return self.m_bIsZombie
end
function ActorBase:SetBeingHitback(bHitback)
  self.m_bBeingHitback = bHitback
end
function ActorBase:IsBeingHitback()
  return self.m_bBeingHitback
end
function ActorBase:SetHurtless(bHurtless)
  self.m_bHurtless = bHurtless
end
function ActorBase:IsHurtless()
  return self.m_bHurtless
end
function ActorBase:SetIsPeace(bPeace)
  self.m_bIsPeace = bPeace
end
function ActorBase:IsPeace()
  return self.m_bIsPeace
end
function ActorBase:SetIsHiding(bHiding)
  self.m_bIsHiding = bHiding
end
function ActorBase:IsHiding()
  return self.m_bIsHiding
end
function ActorBase:SetIsCharmed(bCharmed)
  self.m_bIsCharmed = bCharmed
end
function ActorBase:IsCharmed()
  return self.m_bIsCharmed
end
function ActorBase:SetIsTaunted(bTaunted)
  self.m_bIsTaunted = bTaunted
end
function ActorBase:IsTaunted()
  return self.m_bIsTaunted
end
function ActorBase:SetSkillCDVary(iVary)
  self.m_iSkillCDVary = self.m_iSkillCDVary + iVary
end
function ActorBase:GetSkillCDVary()
  return self.m_iSkillCDVary
end
function ActorBase:SetSkillRatioVary(iVary)
  self.m_iSkillRatioVary = self.m_iSkillRatioVary + iVary
end
function ActorBase:SetIsNothingnessState(state)
  self.m_bIsNothingnessState = state
end
function ActorBase:IsNothingnessState()
  return self.m_bIsNothingnessState
end
function ActorBase:GetSkillRatioVary()
  return self.m_iSkillRatioVary
end
function ActorBase:GetEnemy()
  return ActorManager:GetInstance():FindActorByTag(self.m_iEnemyTag)
end
function ActorBase:SetEnemy(pEnemy)
  local curEnemy = self:GetEnemy()
  if curEnemy == pEnemy then
    return
  end
  if pEnemy and self:GetCareerType() == td.CareerType.Saber and pEnemy:GetCareerType() == td.CareerType.Fly then
    return
  end
  if curEnemy then
    curEnemy:DecAttackActorNum()
    self.m_iEnemyTag = nil
  end
  if pEnemy then
    pEnemy:AddAttackActorNum()
    self.m_iEnemyTag = pEnemy:getTag()
  end
end
function ActorBase:AddAttackActorNum()
  self.m_iAttackActorNum = self.m_iAttackActorNum + 1
end
function ActorBase:DecAttackActorNum()
  self.m_iAttackActorNum = self.m_iAttackActorNum - 1
end
function ActorBase:GetAttackActorNum()
  return self.m_iAttackActorNum
end
function ActorBase:GetCareerType()
  return td.CareerType.Non
end
function ActorBase:OnDead()
end
function ActorBase:OnKillEnemy(enemyTag)
end
function ActorBase:GetAttackValue()
  return 0
end
function ActorBase:GetContentSize()
  if self.m_pSkeleton then
    return self.m_pSkeleton:GetContentSize()
  else
    return cc.size(0, 0)
  end
end
function ActorBase:FindBoneNode(boneName)
  if self.m_pSkeleton then
    return self.m_pSkeleton:FindBoneNode(boneName)
  end
  return nil
end
function ActorBase:FindBonePos(boneName)
  if self.m_pSkeleton then
    local bonePos = self.m_pSkeleton:FindBonePos(boneName)
    local scaleX = self:getScaleX() * self.m_pSkeleton:getScaleX()
    local scaleY = self:getScaleY() * self.m_pSkeleton:getScaleY()
    bonePos = cc.p(bonePos.x * scaleX, bonePos.y * scaleY)
    return bonePos
  end
  return cc.p(0, 0)
end
function ActorBase:GetBeHitPos()
  return cc.pAdd(cc.p(self:getPosition()), self:FindBonePos("bone_beiji"))
end
function ActorBase:SetColor(color)
  if color then
    table.insert(self.m_vColors, color)
    self:setColor(color)
  elseif #self.m_vColors > 0 then
    self:setColor(self.m_vColors[#self.m_vColors])
  end
end
function ActorBase:setColor(color)
  if self.m_pSkeleton then
    self.m_pSkeleton:setColor(color)
  end
end
function ActorBase:UnsetColor(color)
  local count = #self.m_vColors
  for i = count, 1, -1 do
    local c = self.m_vColors[i]
    if c.r == color.r and c.g == color.g and c.b == color.b then
      table.remove(self.m_vColors, i)
      count = count - 1
      break
    end
  end
  if count >= 1 then
    self:setColor(self.m_vColors[count])
  else
    self:setColor(display.COLOR_WHITE)
  end
end
function ActorBase:AddBuffEffect(effectId)
  local buffEffect = self.m_vBuffEffects[effectId]
  if buffEffect then
    buffEffect.count = buffEffect.count + 1
  else
    local EffectManager = require("app.effect.EffectManager")
    local pEffect = EffectManager:GetInstance():CreateEffect(effectId)
    if not pEffect then
      return
    end
    if not pEffect:IsAutoRemove() then
      pEffect:retain()
      buffEffect = {effect = pEffect, count = 1}
      self.m_vBuffEffects[effectId] = buffEffect
    end
    if not self:IsHex() then
      pEffect:AddToActor(self)
      if pEffect:GetActorColor() then
        self:SetColor(pEffect:GetActorColor())
      end
      if pEffect:GetActorScale() then
        self:setScale(self:getScale() * pEffect:GetActorScale())
      end
    end
  end
end
function ActorBase:RemoveBuffEffect(effectId)
  local buffEffect = self.m_vBuffEffects[effectId]
  if buffEffect then
    buffEffect.count = buffEffect.count - 1
    if buffEffect.count == 0 then
      self.m_vBuffEffects[effectId] = nil
      local pEffect = buffEffect.effect
      if pEffect:GetActorColor() then
        self:UnsetColor(pEffect:GetActorColor())
      end
      if pEffect:GetActorScale() then
        self:setScale(self:getScale() / pEffect:GetActorScale())
      end
      pEffect:release()
      pEffect:SetRemove()
    end
  end
end
function ActorBase:ShowBuffEffects()
  for key, buffEffect in pairs(self.m_vBuffEffects) do
    local pEffect = buffEffect.effect
    if not pEffect:getParent() then
      local zOrder = 5
      if pEffect.m_eZorderType < 0 then
        zOrder = pEffect.m_eZorderType
      end
      self:addChild(pEffect, zOrder)
      if pEffect:GetActorColor() then
        self:SetColor(pEffect:GetActorColor())
      end
    end
  end
end
function ActorBase:HideBuffEffects()
  for key, buffEffect in pairs(self.m_vBuffEffects) do
    local pEffect = buffEffect.effect
    if pEffect:getParent() then
      if pEffect:GetActorColor() then
        self:UnsetColor(pEffect:GetActorColor())
      end
      pEffect:removeFromParent()
    end
  end
end
function ActorBase:IsCanBuffed()
  return true
end
function ActorBase:IsCanBeMoved()
  return true
end
function ActorBase:GetDodgeRate()
  return 0
end
function ActorBase:GetHitRate()
  return 100
end
function ActorBase:GetCritRate()
  return 0
end
function ActorBase:GetBehaveType()
  return self.m_eBehaveType
end
function ActorBase:SetBehaveType(_type)
  self.m_eBehaveType = _type
end
function ActorBase:GetRelativeScale()
  return self.m_relativeScale
end
function ActorBase:setPosition(x, y)
  local pos = {}
  if y then
    pos.x = x
    pos.y = y
  else
    pos = x
  end
  s_setPosition(self, pos)
end
return ActorBase
