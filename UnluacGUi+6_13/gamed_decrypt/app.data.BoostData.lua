local BoostData = class("BoostData")
function BoostData:ctor(guildSkills)
  self.m_boostData = {}
  self:InitData(guildSkills)
end
function BoostData:InitData(guildSkills)
  local diMng = require("app.info.GuildInfoManager"):GetInstance()
  for id, var in pairs(guildSkills) do
    self:UpdateData(var)
  end
end
function BoostData:UpdateData(guildSkill)
  local diMng = require("app.info.GuildInfoManager"):GetInstance()
  local info = diMng:GetSkillInfo(guildSkill.id)
  local addValue = guildSkill.level * info.growth_rate
  if info.type == td.BoostType.Soldier or info.type == td.BoostType.Hero then
    local id, propertyType = info.type_param[1], info.type_param[2]
    local data = self.m_boostData[info.type] or {}
    data[id] = data[id] or {}
    data[id][propertyType] = addValue
    self.m_boostData[info.type] = data
  elseif info.type == td.BoostType.Skill then
    local skillId = info.type_param[1]
    self.m_boostData[info.type] = self.m_boostData[info.type] or {}
    self.m_boostData[info.type][skillId] = addValue
  else
    self.m_boostData[info.type] = addValue
  end
end
function BoostData:GetValue(type, param1, param2)
  local data = self.m_boostData[type]
  if not data then
    return 0
  end
  if type == td.BoostType.Soldier or type == td.BoostType.Hero then
    if data[param1] then
      data = data[param1][param2]
    else
      data = 0
    end
  elseif type == td.BoostType.Skill then
    data = data[param1]
  end
  return data or 0
end
return BoostData
