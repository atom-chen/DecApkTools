local GameDataManager = require("app.GameDataManager")
local TriggerBase = import(".TriggerBase")
local EnableMapTrigger = class("EnableMapTrigger", TriggerBase)
function EnableMapTrigger:ctor(iID, iType, bLoop, conditionType, data)
  EnableMapTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_touchAble = data.touchAble
end
function EnableMapTrigger:Active()
  EnableMapTrigger.super.Active(self)
  local map = GameDataManager:GetInstance():GetGameMap()
  if map then
    map:SetIsTouchable(self.m_touchAble)
  end
end
return EnableMapTrigger
