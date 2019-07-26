local TDHttpRequest = require("app.net.TDHttpRequest")
local BaseDlg = require("app.layers.BaseDlg")
local TouchIcon = require("app.widgets.TouchIcon")
local FirstChargeDlg = class("FirstChargeDlg", BaseDlg)
function FirstChargeDlg:ctor(eType)
  FirstChargeDlg.super.ctor(self)
  self:InitUI()
end
function FirstChargeDlg:onEnter()
  FirstChargeDlg.super.onEnter(self)
  self:AddEvents()
end
function FirstChargeDlg:onExit()
  FirstChargeDlg.super.onExit(self)
end
function FirstChargeDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/FirstChargeDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_buyBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_go")
  local heroInfo = require("app.info.ActorInfoManager"):GetInstance():GetHeroInfo(1100)
  local skeleton = SkeletonUnit:create(heroInfo.image)
  skeleton:scale(2)
  skeleton:PlayAni("stand")
  td.AddRelaPos(self.m_bg, skeleton, 1, cc.p(0.26, 0.3))
  local nameLabel = td.CreateLabel(heroInfo.name, td.YELLOW, 24, td.OL_BROWN)
  td.AddRelaPos(self.m_bg, nameLabel, 1, cc.p(0.26, 0.18))
  local items = {20121, 20122}
  for i, var in ipairs(items) do
    local posNode = cc.uiloader:seekNodeByName(self.m_uiRoot, "Node_" .. i)
    local iconSpr = TouchIcon.new(var, true)
    td.AddRelaPos(posNode, iconSpr)
  end
end
function FirstChargeDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function(times)
        self:close()
      end, 0.1)
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  td.BtnAddTouch(self.m_buyBtn, function()
    self:close()
    g_MC:OpenModule(td.UIModule.Topup)
  end)
end
return FirstChargeDlg
