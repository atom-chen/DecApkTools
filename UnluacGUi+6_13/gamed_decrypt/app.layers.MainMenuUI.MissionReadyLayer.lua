local MissionInfoManager = require("app.info.MissionInfoManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local GuideManager = require("app.GuideManager")
local UserDataManager = require("app.UserDataManager")
local UnitDataManager = require("app.UnitDataManager")
local MessageBoxDlg = require("app.layers.MessageBoxDlg")
local BaseDlg = require("app.layers.BaseDlg")
local MissionReadyLayer = class("MissionReadyLayer", BaseDlg)
local ITEM_SIZE = cc.size(80, 80)
function MissionReadyLayer:ctor(missionId)
  MissionReadyLayer.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.MissionReady
  self.unitMng = UnitDataManager:GetInstance()
  self.aiMng = ActorInfoManager:GetInstance()
  self.vList = {}
  self.m_scale = 1
  self.touchingList = nil
  self.m_bDefense = false
  self.vSelSoldierId = {}
  self:InitData(missionId)
  self:InitUI()
end
function MissionReadyLayer:onEnter()
  MissionReadyLayer.super.onEnter(self)
  self:AddEvents()
  self:CheckGuide()
end
function MissionReadyLayer:onExit()
  MissionReadyLayer.super.onExit(self)
  self:SaveLocalData()
end
function MissionReadyLayer:SaveLocalData()
  local soldierStr = ""
  for i, var in pairs(self.vSelSoldierId) do
    soldierStr = soldierStr .. var .. ","
  end
  if soldierStr ~= "" then
    soldierStr = string.sub(soldierStr, 1, string.len(soldierStr) - 1)
  end
  g_LD:SetStr("soldier_sel", soldierStr)
end
function MissionReadyLayer:InitData(missionId)
  self.m_missionId = missionId
  self.m_missionInfo = MissionInfoManager:GetInstance():GetMissionInfo(self.m_missionId)
  self.m_missionData = UserDataManager:GetInstance():GetCityData(self.m_missionId)
  if self.m_missionData and self.m_missionData.occupation ~= td.OccupState.Normal then
    self.m_bDefense = true
  end
  local selSoldierId = g_LD:GetStr("soldier_sel")
  if selSoldierId ~= "" then
    local tmp = string.split(selSoldierId, ",")
    for i, id in ipairs(tmp) do
      if i > 6 then
        break
      end
      if self.unitMng:GetSoldierNum(tonumber(id)) > 0 then
        self.vSelSoldierId[i] = tonumber(id)
      end
    end
  end
  self.m_data = {
    {},
    {},
    {}
  }
  local unlockId = self.unitMng:GetUnlockedRoleIds()
  for i, id in ipairs(unlockId) do
    local num = self.unitMng:GetSoldierNum(id)
    if num > 0 then
      local info = self.aiMng:GetSoldierInfo(id)
      table.insert(self.m_data[info.career + 1], id)
    end
  end
  for i, var in ipairs(self.m_data) do
    table.sort(var, function(a, b)
      return a % 100 > b % 100
    end)
  end
end
function MissionReadyLayer:InitUI()
  self:LoadUI("CCS/MissionReadyLayer.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetBg("UI/common/uibg2.png")
  self:SetTitle(td.Word_Path .. "wenzi_chuzheng.png")
  self.listBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_BtnStart = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_start")
  td.BtnAddTouch(self.m_BtnStart, handler(self, self.StartGame))
  td.BtnSetTitle(self.m_BtnStart, g_LM:getBy("a00232"))
  self.panelEnemy = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_enemy")
  self.vSoldierBg = {}
  for i = 1, 6 do
    local selBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_soldier" .. i)
    table.insert(self.vSoldierBg, selBg)
  end
  for i, roleId in pairs(self.vSelSoldierId) do
    local icon = self:CreateSoldierIcon(roleId)
    td.AddRelaPos(self.vSoldierBg[i], icon, -1)
    local num = self.unitMng:GetSoldierNum(roleId)
    local numLabel = td.CreateLabel(num, td.WHITE, 18)
    if num <= 0 then
      numLabel:setColor(td.RED)
    end
    td.AddRelaPos(self.vSoldierBg[i], numLabel, 1, cc.p(0.5, 0.1))
  end
  self:CreateList()
  self:CreateEnemyCareer()
end
function MissionReadyLayer:CreateEnemyCareer()
  if self.m_missionInfo.enemy_career == "" then
    self.panelEnemy:setVisible(false)
    return
  end
  local tmp = string.split(self.m_missionInfo.enemy_career, "#")
  for i, var in ipairs(tmp) do
    local icon = td.CreateCareerIcon(tonumber(var))
    icon:scale(0.6):pos(125 + (i - 1) * 40, 70):addTo(self.panelEnemy)
  end
end
function MissionReadyLayer:CreateList()
  for i = 1, 3 do
    do
      local list = cc.ui.UIListView.new({
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
        viewRect = cc.rect(0, 0, 900, 100),
        touchOnContent = false,
        scale = self.m_scale
      })
      list:setName("ListView" .. i)
      list:setAnchorPoint(0, 0)
      td.AddRelaPos(self.listBg, list, 1, cc.p(0.12, 0.68 - 0.32 * (i - 1)))
      table.insert(self.vList, list)
      list:onTouch(function(event)
        if event.name == "clicked" and event.item then
          self:OnItemClicked(i, event)
          td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
        end
      end)
      for i, var in ipairs(self.m_data[i]) do
        local itemBg = self:CreateItem(var)
        local item = list:newItem(itemBg)
        item:setItemSize((ITEM_SIZE.width + 10) * self.m_scale, ITEM_SIZE.height * self.m_scale)
        list:addItem(item)
      end
      list:reload()
    end
  end
end
function MissionReadyLayer:OnItemClicked(listId, event)
  local roleId = self.m_data[listId][event.itemPos]
  for i, var in pairs(self.vSelSoldierId) do
    if var == roleId then
      if GuideManager:GetInstance():IsForceGuideOver() then
        self.vSelSoldierId[i] = nil
        self.vSoldierBg[i]:removeAllChildren()
        local checkSpr = event.item:getContent():getChildByName("check")
        if checkSpr then
          checkSpr:removeFromParent()
        end
      end
      return
    end
  end
  local emptyIndex
  for i = 1, 6 do
    if not self.vSelSoldierId[i] then
      emptyIndex = i
      break
    end
  end
  if emptyIndex then
    self.vSelSoldierId[emptyIndex] = roleId
    local icon = self:CreateSoldierIcon(roleId)
    td.AddRelaPos(self.vSoldierBg[emptyIndex], icon, -1)
    local num = self.unitMng:GetSoldierNum(roleId)
    local numLabel = td.CreateLabel(num, td.WHITE, 18)
    if num <= 0 then
      numLabel:setColor(td.RED)
    end
    td.AddRelaPos(self.vSoldierBg[emptyIndex], numLabel, 1, cc.p(0.5, 0.1))
    local checkSpr = display.newSprite("UI/common/gouxuan.png")
    checkSpr:setName("check")
    td.AddRelaPos(event.item:getContent(), checkSpr, 3, cc.p(0.8, 0.2))
  else
    td.alertErrorMsg(td.ErrorCode.POPU_MAX)
  end
end
function MissionReadyLayer:CreateItem(roleId)
  local itemBg = display.newScale9Sprite("UI/scale9/touxiangdi3.png", 0, 0, cc.size(ITEM_SIZE.width * 0.9, ITEM_SIZE.height * 0.9))
  itemBg:setScale(self.m_scale)
  local info = self.aiMng:GetSoldierInfo(roleId)
  local soldierIcon = display.newSprite(info.head .. td.PNG_Suffix)
  soldierIcon:scale(0.8)
  td.AddRelaPos(itemBg, soldierIcon)
  local borderSpr = display.newSprite("UI/battle/yingxiongkuang1.png")
  borderSpr:scale(0.7)
  td.AddRelaPos(itemBg, borderSpr, 1, cc.p(0.5, 0.4))
  local num = self.unitMng:GetSoldierNum(roleId)
  local numLabel = td.CreateLabel(num, td.WHITE, 18)
  if num <= 0 then
    numLabel:setColor(td.RED)
  end
  td.AddRelaPos(itemBg, numLabel, 2, cc.p(0.5, -0.06))
  if self:_isSoldierSel(roleId) then
    local checkSpr = display.newSprite("UI/common/gouxuan.png")
    checkSpr:setName("check")
    td.AddRelaPos(itemBg, checkSpr, 3, cc.p(0.8, 0.2))
  end
  return itemBg
end
function MissionReadyLayer:StartGame()
  if table.nums(self.vSelSoldierId) == 0 then
    td.alert("\232\175\183\229\133\136\233\128\137\230\139\169\228\184\138\233\152\181\229\163\171\229\133\181")
    return
  end
  if self.m_missionData and self.m_missionData.occupation ~= td.OccupState.Normal then
    local loadingScene = require("app.scenes.LoadingScene").new(self.m_missionInfo.defense_mission, self.m_missionId, self.vSelSoldierId)
    cc.Director:getInstance():replaceScene(loadingScene)
  else
    local loadingScene = require("app.scenes.LoadingScene").new(self.m_missionId, self.m_missionId, self.vSelSoldierId)
    cc.Director:getInstance():replaceScene(loadingScene)
  end
end
function MissionReadyLayer:CreateSoldierIcon(roleId)
  local info = self.aiMng:GetSoldierInfo(roleId)
  local soldierIcon = display.newSprite(info.head .. td.PNG_Suffix)
  return soldierIcon
end
function MissionReadyLayer:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    for i, list in ipairs(self.vList) do
      if list:isTouchInViewRect({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.touchingList = list
        self.touchingList:onTouch_({
          name = "began",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
        break
      end
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.touchingList then
      if self.touchingList:isTouchInViewRect({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.touchingList:onTouch_({
          name = "moved",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
      end
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    if self.touchingList then
      self.touchingList:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
      self.touchingList = nil
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
function MissionReadyLayer:_isSoldierSel(roleId)
  for i, var in pairs(self.vSelSoldierId) do
    if var == roleId then
      return true
    end
  end
  return false
end
return MissionReadyLayer
