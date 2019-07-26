local GameDataManager = require("app.GameDataManager")
local UserDataManager = require("app.UserDataManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local ActorManager = require("app.actor.ActorManager")
local TabButton = require("app.widgets.TabButton")
local ActorInfoManager = require("app.info.ActorInfoManager")
local UnitDataManager = require("app.UnitDataManager")
local PokedexInfoManager = require("app.info.PokedexInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local TrialPaibingUILayer = class("TrialPaibingUILayer", function()
  return display.newNode()
end)
function TrialPaibingUILayer:ctor()
  self:setNodeEventEnabled(true)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_gdMng = GameDataManager:GetInstance()
  self.m_selectActor = nil
  self.m_selectActorPos = {}
  self.m_step = {}
  self.m_actorNum = 0
  self.m_actorType = td.ActorType.Soldier
  self.m_actorId = 0
  self.m_actorUid = 0
  self.m_selectRoleType = 1
  self.m_LabelType = 0
  self.m_heros = {}
  self.m_soldiers = {}
  self.m_items = {}
  self.m_isActive = false
  self.m_bChanged = false
  for i = 1, 6 do
    local info = ActorInfoManager:GetInstance():GetCampInfo(i)
    self.m_soldiers[info.level1_role] = 0
    self.m_soldiers[info.level2_role] = 0
    self.m_soldiers[info.level3_branch1] = 0
    self.m_soldiers[info.level3_branch2] = 0
    self.m_soldiers[info.level4_final1] = 0
    self.m_soldiers[info.level4_final2] = 0
  end
  self.m_herosData = self.m_udMng:GetHeroData() or {}
  local infos = ActorInfoManager:GetInstance():GetHeroInfos()
  for i, v in pairs(infos) do
    local j, k = math.modf(i / 100)
    if k == 0 then
      self.m_heros[i] = 0
    end
  end
  self:InitUI()
  self:AddTouch()
end
function TrialPaibingUILayer:onEnter()
end
function TrialPaibingUILayer:onExit()
end
function TrialPaibingUILayer:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/TrialPaibingDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_pPanel_top = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_top")
  td.SetAutoScale(self.m_pPanel_top, td.UIPosHorizontal.Left, td.UIPosVertical.Top)
  self.m_pPanel_bottom = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bottom")
  td.SetAutoScale(self.m_pPanel_bottom, td.UIPosHorizontal.Center, td.UIPosVertical.Bottom)
  local resbg = cc.uiloader:seekNodeByName(self.m_pPanel_top, "resbg")
  local campLevel = self.m_udMng:GetUserDetail().camp
  self.m_resNum = GameDataManager:GetInstance():GetCurResCount()
  self.m_resNumLabel = td.CreateLabel(tostring(self.m_resNum))
  self.m_resNumLabel:setAnchorPoint(cc.p(0.5, 0.5))
  self.m_resNumLabel:setPosition(cc.p(resbg:getContentSize().width / 2 + 5, resbg:getContentSize().height / 2))
  resbg:addChild(self.m_resNumLabel)
  local buttonleave = ccui.Button:create(td.Word_Path .. "likai1.png", td.Word_Path .. "likai2.png")
  buttonleave:pos(20, 8):addTo(self.m_pPanel_bottom)
  buttonleave:setAnchorPoint(0, 0)
  td.BtnAddTouch(buttonleave, function()
    GameDataManager:GetInstance():ExitGame()
  end)
  self.m_buttonpaibin = cc.uiloader:seekNodeByName(self.m_pPanel_bottom, "Button_clear_4")
  self.m_buttonpaibin:setPressedActionEnabled(true)
  td.BtnAddTouch(self.m_buttonpaibin, function()
    self:RemoveAllActor()
  end)
  td.BtnSetTitle(self.m_buttonpaibin, g_LM:getBy("a00158"))
  self.m_buttonstartfight = cc.uiloader:seekNodeByName(self.m_pPanel_bottom, "Button_start")
  self.m_buttonstartfight:setDisable(true)
  self.m_buttonstartfight:setPressedActionEnabled(true)
  td.BtnAddTouch(self.m_buttonstartfight, function()
    self:StartFight()
  end)
  td.BtnSetTitle(self.m_buttonstartfight, g_LM:getBy("a00102"))
  self.m_bg = cc.uiloader:seekNodeByName(self.m_pPanel_bottom, "bg")
  self.m_childTab = {
    cc.uiloader:seekNodeByName(self.m_bg, "role1"),
    cc.uiloader:seekNodeByName(self.m_bg, "role2"),
    cc.uiloader:seekNodeByName(self.m_bg, "role3"),
    cc.uiloader:seekNodeByName(self.m_bg, "role4"),
    cc.uiloader:seekNodeByName(self.m_bg, "role5"),
    cc.uiloader:seekNodeByName(self.m_bg, "role6")
  }
  self.m_items = {}
  for i = 1, 6 do
    local itemBg = cc.uiloader:seekNodeByName(self.m_bg, "lanse_guang" .. i)
    local numBg = cc.uiloader:seekNodeByName(itemBg, "shuliangkuang1")
    local yuanliIcon = cc.uiloader:seekNodeByName(itemBg, "yuanli_icon1")
    local _costLabel = td.CreateLabel("0", td.LIGHT_BLUE, 16)
    _costLabel:setAnchorPoint(cc.p(0, 0.5))
    _costLabel:setPosition(cc.p(55, numBg:getContentSize().height / 2))
    numBg:addChild(_costLabel)
    local _numLabel = td.CreateLabel("0", td.LIGHT_BLUE, 18)
    _numLabel:setAnchorPoint(cc.p(0.5, 0.5))
    _numLabel:setPosition(cc.p(15, numBg:getContentSize().height / 2))
    numBg:addChild(_numLabel)
    table.insert(self.m_items, {
      itemBg = itemBg,
      costLabel = _costLabel,
      numLabel = _numLabel,
      yuanliIcon = yuanliIcon
    })
  end
  self:CreateBingzhong()
  self:UpdateActorNum()
  self:CancelSelected()
end
function TrialPaibingUILayer:CancelSelected()
  if self.m_selectedBg then
    self.m_selectedBg:loadTexture("UI/PVPPaibing/lanse_guang.png")
    self.m_selectedBg = nil
  end
  self.m_actorId = nil
  GameDataManager:GetInstance():SetFocusNode(nil)
end
function TrialPaibingUILayer:ClearAllItem()
  for i = 1, 6 do
    local item = self.m_items[i]
    item.itemBg:removeChildByTag(11)
  end
end
function TrialPaibingUILayer:CreateRole(data, type)
  self:ClearAllItem()
  for i = 1, 6 do
    local item = self.m_items[i]
    local info, isUnlock = nil, false
    if type == td.ActorType.Soldier then
      info = ActorInfoManager:GetInstance():GetSoldierInfo(data[i])
      isUnlock = UnitDataManager:GetInstance():IsRoleUnlock(data[i])
    elseif type == td.ActorType.Hero and data[i] then
      info = ActorInfoManager:GetInstance():GetHeroInfo(data[i])
      for id, var in pairs(self.m_herosData) do
        if math.floor(var.hid / 100) * 100 == data[i] then
          info = var.heroInfo
          isUnlock = true
        end
      end
    end
    if info and isUnlock then
      local skelton = SkeletonUnit:create(info.image)
      skelton:setAnchorPoint(cc.p(0.5, 0))
      skelton:setPosition(cc.p(item.itemBg:getContentSize().width / 2, 20))
      skelton:PlayAni("stand")
      skelton:setTag(11)
      skelton:setScale(0.8)
      item.itemBg:addChild(skelton)
      item.costLabel:setVisible(true)
      item.costLabel:setString(tostring(info.arena_resource))
      item.numLabel:setVisible(true)
      item.yuanliIcon:setVisible(true)
    else
      local lock = display.newSprite("UI/common/suo_icon2.png")
      lock:setPosition(cc.p(item.itemBg:getContentSize().width / 2, item.itemBg:getContentSize().height / 2))
      lock:setTag(11)
      item.itemBg:addChild(lock)
      item.costLabel:setVisible(false)
      item.numLabel:setVisible(false)
      item.yuanliIcon:setVisible(false)
    end
  end
end
function TrialPaibingUILayer:CreateBingzhong()
  self.m_actorType = td.ActorType.Soldier
  self.m_selectRoleType = 1
  if not self.m_selectSprite then
    self.m_selectSprite = display.newSprite("UI/PVPPaibing/xuanzhongwaifaguang.png")
    self.m_selectSprite:retain()
  end
  local function pressRole(count)
    self.m_selectSprite:setVisible(true)
    if self.m_selectSprite:getParent() then
      self.m_selectSprite:retain()
      self.m_selectSprite:removeFromParent()
    end
    self.m_selectSprite:setPosition(cc.p(self.m_childTab[count]:getContentSize().width / 2, self.m_childTab[count]:getContentSize().height / 2))
    self.m_childTab[count]:addChild(self.m_selectSprite)
    self.m_selectSprite:release()
    self.m_selectRoleType = count
    local data = self.m_datas[self.m_selectRoleType]
    self:CreateRole(data, td.ActorType.Soldier)
    self:UpdateActorNum()
    self:CancelSelected()
  end
  self.m_datas = {}
  local t = {}
  for i = 1, 6 do
    self.m_childTab[i]:setVisible(true)
    table.insert(t, {
      tab = self.m_childTab[i],
      callfunc = pressRole
    })
    local info = ActorInfoManager:GetInstance():GetCampInfo(i)
    table.insert(self.m_datas, {
      info.level1_role,
      info.level2_role,
      info.level3_branch1,
      info.level3_branch2,
      info.level4_final1,
      info.level4_final2
    })
  end
  self.m_RoleTab = TabButton.new(t)
  self:UpdateActorNum()
end
function TrialPaibingUILayer:initActor()
  local data = self.m_udMng:GetPVPData()
  for i, v in ipairs(data.selfData.hero_item) do
    local heroId = v.id * 100
    self:CreateActor(td.ActorType.Hero, heroId, cc.p(v.x, v.y), false)
  end
  for i, v in ipairs(data.selfData.soldier_item) do
    self:CreateActor(td.ActorType.Soldier, v.id, cc.p(v.x, v.y), false)
  end
  self:UpdateActorNum()
end
function TrialPaibingUILayer:CreateActor(actorType, id, pos, bAddStep)
  local cost = 0
  if actorType == td.ActorType.Soldier then
    cost = ActorInfoManager:GetInstance():GetSoldierInfo(id).arena_resource
  elseif actorType == td.ActorType.Hero then
    cost = ActorInfoManager:GetInstance():GetHeroInfo(id).arena_resource
  end
  if cost > self.m_resNum then
    td.alert(g_LM:getBy("a00174"), true)
    return
  end
  self.m_resNum = self.m_resNum - cost
  self.m_resNumLabel:setString(tostring(self.m_resNum))
  local pMap = self.m_gdMng:GetGameMap()
  local actor, actorData
  if actorType == td.ActorType.Hero then
    for key, var in pairs(self.m_herosData) do
      if var.hid == id then
        actorData = var
        break
      end
    end
    if not actorData then
      td.alertDebug("Hero id error!")
      return
    end
    local info = StrongInfoManager:GetInstance():GetHeroFinalInfo(actorData)
    actor = ActorManager:GetInstance():CreateActor(actorType, id, false, info)
  elseif actorType == td.ActorType.Soldier then
    actor = ActorManager:GetInstance():CreateActor(actorType, id, false)
  end
  actor:setPosition(pos)
  pMap:addChild(actor, pMap:GetPiexlSize().height - actor:getPositionY(), actor:getTag())
  self:ChangeActorNum(self.m_actorNum + 1)
  self:ChangeActorNumLabel(actorType, id, 1)
  return actor
end
function TrialPaibingUILayer:RemoveActor(actor, bAddStep)
  local vec = ActorManager:GetInstance():GetSelfVec()
  for i, v in pairs(vec) do
    if v == actor then
      v:SetRemove(true)
      self:ChangeActorNum(self.m_actorNum - 1)
      local cost = 0
      if v:GetType() == td.ActorType.Soldier then
        cost = ActorInfoManager:GetInstance():GetSoldierInfo(v:GetID()).arena_resource
      elseif v:GetType() == td.ActorType.Hero then
        cost = ActorInfoManager:GetInstance():GetHeroInfo(v:GetID()).arena_resource
      end
      self.m_resNum = self.m_resNum + cost
      self.m_resNumLabel:setString(tostring(self.m_resNum))
      self:ChangeActorNumLabel(v:GetType(), v:GetID(), -1)
      return
    end
  end
end
function TrialPaibingUILayer:RemoveAllActor()
  local vec = ActorManager:GetInstance():GetSelfVec()
  for i, v in pairs(vec) do
    v:SetRemove(true)
  end
  self:ChangeActorNum(0)
  local campLevel = self.m_udMng:GetUserDetail().camp
  self.m_resNum = GameDataManager:GetInstance():GetCurResCount()
  self.m_resNumLabel:setString(tostring(self.m_resNum))
  for i, v in pairs(self.m_soldiers) do
    self.m_soldiers[i] = 0
  end
  for i, v in pairs(self.m_heros) do
    self.m_heros[i] = 0
  end
  self:UpdateActorNum()
end
function TrialPaibingUILayer:ChangeActorNum(num)
  self.m_actorNum = num
  if self.m_actorNum == 0 then
    self.m_buttonstartfight:setDisable(true)
  else
    self.m_buttonstartfight:setDisable(false)
  end
end
function TrialPaibingUILayer:ChangeActorNumLabel(actorType, id, num)
  if actorType == td.ActorType.Hero then
    self.m_heros[id] = self.m_heros[id] + num
  elseif actorType == td.ActorType.Soldier then
    self.m_soldiers[id] = self.m_soldiers[id] + num
  end
  self:UpdateActorNum()
end
function TrialPaibingUILayer:UpdateActorNum()
  if self.m_actorType == td.ActorType.Hero then
    local data = self.m_datas[self.m_selectRoleType]
    for i = 1, 6 do
      if data[i] then
        local num = self.m_heros[data[i]]
        local numLabel = self.m_items[i].numLabel
        numLabel:setString(tostring(num))
      end
    end
  elseif self.m_actorType == td.ActorType.Soldier then
    local data = self.m_datas[self.m_selectRoleType]
    for i = 1, 6 do
      local num = self.m_soldiers[data[i]]
      local numLabel = self.m_items[i].numLabel
      numLabel:setString(tostring(num))
    end
  end
end
function TrialPaibingUILayer:AddTouch()
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    local bTouchInBg = false
    local touchPos = _touch:getLocation()
    local bgRect = self.m_bg:getBoundingBox()
    local pos = self.m_bg:getParent():convertToNodeSpace({
      x = touchPos.x,
      y = touchPos.y
    })
    if cc.rectContainsPoint(bgRect, pos) then
      bTouchInBg = true
    end
    for i = 1, 6 do
      local itemBg = self.m_items[i].itemBg
      local rect = itemBg:getBoundingBox()
      local pos = itemBg:getParent():convertToNodeSpace({
        x = touchPos.x,
        y = touchPos.y
      })
      if cc.rectContainsPoint(rect, pos) then
        local actorId = self.m_datas[self.m_selectRoleType][i]
        if self.m_actorType == td.ActorType.Soldier then
          if UnitDataManager:GetInstance():IsRoleUnlock(actorId) then
            self.m_actorId = actorId
            self:onTouchBegan(itemBg)
            td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
            return true
          end
        elseif self.m_actorType == td.ActorType.Hero then
          for key, var in pairs(self.m_herosData) do
            if math.floor(var.hid / 100) * 100 == actorId then
              self.m_actorId = actorId
              self:onTouchBegan(itemBg)
              return true
            end
          end
        end
        return bTouchInBg
      end
    end
    local vec = ActorManager:GetInstance():GetSelfVec()
    local mapPos = cc.p(pMap:GetMapPosFromWorldPos(touchPos))
    for i, v in pairs(vec) do
      local actorPos = cc.p(v:getPosition())
      local rect = {}
      rect.width = v:GetContentSize().width * v:getScaleX()
      rect.height = v:GetContentSize().height * v:getScaleX()
      rect.x = actorPos.x - rect.width / 2
      rect.y = actorPos.y
      if cc.rectContainsPoint(rect, mapPos) then
        self.m_selectActor = v
        self.m_selectActorPos = actorPos
        self.m_selectActorOffsetPos = cc.p(mapPos.x - self.m_selectActorPos.x, mapPos.y - self.m_selectActorPos.y)
        return true
      end
    end
    return bTouchInBg
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    local touchPos = _touch:getLocation()
    if self.m_selectActor then
      local mapPos = cc.p(pMap:GetMapPosFromWorldPos(touchPos))
      mapPos.x = mapPos.x - self.m_selectActorOffsetPos.x
      mapPos.y = mapPos.y - self.m_selectActorOffsetPos.y
      local mapTilePos = pMap:GetTilePosFromPixelPos(mapPos)
      if pMap:IsWalkable(mapTilePos) then
        self.m_selectActor:setVisible(true)
        self.m_selectActor:setPosition(mapPos)
      else
        self.m_selectActor:setVisible(false)
      end
      self.m_bChanged = true
    elseif self.m_isActive then
      local rect = _event:getCurrentTarget():getBoundingBox()
      local pos = self:getParent():convertToNodeSpace({
        x = touchPos.x,
        y = touchPos.y
      })
      if not cc.rectContainsPoint(rect, pos) then
        self:onTouchMoved(_touch:getLocation())
      end
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(_touch, _event)
    local touchPos = _touch:getLocation()
    local bgRect = self.m_bg:getBoundingBox()
    local pos = self.m_bg:getParent():convertToNodeSpace({
      x = touchPos.x,
      y = touchPos.y
    })
    local bTouchInBg = false
    if cc.rectContainsPoint(bgRect, pos) then
      self:onTouchEnded(_touch:getLocation())
      return
    end
    if self.m_selectActor then
      local mapPos = cc.p(pMap:GetMapPosFromWorldPos(touchPos))
      mapPos.x = mapPos.x - self.m_selectActorOffsetPos.x
      mapPos.y = mapPos.y - self.m_selectActorOffsetPos.y
      local mapTilePos = pMap:GetTilePosFromPixelPos(mapPos)
      if pMap:IsWalkable(mapTilePos) then
        self.m_selectActor:setVisible(true)
        self.m_selectActor:setPosition(mapPos)
      else
        self:RemoveActor(self.m_selectActor, true)
        self.m_selectActor = nil
      end
      self.m_selectActor = nil
      self.m_selectActorPos = {}
    elseif not self.m_isActive then
      GameDataManager:GetInstance():SetFocusNode(nil)
    else
      self:onTouchEnded(_touch:getLocation())
      local rect = self.m_bg:getBoundingBox()
      local pos = self:getParent():convertToNodeSpace({
        x = touchPos.x,
        y = touchPos.y
      })
      if not cc.rectContainsPoint(rect, pos) then
        self:DoFocus(touchPos)
      end
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function TrialPaibingUILayer:onTouchBegan(itemBg)
  if GameDataManager:GetInstance():GetFocusNode() ~= self then
    GameDataManager:GetInstance():SetFocusNode(self)
  end
  if self.m_selectedBg then
    self.m_selectedBg:loadTexture("UI/PVPPaibing/lanse_guang.png")
  end
  self.m_selectedBg = itemBg
  self.m_selectedBg:loadTexture("UI/PVPPaibing/lanse_guang2.png")
end
function TrialPaibingUILayer:onTouchMoved(_pos)
  local pos = self:convertToNodeSpace(cc.p(_pos.x, _pos.y))
  if self.m_skeleton then
    self.m_skeleton:setPosition(pos)
  else
    local fileName
    if self.m_actorType == td.ActorType.Soldier then
      fileName = ActorInfoManager:GetInstance():GetSoldierInfo(self.m_actorId).image
    elseif self.m_actorType == td.ActorType.Hero then
      fileName = ActorInfoManager:GetInstance():GetHeroInfo(self.m_actorId).image
    end
    self.m_skeleton = SkeletonUnit:create(fileName)
    self.m_skeleton:setScale(0.5)
    self.m_skeleton:setPosition(pos)
    self.m_skeleton:addTo(self, 0)
    self.m_skeleton:PlayAni("stand", true, false)
  end
end
function TrialPaibingUILayer:onTouchEnded(_pos)
  if self.m_skeleton then
    self.m_skeleton:removeFromParent()
    self.m_skeleton = nil
  end
end
function TrialPaibingUILayer:StartFight()
  local ActorManager = require("app.actor.ActorManager")
  local vec = ActorManager:GetInstance():GetSelfVec()
  for i, v in pairs(vec) do
    local pos = cc.p(v:getPosition())
    ActorManager:GetInstance():CreateActorPath(v, pos, pos)
  end
  td.dispatchEvent("Temp_trial_start")
  GameDataManager:GetInstance():SetFocusNode(nil)
  self:removeFromParent()
end
function TrialPaibingUILayer:ActiveFocus()
  self.m_isActive = true
end
function TrialPaibingUILayer:InactiveFocus()
  self.m_isActive = false
end
function TrialPaibingUILayer:DoFocus(_pos)
  if self.m_skeleton then
    self.m_skeleton:removeFromParent()
    self.m_skeleton = nil
  end
  if self.m_actorId == 0 then
    return
  end
  local actorId = self.m_actorId
  if self.m_actorType == td.ActorType.Hero then
    local data = self.m_datas[self.m_selectRoleType]
    local num = self.m_heros[self.m_actorId]
    if num >= 1 then
      return
    end
  end
  local pMap = GameDataManager:GetInstance():GetGameMap()
  local mapPos = cc.p(pMap:GetMapPosFromWorldPos(_pos))
  local mapTilePos = pMap:GetTilePosFromPixelPos(mapPos)
  if pMap:IsWalkable(mapTilePos) then
    self:CreateActor(self.m_actorType, actorId, mapPos, true)
    self.m_bChanged = true
  else
    td.alert(g_LM:getBy("a00176"), true)
  end
end
return TrialPaibingUILayer
