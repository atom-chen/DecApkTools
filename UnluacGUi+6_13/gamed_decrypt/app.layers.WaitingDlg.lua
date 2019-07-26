local TDHttpRequest = require("app.net.TDHttpRequest")
local BaseDlg = require("app.layers.BaseDlg")
local WaitingDlg = class("WaitingDlg", BaseDlg)
function WaitingDlg:ctor()
  WaitingDlg.super.ctor(self, 100)
  self:InitUI()
end
function WaitingDlg:onEnter()
  WaitingDlg.super.onEnter(self)
  self:AddCustomEvent(td.STOP_WAITING, function()
    self:removeFromParent()
  end)
  self:startAnim()
end
function WaitingDlg:onExit()
  WaitingDlg.super.onExit(self)
end
function WaitingDlg:InitUI()
  self.m_sprite = display.newSprite("UI/common/waiting_icon.png")
  self:addChild(self.m_sprite, 1)
  local spriContent = self.m_sprite:getContentSize()
  local pos = cc.p(display.width * 0.5, display.height * 0.5)
  self.m_sprite:setPosition(pos)
end
function WaitingDlg:startAnim()
  local action = cc.RotateBy:create(0.2, 15)
  action = cc.RepeatForever:create(action)
  self.m_sprite:runAction(action)
end
return WaitingDlg
