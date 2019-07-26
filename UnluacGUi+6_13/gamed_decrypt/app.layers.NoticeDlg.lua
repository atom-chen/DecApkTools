local BaseDlg = require("app.layers.BaseDlg")
local NoticeDlg = class("NoticeDlg", BaseDlg)
function NoticeDlg:ctor(noticeStr)
  NoticeDlg.super.ctor(self)
  self.m_uiRoot = cc.uiloader:load("CCS/NoticeDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  local closeBtn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_yes")
  self:setCloseBtn(closeBtn)
  td.BtnSetTitle(closeBtn, g_LM:getBy("a00009"))
  local title = cc.uiloader:seekNodeByName(self.m_uiRoot, "Text_title")
  title:setString(g_LM:getBy("a00244"))
  local label = cc.ui.UILabel.new({
    text = string.urldecode(noticeStr),
    font = td.DEFAULT_FONT,
    size = 18,
    color = td.WHITE,
    align = cc.ui.TEXT_ALIGN_LEFT,
    valign = cc.ui.TEXT_VALIGN_TOP,
    dimensions = cc.size(540, 0)
  })
  local scrollView = cc.uiloader:seekNodeByName(self.m_uiRoot, "ScrollView_1")
  scrollView:setBounceEnabled(true)
  local height = math.max(scrollView:getContentSize().height, label:getContentSize().height)
  scrollView:setInnerContainerSize(cc.size(540, height))
  scrollView:addChild(label)
  label:align(display.LEFT_TOP, 0, height)
end
return NoticeDlg
