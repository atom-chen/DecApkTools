local GameDataManager = require("app.GameDataManager")
local TriggerBase = import(".TriggerBase")
local ActorTouchEnableTrigger = class("ActorTouchEnableTrigger", TriggerBase)
function ActorTouchEnableTrigger:ctor(iID, iType, bLoop, conditionType, data)
  ActorTouchEnableTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_touchAble = data.touchAble
end
function ActorTouchEnableTrigger:Active()
  ActorTouchEnableTrigger.super.Active(self)
  GameDataManager:GetInstance():SetActorCanTouch(self.m_touchAble)
end
return ActorTouchEnableTrigger
