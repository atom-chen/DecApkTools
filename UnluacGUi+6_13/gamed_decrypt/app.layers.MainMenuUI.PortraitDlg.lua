local TDHttpRequest = require("app.net.TDHttpRequest")
local BaseDlg = require("app.layers.BaseDlg")
local CommanderInfoManager = require("app.info.CommanderInfoManager")
local UserDataManager = require("app.UserDataManager")
local UnitDataManager = require("app.UnitDataManager")
local PortraitDlg = class("PortraitDlg", BaseDlg)
local Item_Size = cc.size(550, 110)
function PortraitDlg:ctor(curId)
  PortraitDlg.super.ctor(self)
  self.m_curId = curId or 1
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function PortraitDlg:onEnter()
  PortraitDlg.super.onEnter(self)
  self:AddEvents()
end
function PortraitDlg:onExit()
  PortraitDlg.super.onExit(self)
end
function PortraitDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/PortraitDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self:SetTitle(td.Word_Path .. "wenzi_genghuantouxiang.png")
  self.m_panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel")
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(15, 0, Item_Size.width, Item_Size.height * 3.5),
    touchOnContent = true,
    scale = self.m_scale
  })
  self.m_panel:addChild(self.m_UIListView)
  self.m_UIListView:onTouch(function(event)
    if event.name == "clicked" and event.item then
      local itemSize = event.item:getContentSize()
      local insideIndex = math.ceil(event.point.x / (itemSize.width / 5))
      self:OnBtnClicked((event.itemPos - 1) * 5 + insideIndex)
    end
  end)
  self:RefreshList()
end
function PortraitDlg:RefreshList()
  local portraitInfos = CommanderInfoManager:GetInstance():GetAllPortraitInfo()
  itemCount = math.ceil(#portraitInfos / 5)
  self.m_data = {}
  for i, info in ipairs(portraitInfos) do
    if self:CheckUnlock(info) then
      table.insert(self.m_data, info)
    end
  end
  for i, info in ipairs(portraitInfos) do
    if not self:CheckUnlock(info) then
      table.insert(self.m_data, info)
    end
  end
  for i = 1, itemCount do
    local item = self:CreateItem(i)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
end
function PortraitDlg:CreateItem(itemPos)
  local content = display.newNode()
  for i = 1, 5 do
    local index = i + (itemPos - 1) * 5
    local info = self.m_data[index]
    if not info then
      break
    end
    local iconBg = display.newSprite("UI/scale9/touxiangkuang.png")
    iconBg:setTag(self.m_data[index].id)
    iconBg:align(display.LEFT_BOTTOM, 10 + 105 * (i - 1), 0):addTo(content)
    local conSize = iconBg:getContentSize()
    local headSpr
    if self:CheckUnlock(info) then
      headSpr = display.newSprite(info.file .. td.PNG_Suffix)
      if info.id == self.m_curId then
        display.newScale9Sprite("UI/scale9/xuanzhongkuang1.png", 0, 0, cc.size(115, 115)):pos(conSize.width / 2, conSize.height / 2):addTo(iconBg, 2)
      end
    else
      headSpr = display.newGraySprite(info.file .. td.PNG_Suffix)
    end
    headSpr:scale(conSize.width * 0.85 / headSpr:getContentSize().width):pos(conSize.width / 2, conSize.height / 2):addTo(iconBg, 1)
  end
  local item = self.m_UIListView:newItem(content)
  item:setItemSize(Item_Size.width * self.m_scale, Item_Size.height * self.m_scale)
  item:scale(self.m_scale)
  item:setAnchorPoint(0.5, 0.5)
  return item
end
function PortraitDlg:CheckUnlock(info)
  if info.unlock == "0" then
    return true
  end
  local t = string.split(info.unlock, "#")
  if #t < 2 then
    td.alertDebug("Portrait info error,id=" .. info.id)
    return false
  end
  if t[1] == "1" then
    if UnitDataManager:GetInstance():GetSoldierData(tonumber(t[2])) then
      return true
    end
  elseif t[1] == "2" then
    local missionId = tonumber(t[2])
    local missionData = UserDataManager:GetInstance():GetCityData(missionId)
    if missionData then
      return true
    end
  elseif t[1] == "3" then
    local heroId = tonumber(t[2])
    local heros = UserDataManager:GetInstance():GetHeroData()
    for key, var in pairs(heros) do
      if var.hid == heroId then
        return true
      end
    end
  end
  return false
end
function PortraitDlg:OnBtnClicked(index)
  if not self.m_data[index] then
    return
  end
  if not self:CheckUnlock(self.m_data[index]) then
    td.alert(g_LM:getBy("a00350"), true)
    return
  end
  local portraitId = self.m_data[index].id
  if portraitId ~= self.m_curId then
    self:SendModifyReq(portraitId)
    UserDataManager:GetInstance():UpdatePortrait(portraitId)
    td.dispatchEvent(td.MODIFY_PORTRAIT, portraitId)
  end
  self:close()
end
function PortraitDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      return self.m_UIListView:onTouch_({
        name = "began",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    else
      local tmpPos = self.m_panel:convertToNodeSpace(touch:getLocation())
      if not isTouchInNode(self.m_panel, tmpPos) then
        self:performWithDelay(function()
          self:close()
        end, 0.1)
        return false
      end
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
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
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    self.m_UIListView:onTouch_({
      name = "ended",
      x = touch:getLocation().x,
      y = touch:getLocation().y,
      prevX = touch:getPreviousLocation().x,
      prevY = touch:getPreviousLocation().y
    })
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function PortraitDlg:SendModifyReq(id)
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.ModifyUserDetails
  Msg.sendData = {image_id = id}
  tdRequest:Send(Msg)
end
return PortraitDlg
