local SkillInfoManager = require("app.info.SkillInfoManager")
local AreaSkill = import(".AreaSkill")
local GameDataManager = require("app.GameDataManager")
local SkillManager = class("SkillManager")
local SkillsNoNeedTarget = {
  3047,
  3107,
  3121
}
function SkillManager:ctor(pActor)
  self.m_pActor = pActor
  self.m_vActiveSkills = {}
  self.m_vPassiveSkills = {}
  local mapType = GameDataManager:GetInstance():GetGameMapInfo().type
  self.m_bIsPVP = mapType == td.MapType.PVP or mapType == td.MapType.PVPGuild or mapType == td.MapType.Rob
end
function SkillManager:OnEnter()
  self:DoPassiveSkill()
end
function SkillManager:OnExit()
  for i, var in ipairs(self.m_vActiveSkills) do
    var:OnExit()
  end
  for i, var in ipairs(self.m_vPassiveSkills) do
    var:OnExit()
  end
end
function SkillManager:Update(dt)
  for i, v in ipairs(self.m_vActiveSkills) do
    v:Update(dt)
  end
  for i, v in ipairs(self.m_vPassiveSkills) do
    v:Update(dt)
  end
end
function SkillManager:Skill(id, endCallback)
  local pSkill = self:GetSkill(id)
  if nil ~= pSkill and pSkill:IsCDOver() then
    local rtn = pSkill:Execute(endCallback)
    if rtn == nil then
      rtn = true
    end
    return rtn
  end
  return false
end
function SkillManager:SelectPriorSkill()
  if self.m_pActor:IsNothingnessState() and self:HasSkillNoTarget() and self:SetCurrSkillNoTarget() then
    return
  end
  if self.m_pActor:IsZombie() then
    local normalSkill = self:GetNormalSkill()
    self.m_pActor:SetCurSkill(normalSkill:GetID(), false)
    return
  end
  for i, v in ipairs(self.m_vActiveSkills) do
    if self:_CheckSkillCanAutoSelect(v) then
      local curSkill = self.m_pActor:GetCurSkill()
      if curSkill and curSkill:IsTriggered() then
        if v:GetPriority() < curSkill:GetPriority() and v:IsTriggered() then
          self.m_pActor:SetCurSkill(v:GetID(), false)
        end
      elseif v:IsTriggered() then
        self.m_pActor:SetCurSkill(v:GetID(), false)
      end
    end
  end
end
function SkillManager:_CheckSkillCanAutoSelect(pSkill)
  if pSkill:GetType() == td.SkillType.Normal or pSkill:GetType() == td.SkillType.Soldier then
    return true
  elseif (pSkill:GetType() == td.SkillType.FixedMagic or pSkill:GetType() == td.SkillType.RandomMagic) and self.m_bIsPVP then
    return true
  end
  return false
end
function SkillManager:GetRandomSkill()
  local iNum = #self.m_vActiveSkills
  if iNum == 0 then
    return 0
  end
  local random = math.random(#self.m_vActiveSkills)
  return self.m_vActiveSkills[random]:GetID()
end
function SkillManager:GetNormalSkill()
  local t = {}
  for i, v in ipairs(self.m_vActiveSkills) do
    if v:GetType() == td.SkillType.Normal then
      table.insert(t, v)
    end
  end
  if #t >= 1 then
    local random = math.random(#t)
    return t[random]
  else
    return nil
  end
end
function SkillManager:GetSkill(id)
  for i, v in ipairs(self.m_vActiveSkills) do
    if v:GetID() == id then
      return v
    end
  end
  return nil
end
function SkillManager:GetPassiveSkill(id)
  for i, v in ipairs(self.m_vPassiveSkills) do
    if v:GetID() == id then
      return v
    end
  end
  return nil
end
function SkillManager:OnKillEnemy(enemyTag)
  for i, v in ipairs(self.m_vPassiveSkills) do
    if iskindof(v, "KillPassive") then
      v:OnWork(enemyTag)
    end
  end
end
function SkillManager:OnGetHurt(enemy)
  for i, v in ipairs(self.m_vPassiveSkills) do
    if iskindof(v, "GetHurtPassive") then
      v:OnWork(enemy)
    end
  end
end
function SkillManager:AddSkill(id, iPriority, pData)
  local pSkillBase = self:CreateSkill(id, pData)
  if nil ~= pSkillBase then
    if pSkillBase:GetType() == td.SkillType.Passive or pSkillBase:GetType() == td.SkillType.BuffPassive then
      table.insert(self.m_vPassiveSkills, pSkillBase)
    else
      if iPriority then
        pSkillBase:SetPriority(iPriority)
        for i, var in ipairs(self.m_vActiveSkills) do
          local p = var:GetPriority()
          if iPriority <= p then
            var:SetPriority(p + 1)
          end
        end
      else
        pSkillBase:SetPriority(#self.m_vActiveSkills + 1)
      end
      table.insert(self.m_vActiveSkills, 1, pSkillBase)
    end
  end
end
function SkillManager:CreateSkill(id, pData)
  pData = pData or SkillInfoManager:GetInstance():GetInfo(id)
  if nil == pData then
    print("Skill id = %d is not Exist", id)
    return
  end
  local pSkillBase
  if pData.type == td.SkillType.Normal then
    pSkillBase = self:CreateNormalSkill(id, pData)
  elseif pData.type == td.SkillType.FixedMagic or pData.type == td.SkillType.RandomMagic then
    pSkillBase = self:CreateHeroSkill(id, pData)
  elseif pData.type == td.SkillType.Soldier then
    pSkillBase = self:CreateSoldierSkill(id, pData)
  elseif pData.type == td.SkillType.BuffPassive or pData.type == td.SkillType.Passive then
    pSkillBase = self:CreatePassiveSkill(id, pData)
  end
  return pSkillBase
end
function SkillManager:CreateNormalSkill(id, pData)
  local SkillClass
  if id == 1001 or id == 1013 or id == 1024 then
    SkillClass = require("app.actor.skill.normal.FastHit")
  elseif id == 1008 or id == 1020 then
    SkillClass = require("app.actor.skill.normal.FireNormalSkill")
  elseif id == 1009 or id == 1021 then
    SkillClass = require("app.actor.skill.normal.IceNormalSkill")
  elseif id == 14 then
    SkillClass = require("app.actor.skill.normal.MummyNormalSkill")
  elseif table.indexof({
    15,
    16,
    27,
    60
  }, id) then
    SkillClass = require("app.actor.skill.normal.GunNormalSkill")
  elseif table.indexof({
    17,
    35,
    36,
    37
  }, id) then
    SkillClass = require("app.actor.skill.normal.SnipeNormalSkill")
  elseif id == 50 then
    SkillClass = require("app.actor.skill.normal.ChainNormal")
  elseif id == 32 then
    SkillClass = require("app.actor.skill.normal.BounceNormal")
  elseif id == 21 then
    SkillClass = require("app.actor.skill.normal.HomeSkill")
  elseif id == 61 then
    SkillClass = require("app.actor.skill.normal.HomeSkill2")
  else
    SkillClass = require("app.actor.skill.normal.NormalSkill")
  end
  return SkillClass.new(self.m_pActor, id, pData)
end
function SkillManager:CreateSoldierSkill(id, pData)
  local SkillClass, pSkillBase
  if id == 1000 or id == 1012 then
    SkillClass = require("app.actor.skill.SuddenStrike")
  elseif id == 1002 or id == 1014 then
    SkillClass = require("app.actor.skill.AncientShield")
  elseif id == 1003 or id == 1015 or id == 3053 then
    SkillClass = require("app.actor.skill.Taunt")
  elseif id == 1004 or id == 1016 or id == 3109 then
    SkillClass = require("app.actor.skill.BarrageShot")
  elseif id == 1005 or id == 1017 then
    SkillClass = require("app.actor.skill.DeadMark")
  elseif id == 1006 or id == 1018 or id == 1026 then
    SkillClass = require("app.actor.skill.Flashbomb")
  elseif id == 1007 then
    SkillClass = require("app.actor.skill.NuclearDetected")
  elseif id == 1010 or id == 1022 or id == 1028 then
    SkillClass = require("app.actor.skill.AngelCure")
  elseif id == 1011 or id == 1023 then
    SkillClass = require("app.actor.skill.AngelSanction")
  elseif id == 3027 or id == 3115 then
    SkillClass = require("app.actor.skill.Charge")
  elseif id == 3036 or id == 3037 then
    SkillClass = require("app.actor.skill.LifeDrawing")
  elseif id == 3039 then
    SkillClass = require("app.actor.skill.BloodFog")
  elseif id == 3043 then
    SkillClass = require("app.actor.skill.DarkInvade")
  elseif id == 3045 then
    SkillClass = require("app.actor.skill.FireworkShot")
  elseif id == 3046 then
    SkillClass = require("app.actor.skill.BlinkStrike")
  elseif id == 3047 then
    SkillClass = require("app.actor.skill.Summon")
  elseif id == 3051 then
    SkillClass = require("app.actor.skill.Charm")
  elseif id == 3102 then
    SkillClass = require("app.actor.skill.BandageTwine")
  elseif id == 3103 then
    SkillClass = require("app.actor.skill.ZombieReborn")
  elseif id == 3105 then
    SkillClass = require("app.actor.skill.BlockLong")
  elseif id == 3106 then
    SkillClass = require("app.actor.skill.HitBackShort")
  elseif id == 3107 then
    SkillClass = require("app.actor.skill.CastBomb")
  elseif id == 3108 then
    SkillClass = require("app.actor.skill.CrossChop")
  elseif id == 3110 then
    SkillClass = require("app.actor.skill.EvilSweep")
  elseif id == 3111 then
    SkillClass = require("app.actor.skill.FuryCharge")
  elseif id == 3112 then
    SkillClass = require("app.actor.skill.ForceSource")
  elseif id == 3113 then
    SkillClass = require("app.actor.skill.HellDoor")
  elseif id == 3117 then
    SkillClass = require("app.actor.skill.PoisonRain")
  elseif id == 3119 then
    SkillClass = require("app.actor.skill.LifeDrawingSuper")
  elseif id == 3121 then
    SkillClass = require("app.actor.skill.Transform")
  elseif id == 1025 then
    SkillClass = require("app.actor.skill.ImproveSelf")
  else
    SkillClass = require("app.actor.skill.SkillBase")
  end
  return SkillClass.new(self.m_pActor, id, pData)
end
function SkillManager:CreatePassiveSkill(id, pData)
  local skillClass
  if pData.type == td.SkillType.Passive then
    if id >= 2018 and id <= 2021 or id == 2062 then
      skillClass = require("app.actor.skill.passive.AlongPassive")
    elseif id == 3038 or id == 3054 then
      skillClass = require("app.actor.skill.passive.DeadPassive")
    elseif id == 3040 or id == 2088 then
      skillClass = require("app.actor.skill.passive.DeadCallPassive")
    elseif id == 3044 then
      skillClass = require("app.actor.skill.passive.CDBuffPassive")
    elseif id == 3052 then
      skillClass = require("app.actor.skill.passive.SneakPassive")
    elseif id == 3114 then
      skillClass = require("app.actor.skill.passive.MummyPassive")
    elseif id == 3120 or id == 2090 then
      skillClass = require("app.actor.skill.passive.KillPassive")
    elseif id == 2016 or id == 2022 or id == 2061 then
      skillClass = require("app.actor.skill.passive.GetHurtPassive")
    else
      skillClass = require("app.actor.skill.passive.HaloPassive")
    end
  else
    skillClass = require("app.actor.skill.passive.BuffPassive")
  end
  return skillClass.new(self.m_pActor, id, pData)
end
function SkillManager:CreateHeroSkill(id, pData)
  local SkillClass
  if table.indexof({
    2055,
    2056,
    2076,
    4004,
    4005,
    4019,
    4021,
    4023
  }, id) then
    SkillClass = require("app.actor.skill.OriginalFury")
  elseif table.indexof({
    2050,
    2054,
    2058,
    2064,
    2067,
    2068,
    2069,
    4024
  }, id) then
    SkillClass = require("app.actor.skill.ImproveSelf")
  elseif id == 2077 then
    SkillClass = require("app.actor.skill.SummonShadow")
  elseif id == 2078 then
    SkillClass = require("app.actor.skill.SummonTower")
  elseif id == 2079 or id == 2091 then
    SkillClass = require("app.actor.skill.SummonSprite")
  elseif id == 2089 then
    SkillClass = require("app.actor.skill.Charm")
  elseif id == 4012 or id == 4013 then
    SkillClass = require("app.actor.skill.ExtremeCold")
  elseif id == 4014 or id == 4015 then
    SkillClass = require("app.actor.skill.JusticeTrial")
  elseif id == 4010 or id == 4011 then
    SkillClass = require("app.actor.skill.SteelySky")
  elseif table.indexof({
    2067,
    2070,
    4016,
    4018
  }, id) then
    SkillClass = require("app.actor.skill.ImproveMate")
  elseif id == 4022 then
    SkillClass = require("app.actor.skill.HellDoor")
  elseif id == 4025 then
    SkillClass = require("app.actor.skill.HitBackShort")
  elseif id == 4026 then
    SkillClass = require("app.actor.skill.DarkInvade")
  else
    SkillClass = AreaSkill
  end
  return SkillClass.new(self.m_pActor, id, pData)
end
function SkillManager:RemoveSkill(id)
  for i, skill in ipairs(self.m_vActiveSkills) do
    if skill:GetID() == id then
      table.remove(self.m_vActiveSkills, i)
      return
    end
  end
  for i, skill in ipairs(self.m_vPassiveSkills) do
    if skill:GetID() == id then
      skill:Inactive()
      table.remove(self.m_vPassiveSkills, i)
      return
    end
  end
end
function SkillManager:EmptySkill()
  self.m_vActiveSkills = {}
  for i, skill in ipairs(self.m_vPassiveSkills) do
    skill:Inactive()
  end
  self.m_vPassiveSkills = {}
end
function SkillManager:DoPassiveSkill()
  for i, v in ipairs(self.m_vPassiveSkills) do
    self.m_pActor:performWithDelay(function()
      v:Active()
    end, (i - 1) * 2)
  end
end
function SkillManager:StopPassiveSkill()
  for i, v in ipairs(self.m_vPassiveSkills) do
    v:Inactive()
  end
end
function SkillManager:HasSkillNoTarget()
  if self.m_pActor:IsZombie() then
    return false
  end
  for i, v in ipairs(self.m_vActiveSkills) do
    for i2, v2 in pairs(SkillsNoNeedTarget) do
      if v:GetID() == v2 and v:IsTriggered() then
        return true
      end
    end
  end
  return false
end
function SkillManager:SetCurrSkillNoTarget()
  if not self:HasSkillNoTarget() then
    return false
  end
  for i, v in ipairs(self.m_vActiveSkills) do
    for i2, v2 in pairs(SkillsNoNeedTarget) do
      if v:GetID() == v2 and v:IsTriggered() then
        self.m_pActor:SetCurSkill(v:GetID(), false)
        return true
      end
    end
  end
  return false
end
function SkillManager:IsSkillNoTarget(skill)
  for i2, v2 in pairs(SkillsNoNeedTarget) do
    if skill:GetID() == v2 then
      return true
    end
  end
  return false
end
return SkillManager
