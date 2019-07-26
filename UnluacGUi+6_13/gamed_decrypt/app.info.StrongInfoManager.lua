local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local ActorInfoManager = require("app.info.ActorInfoManager")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
local StrongInfoManager = class("StrongInfoManager", GameControl)
StrongInfoManager.instance = nil
function StrongInfoManager:ctor(eType)
  StrongInfoManager.super.ctor(self, eType)
  self:Init()
  self:addListeners()
end
function StrongInfoManager:GetInstance()
  if StrongInfoManager.instance == nil then
    StrongInfoManager.instance = StrongInfoManager.new(td.GameControlType.ExitGame)
  end
  return StrongInfoManager.instance
end
function StrongInfoManager:Init()
  self.m_soldierInfos = {}
  self.m_weaponInfos = {}
  self.m_gemInfos = {}
  self:SaveInfo()
end
function StrongInfoManager:ClearValue()
end
function StrongInfoManager:SaveInfo()
  local vData = CSVLoader.loadCSV("Config/role.csv")
  for i, v in ipairs(vData) do
    local tmp = string.split(v.star_cost, ";")
    v.star_cost = {}
    for j, v1 in ipairs(tmp) do
      local p = {}
      local tmp1 = string.split(v1, "|")
      for k, v2 in ipairs(tmp1) do
        local tmp2 = string.split(v2, "#")
        table.insert(p, {
          itemId = tonumber(tmp2[1]),
          num = tonumber(tmp2[2])
        })
      end
      table.insert(v.star_cost, p)
    end
    if v.unlock == "" then
      v.unlock = nil
    else
      tmp = string.split(v.unlock, "|")
      local condition = string.split(tmp[1], "#")
      local items = {}
      for i = 2, #tmp do
        local itemDetail = string.split(tmp[i], "#")
        local item = {}
        item.itemId = tonumber(itemDetail[1])
        item.num = tonumber(itemDetail[2])
        table.insert(items, item)
      end
      v.unlock = {
        soldierId = tonumber(condition[1]),
        level = tonumber(condition[2]),
        item = items
      }
    end
    self.m_soldierInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/weapon.csv")
  for i, v in ipairs(vData) do
    local tmp = string.split(v.property, ";")
    v.property = {}
    for j, v1 in ipairs(tmp) do
      local p = {}
      local tmp1 = string.split(v1, "|")
      for k, v2 in ipairs(tmp1) do
        local tmp2 = string.split(v2, "#")
        p[tonumber(tmp2[1])] = tonumber(tmp2[2])
      end
      table.insert(v.property, p)
    end
    tmp = string.split(v.up_rate, ";")
    v.up_rate = {}
    for j, v1 in ipairs(tmp) do
      local p = {}
      local tmp1 = string.split(v1, "|")
      for k, v2 in ipairs(tmp1) do
        local tmp2 = string.split(v2, "#")
        p[tonumber(tmp2[1])] = tonumber(tmp2[2])
      end
      table.insert(v.up_rate, p)
    end
    tmp = string.split(v.star_cost, ";")
    v.star_cost = {}
    for j, v1 in ipairs(tmp) do
      local p = {}
      local tmp1 = string.split(v1, "|")
      for k, v2 in ipairs(tmp1) do
        local tmp2 = string.split(v2, "#")
        table.insert(p, {
          itemId = tonumber(tmp2[1]),
          num = tonumber(tmp2[2])
        })
      end
      table.insert(v.star_cost, p)
    end
    v.name = g_LM:getBy(v.name) or v.name
    v.desc = g_LM:getBy(v.desc) or v.desc
    self.m_weaponInfos[v.id] = v
  end
  self:SaveGemInfo()
end
function StrongInfoManager:SaveGemInfo()
  local vData = CSVLoader.loadCSV("Config/gem.csv")
  for i, v in ipairs(vData) do
    local tmp1 = string.split(v.property, "|")
    v.property = {}
    for k, v2 in ipairs(tmp1) do
      local tmp2 = string.split(v2, "#")
      v.property[tonumber(tmp2[1])] = tonumber(tmp2[2])
    end
    local tmp = string.split(v.use_type, "#")
    v.use_type = {}
    for j, var in ipairs(tmp) do
      table.insert(v.use_type, tonumber(var))
    end
    v.name = g_LM:getBy(v.name) or v.name
    v.desc = g_LM:getBy(v.desc) or v.desc
    self.m_gemInfos[v.id] = v
  end
end
function StrongInfoManager:GetSoldierStrongInfo(id)
  return self.m_soldierInfos[id]
end
function StrongInfoManager:GetWeaponInfo(weaponId)
  if weaponId then
    return clone(self.m_weaponInfos[weaponId])
  end
  return self.m_weaponInfos
end
function StrongInfoManager:GetGemInfo(gemId)
  if gemId then
    return clone(self.m_gemInfos[gemId])
  end
  return self.m_gemInfos
end
function StrongInfoManager:addListeners()
end
function StrongInfoManager:removeListeners()
end
function StrongInfoManager:CalculationTotalPower()
  local udMng = UserDataManager:GetInstance()
  local unitMng = require("app.UnitDataManager"):GetInstance()
  local userDetail = udMng:GetUserDetail()
  local power = userDetail.camp * 100
  power = power + (userDetail.arena_level + userDetail.mission_level) * 30
  power = power + userDetail.honor * 20
  local herosData = udMng:GetHeroData()
  for id, heroData in pairs(herosData) do
    power = power + self:CalculateHeroPower(heroData)
  end
  local vAllSoldierData = unitMng:GetSoldierData()
  power = power + table.nums(vAllSoldierData) * 50
  for id, soldierData in pairs(vAllSoldierData) do
    power = power + soldierData.level * 10
    power = power + soldierData.skill_level * 10
    power = power + (soldierData.star - 1) * 50
  end
  local guildSkillInfos = require("app.info.GuildInfoManager"):GetInstance():GetSkillInfo()
  local totalGuildSkillLevel = 0
  for skillId, var in pairs(guildSkillInfos) do
    totalGuildSkillLevel = totalGuildSkillLevel + udMng:GetGuildSkillLevel(skillId)
  end
  power = power + totalGuildSkillLevel * 20
  return math.ceil(power)
end
function StrongInfoManager:MakeHeroData(data, boostData)
  local heroData = data
  heroData.gems = {
    data.gemstone1,
    data.gemstone2,
    data.gemstone3,
    data.gemstone4
  }
  local heroInfo = ActorInfoManager:GetInstance():GetHeroInfo(heroData.hid)
  heroData.quality = heroInfo.quality
  heroData.star = heroData.star or 1
  for propType, prop in pairs(heroInfo.property) do
    local proValue, ratio = prop.value, prop.ratio
    proValue = td.CalHeroProperty(propType, heroData.level, proValue, ratio)
    proValue = proValue + boostData:GetValue(td.BoostType.Hero, heroInfo.career, propType)
    prop.value = proValue
  end
  heroData.heroInfo = heroInfo
  return heroData
end
function StrongInfoManager:GetHeroDataByWeaponId(weaponId)
  local herosData = UserDataManager:GetInstance():GetHeroData()
  for k, value in pairs(herosData) do
    if value.attackSite == weaponId then
      return value
    elseif value.defSite == weaponId then
      return value
    end
  end
  return nil
end
function StrongInfoManager:GetGuideHeros()
  local data = {
    hid = 1000,
    level = 100,
    attackSite = 0,
    defSite = 0
  }
  local boostData = UserDataManager:GetInstance():GetBoostData()
  local heroData = self:MakeHeroData(data, boostData)
  table.insert(heroData.heroInfo.skill, 4019)
  return {heroData}
end
function StrongInfoManager:GetBattleHeros()
  local herosData = UserDataManager:GetInstance():GetHeroData()
  local heros = {}
  for k, value in pairs(herosData) do
    if value.battle ~= 0 then
      heros[value.battle] = value
    end
  end
  return heros
end
function StrongInfoManager:GetHeroFinalInfo(heroData, weaponsData, skillLib, gemsData)
  weaponsData = weaponsData or UserDataManager:GetInstance():GetWeaponData()
  gemsData = gemsData or UserDataManager:GetInstance():GetGemData()
  skillLib = skillLib or UserDataManager:GetInstance():GetSkillLib()
  local heroInfo = self:_CalculationJiacheng(heroData, weaponsData, gemsData)
  heroInfo.skillInfo = {}
  if heroData.activeSkill then
    for i, skillUId in ipairs(heroData.activeSkill) do
      if td.IsHeroSkillUnlock(heroData.level, true, i) then
        if skillLib[skillUId] then
          local skillId = skillLib[skillUId].skill_id
          table.insert(heroInfo.skill, 1, skillId)
          heroInfo.skillInfo[skillId] = skillLib[skillUId].skillInfo
        elseif skillUId ~= 0 then
          table.insert(heroInfo.skill, 1, skillUId)
        end
      end
    end
  end
  if heroData.passiveSkill then
    for i, skillUId in ipairs(heroData.passiveSkill) do
      if td.IsHeroSkillUnlock(heroData.level, false, i) then
        if skillLib[skillUId] then
          local skillId = skillLib[skillUId].skill_id
          table.insert(heroInfo.skill, skillId)
          heroInfo.skillInfo[skillId] = skillLib[skillUId].skillInfo
        elseif skillUId ~= 0 then
          table.insert(heroInfo.skill, skillUId)
        end
      end
    end
  end
  return heroInfo
end
function StrongInfoManager:_CalculationJiacheng(heroData, weaponsData, gemsData)
  local heroInfo = clone(heroData.heroInfo)
  local vWeaponId = {
    heroData.attackSite,
    heroData.defSite
  }
  for i, weaponId in ipairs(vWeaponId) do
    if weaponId and weaponId ~= 0 then
      local weaponData = weaponsData[weaponId]
      if weaponData then
        for propType, prop in pairs(weaponData.property) do
          heroInfo.property[propType].value = heroInfo.property[propType].value + prop
        end
        local skillInfo = require("app.info.SkillInfoManager"):GetInstance():GetInfo(weaponData.weaponInfo.skill)
        if skillInfo then
          table.insert(heroInfo.skill, 1, weaponData.weaponInfo.skill)
        end
      end
    end
  end
  for i, gemUid in ipairs(heroData.gems) do
    local gemData = gemsData[gemUid]
    if gemData then
      local gemInfo = self:GetGemInfo(gemData.gemstoneId)
      for propType, prop in pairs(gemInfo.property) do
        heroInfo.property[propType].value = heroInfo.property[propType].value + prop
      end
    end
  end
  return heroInfo
end
function StrongInfoManager:CalculateHeroPower(heroData)
  local udMng = UserDataManager:GetInstance()
  local finalHeroInfo = self:GetHeroFinalInfo(heroData)
  local power = finalHeroInfo.property[td.Property.HP].value * 0.5
  power = power + finalHeroInfo.property[td.Property.Atk].value * 5
  power = power + finalHeroInfo.property[td.Property.Def].value * 10
  power = power + finalHeroInfo.property[td.Property.Speed].value * 10
  power = power + finalHeroInfo.property[td.Property.Crit].value * 16
  power = power + finalHeroInfo.property[td.Property.Dodge].value * 16
  power = power + finalHeroInfo.property[td.Property.SuckHp].value * 16
  power = power + finalHeroInfo.property[td.Property.Reflect].value * 16
  local skills = {
    heroData.activeSkill,
    heroData.passiveSkill
  }
  local skillLib = udMng:GetSkillLib()
  for i, var in ipairs(skills) do
    for j, skillLibId in ipairs(var) do
      if skillLib[skillLibId] then
        power = math.floor(power + skillLib[skillLibId].star * 150)
      end
    end
  end
  return power
end
function StrongInfoManager:SendBattleHeroRequest(inData)
  local data = {}
  data.heroIds = inData
  data.type = 1
  local Msg = {}
  Msg.msgType = td.RequestID.BattleHero_req
  Msg.sendData = data
  TDHttpRequest:getInstance():Send(Msg, true)
end
function StrongInfoManager:IsEnableHeroStrong(id)
  local userDataMng = UserDataManager:GetInstance()
  local heroData = userDataMng:GetHeroData(id)
  local heroInfo = heroData.heroInfo
  local errorCode = td.ErrorCode.SUCCESS
  if heroData.level >= td.MaxLevel then
    errorCode = td.ErrorCode.LEVEL_MAX
  elseif userDataMng:GetBaseCampLevel() <= heroData.level then
    errorCode = td.ErrorCode.BASE_LEVEL_LOW
  else
    if userDataMng:GetExp() < td.CalHeroExp(heroData.level) then
      errorCode = td.ErrorCode.EXP_NOT_ENOUGH
    else
    end
  end
  if td.ErrorCode.SUCCESS == errorCode then
    return true, errorCode
  end
  return false, errorCode
end
function StrongInfoManager:CalculateCampPower(campData)
  local power = (campData.attack + campData.hp + campData.def + campData.speed) * 8
  power = power + campData.crit * 3
  power = power + (campData.skill1 % 100 - 1) * 5 + (campData.skill2 % 100 - 1) * 5
  return power
end
function StrongInfoManager:MakeSoldierData(data, boostData)
  local soldierData = data
  local info = ActorInfoManager:GetInstance():GetSoldierInfo(data.role_id)
  soldierData.quality = self.m_soldierInfos[data.role_id].quality
  for i = 1, soldierData.star - 1 do
    info.property[td.Property.Dodge].value = info.property[td.Property.Dodge].value + 5
    info.property[td.Property.Crit].value = info.property[td.Property.Crit].value + 5
  end
  for propType, prop in pairs(info.property) do
    local proValue, ratio = prop.value, prop.ratio
    for j = 1, soldierData.star do
      local maxLevel = j < soldierData.star and j * 5 or soldierData.level
      for k = 1, maxLevel - 1 do
        proValue = proValue + ratio
      end
    end
    proValue = proValue + boostData:GetValue(td.BoostType.Soldier, math.floor(data.role_id / 100), propType)
    prop.value = proValue
  end
  local reputation = UserDataManager:GetInstance():GetUserDetail().reputation
  local honorInfo = require("app.info.CommanderInfoManager"):GetInstance():GetHonorInfoByRepu(reputation)
  local atkValue = info.property[td.Property.Atk].value
  info.property[td.Property.Atk].value = atkValue + honorInfo.atk_increase
  local skillInfoMng = require("app.info.SkillInfoManager"):GetInstance()
  info.skillInfo = {}
  for i, var in ipairs(info.skill) do
    local soldierSkillInfo = skillInfoMng:GetSoldierSkillInfo(var)
    if soldierSkillInfo then
      local finalSkillInfo = skillInfoMng:GetFinalSkillInfo(var, soldierData.skill_level, td.ActorType.Soldier)
      info.skillInfo[var] = finalSkillInfo
    end
  end
  soldierData.soldierInfo = info
  return soldierData
end
function StrongInfoManager:UpdateSoldierData(id, totalExp)
  local unitMng = require("app.UnitDataManager"):GetInstance()
  local soldierData = unitMng:GetSoldierData(id)
  if soldierData.level == soldierData.star * 10 then
    soldierData.star = soldierData.star + 1
  elseif totalExp and totalExp > 0 then
    totalExp = totalExp + soldierData.exp
    local addLevel = 0
    local upExp = td.CalSoldierExp(soldierData.star, soldierData.level, soldierData.quality)
    while totalExp >= upExp do
      addLevel = addLevel + 1
      if soldierData.level + addLevel >= soldierData.star * 10 then
        totalExp = 0
        break
      else
        totalExp = totalExp - upExp
        upExp = td.CalSoldierExp(soldierData.star, soldierData.level + addLevel, soldierData.quality)
      end
    end
    soldierData.level = soldierData.level + addLevel
    soldierData.exp = totalExp
  end
  unitMng:UpdateSoldierData(soldierData)
end
function StrongInfoManager:GetGuideSoldiers()
  local soldiers = {}
  local boostData = UserDataManager:GetInstance():GetBoostData()
  for i = 1, 6 do
    for j = 1, 6 do
      local soldierId = i * 100 + j
      local strongInfo = self.m_soldierInfos[soldierId]
      local data = {
        role_id = soldierId,
        star = strongInfo.quality,
        level = strongInfo.quality * 5
      }
      local soldierData = self:MakeSoldierData(data, boostData)
      soldiers[soldierId] = soldierData
    end
  end
  return soldiers
end
function StrongInfoManager:GetWeaponDataByWeaponId(weaponId)
  local weaponsData = UserDataManager:GetInstance():GetWeaponData()
  local targetIndex, val = self:FindWeaponData(weaponsData, weaponId)
  return val
end
function StrongInfoManager:MakeWeaponData(data)
  local weaponData = data
  local weaponInfo = self:GetWeaponInfo(weaponData.weaponId)
  if not weaponInfo then
    td.alertDebug(string.format("\230\173\166\229\153\168id\233\148\153\232\175\175\239\188\140id=%d", weaponData.weaponId))
    return
  end
  weaponData.weaponInfo = weaponInfo
  weaponData.property = {}
  self:SaveWeaponAttr(weaponData)
  return weaponData
end
function StrongInfoManager:UpdateWeaponData(id, totalExp)
  local weaponData = UserDataManager:GetInstance():GetWeaponData(id)
  if weaponData.level == weaponData.star * 5 then
    weaponData.level = 1
    weaponData.star = weaponData.star + 1
  elseif totalExp > 0 then
    totalExp = totalExp + weaponData.exp
    local addLevel = 0
    local upExp = td.CalWeaponExp(weaponData.star, weaponData.level, weaponData.weaponInfo.quality)
    while totalExp >= upExp do
      addLevel = addLevel + 1
      if weaponData.level + addLevel >= weaponData.star * 5 then
        totalExp = 0
        break
      else
        totalExp = totalExp - upExp
        upExp = td.CalWeaponExp(weaponData.star, weaponData.level + addLevel, weaponData.weaponInfo.quality)
      end
    end
    weaponData.level = weaponData.level + addLevel
    weaponData.exp = totalExp
  end
  self:SaveWeaponAttr(weaponData)
  UserDataManager:GetInstance():UpdateTotalPower()
  return weaponsData
end
function StrongInfoManager:SaveWeaponAttr(weaponData)
  local baseValue = weaponData.weaponInfo.property[weaponData.star]
  local rateValue = weaponData.weaponInfo.up_rate[weaponData.star]
  for _type, var in pairs(baseValue) do
    local rate = rateValue[_type] or 0
    local _value = td.CalWeaponProperty(weaponData.level, var, rate)
    weaponData.property[_type] = _value
  end
end
function StrongInfoManager:FindWeaponData(weaponDatas, targetId)
  for k, v in pairs(weaponDatas) do
    if v.weaponId == targetId then
      return k, v
    end
  end
  return -1, nil
end
function StrongInfoManager:IsEnableWeaponStrong(id, weaponId, eType)
  local userDataMng = UserDataManager:GetInstance()
  local weaponData = userDataMng:GetWeaponData(id)
  local heroData = self:GetHeroDataByWeaponId(id)
  local errorCode = td.ErrorCode.SUCCESS
  do
    local itemCost = {}
    if eType == 1 then
    else
    end
    for i, item in ipairs(itemCost) do
      if item.itemId == td.ItemID_Gold then
        if userDataMng:GetGold() < item.num then
          errorCode = td.ErrorCode.GOLD_NOT_ENOUGH
          break
        end
      elseif userDataMng:GetItemNum(item.itemId) < item.num then
        errorCode = td.ErrorCode.MATERIAL_NOT_ENOUGH
        break
      end
    end
  end
  if td.ErrorCode.SUCCESS == errorCode then
    return true, errorCode
  end
  return false, errorCode
end
function StrongInfoManager:MakeGemData(data)
  local gemInfo = self:GetGemInfo(data.gemstoneId)
  if not gemInfo then
    td.alertDebug(string.format("\229\174\157\231\159\179id\233\148\153\232\175\175\239\188\140id=%d", data.gemstoneId))
    return
  end
  data.quality = gemInfo.quality
  data.type = gemInfo.type
  return data
end
return StrongInfoManager
