local BaseDlg = require("app.layers.BaseDlg")
local scheduler = require("framework.scheduler")
local AssistConfirmDlg = class("AssistConfirmDlg", BaseDlg)
function AssistConfirmDlg:ctor(str)
  AssistConfirmDlg.super.ctor(self)
  self.m_yesCallback = nil
  self.m_conStr = str
  self:InitUI()
  self:AddEvents()
  self:setNodeEventEnabled(true)
end
function AssistConfirmDlg:onEnter()
  AssistConfirmDlg.super.onEnter(self)
end
function AssistConfirmDlg:onExit()
  AssistConfirmDlg.super.onExit(self)
end
function AssistConfirmDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/AssistTipDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self:SetTitle(td.Word_Path .. "wenzi_tishi.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local label1 = td.CreateLabel(g_LM:getBy("a00208"), td.LIGHT_GREEN, 22, nil, nil, cc.size(350, 0))
  label1:setAnchorPoint(0, 1)
  label1:pos(50, 350):addTo(self.m_bg)
  local label2 = td.CreateLabel(self.m_conStr, td.LIGHT_BLUE, 22, nil, nil, cc.size(350, 0))
  label2:setAnchorPoint(0, 1)
  label2:pos(50, 310):addTo(self.m_bg)
  local btn = td.CreateBtn(td.BtnType.GreenLong)
  btn:addTouchEventListener(function(sender, eventType)
    if ccui.TouchEventType.ended == eventType then
      if self.m_yesCallback then
        self.m_yesCallback()
        self.m_yesCallback = nil
      end
      self:close()
    end
  end)
  td.BtnSetTitle(btn, g_LM:getBy("a00009"))
  td.AddRelaPos(self.m_bg, btn, 1, cc.p(0.7, 0.12))
  btn = td.CreateBtn(td.BtnType.BlueLong)
  btn:addTouchEventListener(function(sender, eventType)
    if ccui.TouchEventType.ended == eventType then
      self:close()
    end
  end)
  td.BtnSetTitle(btn, g_LM:getBy("a00116"))
  td.AddRelaPos(self.m_bg, btn, 1, cc.p(0.3, 0.12))
end
function AssistConfirmDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      scheduler.performWithDelayGlobal(function(times)
        self:close()
      end, 0.03333333333333333)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function AssistConfirmDlg:SetCallback(cb)
  self.m_yesCallback = cb
end
return AssistConfirmDlg
