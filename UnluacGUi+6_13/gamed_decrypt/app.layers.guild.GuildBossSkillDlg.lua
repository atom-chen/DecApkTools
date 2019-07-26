local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
local ActorInfoManager = require("app.info.ActorInfoManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local GuildBossSkillDlg = class("GuildBossSkillDlg", BaseDlg)
local ITEM_SIZE = cc.size(815, 80)
local BossSkillConfig = {
  [9010] = {
    3121,
    3115,
    3116,
    3117,
    3118,
    3119,
    3120
  }
}
function GuildBossSkillDlg:ctor(bossId)
  GuildBossSkillDlg.super.ctor(self, 200)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_bossId = bossId
  self:InitUI()
end
function GuildBossSkillDlg:onEnter()
  GuildBossSkillDlg.super.onEnter(self)
  self:AddEvents()
  self:PlayEnterAni(handler(self, self.RefreshList))
end
function GuildBossSkillDlg:InitUI()
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
end
function GuildBossSkillDlg:PlayEnterAni(cb)
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
function GuildBossSkillDlg:CreateList()
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
function GuildBossSkillDlg:RefreshList()
  local skills = BossSkillConfig[self.m_bossId]
  self.m_UIListView:removeAllItems()
  for i, id in ipairs(skills) do
    local skillInfo = SkillInfoManager:GetInstance():GetInfo(id)
    if skillInfo and skillInfo.type ~= td.SkillType.Normal then
      local item = self:CreateItem(skillInfo)
      self.m_UIListView:addItem(item)
    end
  end
  self.m_UIListView:reload()
end
function GuildBossSkillDlg:CreateItem(skillInfo)
  local itemNode = display.newNode()
  itemNode:setContentSize(ITEM_SIZE)
  itemNode:setScale(self.m_scale)
  local nameLabel = td.CreateLabel(skillInfo.name, td.WHITE, 18)
  local descLabel = td.CreateLabel(skillInfo.desc, td.GRAY, 18, nil, nil, cc.size(ITEM_SIZE.width, 0))
  local cellHeight = nameLabel:getContentSize().height + descLabel:getContentSize().height + 10
  itemNode:setContentSize(cc.size(ITEM_SIZE.width, cellHeight))
  nameLabel:align(display.LEFT_TOP, 10, cellHeight - 5):addTo(itemNode)
  descLabel:align(display.LEFT_TOP, 10, cellHeight - 30):addTo(itemNode)
  local lineSpr = display.newSprite("UI/common/fengexian_shu.png")
  lineSpr:setScaleX(ITEM_SIZE.width / lineSpr:getContentSize().width)
  td.AddRelaPos(itemNode, lineSpr, 1, cc.p(0.5, 0))
  local item = self.m_UIListView:newItem(itemNode)
  item:setItemSize(ITEM_SIZE.width * self.m_scale, (cellHeight + 5) * self.m_scale)
  return item
end
function GuildBossSkillDlg:AddEvents()
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
return GuildBossSkillDlg
