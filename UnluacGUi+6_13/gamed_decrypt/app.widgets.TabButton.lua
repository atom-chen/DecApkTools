local scheduler = require("framework.scheduler")
local TabButton = class("TabButton")
function TabButton:ctor(buttonTable, info)
  self.m_bEnable = true
  self.m_buttonTable = buttonTable
  self.m_iCurTabCount = 0
  self.m_iLastTabCount = 0
  self.m_textPos = cc.p(0.5, 0.5)
  if info then
    self.m_textSize = info.textSize or 24
    self.m_normalTextColor = info.normalTextColor
    self.m_highTextColor = info.highTextColor or self.m_normalTextColor
    self.m_textEffectColor = info.textEffectColor
    self.m_autoSelectIndex = info.autoSelectIndex
    self.m_textPos = info.textPos or self.m_textPos
    self.m_spineInfo = info.spineInfo
  end
  if self.m_spineInfo then
    self.m_isInit = false
    self:PlayInitAnim()
  else
    self:InitTabData()
  end
end
function TabButton:PlayInitAnim()
  for i = 1, #self.m_buttonTable do
    local tab = self.m_buttonTable[i].tab
    local buttonSpine = self.m_buttonTable[i].spine
    if i == 1 then
      buttonSpine:PlayAni(self.m_spineInfo.focusInit, false)
    else
      buttonSpine:PlayAni(self.m_spineInfo.normalInit, false)
    end
  end
  performWithDelay(self.m_buttonTable[1].spine, function()
    self:InitTabData()
  end, self.m_spineInfo.initTime)
end
function TabButton:InitTabData()
  for i, v in ipairs(self.m_buttonTable) do
    v.tab:setTouchEnabled(true)
    v.tab:setUnifySizeEnabled(true)
    v.tab:addTouchEventListener(function(sender, eventType)
      if ccui.TouchEventType.ended == eventType and self.m_bEnable then
        self:changeCount(i)
      end
    end)
    do
      local textData, hlTextData = {}, {}
      if v.text then
        table.insert(textData, {
          type = 1,
          str = v.text,
          color = self.m_normalTextColor,
          size = self.m_textSize
        })
        table.insert(hlTextData, {
          type = 1,
          str = v.text,
          color = self.m_highTextColor,
          size = self.m_textSize
        })
      end
      if v.normalIconFile then
        table.insert(textData, {
          type = 2,
          file = v.normalIconFile,
          scale = v.iconScale or 1
        })
      end
      if v.highIconFile then
        table.insert(hlTextData, {
          type = 2,
          file = v.highIconFile,
          scale = v.iconScale or 1
        })
      end
      if i == 1 or self.m_autoSelectIndex then
        if v.highImageSize then
          v.tab:setContentSize(v.highImageSize)
        end
        v.textData = textData
        v.hlTextData = hlTextData
        v.label = td.RichText(textData)
        v.label:setVisible(false)
        td.AddRelaPos(v.tab, v.label, 1, self.m_textPos)
        v.hlLabel = td.RichText(hlTextData)
        td.AddRelaPos(v.tab, v.hlLabel, 1, self.m_textPos)
      else
        v.textData = textData
        v.hlTextData = hlTextData
        v.label = td.RichText(textData)
        td.AddRelaPos(v.tab, v.label, 1, self.m_textPos)
        v.hlLabel = td.RichText(hlTextData)
        v.hlLabel:setVisible(false)
        td.AddRelaPos(v.tab, v.hlLabel, 1, self.m_textPos)
      end
    end
  end
  scheduler.performWithDelayGlobal(function(dt)
    self:changeCount(self.m_autoSelectIndex or 1)
    self.m_isInit = true
  end, 1.0E-6)
end
function TabButton:changeCount(id)
  if self.m_iCurTabCount == id then
    return
  end
  local preButton = self.m_buttonTable[self.m_iCurTabCount]
  local button = self.m_buttonTable[id]
  if button.callfunc(id) == false then
    return
  end
  if preButton then
    if not self.m_spineInfo then
      preButton.tab:loadTexture(preButton.normalImageFile)
    else
      if preButton.normalImageSize then
        preButton.tab:setContentSize(preButton.normalImageSize)
      end
      preButton.spine:PlayAni(self.m_spineInfo.toNormal, false)
    end
    if preButton.label then
      preButton.label:setVisible(true)
      preButton.hlLabel:setVisible(false)
      preButton.label:setPosition(cc.p(preButton.tab:getContentSize().width * self.m_textPos.x, preButton.tab:getContentSize().height * self.m_textPos.y))
      preButton.hlLabel:setPosition(cc.p(preButton.tab:getContentSize().width * self.m_textPos.x, preButton.tab:getContentSize().height * self.m_textPos.y))
    end
  end
  if self.m_iCurTabCount == 0 then
    self.m_iLastTabCount = id
  else
    self.m_iLastTabCount = self.m_iCurTabCount
  end
  self.m_iCurTabCount = id
  if not self.m_spineInfo then
    button.tab:loadTexture(button.highImageFile)
  else
    if button.highImageSize then
      button.tab:setContentSize(button.highImageSize)
    end
    if self.m_isInit == true then
      button.spine:PlayAni(self.m_spineInfo.toFocus, false)
    end
  end
  if button.label then
    button.label:setVisible(false)
    button.hlLabel:setVisible(true)
    button.label:setPosition(cc.p(button.tab:getContentSize().width * self.m_textPos.x, button.tab:getContentSize().height * self.m_textPos.y))
    button.hlLabel:setPosition(cc.p(button.tab:getContentSize().width * self.m_textPos.x, button.tab:getContentSize().height * self.m_textPos.y))
  end
end
function TabButton:getCurTableCount()
  return self.m_iCurTabCount
end
function TabButton:getLastTableCount()
  return self.m_iLastTabCount
end
function TabButton:setEnable(bEnable)
  self.m_bEnable = bEnable
end
function TabButton:setVisible(b)
  for i, var in ipairs(self.m_buttonTable) do
    var.tab:setVisible(b)
  end
end
return TabButton
