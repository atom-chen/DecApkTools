local UserDataManager = require("app.UserDataManager")
local IncomeButton = class("IncomeButton", function()
  return display.newSprite("UI/mainmenu_new/shoufuchengshi_zhuangshidi.png")
end)
function IncomeButton:ctor()
  self.m_isShowing = false
  self:setNodeEventEnabled(true)
end
function IncomeButton:onEnter()
  self:AddEvents()
end
function IncomeButton:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local touchPos = self:convertToNodeSpace(touch:getLocation())
    local selfPos = self:getPosition()
    if self.m_isShowing then
      self.m_isShowing = false
      self.m_incomeInfo:removeFromParent()
      return true
    end
    if not self.m_isShowing and isTouchInNode(self, touchPos) then
      self.m_isShowing = true
      self.m_incomeInfo = cc.uiloader:load("CCS/IncomeInfo.csb")
      td.AddRelaPos(self, self.m_incomeInfo, 1, cc.p(1.4, -1))
      local text = cc.uiloader:seekNodeByName(self.m_incomeInfo, "Text_income")
      local income = UserDataManager:GetInstance():GetProfitData(td.ItemID_Gold).speed * 10
      text:setString(tostring(income) .. "/" .. g_LM:getBy("a00057"))
      local text2 = cc.uiloader:seekNodeByName(self.m_incomeInfo, "Text_income2")
      local income2 = UserDataManager:GetInstance():GetProfitData(td.ItemID_Force).speed * 10
      text2:setString(tostring(income2) .. "/" .. g_LM:getBy("a00057"))
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
return IncomeButton
