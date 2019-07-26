local AreaSkill = import(".AreaSkill")
local SkillInfoManager = require("app.info.SkillInfoManager")
local EffectManager = require("app.effect.EffectManager")
local BuffManager = require("app.buff.BuffManager")
local GameDataManager = require("app.GameDataManager")
local SteelySky = class("SteelySky", AreaSkill)
function SteelySky:ctor(pActor, id, pData)
  SteelySky.super.ctor(self, pActor, id, pData)
end
function SteelySky:Execute(endCallback)
  SteelySky.super.super.Execute(self, endCallback)
  local gameDataMng = GameDataManager:GetInstance()
  self.m_skillPos = self:GetSkillPos()
  local pMap = gameDataMng:GetGameMap()
  local bornPos = self.m_skillPos
  local dir = bornPos.x > self.m_pActor:getPositionX() and td.DirType.Right or td.DirType.Left
  local pEffect = EffectManager:GetInstance():CreateEffect(self.m_atkEffect, self.m_pActor, nil, bornPos)
  pEffect:SetSkill(self)
  pEffect:SetDir(dir)
  pEffect:AddToMap(pMap)
end
return SteelySky
