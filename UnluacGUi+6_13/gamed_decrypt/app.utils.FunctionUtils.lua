function string.toTable(_s)
  local t = loadstring("return" .. _s)()
  if t == nil then
    print("string.toTable wrong table format")
  end
  return t
end
function string.findLast(haystack, needle)
  local i = haystack:match(".*" .. needle .. "()")
  if i == nil then
    return nil
  else
    return i - 1
  end
end
function table.toString(_t)
  local szRet = "{"
  function doT2S(_i, _v)
    if "number" == type(_i) then
      szRet = szRet .. "[" .. _i .. "] = "
      if "number" == type(_v) then
        szRet = szRet .. _v .. ","
      elseif "string" == type(_v) then
        szRet = szRet .. "\"" .. _v .. "\"" .. ","
      elseif "table" == type(_v) then
        szRet = szRet .. table.toString(_v) .. ","
      else
        szRet = szRet .. "nil,"
      end
    elseif "string" == type(_i) then
      szRet = szRet .. "[\"" .. _i .. "\"] = "
      if "number" == type(_v) then
        szRet = szRet .. _v .. ","
      elseif "string" == type(_v) then
        szRet = szRet .. "\"" .. _v .. "\"" .. ","
      elseif "table" == type(_v) then
        szRet = szRet .. table.toString(_v) .. ","
      else
        szRet = szRet .. "nil,"
      end
    end
  end
  table.foreach(_t, doT2S)
  szRet = szRet .. "}"
  return szRet
end
function table.equalsValue(table1, table2)
  assert(table1 ~= nil)
  assert(table2 ~= nil)
  if #table1 ~= #table2 then
    return false
  end
  local tmp_tb = {}
  for k, value in pairs(table1) do
    tmp_tb[value] = (tmp_tb[value] or 0) + 1
  end
  for k, value in pairs(table2) do
    if tmp_tb[value] == nil then
      return false
    else
      tmp_tb[value] = tmp_tb[value] - 1
    end
  end
  for k, value in pairs(tmp_tb) do
    if value > 0 then
      return false
    end
  end
  return true
end
function td.AttackFormula(atkParams, enemy, ratio, fixedValue)
  local attackValue, attackType, attackCareer = atkParams.atk, atkParams.type, atkParams.career
  local busterRatio = atkParams.buster
  local enemyDef, enemyType, enemyTag, enemyCareer = enemy:GetDefense(), enemy:GetType(), enemy:getTag(), enemy:GetCareerType()
  local skillRatio = (ratio or 100) / 100
  local fixedHurt = fixedValue or 0
  local value = attackValue * (1 - enemyDef / (150 + enemyDef)) * skillRatio
  local ratio = 1
  local BuffManager = require("app.buff.BuffManager")
  local hurtBuffs = {
    td.BuffType.SaberHurtVary,
    td.BuffType.ArcherHurtVary,
    td.BuffType.CasterHurtVary
  }
  local hurtRatio = {
    1,
    1,
    1
  }
  local attackCareers = {
    td.CareerType.Saber,
    td.CareerType.Archer,
    td.CareerType.Caster
  }
  local eBuffs = BuffManager:GetInstance():GetBuffByTag(enemyTag)
  for i, buffType in ipairs(hurtBuffs) do
    if eBuffs[buffType] then
      for key, v in ipairs(eBuffs[buffType]) do
        hurtRatio[i] = hurtRatio[i] * (1 + v:GetValue() / 100)
        if attackCareer == attackCareers[i] then
          v:OnWork()
        end
      end
    end
  end
  if eBuffs[td.BuffType.HurtVary_P] then
    for key, v in ipairs(eBuffs[td.BuffType.HurtVary_P]) do
      ratio = ratio * (1 + v:GetValue() / 100)
      v:OnWork()
    end
  end
  local effectRatio = 1.5
  local noEffectRatio = 0.5
  if (attackType == td.ActorType.Hero or attackType == td.ActorType.Monster or attackType == td.ActorType.Soldier) and (enemyType == td.ActorType.Hero or enemyType == td.ActorType.Monster or enemyType == td.ActorType.Soldier) then
    if attackCareer == td.CareerType.Saber then
      if enemyCareer == td.CareerType.Saber then
        ratio = ratio * hurtRatio[1] * busterRatio[1]
      elseif enemyCareer == td.CareerType.Archer then
        ratio = ratio * effectRatio * hurtRatio[1] * busterRatio[2]
      elseif enemyCareer == td.CareerType.Caster then
        ratio = ratio * noEffectRatio * hurtRatio[1] * busterRatio[3]
      end
    elseif attackCareer == td.CareerType.Archer then
      if enemyCareer == td.CareerType.Saber then
        ratio = ratio * noEffectRatio * hurtRatio[2] * busterRatio[1]
      elseif enemyCareer == td.CareerType.Archer then
        ratio = ratio * hurtRatio[2] * busterRatio[2]
      elseif enemyCareer == td.CareerType.Caster then
        ratio = ratio * effectRatio * hurtRatio[2] * busterRatio[3]
      end
    elseif attackCareer == td.CareerType.Caster then
      if enemyCareer == td.CareerType.Saber then
        ratio = ratio * effectRatio * hurtRatio[3] * busterRatio[1]
      elseif enemyCareer == td.CareerType.Archer then
        ratio = ratio * noEffectRatio * hurtRatio[3] * busterRatio[2]
      elseif enemyCareer == td.CareerType.Caster then
        ratio = ratio * hurtRatio[3] * busterRatio[3]
      end
    elseif enemyCareer == td.CareerType.Saber then
      ratio = ratio * hurtRatio[3] * busterRatio[1]
    elseif enemyCareer == td.CareerType.Archer then
      ratio = ratio * hurtRatio[3] * busterRatio[2]
    elseif enemyCareer == td.CareerType.Caster then
      ratio = ratio * hurtRatio[3] * busterRatio[3]
    end
  end
  value = value * ratio + fixedHurt
  return value
end
function td.CreateActorParams(pActor)
  local params = {}
  params.atk = pActor:GetAttackValue()
  params.hit = pActor:GetHitRate()
  params.crit = pActor:GetCritRate()
  params.type = pActor:GetType()
  params.career = pActor:GetCareerType()
  params.group = pActor:GetGroupType()
  params.id = pActor:GetData().id
  params.tag = pActor:getTag()
  local busterRatio = {
    1,
    1,
    1
  }
  local busterBuffs = {
    td.BuffType.SaberBuster,
    td.BuffType.ArcherBuster,
    td.BuffType.CasterBuster
  }
  local aBuffs = require("app.buff.BuffManager"):GetInstance():GetBuffByTag(pActor:getTag())
  for i, buffType in ipairs(busterBuffs) do
    if aBuffs[buffType] then
      for key, v in ipairs(aBuffs[buffType]) do
        busterRatio[i] = busterRatio[i] * (1 + v:GetValue() / 100)
        if v:GetValue() < 0 then
          v:OnWork()
        end
      end
    end
  end
  params.buster = busterRatio
  return params
end
function td.HurtEnemy(atkParams, enemy, ratio, value, isMustHit)
  if not atkParams then
    return false
  end
  local attacker = require("app.actor.ActorManager"):GetInstance():FindActorByTag(atkParams.tag)
  local targetEnemy = enemy
  local skillRatio = ratio or 100
  local fixedValue = value or 0
  if targetEnemy and not targetEnemy:IsDead() then
    local hitRateNum = cc.clampf(atkParams.hit - targetEnemy:GetDodgeRate(atkParams.career), 0, 100)
    local randNum = (isMustHit or hitRateNum >= 100) and 0 or math.random(100)
    if hitRateNum >= randNum then
      local value = td.AttackFormula(atkParams, targetEnemy, skillRatio, fixedValue)
      local critRateNum = atkParams.crit
      randNum = math.random(100)
      local bIsDead = false
      if critRateNum >= randNum then
        bIsDead = targetEnemy:ChangeHp(-value * 2, false, attacker)
        local BattleWord = require("app.widgets.BattleWord")
        local critWord = BattleWord.new("crit")
        critWord:AddToActor(targetEnemy)
      else
        bIsDead = targetEnemy:ChangeHp(-value, false, attacker)
      end
      if bIsDead and attacker then
        attacker:OnKillEnemy(targetEnemy:getTag())
      end
      return true
    else
      local BattleWord = require("app.widgets.BattleWord")
      local missWord = BattleWord.new("miss")
      missWord:AddToActor(targetEnemy)
    end
  end
  return false
end
function td.GunActorAzimuth(pActor, pEnemy)
  if not pEnemy or pEnemy:GetType() == td.ActorType.Home then
    return 3
  end
  local enemyPos = pEnemy:FindBonePos("bone_beiji")
  enemyPos = cc.pAdd(enemyPos, cc.p(pEnemy:getPosition()))
  local selfPos = cc.pAdd(cc.p(pActor:getPosition()), cc.p(0, pActor:GetContentSize().height / 3))
  local angle = -GetAzimuth(selfPos, enemyPos)
  local azimuth = math.ceil(math.abs(angle - 90) % 180 / 36)
  if azimuth == 1 and cc.pDistanceSQ(selfPos, enemyPos) <= 10000 and pEnemy:GetContentSize().height <= 150 then
    azimuth = 2
  end
  return azimuth
end
function td.GetValidPos(pMap, vBlockId, pos)
  local GameDataManager = require("app.GameDataManager")
  local tilePos = pMap:GetTilePosFromPixelPos(pos)
  for i, v in ipairs(vBlockId) do
    local n = tonumber(v)
    if n ~= 0 and not GameDataManager:GetInstance():IsAllPassBlock(n) then
      pMap:AddPassableRoadType(n)
    end
  end
  tilePos = cc.p(pMap:FindValidPos(tilePos))
  tilePos = cc.p(tilePos.x + 0.5, tilePos.y + 0.5)
  for i, v in ipairs(vBlockId) do
    local n = tonumber(v)
    if n ~= 0 and not GameDataManager:GetInstance():IsAllPassBlock(n) then
      pMap:RemovePassableRoadType(n)
    end
  end
  return cc.p(pMap:GetPixelPosFromTilePos(tilePos))
end
function td.CalculateTowerHp(level)
  return 300 + (level - 1) * (level * 15)
end
function td.CalculateTowerAttack(level)
  return 10 + (level - 1) * 8
end
function td.CalBaseExp(level)
  local baseInfo = require("app.info.BaseInfoManager"):GetInstance():GetBaseInfo(level)
  if baseInfo then
    return baseInfo.exp
  end
  return 9999999
end
function td.CalHeroExp(level)
  local t = math.pow(level - 1, 1.8)
  return 100 + math.floor(t) * 50
end
function td.CalHeroProperty(propType, level, base, rate)
  if propType == td.Property.HP then
    return td.CalHeroHp(level, base, rate)
  elseif propType == td.Property.Def then
    return td.CalHeroDef(level, base, rate)
  elseif propType == td.Property.Atk then
    return td.CalHeroAtk(level, base, rate)
  else
    return base
  end
end
function td.CalHeroHp(level, base, rate)
  return math.floor(base + (level - 1) * rate)
end
function td.CalHeroDef(level, base, rate)
  return math.floor(base + (level - 1) * rate)
end
function td.CalHeroAtk(level, base, rate)
  return math.floor(base + (level - 1) * rate)
end
function td.IsHeroSkillUnlock(heroLevel, bActive, skillIndex)
  local bResult = false
  local config = {
    {
      5,
      10,
      20
    },
    {1, 15}
  }
  local unlockLevel
  if bActive then
    unlockLevel = config[2][skillIndex]
  else
    unlockLevel = config[1][skillIndex]
  end
  if unlockLevel and heroLevel >= unlockLevel then
    bResult = true
  end
  return bResult, unlockLevel
end
function td.IsHeroGemUnlock(heroLevel, gemIndex)
  local unlockLevel = gemIndex * 10
  return heroLevel >= unlockLevel, unlockLevel
end
function td.CalWeaponExp(star, level, quality)
  local t = 50 + math.pow(quality - 1, 0.5) * (math.pow(50 * star, 1.25) + 100 * level)
  return math.floor(t / 50) * 50
end
function td.CalWeaponProperty(level, base, rate)
  return math.floor(base + (level - 1) * rate)
end
function td.CalWeaponProvideExp(star, level, curExp, quality)
  local totalExp = curExp or 0
  for i = 1, star do
    if i == star then
      for j = 1, level - 1 do
        totalExp = totalExp + td.CalWeaponExp(i, j, quality)
      end
    else
      for j = 1, i * 5 - 1 do
        totalExp = totalExp + td.CalWeaponExp(i, j, quality)
      end
    end
  end
  return totalExp * 0.8 + 200
end
function td.CalSoldierExp(star, level, quality)
  return 60 + (level - 1) * 60 * (quality / 2)
end
function td.GetMaxRob(itemId, friendLevel)
  if itemId == td.ItemID_Gold then
    return friendLevel * 100
  end
  return friendLevel * 45
end
function td.CalGuildPVPRes(startTime)
  local nowTime = require("app.UserDataManager"):GetInstance():GetServerTime()
  return math.floor((nowTime - startTime) / 10) * 1
end
function td.dispatchEvent(_eName, _data)
  local event = cc.EventCustom:new(_eName)
  if _data ~= nil then
    local d = ""
    if "string" == type(_data) or "number" == type(_data) then
      d = _data
    elseif "table" == type(_data) then
      d = table.toString(_data)
    end
    event:setDataString(d)
  end
  local dispatcher = cc.Director:getInstance():getEventDispatcher()
  dispatcher:dispatchEvent(event)
end
function td.TimeCompare(now, pre)
  if (now - pre) / 86400 >= 1 then
    return true
  end
  local preYear, preMonth, preDay = tonumber(os.date("%Y", pre)), tonumber(os.date("%m", pre)), tonumber(os.date("%d", pre))
  local nowYear, nowMonth, nowDay = tonumber(os.date("%Y", now)), tonumber(os.date("%m", now)), tonumber(os.date("%d", now))
  if preYear < nowYear or preMonth < nowMonth or preDay < nowDay then
    return true
  end
  return false
end
function td.GetStrForTime(time)
  local str
  local i1 = math.floor(time / 60)
  str = string.format("%02d:", i1)
  local i2 = math.floor(time - i1 * 60)
  str = str .. string.format("%02d", i2)
  return str
end
local partion = function(array, left, right, compareFunc)
  local key = array[left]
  local index = left
  array[index], array[right] = array[right], array[index]
  local i = left
  while right > i do
    if compareFunc(key, array[i]) then
      array[index], array[i] = array[i], array[index]
      index = index + 1
    end
    i = i + 1
  end
  array[right], array[index] = array[index], array[right]
  return index
end
local function quick(array, left, right, compareFunc)
  if left < right then
    local index = partion(array, left, right, compareFunc)
    quick(array, left, index - 1, compareFunc)
    quick(array, index + 1, right, compareFunc)
  end
end
function quickSort(array, compareFunc)
  quick(array, 1, table.nums(array), compareFunc)
end
function td.GetFutureTimeStamp(nowTimeStamp, future_days, future_hour)
  local one_hour_timestamp = 86400
  local temp_time = nowTimeStamp + one_hour_timestamp * future_days
  local temp_date = os.date("*t", temp_time)
  return os.time({
    year = temp_date.year,
    month = temp_date.month,
    day = temp_date.day,
    hour = future_hour
  })
end
function td.GetSimpleTime(time)
  local serverTime = require("app.UserDataManager"):GetInstance():GetServerTime()
  local timeDif = serverTime - time
  local formatStr, value
  if timeDif >= 86400 then
    formatStr, value = "%d\229\164\169\229\137\141", math.floor(timeDif / 86400)
  elseif timeDif >= 3600 then
    formatStr, value = "%d\229\176\143\230\151\182\229\137\141", math.floor(timeDif / 3600)
  else
    formatStr, value = "%d\229\136\134\233\146\159\229\137\141", math.floor(timeDif / 60)
  end
  return string.format(formatStr, value)
end
function timeStampToStr(timeStamp)
  local temp_date = os.date("*t", timeStamp)
  local year = temp_date.year < 10 and "0" .. temp_date.year or temp_date.year
  local month = 10 > temp_date.month and "0" .. temp_date.month or temp_date.month
  local day = 10 > temp_date.day and "0" .. temp_date.day or temp_date.day
  return year .. "-" .. month .. "-" .. day
end
function TimeStampToStr2(timeStamp)
  local temp_date = os.date("*t", timeStamp)
  local hour = temp_date.hour < 10 and "0" .. temp_date.hour or temp_date.hour
  local min = 10 > temp_date.min and "0" .. temp_date.min or temp_date.min
  local sec = 10 > temp_date.sec and "0" .. temp_date.sec or temp_date.sec
  return hour .. ":" .. min .. ":" .. sec
end
function td.CheckSensitive(str)
  local words = require("app.config.sensitive_words")
  for i, word in ipairs(words) do
    if string.find(str, word) then
      return true
    end
  end
  return false
end
function td.ReplaceSensitive(str)
  local words = require("app.config.sensitive_words")
  for i, word in ipairs(words) do
    str = string.gsub(str, word, "*")
  end
  return str
end
function td.CheckStringLength(str, maxLength)
  local legal = false
  local skipBits = 0
  local length = 0
  for i = 1, string.len(str) do
    if skipBits > 0 then
      skipBits = skipBits - 1
    elseif string.byte(str, i) > 127 then
      length = length + 2
      skipBits = 2
    else
      length = length + 1
    end
  end
  if maxLength < length then
    legal = false
  else
    legal = true
  end
  return legal
end
function td.CheckStamina(missionId, text)
  local isAvailable = false
  local stam = require("app.info.MissionInfoManager"):GetInstance():GetMissionInfo(missionId).vit or 0
  local myStam = require("app.UserDataManager"):GetInstance():GetStamina()
  if stam <= myStam then
    isAvailable = true
  end
  if text then
    text:setString("x" .. tostring(stam))
    text:setColor(isAvailable and td.WHITE or td.RED)
  end
  return isAvailable
end
function td.GetSysMsg(data)
  local tmp = string.split(data.msg, "#")
  local result = {
    data.msg
  }
  if data.type == 1 then
    result = {
      "",
      tmp[1],
      "\233\128\154\232\191\135\230\141\144\231\140\174\232\142\183\229\190\151\228\186\134",
      tmp[2],
      "\232\180\161\231\140\174\229\128\188\227\128\130"
    }
  elseif data.type == 2 then
    local buildName = require("app.info.GuildInfoManager"):GetInstance():GetBuildingInfo(tonumber(tmp[1])).name
    result = {
      "\229\134\155\229\155\162\229\187\186\231\173\145",
      buildName,
      "\229\141\135\229\136\176\228\186\134",
      tmp[2],
      "\231\186\167\227\128\130"
    }
  elseif data.type == 3 then
    local weaponName = require("app.info.StrongInfoManager"):GetInstance():GetWeaponInfo(tonumber(tmp[2])).name
    result = {
      "",
      tmp[1],
      "\232\142\183\229\190\151\228\186\1345\230\152\159\232\163\133\229\164\135",
      weaponName,
      "\227\128\130"
    }
  elseif data.type == 4 then
    local stateStr = tmp[2] == "0" and "\230\136\152\232\131\156\228\186\134" or "\228\184\141\230\149\140"
    result = {
      "\230\136\145\230\150\185\229\134\155\229\155\162\229\156\168\230\156\172\230\172\161\229\134\155\229\155\162\230\136\152\228\184\173" .. stateStr,
      tmp[1],
      "\227\128\130"
    }
  elseif data.type == 5 then
    result = {
      "",
      tmp[1],
      "\229\138\160\229\133\165\228\186\134\229\134\155\229\155\162\227\128\130"
    }
  elseif data.type == 6 then
    result = {
      "",
      tmp[1],
      "\233\128\128\229\135\186\228\186\134\229\134\155\229\155\162\227\128\130"
    }
  elseif data.type == 7 then
    tmp[2] = tonumber(tmp[2])
    tmp[3] = tonumber(tmp[3])
    local stateStr = tmp[2] > tmp[3] and "\232\162\171\230\143\144\229\141\135\228\184\186" or "\232\162\171\233\153\141\232\129\140\228\184\186"
    result = {
      "",
      tmp[1],
      "\228\187\142",
      g_LM:getMode("guildPos", tmp[2]),
      stateStr,
      g_LM:getMode("guildPos", tmp[3]),
      "\227\128\130"
    }
  end
  return result
end
function td.GetItemInfo(id)
  local info
  if id < 20000 then
    info = require("app.info.StrongInfoManager"):GetInstance():GetWeaponInfo(id)
  elseif id > 80000 then
    info = require("app.info.StrongInfoManager"):GetInstance():GetGemInfo(id)
  else
    info = require("app.info.ItemInfoManager"):GetInstance():GetItemInfo(id)
  end
  return info
end
function td.ParserItemStr(itemStr, splitChar)
  splitChar = splitChar or "|"
  local result = {}
  local tmp = string.split(itemStr, splitChar)
  for i, subStr in ipairs(tmp) do
    local tmp1 = string.split(subStr, "#")
    local item = {}
    if tonumber(tmp1[1]) == 1 then
      item.itemId = tonumber(tmp1[2])
      item.num = 1
    else
      item.itemId = tonumber(tmp1[1])
      item.num = tonumber(tmp1[2])
    end
    table.insert(result, item)
  end
  return result
end
function td.GetConst(key)
  return require("app.info.CommonInfoManager"):GetInstance():GetConstant(key)
end
