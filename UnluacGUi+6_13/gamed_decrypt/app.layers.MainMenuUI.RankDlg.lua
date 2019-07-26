local BaseDlg = require("app.layers.BaseDlg")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local GameDataManager = require("app.GameDataManager")
local BaseInfoManager = require("app.info.BaseInfoManager")
local TabButton = require("app.widgets.TabButton")
local scheduler = require("framework.scheduler")
local RankType = {
  power = 1,
  hero = 2,
  arena = 3,
  endless = 4
}
local RankDlg = class("RankDlg", BaseDlg)
local tabConfig = {
  {
    pos = {x = -90, y = 400},
    path = td.Word_Path .. "zonghezhanli_button"
  },
  {
    pos = {x = -90, y = 290},
    path = td.Word_Path .. "yingxiongzhanli_button"
  },
  {
    pos = {x = -90, y = 180},
    path = td.Word_Path .. "arena_button"
  },
  {
    pos = {x = -90, y = 70},
    path = td.Word_Path .. "wujinmoshi_button"
  }
}
local words = {
  {
    str = {
      "a00163",
      "a00031",
      "a00064",
      "a00037",
      "a00032"
    },
    posx = {
      100,
      280,
      480,
      630,
      790
    }
  },
  {
    str = {
      "a00163",
      "a00031",
      "a00310",
      "a00311"
    },
    posx = {
      120,
      340,
      560,
      780
    }
  },
  {
    str = {
      "a00163",
      "a00031",
      "a00064",
      "a00032"
    },
    posx = {
      120,
      340,
      560,
      780
    }
  },
  {
    str = {
      "a00163",
      "a00031",
      "a00312",
      "a00313"
    },
    posx = {
      120,
      340,
      560,
      780
    }
  }
}
function RankDlg:ctor()
  RankDlg.super.ctor(self, 255, true)
  self.m_uiId = td.UIModule.Rank
  self.m_commanderInfoManager = require("app.info.CommanderInfoManager"):GetInstance()
  self.m_actorInfoManager = require("app.info.ActorInfoManager"):GetInstance()
  self.m_vHeaders = {}
  self.m_datas = {}
  self.m_posInfo = {}
  self.m_curTabIndex = 1
  self.m_currPos = 1
  self.m_scrollPos = nil
  self.m_rank = 0
  self:InitUI()
  self:AddEvents()
end
function RankDlg:onEnter()
  RankDlg.super.onEnter(self)
  self:CreateTabs()
  self:CreateList()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.RankZhanli_req, handler(self, self.RequestCallBack))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.RankArena_req, handler(self, self.RequestCallBack))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.RankHero_req, handler(self, self.RequestCallBack))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetEndlessRank, handler(self, self.RequestCallBack))
end
function RankDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.RankZhanli_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.RankArena_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.RankHero_req)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetEndlessRank)
  RankDlg.super.onExit(self)
end
function RankDlg:initHeaders()
  for i, var in ipairs(words) do
    local header = display.newNode()
    header:pos(10, 425):addTo(self.m_list_bg)
    if i ~= 1 then
      header:setVisible(false)
    end
    table.insert(self.m_vHeaders, header)
    for j, s in ipairs(var.str) do
      local label = td.CreateLabel(g_LM:getBy(s), td.BLUE, 22)
      label:pos(var.posx[j], 17):addTo(header)
    end
  end
end
function RankDlg:InitUI()
  self:LoadUI("CCS/RankDlg.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetTitle(td.Word_Path .. "wenzi_paihangbang.png")
  self.m_list_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self:initHeaders()
end
function RankDlg:CreateTabs()
  self.m_tabs = {}
  for i = 1, #tabConfig do
    local tab = ccui.ImageView:create(tabConfig[i].path .. "1.png")
    tab:pos(tabConfig[i].pos.x, tabConfig[i].pos.y):addTo(self.m_list_bg)
    table.insert(self.m_tabs, tab)
  end
  local function pressItemBtn(index)
    self.m_currPos = 1
    self.m_scrollPos = nil
    if not UserDataManager:GetInstance():GetRankListData()[index] then
      self:SendRequest(index)
    else
      self:refreshRankListByType(index)
    end
    self.m_vHeaders[self.m_curTabIndex]:setVisible(false)
    self.m_curTabIndex = index
    self.m_vHeaders[self.m_curTabIndex]:setVisible(true)
  end
  local tabButtons = {}
  for i = 1, #self.m_tabs do
    local t = {
      tab = self.m_tabs[i],
      callfunc = pressItemBtn,
      normalImageFile = tabConfig[i].path .. "1.png",
      highImageFile = tabConfig[i].path .. "2.png"
    }
    table.insert(tabButtons, t)
  end
  local initIndex = self.m_vEnterSubIndex[1] or 1
  self.m_TabButton = TabButton.new(tabButtons, {autoSelectIndex = initIndex})
end
function RankDlg:CreateList()
  local list_bg_size = self.m_list_bg:getContentSize()
  local wordSpr = td.CreateLabel(g_LM:getBy("a00417"), td.BLUE, 20)
  wordSpr:setAnchorPoint(0, 0.5)
  wordSpr:pos(80, -20):addTo(self.m_list_bg)
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(2, 5, 918, 415),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_UIListView:setAnchorPoint(cc.p(0, 0))
  self.m_UIListView:setPosition(cc.p(0, 0))
  self.m_UIListView:setLayoutPadding(10, 10, 10, 10)
  self.m_list_bg:addChild(self.m_UIListView)
  self.m_UIListView:onTouch(function(event)
    if event.name == "nextPage" then
      self:refreshRankListByType(self.m_curTabIndex)
    elseif event.name == "ended" then
      self.m_scrollPos = cc.p(self.m_UIListView:getScrollNode():getPosition())
    end
  end)
end
function RankDlg:createItem(rankType, data, rankValue)
  local pItem = cc.uiloader:load("CCS/RankItem.csb")
  self:initItem(pItem, rankType, data, rankValue)
  local item = self.m_UIListView:newItem(pItem)
  local size = cc.uiloader:seekNodeByName(pItem, "Image_bg"):getContentSize()
  item:setItemSize(size.width * self.m_scale, (size.height + 7) * self.m_scale)
  item:setScale(self.m_scale)
  item:setAnchorPoint(cc.p(0.5, 0.5))
  return item
end
function RankDlg:initItem(pItem, rankType, data, rankValue)
  local tmpBg = cc.uiloader:seekNodeByName(pItem, "Image_bg")
  local size = tmpBg:getContentSize()
  local rank = rankValue
  local rankNode = cc.uiloader:seekNodeByName(pItem, "Node_rank")
  rankNode:setPositionX(words[rankType].posx[1] + 5)
  if rank <= 3 then
    local fileName = string.format("UI/words/no%02d.png", rank)
    local rankText = display.newSprite(fileName)
    rankText:addTo(rankNode)
  else
    local pLabel = display.newBMFontLabel({
      text = rank .. "",
      font = "Fonts/RankNumber.fnt",
      align = cc.TEXT_ALIGNMENT_LEFT
    })
    pLabel:addTo(rankNode)
  end
  local avatarNode = cc.uiloader:seekNodeByName(pItem, "Node_avatar")
  local heroName = cc.uiloader:seekNodeByName(avatarNode, "Text_name")
  local nameStr = data.nickname ~= "" and data.nickname or "NO." .. data.uid
  local headImg = cc.uiloader:seekNodeByName(pItem, "Image_head")
  headImg:loadTexture(td.GetPortrait(data.image_id))
  avatarNode:setPositionX(words[rankType].posx[2] - 30)
  heroName:setString(nameStr)
  local vipIcon = cc.uiloader:seekNodeByName(pItem, "Image_vip")
  vipIcon:loadTexture(td.GetVIPIcon(data.vip_level))
  if rankType == RankType.power then
    local pLevelLabel = td.CreateLabel("LV." .. data.level, td.LIGHT_BLUE, 20)
    pLevelLabel:pos(words[rankType].posx[3] + 7, size.height / 2):addTo(tmpBg)
    local honorInfo = self.m_commanderInfoManager:GetHonorInfoByRepu(data.reputation)
    local image = honorInfo.image .. td.PNG_Suffix
    local pHonorLabel = td.RichText({
      {
        type = 2,
        file = image,
        scale = 0.45
      },
      {
        type = 1,
        color = td.YELLOW,
        size = 18,
        str = honorInfo.military_rank
      }
    })
    pHonorLabel:pos(words[rankType].posx[4], size.height / 2):addTo(tmpBg)
    local pPowerLabel = td.CreateLabel(data.attack, td.LIGHT_BLUE, 20)
    pPowerLabel:pos(words[rankType].posx[5] + 10, size.height / 2):addTo(tmpBg)
  elseif rankType == RankType.arena then
    local pLevelLabel = td.CreateLabel("LV." .. data.level, td.LIGHT_BLUE, 20)
    pLevelLabel:pos(words[rankType].posx[3] + 7, size.height / 2):addTo(tmpBg)
    local pPowerLabel = td.CreateLabel(data.attack, td.LIGHT_BLUE, 20)
    pPowerLabel:pos(words[rankType].posx[4] + 10, size.height / 2):addTo(tmpBg)
  elseif rankType == RankType.hero then
    local pHeroQuantity = td.CreateLabel(data.num, td.LIGHT_BLUE, 20)
    pHeroQuantity:pos(words[rankType].posx[3], size.height / 2):addTo(tmpBg)
    local pHeroPower = td.CreateLabel(data.attack, td.LIGHT_BLUE, 20)
    pHeroPower:pos(words[rankType].posx[4], size.height / 2):addTo(tmpBg)
  elseif rankType == RankType.endless then
    local pPower = td.CreateLabel(data.max_attack, td.LIGHT_BLUE, 20)
    pPower:pos(words[rankType].posx[3], size.height / 2):addTo(tmpBg)
    local pBestRecord = td.CreateLabel(data.max_wave, td.LIGHT_BLUE, 20)
    pBestRecord:pos(words[rankType].posx[4], size.height / 2):addTo(tmpBg)
  end
end
function RankDlg:refreshListViewBottom(rankType)
  if self.m_myRankLabel then
    self.m_myRankLabel:removeFromParent()
    self.m_myRankLabel = nil
  end
  local myRank = UserDataManager:GetInstance():GetMyRank(rankType)
  if myRank == 0 then
    myRank = "\230\156\170\228\184\138\230\166\156"
  end
  self.m_myRankLabel = td.CreateLabel(myRank, td.YELLOW, 20)
  self.m_myRankLabel:setAnchorPoint(0, 0.5)
  self.m_myRankLabel:setPosition(175, -20)
  self.m_myRankLabel:addTo(self.m_list_bg)
end
function RankDlg:AddEvents()
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
      return true
    end
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
function RankDlg:refreshRankListByType(rankType)
  if self.m_currPos == 1 then
    self.m_UIListView:removeAllItems()
  end
  local datas = UserDataManager:GetInstance():GetRankListData()[rankType]
  if #datas > 0 then
    local length
    if #datas - self.m_currPos >= 5 then
      length = 5
    else
      length = #datas - self.m_currPos
    end
    for i = self.m_currPos, self.m_currPos + length do
      local item = self:createItem(rankType, datas[i], i)
      self.m_UIListView:addItem(item)
    end
    self.m_UIListView:reload()
    if self.m_scrollPos then
      local itemSize = self.m_UIListView:getItemByPos(1):getContent():getContentSize()
      self.m_scrollPos = cc.p(self.m_scrollPos.x, self.m_scrollPos.y - self.m_currPos * itemSize.height)
      self.m_UIListView:scrollTo(self.m_scrollPos)
    end
    self.m_currPos = self.m_currPos + length + 1
  end
  self:refreshListViewBottom(rankType)
end
function RankDlg:SendRequest(index)
  local tdRequest = TDHttpRequest:getInstance()
  local reqId = -1
  if index == td.RankType.General then
    reqId = td.RequestID.RankZhanli_req
  elseif index == td.RankType.Hero then
    reqId = td.RequestID.RankHero_req
  elseif index == td.RankType.Arena then
    reqId = td.RequestID.RankArena_req
  elseif index == td.RankType.Endless then
    reqId = td.RequestID.GetEndlessRank
  end
  local Msg = {}
  Msg.msgType = reqId
  Msg.cbData = reqId
  tdRequest:Send(Msg)
end
function RankDlg:RequestCallBack(data, cbData)
  local listData = {}
  local index = -1
  if cbData == td.RequestID.RankZhanli_req then
    listData = data.attackProto
    index = td.RankType.General
  elseif cbData == td.RequestID.RankHero_req then
    listData = data.heroRankProto
    index = td.RankType.Hero
  elseif cbData == td.RequestID.RankArena_req then
    listData = data.arenaRankProto
    index = td.RankType.Arena
  elseif cbData == td.RequestID.GetEndlessRank then
    listData = data.otherEndlessProto
    index = td.RankType.Endless
  end
  UserDataManager:GetInstance():UpdateRankListData(listData, index)
  self.m_currPos = 1
  self:refreshRankListByType(index)
end
return RankDlg
