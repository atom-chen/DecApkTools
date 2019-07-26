local StateManager = require("app.actor.state.StateManager")
local SkillManager = require("app.actor.skill.SkillManager")
local BuffManager = require("app.buff.BuffManager")
local UserDataManager = require("app.UserDataManager")
local GameDataManager = require("app.GameDataManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local ActorBase = import(".ActorBase")
local Actor = class("Actor", ActorBase)
function Actor:ctor(eType, pData)
  Actor.super.ctor(self, eType, pData.image)
  self.m_TempTargetPos = cc.p(-1, -1)
  self.m_FinalTargetPos = cc.p(-1, -1)
  self.m_iCurHp = 0
  self.m_eDirType = td.DirType.Right
  self.m_MoveEndCallback = nil
  self.m_iCurPathCount = 1
  self.m_iPathId = 0
  self.m_bInverted = false
  self.m_iCurSkillID = 0
  self.m_pData = nil
  self.m_PathVec = {}
  self.m_iCareerType = td.CareerType.Non
  self.m_bAttractRes = false
  self.m_iEnterEffect = 2003
  self.m_iEnterDelay = 0
  self.m_canMoveBlockIds = {}
  self.m_attackSound = pData.normal_sound
  self.m_pEnemyAzimuth = 3
  self.m_relativeScale = pData.scale or 1
  self:setScale(0.5 * self.m_relativeScale)
  self:SetData(pData)
  if self.m_pSkeleton then
    local t = string.split(self.m_pData.model, "#")
    self.m_pSkeleton:SetContentSize(tonumber(t[1]), tonumber(t[2]))
  end
  self.m_bYXWave = true
  self.m_bDebug = false
end
function Actor:onEnter()
  Actor.super.onEnter(self)
  self:CreateHPBar()
  self:InitState()
  self:InitSkill()
  self:AddTouch()
  self:PlayEnterAni()
end
function Actor:onExit()
  Actor.super.onExit(self)
  self.m_pSkillManager:OnExit()
  self:RemoveTouch()
end
function Actor:CreateAnimation(strFileName)
  Actor.super.CreateAnimation(self, strFileName)
  if self.m_pSkeleton then
    local function spineCallBack(event)
      if event.eventData.name == "hit" then
        self:GetCurSkill():Hit()
      elseif event.eventData.name == "shoot" then
        self:GetCurSkill():Shoot()
      end
    end
    self.m_pSkeleton:registerSpineEventHandler(spineCallBack, sp.EventType.ANIMATION_EVENT)
  end
end
function Actor:InitState()
end
function Actor:InitSkill()
  self.m_pSkillManager = SkillManager.new(self)
  for i, v in ipairs(self.m_pData.skill) do
    if v ~= 0 then
      local skillInfo
      if self.m_pData.skillInfo then
        skillInfo = self.m_pData.skillInfo[v]
      end
      self.m_pSkillManager:AddSkill(v, nil, skillInfo)
    end
  end
  self.m_pSkillManager:OnEnter()
end
function Actor:PlayEnterAni()
  local pEffect = EffectManager:GetInstance():CreateEffect(self.m_iEnterEffect, nil, nil, cc.p(0, -3))
  if pEffect then
    self:addChild(pEffect, 2)
    if 0 < self.m_iEnterDelay then
      self.m_pSkeleton:setOpacity(0)
      self:performWithDelay(function()
        self.m_pSkeleton:setOpacity(255)
      end, self.m_iEnterDelay)
    end
  end
end
function Actor:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    if GameDataManager:GetInstance():GetActorCanTouch() and not self:IsDead() then
      local size = self:GetContentSize()
      size.width = size.width * self:getScaleX()
      size.height = size.height * self:getScaleY()
      local rect
      if self:GetCareerType() == td.CareerType.Fly then
        local pos = self:GetBeHitPos()
        rect = cc.rect(pos.x - size.width / 2, pos.y - size.height / 2, size.width, size.height)
      else
        local x, y = self:getPosition()
        rect = cc.rect(x - size.width / 2, y, size.width, size.height)
      end
      local pos = _touch:getLocation()
      pos = self:getParent():convertToNodeSpace({
        x = pos.x,
        y = pos.y
      })
      if cc.rectContainsPoint(rect, pos) then
        return true
      end
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    if td.Debug_Tag then
      print("**************start*******************")
      dump(self)
      dump(self.m_pEnemy)
      print("career:" .. self:GetCareerType() .. ",group:" .. self:GetGroupType())
      print("state:" .. self.m_pStateManager:GetCurState():GetType())
      print("max hp:" .. self:GetMaxHp() .. ",hp:" .. self:GetCurHp() .. ",defence:" .. self:GetDefense())
      print("attack sp:" .. self:GetAttackSpeed() .. ",attack:" .. self:GetAttackValue() .. ",crit:" .. self:GetCritRate())
      print("state history:")
      for key, var in ipairs(self.m_pStateManager.m_vHistory) do
        print(var)
      end
      self.m_bDebug = not self.m_bDebug
      print("**************end*******************")
    end
    if GameDataManager:GetInstance():GetActorCanTouch() and not self:IsDead() then
      g_MC:UpdateOpTime()
      GameDataManager:GetInstance():SetFocusNode(self)
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function Actor:RemoveTouch()
  self:getEventDispatcher():removeEventListenersForTarget(self)
end
function Actor:Update(dt)
  Actor.super.Update(self, dt)
  self.m_pSkillManager:Update(dt)
  self.m_pStateManager:Update(dt)
  if self.m_bBeingHitback then
    self.m_PathVec = {}
  end
  if #self.m_PathVec ~= 0 then
    local pos = self.m_PathVec[1]
    local curPos = cc.p(self:getPosition())
    local normalizePos = cc.pNormalize(cc.pSub(pos, curPos))
    local tempPos = cc.pAdd(curPos, cc.pMul(normalizePos, self:GetSpeed() * dt))
    if PulibcFunc:GetInstance():GetDirection(curPos, pos) == PulibcFunc:GetInstance():GetDirection(tempPos, pos) and not cc.pFuzzyEqual(normalizePos, cc.p(0, 0), 0) then
      self:MoveAction(tempPos)
      self:setPosition(tempPos)
    else
      tempPos = pos
      table.remove(self.m_PathVec, 1)
      self:MoveAction(tempPos)
      self:setPosition(tempPos)
      if table.nums(self.m_PathVec) == 0 then
        self.m_MoveEndCallback()
      end
    end
  end
  local pMap = GameDataManager:GetInstance():GetGameMap()
  pMap:reorderChild(self, pMap:GetPiexlSize().height - self:getPositionY())
end
function Actor:ActiveFocus()
  if not self.m_chosenEffect then
    self.m_chosenEffect = EffectManager:GetInstance():CreateEffect(2005)
    self:addChild(self.m_chosenEffect, -1)
  end
end
function Actor:InactiveFocus()
  if self.m_chosenEffect then
    self.m_chosenEffect:SetRemove()
    self.m_chosenEffect = nil
  end
end
function Actor:DoFocus(pos)
  GameDataManager:GetInstance():SetFocusNode(nil)
end
function Actor:PlayAnimation(aniName, isLoop, callback, eType)
  if aniName == "run" or aniName == "BMrun" or aniName == "ZMrun" then
    self.m_pSkeleton:setTimeScale(self.m_pData.move_rate)
  else
    local subAniName = aniName
    if string.find(aniName, "_") then
      subAniName = string.sub(aniName, string.find(aniName, "_"))
    end
    if subAniName == "attack" or subAniName == "skill" or subAniName == "fire" then
      local ratio = 0
      local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
      if buffs[td.BuffType.AtkSpVary_P] then
        for i, v in ipairs(buffs[td.BuffType.AtkSpVary_P]) do
          ratio = ratio + v:GetValue() / 100
        end
      end
      self.m_pSkeleton:setTimeScale(1 + ratio)
    else
      self.m_pSkeleton:setTimeScale(1)
    end
  end
  Actor.super.PlayAnimation(self, aniName, isLoop, callback, eType)
end
function Actor:CreateHPBar()
  local height = self.m_pSkeleton:GetContentSize().height
  local BloodBar = require("app.widgets.BloodBar")
  self.m_pHpBar = BloodBar.new(0, self.m_eGroupType)
  self.m_pHpBar:setScale(1 / self:getScale())
  self.m_pHpBar:setPosition(cc.p(0, height))
  self:addChild(self.m_pHpBar, 10)
end
function Actor:ChangeHp(iHp, isIndirect, attacker)
  if isIndirect == nil then
    isIndirect = false
  end
  if self:IsDead() then
    return true, 0
  end
  iHp = self:_HandleHpWithBuffs(iHp, isIndirect, attacker)
  if iHp == 0 then
    return false, 0
  end
  local oriHp = self.m_iCurHp
  self:SetCurHp(cc.clampf(self.m_iCurHp + iHp, 0, self:GetMaxHp()))
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  if mapType == td.MapType.Trial or mapType == td.MapType.PVP or mapType == td.MapType.PVPGuild then
    td.dispatchEvent(td.ACTOR_CHANGE_HP, {
      group = self:GetRealGroupType(),
      hp = self.m_iCurHp - oriHp
    })
  end
  local bIsDead = false
  if 0 >= self.m_iCurHp then
    bIsDead = true
    self:OnDead(attacker)
    td.dispatchEvent(td.ACTOR_DIED, self:getTag())
  end
  return bIsDead, iHp
end
function Actor:_HandleHpWithBuffs(iHp, isIndirect, attacker)
  if iHp < 0 and self:IsHurtless() then
    return 0
  end
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  if mapType == td.MapType.PVP or mapType == td.MapType.PVPGuild or mapType == td.MapType.Rob then
    iHp = iHp * 0.6
  end
  if iHp < 0 and not isIndirect then
    local meatShield, buffShield
    local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
    if buffs[td.BuffType.MeatShield] and 0 < #buffs[td.BuffType.MeatShield] then
      local buff = buffs[td.BuffType.MeatShield][1]
      meatShield = buff:GetObject()
      buff:OnWork()
    end
    if buffs[td.BuffType.Shield] and 0 < #buffs[td.BuffType.Shield] then
      local buff = buffs[td.BuffType.Shield][1]
      buffShield = buff
      buff:OnWork()
    end
    if buffs[td.BuffType.Shield_P] and 0 < #buffs[td.BuffType.Shield_P] then
      local buff = buffs[td.BuffType.Shield_P][1]
      buffShield = buff
      buff:OnWork()
    end
    if buffs[td.BuffType.HurtGetBuff] and 0 < #buffs[td.BuffType.HurtGetBuff] then
      for i, buff in ipairs(buffs[td.BuffType.HurtGetBuff]) do
        local condition = self:GetMaxHp() * buff:GetValue(2) / 100
        if condition >= self.m_iCurHp and buff:IsTriggered() then
          for j, var in ipairs(buff:GetTriggerBuffId()) do
            BuffManager:GetInstance():AddBuff(self, var, nil)
          end
          buff:OnWork()
        end
      end
    end
    if buffs[td.BuffType.HurtCauseBuff] and 0 < #buffs[td.BuffType.HurtCauseBuff] then
      for i, buff in ipairs(buffs[td.BuffType.HurtCauseBuff]) do
        if attacker and buff:IsTriggered() then
          for j, var in ipairs(buff:GetTriggerBuffId()) do
            BuffManager:GetInstance():AddBuff(attacker, var, nil)
          end
          buff:OnWork()
        end
      end
    end
    if attacker and not attacker:IsDead() then
      local careerType = attacker:GetCareerType()
      local reflectRate = self:GetReflect(careerType)
      local reboundHp = iHp * reflectRate
      local suckHpRate = attacker:GetSuckHp()
      local absorbHp = iHp * suckHpRate
      attacker:ChangeHp(reboundHp - absorbHp, true)
      local careerReflectBuffs = {}
      if careerType == td.CareerType.Archer then
        careerReflectBuffs = buffs[td.BuffType.ReflectArcher]
      elseif careerType == td.CareerType.Saber then
        careerReflectBuffs = buffs[td.BuffType.ReflectSaber]
      elseif careerType == td.CareerType.Caster then
        careerReflectBuffs = buffs[td.BuffType.ReflectCaster]
      end
      if careerReflectBuffs and #careerReflectBuffs > 0 then
        iHp = 0
      end
    end
    if meatShield then
      meatShield:ChangeHp(iHp, true)
      iHp = 0
    end
    if buffShield then
      iHp = buffShield:BlockDamage(iHp, attacker)
    end
    self.m_pSkillManager:OnGetHurt(attacker)
  end
  return iHp
end
function Actor:OnDead(pAttacker)
  local gdMng = GameDataManager:GetInstance()
  local pMap = gdMng:GetGameMap()
  local mapType = pMap:GetMapType()
  local groupType = self:GetRealGroupType()
  local curPos = cc.p(self:getPosition())
  local lastTilePos = pMap:GetTilePosFromPixelPos(curPos)
  gdMng:SetActorInTile(PulibcFunc:GetInstance():GetIntForPoint(lastTilePos), nil, self)
  local ActorManager = require("app.actor.ActorManager")
  if groupType == td.GroupType.Enemy then
    if not self:IsZombie() then
      gdMng:UpdateStarCondition(td.StarLevel.KILL_ENEMY, 1)
    end
    local bAllCreate = gdMng:IsSingleCreateAll()
    if bAllCreate then
      local curCount = gdMng:GetCurMonsterCount()
      local maxCount = gdMng:GetMaxMonsterCount()
      if curCount >= maxCount then
        local bAllDead = ActorManager:GetInstance():IsAllSideDead(true)
        if bAllDead then
          require("app.trigger.TriggerManager"):GetInstance():SendEvent({
            eType = td.ConditionType.AllSideDead,
            isEnemy = true
          })
          return
        end
      end
    end
  else
    gdMng:UpdateStarCondition(td.StarLevel.UNIT_DEATH, 1)
    local bAllDead = ActorManager:GetInstance():IsAllSideDead(false)
    if bAllDead then
      require("app.trigger.TriggerManager"):GetInstance():SendEvent({
        eType = td.ConditionType.AllSideDead,
        isEnemy = false
      })
      return
    end
  end
end
function Actor:OnKillEnemy(enemyTag)
  self.m_pSkillManager:OnKillEnemy(enemyTag)
end
function Actor:SetRemove(bRemove)
  Actor.super.SetRemove(self, bRemove)
  if bRemove then
    self:SetEnemy(nil)
    self.m_pSkillManager:StopPassiveSkill()
    BuffManager:GetInstance():RemoveBuffByTag(self:getTag())
    if GameDataManager:GetInstance():GetFocusNode() == self then
      GameDataManager:GetInstance():SetFocusNode(nil)
    end
  end
end
function Actor:Alive(hp, groupType)
  local ActorManager = require("app.actor.ActorManager")
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local realGroupType = self:GetRealGroupType()
  ActorManager:GetInstance():ChangeActorGroup(self, groupType)
  self.m_pHpBar:removeFromParent()
  self:CreateHPBar()
  self:SetEnemy(nil)
  self:SetCurHp(hp)
  if realGroupType ~= groupType then
    self:SetInverted(not self:GetInverted())
  end
  local vPath = pMap:GetMapPath(self:GetPathId())
  local vTemp = {}
  for i, v in ipairs(vPath) do
    local tempPos = pMap:GetPixelPosFromTilePos(PulibcFunc:GetInstance():GetPointForInt(v))
    table.insert(vTemp, pMap:GetTilePosFromPixelPos(tempPos))
  end
  self:SetPath(vTemp)
  if self:GetInverted() then
    self:SetCurPathCount(#vTemp)
    self:SetFinalTargetPos(pMap:GetPixelPosFromTilePos(vTemp[1]))
  else
    self:SetCurPathCount(1)
    self:SetFinalTargetPos(pMap:GetPixelPosFromTilePos(vTemp[#vTemp]))
  end
  self.m_pStateManager:ChangeState(td.StateType.Idle)
end
function Actor:SetDirType(eType)
  if eType == td.DirType.Left then
    self.m_pSkeleton:setScaleX(-1)
  else
    self.m_pSkeleton:setScaleX(1)
  end
  self.m_eDirType = eType
end
function Actor:SetEnemy(enemy)
  if self:IsTaunted() then
    local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
    if buffs[td.BuffType.Taunted] and #buffs[td.BuffType.Taunted] > 0 then
      enemy = buffs[td.BuffType.Taunted][1]:GetObject()
    end
  end
  Actor.super.SetEnemy(self, enemy)
end
function Actor:SetEnterEffect(effectID, iEnterDelay)
  self.m_iEnterEffect = effectID
  self.m_iEnterDelay = iEnterDelay or 0
end
function Actor:IsInViewRange(pEnemy)
  local iRange = self:GetViewRange()
  local enemyPos = cc.p(pEnemy:getPosition())
  local curPos = cc.p(self:getPosition())
  local distanceSQ = cc.pDistanceSQ(curPos, cc.p(pEnemy:getPosition()))
  if pEnemy:GetType() == td.ActorType.Home then
    if pEnemy:GetGroupType() == td.GroupType.Self then
      local center = pEnemy:GetCenterPos()
      local isIn = IsCircleAndEllipseCross(center.x, center.y, pEnemy:GetEllipseSize().width / 2, pEnemy:GetEllipseSize().height / 2, curPos.x, curPos.y, iRange)
      return isIn, distanceSQ
    else
      local size = pEnemy:GetContentSize()
      size.width = size.width * pEnemy:getScale()
      size.height = size.height * pEnemy:getScale()
      local isIn = IsRectAndCircleCross(curPos.x, curPos.y, iRange, enemyPos.x, enemyPos.y, size.width, size.height)
      return isIn, distanceSQ
    end
  elseif distanceSQ <= iRange * iRange then
    return true, distanceSQ
  end
  return false, distanceSQ
end
function Actor:IsInAttackRange(pEnemy)
  local curPos = cc.p(self:getPosition())
  return self:IsInAttackRangeForPos(pEnemy, curPos)
end
function Actor:IsInAttackRangeForPos(pEnemy, pos)
  if not pEnemy then
    return false
  end
  self:SelectPriorSkill()
  local pSkill = self:GetCurSkill()
  local iRange = pSkill:GetAttackRange()
  local enemyPos = cc.p(pEnemy:getPosition())
  if pEnemy:GetType() == td.ActorType.Home then
    if pEnemy:GetGroupType() == td.GroupType.Self then
      local center = pEnemy:GetCenterPos()
      local isIn = IsCircleAndEllipseCross(center.x, center.y, pEnemy:GetEllipseSize().width / 2, pEnemy:GetEllipseSize().height / 2, pos.x, pos.y, iRange)
      return isIn
    else
      local size = pEnemy:getContentSize()
      local isIn = IsRectAndCircleCross(pos.x, pos.y, iRange, enemyPos.x, enemyPos.y, size.width, size.height)
      return isIn
    end
  elseif cc.pDistanceSQ(pos, enemyPos) <= iRange * iRange then
    return true
  end
  return false
end
function Actor:GetCanMoveBlocks()
  return self.m_canMoveBlockIds
end
function Actor:FindPath(endPos)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  for i, v in ipairs(self.m_canMoveBlockIds) do
    local n = tonumber(v)
    if n ~= 0 and not GameDataManager:GetInstance():IsAllPassBlock(n) then
      pMap:AddPassableRoadType(n)
    end
  end
  local vec = {}
  vec = pMap:FindPath(cc.p(self:getPosition()), endPos)
  for i, v in ipairs(self.m_canMoveBlockIds) do
    local n = tonumber(v)
    if n ~= 0 and not GameDataManager:GetInstance():IsAllPassBlock(n) then
      pMap:RemovePassableRoadType(n)
    end
  end
  return vec
end
function Actor:GetNextMovePos()
  local actorType = self:GetType()
  local nextPos = cc.p(0, 0)
  local mapInfo = GameDataManager:GetInstance():GetGameMapInfo()
  if actorType == td.ActorType.Hero and mapInfo.type ~= td.MapType.PVP and mapInfo.type ~= td.MapType.PVPGuild and mapInfo.type ~= td.MapType.Rob then
    nextPos = cc.p(self:GetTempTargetPos())
    return nextPos
  end
  local vPath = self:GetPath()
  if not vPath or 0 >= self.m_iCurPathCount or self.m_iCurPathCount > table.nums(vPath) then
    nextPos = cc.p(self:GetFinalTargetPos())
    return nextPos, false
  end
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local pos = pMap:GetTilePosFromPixelPos(cc.p(self:getPosition()))
  local iMinCount = GetMinCountForPath(vPath, pos)
  if iMinCount > #vPath then
    nextPos = cc.p(self:GetFinalTargetPos())
    return nextPos, false
  end
  self.m_iCurPathCount = iMinCount
  local isTransfer = false
  local transferID = pMap:GetPathPointTransferID(self.m_iPathId, self.m_iCurPathCount)
  local tempPos1 = vPath[self.m_iCurPathCount]
  if not cc.pFuzzyEqual(pos, tempPos1, 0) then
    if self.m_bInverted then
      if self.m_iCurPathCount > 1 then
        local tempPos2 = vPath[self.m_iCurPathCount - 1]
        if IsIn2Point(pos, tempPos1, tempPos2) then
          nextPos = cc.p(pMap:GetPixelPosFromTilePos(tempPos2))
          if transferID == self.m_iCurPathCount then
            isTransfer = true
          end
          return nextPos, isTransfer
        end
      else
        nextPos = cc.p(self:GetFinalTargetPos())
        return nextPos, isTransfer
      end
    elseif self.m_iCurPathCount < #vPath then
      local tempPos2 = vPath[self.m_iCurPathCount + 1]
      if IsIn2Point(pos, tempPos1, tempPos2) then
        nextPos = cc.p(pMap:GetPixelPosFromTilePos(tempPos2))
        if transferID == self.m_iCurPathCount then
          isTransfer = true
        end
        return nextPos, isTransfer
      end
    else
      nextPos = cc.p(self:GetFinalTargetPos())
      return nextPos, isTransfer
    end
  end
  if self.m_bInverted then
    if self.m_iCurPathCount > 1 then
      self.m_iCurPathCount = self.m_iCurPathCount - 1
    else
      nextPos = cc.p(self:GetFinalTargetPos())
      return nextPos, false
    end
  elseif self.m_iCurPathCount < #vPath then
    self.m_iCurPathCount = self.m_iCurPathCount + 1
  else
    nextPos = cc.p(self:GetFinalTargetPos())
    return nextPos, false
  end
  if transferID == self.m_iCurPathCount then
    isTransfer = true
  end
  nextPos = cc.p(pMap:GetPixelPosFromTilePos(vPath[self.m_iCurPathCount]))
  return nextPos, isTransfer
end
function Actor:Skill(id, endCallback)
  self.m_pSkillManager:Skill(id, endCallback)
end
function Actor:SelectPriorSkill()
  self.m_pSkillManager:SelectPriorSkill()
end
function Actor:SetCurSkill(id, bChangeState)
  if self:IsDead() then
    return
  end
  self.m_iCurSkillID = id
  if bChangeState then
    self.m_pStateManager:ChangeState(td.StateType.Attack)
  end
end
function Actor:GetCurSkill()
  return self.m_pSkillManager:GetSkill(self.m_iCurSkillID)
end
function Actor:IsCanAttack()
  return Actor.super.IsCanAttack(self) and not self:IsDead() and not self:IsPeace()
end
function Actor:IsCanAttacked()
  return Actor.super.IsCanAttacked(self) and not self:IsDead() and not self:IsPeace() and not self:IsHiding()
end
function Actor:SetData(pData)
  self.m_pData = clone(pData)
  self.m_iCareerType = self.m_pData.career
  self:SetCurHp(self:GetMaxHp())
end
function Actor:MoveAction(nextPos)
  local tempPos = cc.pNormalize(cc.pSub(nextPos, cc.p(self:getPosition())))
  if self.m_bHaveZBMRun and math.abs(tempPos.y) > math.abs(tempPos.x) and math.abs(tempPos.x) < 0.5 then
    if tempPos.y > 0 then
      self:PlayAnimation("BMrun")
    else
      self:PlayAnimation("ZMrun")
    end
  else
    self:PlayAnimation("run")
  end
  if tempPos.x > 0 then
    self:SetDirType(td.DirType.Right)
  elseif tempPos.x < 0 then
    self:SetDirType(td.DirType.Left)
  end
end
function Actor:SetPathList(vec, endCallback)
  self.m_PathVec = vec
  self.m_MoveEndCallback = endCallback
end
function Actor:GetHole(pEnemy)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local actorPos = cc.p(self:getPosition())
  local enemyPos = cc.p(pEnemy:getPosition())
  self:SelectPriorSkill()
  local pSkill = self:GetCurSkill()
  local iRange = pSkill:GetAttackRange()
  if self:GetCareerType() == td.CareerType.Saber and self:GetGroupType() == td.GroupType.Self and iRange < 100 then
    local tempPos = cc.p(enemyPos)
    if actorPos.x <= enemyPos.x then
      tempPos.x = tempPos.x - iRange + 1
      while tempPos.x <= enemyPos.x do
        local tempTilePos = pMap:GetTilePosFromPixelPos(tempPos)
        if pMap:IsWalkable(tempTilePos) and self:IsInAttackRangeForPos(pEnemy, tempPos) then
          local t = GameDataManager:GetInstance():GetInTileActors(PulibcFunc:GetInstance():GetIntForPoint(tempTilePos))
          if not t or #t <= 1 and t[1] == self then
            return tempPos
          end
        end
        tempPos.x = tempPos.x + pMap:GetTileSize().width
      end
    else
      tempPos.x = tempPos.x + iRange - 1
      while tempPos.x >= enemyPos.x do
        local tempTilePos = pMap:GetTilePosFromPixelPos(tempPos)
        if pMap:IsWalkable(tempTilePos) and self:IsInAttackRangeForPos(pEnemy, tempPos) then
          local t = GameDataManager:GetInstance():GetInTileActors(PulibcFunc:GetInstance():GetIntForPoint(tempTilePos))
          if not t or #t <= 1 and t[1] == self then
            return tempPos
          end
        end
        tempPos.x = tempPos.x - pMap:GetTileSize().width
      end
    end
  end
  local actorTilePos = pMap:GetTilePosFromPixelPos(actorPos)
  local t = GameDataManager:GetInstance():GetInTileActors(PulibcFunc:GetInstance():GetIntForPoint(actorTilePos))
  if not t or #t <= 1 and t[1] == self then
    return actorPos
  end
  local tileSize = pMap:GetTileSize()
  local piexlPos = cc.p(actorPos.x, actorPos.y)
  local iCount = 1
  local noUp = false
  local noDown = false
  local function RandomPos(pos1, pos2)
    local minTilePos = pMap:GetPixelPosFromTilePos(pMap:GetTilePosFromPixelPos(pos2))
    local normalize = cc.pNormalize(cc.pSub(pos1, pos2))
    local tempX = 0
    local tempY = 0
    if 0 > normalize.x then
      tempX = pos2.x - minTilePos.x
    else
      tempX = minTilePos.x + pMap:GetTileSize().width - pos2.x
    end
    if tempX >= 1 then
      tempX = math.modf(tempX)
      tempX = math.random(tempX)
    end
    if 0 > normalize.x then
      tempX = -tempX
    end
    if 0 > normalize.y then
      tempY = pos2.y - minTilePos.y
    else
      tempY = minTilePos.y + pMap:GetTileSize().height - pos2.y
    end
    if tempY >= 1 then
      tempY = math.modf(tempY)
      tempY = math.random(tempY)
    end
    if 0 > normalize.y then
      tempY = -tempY
    end
    return cc.p(tempX, tempY)
  end
  local minNum = #t
  local pos = cc.p(actorPos.x, actorPos.y)
  while true do
    piexlPos.y = actorPos.y + iCount * tileSize.height
    local bValid = true
    if pEnemy:GetType() == td.ActorType.Home and pEnemy:GetGroupType() == td.GroupType.Self then
      local center = cc.p(enemyPos.x + pEnemy:getContentSize().width / 2, enemyPos.y + pEnemy:getContentSize().height / 2)
      if IsInEllipse(center.x, center.y, pEnemy:GetEllipseSize().width / 2, pEnemy:GetEllipseSize().height / 2, piexlPos) then
        bValid = false
      end
    end
    local piexlTilePos = pMap:GetTilePosFromPixelPos(piexlPos)
    if not pMap:IsWalkable(piexlTilePos) or not self:IsInAttackRangeForPos(pEnemy, piexlPos) then
      if iCount > 0 then
        noUp = true
      else
        noDown = true
      end
    elseif bValid then
      local t = GameDataManager:GetInstance():GetInTileActors(PulibcFunc:GetInstance():GetIntForPoint(piexlTilePos))
      if not t then
        local tempPos = RandomPos(enemyPos, piexlPos)
        pos.x = piexlPos.x + tempPos.x
        pos.y = piexlPos.y + tempPos.y
        local posTile = pMap:GetTilePosFromPixelPos(pos)
        if pMap:IsWalkable(posTile) and self:IsInAttackRangeForPos(pEnemy, pos) then
          return pos
        end
        return piexlPos
      end
      if minNum > #t then
        minNum = #t
        pos = cc.p(piexlPos.x, piexlPos.y)
      end
    end
    if noUp and noDown then
      local enemyTilePos = pMap:GetTilePosFromPixelPos(enemyPos)
      local tempTilePos = pMap:GetTilePosFromPixelPos(piexlPos)
      if enemyTilePos.x == tempTilePos.x then
        break
      else
        if enemyTilePos.x > tempTilePos.x then
          piexlPos.x = piexlPos.x + pMap:GetTileSize().width
        else
          piexlPos.x = piexlPos.x - pMap:GetTileSize().width
        end
        noUp = false
        noDown = false
        iCount = 1
      end
    elseif noUp then
      if iCount > 0 then
        iCount = -iCount
      else
        iCount = iCount - 1
      end
    elseif noDown then
      if iCount > 0 then
        iCount = iCount + 1
      else
        iCount = (iCount - 1) * -1
      end
    elseif iCount > 0 then
      iCount = -iCount
    else
      iCount = (iCount - 1) * -1
    end
  end
  if cc.pFuzzyEqual(pos, actorPos, 0) then
    local tempPos = RandomPos(enemyPos, actorPos)
    pos.x = actorPos.x + tempPos.x
    pos.y = actorPos.y + tempPos.y
    if pMap:IsWalkable(pMap:GetTilePosFromPixelPos(pos)) and self:IsInAttackRangeForPos(pEnemy, pos) then
      return pos
    end
    return actorPos
  end
  return pos
end
function Actor:SetTempTargetPos(pos)
  self.m_TempTargetPos = pos
end
function Actor:GetTempTargetPos()
  return self.m_TempTargetPos
end
function Actor:SetFinalTargetPos(pos)
  self.m_FinalTargetPos = pos
end
function Actor:GetFinalTargetPos()
  return self.m_FinalTargetPos
end
function Actor:IsDead()
  return self.m_iCurHp <= 0
end
function Actor:SetCurHp(iHp)
  self.m_iCurHp = iHp
  if self.m_pHpBar then
    self.m_pHpBar:SetPercentage(self:GetCurHp() / self:GetMaxHp() * 100)
  end
end
function Actor:GetCurHp()
  return self.m_iCurHp
end
function Actor:GetDirType()
  return self.m_eDirType
end
function Actor:SetPathId(id, bInverted)
  bInverted = bInverted or false
  self.m_iPathId = id
  self:SetInverted(bInverted)
end
function Actor:GetPathId()
  return self.m_iPathId
end
function Actor:SetInverted(bInverted)
  self.m_bInverted = bInverted
end
function Actor:GetInverted()
  if self:IsCharmed() then
    return not self.m_bInverted
  end
  return self.m_bInverted
end
function Actor:SetCurPathCount(iCount)
  self.m_iCurPathCount = iCount
end
function Actor:GetCurPathCount()
  return self.m_iCurPathCount
end
function Actor:GetPathList()
  return self.m_PathVec
end
function Actor:StopMove()
  self:SetTempTargetPos(cc.p(self:getPosition()))
  self.m_PathVec = {}
end
function Actor:GetOwenPlayPos()
  return self.m_OwenPlayPos
end
function Actor:GetName()
  return self.m_pData.name
end
function Actor:GetAttackValue()
  local ratio = 0
  local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
  if buffs[td.BuffType.AtkAdd] then
    for i, v in ipairs(buffs[td.BuffType.AtkAdd]) do
      ratio = ratio + math.abs(v:GetValue()) / 100
    end
  end
  if buffs[td.BuffType.AtkReduce] then
    for i, v in ipairs(buffs[td.BuffType.AtkReduce]) do
      ratio = ratio - math.abs(v:GetValue()) / 100
    end
  end
  local result = self.m_pData.property[td.Property.Atk].value * (1 + ratio)
  return result > 0 and result or 0
end
function Actor:GetDefense()
  local ratio = 0
  local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
  if buffs[td.BuffType.DefAdd] then
    for i, v in ipairs(buffs[td.BuffType.DefAdd]) do
      ratio = ratio + math.abs(v:GetValue()) / 100
    end
  end
  if buffs[td.BuffType.DefReduce] then
    for i, v in ipairs(buffs[td.BuffType.DefReduce]) do
      ratio = ratio - math.abs(v:GetValue()) / 100
    end
  end
  local result = self.m_pData.property[td.Property.Def].value * (1 + ratio)
  return result > 0 and result or 0
end
function Actor:GetSpeed()
  local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
  if buffs[td.BuffType.LockFeet] and #buffs[td.BuffType.LockFeet] > 0 then
    return 0
  end
  local ratio = 1
  if buffs[td.BuffType.SpVary_P] then
    for i, v in ipairs(buffs[td.BuffType.SpVary_P]) do
      ratio = ratio * (1 + v:GetValue() / 100)
    end
  end
  if ratio < 0 then
    ratio = 0
  end
  return self.m_pData.property[td.Property.Speed].value * ratio
end
function Actor:GetViewRange()
  local mapInfo = GameDataManager:GetInstance():GetGameMapInfo()
  if mapInfo.type == td.MapType.PVP or mapInfo.type == td.MapType.PVPGuild or mapInfo.type == td.MapType.Trial or mapInfo.type == td.MapType.Boss or mapInfo.type == td.MapType.Bomb then
    return 10000
  end
  return self.m_pData.view
end
function Actor:GetRealMaxHp()
  return self.m_pData.property[td.Property.HP].value
end
function Actor:GetMaxHp()
  local ratio = 0
  local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
  if buffs[td.BuffType.HpMaxAdd] then
    for i, v in ipairs(buffs[td.BuffType.HpMaxAdd]) do
      ratio = ratio + math.abs(v:GetValue()) / 100
    end
  end
  if buffs[td.BuffType.HpMaxReduce] then
    for i, v in ipairs(buffs[td.BuffType.HpMaxReduce]) do
      ratio = ratio - math.abs(v:GetValue()) / 100
    end
  end
  local result = self.m_pData.property[td.Property.HP].value * (1 + ratio)
  return result > 0 and result or 0
end
function Actor:GetAttackSpeed()
  local ratio = 1
  local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
  if buffs[td.BuffType.AtkSpVary_P] then
    for i, v in ipairs(buffs[td.BuffType.AtkSpVary_P]) do
      ratio = ratio * (1 - v:GetValue() / 100)
    end
  end
  if ratio < 0 then
    ratio = 0
  end
  return self.m_pData.property[td.Property.AtkSp].value * ratio
end
function Actor:GetCritRate()
  local vary = 0
  local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
  if buffs[td.BuffType.CritVary_V] then
    for i, v in ipairs(buffs[td.BuffType.CritVary_V]) do
      vary = vary + v:GetValue()
    end
  end
  return cc.clampf(self.m_pData.property[td.Property.Crit].value + vary, 0, 1000)
end
function Actor:GetDodgeRate(careerType)
  local vary = 0
  local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
  if buffs[td.BuffType.DodgeVary_V] then
    for i, v in ipairs(buffs[td.BuffType.DodgeVary_V]) do
      vary = vary + v:GetValue()
    end
  end
  if careerType == td.CareerType.Saber then
    if buffs[td.BuffType.DodgeSaber] then
      for i, v in ipairs(buffs[td.BuffType.DodgeSaber]) do
        vary = vary + v:GetValue()
      end
    end
  elseif careerType == td.CareerType.Archer then
    if buffs[td.BuffType.DodgeArcher] then
      for i, v in ipairs(buffs[td.BuffType.DodgeArcher]) do
        vary = vary + v:GetValue()
      end
    end
  elseif careerType == td.CareerType.Caster and buffs[td.BuffType.DodgeCaster] then
    for i, v in ipairs(buffs[td.BuffType.DodgeCaster]) do
      vary = vary + v:GetValue()
    end
  end
  return cc.clampf(self.m_pData.property[td.Property.Dodge].value + vary, 0, 1000)
end
function Actor:GetBlockRate()
  local vary = 0
  local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
  if buffs[td.BuffType.BlockVary_V] then
    for i, v in ipairs(buffs[td.BuffType.BlockVary_V]) do
      vary = vary + v:GetValue()
    end
  end
  return cc.clampf(self.m_pData.block_rate + vary, 0, 100)
end
function Actor:GetHitRate()
  local vary = 0
  local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
  if buffs[td.BuffType.HitVary_V] then
    for i, v in ipairs(buffs[td.BuffType.HitVary_V]) do
      vary = vary + v:GetValue()
    end
  end
  return cc.clampf(100 + vary, 0, 1000)
end
function Actor:GetSuckHp()
  local vary = 0
  local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
  if buffs[td.BuffType.HpAbsorb] then
    for i, v in ipairs(buffs[td.BuffType.HpAbsorb]) do
      vary = vary + v:GetValue()
    end
  end
  local result = (self.m_pData.property[td.Property.SuckHp].value + vary) / 100
  return result
end
function Actor:GetReflect(careerType)
  local vary = 0
  local buffs = BuffManager:GetInstance():GetBuffByTag(self:getTag())
  if buffs[td.BuffType.Rebound] then
    for i, buff in ipairs(buffs[td.BuffType.Rebound]) do
      vary = vary + buff:GetValue()
      buff:OnWork()
    end
  end
  if careerType then
    local careerReflectBuffs = {}
    if careerType == td.CareerType.Archer then
      careerReflectBuffs = buffs[td.BuffType.ReflectArcher]
    elseif careerType == td.CareerType.Saber then
      careerReflectBuffs = buffs[td.BuffType.ReflectSaber]
    elseif careerType == td.CareerType.Caster then
      careerReflectBuffs = buffs[td.BuffType.ReflectCaster]
    end
    if careerReflectBuffs then
      for i, buff in ipairs(careerReflectBuffs) do
        vary = vary + buff:GetValue()
        buff:OnWork()
      end
    end
  end
  local result = (self.m_pData.property[td.Property.Reflect].value + vary) / 100
  return result
end
function Actor:BeforeAttack(callback)
  callback()
end
function Actor:AfterAttack(callback)
  callback()
end
function Actor:GetData()
  return self.m_pData
end
function Actor:SetPath(v)
  self.m_vPath = v
end
function Actor:GetPath()
  return self.m_vPath
end
function Actor:GetCareerType()
  return self.m_iCareerType
end
function Actor:SetAttractRes(bAttractRes)
  self.m_bAttractRes = bAttractRes
end
function Actor:IsAttractRes()
  return self.m_bAttractRes
end
function Actor:setPosition(x, y)
  local pos = {}
  if y then
    pos.x = x
    pos.y = y
  else
    pos = x
  end
  local lastPos = cc.p(self:getPosition())
  Actor.super.setPosition(self, pos)
  if self.m_pStateManager then
    local state = self.m_pStateManager:GetCurState()
    if state:GetType() ~= td.StateType.MoveToHole then
      local pMap = GameDataManager:GetInstance():GetGameMap()
      local lastTilePos = pMap:GetTilePosFromPixelPos(lastPos)
      local curTilePos = pMap:GetTilePosFromPixelPos(pos)
      if not cc.pFuzzyEqual(lastTilePos, curTilePos, 0) then
        GameDataManager:GetInstance():SetActorInTile(PulibcFunc:GetInstance():GetIntForPoint(lastTilePos), PulibcFunc:GetInstance():GetIntForPoint(curTilePos), self)
      end
    end
  end
end
function Actor:ChangeState(eStateType)
  if self.m_pStateManager then
    self.m_pStateManager:ChangeState(eStateType)
  end
end
function Actor:GetSkillManager()
  return self.m_pSkillManager
end
function Actor:AddSkill(skillId, prioprty)
  self.m_pSkillManager:AddSkill(skillId, prioprty)
end
function Actor:RemoveSkill(skillId)
  self.m_pSkillManager:RemoveSkill(skillId)
end
function Actor:UpdateEnemyAzimuth()
  self.m_pEnemyAzimuth = td.GunActorAzimuth(self, self:GetEnemy())
end
function Actor:SetYXWave(bYXWave)
  self.m_bYXWave = bYXWave
end
function Actor:GetYXWave()
  return self.m_bYXWave
end
return Actor
