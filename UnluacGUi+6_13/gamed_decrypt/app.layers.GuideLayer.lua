local BaseDlg = require("app.layers.BaseDlg")
local GameDataManager = require("app.GameDataManager")
local GuideLayer = class("GuideLayer", function()
  return display.newLayer()
end)
local UIGuideType = {
  Arrow = 1,
  Empty = 2,
  Bubble = 3,
  Slide = 4
}
function GuideLayer:ctor(uiRoot, info)
  self.m_scale = td.GetAutoScale()
  self.m_guideUiRoot = uiRoot
  self.m_guideInfo = info
  self.m_eType = info.style
  if info.needCallback == false then
    self.m_bNeedCallback = false
  else
    self.m_bNeedCallback = true
  end
  self.m_bSwallowAll = false
  self.m_bIsDone = false
  self.m_bIsInitSuccess = true
  self:setContentSize(display.width, display.height)
  self:setNodeEventEnabled(true)
  self:InitUI()
end
function GuideLayer:onEnter()
  display.getRunningScene():SetPause(true)
  self:AddEvents()
end
function GuideLayer:onExit()
  if self.m_customListener then
    local eventDsp = self:getEventDispatcher()
    eventDsp:removeEventListener(self.m_customListener)
    self.m_customListener = nil
  end
end
function GuideLayer:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  td.SetAutoScale(self.m_uiRoot, td.UIPosVertical.Center, td.UIPosHorizontal.Center)
  self.m_panel = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_panelSize = self.m_panel:getContentSize()
  if self.m_eType == UIGuideType.Bubble then
    self:InitBubble()
  elseif self.m_eType == UIGuideType.Empty then
    self:InitEmpty()
  else
    self:InitClickArea()
  end
end
function GuideLayer:IsInitSuccess()
  return self.m_bIsInitSuccess
end
function GuideLayer:InitBubble()
  local clickSize, clickPos = cc.size(display.width, display.height), cc.p(self.m_panelSize.width / 2, self.m_panelSize.height / 2)
  local function AddBubble(pos, text, index)
    local label = td.CreateLabel(g_LM:getBy(text), td.YELLOW, 16, td.OL_BROWN, 2)
    if label:getContentSize().width > 100 then
      label = td.CreateLabel(g_LM:getBy(text), td.YELLOW, 16, td.OL_BROWN, 2, cc.size(100, 0))
    end
    label:setAnchorPoint(0.5, 0.5)
    local conSize = label:getContentSize()
    local bgHeight = cc.clampf(conSize.height + 20, 46, 500)
    local bgWidth = conSize.width + 20
    local pArrow = display.newScale9Sprite("UI/scale9/paopaokuang2.png", 0, 0, cc.size(bgWidth, bgHeight))
    local arrowPos = cc.p(pos.x, pos.y)
    if arrowPos.y >= display.height * 0.9 then
      arrowPos.y = arrowPos.y - (bgHeight / 2 + 23)
    else
      arrowPos.y = arrowPos.y + (bgHeight / 2 + 23)
      pArrow:setRotation(180)
      label:setRotation(-180)
    end
    td.AddRelaPos(pArrow, label)
    local spr = display.newSprite("UI/scale9/paopaokuang1.png")
    spr:setAnchorPoint(0.5, 0)
    spr:setPosition(bgWidth / 2, bgHeight - 4)
    pArrow:addChild(spr)
    pArrow:setPosition(arrowPos)
    pArrow:setScale(0.01)
    self.m_panel:addChild(pArrow)
    index = index or 1
    pArrow:runAction(cca.seq({
      cca.delay(index * 0.2),
      cca.scaleTo(0.2, 1.2),
      cca.scaleTo(0.2, 0.85),
      cca.scaleTo(0.2, 1)
    }))
    self.m_arrow = pArrow
  end
  if self.m_guideInfo.nodeName then
    local nodeNames = self.m_guideInfo.nodeName
    local texts = self.m_guideInfo.text
    for i, name in ipairs(nodeNames) do
      local targetNode = cc.uiloader:seekNodeByName(self.m_guideUiRoot, name)
      if nil == targetNode then
        self.m_bIsInitSuccess = false
        return
      end
      local pos = cc.p(targetNode:getPosition())
      pos = targetNode:getParent():convertToWorldSpace(pos)
      local box = targetNode:getBoundingBox()
      local size = cc.size(box.width, box.height) or cc.size(display.width, display.height)
      AddBubble(pos, texts[i], i)
    end
  else
    if type(self.m_guideInfo.pos) ~= "table" then
      self.m_guideInfo.pos = {
        self.m_guideInfo.pos
      }
    end
    for i, pos in ipairs(self.m_guideInfo.pos) do
      local pos = GameDataManager.GetInstance():GetGameMap():GetTileMap():convertToWorldSpace(pos)
      AddBubble(pos, self.m_guideInfo.text[i], i)
    end
  end
  self.m_bSwallowAll = true
  local pScale9Spri = display.newScale9Sprite("UI/scale9/transparent1x1.png", 0, 0, clickSize)
  pScale9Spri:setPosition(clickPos)
  self.m_panel:addChild(pScale9Spri)
  self.m_scale9Spri = pScale9Spri
  self:performWithDelay(function()
    if self.m_bIsDone then
      return true
    end
    if not self.m_bNeedCallback then
      self:Close()
    end
  end, 5)
end
function GuideLayer:InitEmpty()
  local clickSize, clickPos = cc.size(display.width, display.height), cc.p(display.width / 2, display.height / 2)
  local pScale9Spri = display.newScale9Sprite("UI/scale9/transparent1x1.png", 0, 0, clickSize)
  pScale9Spri:setPosition(clickPos)
  self.m_panel:addChild(pScale9Spri)
  self.m_scale9Spri = pScale9Spri
end
function GuideLayer:InitClickArea()
  self.m_pos, self.m_size, self.m_bIsInitSuccess = td.GetGuideArea(self.m_guideInfo, self.m_guideUiRoot)
  self.m_pos = self.m_panel:convertToNodeSpace(self.m_pos)
  if not self.m_bIsInitSuccess then
    return
  end
  if self.m_guideInfo.nodeName and not self.m_guideInfo.childId then
    g_MC:SetOnlyEnableName(self.m_guideInfo.nodeName)
  end
  local pos = self.m_pos or cc.p(display.width * 0.5, display.height * 0.5)
  local size = self.m_size or cc.size(100, 100)
  local fileName = "UI/scale9/transparent1x1.png"
  local pScale9Spri = display.newScale9Sprite(fileName, 0, 0, size)
  pScale9Spri:setPosition(pos)
  self.m_panel:addChild(pScale9Spri)
  self.m_scale9Spri = pScale9Spri
  local pArrow = SkeletonUnit:create("Spine/UI_effect/UI_shouzhi_01")
  self.m_panel:addChild(pArrow)
  self.m_arrow = pArrow
  if pos.x > display.width * 0.9 then
    pArrow:setScaleX(-0.6)
  else
    pArrow:setScaleX(0.6)
  end
  pArrow:setScaleY(0.6)
  pArrow:setPosition(pos)
  if self.m_eType == UIGuideType.Slide then
    do
      local moveToPos = cc.p(0, 0)
      if self.m_guideInfo.toNodeName then
        local targetNode = cc.uiloader:seekNodeByName(self.m_guideUiRoot, self.m_guideInfo.toNodeName)
        moveToPos = cc.p(targetNode:getPosition())
        moveToPos = targetNode:getParent():convertToWorldSpace(moveToPos)
      else
        moveToPos = GameDataManager.GetInstance():GetGameMap():GetTileMap():convertToWorldSpace(self.m_guideInfo.toPos)
      end
      pArrow:registerSpineEventHandler(function(event)
        if event.animation == "animation_02" then
          pArrow:PlayAni("animation_01", true)
          pArrow:runAction(cca.seq({
            cca.cb(function()
              local tail = ParticleManager:GetInstance():CreateParticle("Effect/huomiao.plist")
              tail:setScale(2)
              tail:setTag(11)
              pArrow:addChild(tail)
            end),
            cca.moveTo(1, moveToPos.x, moveToPos.y),
            cca.fadeOut(0.1),
            cca.moveTo(0, pos.x, pos.y),
            cca.fadeIn(0.1),
            cca.cb(function()
              pArrow:getChildByTag(11):removeFromParent()
              pArrow:PlayAni("animation_02", false)
            end)
          }))
        end
      end, sp.EventType.ANIMATION_COMPLETE)
      pArrow:PlayAni("animation_02", false)
    end
  else
    pArrow:PlayAni("animation_02", true)
  end
end
function GuideLayer:IsInScene(pos)
  if pos.x < 0 or pos.x > display.width or 0 > pos.y or pos.y > display.height then
    return false
  end
  return true
end
function GuideLayer:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  if self.m_eType ~= UIGuideType.Empty then
    listener:setSwallowTouches(true)
  else
    listener:setSwallowTouches(false)
  end
  listener:registerScriptHandler(function(touch, event)
    if self.m_bIsDone then
      return true
    end
    local pos = self.m_scale9Spri:convertToNodeSpace(touch:getLocation())
    if isTouchInNode(self.m_scale9Spri, pos) then
      if not self.m_bNeedCallback then
        self:Close()
      end
      if not self.m_bSwallowAll then
        return false
      end
    end
    print("guide mask worked")
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  if self.m_bNeedCallback then
    self.m_customListener = cc.EventListenerCustom:create(td.GUIDE_FINISHED, function(event)
      if tonumber(event:getDataString()) == self.m_guideInfo.uiId and not self.m_bIsDone then
        self:Close()
      end
    end)
    eventDsp:addEventListenerWithFixedPriority(self.m_customListener, 1)
  end
end
function GuideLayer:Close()
  if self.m_bIsDone then
    return
  end
  self.m_bIsDone = true
  display.getRunningScene():SetPause(false)
  g_MC:SetOnlyEnableName("")
  if self.m_guideInfo.delay and self.m_guideInfo.delay > 0 then
    self:removeAllChildren()
    self:performWithDelay(function()
      self:removeFromParent(true)
      local GuideManager = require("app.GuideManager")
      GuideManager:GetInstance():UpdateGuide()
    end, self.m_guideInfo.delay)
  else
    self:removeFromParent(true)
    local GuideManager = require("app.GuideManager")
    GuideManager:GetInstance():UpdateGuide()
  end
end
function GuideLayer.AddToNode(uiRoot, info)
  local pLayer = GuideLayer.new(uiRoot, info)
  if pLayer:IsInitSuccess() then
    local runScene = cc.Director:getInstance():getRunningScene()
    runScene:addChild(pLayer)
    pLayer:setLocalZOrder(td.ZORDER.Guide)
    return true
  end
  return false
end
return GuideLayer
