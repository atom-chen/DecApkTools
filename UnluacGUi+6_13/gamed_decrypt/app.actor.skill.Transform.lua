local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local GameDataManager = require("app.GameDataManager")
local BuffManager = require("app.buff.BuffManager")
local EffectManager = require("app.effect.EffectManager")
local Transform = class("Transform", SkillBase)
function Transform:ctor(pActor, id, pData)
  Transform.super.ctor(self, pActor, id, pData)
  self.m_fStartTime = 0
end
function Transform:Execute(endCallback)
  self.m_fStartTime = 0
  local aniNames = string.split(self.m_pData.skill_name, "#")
  self.m_pActor:PlayAnimation(aniNames[1], false, function()
    self.m_pActor:runAction(cca.seq({
      cca.delay(0.1),
      cca.cb(function()
        self.m_pActor:Transform(function()
          self:ExecuteOver()
          endCallback()
        end)
      end)
    }))
  end, sp.EventType.ANIMATION_COMPLETE)
end
return Transform
