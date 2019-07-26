local AreaSkill = import(".AreaSkill")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local OriginalFury = class("OriginalFury", AreaSkill)
function OriginalFury:ctor(pActor, id, pData)
  OriginalFury.super.ctor(self, pActor, id, pData)
end
function OriginalFury:Update(dt)
  OriginalFury.super.Update(self, dt)
end
function OriginalFury:Execute(endCallback)
  OriginalFury.super.super.Execute(self, endCallback)
  local gameDataMng = GameDataManager:GetInstance()
  self.m_skillPos = self:GetSkillPos()
  local isFlip = false
  if self.m_skillPos.x < self.m_pActor:getPositionX() then
    isFlip = true
  end
  local pMap = gameDataMng:GetGameMap()
  for i = 1, 15 do
    local rangeWidth, rangeHeight = self.m_iDamageRangeW, self.m_iDamageRangeH
    local randX = i == 1 and 0 or math.random(rangeWidth) - rangeWidth / 2
    local randY = i == 1 and 0 or math.random(rangeHeight) - rangeHeight / 2
    local pos = cc.p(self.m_skillPos.x + randX, self.m_skillPos.y + randY)
    local delayTime = i * 0.1
    local pEffect = EffectManager:GetInstance():CreateEffect(self.m_pData.atk_effect, self.m_pActor, nil, pos)
    pEffect:SetSkill(self)
    for j, v in ipairs(pEffect.m_vAttributes) do
      if isFlip and v:GetType() == td.AttributeType.Place then
        v.m_pos.x = -v.m_pos.x
      elseif v:GetType() == td.AttributeType.Delay then
        v.m_fNextAttributeTime = delayTime
      end
    end
    pEffect:AddToMap(pMap)
  end
end
return OriginalFury
