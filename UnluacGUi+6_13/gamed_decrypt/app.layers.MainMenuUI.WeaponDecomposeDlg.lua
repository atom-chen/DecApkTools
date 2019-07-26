local ItemInfoManager = require("app.info.ItemInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local UserDataManager = require("app.UserDataManager")
local BaseDlg = require("app.layers.BaseDlg")
local WeaponDecomposeDlg = class("WeaponDecomposeDlg", BaseDlg)
function WeaponDecomposeDlg:ctor(data)
  WeaponDecomposeDlg.super.ctor(self)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_uiId = td.UIModule.WeaponDecompose
  self.data = nil
  self:InitUI()
  self:SetData(data.id)
end
function WeaponDecomposeDlg:onEnter()
  WeaponDecomposeDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.Decompose, handler(self, self.DecomposeCallback))
  self:AddBtnEvents()
  self:AddTouch()
end
function WeaponDecomposeDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.Decompose)
  WeaponDecomposeDlg.super.onExit(self)
end
function WeaponDecomposeDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  local panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  local bgSize = cc.size(490, 430)
  self.m_bg = display.newScale9Sprite("UI/scale9/yijitankuang2.png", 0, 0, bgSize, cc.rect(110, 80, 5, 2))
  td.AddRelaPos(panel, self.m_bg)
  self.btn_cancel = td.CreateBtn(td.BtnType.BlueLong)
  td.AddRelaPos(self.m_bg, self.btn_cancel, 1, cc.p(0.27, 0.17))
  td.BtnSetTitle(self.btn_cancel, g_LM:getBy("a00116"))
  self.btn_confirm = td.CreateBtn(td.BtnType.GreenLong)
  td.AddRelaPos(self.m_bg, self.btn_confirm, 1, cc.p(0.73, 0.17))
  td.BtnSetTitle(self.btn_confirm, g_LM:getBy("a00009"))
end
function WeaponDecomposeDlg:SetData(id)
  self.data = self.m_udMng:GetWeaponData(id)
  self:RefreshUI()
end
function WeaponDecomposeDlg:RefreshUI()
  self.iconSpr = td.CreateWeaponIcon(self.data.weaponId, self.data.star)
  td.AddRelaPos(self.m_bg, self.iconSpr, 1, cc.p(0.5, 0.76))
  local gainInfo = ItemInfoManager:GetInstance():GetDecomposeInfo(self.data.weaponId)
  local numLabel = td.CreateLabel2({
    str = g_LM:getBy("a00234") .. ":",
    color = td.BLUE,
    size = 20
  })
  numLabel:align(display.RIGHT_CENTER, 138, 180):addTo(self.m_bg)
  local labelGain = td.RichText({
    {
      type = 2,
      file = td.GetItemIcon(gainInfo.gain_id),
      scale = 0.6
    },
    {
      type = 1,
      str = "x" .. gainInfo.gain_num,
      size = 20,
      color = td.WHITE
    }
  })
  labelGain:align(display.LEFT_CENTER, 171, 180):addTo(self.m_bg)
end
function WeaponDecomposeDlg:AddTouch()
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
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function WeaponDecomposeDlg:AddBtnEvents()
  td.BtnAddTouch(self.btn_confirm, function()
    if self.m_bIsSending then
      return
    end
    self:DecomposeRequest(self.data.id)
  end, nil, td.ButtonEffectType.Long)
  td.BtnAddTouch(self.btn_cancel, function()
    self:close()
  end)
end
function WeaponDecomposeDlg:DecomposeRequest(targetId)
  self.m_bIsSending = true
  local Msg = {}
  Msg.msgType = td.RequestID.Decompose
  Msg.sendData = {
    id = targetId,
    num = 1,
    type = 1
  }
  Msg.cbData = {
    id = targetId,
    num = 1,
    type = 1
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function WeaponDecomposeDlg:DecomposeCallback(data, cbData)
  self.m_bIsSending = false
  if td.ResponseState.Success == data.state then
    self.m_udMng:DeleteWeaponData(cbData.id)
    td.CreateUIEffect(self.iconSpr, "Spine/UI_effect/UI_fenjie_01", {
      cb = function()
        local gainInfo = ItemInfoManager:GetInstance():GetDecomposeInfo(self.data.weaponId)
        local _items = {
          [gainInfo.gain_id] = gainInfo.gain_num
        }
        InformationManager:GetInstance():ShowInfoDlg({
          type = td.ShowInfo.Item,
          items = _items
        })
        self:close()
      end
    })
  end
end
return WeaponDecomposeDlg
