local Actor = import(".Actor")
local GameDataManager = require("app.GameDataManager")
local EffectManager = require("app.effect.EffectManager")
local StateManager = require("app.actor.state.StateManager")
require("app.config.hero_sound_config")
local Hero = class("Hero", Actor)
Hero.RecoverCD = 1
Hero.CheckRecoverCD = 5
Hero.ActiveNum = 2
Hero.PassiveNum = 3
function Hero:ctor(eType, pData, isEnemy)
  Hero.super.ctor(self, eType, pData)
  self.m_iEnterEffect = 2064
  self.m_isRecovering = false
  self.m_timeInvl = 0
  self.m_bIsPlayingMoveSound = false
  self.m_chosenEffect = nil
  self.m_initSkillCD = nil
  local mapInfo = GameDataManager:GetInstance():GetGameMapInfo()
  self.m_canMoveBlockIds = string.split(mapInfo.hero_move_block, "#")
  self.m_soundConfig = GetHeroSoundConfig(pData.id)
end
function Hero:GetSpeed()
  local speed = Hero.super.GetSpeed(self)
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  if mapType == td.MapType.Rob then
    speed = speed * 2
  end
  return speed
end
function Hero:onEnter()
  Hero.super.onEnter(self)
  if self.m_initSkillCD then
    for skillId, var in pairs(self.m_initSkillCD) do
      self:SetSkillCD(skillId, var.time)
    end
  end
end
function Hero:Update(dt)
  Hero.super.Update(self, dt)
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  if mapType == td.MapType.PVP or mapType == td.MapType.PVPGuild then
    return
  end
  self.m_timeInvl = self.m_timeInvl + dt
  if self.m_isRecovering then
    if self:GetCurHp() < self:GetMaxHp() then
      self:ChangeHp(self:GetMaxHp() * 0.1 * dt)
    end
    self.m_timeInvl = 0
  elseif self.m_timeInvl >= Hero.CheckRecoverCD then
    self.m_isRecovering = true
    self.m_timeInvl = 0
    td.dispatchEvent(td.HERO_GET_HURT, 0)
  end
end
function Hero:Move(pos)
  self:SetEnemy(nil)
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local mapPos = cc.p(pMap:GetMapPosFromWorldPos(pos))
  self:SetTempTargetPos(mapPos)
  self:SetFinalTargetPos(mapPos)
  local state = self.m_pStateManager:GetCurState()
  if state and state:GetType() == td.StateType.Move then
    state:OnEnter()
  else
    self.m_pStateManager:ChangeState(td.StateType.Move)
  end
end
function Hero:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    if GameDataManager:GetInstance():GetActorCanTouch() then
      local x, y = self:getPosition()
      local size = self:GetContentSize()
      size.width = size.width * self:getScaleX()
      size.height = size.height * self:getScaleY()
      local rect = cc.rect(x - size.width / 2, y, size.width, size.height)
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
    if GameDataManager:GetInstance():GetActorCanTouch() then
      local x, y = self:getPosition()
      local size = self:GetContentSize()
      size.width = size.width * self:getScaleX()
      size.height = size.height * self:getScaleY()
      local rect = cc.rect(x - size.width / 2, y, size.width, size.height)
      local pos = _touch:getLocation()
      pos = self:getParent():convertToNodeSpace({
        x = pos.x,
        y = pos.y
      })
      if cc.rectContainsPoint(rect, pos) then
        GameDataManager:GetInstance():SetFocusNode(self)
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
      end
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function Hero:InitState()
  self.m_pStateManager = StateManager.new(self)
  self.m_pStateManager:AddStates(td.StatesType.Hero)
  self.m_pStateManager:ChangeState(td.StateType.Idle)
end
function Hero:ChangeHp(iHp, isIndirect, attacker)
  local bIsDead = Hero.super.ChangeHp(self, iHp, isIndirect, attacker)
  if iHp <= 0 then
    self.m_timeInvl = 0
    self.m_isRecovering = false
    td.dispatchEvent(td.HERO_GET_HURT, 1)
  end
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  if mapType ~= td.MapType.PVP and mapType ~= td.MapType.PVPGuild and mapType ~= td.MapType.Rob then
    td.dispatchEvent(td.UPDATE_HERO)
  end
  return bIsDead
end
function Hero:OnDead()
  local gdMng = GameDataManager:GetInstance()
  gdMng:UpdateStarCondition(td.StarLevel.HERO_DEATH, 1)
  local mapType = gdMng:GetGameMapInfo().type
  if mapType == td.MapType.PVP or mapType == td.MapType.PVPGuild or mapType == td.MapType.Bomb then
    local bAllDead, bEnemy = false, false
    if self.m_eGroupType == td.GroupType.Enemy then
      bEnemy = true
    end
    bAllDead = require("app.actor.ActorManager"):GetInstance():IsAllSideDead(bEnemy)
    if bAllDead then
      require("app.trigger.TriggerManager"):GetInstance():SendEvent({
        eType = td.ConditionType.AllSideDead,
        allSideDead = true,
        isEnemy = bEnemy
      })
    end
  end
  if mapType ~= td.MapType.PVP and mapType ~= td.MapType.PVPGuild and mapType ~= td.MapType.Rob then
    gdMng:OnCurHeroDead()
    if gdMng:GetFocusNode() == self then
      gdMng:SetFocusNode(nil)
    end
    td.alert(g_LM:getBy("a00321"), true)
  end
  local randIndex = 1
  if 1 < #self.m_soundConfig.dead then
    randIndex = math.random(#self.m_soundConfig.dead)
  end
  G_SoundUtil:PlaySound(self.m_soundConfig.dead[randIndex], false)
end
function Hero:SetCurSkill(id, bChangeState)
  if self:IsDead() then
    return
  end
  self.m_iCurSkillID = id
  if bChangeState then
    local pData = self.m_pSkillManager:GetSkill(id)
    if pData:GetType() == td.SkillType.FixedMagic or pData:GetType() == td.SkillType.RandomMagic then
      local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
      if mapType ~= td.MapType.PVP and mapType ~= td.MapType.PVPGuild and mapType ~= td.MapType.Rob then
        self.m_pStateManager:ChangeState(td.StateType.Magic)
        local randIndex = 1
        if 1 < #self.m_soundConfig.magic then
          randIndex = math.random(#self.m_soundConfig.magic)
        end
        G_SoundUtil:PlaySound(self.m_soundConfig.magic[randIndex], false)
        return
      end
    end
    self.m_pStateManager:ChangeState(td.StateType.Attack)
  end
end
function Hero:SetInitSkillCD(data)
  self.m_initSkillCD = data
end
function Hero:SetSkillCD(skillId, cd)
  local pSkill = self.m_pSkillManager:GetSkill(skillId)
  if pSkill then
    pSkill:SetCDTime(cd)
  end
end
function Hero:SetRemove(bRemove)
  Hero.super.SetRemove(self, bRemove)
  if bRemove then
    td.dispatchEvent(td.CHANGE_HERO)
  end
end
function Hero:OnKillEnemy(enemyTag)
  Hero.super.OnKillEnemy(self, enemyTag)
  local gdMng = GameDataManager:GetInstance()
  gdMng:AddBattleLog(self.m_Id, 1)
  gdMng:UpdateStarCondition(td.StarLevel.HERO_SKILL_KILL, 1)
end
function Hero:ActiveFocus()
  local dataManager = GameDataManager:GetInstance()
  local mapType = dataManager:GetGameMapInfo().type
  if mapType == td.MapType.PVP or mapType == td.MapType.PVPGuild or mapType == td.MapType.Rob then
    td.dispatchEvent(td.SHOW_ACTOR_DETAIL, {
      tag = self:getTag()
    })
  else
    td.dispatchEvent(td.UPDATE_HERO, {hide = 0})
  end
  Hero.super.ActiveFocus(self)
end
function Hero:InactiveFocus()
  local dataManager = GameDataManager:GetInstance()
  local mapType = dataManager:GetGameMapInfo().type
  if mapType == td.MapType.PVP or mapType == td.MapType.PVPGuild or mapType == td.MapType.Rob then
    td.dispatchEvent(td.SHOW_ACTOR_DETAIL, {tag = -1})
  else
    td.dispatchEvent(td.UPDATE_HERO, {hide = 1})
  end
  Hero.super.InactiveFocus(self)
end
function Hero:DoFocus(pos)
  local dataManager = GameDataManager:GetInstance()
  local mapType = dataManager:GetGameMapInfo().type
  if mapType == td.MapType.PVP or mapType == td.MapType.PVPGuild or mapType == td.MapType.Rob then
    GameDataManager:GetInstance():SetFocusNode(nil)
    return
  end
  local pMap = dataManager:GetGameMap()
  local childPos = pMap:GetMapPosFromWorldPos(pos)
  pos = td.GetValidPos(pMap, self.m_canMoveBlockIds, childPos)
  pos = cc.p(self:getParent():convertToWorldSpace(pos))
  self:StopMove()
  self:Move(pos)
  local cursor = EffectManager:GetInstance():CreateEffect(2006)
  cursor:setPosition(childPos)
  cursor:AddToMap(pMap)
  if not self.m_bIsPlayingMoveSound then
    local randIndex = 1
    if #self.m_soundConfig.move > 0 then
      randIndex = math.random(#self.m_soundConfig.move)
    end
    G_SoundUtil:PlaySound(self.m_soundConfig.move[randIndex], false)
    self.m_bIsPlayingMoveSound = true
    self:performWithDelay(function()
      self.m_bIsPlayingMoveSound = false
    end, 5)
  end
end
return Hero
