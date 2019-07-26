local BaseDlg = require("app.layers.BaseDlg")
local ItemInfoManager = require("app.info.ItemInfoManager")
local MissionInfoManager = require("app.info.MissionInfoManager")
local ItemSourceDlg = class("ItemSourceDlg", BaseDlg)
function ItemSourceDlg:ctor(itemId)
  ItemSourceDlg.super.ctor(self)
  self:InitUI()
  self:SetData(itemId)
end
function ItemSourceDlg:onEnter()
  ItemSourceDlg.super.onEnter(self)
  self:AddEvents()
end
function ItemSourceDlg:onExit()
  ItemSourceDlg.super.onExit(self)
end
function ItemSourceDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
    if not isTouchInNode(self.m_bg, tmpPos) then
      self:performWithDelay(function()
        self:close()
      end, 0.1)
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function ItemSourceDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/ItemSourceDlg.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_bg")
  local titleSpr = display.newSprite(td.Word_Path .. "wenzi_wupingxiangqing.png")
  td.AddRelaPos(self.m_bg, titleSpr, 1, cc.p(0.5, 0.9))
  self.iconBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Image_iconBg")
  self.nameLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_name")
  self.descLabel = cc.uiloader:seekNodeByName(self.m_bg, "Text_desc")
end
function ItemSourceDlg:SetData(itemId)
  self.m_itemInfo = ItemInfoManager:GetInstance():GetItemInfo(itemId)
  self.iconSpr = td.IconWithStar(self.m_itemInfo.icon .. td.PNG_Suffix, self.m_itemInfo.quality, nil, -60)
  self.iconSpr:scale(1.2)
  td.AddRelaPos(self.iconBg, self.iconSpr, 1, cc.p(0.5, 0.55))
  self.nameLabel:setString(self.m_itemInfo.name)
  self.descLabel:setString(self.m_itemInfo.desc)
  self:CreateButton(self.m_itemInfo.source)
end
function ItemSourceDlg:CreateButton(source)
  for i = 1, 4 do
    do
      local button = cc.uiloader:seekNodeByName(self.m_uiRoot, "Button_" .. i)
      if source[i] then
        if source[i].type == 1 then
          local missionInfo = MissionInfoManager:GetInstance():GetMissionInfo(source[i].id)
          if missionInfo.mode == 2 then
            button:loadTextures("UI/button/huangsebantouming1_button.png", "UI/button/huangsebantouming2_button.png")
          elseif missionInfo.mode == 3 then
            button:loadTextures("UI/button/zisebantouming1_button.png", "UI/button/zisebantouming2_button.png")
          end
        end
        td.BtnAddTouch(button, function()
          self:DoEvent(source[i])
        end)
        td.BtnSetTitle(button, self:GetSourceStr(source[i]))
        button:setVisible(true)
        if not self:CheckSourceOpen(source[i]) then
          button:setColor(td.BTN_PRESSED_COLOR)
        end
      end
    end
  end
end
function ItemSourceDlg:CheckSourceOpen(source)
  local bOpen = false
  if source.type == 1 then
    bOpen = MissionInfoManager:GetInstance():IsMissionUnlock(source.id)
  elseif source.type == 2 then
    bOpen = g_MC:IsModuleUnlock(td.UIModule.Dungeon)
  elseif source.type == 3 then
    bOpen = g_MC:IsModuleUnlock(td.UIModule.Dungeon)
  elseif source.type == 4 then
    bOpen = g_MC:IsModuleUnlock(td.UIModule.Store)
  end
  return bOpen
end
function ItemSourceDlg:DoEvent(source)
  if source.type == 1 then
    g_MC:OpenModule(td.UIModule.MissionDetail, source.id)
  elseif source.type == 2 then
    g_MC:OpenModule(td.UIModule.Dungeon)
  elseif source.type == 3 then
    g_MC:OpenModule(td.UIModule.Dungeon)
  elseif source.type == 4 then
    g_MC:OpenModule(td.UIModule.Store)
  end
end
function ItemSourceDlg:GetSourceStr(source)
  local result = ""
  if source.type == 1 then
    local missionInfo = MissionInfoManager:GetInstance():GetMissionInfo(source.id)
    result = missionInfo.name
  elseif source.type == 2 then
    result = g_LM:getBy("a00120")
  elseif source.type == 3 then
    result = g_LM:getBy("a00286")
  elseif source.type == 4 then
    result = g_LM:getBy("a00095")
  end
  return result
end
return ItemSourceDlg
