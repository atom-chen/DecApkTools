local ActorManager = require("app.actor.ActorManager")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local MissionInfoManager = require("app.info.MissionInfoManager")
local UserDataManager = require("app.UserDataManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local EditorScene = class("EditorScene", function()
  return display.newScene("EditorScene")
end)
function EditorScene:ctor()
  self.m_dataManager = GameDataManager:GetInstance()
  self.m_eType = td.SceneType.Battle
end
function EditorScene:onCleanup()
  cc.Director:getInstance():getTextureCache():unbindAllImageAsync()
  cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end
function EditorScene:onEnter()
  self:InitGame()
end
function EditorScene:onExit()
  self:removeListeners()
end
function EditorScene:update(dt)
end
function EditorScene:InitGame()
  self.m_pMap = CGameTileMap:create("Map/tiled_shilian/beijing", td.MapType.Trial)
  self.m_pMap:addTo(self)
  self.m_pMap:AddPassableRoadType(11)
  self.m_pMap:GetTileMap():setScale(0.8)
  self.m_uiLayer = require("app.layers.EditorUILayer").new()
  self:addChild(self.m_uiLayer, 101)
  self:AddTouch()
  self:addListeners()
end
function EditorScene:GetGameMap()
  return self.m_pMap
end
function EditorScene:ChangeMap(file)
  self.m_pMap:removeFromParent()
  self.m_pMap = CGameTileMap:create(file, td.MapType.Trial)
  self.m_pMap:addTo(self)
  self.m_pMap:AddPassableRoadType(11)
  self.m_pMap:GetTileMap():setScale(0.8)
end
function EditorScene:addListeners()
  self.m_vCustomListeners = {}
end
function EditorScene:removeListeners()
  local eventDsp = self:getEventDispatcher()
  for i, listener in ipairs(self.m_vCustomListeners) do
    eventDsp:removeEventListener(listener)
  end
end
function EditorScene:AddTouch()
  local touchPos
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    touchPos = _touch:getLocation()
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded(_touch:getLocation(), touchPos)
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function EditorScene:onTouchEnded(endPos, beginPos)
  if cc.pFuzzyEqual(beginPos, endPos, 20) then
    local focusNode = self.m_dataManager:GetFocusNode()
    if focusNode then
      focusNode:DoFocus(beginPos)
    end
  end
end
function EditorScene:SaveScreen()
  local renderTx = cc.RenderTexture:create(display.width, display.height)
  renderTx:begin()
  self.m_pMap:visit()
  renderTx:endToLua()
  renderTx:saveToFile("screen.png", cc.IMAGE_FORMAT_PNG)
end
return EditorScene
