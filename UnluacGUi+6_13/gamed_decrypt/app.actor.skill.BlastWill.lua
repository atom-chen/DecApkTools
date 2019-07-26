local SkillBase = import(".SkillBase")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BlastWill = class("BlastWill", SkillBase)
function BlastWill:ctor(pActor, id, pData)
  BlastWill.super.ctor(self, pActor, id, pData)
end
function BlastWill:Execute(endCallback)
  BlastWill.super.Execute(self, endCallback)
  local dir = self.m_pActor:GetDirType()
  local startPos = cc.pAdd(cc.p(self.m_pActor:getPosition()), cc.p(dir * 30, 0))
  local pData = SkillInfoManager:GetInstance():GetInfo(self.m_Id)
  local pEffect = EffectManager:GetInstance():CreateEffect(pData.atk_effect, self.m_pActor, targetActor, startPos)
  for j, v in ipairs(pEffect.m_vAttributes) do
    if v:GetType() == td.AttributeType.RangeAttack then
      v.m_iDamageRatio = self.m_iSkillRatio
      v.m_iWidth, v.m_iHeight = self:GetDamageRange()
      break
    end
  end
  local pMap = GameDataManager:GetInstance():GetGameMap()
  pMap:addChild(pEffect, pMap:GetPiexlSize().height - startPos.y)
end
return BlastWill
