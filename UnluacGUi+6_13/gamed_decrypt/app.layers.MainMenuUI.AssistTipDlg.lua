local BaseDlg = require("app.layers.BaseDlg")
local AssistTipDlg = class("AssistTipDlg", BaseDlg)
function AssistTipDlg:ctor()
  AssistTipDlg.super.ctor(self)
  self:InitShowUI()
  self:AddEventsWithList()
  self:setNodeEventEnabled(true)
end
function AssistTipDlg:onEnter()
  AssistTipDlg.super.onEnter(self)
end
function AssistTipDlg:onExit()
  AssistTipDlg.super.onExit(self)
end
function AssistTipDlg:InitShowUI()
  self.m_uiRoot = cc.uiloader:load("CCS/AssistTipDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  local panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  local bgSize = cc.size(500, 390)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local lineSpr = display.newSprite("UI/common/lanse_guang.png")
  lineSpr:setScaleX(bgSize.width / lineSpr:getContentSize().width)
  td.AddRelaPos(self.m_bg, lineSpr, 1, cc.p(0.5, 0.6))
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 510, 180),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_UIListView:setAnchorPoint(0, 0)
  self.m_UIListView:setPosition(25, 50)
  self.m_UIListView:setAlignment(3)
  self.m_bg:addChild(self.m_UIListView)
  self:RefreshUI()
end
function AssistTipDlg:RefreshUI()
  local udMng = require("app.UserDataManager"):GetInstance()
  self.m_vData = udMng:GetFriendData()
  local vAssistMsg = udMng:GetAssistMsg()
  local curNum = table.nums(vAssistMsg)
  local itemId
  local myFriends = self.m_vData[td.FriendType.Mine]
  self.m_UIListView:removeAllItems()
  if myFriends and vAssistMsg then
    for friendId, var in pairs(vAssistMsg) do
      itemId = var.itemId
      local value = myFriends[friendId]
      value = value or {
        uname = "NO." .. friendId,
        image_id = 1,
        reputation = 0,
        attack = 0
      }
      local item = self:CreateItem(value)
      self.m_UIListView:addItem(item)
    end
    self.m_UIListView:reload()
  end
  local icon = td.CreateItemIcon(itemId, true)
  icon:scale(0.8):pos(100, 300):addTo(self.m_bg)
  local numLabel = td.CreateLabel(string.format("\229\183\178\230\148\182\229\136\176\231\162\142\231\137\135%d\228\184\170", curNum))
  numLabel:align(display.LEFT_CENTER, 150, 320):addTo(self.m_bg)
  local expBar = cc.uiloader:seekNodeByName(self.m_bg, "Image_exp_bar")
  expBar:setScaleX(cc.clampf(curNum / 2, 0, 1))
  local progLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_exp")
  progLabel:setString(string.format("%d/%d", curNum, 2))
end
function AssistTipDlg:CreateItem(data)
  local commanderInfoMng = require("app.info.CommanderInfoManager"):GetInstance()
  local itemUI = display.newNode()
  local bgSize = cc.size(440, 75)
  local itemBg = display.newScale9Sprite("UI/scale9/transparent1x1.png", 0, 0, bgSize)
  itemBg:setAnchorPoint(0, 0)
  itemBg:addTo(itemUI)
  local headBtn = ccui.Button:create("UI/scale9/touxiangkuang5.png", "UI/scale9/touxiangkuang5.png")
  headBtn:setScale9Enabled(true)
  headBtn:setContentSize(cc.size(65, 65))
  td.AddRelaPos(itemBg, headBtn, 1, cc.p(0.13, 0.5))
  local headFile = commanderInfoMng:GetPortraitInfo(data.image_id).file .. td.PNG_Suffix
  local headSpr = display.newSprite(headFile)
  headSpr:scale(headBtn:getContentSize().width * 0.9 / headSpr:getContentSize().width)
  td.AddRelaPos(headBtn, headSpr)
  local honorInfo = commanderInfoMng:GetHonorInfoByRepu(data.reputation)
  local honorFile = honorInfo.image .. td.PNG_Suffix
  local nameLabel = td.RichText({
    {
      type = 2,
      file = honorFile,
      scale = 0.6
    },
    {
      type = 1,
      color = td.LIGHT_GREEN,
      size = 18,
      str = data.uname
    }
  })
  nameLabel:setAnchorPoint(0, 0.5)
  nameLabel:pos(100, bgSize.height * 0.7):addTo(itemBg)
  local label = td.CreateBMF(g_LM:getBy("a00032") .. ": ", "Fonts/BlackWhite18.fnt")
  local powerLabel = td.RichText({
    {type = 3, node = label},
    {
      type = 1,
      color = td.WHITE,
      size = 18,
      str = data.attack
    }
  })
  powerLabel:setAnchorPoint(0, 0.5)
  powerLabel:pos(110, bgSize.height * 0.27):addTo(itemBg)
  local assistLabel = td.CreateLabel(g_LM:getBy("a00282"), td.GREEN, 18)
  assistLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itemBg, assistLabel, 1, cc.p(0.7, 0.5))
  local lineSpr = display.newSprite("UI/common/fengexian_shu.png")
  lineSpr:setScaleX(bgSize.width / lineSpr:getContentSize().width)
  td.AddRelaPos(itemBg, lineSpr, 1, cc.p(0.5, 0))
  local item = self.m_UIListView:newItem(itemUI)
  item:setItemSize(bgSize.width * self.m_scale, (bgSize.height + 5) * self.m_scale)
  item:setScale(self.m_scale)
  item:setAnchorPoint(cc.p(0.5, 0.5))
  return item
end
function AssistTipDlg:AddEventsWithList()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local bResult = false
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
      bResult = true
      self.m_bIsTouchInList = true
    else
      local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
      if not isTouchInNode(self.m_bg, tmpPos) then
        self:performWithDelay(function()
          self:close()
        end, 0.1)
        bResult = true
      end
      self.m_bIsTouchInList = false
    end
    return bResult
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
    if self.m_bIsTouchInList then
      self.m_UIListView:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
return AssistTipDlg
