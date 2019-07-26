local break_config = {
  [1] = {
    itemId = 20007,
    num = {min = 8, max = 12}
  },
  [2] = {
    itemId = 20007,
    num = {min = 18, max = 24}
  },
  [20108] = {
    itemId = 20107,
    num = {min = 3, max = 8}
  },
  [20109] = {
    itemId = 20107,
    num = {min = 10, max = 20}
  },
  [20110] = {
    itemId = 20107,
    num = {min = 30, max = 80}
  }
}
function GetBreakConfig(id)
  local SkillInfoMng = require("app.info.SkillInfoManager"):GetInstance()
  local itemSkillInfo = SkillInfoMng:GetItemSkillInfo(id)
  if itemSkillInfo then
    if itemSkillInfo.type == 0 then
      id = 2
    else
      id = 1
    end
  end
  return clone(break_config[id])
end
