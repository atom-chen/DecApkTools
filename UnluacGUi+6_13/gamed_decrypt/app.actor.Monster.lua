local Actor = import(".Actor")
local GameDataManager = require("app.GameDataManager")
local ActorManager = require("app.actor.ActorManager")
local StateManager = require("app.actor.state.StateManager")
local Monster = class("Monster", Actor)
local ZiYuan_Tag = 1000
function Monster:ctor(eType, pData)
  Monster.super.ctor(self, eType, pData)
  local mapInfo = GameDataManager:GetInstance():GetGameMapInfo()
  self.m_canMoveBlockIds = string.split(mapInfo.monster_move_block, "#")
  self.m_flyTime = 0
  self.m_eCollectionResType = 0
end
function Monster:onEnter()
  Monster.super.onEnter(self)
  local mType = self.m_pData.monster_type
  if mType == td.MonsterType.BOSS then
    td.dispatchEvent(td.UPDATE_BOSS_HP, self:GetCurHp() / self:GetMaxHp() * 100)
  end
  require("app.trigger.TriggerManager"):GetInstance():SendEvent({
    eType = td.ConditionType.MonsterBirth,
    monsterId = self:GetID()
  })
end
function Monster:SetData(pData)
  local gdMng = GameDataManager:GetInstance()
  local mapInfo = gdMng:GetGameMapInfo()
  if mapInfo.type == td.MapType.Endless then
    local wave = (gdMng:GetMonsterWave() - 1) * gdMng:GetMaxMonsterCount() + gdMng:GetCurMonsterCount()
    local temp = 1.2 + math.floor((wave - 1) / 5) * mapInfo.difficult * 0.1
    pData.property[td.Property.HP].value = pData.property[td.Property.HP].value * temp
    pData.property[td.Property.Atk].value = pData.property[td.Property.Atk].value * temp
    pData.property[td.Property.Def].value = pData.property[td.Property.Def].value * temp
  elseif mapInfo.type == td.MapType.Bomb then
    local bomb_config = require("app.config.bomb_config")
    local wave = (gdMng:GetMonsterWave() - 1) * gdMng:GetMaxMonsterCount() + gdMng:GetCurMonsterCount()
    local initRatio = bomb_config.init_ratio[gdMng:GetBombData().mode]
    local temp = initRatio + math.floor((wave - 1) / bomb_config.add_wave) * bomb_config.add_ratio
    pData.property[td.Property.HP].value = pData.property[td.Property.HP].value * temp
    pData.property[td.Property.Atk].value = pData.property[td.Property.Atk].value * temp
    pData.property[td.Property.Def].value = pData.property[td.Property.Def].value * temp
  else
    local temp = 0.9 + mapInfo.difficult * 0.1
    pData.property[td.Property.HP].value = pData.property[td.Property.HP].value * temp
    pData.property[td.Property.Atk].value = pData.property[td.Property.Atk].value * temp
    pData.property[td.Property.Def].value = pData.property[td.Property.Def].value * temp
  end
  Monster.super.SetData(self, pData)
end
function Monster:InitState()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local mapType = pMap:GetMapType()
  self.m_pStateManager = StateManager.new(self)
  if self.m_eBehaveType == td.BehaveType.Collect then
    self.m_pStateManager:AddStates(td.StatesType.BombMonster)
  else
    self.m_pStateManager:AddStates(td.StatesType.Monster)
  end
  self.m_pStateManager:ChangeState(td.StateType.Idle)
end
function Monster:IsCanBuffed()
  local mType = self.m_pData.monster_type
  if mType == td.MonsterType.BOSS or mType == td.MonsterType.DeputyBoss then
    return false
  end
  return true
end
function Monster:IsCanBeMoved()
  local mType = self.m_pData.monster_type
  if mType == td.MonsterType.BOSS or mType == td.MonsterType.DeputyBoss then
    return false
  end
  return true
end
function Monster:SetCurHp(iHp)
  Monster.super.SetCurHp(self, iHp)
  local mType = self.m_pData.monster_type
  if mType == td.MonsterType.BOSS then
    td.dispatchEvent(td.UPDATE_BOSS_HP, self:GetCurHp() / self:GetMaxHp() * 100)
  end
  require("app.trigger.TriggerManager"):GetInstance():SendEvent({
    eType = td.ConditionType.MonsterHp,
    monsterId = self:GetID(),
    hpRatio = self:GetCurHp() / self:GetMaxHp()
  })
end
function Monster:GetViewRange()
  local mapInfo = GameDataManager:GetInstance():GetGameMapInfo()
  if mapInfo.type == td.MapType.Trial or mapInfo.type == td.MapType.Bomb then
    return 10000
  end
  return self.m_pData.view
end
function Monster:GetMonsterType()
  return self.m_pData.monster_type
end
function Monster:FlyToPos(pos, callback, flyDur)
  flyDur = flyDur or 1
  self:_FlyBefore()
  self:runAction(cca.seq({
    cca.moveTo(flyDur, pos.x, pos.y),
    cca.cb(function()
      self:_FlyAfter(callback)
    end)
  }))
end
function Monster:_FlyBefore()
  self.m_pStateManager:SetPause(true)
  self.m_flyTime = self.m_flyTime + 1
end
function Monster:_FlyAfter(cb)
  self.m_pStateManager:SetPause(false)
  self.m_pStateManager:ChangeState(td.StateType.Idle)
  require("app.trigger.TriggerManager"):GetInstance():SendEvent({
    eType = td.ConditionType.MonsterFlyEnd,
    monsterId = self:GetID(),
    time = self.m_flyTime
  })
  if cb then
    cb()
  end
end
function Monster:OnDead(pAttacker)
  Monster.super.OnDead(self, pAttacker)
  local sprite = self:getChildByTag(ZiYuan_Tag)
  if sprite then
    sprite:removeFromParent()
    local pMap = GameDataManager:GetInstance():GetGameMap()
    local pos = cc.p(self:getPosition())
    local dir = {1, -1}
    local itemIcon = td.CreateItemIcon(self.m_eCollectionResType)
    itemIcon:scale(0.6):align(display.CENTER_BOTTOM, pos.x, pos.y):addTo(pMap, pMap:GetPiexlSize().height - pos.y)
    itemIcon:runAction(cca.seq({
      cca.jumpBy(1, dir[math.random(2)] * 100, 0, 50, 3),
      cca.delay(1),
      cca.spawn({
        cca.moveBy(0.5, 0, 100),
        cca.fadeOut(0.5)
      }),
      cca.removeSelf()
    }))
  end
end
function Monster:SetCollectionRes(itemId)
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  self.m_eCollectionResType = itemId
  local itemIcon = td.CreateItemIcon(self.m_eCollectionResType)
  itemIcon:setScale(0.5 / self:getScale())
  itemIcon:setPosition(0, self.m_pSkeleton:GetContentSize().height * self:getScaleY() + 80)
  self:addChild(itemIcon, 0, ZiYuan_Tag)
end
function Monster:ActiveFocus()
  Monster.super.ActiveFocus(self)
  td.dispatchEvent(td.SHOW_ACTOR_DETAIL, {
    tag = self:getTag()
  })
end
function Monster:InactiveFocus()
  Monster.super.InactiveFocus(self)
  td.dispatchEvent(td.SHOW_ACTOR_DETAIL, {tag = -1})
end
function Monster:DoFocus(pos)
  Monster.super.DoFocus(self, pos)
end
return Monster
