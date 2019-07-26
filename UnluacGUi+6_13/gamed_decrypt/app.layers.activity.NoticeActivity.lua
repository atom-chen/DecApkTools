local ItemInfoManager = require("app.info.ItemInfoManager")
local UserDataManager = require("app.UserDataManager")
local ActivityInfoManager = require("app.info.ActivityInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local NoticeActivity = class("NoticeActivity", function()
  return display.newNode()
end)
function NoticeActivity:ctor(data)
  self:InitUI()
end
function NoticeActivity:InitUI()
  self.m_bg = display.newScale9Sprite("UI/scale9/bantouming4.png", 0, 0, cc.size(590, 405))
  self:addChild(self.m_bg)
  local titleBg = display.newScale9Sprite("UI/scale9/huisejianbianchangtiao.png", 0, 0, cc.size(583, 34))
  td.AddRelaPos(self.m_bg, titleBg, 1, cc.p(0.5, 0.95))
  local titleLabel = td.CreateLabel(g_LM:getBy("a00403"), td.LIGHT_BLUE, 18)
  td.AddRelaPos(titleBg, titleLabel)
  local noticeStr = UserDataManager:GetInstance():GetServerData().content or ""
  local label = cc.ui.UILabel.new({
    text = string.urldecode(noticeStr),
    font = td.DEFAULT_FONT,
    size = 18,
    color = td.WHITE,
    align = cc.ui.TEXT_ALIGN_LEFT,
    valign = cc.ui.TEXT_VALIGN_TOP,
    dimensions = cc.size(540, 0)
  })
  local scrollView = ccui.ScrollView:create()
  scrollView:setContentSize(cc.size(550, 350))
  scrollView:pos(20, 0):addTo(self.m_bg)
  scrollView:setBounceEnabled(true)
  local height = math.max(scrollView:getContentSize().height, label:getContentSize().height)
  scrollView:setInnerContainerSize(cc.size(540, height))
  scrollView:addChild(label)
  label:align(display.LEFT_TOP, 0, height)
end
return NoticeActivity
