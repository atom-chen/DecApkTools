local Actor = import(".Actor")
local GameDataManager = require("app.GameDataManager")
local StateManager = require("app.actor.state.StateManager")
local EffectManager = require("app.effect.EffectManager")
local Soldier = class("Soldier", Actor)
local ZiYuan_Tag = 1000
function Soldier:ctor(eType, pData, isEnemy)
  Soldier.super.ctor(self, eType, pData)
  self.m_eCollectionResType = 0
  self.m_iCollectionRes = 0
  self.m_iCarryRes = pData.res_carry
  self.m_strWord = nil
  local mapInfo = GameDataManager:GetInstance():GetGameMapInfo()
  self.m_canMoveBlockIds = string.split(mapInfo.role_move_block, "#")
end
function Soldier:onEnter()
  Soldier.super.onEnter(self)
end
function Soldier:PlayEnterAni()
  Soldier.super.PlayEnterAni(self)
  if self.m_strWord then
    self:Speak(self.m_strWord)
  end
end
function Soldier:SetSpeakWord(word)
  self.m_strWord = word
end
function Soldier:Speak(word)
  local width = 140
  local wordLabel = td.CreateLabel(word, display.COLOR_BLACK, 14, nil, nil, cc.size(width, 0))
  local height = wordLabel:getContentSize().height
  height = cc.clampf(50 + height, 90, 500)
  wordLabel:setAnchorPoint(0, 0.5)
  wordLabel:setVisible(false)
  if self.m_eDirType == td.DirType.Right then
    wordLabel:pos(10, 30 + (height - 30) / 2)
  else
    wordLabel:pos(width + 10, 30 + (height - 30) / 2)
  end
  local talkBubble = display.newScale9Sprite("UI/common/duihuakuang.png", 0, 0, cc.size(165, height), cc.rect(75, 40, 10, 10))
  wordLabel:addTo(talkBubble)
  talkBubble:setAnchorPoint(0, 0)
  talkBubble:pos(0, self:GetContentSize().height):opacity(0):scale(0.01):addTo(self)
  talkBubble:runAction(cca.seq({
    cca.spawn({
      cca.scaleTo(0.1, 1.3 / self:getScale()),
      cca.fadeIn(0.1)
    }),
    cca.scaleTo(0.05, 1.2 / self:getScale()),
    cca.cb(function()
      wordLabel:setVisible(true)
    end),
    cca.delay(3),
    cca.cb(function()
      talkBubble:removeAllChildren()
    end),
    cca.fadeOut(0.5),
    cca.removeSelf()
  }))
end
function Soldier:InitState()
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  self.m_pStateManager = StateManager.new(self)
  if self.m_eBehaveType == td.BehaveType.Collect then
    self.m_pStateManager:AddStates(td.StatesType.ResSoldier)
  else
    self.m_pStateManager:AddStates(td.StatesType.Soldier)
  end
  self.m_pStateManager:ChangeState(td.StateType.Idle)
end
function Soldier:GetSpeed()
  local speed = Soldier.super.GetSpeed(self)
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  if mapType == td.MapType.Rob then
    speed = speed * 2
  end
  return speed
end
function Soldier:OnDead(pAttacker)
  Soldier.super.OnDead(self, pAttacker)
  local gdMng = GameDataManager:GetInstance()
  local pMap = gdMng:GetGameMap()
  if self:GetRealGroupType() == td.GroupType.Self then
    gdMng:UpdateCurPopulation(-self.m_pData.space)
    gdMng:UpdateDeadUnit(self.m_pData.id, 1)
  end
  if self.m_eBehaveType == td.BehaveType.Collect then
    self:DropCollectionRes()
  end
end
function Soldier:DropCollectionRes()
  local gdMng = GameDataManager:GetInstance()
  local pMap = gdMng:GetGameMap()
  local sprite = self:getChildByTag(ZiYuan_Tag)
  if sprite then
    sprite:removeFromParent()
    local pos = cc.p(self:getPosition())
    if pMap:IsWalkable(pMap:GetTilePosFromPixelPos(cc.p(pos.x + 100, pos.y))) then
      pos.x = pos.x + 100
    elseif pMap:IsWalkable(pMap:GetTilePosFromPixelPos(cc.p(pos.x - 100, pos.y))) then
      pos.x = pos.x - 100
    end
    local ActorManager = require("app.actor.ActorManager")
    local path = ""
    if self.m_eCollectionResType == td.ResourceType.ZiYuan then
      path = td.UI_ziyuan
    elseif self.m_eCollectionResType == td.ResourceType.ShiYou then
      path = td.UI_shiyou
    elseif self.m_eCollectionResType == td.ResourceType.ShuiJing then
      path = td.UI_shuijing
    elseif self.m_eCollectionResType == td.ResourceType.DanYao then
      path = td.UI_danyao
    elseif self.m_eCollectionResType == td.ResourceType.Gold then
      path = td.UI_jinbi
    elseif self.m_eCollectionResType == td.ResourceType.Exp then
      path = td.UI_nengliang
    elseif self.m_eCollectionResType == td.ResourceType.EnergyBall_s then
      path = td.UI_energy1
    elseif self.m_eCollectionResType == td.ResourceType.EnergyBall_m then
      path = td.UI_energy2
    elseif self.m_eCollectionResType == td.ResourceType.EnergyBall_l then
      path = td.UI_energy3
    elseif self.m_eCollectionResType == td.ResourceType.Medal_s then
      path = td.UI_medal1
    elseif self.m_eCollectionResType == td.ResourceType.Medal_m then
      path = td.UI_medal2
    elseif self.m_eCollectionResType == td.ResourceType.Medal_l then
      path = td.UI_medal3
    elseif self.m_eCollectionResType == td.ResourceType.StarStone_s then
      path = td.UI_star1
    elseif self.m_eCollectionResType == td.ResourceType.StarStone_m then
      path = td.UI_star2
    elseif self.m_eCollectionResType == td.ResourceType.StarStone_l then
      path = td.UI_star3
    end
    if path ~= "" then
      local pActor = ActorManager:GetInstance():CreateActor(td.ActorType.ZiYuan)
      pActor:CreateAnimation(path)
      pActor:setPosition(pos)
      pMap:addChild(pActor, pMap:GetPiexlSize().height - pActor:getPositionY(), pActor:getTag())
      pActor:SetPath(self:GetPath())
      if self.m_eCollectionResType >= td.ResourceType.EnergyBall_s and self.m_eCollectionResType <= td.ResourceType.StarStone_l then
        pActor:SetCollectionRes(self.m_eCollectionResType, self.m_iCollectionRes)
      else
        pActor:SetCollectionRes(self.m_eCollectionResType, self.m_iCollectionRes / self.m_iCarryRes)
      end
      pActor:PlayAnimation("animation02", true)
    end
  end
end
function Soldier:SetCollectionRes(eCollectionResType, iCollectionRes)
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  if self.m_eBehaveType ~= td.BehaveType.Collect then
    return
  end
  self.m_eCollectionResType = eCollectionResType
  if self.m_eCollectionResType >= td.ResourceType.EnergyBall_s and self.m_eCollectionResType <= td.ResourceType.StarStone_l then
    self.m_iCollectionRes = iCollectionRes
  else
    self.m_iCollectionRes = self.m_iCarryRes * iCollectionRes
  end
  local path = ""
  if self.m_eCollectionResType == td.ResourceType.ZiYuan then
    path = td.UI_ziyuan
  elseif self.m_eCollectionResType == td.ResourceType.ShiYou then
    path = td.UI_shiyou
  elseif self.m_eCollectionResType == td.ResourceType.ShuiJing then
    path = td.UI_shuijing
  elseif self.m_eCollectionResType == td.ResourceType.DanYao then
    path = td.UI_danyao
  elseif self.m_eCollectionResType == td.ResourceType.Gold then
    path = td.UI_jinbi
  elseif self.m_eCollectionResType == td.ResourceType.Exp then
    path = td.UI_nengliang
  elseif self.m_eCollectionResType == td.ResourceType.EnergyBall_s then
    path = td.UI_energy1
  elseif self.m_eCollectionResType == td.ResourceType.EnergyBall_m then
    path = td.UI_energy2
  elseif self.m_eCollectionResType == td.ResourceType.EnergyBall_l then
    path = td.UI_energy3
  elseif self.m_eCollectionResType == td.ResourceType.Medal_s then
    path = td.UI_medal1
  elseif self.m_eCollectionResType == td.ResourceType.Medal_m then
    path = td.UI_medal2
  elseif self.m_eCollectionResType == td.ResourceType.Medal_l then
    path = td.UI_medal3
  elseif self.m_eCollectionResType == td.ResourceType.StarStone_s then
    path = td.UI_star1
  elseif self.m_eCollectionResType == td.ResourceType.StarStone_m then
    path = td.UI_star2
  elseif self.m_eCollectionResType == td.ResourceType.StarStone_l then
    path = td.UI_star3
  end
  if path ~= "" then
    local pActor = SkeletonUnit:create(path)
    pActor:setScale(1 / self:getScale())
    pActor:setPosition(0, self.m_pSkeleton:GetContentSize().height * self:getScaleY() + 80)
    self:addChild(pActor, 0, ZiYuan_Tag)
    pActor:PlayAni("animation01", true)
  end
end
function Soldier:GetCollectionRes()
  return self.m_eCollectionResType, self.m_iCollectionRes
end
function Soldier:HandinCollectionRes()
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  if self.m_eBehaveType ~= td.BehaveType.Collect then
    return
  end
  local sprite = self:getChildByTag(ZiYuan_Tag)
  if sprite then
    sprite:removeFromParent()
  end
  local eType = self.m_eCollectionResType
  local num = self.m_iCollectionRes
  self:SetCollectionRes(td.ResourceType.Non, 0)
  self:SetAttractRes(false)
  local BattleWord = require("app.widgets.BattleWord")
  local critWord = BattleWord.new(num)
  critWord:AddToActor(self)
  return eType, num
end
function Soldier:PickupCollectionRes(eCollectionResType, iCollectionRes)
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  if self.m_eBehaveType ~= td.BehaveType.Collect then
    return false
  end
  self:SetCollectionRes(eCollectionResType, iCollectionRes)
  local curPos = cc.p(self:getPosition())
  local path = self:GetPath()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  self:SetFinalTargetPos(pMap:GetPixelPosFromTilePos(path[1]))
  self:SetInverted(true)
  local state = self.m_pStateManager:GetCurState()
  if state.MoveOver then
    state:MoveOver()
  end
  return true
end
function Soldier:ActiveFocus()
  Soldier.super.ActiveFocus(self)
  td.dispatchEvent(td.SHOW_ACTOR_DETAIL, {
    tag = self:getTag()
  })
end
function Soldier:InactiveFocus()
  Soldier.super.InactiveFocus(self)
  td.dispatchEvent(td.SHOW_ACTOR_DETAIL, {tag = -1})
end
function Soldier:DoFocus(pos)
  Soldier.super.DoFocus(self, pos)
end
return Soldier
