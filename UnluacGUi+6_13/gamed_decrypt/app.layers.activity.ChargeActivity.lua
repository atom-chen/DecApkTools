local ItemInfoManager = require("app.info.ItemInfoManager")
local UserDataManager = require("app.UserDataManager")
local ActivityDataManager = require("app.ActivityDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local TouchIcon = require("app.widgets.TouchIcon")
local ChargeActivity = class("ChargeActivity", function()
  return cc.uiloader:load("CCS/activities/Charge.csb")
end)
function ChargeActivity:ctor(data)
  self:InitUI()
end
function ChargeActivity:InitUI()
  self:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self)
  self.m_bg = cc.uiloader:seekNodeByName(self, "Image_bg")
  self.m_buyBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_go")
  td.BtnAddTouch(self.m_buyBtn, function()
    g_MC:OpenModule(td.UIModule.Topup)
  end)
end
return ChargeActivity