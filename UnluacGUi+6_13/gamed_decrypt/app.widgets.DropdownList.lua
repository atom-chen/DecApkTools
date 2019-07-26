local DropdownList = class("DropdownList", function(dropdownConfig)
  return display.newSprite()
end)
function DropdownList:ctor(itemList, config)
  self.m_dropdownList = itemList
  self.m_config = config
  self.m_fontSize = self.m_config.fontSize or 24
  self.m_buttonList = {}
  self.m_index = self.m_config.initIndex or 1
  self.bIsClicked = false
  self:InitTopButton()
  self:AddEvents()
end
function DropdownList:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local rect = event:getCurrentTarget():getBoundingBox()
    local pos = touch:getLocation()
    pos = self:getParent():convertToNodeSpace({
      x = pos.x,
      y = pos.y
    })
    if cc.rectContainsPoint(rect, pos) and td.IsVisible(self) then
      if self.bIsClicked == false then
        self:CreateList()
        self:performWithDelay(function()
          self.bIsClicked = true
        end, 0.1)
      else
        self:DumpList()
        self:performWithDelay(function()
          self.bIsClicked = false
        end, 0.1)
      end
      G_SoundUtil:PlaySound(53, false)
      return true
    elseif self.bIsClicked and td.IsVisible(self) then
      self:DumpList()
      self.bIsClicked = false
      return true
    end
    return false
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function DropdownList:InitTopButton()
  local normalBg, pressBg, disableBg
  if not self.m_config.mainBg then
    normalBg = self.m_dropdownList[self.m_index].normalBg
    pressBg = self.m_dropdownList[self.m_index].pressBg or normalBg
    disableBg = self.m_dropdownList[self.m_index].disableBg or pressBg
  else
    normalBg = self.m_config.normalMainBg
    pressBg = self.m_config.pressMainBg or normalBg
    disableBg = self.m_config.disableMainBg or pressBg
  end
  self:setTexture(normalBg)
  local icon = ccui.ImageView:create(self.m_dropdownList[self.m_index].icon)
  icon:setName("icon")
  icon:setScale(0.6)
  icon:setAnchorPoint(cc.p(0.5, 0.5))
  td.AddRelaPos(self, icon, 1, cc.p(0.9, 0.5))
  td.BtnSetTitle(self, self.m_dropdownList[self.m_index].str, self.m_fontSize)
end
function DropdownList:CreateList()
  local length = #self.m_dropdownList
  local j = 1
  for i = 1, length do
    if i ~= self.m_index then
      do
        local normalBg = self.m_dropdownList[i].normalBg
        local pressBg = self.m_dropdownList[i].pressBg or normalBg
        local disableBg = self.m_dropdownList[i].disableBg or pressBg
        local button
        if self.m_dropdownList[i].disable then
          button = ccui.Button:create(disableBg, disableBg, disableBg)
        else
          button = ccui.Button:create(normalBg, pressBg, disableBg)
          local icon = display.newSprite(self.m_dropdownList[i].icon)
          icon:setScale(0.6)
          td.AddRelaPos(button, icon, 1, cc.p(0.9, 0.5))
        end
        button:setAnchorPoint(cc.p(0, 0))
        td.BtnSetTitle(button, self.m_dropdownList[i].str, self.m_fontSize)
        td.AddRelaPos(self, button, 1, cc.p(0, -j))
        table.insert(self.m_buttonList, button)
        td.BtnAddTouch(button, function()
          local bResult = self.m_dropdownList[i].callfunc(i)
          if bResult == nil or bResult == true then
            self.bIsClicked = false
            self.m_index = i
            td.BtnSetTitle(self, self.m_dropdownList[i].str, self.m_fontSize)
            self:getChildByName("icon"):loadTexture(self.m_dropdownList[i].icon)
            if not self.m_config.mainBg then
              self:setTexture(normalBg)
            end
            self:DumpList()
          end
        end)
        j = j + 1
      end
    end
  end
end
function DropdownList:DumpList()
  for k, v in ipairs(self.m_buttonList) do
    v:removeFromParent(true)
  end
  self.m_buttonList = {}
end
return DropdownList
