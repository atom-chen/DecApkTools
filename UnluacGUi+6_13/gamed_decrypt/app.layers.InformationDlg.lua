local BaseDlg = require("app.layers.BaseDlg")
local InformationManager = require("app.layers.InformationManager")
local InformationDlg = class("InformationDlg", BaseDlg)
function InformationDlg:ctor(data)
  InformationDlg.super.ctor(self)
  self.m_uiId = td.UIModule.Information
  self:InitUI()
  self:SetData(data)
end
function InformationDlg:onEnter()
  InformationDlg.super.onEnter(self)
  self:AddTouch()
  self:performWithDelay(function()
    td.CreateUIEffect(self.m_icon, "Spine/UI_effect/EFT_dedaojineng_01")
  end, 0.3)
  self:CheckGuide()
end
function InformationDlg:onExit()
  InformationDlg.super.onExit(self)
  InformationManager:GetInstance():OnShowDone(td.ShowInfo.Item)
end
function InformationDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/InfoDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  self.m_icon = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_icon")
  self.m_label = td.CreateLabel("", td.LIGHT_BLUE, 20)
  self.m_label:setAnchorPoint(0.5, 0.5)
  self.m_textBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_textBg")
  td.AddRelaPos(self.m_textBg, self.m_label)
  self.m_iconBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "spr_light")
  local spine1 = SkeletonUnit:create("Spine/UI_effect/EFT_dedaojineng_02")
  td.AddRelaPos(self.m_iconBg, spine1, -1)
  spine1:PlayAni("animation", true)
end
function InformationDlg:SetData(data)
  self:SetTitle(data.title)
  if data.items then
    self:CreateIcons(data)
  else
    self:CreateIcon(data)
  end
  if data.isSkill then
    self:ShowGoBtn()
  end
  self:CheckGuide()
end
function InformationDlg:CreateIcon(item)
  self.m_iconBg:setVisible(true)
  self.m_icon:setVisible(true)
  self.m_textBg:setVisible(true)
  self.m_icon:loadTexture(item.icon)
  self.m_label:setString(item.name)
end
function InformationDlg:CreateIcons(data)
  for key, val in ipairs(data.items) do
    local item = cc.uiloader:load("CCS/BackpackItem.csb")
    local itemBg = cc.uiloader:seekNodeByName(item, "item_bg")
    local border = itemBg:getChildByName("Image_border")
    local itemIcon
    if data.isSkill then
      itemIcon = td.CreateSkillIcon(val.id)
    elseif val.id > 20000 then
      itemIcon = td.CreateItemIcon(val.id)
    else
      itemIcon = td.CreateWeaponIcon(val.id)
    end
    td.AddRelaPos(border, itemIcon)
    if val.num then
      local textNum = itemBg:getChildByName("Text_num")
      textNum:setString("x" .. val.num)
    end
    local textName = itemBg:getChildByName("Text_name")
    textName:setString(val.name)
    local width = itemBg:getContentSize().width
    local offset = (410 - width * (#data.items - 1)) / (#data.items - 1 + 2)
    local posX = (key - 1) * width + key * offset + 90
    item:setContentSize(itemBg:getContentSize())
    item:setAnchorPoint(0.5, 0.5)
    item:pos(posX, 240):addTo(self.m_bg)
  end
end
function InformationDlg:ShowGoBtn()
  local btn = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_go")
  td.BtnAddTouch(btn, function()
    td.dispatchEvent(td.CLOSE_MODULE, td.UIModule.Pack)
    g_MC:OpenModule(td.UIModule.Hero, nil, {2})
    self:close()
  end)
  btn:setVisible(true)
  td.BtnSetTitle(btn, g_LM:getBy("a00086"))
end
function InformationDlg:AddTouch()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    self:close()
    td.dispatchEvent(td.GUIDE_CONTINUE)
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
return InformationDlg
