local BaseDlg = require("app.layers.BaseDlg")
local MissionInfoManger = require("app.info.MissionInfoManager")
local InterludeLayer = class("InterludeLayer", function()
  return display.newLayer()
end)
function InterludeLayer:ctor(missionId, cb)
  self.m_content = nil
  self.m_currWordIndex = 1
  self.m_bIsShowAll = false
  self.m_updateTime = 0.05
  self.m_cb = cb
  self:SetContent(missionId)
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function InterludeLayer:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/EmptyLayer.csb")
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  td.SetAutoScale(self.m_uiRoot, td.UIPosVertical.Center, td.UIPosHorizontal.Center)
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_content")
  self.m_text = td.CreateLabel("", td.WHITE, 24, nil, nil, cc.size(580, 0))
  self.m_text:setAnchorPoint(0, 1)
  td.AddRelaPos(self.m_bg, self.m_text, 1, cc.p(0.2447, 0.75))
end
function InterludeLayer:SetContent(missionId)
  self.m_content = MissionInfoManger:GetInstance():GetMissionInfo(missionId).story
end
function InterludeLayer:onEnter()
  self:AddEvent()
  self:StartShowWord()
end
function InterludeLayer:AddEvent()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if not self.m_bIsShowAll then
      self.m_text:setString(self.m_content)
      self:ShowWordDone()
    else
      self.m_cb()
      self:removeFromParent(true)
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function InterludeLayer:StartShowWord()
  self.m_bDidStart = true
  local bIsEnd, str = self:GetString()
  if not bIsEnd then
    self:performWithDelay(function()
      if not self.m_bIsShowAll then
        self.m_text:setString(str)
        self:StartShowWord()
      end
    end, self.m_updateTime)
  else
    self:ShowWordDone()
  end
end
function InterludeLayer:ShowWordDone()
  local reminder = td.CreateLabel(g_LM:getBy("a00409"), td.WHITE, 24)
  td.AddRelaPos(self.m_bg, reminder, 1, cc.p(0.5, 0.15))
  reminder:runAction(cca.repeatForever(cca.seq({
    cca.fadeOut(0.6, 0),
    cca.fadeIn(0.6, 1)
  })))
  self.m_bIsShowAll = true
  self.m_content = nil
  self.m_currWordIndex = 1
end
function InterludeLayer:GetString()
  if not self.m_bIsShowAll then
    local str = self.m_content or ""
    local lenInByte = #str
    if lenInByte > self.m_currWordIndex then
      local i = self.m_currWordIndex
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
      self.m_currWordIndex = self.m_currWordIndex + byteCount
      return false, char
    end
  end
  return true, nil
end
return InterludeLayer
