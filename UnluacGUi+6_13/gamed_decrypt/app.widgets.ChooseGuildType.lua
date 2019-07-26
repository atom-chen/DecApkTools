local ChooseGuildType = class("ChooseGuildType", function(guildPosition, type)
  return display.newNode()
end)
local UserDataManager = require("app.UserDataManager")
function ChooseGuildType:ctor(guildPosition, type)
  self.m_gdm = UserDataManager:GetInstance():GetGuildManager()
  self.m_guildPosition = guildPosition
  self.m_CurTypeNode = nil
  self.m_CurType = type
  self.m_CurTxt = nil
  self.targetType = nil
  self.targetTxt = nil
  self.bIsClicked = false
  self:CreateCurType()
  if self.m_guildPosition == td.GuildPos.Master then
    self:AddEvent()
  end
  self:AddListeners()
end
function ChooseGuildType:onEnter()
end
function ChooseGuildType:onExit()
  self:RemoveListeners()
end
function ChooseGuildType:AddListeners()
  local eventDsp = self:getEventDispatcher()
  local typeChangeListener = cc.EventListenerCustom:create(td.GUILD_TYPE_CHANGED, handler(self, self.UpdateTypeDisplay))
  eventDsp:addEventListenerWithFixedPriority(typeChangeListener, 1)
end
function ChooseGuildType:RemoveListeners()
  self:getEventDispatcher():removeCustomEventListeners(td.GUILD_TYPE_CHANGED)
end
function ChooseGuildType:SetText(txt, type)
  if type == td.GuildType.Anyone then
    txt:setString(g_LM:getBy("g00016"))
  else
    txt:setString(g_LM:getBy("g00017"))
  end
end
function ChooseGuildType:CreateCurType()
  self.m_CurTypeNode = display.newSprite("UI/guild/leixingdikuang.png")
  self.m_CurTypeNode:addTo(self)
  self.m_CurTxt = td.CreateLabel("", td.WHITE, 18)
  self:SetText(self.m_CurTxt, self.m_CurType)
  td.AddRelaPos(self.m_CurTypeNode, self.m_CurTxt, 1)
end
function ChooseGuildType:AddEvent()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    if not self.m_CurTypeNode:isVisible() then
      return
    end
    local rect = cc.rect(0, 0, self.m_CurTypeNode:getContentSize().width, self.m_CurTypeNode:getContentSize().height)
    local pos = _touch:getLocation()
    local posInRect = self.m_CurTypeNode:convertToNodeSpace({
      x = pos.x,
      y = pos.y
    })
    if cc.rectContainsPoint(rect, posInRect) and not self.bIsClicked then
      self.bIsClicked = true
      self:AddDropDown()
    end
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function ChooseGuildType:AddDropDown(num)
  local chooseType = display.newSprite("UI/guild/leixingdikuang.png")
  chooseType:setAnchorPoint(0, 0)
  if self.m_CurType == td.GuildType.Anyone then
    self.targetType = td.GuildType.Permission
  else
    self.targetType = td.GuildType.Anyone
  end
  td.AddRelaPos(self.m_CurTypeNode, chooseType, 1, cc.p(0, -1))
  local text = td.CreateLabel("", td.WHITE, 18)
  self:SetText(text, self.targetType)
  td.AddRelaPos(chooseType, text, 1)
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(_touch, _event)
    if not chooseType:isVisible() then
      return
    end
    local rect = cc.rect(0, 0, chooseType:getContentSize().width, chooseType:getContentSize().height)
    local pos = _touch:getLocation()
    local posInRect = chooseType:convertToNodeSpace({
      x = pos.x,
      y = pos.y
    })
    if cc.rectContainsPoint(rect, posInRect) then
      local data = {
        guild_type = self.targetType
      }
      self.m_gdm:SendModifyGuildRequest(data)
      print("\229\134\155\229\155\162\231\155\174\229\137\141\231\177\187\229\158\139\228\184\186: " .. self.m_CurType .. "  \231\155\174\230\160\135\231\177\187\229\158\139\228\184\186: " .. self.targetType)
      self.bIsClicked = false
      chooseType:removeSelf()
    else
      self.bIsClicked = false
      chooseType:removeSelf()
    end
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, chooseType)
end
function ChooseGuildType:UpdateTypeDisplay(event)
  print("\229\189\147\229\137\141\229\134\155\229\155\162\231\177\187\229\158\139\230\152\190\231\164\186\229\183\178\231\187\143\230\155\180\230\150\176")
  local newType = tonumber(event:getDataString())
  self.m_CurType = newType
  self:SetText(self.m_CurTxt, self.m_CurType)
end
return ChooseGuildType
