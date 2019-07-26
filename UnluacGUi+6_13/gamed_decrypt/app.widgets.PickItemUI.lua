local ItemInfoManager = require("app.info.ItemInfoManager")
local UserDataManager = require("app.UserDataManager")
local PickItemUI = class("PickItemUI", function(itemId, pos)
  return display.newLayer()
end)
function PickItemUI:ctor(itemId, pos)
  self.m_itemId = itemId
  self.m_pos = pos
  self:InitUI()
  self:setNodeEventEnabled(true)
end
function PickItemUI:onEnter()
  self:AddEvents()
end
function PickItemUI:onExit()
end
function PickItemUI:InitUI()
  self.m_scale = td.GetAutoScale()
  self.bg = display.newScale9Sprite("UI/scale9/lanse_xuanfukuang.png", 0, 0, cc.size(180, 130))
  self.bg:scale(self.m_scale)
  self.bg:pos(self.m_pos.x + 120 * self.m_scale, self.m_pos.y):addTo(self)
  local icon = td.CreateItemIcon(self.m_itemId, true)
  icon:scale(0.6)
  td.CreateUIEffect(icon, "Spine/UI_effect/UI_tishikeyong_01", {loop = true, scale = 0.86})
  td.AddRelaPos(self.bg, icon, 1, cc.p(0.5, 0.6))
  local itemInfo = ItemInfoManager:GetInstance():GetItemInfo(self.m_itemId)
  local labelColor = td.WHITE
  if 1 > UserDataManager:GetInstance():GetItemNum(self.m_itemId) then
    labelColor = td.RED
  end
  local nameLabel = td.CreateLabel(itemInfo.name, labelColor, 20)
  td.AddRelaPos(self.bg, nameLabel, 1, cc.p(0.5, 0.2))
end
function PickItemUI:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    local tmpPos = self.bg:convertToNodeSpace(touch:getLocation())
    if isTouchInNode(self.bg, tmpPos) then
      self:OnClicked()
    else
      self:performWithDelay(function()
        self:removeFromParent()
      end, 0.1)
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
end
function PickItemUI:OnClicked()
  if UserDataManager:GetInstance():GetItemNum(self.m_itemId) > 0 then
    td.dispatchEvent(td.HERO_SKILL_HOLE)
    self:performWithDelay(function()
      self:removeFromParent()
    end, 0.1)
  else
    local tmpNode = require("app.layers.MainMenuUI.ItemSourceDlg").new(self.m_itemId)
    td.popView(tmpNode)
    td.alertErrorMsg(td.ErrorCode.MATERIAL_NOT_ENOUGH)
  end
end
return PickItemUI
