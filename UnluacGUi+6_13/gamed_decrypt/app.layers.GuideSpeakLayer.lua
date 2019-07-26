local GuideSpeakLayer = class("GuideSpeakLayer", function()
  return display.newLayer()
end)
function GuideSpeakLayer:ctor(uiRoot, info)
  self.m_scale = td.GetAutoScale()
  self.m_guideUiRoot = uiRoot
  self.m_guideInfo = info
  self.m_currWorldIndex = 0
  self.m_content = nil
  self.m_bIsShowAll = false
  self.m_bIsDone = false
  self.m_bDidStart = false
  self:setNodeEventEnabled(true)
  self:setContentSize(display.width, display.height)
  self:InitUI()
end
function GuideSpeakLayer:onEnter()
  display.getRunningScene():SetPause(true)
  self:AddEvents()
end
function GuideSpeakLayer:onExit()
end
function GuideSpeakLayer:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  td.SetAutoScale(self.m_uiRoot, td.UIPosVertical.Center, td.UIPosHorizontal.Center)
  self.m_panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_panelSize = self.m_panel:getContentSize()
  if self.m_guideUiRoot and self.m_guideInfo.uiId then
    self:InitHighLightArea()
  else
    self:InitClickArea()
  end
end
function GuideSpeakLayer:InitHighLightArea()
  self.m_pos, self.m_size = td.GetGuideArea(self.m_guideInfo, self.m_guideUiRoot)
  self.m_clipNode = cc.ClippingNode:create()
  self.m_clipNode:setInverted(true)
  self.m_clipNode:addTo(self)
  if not self.m_guideInfo.noMask then
    local colorLayer = display.newColorLayer(td.WIN_COLOR)
    self.m_clipNode:addChild(colorLayer)
  end
  local stencil = display.newNode()
  local sprStencil = display.newScale9Sprite("UI/scale9/guide_area.png", 0, 0, cc.size(self.m_size.width * self.m_scale, self.m_size.height * self.m_scale))
  sprStencil:setScale(0)
  stencil:addChild(sprStencil)
  stencil:setPosition(self.m_pos)
  self.m_clipNode:setStencil(stencil)
  sprStencil:runAction(cca.seq({
    cca.delay(0.2),
    cc.EaseBackOut:create(cca.scaleTo(0.5, 1)),
    cca.cb(function()
      self:InitClickArea()
    end)
  }))
  local spr = display.newScale9Sprite("UI/scale9/guide_area.png", 0, 0, cc.size(self.m_size.width + 20, self.m_size.height + 20), cc.rect(45, 50, 3, 3))
  spr:setScale(0.01)
  spr:setPosition(self.m_panel:convertToNodeSpace(self.m_pos))
  self.m_panel:addChild(spr)
  spr:runAction(cca.seq({
    cca.delay(0.2),
    cc.EaseBackOut:create(cca.scaleTo(0.5, 1))
  }))
  if self.m_guideInfo.color == 2 then
    spr:setColor(cc.c3b(255, 80, 80))
  else
    spr:setColor(cc.c3b(155, 255, 80))
  end
end
function GuideSpeakLayer:InitClickArea()
  if not self.m_guideInfo.content then
    self.m_bDidStart = true
    self.m_bIsShowAll = true
    return
  end
  local bgSize = cc.size(620, 110)
  self.m_bg = display.newScale9Sprite("UI/scale9/tipskuang.png", 0, 0, bgSize)
  self.m_panel:addChild(self.m_bg)
  local diSpr = display.newSprite("UI/scale9/tipstouxiangkuang.png")
  self.m_pIcon = display.newSprite(self.m_guideInfo.icon)
  self.m_pIcon:align(display.CENTER_BOTTOM, 80, 0):addTo(diSpr)
  local nameStr = ""
  if self.m_guideInfo.name then
    if g_LM:getBy(self.m_guideInfo.name) then
      nameStr = g_LM:getBy(self.m_guideInfo.name) .. ":"
    end
  else
    nameStr = "BB-9:"
  end
  local nameLabel = td.CreateLabel(nameStr, td.YELLOW, 16, td.OL_BROWN, 2)
  nameLabel:pos(195, 128):addTo(diSpr)
  local pLabel = td.CreateLabel("", td.WHITE, 20, nil, nil, cc.size(460, bgSize.height - 30))
  pLabel:setAnchorPoint(cc.p(0, 1))
  self.m_bg:addChild(pLabel)
  pLabel:setTag(1)
  if self.m_guideInfo.style == 2 then
    self.m_bg:setAnchorPoint(1, 0)
    self.m_bg:setPosition(cc.p(self.m_panelSize.width - 100, 150))
    diSpr:setScaleX(-1)
    td.AddRelaPos(self.m_bg, diSpr, 1, cc.p(0.9, 0.6))
    nameLabel:setScaleX(-1)
    pLabel:setPosition(cc.p(50, bgSize.height - 15))
  else
    self.m_bg:setAnchorPoint(0, 0)
    self.m_bg:setPosition(cc.p(100, 150))
    td.AddRelaPos(self.m_bg, diSpr, 1, cc.p(0.1, 0.6))
    pLabel:setPosition(cc.p(110, bgSize.height - 15))
  end
  self.m_content = g_LM:getBy(self.m_guideInfo.content)
  self.m_currWorldIndex = 1
  self:StartShowWord()
end
function GuideSpeakLayer:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if self.m_bIsDone or not self.m_bDidStart then
      return true
    end
    if not self.m_bIsShowAll then
      self.m_bg:getChildByTag(1):setString(self.m_content)
      self.m_bIsShowAll = true
    else
      self.m_bIsDone = true
      self:performWithDelay(function()
        self:NextOrClose()
      end, 0.1)
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function GuideSpeakLayer:NextOrClose()
  if self.m_guideInfo.delay and self.m_guideInfo.delay > 0 then
    self:setVisible(false)
    self:performWithDelay(function()
      local GuideManager = require("app.GuideManager")
      GuideManager:GetInstance():UpdateGuide()
      self:removeFromParent(true)
      display.getRunningScene():SetPause(false)
    end, self.m_guideInfo.delay)
  else
    local GuideManager = require("app.GuideManager")
    GuideManager:GetInstance():UpdateGuide()
    self:removeFromParent(true)
    display.getRunningScene():SetPause(false)
  end
end
function GuideSpeakLayer:StartShowWord()
  self.m_bDidStart = true
  local bIsEnd, str = self:GetString()
  if not bIsEnd then
    self:performWithDelay(function()
      if not self.m_bIsShowAll then
        self.m_bg:getChildByTag(1):setString(str)
        self:StartShowWord()
      end
    end, 0.05)
  else
    self.m_bIsShowAll = true
    self.m_content = nil
    self.m_currWorldIndex = 1
  end
end
function GuideSpeakLayer.AddToScene(uiRoot, info)
  local pLayer = GuideSpeakLayer.new(uiRoot, info)
  local runScene = cc.Director:getInstance():getRunningScene()
  runScene:addChild(pLayer)
  pLayer:setLocalZOrder(td.ZORDER.Speak)
  pLayer:setPosition(cc.p(0, 0))
end
function GuideSpeakLayer:GetString()
  local str = self.m_content or ""
  local lenInByte = #str
  if lenInByte > self.m_currWorldIndex then
    local i = self.m_currWorldIndex
    local curByte = string.byte(str, i)
    local byteCount = 1
    if curByte > 0 and curByte <= 127 then
      byteCount = 1
    elseif curByte >= 192 and curByte <= 223 then
      byteCount = 2
    elseif curByte >= 224 and curByte <= 239 then
      byteCount = 3
    elseif curByte >= 240 and curByte <= 247 then
      byteCount = 4
    end
    local char = string.sub(str, 1, i + byteCount - 1)
    self.m_currWorldIndex = self.m_currWorldIndex + byteCount
    return false, char
  end
  return true, nil
end
return GuideSpeakLayer
