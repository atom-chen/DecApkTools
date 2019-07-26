local BaseDlg = require("app.layers.BaseDlg")
local UnitUnlockedDlg = class("UnitUnlockedDlg", BaseDlg)
function UnitUnlockedDlg:ctor(soldierId)
  UnitUnlockedDlg.super.ctor(self)
  self.m_soldierId = soldierId
  self.m_showingAnim = false
  self:InitUI()
end
function UnitUnlockedDlg:onEnter()
  UnitUnlockedDlg.super.onEnter(self)
  self:AddEvents()
end
function UnitUnlockedDlg:onExit()
  UnitUnlockedDlg.super.onExit(self)
  td.dispatchEvent(td.GUIDE_CONTINUE)
end
function UnitUnlockedDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/UnitUnlocked.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_panelBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_bg:setScale(0)
  local soldierInfo = require("app.info.ActorInfoManager"):GetInstance():GetSoldierInfo(self.m_soldierId)
  local spine = SkeletonUnit:create(soldierInfo.image)
  spine:setName("spine")
  spine:setOpacity(0)
  spine:PlayAni("stand", true)
  td.AddRelaPos(self.m_bg, spine, 1, cc.p(0.5, 0.31))
  local ratingIcon = td.CreateRatingIcon(soldierInfo.rate)
  ratingIcon:pos(255, 317):addTo(self.m_bg)
  local itemName = soldierInfo.name
  local nameLabel = td.CreateLabel(itemName, td.WHITE, 22, td.OL_BLACK)
  td.AddRelaPos(self.m_bg, nameLabel, 1, cc.p(0.5, 0.885))
  local careerIcon = td.CreateCareerIcon(soldierInfo.career)
  careerIcon:pos(45, 317):addTo(self.m_bg)
  self:ShowSoldierAnim()
end
function UnitUnlockedDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) and not self.m_showingAnim then
      self:performWithDelay(function(times)
        self:close()
      end, 0.1)
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function UnitUnlockedDlg:ShowSoldierAnim()
  self.m_showingAnim = true
  local spine = self.m_bg:getChildByName("spine")
  self.m_bg:runAction(cca.seq({
    cca.scaleTo(0.2, 1, 1),
    cca.cb(function()
      local pos = spine:getPosition()
      td.CreateUIEffect(self.m_bg, "Spine/UI_effect/UI_goumaiyingxiong_01")
    end),
    cca.delay(0.25),
    cca.cb(function()
      spine:runAction(cca.seq({
        cca.fadeIn(0.2),
        cca.cb(function()
          spine:PlayAni("attack_01", false)
          spine:PlayAni("stand", true, true)
          self.m_showingAnim = false
        end)
      }))
    end)
  }))
end
return UnitUnlockedDlg
