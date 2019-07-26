local GameControl = require("app.GameControl")
local BuffInfoManager = require("app.info.BuffInfoManager")
local BuffManager = class("BuffManager", GameControl)
BuffManager.instance = nil
function BuffManager:ctor(eType)
  BuffManager.super.ctor(self, eType)
  self:Init()
end
function BuffManager:GetInstance()
  if BuffManager.instance == nil then
    BuffManager.instance = BuffManager.new(td.GameControlType.EnterMap)
  end
  return BuffManager.instance
end
function BuffManager:Init()
  self.m_Buffs = {}
  self.m_bPause = false
end
function BuffManager:ClearValue()
  for key, var in pairs(self.m_Buffs) do
    if var then
      for i, v in ipairs(var) do
        self:RemoveBuff(v)
      end
    end
  end
  self:Init()
end
function BuffManager:AddBuff(pActor, id, callBackFunc, iActorObjectTag, bIgnoreActorType)
  local tag = pActor:getTag()
  local info = BuffInfoManager:GetInstance():GetInfo(id)
  if not info or pActor:IsDead() then
    return nil
  end
  if not bIgnoreActorType and not self:_CheckCanAddToActor(id, pActor) then
    return nil
  end
  if not self:CheckCanAdd(id, info.type, pActor) then
    return nil
  end
  local buff
  if td.BuffType.Trapped == info.type then
    local TrappedBuff = require("app.buff.TrappedBuff")
    buff = TrappedBuff.new(pActor, info, callBackFunc)
  elseif table.indexof({
    td.BuffType.Taunted,
    td.BuffType.MeatShield
  }, info.type) then
    local ObjectiveBuff = require("app.buff.ObjectiveBuff")
    buff = ObjectiveBuff.new(pActor, info, callBackFunc, iActorObjectTag)
  elseif td.BuffType.Zombie == info.type then
    local ZombieBuff = require("app.buff.ZombieBuff")
    buff = ZombieBuff.new(pActor, info, callBackFunc)
  elseif td.BuffType.Hurtless == info.type then
    local HurtlessBuff = require("app.buff.HurtlessBuff")
    buff = HurtlessBuff.new(pActor, info, callBackFunc)
  elseif td.BuffType.Shield == info.type or td.BuffType.Shield_P == info.type then
    local ShieldBuff = require("app.buff.ShieldBuff")
    buff = ShieldBuff.new(pActor, info, callBackFunc)
  elseif table.indexof({
    td.BuffType.HpVary_P,
    td.BuffType.HpVary_V,
    td.BuffType.HpVaryAC_P,
    td.BuffType.HpVaryAC_V
  }, info.type) then
    local BloodBuff = require("app.buff.BloodBuff")
    buff = BloodBuff.new(pActor, info, callBackFunc)
  elseif td.BuffType.Hex == info.type then
    local HexBuff = require("app.buff.HexBuff")
    buff = HexBuff.new(pActor, info, callBackFunc)
  elseif td.BuffType.Peace == info.type then
    local PeaceBuff = require("app.buff.PeaceBuff")
    buff = PeaceBuff.new(pActor, info, callBackFunc)
  elseif td.BuffType.Hiding == info.type then
    local HidingBuff = require("app.buff.HidingBuff")
    buff = HidingBuff.new(pActor, info, callBackFunc)
  elseif td.BuffType.Charmed == info.type then
    local CharmedBuff = require("app.buff.CharmedBuff")
    buff = CharmedBuff.new(pActor, info, callBackFunc)
  elseif td.BuffType.Taunted == info.type then
    local TauntedBuff = require("app.buff.TauntedBuff")
    buff = TauntedBuff.new(pActor, info, callBackFunc, iActorObjectTag)
  elseif table.indexof({
    td.BuffType.HurtGetBuff,
    td.BuffType.AttackCauseBuff,
    td.BuffType.HurtCauseBuff
  }, info.type) then
    local LinkageBuff = require("app.buff.LinkageBuff")
    buff = LinkageBuff.new(pActor, info, callBackFunc)
  elseif td.BuffType.SkillCDVary == info.type then
    local SkillCDBuff = require("app.buff.SkillCDBuff")
    buff = SkillCDBuff.new(pActor, info, callBackFunc)
  elseif td.BuffType.SkillRatioVary == info.type then
    local SkillRatioBuff = require("app.buff.SkillRatioBuff")
    buff = SkillRatioBuff.new(pActor, info, callBackFunc)
  elseif td.BuffType.AttackCauseSkill == info.type then
    local SkillBuff = require("app.buff.SkillBuff")
    buff = SkillBuff.new(pActor, info, callBackFunc)
  elseif table.indexof({
    td.BuffType.ReflectCaster,
    td.BuffType.ReflectArcher,
    td.BuffType.ReflectSaber,
    td.BuffType.SaberHurtVary,
    td.BuffType.ArcherHurtVary,
    td.BuffType.CasterHurtVary,
    td.BuffType.Rebound
  }, info.type) then
    local ReflectBuff = require("app.buff.ReflectBuff")
    buff = ReflectBuff.new(pActor, info, callBackFunc)
  elseif info.type == td.BuffType.HpMaxAdd or info.type == td.BuffType.HpMaxReduce then
    local MaxHPVaryBuff = require("app.buff.MaxHPVaryBuff")
    buff = MaxHPVaryBuff.new(pActor, info, callBackFunc)
  elseif info.type == td.BuffType.Halo then
    local HaloBuff = require("app.buff.HaloBuff")
    buff = HaloBuff.new(pActor, info, callBackFunc)
  else
    local BuffBase = require("app.buff.BuffBase")
    buff = BuffBase.new(pActor, info, callBackFunc)
  end
  if buff then
    if not self.m_Buffs[tag] then
      self.m_Buffs[tag] = {}
    end
    if not self.m_Buffs[tag][info.type] then
      self.m_Buffs[tag][info.type] = {}
    end
    buff:OnEnter()
    table.insert(self.m_Buffs[tag][info.type], buff)
    buff:DidEnter()
  end
  return buff
end
function BuffManager:RemoveActorBuff(pActor, id, callBackFunc, iActorObjectTag)
  assert(pActor, "pActor should not null")
  local info = BuffInfoManager:GetInstance():GetInfo(id)
  if not info or pActor:IsDead() then
    return nil
  end
  local tag = pActor:getTag()
  if self.m_Buffs[tag] and self.m_Buffs[tag][info.type] then
    for k, value in ipairs(self.m_Buffs[tag][info.type]) do
      if value:GetID() == id then
        value:SetRemove()
      end
    end
  end
end
function BuffManager:CheckCanAdd(id, buffType, pActor)
  local typeInfo = BuffInfoManager:GetInstance():GetTypeInfo(buffType)
  if not typeInfo then
    return false
  end
  local tag = pActor:getTag()
  if self.m_Buffs[tag] then
    for i, v in ipairs(typeInfo.reject_type) do
      if self.m_Buffs[tag][v] and #self.m_Buffs[tag][v] >= 1 then
        for j, buff in ipairs(self.m_Buffs[tag][v]) do
          if not buff:IsRemove() then
            return false
          end
        end
      end
    end
    for i, v in ipairs(typeInfo.remove_type) do
      if not self.m_Buffs[tag][v] then
        break
      end
      for i, buff in ipairs(self.m_Buffs[tag][v]) do
        buff:SetRemove()
      end
    end
    if self.m_Buffs[tag][buffType] then
      for i, buff in ipairs(self.m_Buffs[tag][buffType]) do
        if buff:GetID() == id then
          buff:SetRemove()
        end
      end
    end
  end
  return true
end
function BuffManager:_CheckCanAddToActor(id, pActor)
  if pActor:GetType() == td.ActorType.FangYuTa or pActor:GetType() == td.ActorType.Home then
    return false
  end
  if pActor:GetType() == td.ActorType.Monster and pActor:GetMonsterType() == td.MonsterType.BOSS and self:_CheckIsDebuff(id) then
    return false
  end
  return true
end
function BuffManager:_CheckIsDebuff(id)
  local buffInfo = BuffInfoManager:GetInstance():GetInfo(id)
  local buffTypeInfo = BuffInfoManager:GetInstance():GetTypeInfo(buffInfo.type)
  if buffTypeInfo.is_good == 0 then
    return true
  elseif buffTypeInfo.is_good == 2 then
    if table.indexof({
      27,
      31,
      32,
      33
    }, buffInfo.type) then
      if 0 < buffInfo.value[1] then
        return true
      end
    elseif 0 > buffInfo.value[1] then
      return true
    end
  end
  return false
end
function BuffManager:RemoveBuff(buff)
  local tag = buff:GetTag()
  local buffType = buff:GetType()
  local typeBuffs
  if not self.m_Buffs[tag] then
    return
  else
    typeBuffs = self.m_Buffs[tag][buffType]
    if not typeBuffs then
      return
    end
  end
  local count = #typeBuffs
  for i = count, 1, -1 do
    local v = typeBuffs[i]
    if v == buff then
      table.remove(typeBuffs, i)
      v:OnExit()
      break
    end
  end
  if #typeBuffs == 0 then
    self.m_Buffs[tag][buffType] = nil
    if table.nums(self.m_Buffs[tag]) == 0 then
      self.m_Buffs[tag] = nil
    end
  end
end
function BuffManager:RemoveBuffByTag(tag)
  if not self.m_Buffs[tag] then
    return
  end
  for type, buffs in pairs(self.m_Buffs[tag]) do
    for i, buff in ipairs(buffs) do
      buff:SetRemove()
    end
  end
end
function BuffManager:GetBuffByTag(tag)
  return self.m_Buffs[tag] or {}
end
function BuffManager:Update(dt)
  if self.m_bPause then
    return
  end
  for tag, buffs in pairs(self.m_Buffs) do
    for type, typebuffs in pairs(buffs) do
      local count = #typebuffs
      for i = count, 1, -1 do
        local buff = typebuffs[i]
        if buff:IsRemove() then
          self:RemoveBuff(buff)
        else
          buff:Update(dt)
        end
      end
    end
  end
end
function BuffManager:SetPause(bPause)
  self.m_bPause = bPause
end
function BuffManager:IsPause()
  return self.m_bPause
end
return BuffManager
