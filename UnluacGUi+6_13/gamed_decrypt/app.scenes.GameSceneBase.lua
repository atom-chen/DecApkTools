local GameControl = require("app.GameControl")
local ActorManager = require("app.actor.ActorManager")
local GameDataManager = require("app.GameDataManager")
local EffectManager = require("app.effect.EffectManager")
local TriggerManager = require("app.trigger.TriggerManager")
local BuffManager = require("app.buff.BuffManager")
local UserDataManager = require("app.UserDataManager")
local UnitDataManager = require("app.UnitDataManager")
local GameSceneBase = class("GameSceneBase", function()
  return display.newScene("GameSceneBase")
end)
function GameSceneBase:ctor()
  self.m_eType = td.SceneType.Non
  self.m_iPause = 0
  self.m_timeScale = 1
  self.m_uiRoot = nil
  self.m_eEnterModuleId = nil
  self.m_vCustomListeners = {}
end
function GameSceneBase:onEnter()
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
  self:scheduleUpdate()
  local soundPreload = require("app.config.sound_preload_ui")
  if soundPreload[self.m_eType] then
    for i, id in ipairs(soundPreload[self.m_eType]) do
      G_SoundUtil:PreloadSound(id)
    end
  end
end
function GameSceneBase:onExit()
  self:removeNodeEventListener(handler(self, self.update))
  self:unscheduleUpdate()
  self:RemoveListeners()
  self.m_timeScale = 1
  G_SoundUtil:Stop(true)
  local soundPreload = require("app.config.sound_preload_ui")
  if soundPreload[self.m_eType] then
    for i, id in ipairs(soundPreload[self.m_eType]) do
      G_SoundUtil:UnloadSound(id)
    end
  end
  GameControl.ClearValueForType(td.GameControlType.SwichScene)
end
function GameSceneBase:update(dt)
  UserDataManager:GetInstance():Update(dt)
  UnitDataManager:GetInstance():Update(dt)
  TriggerManager:GetInstance():Update(dt)
  local time = self.m_timeScale * dt
  if self.m_eType == td.SceneType.Battle then
    GameDataManager:GetInstance():Update(time)
    EffectManager:GetInstance():Update(time)
    BuffManager:GetInstance():Update(time)
    ActorManager:GetInstance():Update(time)
  end
end
function GameSceneBase:GetType()
  return self.m_eType
end
function GameSceneBase:SetPause(bPause)
  self.m_iPause = bPause and self.m_iPause + 1 or self.m_iPause - 1
  if self.m_iPause <= 0 then
    self.m_iPause = 0
    bPause = false
  else
    bPause = true
  end
  GameDataManager:GetInstance():SetPause(bPause)
  ActorManager:GetInstance():SetPause(bPause)
  BuffManager:GetInstance():SetPause(bPause)
  EffectManager:GetInstance():SetPause(bPause)
  if GameDataManager:GetInstance():GetGameMap() then
    if bPause then
      GameDataManager:GetInstance():GetGameMap():pause()
    else
      GameDataManager:GetInstance():GetGameMap():resume()
    end
  end
  local vSoldiers = ActorManager:GetInstance():GetSelfVec()
  for i, v in ipairs(vSoldiers) do
    if v:GetType() == td.ActorType.Camp then
      if bPause then
        v:pause()
      else
        v:resume()
      end
    end
  end
  local vEnemies = ActorManager:GetInstance():GetEnemyVec()
  for i, v in ipairs(vEnemies) do
    if v:GetType() == td.ActorType.Camp then
      if bPause then
        v:pause()
      else
        v:resume()
      end
    end
  end
end
function GameSceneBase:IsPause()
  if self.m_iPause <= 0 then
    return false
  else
    return true
  end
end
function GameSceneBase:setTimeScale(scale)
  self.m_timeScale = scale
end
function GameSceneBase:AddCustomEvent(name, func)
  local eventDsp = self:getEventDispatcher()
  local customListener = cc.EventListenerCustom:create(name, func)
  eventDsp:addEventListenerWithFixedPriority(customListener, 1)
  table.insert(self.m_vCustomListeners, customListener)
end
function GameSceneBase:RemoveListeners()
  local eventDsp = self:getEventDispatcher()
  for i, listener in ipairs(self.m_vCustomListeners) do
    eventDsp:removeEventListener(listener)
  end
  self.m_vCustomListeners = {}
end
function GameSceneBase:GetUIRoot()
  return self.m_uiRoot
end
function GameSceneBase:setAutoScale(root, uiPosHorizontal, uiPosVertical)
  self.m_scale = td.GetAutoScale()
  td.SetAutoScale(root, uiPosHorizontal, uiPosVertical, self.m_scale)
end
function GameSceneBase:CreateForgroundMask()
  self.m_forgroundMaskLayer = require("app.layers.MaskLayer").new(0)
  self.m_forgroundMaskLayer:addTo(self, td.ZORDER.Guide)
  local pos = cc.p(self.m_forgroundMaskLayer:getPosition())
  pos.y = pos.y - self.m_forgroundMaskLayer.m_yOffset
  pos.x = pos.x - self.m_forgroundMaskLayer.m_xOffset
  self.m_forgroundMaskLayer:setPosition(pos)
end
function GameSceneBase:RemoveForgroundMask()
  if self.m_forgroundMaskLayer then
    self.m_forgroundMaskLayer:removeFromParent()
    self.m_forgroundMaskLayer = nil
  end
end
function GameSceneBase:SetEnterModule(moId)
  self.m_eEnterModuleId = moId
end
return GameSceneBase
