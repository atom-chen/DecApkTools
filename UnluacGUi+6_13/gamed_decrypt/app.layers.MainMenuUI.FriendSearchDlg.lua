local BaseDlg = require("app.layers.BaseDlg")
local FriendSearchDlg = class("FriendSearchDlg", BaseDlg)
function FriendSearchDlg:ctor(searchStr)
  FriendSearchDlg.super.ctor(self)
  self.m_searchStr = searchStr or ""
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function FriendSearchDlg:onEnter()
  FriendSearchDlg.super.onEnter(self)
  self:AddEvents()
end
function FriendSearchDlg:onExit()
  FriendSearchDlg.super.onExit(self)
end
function FriendSearchDlg:InitUI()
  self:LoadUI("CCS/FriendSearch.csb")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  td.SetAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  local textInfoTitle = cc.uiloader:seekNodeByName(self.m_bg, "Text_info")
  textInfoTitle:setString(g_LM:getBy("a00258"))
  self.m_editbox = ccui.EditBox:create(cc.size(340, 50), "UI/scale9/wenzineirongbiankuang.png")
  td.AddRelaPos(self.m_bg, self.m_editbox)
  self.m_editbox:setFontSize(20)
  self.m_editbox:setMaxLength(18)
  self.m_editbox:setText(self.m_searchStr)
  local btn = cc.uiloader:seekNodeByName(self.m_bg, "Button_search")
  td.BtnSetTitle(btn, g_LM:getBy("a00259"))
  btn:addTouchEventListener(function(sender, eventType)
    if ccui.TouchEventType.ended == eventType then
      td.dispatchEvent(td.SEARCH_FRIEND, self.m_editbox:getText())
      self:close()
    end
  end)
end
function FriendSearchDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:close()
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
return FriendSearchDlg
