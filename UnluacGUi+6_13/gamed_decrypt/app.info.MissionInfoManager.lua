local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local TDHttpRequest = require("app.net.TDHttpRequest")
local scheduler = require("framework.scheduler")
local UserDataManager = require("app.UserDataManager")
local MissionInfoManager = class("MissionInfoManager", GameControl)
MissionInfoManager.instance = nil
function MissionInfoManager:ctor(eType)
  MissionInfoManager.super.ctor(self, eType)
  self:Init()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetMissions_req, handler(self, self.GetCityDataCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetAllMissionReward_req, handler(self, self.GetProfitCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.AddMission_req, handler(self, self.AddMissionCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.BuyMissionTime, handler(self, self.BuyMissionCallback))
end
function MissionInfoManager:GetInstance()
  if MissionInfoManager.instance == nil then
    MissionInfoManager.instance = MissionInfoManager.new(td.GameControlType.ExitGame)
  end
  return MissionInfoManager.instance
end
function MissionInfoManager:Init()
  self.m_chapterInfos = {
    [1] = {},
    [2] = {},
    [3] = {}
  }
  self.m_missionInfos = {}
  self.m_ziyuanposInfos = {}
  self.m_missionCaidans = {}
  self.m_trialLevelInfos = {
    [1] = {},
    [2] = {},
    [3] = {}
  }
  self.m_trialInfos = {}
  self:SaveInfo()
end
function MissionInfoManager:ClearValue()
end
function MissionInfoManager:SaveInfo()
  local vData = CSVLoader.loadCSV("Config/chapter.csv")
  for i, v in ipairs(vData) do
    v.missions = {}
    v.name = g_LM:getBy(v.name)
    self.m_chapterInfos[v.mode][v.chapter_id] = v
  end
  vData = CSVLoader.loadCSV("Config/mission.csv")
  for i, v in ipairs(vData) do
    local tmp = string.split(v.award_1, "|")
    local vRewardID = {}
    for key, val in ipairs(tmp) do
      if val ~= "" then
        local reward = string.split(val, "#")
        table.insert(vRewardID, {
          itemId = tonumber(reward[1]),
          num = tonumber(reward[2])
        })
      end
    end
    v.award = vRewardID
    if v.camera_dot ~= "" and v.camera_dot ~= "0" then
      tmp = string.split(v.camera_dot, "#")
      v.camera_dot = cc.p(tonumber(tmp[1]), tonumber(tmp[2]))
    else
      v.camera_dot = nil
    end
    tmp = string.split(v.star_level, "|")
    local vStarLvl = {}
    for key, val in ipairs(tmp) do
      local starLvlInfo = string.split(val, "#")
      local starLvl = {
        tonumber(starLvlInfo[1]),
        tonumber(starLvlInfo[2] or 0)
      }
      table.insert(vStarLvl, starLvl)
    end
    v.star_level = vStarLvl
    v.name = g_LM:getBy(v.name)
    v.text = g_LM:getBy(v.text)
    v.story = g_LM:getBy(v.story)
    self.m_missionInfos[v.id] = v
    if self.m_chapterInfos[v.mode] and self.m_chapterInfos[v.mode][v.chapter] then
      table.insert(self.m_chapterInfos[v.mode][v.chapter].missions, v.id)
    end
  end
  vData = CSVLoader.loadCSV("Config/ziyuanpos.csv")
  for i, v in ipairs(vData) do
    self.m_ziyuanposInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/mission_caidan.csv")
  for i, v in ipairs(vData) do
    local tmp = string.split(v.effectId, "#")
    v.effectId = {}
    for j, var in ipairs(tmp) do
      table.insert(v.effectId, tonumber(var))
    end
    self.m_missionCaidans[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/trial_level.csv")
  for i, v in ipairs(vData) do
    local tmp1 = string.split(v.maps, "#")
    v.maps = {}
    for j, var in ipairs(tmp1) do
      table.insert(v.maps, tonumber(var))
    end
    table.insert(self.m_trialLevelInfos[v.mode], v)
  end
  vData = CSVLoader.loadCSV("Config/trial.csv")
  for i, v in ipairs(vData) do
    self.m_trialInfos[v.id] = v
  end
end
function MissionInfoManager:GetChaptersInfo()
  return self.m_chapterInfos
end
function MissionInfoManager:GetMissionInfo(missionId)
  return self.m_missionInfos[missionId]
end
function MissionInfoManager:GetTrialLevelInfo(diff, level)
  diff = diff or 1
  local trialLevels = self.m_trialLevelInfos[diff]
  if level then
    return trialLevels[level]
  end
  return trialLevels
end
function MissionInfoManager:GetTrialInfo(id)
  return self.m_trialInfos[id]
end
function MissionInfoManager:GetZiyuanPosInfo(key)
  return self.m_ziyuanposInfos[key]
end
function MissionInfoManager:GetMissionCaidan(missionId)
  return self.m_missionCaidans[missionId]
end
function MissionInfoManager:GetAllMissionInfo()
  return self.m_missionInfos
end
function MissionInfoManager:getAllMissionCnt()
  local cnt = 0
  for _, value in pairs(self.m_missionInfos) do
    if value.id >= 1000 and value.id < 3000 then
      cnt = cnt + 1
    end
  end
  cnt = cnt / 2
  return math.floor(cnt)
end
function MissionInfoManager:UpdateProfitSpeed()
  local udMng = UserDataManager:GetInstance()
  local cityData = udMng:GetAllCitiesData()
  local goldSpeed, forceSpeed = 0, 0
  for k, value in pairs(cityData) do
    local info = self.m_missionInfos[value.missionId]
    if info and info.tax ~= "0" and info.tax ~= "" then
      local tmp = string.split(info.tax, "|")
      for i, var in ipairs(tmp) do
        local tmp2 = string.split(var, "#")
        local id = tonumber(tmp2[1])
        if id == td.ItemID_Gold then
          goldSpeed = goldSpeed + tonumber(tmp2[2])
        elseif id == td.ItemID_Force then
          forceSpeed = forceSpeed + tonumber(tmp2[2])
        end
      end
    end
  end
  local vipInfo = require("app.info.CommonInfoManager"):GetInstance():GetVipInfo(udMng:GetVipLevel())
  local boostGoldSpeed = udMng:GetBoostValue(td.BoostType.GoldSpeed)
  goldSpeed = goldSpeed * (100 + boostGoldSpeed + vipInfo.gold_speed) / 100
  local boostForceSpeed = udMng:GetBoostValue(td.BoostType.ForceSpeed)
  forceSpeed = forceSpeed * (100 + boostForceSpeed + vipInfo.gold_speed) / 100
  udMng:UpdateProfitSpeed(td.ItemID_Gold, goldSpeed)
  udMng:UpdateProfitSpeed(td.ItemID_Force, forceSpeed)
end
function MissionInfoManager.GetProfit(itemId)
  local userMng = UserDataManager:GetInstance()
  local servertime = userMng:GetServerTime()
  local max = userMng:GetMaxProfit(itemId) or 0
  local profitData = userMng:GetProfitData(itemId)
  if not profitData then
    return 0, max
  end
  local profitTime = profitData.lastTime
  if profitTime == 0 then
    return 0, max
  end
  local remain = profitData.remain
  local speed = profitData.speed
  local accTime = math.floor((servertime - profitTime) / 360)
  local cur = math.min(remain + speed * accTime, max)
  return math.floor(cur), max
end
function MissionInfoManager:UpdateProfitLocal()
  local udMng = UserDataManager:GetInstance()
  local serverTime = udMng:GetInstance():GetServerTime()
  local profits = udMng:GetProfitData()
  for itemId, var in pairs(profits) do
    udMng:UpdateRestProfit(itemId, MissionInfoManager.GetProfit(itemId))
    udMng:UpdateProfitTime(itemId, serverTime)
  end
end
function MissionInfoManager:GetCityNumByState(state)
  local cityData = UserDataManager:GetInstance():GetAllCitiesData()
  local cnt = 0
  for k, value in pairs(cityData) do
    if k < 2000 then
      cnt = cnt + 1
    end
  end
  return cnt
end
function MissionInfoManager.CalculateProfitSpeed(itemId, missionIds)
  local speed = 0
  for i, missionId in ipairs(missionIds) do
    local info = MissionInfoManager:GetInstance():GetMissionInfo(missionId)
    if info then
      local tmp = string.split(info.tax, "|")
      for i, var in ipairs(tmp) do
        local tmp2 = string.split(var, "#")
        if tonumber(tmp2[1]) == itemId then
          speed = speed + tonumber(tmp2[2])
          break
        end
      end
    end
  end
  return speed
end
function MissionInfoManager:IsMissionUnlock(missionId)
  local missionInfo = self.m_missionInfos[missionId]
  local preMissionId = missionInfo.unlock_mission
  if preMissionId ~= 0 and nil == UserDataManager:GetInstance():GetCityData(preMissionId) then
    return false
  end
  return true
end
function MissionInfoManager:IsChapterUnlock(chapterId, diff)
  diff = diff or 1
  local preDiff = diff - 1
  if chapterId ~= 1 then
    local bMissionUnlock = self:IsMissionUnlock(self.m_chapterInfos[diff][chapterId].missions[1])
    if not bMissionUnlock then
      return false, td.ErrorCode.MISSION_LOCKED
    end
  end
  if diff ~= 1 then
    local udMng = UserDataManager:GetInstance()
    if diff == 3 and udMng:GetBaseCampLevel() < 20 then
      return false, td.ErrorCode.LEVEL_LOW
    end
    local missions = self.m_chapterInfos[preDiff][chapterId].missions
    if not udMng:GetCityData(missions[4]) then
      return false, td.ErrorCode.MISSION_LOCKED
    end
    local starCount = 0
    for i, missionId in ipairs(missions) do
      local missionData = udMng:GetCityData(missionId)
      if missionData then
        starCount = starCount + table.nums(missionData.star)
      end
    end
    if starCount < self.m_chapterInfos[diff][chapterId].unlock then
      return false, td.ErrorCode.STAR_LOW
    end
  end
  return true, td.ErrorCode.SUCCESS
end
function MissionInfoManager:TestMissions()
  self.errorMissions = {}
  for key, var in pairs(self.m_missionInfos) do
    if key >= 1000 and key < 6000 then
      self:_CheckMission(var)
    end
  end
  for id, errors in pairs(self.errorMissions) do
    for i, var in ipairs(errors) do
      print(id, var)
    end
  end
end
function MissionInfoManager:_CheckMission(mapInfo)
  local aiMng = require("app.info.ActorInfoManager"):GetInstance()
  self.errorMissions[mapInfo.id] = {}
  print("\230\163\128\230\181\139\229\188\128\229\167\139 mission\239\188\154" .. mapInfo.id)
  self.m_vMonsterPlans = {}
  local plan = mapInfo.monster_plan
  if plan == "0" then
    print("monster_plan=0")
    print("\230\163\128\230\181\139\231\187\147\230\157\159")
    return true
  end
  local t1 = string.split(plan, ";")
  for i1, j1 in ipairs(t1) do
    if "" == j1 then
      break
    end
    local plan = {}
    plan.monstInfos = {}
    local t5 = string.split(j1, "$")
    if #t5 >= 2 then
      plan.reward = tonumber(t5[2])
    end
    local t10 = string.split(t5[1], "&")
    local t20 = string.split(t10[1], "*")
    plan.tipInfo = {}
    for i20, j20 in ipairs(t20) do
      local tipData = {}
      local t11 = string.split(j20, "#")
      if #t11 >= 4 then
        if t11[1] == "^" then
          tipData.waitTime = -1
        else
          tipData.waitTime = tonumber(t11[1])
        end
        local t12 = string.split(t11[2], "|")
        tipData.pathID = tonumber(t12[1])
        tipData.pathIndex = tonumber(t12[2])
        tipData.dir = tonumber(t11[3])
        local monstInfo = {}
        if t11[4] then
          local t12 = string.split(t11[4], "@")
          for i12, j12 in ipairs(t12) do
            local t13 = string.split(j12, "|")
            local monstData = {}
            monstData.monstId = tonumber(t13[1])
            monstData.monstNum = tonumber(t13[2])
            table.insert(monstInfo, monstData)
            if not aiMng:GetMonsterInfo(monstData.monstId) then
              table.insert(self.errorMissions[mapInfo.id], "\229\135\186\229\133\181\230\143\144\231\164\186\230\128\170\231\137\169\228\184\141\229\173\152\229\156\168\239\188\154" .. monstData.monstId .. ",\230\179\162\230\149\176\239\188\154" .. i1)
            elseif nil == monstData.monstNum then
              table.insert(self.errorMissions[mapInfo.id], "\229\135\186\229\133\181\230\143\144\231\164\186\230\128\170\231\137\169\230\149\176\233\135\143\230\178\161\233\133\141,\230\179\162\230\149\176\239\188\154" .. i1 .. ",\230\128\170\231\137\169id:" .. monstData.monstId)
            end
          end
        end
        tipData.monstInfo = monstInfo
        table.insert(plan.tipInfo, tipData)
      else
        print("\229\135\186\229\133\181\230\150\185\230\161\136\233\133\141\231\189\174\230\156\137\232\175\175\239\188\154" .. t10[1])
        return false
      end
    end
    local waveInf = {}
    local t2 = string.split(t10[2], ":")
    for i2, j2 in ipairs(t2) do
      local info = {}
      info.subMonstInfos = {}
      local t3 = string.split(j2, "%")
      info.nextWait = tonumber(t3[2])
      local t31 = string.split(t3[1], "@")
      for i30, j30 in ipairs(t31) do
        local subinfo = {}
        subinfo.count = 0
        subinfo.paths = {}
        subinfo.type = td.ActorType.Monster
        subinfo.enemy = true
        local t32 = string.split(j30, "|")
        for i3, j3 in ipairs(t32) do
          local t4 = string.split(j3, "#")
          for i4, j4 in ipairs(t4) do
            if i3 == 1 then
              if i4 == 1 then
                subinfo.id = tonumber(j4)
                if not aiMng:GetMonsterInfo(subinfo.id) then
                  table.insert(self.errorMissions[mapInfo.id], "\230\128\170\231\137\169\228\184\141\229\173\152\229\156\168\239\188\154" .. subinfo.id)
                end
              else
                subinfo.num = tonumber(j4)
                if nil == subinfo.num then
                  table.insert(self.errorMissions[mapInfo.id], "\230\128\170\231\137\169\230\149\176\233\135\143\230\178\161\233\133\141,\230\179\162\230\149\176\239\188\154" .. i1 .. ",\229\176\143\230\179\162\239\188\154" .. i2 .. ",\230\128\170\231\137\169id:" .. subinfo.id)
                end
              end
            else
              local pathInfo = {}
              local found = string.find(j4, "f")
              if found then
                local s = string.sub(j4, 2, string.len(j4))
                pathInfo.pathID = tonumber(s)
                pathInfo.bInverted = true
              else
                pathInfo.pathID = tonumber(j4)
                pathInfo.bInverted = false
              end
              table.insert(subinfo.paths, pathInfo)
            end
          end
        end
        table.insert(info.subMonstInfos, subinfo)
      end
      table.insert(waveInf, info)
    end
    plan.monstInfos = waveInf
    table.insert(self.m_vMonsterPlans, plan)
  end
  print("\230\156\128\229\164\167\230\179\162\230\149\176\239\188\154" .. #self.m_vMonsterPlans)
  print("\230\163\128\230\181\139\231\187\147\230\157\159")
  return true
end
function MissionInfoManager.GetStaminaCost(type, vit)
  if type == 2 then
    return vit * 8
  else
    return vit
  end
end
function MissionInfoManager.GetSweepCost(type, sweep)
  if type == 2 then
    return sweep * 8
  elseif type == 1 then
    return sweep
  end
  return 0
end
function MissionInfoManager:SendAddMissionRequest(_missionId, vStar, _bIsDF)
  local Msg = {}
  Msg.msgType = td.RequestID.AddMission_req
  Msg.sendData = {
    missionId = _missionId,
    type = 1,
    star = vStar
  }
  Msg.cbData = {
    missionId = _missionId,
    type = 1,
    star = vStar,
    bIsDF = _bIsDF
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function MissionInfoManager:SendQuickMissionRequest(_missionId, time)
  local Msg = {}
  Msg.msgType = td.RequestID.AddMission_req
  Msg.sendData = {
    missionId = _missionId,
    type = 0,
    num = time
  }
  Msg.cbData = {
    missionId = _missionId,
    type = 0,
    num = time
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function MissionInfoManager:AddMissionCallback(data, cbData)
  if data.state == td.ResponseState.Success and cbData then
    local udMng = UserDataManager:GetInstance()
    local costNum = cbData.num or 1
    local missionData = udMng:GetCityData(cbData.missionId)
    if not cbData.bIsDF then
      local missionInfo = self:GetMissionInfo(cbData.missionId)
      local staminaCost = missionInfo.vit
      if costNum == 10 then
        staminaCost = MissionInfoManager.GetStaminaCost(2, missionInfo.vit)
      end
      udMng:PublicConsume(td.WealthType.STAMINA, staminaCost)
      if missionData then
        missionData.num = missionData.num - costNum
      end
    end
    if cbData.type == 1 then
      local starDic = {}
      for i, var in ipairs(cbData.star) do
        starDic[tonumber(var)] = 1
      end
      if not missionData then
        udMng:UpdateCityData({
          missionId = cbData.missionId,
          star = starDic,
          occupation = td.OccupState.Normal
        })
        self:UpdateProfitLocal()
        self:UpdateProfitSpeed()
      else
        udMng:UpdateCityState({
          missionId = cbData.missionId,
          occupation = td.OccupState.Normal
        })
        udMng:UpdateCityStar({
          missionId = cbData.missionId,
          star = starDic
        })
      end
    end
    local _awards = {}
    for i, var in ipairs(data.missionItem) do
      table.insert(_awards, {
        itemId = var.item_id,
        num = var.item_num
      })
    end
    td.dispatchEvent(td.FIGHT_WIN, {
      missionId = cbData.missionId,
      awards = _awards
    })
  end
end
function MissionInfoManager:SendBuyMissionRequest(_missionId)
  local Msg = {}
  Msg.msgType = td.RequestID.BuyMissionTime
  Msg.sendData = {mission_id = _missionId}
  Msg.cbData = {mission_id = _missionId}
  TDHttpRequest:getInstance():Send(Msg)
end
function MissionInfoManager:BuyMissionCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    local missionData = UserDataManager:GetInstance():GetCityData(cbData.mission_id)
    if missionData then
      missionData.num = td.MissionTime
      missionData.buy_num = missionData.buy_num - 1
    end
    td.dispatchEvent(td.MISSION_UPDATE)
  else
    td.alert(g_LM:getBy("a00323"))
  end
end
function MissionInfoManager:SendGetCityRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetMissions_req
  TDHttpRequest:getInstance():Send(Msg)
end
function MissionInfoManager:GetCityDataCallback(data)
  if data then
    local udMng = UserDataManager:GetInstance()
    for key, missionData in pairs(data.missions) do
      if missionData.star == "" then
        missionData.star = {}
      elseif missionData.star then
        local tmp = string.split(missionData.star, ",")
        missionData.star = {}
        for i, var in ipairs(tmp) do
          if var ~= "" then
            missionData.star[tonumber(var)] = 1
          end
        end
      end
      UserDataManager:GetInstance():UpdateCityData(missionData)
    end
    self:UpdateProfitSpeed()
    td.dispatchEvent(td.MISSION_DATA_INITED)
  end
end
function MissionInfoManager:SendGetProfitRequest(itemId)
  local Msg = {}
  Msg.msgType = td.RequestID.GetAllMissionReward_req
  Msg.sendData = {item_id = itemId}
  Msg.cbData = {item_id = itemId}
  TDHttpRequest:getInstance():Send(Msg)
end
function MissionInfoManager:GetProfitCallback(data, cbData)
  if data.state ~= td.ResponseState.Success then
    td.alertDebug("\233\162\134\229\143\150\229\164\177\232\180\165")
  end
  local udMng = UserDataManager:GetInstance()
  udMng:UpdateProfitTime(cbData.item_id, udMng:GetServerTime())
  udMng:UpdateRestProfit(cbData.item_id, 0)
  td.dispatchEvent(td.UPDATE_PROFIT)
end
return MissionInfoManager
