local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
local TabButton = require("app.widgets.TabButton")
local GuildPVPLogDlg = class("GuildPVPLogDlg", BaseDlg)
local ITEM_SIZE = cc.size(815, 80)
function GuildPVPLogDlg:ctor(index)
  GuildPVPLogDlg.super.ctor(self, 200)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_pvpData = self.m_udMng:GetGuildManager():GetGuildPVPData()
  self.m_vLogData = nil
  self.m_vResData = nil
  self.m_vHeaderLabel = {}
  self:InitUI()
end
function GuildPVPLogDlg:onEnter()
  GuildPVPLogDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GuildPVPLog, handler(self, self.LogCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GuildPVPResLog, handler(self, self.LogResCallback))
  self:AddEvents()
  self:PlayEnterAni()
end
function GuildPVPLogDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GuildPVPLog)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GuildPVPResLog)
  GuildPVPLogDlg.super.onExit(self)
end
function GuildPVPLogDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/guild/GuildPVPLogDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local closeBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_close")
  td.BtnSetTitle(closeBtn, g_LM:getBy("a00164"))
  self:setCloseBtn(closeBtn)
  self:CreateList()
  self:CreateTabs()
end
function GuildPVPLogDlg:PlayEnterAni(cb)
  local lightImg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_btmLight")
  lightImg:runAction(cca.seq({
    cca.moveBy(0.3, 0, -360),
    cca.cb(function()
      self.m_bg:runAction(cca.seq({
        cca.fadeIn(0.3),
        cca.cb(cb)
      }))
    end)
  }))
end
function GuildPVPLogDlg:CreateTabs()
  local buttons = {}
  local tabTitles = {
    "\230\136\152\230\138\165",
    "\232\181\132\230\186\144\232\175\166\230\131\133"
  }
  local tabConfig = {
    "UI/arena/tiaozhan%d_icon.png",
    "UI/arena/zhandourizhi%d_icon.png"
  }
  for i = 1, 2 do
    local _tab = ccui.ImageView:create(string.format(tabConfig[i], 2))
    td.AddRelaPos(self.m_bg, _tab, 1, cc.p(-0.1, 1.1 - i * 0.4))
    local tabButton = {
      tab = _tab,
      text = tabTitles[i],
      callfunc = handler(self, self.RefreshList),
      normalImageFile = string.format(tabConfig[i], 2),
      highImageFile = string.format(tabConfig[i], 1)
    }
    table.insert(buttons, tabButton)
  end
  local tabButtons = TabButton.new(buttons, {
    textSize = 24,
    normalTextColor = td.LIGHT_BLUE,
    highTextColor = td.YELLOW,
    textPos = cc.p(0.5, -0.4)
  })
end
function GuildPVPLogDlg:CreateList()
  local listView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 815, 400),
    touchOnContent = false,
    scale = self.m_scale
  })
  listView:setAnchorPoint(cc.p(0, 0))
  listView:pos(0, 0):addTo(self.m_bg)
  self.m_UIListView = listView
end
function GuildPVPLogDlg:CreateListHeader(tabIndex)
  for i, var in ipairs(self.m_vHeaderLabel) do
    var:removeFromParent()
  end
  self.m_vHeaderLabel = {}
  local headerConfig = {
    {
      {
        str = "\230\136\145\230\150\185\229\134\155\229\155\162\230\136\144\229\145\152",
        x = 0.15
      },
      {
        str = "\230\149\140\230\150\185\229\134\155\229\155\162\230\136\144\229\145\152",
        x = 0.44
      }
    },
    {
      {
        str = g_LM:getBy("a00031"),
        x = 0.1
      },
      {
        str = "\231\180\175\232\174\161\232\142\183\229\190\151\232\181\132\230\186\144",
        x = 0.44
      },
      {
        str = "\232\142\183\232\131\156\230\172\161\230\149\176",
        x = 0.77
      }
    }
  }
  for i, var in ipairs(headerConfig[tabIndex]) do
    local label = td.CreateLabel(var.str, td.BLUE, 20)
    label:setAnchorPoint(0, 0.5)
    td.AddRelaPos(self.m_bg, label, 1, cc.p(var.x, 1.05))
    table.insert(self.m_vHeaderLabel, label)
  end
end
function GuildPVPLogDlg:RefreshList(tabIndex)
  self:CreateListHeader(tabIndex)
  if tabIndex == 1 then
    if self.m_vLogData then
      self:RefreshLogList()
    else
      self:SendLogReq()
    end
  elseif self.m_vResData then
    self:RefreshResList()
  else
    self:SendLogResReq()
  end
end
function GuildPVPLogDlg:RefreshResList()
  self.m_UIListView:removeAllItems()
  for i, var in ipairs(self.m_vResData) do
    local playerData = clone(self.m_pvpData:GetMemberData(var.uid))
    if playerData then
      playerData.res = var.award
      playerData.win_num = var.win_num
      local listItem = self:CreateResItem(playerData)
      self.m_UIListView:addItem(listItem)
    end
  end
  self.m_UIListView:reload()
end
function GuildPVPLogDlg:RefreshLogList()
  self.m_UIListView:removeAllItems()
  local num = #self.m_vLogData
  for i = num, 1, -1 do
    local listItem = self:CreateItem(self.m_vLogData[i])
    self.m_UIListView:addItem(listItem)
  end
  self.m_UIListView:reload()
end
function GuildPVPLogDlg:CreateItem(data)
  local itemNode = display.newNode()
  itemNode:setContentSize(ITEM_SIZE)
  itemNode:scale(self.m_scale)
  local selfGuildId = self.m_pvpData:GetValue("guildId")
  local bWin = true
  local vPlayerData = {}
  if data.guild1 == selfGuildId then
    table.insert(vPlayerData, {
      name = data.name1,
      head = data.image1
    })
    table.insert(vPlayerData, {
      name = data.name2,
      head = data.image2
    })
    bWin = data.result == 0
  else
    table.insert(vPlayerData, {
      name = data.name2,
      head = data.image2
    })
    table.insert(vPlayerData, {
      name = data.name1,
      head = data.image1
    })
    bWin = data.result ~= 0
  end
  local winFile = "UI/arena/shengli_icon.png"
  if not bWin then
    winFile = "UI/arena/shibai_icon.png"
  end
  local winSpr = display.newSprite(winFile)
  td.AddRelaPos(itemNode, winSpr, 1, cc.p(0.08, 0.5))
  for i = 1, 2 do
    local playerData = vPlayerData[i]
    local imageHead = display.newSprite(td.GetPortrait(playerData.head))
    imageHead:scale(0.3)
    td.AddRelaPos(itemNode, imageHead, 1, cc.p(0.18 + (i - 1) * 0.3, 0.5))
    local conSize = imageHead:getContentSize()
    local headBg = display.newScale9Sprite("UI/scale9/touxiangkuang5.png", 0, 0, cc.size(conSize.width + 10, conSize.height + 10))
    td.AddRelaPos(imageHead, headBg, -1)
    local nameColor = i == 1 and td.LIGHT_BLUE or td.RED
    local labelName = td.CreateLabel(playerData.name, nameColor)
    labelName:setAnchorPoint(0, 0.5)
    td.AddRelaPos(itemNode, labelName, 1, cc.p(0.22 + (i - 1) * 0.3, 0.5))
  end
  local dateLabel = td.CreateLabel(os.date("%Y/%m/%d %H:%M:%S", data.ctime), td.BLUE, 18)
  td.AddRelaPos(itemNode, dateLabel, 1, cc.p(0.85, 0.5))
  local vsSpr = display.newSprite("UI/guild/vs.png")
  vsSpr:scale(0.5)
  td.AddRelaPos(itemNode, vsSpr, 1, cc.p(0.4, 0.5))
  local lineSpr = display.newSprite("UI/common/fengexian_shu.png")
  lineSpr:setScaleX(ITEM_SIZE.width / lineSpr:getContentSize().width)
  td.AddRelaPos(itemNode, lineSpr, 1, cc.p(0.5, 0))
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize(ITEM_SIZE.width * self.m_scale, (ITEM_SIZE.height + 5) * self.m_scale)
  return item
end
function GuildPVPLogDlg:CreateResItem(data)
  local itemNode = display.newNode()
  itemNode:setContentSize(ITEM_SIZE)
  itemNode:scale(self.m_scale)
  local imageHead = display.newSprite(td.GetPortrait(data.image_id))
  imageHead:scale(0.3)
  td.AddRelaPos(itemNode, imageHead, 1, cc.p(0.1, 0.5))
  local conSize = imageHead:getContentSize()
  local headBg = display.newScale9Sprite("UI/scale9/touxiangkuang5.png", 0, 0, cc.size(conSize.width + 10, conSize.height + 10))
  td.AddRelaPos(imageHead, headBg, -1)
  local labelName = td.CreateLabel(data.uname, td.LIGHT_BLUE)
  labelName:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itemNode, labelName, 1, cc.p(0.15, 0.5))
  if not data.isSelf then
    labelName:setColor(td.RED)
  end
  local resLabel = td.RichText({
    {
      type = 2,
      file = "UI/icon/yuanli1_wupin.png",
      scale = 1
    },
    {
      type = 1,
      str = "" .. data.res,
      size = 20,
      color = td.WHITE
    }
  })
  td.AddRelaPos(itemNode, resLabel, 1, cc.p(0.55, 0.5))
  local labelWin = td.CreateLabel(data.win_num, td.LIGHT_BLUE)
  td.AddRelaPos(itemNode, labelWin, 1, cc.p(0.87, 0.5))
  local lineSpr = display.newSprite("UI/common/fengexian_shu.png")
  lineSpr:setScaleX(ITEM_SIZE.width / lineSpr:getContentSize().width)
  td.AddRelaPos(itemNode, lineSpr, 1, cc.p(0.5, 0))
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize(ITEM_SIZE.width * self.m_scale, (ITEM_SIZE.height + 5) * self.m_scale)
  return item
end
function GuildPVPLogDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
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
    else
      local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
      if not isTouchInNode(self.m_bg, tmpPos) then
        self:performWithDelay(function()
          self:close()
        end, 0.1)
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
function GuildPVPLogDlg:SendLogReq()
  local Msg = {}
  Msg.msgType = td.RequestID.GuildPVPLog
  Msg.sendData = {
    team_id = self.m_pvpData:GetValue("battleId")
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function GuildPVPLogDlg:LogCallback(data)
  self.m_vLogData = data.log
  self:RefreshList(1)
end
function GuildPVPLogDlg:SendLogResReq()
  local Msg = {}
  Msg.msgType = td.RequestID.GuildPVPResLog
  Msg.sendData = {
    team_id = self.m_pvpData:GetValue("battleId")
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function GuildPVPLogDlg:LogResCallback(data)
  self.m_vResData = data.award
  local vBattlePosData = self.m_pvpData:GetValue("battlePos")
  for index, posData in pairs(vBattlePosData) do
    local addRes = td.CalGuildPVPRes(posData.startTime)
    for i, var in ipairs(self.m_vResData) do
      if var.uid == posData.id then
        var.award = var.award + addRes
      end
    end
  end
  table.sort(self.m_vResData, function(a, b)
    return a.award > b.award
  end)
  self:RefreshList(2)
end
return GuildPVPLogDlg
