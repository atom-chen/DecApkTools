local GuildContentBase = require("app.layers.guild.GuildContentBase")
local UserDataManager = require("app.UserDataManager")
local CommanderInfoManager = require("app.info.CommanderInfoManager")
local GuildInfoManager = require("app.info.GuildInfoManager")
local GuildBuildingBtn = require("app.widgets.GuildBuildingBtn")
local GuildGizmo = require("app.widgets.GuildGizmo")
local GuildCrystal = require("app.widgets.GuildCrystal")
local GuildBuildings = class("GuildBuildings", GuildContentBase)
function GuildBuildings:ctor(height)
  GuildBuildings.super.ctor(self, height)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_gdMng = self.m_udMng:GetGuildManager()
  self.m_vBuilding = {}
  self.m_focusBuild = nil
  self.gizmos = {}
  self:InitUI()
end
function GuildBuildings:onEnter()
  self:AddCustomEvent(td.CONTRIBUTION_CHANGED, function()
    local selfData = self.m_gdMng:GetSelfData()
    self.m_contriLabel:setString("" .. math.floor(selfData.contribute))
  end)
  self:AddCustomEvent(td.BUILDING_UPGRADE, handler(self, self.BuildingUpgrade))
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
  self:scheduleUpdate()
  self:AddTouch()
end
function GuildBuildings:onExit()
  GuildBuildings.super.onExit(self)
  self:removeNodeEventListener(handler(self, self.update))
  self:unscheduleUpdate()
end
function GuildBuildings:update(dt)
  for key, val in ipairs(self.gizmos) do
    val:Update(dt)
    val:setLocalZOrder(self.m_mapHeight - val:getPositionY())
    local delScale = val:GetScale() * (-0.6 / self.m_mapHeight * val:getPositionY() + 1.3)
    val:setScale(delScale, delScale)
  end
end
function GuildBuildings:InitUI()
  self.m_mapRect = cc.rect(-453, -self.m_bgHeight, 906, self.m_bgHeight)
  cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2D_PIXEL_FORMAT_RGB565)
  self.m_map = display.newSprite("UI/guild/guild_map.png")
  cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2D_PIXEL_FORMAT_RGBA8888)
  self.m_map:pos(0, 0):scale(self.m_mapRect.height * self.m_scale / self.m_map:getContentSize().height)
  self.m_mapHeight = self.m_map:getContentSize().height
  local emptyNode = cc.Node:create()
  emptyNode:pos(0, -self.m_mapRect.height / 2 * self.m_scale)
  emptyNode:addChild(self.m_map)
  self.m_scrollView = cc.ui.UIScrollView.new({
    viewRect = self.m_mapRect,
    scale = self.m_scale
  }):addScrollNode(emptyNode):setDirection(cc.ui.UIScrollView.DIRECTION_HORIZONTAL):setBounceable(false):onScroll(handler(self, self.scrollListener)):addTo(self)
  self:CreateUserInfo()
  self:CreateBuilding()
  self:CreateCrystals()
  self:CreateGizmos()
  self:ShowGuildNotice()
end
function GuildBuildings:CreateUserInfo()
  local pos = cc.p(-450, -60)
  self.m_infoBg = display.newSprite("UI/guild/touxiangkuang1.png")
  self.m_infoBg:align(display.LEFT_CENTER, pos.x, pos.y):addTo(self, 10)
  local portraitInfo = CommanderInfoManager:GetInstance():GetPortraitInfo(self.m_udMng:GetPortrait())
  local portraitSpr = display.newSprite(portraitInfo.file .. td.PNG_Suffix)
  portraitSpr:scale(0.5):pos(60, 55):addTo(self.m_infoBg)
  local nameLabel = td.CreateLabel(self.m_udMng:GetNickname(), td.YELLOW, 20, td.OL_BROWN)
  nameLabel:align(display.LEFT_CENTER, 130, 75):addTo(self.m_infoBg)
  local selfData = self.m_gdMng:GetSelfData()
  local tmpLabel = td.CreateLabel(g_LM:getBy("g00025") .. ": ", td.LIGHT_BLUE, 22)
  tmpLabel:align(display.LEFT_CENTER, 130, 45):addTo(self.m_infoBg)
  self.m_contriLabel = td.CreateLabel("" .. math.floor(selfData.contribute), td.LIGHT_BLUE, 20)
  self.m_contriLabel:align(display.LEFT_CENTER, 210, 45):addTo(self.m_infoBg)
end
function GuildBuildings:CreateBuilding()
  local vBuildingData = self.m_gdMng:GetGuildData().builds
  local giMng = GuildInfoManager:GetInstance()
  for i, data in ipairs(vBuildingData) do
    local info = giMng:GetBuildingInfo(data.id)
    local building = GuildBuildingBtn.new(info, data)
    building:pos(info.pos.x, info.pos.y):addTo(self.m_map, self.m_mapHeight - info.pos.y)
    table.insert(self.m_vBuilding, building)
  end
end
function GuildBuildings:ShowGuildNotice()
  self.m_noticeBg = display.newScale9Sprite("UI/guild/gonggaokuang.png", 0, 0, cc.size(220, 140))
  self.m_noticeBg:pos(340, -75):addTo(self, 10)
  self.m_noticeTitle = td.CreateLabel(g_LM:getBy("a00244") .. "\239\188\154", td.WHITE, 20)
  self.m_noticeTitle:setAnchorPoint(0, 0)
  td.AddRelaPos(self.m_noticeBg, self.m_noticeTitle, 0, cc.p(0.05, 0.8))
  self.m_textBg = display.newScale9Sprite("UI/scale9/bantouming5.png", 0, 0, cc.size(200, 100))
  td.AddRelaPos(self.m_noticeBg, self.m_textBg, 0, cc.p(0.5, 0.4))
  local currNotice = self.m_gdMng:GetGuildData().notice or " "
  self.m_noticeLabel = td.CreateLabel(currNotice, td.LIGHT_BLUE, 18, nil, nil, cc.size(180, 100))
  td.AddRelaPos(self.m_textBg, self.m_noticeLabel)
  self.m_noticeLabel:setAnchorPoint(0.5, 0.5)
  if self.m_gdMng:GetSelfData().type < td.GuildPos.Member then
    self.m_noticeEditBox = ccui.EditBox:create(cc.size(220, 120), "UI/guild/gonggaokuang.png")
    self.m_noticeEditBox:setOpacity(0)
    local children = self.m_noticeEditBox:getChildren()
    for key, val in ipairs(children) do
      val:setOpacity(0)
    end
    td.AddRelaPos(self.m_noticeBg, self.m_noticeEditBox)
    self.m_noticeEditBox:registerScriptEditBoxHandler(function(event)
      if event == "changed" then
        local text = self.m_noticeEditBox:getText()
        self.m_noticeLabel:setString(text)
        self.m_confirmBtn:setVisible(true)
      end
    end)
    self.m_confirmBtn = td.CreateBtn(td.BtnType.GreenShort)
    td.BtnSetTitle(self.m_confirmBtn, g_LM:getBy("a00009"))
    td.BtnAddTouch(self.m_confirmBtn, function()
      self.m_gdMng:SendModifyGuildRequest({
        notice = self.m_noticeLabel:getString()
      })
      self.m_confirmBtn:setVisible(false)
    end)
    self.m_confirmBtn:setVisible(false)
    td.AddRelaPos(self.m_noticeBg, self.m_confirmBtn, 1, cc.p(0.5, -0.35))
  end
end
function GuildBuildings:CreateCrystals()
  local crystals = {
    [1] = {
      id = 3,
      posX = 680,
      posY = 540,
      scale = 0.5
    },
    [2] = {
      id = 2,
      posX = 890,
      posY = 520,
      scale = 0.5
    },
    [3] = {
      id = 5,
      posX = 200,
      posY = 565,
      scale = 0.5
    },
    [4] = {
      id = 4,
      posX = 445,
      posY = 550,
      scale = 0.5
    },
    [5] = {
      id = 1,
      posX = 1010,
      posY = 560,
      scale = 0.5
    }
  }
  for key, val in ipairs(crystals) do
    local crys = GuildCrystal.new(val.id)
    crys:addTo(self.m_map)
    crys:pos(val.posX, val.posY)
    crys:scale(val.scale, val.scale)
  end
end
function GuildBuildings:CreateGizmos()
  local GizmoConfig = require("app.config.gizmos_config")
  for i, val in ipairs(GizmoConfig) do
    local gizmo = GuildGizmo.new(i)
    gizmo:addTo(self.m_map)
    table.insert(self.gizmos, gizmo)
  end
end
function GuildBuildings:AddTouch()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, _event)
    if not self:isVisible() then
      return
    end
    self.m_bTouchInScrollView = false
    local rect = self.m_mapRect
    local pos = touch:getLocation()
    local posInRect = self:convertToNodeSpace({
      x = pos.x,
      y = pos.y
    })
    if cc.rectContainsPoint(rect, posInRect) then
      if self:OnTouchBegan(pos) then
        return true
      elseif self.m_scrollView:isTouchInViewRect({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.m_bTouchInScrollView = true
        self.m_scrollView:onTouch_({
          name = "began",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
        return true
      end
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_bTouchInScrollView then
      if self.m_scrollView:isTouchInViewRect({
        x = touch:getLocation().x,
        y = touch:getLocation().y
      }) then
        self.m_scrollView:onTouch_({
          name = "moved",
          x = touch:getLocation().x,
          y = touch:getLocation().y,
          prevX = touch:getPreviousLocation().x,
          prevY = touch:getPreviousLocation().y
        })
      end
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    self.m_scrollView:onTouch_({
      name = "ended",
      x = touch:getLocation().x,
      y = touch:getLocation().y,
      prevX = touch:getPreviousLocation().x,
      prevY = touch:getPreviousLocation().y
    })
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function GuildBuildings:OnTouchBegan(pos)
  pos = self.m_map:convertToNodeSpace(pos)
  for i, build in ipairs(self.m_vBuilding) do
    local rect = build:getBoundingBox()
    if cc.rectContainsPoint(rect, pos) then
      if self.m_focusBuild ~= build then
        if self.m_focusBuild then
          self.m_focusBuild:OnTouchBegan()
          self.m_infoBg:setVisible(true)
          self.m_noticeBg:setVisible(true)
        end
        self.m_focusBuild = build
        self.m_focusBuild:OnTouchBegan()
        self.m_infoBg:setVisible(false)
        self.m_noticeBg:setVisible(false)
      end
      return true
    end
  end
  if self.m_focusBuild then
    self.m_focusBuild:OnTouchBegan()
    self.m_focusBuild = nil
    self.m_infoBg:setVisible(true)
    self.m_noticeBg:setVisible(true)
    return true
  else
    self.m_infoBg:setVisible(true)
    self.m_noticeBg:setVisible(true)
    return false
  end
end
function GuildBuildings:scrollListener(event)
end
function GuildBuildings:BuildingUpgrade(_event)
  local id = tonumber(_event:getDataString())
  if id ~= 0 then
    local lvl = self.m_gdMng:GetBuildingLevel(id)
    self.m_vBuilding[id]:CreateNameLabel()
  end
end
function GuildBuildings:ShowRps()
  local rpBuildings = self.m_gdMng:GetRPBuildings()
  for key, val in ipairs(rpBuildings) do
    if val == true then
      td.ShowRP(self.m_vBuilding[key], true, cc.p(3, 3))
    else
      val = false
      td.ShowRP(self.m_vBuilding[key], false)
    end
  end
end
return GuildBuildings
