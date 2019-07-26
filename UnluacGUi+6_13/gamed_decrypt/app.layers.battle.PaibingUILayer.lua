local BaseUILayer = require("app.layers.BaseUILayer")
local StrongInfoManager = require("app.info.StrongInfoManager")
local ActorManager = require("app.actor.ActorManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local UnitDataManager = require("app.UnitDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local PaibingUILayer = class("PaibingUILayer", BaseUILayer)
local StepType_Create = 1
local StepType_Remove = 2
local StepType_Move = 3
local Item_Size = cc.size(550, 150)
function PaibingUILayer:ctor()
  PaibingUILayer.super.ctor(self)
  self.m_uiId = td.UIModule.PVPBattleUI
  self.m_scale = td.GetAutoScale()
  self.tabIndex = 0
  self.m_tabs = {}
  self.subTabIndex = 0
  self.subTabs = {}
  self.m_selectActor = nil
  self.m_selectActorPos = {}
  self.m_actorNum = 0
  self.m_actorId = 0
  self.m_actorUid = 0
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
    self.m_heros[i] = 0
  end
  self.leaveCb = nil
  self.startCb = nil
  self.lackResCb = nil
  self.initHeroItems = {}
  self.initSoldierItems = {}
  self:InitUI()
end
function PaibingUILayer:onEnter()
  self:AddCustomEvent(td.UPDATE_RESOURCE, handler(self, self.UpdateRes))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
  self:performWithDelay(function()
    self:initActor()
    self:CheckGuide()
    self:AddTouch()
  end, 0.1)
end
function PaibingUILayer:onExit()
  PaibingUILayer.super.onExit(self)
end
function PaibingUILayer:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/PaibingDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self.m_pPanel_top = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_top")
  td.SetAutoScale(self.m_pPanel_top, td.UIPosHorizontal.Left, td.UIPosVertical.Top)
  self.m_pPanel_middle = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_middle")
  td.SetAutoScale(self.m_pPanel_middle, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_pPanel_bottom = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bottom")
  td.SetAutoScale(self.m_pPanel_bottom, td.UIPosHorizontal.Center, td.UIPosVertical.Bottom)
  local popbg = cc.uiloader:seekNodeByName(self.m_pPanel_top, "popbg")
  self.m_popNumLabel = td.CreateLabel(string.format("0/%d", self.m_gdMng:GetMaxPopulation()))
  self.m_popNumLabel:setAnchorPoint(cc.p(0.5, 0.5))
  self.m_popNumLabel:setPosition(cc.p(popbg:getContentSize().width / 2 + 5, popbg:getContentSize().height / 2))
  popbg:addChild(self.m_popNumLabel)
  local btnLeave = ccui.Button:create(td.Word_Path .. "likai1.png", td.Word_Path .. "likai2.png")
  btnLeave:pos(20, 8):addTo(self.m_pPanel_bottom)
  btnLeave:setAnchorPoint(0, 0)
  td.BtnAddTouch(btnLeave, handler(self, self.Leave))
  local btnClear = cc.uiloader:seekNodeByName(self.m_pPanel_middle, "Button_clear_4")
  btnClear:setPressedActionEnabled(true)
  td.BtnAddTouch(btnClear, handler(self, self.RemoveAllActor))
  td.BtnSetTitle(btnClear, g_LM:getBy("a00158"))
  self.m_btnStart = cc.uiloader:seekNodeByName(self.m_pPanel_middle, "Button_start")
  self.m_btnStart:setDisable(true)
  self.m_btnStart:setPressedActionEnabled(true)
  td.BtnAddTouch(self.m_btnStart, handler(self, self.StartFight))
  td.BtnSetTitle(self.m_btnStart, g_LM:getBy("a00102"))
  self.m_bg = cc.uiloader:seekNodeByName(self.m_pPanel_middle, "bg")
  self.m_childTab = {
    cc.uiloader:seekNodeByName(self.m_bg, "role1"),
    cc.uiloader:seekNodeByName(self.m_bg, "role2"),
    cc.uiloader:seekNodeByName(self.m_bg, "role3"),
    cc.uiloader:seekNodeByName(self.m_bg, "role4"),
    cc.uiloader:seekNodeByName(self.m_bg, "role5"),
    cc.uiloader:seekNodeByName(self.m_bg, "role6")
  }
  self:CreateListView()
  self:CreateTopTab()
end
function PaibingUILayer:CreateTopTab()
  local bingzhong = ccui.ImageView:create(td.Word_Path .. "bingzhong1_button.png"):pos(147, 592):addTo(self.m_bg)
  bingzhong:setTouchEnabled(true)
  bingzhong:addTouchEventListener(function(sender, eventType)
    if ccui.TouchEventType.ended == eventType then
      self:OnTabClicked(1)
    end
  end)
  self.m_tabs[1] = bingzhong
  local yingxiong = ccui.ImageView:create(td.Word_Path .. "yingxiong2_button.png"):pos(415, 592):addTo(self.m_bg)
  yingxiong:setName("hero_tab")
  yingxiong:setTouchEnabled(true)
  yingxiong:addTouchEventListener(function(sender, eventType)
    if ccui.TouchEventType.ended == eventType then
      self:OnTabClicked(2)
      td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
    end
  end)
  self.m_tabs[2] = yingxiong
  self:OnTabClicked(1)
end
function PaibingUILayer:CreateSoldierTab()
  self.m_datas = {}
  for i = 1, 6 do
    do
      local btn = self.m_childTab[i]
      btn:setVisible(true)
      btn:setTouchEnabled(true)
      btn:addTouchEventListener(function(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
          self:OnSubTabClicked(i)
        end
      end)
      self.subTabs[i] = btn
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
  end
  self:OnSubTabClicked(1)
end
function PaibingUILayer:OnTabClicked(index)
  if self.tabIndex == index then
    return
  end
  self.tabIndex = index
  self.subTabIndex = 0
  if index == 1 then
    self:CreateBingzhong()
    self.m_tabs[1]:loadTexture(td.Word_Path .. "bingzhong1_button.png")
    self.m_tabs[2]:loadTexture(td.Word_Path .. "yingxiong2_button.png")
  else
    self:CreateYingxiong()
    self.m_tabs[1]:loadTexture(td.Word_Path .. "bingzhong2_button.png")
    self.m_tabs[2]:loadTexture(td.Word_Path .. "yingxiong1_button.png")
  end
  self:CancelSelected()
end
function PaibingUILayer:OnSubTabClicked(index)
  if self.subTabIndex == index then
    return
  end
  self.subTabIndex = index
  self.m_selectSprite:setVisible(true)
  if self.m_selectSprite:getParent() then
    self.m_selectSprite:retain()
    self.m_selectSprite:removeFromParent()
  end
  self.m_selectSprite:setPosition(cc.p(self.m_childTab[index]:getContentSize().width / 2, self.m_childTab[index]:getContentSize().height / 2))
  self.m_childTab[index]:addChild(self.m_selectSprite)
  self.m_selectSprite:release()
  local data = self.m_datas[self.subTabIndex]
  self:RefreshList(data, td.ActorType.Soldier)
  self:UpdateActorNum()
  self:CancelSelected()
  td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
end
function PaibingUILayer:CreateListView()
  if self.m_UIListView then
    return
  end
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(6, 260, 550, 300),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_UIListView:onTouch(function(event)
    if event.name == "clicked" and event.item then
      local itemSize = event.item:getContentSize()
      local insideIndex = math.ceil(event.point.x / (itemSize.width / 3))
      self:OnItemClicked(event.itemPos, insideIndex)
    end
  end)
  self.m_UIListView:setName("ListView")
  self.m_UIListView:addTo(self.m_bg)
end
function PaibingUILayer:OnItemClicked(itemPos, insideIndex)
  local listItem = self.m_UIListView:getItemByPos(itemPos)
  local itemBg = listItem:getContent():getChildByTag(insideIndex)
  local index = (itemPos - 1) * 3 + insideIndex
  if self.tabIndex == 1 then
    local actorId = self.m_datas[self.subTabIndex][index]
    if UnitDataManager:GetInstance():IsRoleUnlock(actorId) then
      self.m_actorId = actorId
      self:onTouchBegan(itemBg)
      td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
    end
  elseif self.tabIndex == 2 then
    local actorId = self.m_datas[1][index]
    for key, var in pairs(self.m_herosData) do
      if math.floor(var.hid / 100) * 100 == actorId then
        self.m_actorId = actorId
        self:onTouchBegan(itemBg)
        td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
      end
    end
  end
end
function PaibingUILayer:RefreshList(data, type)
  self.m_UIListView:removeAllItems()
  self.m_selectedBg = nil
  local itemCount = math.ceil(table.nums(data) / 3)
  for i = 1, itemCount do
    local item = self:CreateItem(data, i, type)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function PaibingUILayer:CreateItem(data, pos, type)
  local content = display.newNode()
  content:scale(self.m_scale)
  content:setContentSize(Item_Size)
  for i = 1, 3 do
    local iconBg = ccui.ImageView:create("UI/PVPPaibing/lanse_guang.png")
    iconBg:scale(1.25)
    iconBg:setTag(i)
    iconBg:pos(95 + 180 * (i - 1), 95):addTo(content)
    local labelBg = display.newSprite("UI/scale9/shuliangdikuang.png")
    labelBg:scale(0.8)
    labelBg:setName("labelBg")
    td.AddRelaPos(iconBg, labelBg, 1, cc.p(0.5, -0.1))
    local idx = (pos - 1) * 3 + i
    local info, isUnlock = nil, false
    if type == td.ActorType.Soldier then
      info = ActorInfoManager:GetInstance():GetSoldierInfo(data[idx])
      isUnlock = UnitDataManager:GetInstance():IsRoleUnlock(data[idx])
    elseif type == td.ActorType.Hero and data[idx] then
      info = ActorInfoManager:GetInstance():GetHeroInfo(data[idx])
      for id, var in pairs(self.m_herosData) do
        if math.floor(var.hid / 100) * 100 == data[idx] then
          info = var.heroInfo
          isUnlock = true
        end
      end
    end
    if info and isUnlock then
      local skelton = SkeletonUnit:create(info.image)
      skelton:PlayAni("stand")
      skelton:setTag(11)
      skelton:setScale(0.5 * info.scale)
      skelton:setAnchorPoint(cc.p(0.5, 0))
      td.AddRelaPos(iconBg, skelton, 1, cc.p(0.5, 0.15))
      local icon = display.newSprite("UI/icon/renkou_icon.png")
      icon:scale(0.5)
      td.AddRelaPos(labelBg, icon, 1, cc.p(0.4, 0.5))
      local costLabel = td.CreateLabel(info.space or 0, td.LIGHT_BLUE, 16)
      costLabel:setName("cost")
      costLabel:align(display.LEFT_CENTER, 55, 17):addTo(labelBg)
      local numLabel = td.CreateLabel("0", td.LIGHT_BLUE, 18)
      numLabel:setName("num")
      numLabel:pos(15, 17):addTo(labelBg)
    else
      local lock = display.newSprite("UI/common/suo_icon2.png")
      lock:setTag(11)
      td.AddRelaPos(iconBg, lock)
    end
  end
  local item = self.m_UIListView:newItem(content)
  item:setItemSize(Item_Size.width * self.m_scale, Item_Size.height * self.m_scale)
  return item
end
function PaibingUILayer:CancelSelected()
  if self.m_selectedBg then
    self.m_selectedBg:loadTexture("UI/PVPPaibing/lanse_guang.png")
    self.m_selectedBg = nil
  end
  self.m_actorId = nil
  self.m_gdMng:SetFocusNode(nil)
end
function PaibingUILayer:CreateBingzhong()
  if not self.m_selectSprite then
    self.m_selectSprite = display.newSprite("UI/PVPPaibing/xuanzhongwaifaguang.png")
    self.m_selectSprite:retain()
  end
  self:CreateSoldierTab()
end
function PaibingUILayer:CreateYingxiong()
  for i = 1, 6 do
    self.m_childTab[i]:setVisible(false)
  end
  if self.m_selectSprite then
    self.m_selectSprite:setVisible(false)
  end
  self.m_datas = {}
  local infos = ActorInfoManager:GetInstance():GetHeroInfos()
  local data = table.keys(infos)
  table.sort(data, function(a, b)
    return a < b
  end)
  table.insert(self.m_datas, data)
  self:RefreshList(self.m_datas[1], td.ActorType.Hero)
end
function PaibingUILayer:initActor()
  for i, v in ipairs(self.initHeroItems) do
    local heroId = v.id
    self:CreateActor(td.ActorType.Hero, heroId, cc.p(v.x, v.y), false)
  end
  for i, v in ipairs(self.initSoldierItems) do
    self:CreateActor(td.ActorType.Soldier, v.id, cc.p(v.x, v.y), false)
  end
end
function PaibingUILayer:CreateActor(actorType, id, pos, bAddStep)
  local bCan, errorCode = self:CheckCanAdd(actorType, id)
  if not bCan then
    td.alertErrorMsg(errorCode)
    return
  end
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
function PaibingUILayer:CheckCanAdd(actorType, id)
  if actorType == td.ActorType.Soldier then
    local info = ActorInfoManager:GetInstance():GetSoldierInfo(id)
    local curPopu = self.m_gdMng:GetCurPopulation()
    local maxPopu = self.m_gdMng:GetMaxPopulation()
    if maxPopu < curPopu + info.space then
      return false, td.ErrorCode.POPU_MAX
    end
  elseif actorType == td.ActorType.Hero then
    local heroNum = 0
    for id, var in pairs(self.m_heros) do
      heroNum = heroNum + var
    end
    if heroNum >= 3 then
      return false, g_LM:getBy("a00326")
    end
  end
  return true, td.ErrorCode.SUCCESS
end
function PaibingUILayer:RemoveActor(actor, bAddStep)
  local vec = ActorManager:GetInstance():GetSelfVec()
  for i, v in pairs(vec) do
    if v == actor then
      v:SetRemove(true)
      self:ChangeActorNum(self.m_actorNum - 1)
      self:ChangeActorNumLabel(v:GetType(), v:GetID(), -1)
      return
    end
  end
end
function PaibingUILayer:RemoveAllActor()
  local vec = ActorManager:GetInstance():GetSelfVec()
  for i, v in pairs(vec) do
    v:SetRemove(true)
  end
  self:ChangeActorNum(0)
  for id, v in pairs(self.m_soldiers) do
    self.m_soldiers[id] = 0
  end
  for id, v in pairs(self.m_heros) do
    self.m_heros[id] = 0
  end
  self:UpdateActorNum()
  self.m_gdMng:UpdateCurPopulation(-self.m_gdMng:GetCurPopulation())
  self.m_popNumLabel:setString("0/" .. self.m_gdMng:GetMaxPopulation())
end
function PaibingUILayer:ChangeActorNum(num)
  self.m_actorNum = num
  if self.m_actorNum == 0 then
    self.m_btnStart:setDisable(true)
  else
    self.m_btnStart:setDisable(false)
  end
end
function PaibingUILayer:ChangeActorNumLabel(actorType, id, num)
  if actorType == td.ActorType.Hero then
    self.m_heros[id] = self.m_heros[id] + num
  elseif actorType == td.ActorType.Soldier then
    self.m_soldiers[id] = self.m_soldiers[id] + num
    local info = ActorInfoManager:GetInstance():GetSoldierInfo(id)
    local curPop = self.m_gdMng:UpdateCurPopulation(num * info.space)
    local maxPop = self.m_gdMng:GetMaxPopulation()
    self.m_popNumLabel:setString(string.format("%d/%d", curPop, maxPop))
  end
  self:UpdateActorNum()
end
function PaibingUILayer:UpdateActorNum()
  if self.tabIndex == 2 then
    local data = self.m_datas[1]
    for i = 1, 9 do
      if data[i] then
        local num = self.m_heros[data[i]]
        local listItem = self.m_UIListView:getItemByPos(math.ceil(i / 3))
        local item = listItem:getContent():getChildByTag((i - 1) % 3 + 1)
        local numLabel = item:getChildByName("labelBg"):getChildByName("num")
        if numLabel then
          numLabel:setString(tostring(num))
        end
      end
    end
  elseif self.tabIndex == 1 then
    local data = self.m_datas[self.subTabIndex]
    for i = 1, 6 do
      local info = ActorInfoManager:GetInstance():GetSoldierInfo(data[i])
      local num = self.m_soldiers[data[i]]
      local listItem = self.m_UIListView:getItemByPos(math.ceil(i / 3))
      local item = listItem:getContent():getChildByTag((i - 1) % 3 + 1)
      local numLabel = item:getChildByName("labelBg"):getChildByName("num")
      if numLabel then
        numLabel:setString(tostring(num))
      end
    end
  end
end
function PaibingUILayer:UpdateRes()
end
function PaibingUILayer:HadChanged()
  return self.m_bChanged
end
function PaibingUILayer:SetInitData(heroItems, soldierItems)
  self.initHeroItems = heroItems
  self.initSoldierItems = soldierItems
end
function PaibingUILayer:SetStartCb(cb)
  self.startCb = cb
end
function PaibingUILayer:SetLeaveCb(cb)
  self.leaveCb = cb
end
function PaibingUILayer:SetLackResCb(cb)
  self.lackResCb = cb
end
function PaibingUILayer:SetStartBtnTitle(str)
  td.BtnSetTitle(self.m_btnStart, str)
end
function PaibingUILayer:HideTopTab()
  for i, tab in ipairs(self.m_tabs) do
    tab:setVisible(false)
  end
end
function PaibingUILayer:StartFight()
  local ActorManager = require("app.actor.ActorManager")
  local heroStr = ""
  local soldierStr = ""
  local vec = ActorManager:GetInstance():GetSelfVec()
  for i, v in pairs(vec) do
    local actorType = v:GetType()
    local pos = cc.p(v:getPosition())
    local id = v:GetData().id
    if actorType == td.ActorType.Hero then
      if heroStr ~= "" then
        heroStr = heroStr .. ";"
      end
      heroStr = heroStr .. tostring(id) .. ":" .. tostring(math.floor(pos.x)) .. ":" .. tostring(math.floor(pos.y))
    elseif actorType == td.ActorType.Soldier then
      if soldierStr ~= "" then
        soldierStr = soldierStr .. ";"
      end
      soldierStr = soldierStr .. tostring(id) .. ":" .. tostring(math.floor(pos.x)) .. ":" .. tostring(math.floor(pos.y))
    end
  end
  if self.startCb then
    self.startCb(heroStr, soldierStr)
  end
end
function PaibingUILayer:Leave()
  if self.leaveCb then
    self.leaveCb()
  end
end
function PaibingUILayer:Close()
  self.m_gdMng:SetFocusNode(nil)
  self.m_gdMng:GetGameMap():SetIsTouchable(true)
  self:removeFromParent()
end
function PaibingUILayer:AddTouch()
  local pMap = self.m_gdMng:GetGameMap()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, _event)
    if self.m_UIListView then
      if self.m_UIListView:isTouchInViewRect({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.m_UIListView:onTouch_({
          name = "began",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
        self.m_bTouchInList = true
        return true
      end
    else
      local touchPos = touch:getLocation()
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
      local tmpPos = self.m_bg:convertToNodeSpace(touchPos)
      if isTouchInNode(self.m_bg, tmpPos) then
        return true
      end
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, _event)
    if self.m_bTouchInList then
      if self.m_UIListView:isTouchInViewRect({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.m_UIListView:onTouch_({
          name = "moved",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
      end
    else
      local touchPos = touch:getLocation()
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
          self:onTouchMoved(touch:getLocation())
        end
      end
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, _event)
    if self.m_bTouchInList then
      self.m_UIListView:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
      self.m_bTouchInList = false
    else
      local touchPos = touch:getLocation()
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
        self.m_gdMng:SetFocusNode(nil)
      else
        self:onTouchEnded(touch:getLocation())
        local tmpPos = self.m_bg:convertToNodeSpace(touchPos)
        if not isTouchInNode(self.m_bg, tmpPos) then
          self:DoFocus(touchPos)
        end
      end
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function PaibingUILayer:onTouchBegan(itemBg)
  if self.m_gdMng:GetFocusNode() ~= self then
    self.m_gdMng:SetFocusNode(self)
  end
  if self.m_selectedBg then
    self.m_selectedBg:loadTexture("UI/PVPPaibing/lanse_guang.png")
  end
  self.m_selectedBg = itemBg
  self.m_selectedBg:loadTexture("UI/PVPPaibing/lanse_guang2.png")
end
function PaibingUILayer:onTouchMoved(_pos)
  local pos = self:convertToNodeSpace(cc.p(_pos.x, _pos.y))
  if self.m_skeleton then
    self.m_skeleton:setPosition(pos)
  else
    local fileName
    if self.tabIndex == 1 then
      fileName = ActorInfoManager:GetInstance():GetSoldierInfo(self.m_actorId).image
    elseif self.tabIndex == 2 then
      fileName = ActorInfoManager:GetInstance():GetHeroInfo(self.m_actorId).image
    end
    self.m_skeleton = SkeletonUnit:create(fileName)
    self.m_skeleton:setScale(0.5)
    self.m_skeleton:setPosition(pos)
    self.m_skeleton:addTo(self, 0)
    self.m_skeleton:PlayAni("stand", true, false)
  end
end
function PaibingUILayer:onTouchEnded(_pos)
  if self.m_skeleton then
    self.m_skeleton:removeFromParent()
    self.m_skeleton = nil
  end
end
function PaibingUILayer:ActiveFocus()
  self.m_isActive = true
end
function PaibingUILayer:InactiveFocus()
  self.m_isActive = false
end
function PaibingUILayer:DoFocus(_pos)
  if self.m_skeleton then
    self.m_skeleton:removeFromParent()
    self.m_skeleton = nil
  end
  if self.m_actorId == 0 then
    return
  end
  local actorId = self.m_actorId
  if self.tabIndex == 2 then
    local data = self.m_datas[1]
    local num = self.m_heros[self.m_actorId]
    if num >= 1 then
      return
    end
  end
  local pMap = self.m_gdMng:GetGameMap()
  local mapPos = cc.p(pMap:GetMapPosFromWorldPos(_pos))
  local mapTilePos = pMap:GetTilePosFromPixelPos(mapPos)
  if pMap:IsWalkable(mapTilePos) then
    td.dispatchEvent(td.GUIDE_FINISHED, td.UIModule.BattleScene)
    local actorType = self.tabIndex == 1 and td.ActorType.Soldier or td.ActorType.Hero
    self:CreateActor(actorType, actorId, mapPos, true)
    self.m_bChanged = true
  else
    td.alert(g_LM:getBy("a00176"), true)
  end
end
return PaibingUILayer
