local BaseDlg = require("app.layers.BaseDlg")
local UserDataManager = require("app.UserDataManager")
local GuildInfoManager = require("app.info.GuildInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local NormalItemSize = cc.size(625, 90)
local GuildSkillDlg = class("GuildSkillDlg", BaseDlg)
function GuildSkillDlg:ctor(id)
  GuildSkillDlg.super.ctor(self)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_gdMng = self.m_udMng:GetGuildManager()
  self.m_id = id
  self.m_skillId = nil
  self.m_data = self.m_gdMng:GetBuildData(id)
  self.m_vSkill = GuildInfoManager:GetInstance():GetBuildingInfo(id).skills
  self.m_scrollPos = nil
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function GuildSkillDlg:onEnter()
  GuildSkillDlg.super.onEnter(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UpgradeGuildSkill, handler(self, self.UpgradeCallback))
  self:AddEvents()
end
function GuildSkillDlg:onExit()
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.UpgradeGuildSkill)
  GuildSkillDlg.super.onExit(self)
end
function GuildSkillDlg:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  self:setAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  local panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  local bgSize = cc.size(675, 470)
  self.m_bg = display.newScale9Sprite("UI/scale9/yijitankuang2.png", 0, 0, bgSize, cc.rect(110, 80, 5, 2))
  td.AddRelaPos(panel, self.m_bg)
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 625, 410),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_UIListView:onTouch(function(event)
    if event.name == "ended" then
      self.m_scrollPos = cc.p(self.m_UIListView:getScrollNode():getPosition())
    end
  end)
  self.m_UIListView:setAnchorPoint(0, 0)
  self.m_UIListView:setPosition(25, 30)
  self.m_UIListView:setAlignment(3)
  self.m_bg:addChild(self.m_UIListView)
  self:RefreshList()
end
function GuildSkillDlg:RefreshList()
  self.m_UIListView:removeAllItems()
  local giMng = GuildInfoManager:GetInstance()
  for i, id in ipairs(self.m_vSkill) do
    local info = giMng:GetSkillInfo(id)
    local item = self:CreateItem(info)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
  if self.m_scrollPos then
    self.m_UIListView:scrollTo(self.m_scrollPos)
  end
end
function GuildSkillDlg:CreateItem(info)
  local skillLevel = self.m_udMng:GetGuildSkillLevel(info.id)
  local itemUI = display.newNode()
  local itemBg = display.newScale9Sprite("UI/scale9/transparent1x1.png", 0, 0, NormalItemSize)
  itemBg:setAnchorPoint(0, 0)
  itemBg:addTo(itemUI)
  local icon = display.newSprite(info.icon .. td.PNG_Suffix)
  icon:scale(0.65)
  td.AddRelaPos(itemBg, icon, 1, cc.p(0.08, 0.5))
  local border = display.newSprite("UI/backpack/item_border1.png")
  border:scale(1.1)
  td.AddRelaPos(icon, border)
  local levelLabel = td.CreateLabel("LV." .. skillLevel, td.LIGHT_GREEN, 18)
  levelLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itemBg, levelLabel, 1, cc.p(0.15, 0.75))
  local growthNum = info.growth_rate * skillLevel
  local descLabel = td.CreateLabel2({
    str = string.format(info.desc, growthNum),
    color = td.BLUE,
    size = 18,
    dimen = cc.size(230, 55),
    valign = 1
  })
  descLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itemBg, descLabel, 1, cc.p(0.15, 0.35))
  local tmpLabel = td.CreateLabel(g_LM:getBy("a00082") .. ": ", td.BLUE, 18)
  tmpLabel:setAnchorPoint(1, 0.5)
  td.AddRelaPos(itemBg, tmpLabel, 1, cc.p(0.67, 0.5))
  local costLabel = td.CreateLabel(tostring(info.need[skillLevel + 1]), td.WHITE, 18)
  costLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itemBg, costLabel, 1, cc.p(0.67, 0.5))
  local btn = td.CreateBtn(td.BtnType.GreenShort)
  btn:setName("Button_3")
  td.BtnAddTouch(btn, function()
    self:SendUpgradeReq(info.id)
  end, 64, td.ButtonEffectType.Short)
  td.BtnSetTitle(btn, g_LM:getBy("a00094"))
  td.AddRelaPos(itemBg, btn, 1, cc.p(0.87, 0.5))
  local bEnable, errorCode = self:CheckUpgrade(info.id)
  if not bEnable then
    btn:setDisable(true)
  end
  local lineSpr = display.newSprite("UI/common/fengexian_shu.png")
  lineSpr:setScaleX(NormalItemSize.width / lineSpr:getContentSize().width)
  td.AddRelaPos(itemBg, lineSpr, 1, cc.p(0.5, 0))
  local item = self.m_UIListView:newItem(itemUI)
  item:setItemSize(NormalItemSize.width * self.m_scale, (NormalItemSize.height + 5) * self.m_scale)
  item:setScale(self.m_scale)
  item:setAnchorPoint(cc.p(0.5, 0.5))
  return item
end
function GuildSkillDlg:CheckUpgrade(id)
  local skillLevel = self.m_udMng:GetGuildSkillLevel(id)
  if skillLevel >= self.m_data.level then
    return false, td.ErrorCode.LEVEL_MAX
  end
  local info = GuildInfoManager:GetInstance():GetSkillInfo(id)
  local contribution = self.m_gdMng:GetSelfData().contribute
  if contribution < info.need[skillLevel + 1] then
    return false, td.ErrorCode.MATERIAL_NOT_ENOUGH
  end
  return true
end
function GuildSkillDlg:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local bResult = false
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_UIListView:onTouch_({
        name = "began",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
      bResult = true
      self.m_bIsTouchInList = true
    else
      local tmpPos = self.m_bg:convertToNodeSpace(touch:getLocation())
      if not isTouchInNode(self.m_bg, tmpPos) then
        self:performWithDelay(function()
          self:close()
        end, 0.1)
        bResult = true
      end
      self.m_bIsTouchInList = false
    end
    return bResult
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_UIListView:onTouch_({
        name = "moved",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    if self.m_bIsTouchInList then
      self.m_UIListView:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function GuildSkillDlg:SendUpgradeReq(id)
  if self.m_skillId then
    return
  end
  self.m_skillId = id
  local tdRequest = TDHttpRequest:getInstance()
  local Msg = {}
  Msg.msgType = td.RequestID.UpgradeGuildSkill
  Msg.sendData = {
    type = self.m_id,
    skill_id = id
  }
  tdRequest:Send(Msg)
end
function GuildSkillDlg:UpgradeCallback(data)
  if data.state == td.ResponseState.Success then
    self.m_gdMng:LearnSkill(self.m_skillId)
    self:RefreshList()
  else
    td.alert(g_LM:getBy("a00323"))
  end
  self.m_skillId = nil
end
return GuildSkillDlg
