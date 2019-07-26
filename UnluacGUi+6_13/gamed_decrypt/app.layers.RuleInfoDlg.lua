local BaseDlg = require("app.layers.BaseDlg")
local RuleInfoDlg = class("RuleInfoDlg", BaseDlg)
function RuleInfoDlg:ctor(data)
  RuleInfoDlg.super.ctor(self)
  self:SetData(data)
  self:InitUI()
end
function RuleInfoDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/RuleInfo.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_title = cc.uiloader:seekNodeByName(self.m_bg, "Text_title")
  self.m_title:setString(self.m_data.title)
  self.m_scrollList = cc.uiloader:seekNodeByName(self.m_bg, "ScrollView")
  local ruleText = td.CreateLabel(self.m_data.text, td.WHITE, 18, nil, nil, cc.size(360, 0))
  if ruleText then
    local size = self.m_scrollList:getContentSize()
    local textSize = ruleText:getContentSize()
    ruleText:setAnchorPoint(0.5, 1)
    ruleText:pos(size.width / 2, math.max(textSize.height, size.height)):addTo(self.m_scrollList)
    self.m_scrollList:setInnerContainerSize(cc.size(size.width, textSize.height))
  end
end
function RuleInfoDlg:onEnter()
  RuleInfoDlg.super.onEnter(self)
  self:AddEvent()
end
function RuleInfoDlg:onExit()
  RuleInfoDlg.super.onExit(self)
end
function RuleInfoDlg:SetData(data)
  self.m_data = data
end
function RuleInfoDlg:AddEvent()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function()
        self:close()
      end, 0.1)
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
return RuleInfoDlg
