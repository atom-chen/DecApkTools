local TriggerBase = import(".TriggerBase")
local MapBlockTrigger = class("MapBlockTrigger", TriggerBase)
function MapBlockTrigger:ctor(iID, iType, bLoop, conditionType, data)
  MapBlockTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_iBlockId = data.blockId
end
function MapBlockTrigger:Active()
  MapBlockTrigger.super.Active(self)
  local gameDataMng = require("app.GameDataManager"):GetInstance()
  gameDataMng:AddAllPassBlock(self.m_iBlockId)
end
return MapBlockTrigger
