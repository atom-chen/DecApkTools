local ConditionBase = import(".ConditionBase")
local GuideEndCondition = class("GuideEndCondition", ConditionBase)
function GuideEndCondition:ctor(data)
  GuideEndCondition.super.ctor(self, td.ConditionType.GuideEnd)
  self.m_guideGroup = data.group
end
function GuideEndCondition:CheckSatisfyOnInit()
  local GuideManager = require("app.GuideManager")
  if type(self.m_guideGroup) == "table" then
    for i, var in ipairs(self.m_guideGroup) do
      if GuideManager:GetInstance():IsGuideGroupOver(var) then
        return true
      end
    end
  else
    GuideManager:GetInstance():IsGuideGroupOver(self.m_guideGroup)
  end
  return false
end
function GuideEndCondition:CheckSatisfy(data)
  if type(self.m_guideGroup) == "table" then
    if table.indexof(self.m_guideGroup, data.group) then
      return true
    end
  elseif self.m_guideGroup == data.group then
    return true
  end
  return false
end
return GuideEndCondition
