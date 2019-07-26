local TDHttpRequest = require("app.net.TDHttpRequest")
local GameControl = require("app.GameControl")
local scheduler = require("framework.scheduler")
require("socket")
local UserDataManager = class("UserDataManager", GameControl)
UserDataManager.instance = nil
function UserDataManager:ctor(eType)
  UserDataManager.super.ctor(self, eType)
  self:Init()
  self:AddListeners()
end
function UserDataManager:GetInstance()
  if UserDataManager.instance == nil then
    UserDataManager.instance = UserDataManager.new(td.GameControlType.Login)
  end
  return UserDataManager.instance
end
function UserDataManager:Init()
  self.m_sessionId = ""
  self.m_uuid = ""
  self.m_timeDiff = 0
  self.m_timeDiffMil = 0
  self.m_bHadEnterMainMenu = false
  self.m_serverData = nil
  self.m_userData = {}
  self.m_taskDatas = {}
  self.m_achieveDatas = {}
  self.m_friendDatas = {}
  self.m_otherUserDatas = {}
  self.m_vMailsData = {}
  self.m_vCitiesData = {}
  self.m_cityProfits = {}
  self.m_maxStamina = 0
  self.m_vSkillLib = {}
  self.m_heroDatas = {}
  self.m_vSoldiersData = {}
  self.m_vWeaponData = {}
  self.m_vGemData = {}
  self.m_vItems = {}
  self.m_vLog = {}
  self.m_vGuildSkillsData = {}
  self.m_boostData = {}
  self.m_PVPData = {}
  self.m_rankListData = {}
  self.m_myRank = {}
  self.m_payInfo = nil
  self.timeInteval = 0
  self.bPayEnd = true
end
function UserDataManager:ClearValue()
  self:Init()
  if self.addStaminaTimer then
    scheduler.unscheduleGlobal(self.addStaminaTimer)
    self.addStaminaTimer = nil
  end
  pu.MobClickFunc(3)
end
function UserDataManager:Update(dt)
  if not self.bPayEnd and self.m_payInfo then
    self.timeInteval = self.timeInteval + dt
    if self.timeInteval > 3 then
      self.timeInteval = 0
      self:GetTradeStateRequest(self.m_payInfo.orderId)
    end
  end
end
function UserDataManager:GetTradeStateRequest(orderId)
  local sendData = {id = orderId}
  TDHttpRequest:getInstance():SendNoProto("GetPayOrderServlet", sendData, function(data)
    self:TradeStateResponse(data)
  end)
end
function UserDataManager:TradeStateResponse(data)
  if data and data.order and data.order.success == 1 then
    self:PaySuccess(self.m_payInfo)
    self.m_payInfo = nil
    self.bPayEnd = true
  end
end
function UserDataManager:AddListeners()
  TDHttpRequest:getInstance():registerCallback(td.RequestID.JoinGame, handler(self, self.JoinGameResponse))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UpdateUser_req, handler(self, self.UpdateUserDetailCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetPack, handler(self, self.GetPackCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.UpdateItems, handler(self, self.ItemCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetWeapons_req, handler(self, self.GetWeaponCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetGems, handler(self, self.GetGemCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetSkillLib, handler(self, self.GetSkillsCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetHeros_req, handler(self, self.GetHerosCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.TaskRequest, handler(self, self.TaskResponseCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetTaskAward_req, handler(self, self.TaskRewardCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.Achieventment, handler(self, self.AchieveResponseCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetFriends_req, handler(self, self.FriendResponseCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.RecommendFriends, handler(self, self.RecommendFriendCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.ServerInfo, handler(self, self.FinishAchieveResponse))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetCards, handler(self, self.GetCards))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetMails_req, handler(self, self.GetMailsRequestCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.AddFriend_req, handler(self, self.AddFriendCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetPVPData_req, handler(self, self.GetPVPDataCallback))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.Topup, handler(self, self.TradeIdResponse))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.Validation, handler(self, self.ValidationResponse))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.NewSignIn, handler(self, self.NewSignInResponse))
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetUserLog, handler(self, self.GetUserLogResponse))
end
function UserDataManager:SetServerData(data)
  self.m_serverData = data
end
function UserDataManager:GetServerData()
  return self.m_serverData
end
function UserDataManager:InitAchieveData()
  self.m_achieveDatas = {}
  for i = 0, 2 do
    local data = {
      [td.AchievementState.Incomplete] = {},
      [td.AchievementState.Complete] = {},
      [td.AchievementState.Received] = {}
    }
    self.m_achieveDatas[i] = data
  end
  local achieveInfos = require("app.info.AchievementInfo"):GetInstance():GetInfos()
  for key, var in pairs(achieveInfos) do
    local data = {
      id = key,
      num = 0,
      receive = td.AchievementState.Incomplete
    }
    table.insert(self.m_achieveDatas[var.type][td.AchievementState.Incomplete], data)
  end
end
function UserDataManager:InitLivenessData()
  local liveness = {
    false,
    false,
    false,
    false
  }
  if self.m_userDetail.liveness_award then
    local tmp = string.split(self.m_userDetail.liveness_award, ",")
    for i, index in ipairs(tmp) do
      local _index = tonumber(index)
      if _index then
        liveness[_index] = true
      end
    end
  end
  self.m_userDetail.liveness_award = liveness
end
function UserDataManager:ExitGame()
  pu.SubmitData(3)
end
function UserDataManager:GetActivityManager()
  return require("app.ActivityDataManager"):GetInstance()
end
function UserDataManager:GetGuildManager()
  return require("app.GuildDataManager"):GetInstance()
end
function UserDataManager:GetStoreManager()
  return require("app.StoreDataManager"):GetInstance()
end
function UserDataManager:HadEnteredMainMenu()
  return self.m_bHadEnterMainMenu
end
function UserDataManager:SetEnteredMainMenu()
  self.m_bHadEnterMainMenu = true
end
function UserDataManager:GetRoleCTime()
  return self.m_userDetail.c_time
end
function UserDataManager:SetSessionId(id)
  self.m_sessionId = id
end
function UserDataManager:GetSessionId()
  if nil == self.m_sessionId or self.m_sessionId == "" then
    return td.ORI_SESSION
  end
  return self.m_sessionId
end
function UserDataManager:SetUId(id)
  self.m_uuid = string.format("%s_%s", tostring(id), pu.GetPlatform())
  g_LD:SetUId(self.m_uuid)
end
function UserDataManager:GetUId()
  return self.m_uuid
end
function UserDataManager:GetUserData()
  return self.m_userData
end
function UserDataManager:GetUserDetail()
  return clone(self.m_userDetail)
end
function UserDataManager:SetBaseCampLevel(baseCampLevel)
  if self.m_userDetail then
    self.m_userDetail.camp = baseCampLevel
    self:UpdateTotalPower()
  end
end
function UserDataManager:GetBaseCampLevel()
  return self.m_userDetail.camp
end
function UserDataManager:GetMaxProfit(itemId)
  local reputation = self.m_userDetail.reputation
  local result = require("app.info.CommanderInfoManager"):GetInstance():GetMaxProfitByRepu(reputation, itemId)
  if itemId == td.ItemID_Gold then
    result = result * (1 + self:GetBoostValue(td.BoostType.MaxGold) / 100)
  elseif itemId == td.ItemID_Force then
    result = result * (1 + self:GetBoostValue(td.BoostType.MaxForce) / 100)
  end
  return result
end
function UserDataManager:AddExp(campExp)
  local bLevelUp = false
  local biMng = require("app.info.BaseInfoManager"):GetInstance()
  local nextBaseInfo = biMng:GetBaseInfo(self.m_userDetail.camp + 1)
  if nextBaseInfo then
    self.m_userDetail.campExp = self.m_userDetail.campExp + campExp
  end
  while nextBaseInfo do
    local baseInfo = biMng:GetBaseInfo(self.m_userDetail.camp)
    if self.m_userDetail.campExp >= baseInfo.exp then
      self.m_userDetail.campExp = self.m_userDetail.campExp - baseInfo.exp
      self:SetBaseCampLevel(self.m_userDetail.camp + 1)
      require("app.GuideManager"):GetInstance():SetGuideLevelUp(self.m_userDetail.camp)
      bLevelUp = true
      self:PublicGain(td.WealthType.STAMINA, math.floor(nextBaseInfo.vit / 2))
      pu.SubmitData(2)
      pu.MobClickFunc(6, self.m_userDetail.camp)
      nextBaseInfo = biMng:GetBaseInfo(self.m_userDetail.camp + 1)
    else
      nextBaseInfo = nil
    end
  end
  return bLevelUp
end
function UserDataManager:GetExp()
  return self.m_userDetail.campExp
end
function UserDataManager:GetGold()
  return self.m_userDetail.gold
end
function UserDataManager:GetDiamond()
  return self.m_userDetail.diamond
end
function UserDataManager:GetStamina()
  return self.m_userDetail.stamina
end
function UserDataManager:GetMaxStamina()
  local baseInfo = require("app.info.BaseInfoManager"):GetInstance():GetBaseInfo(self.m_userDetail.camp)
  return baseInfo.vit + self:GetBoostValue(td.BoostType.MaxStamina)
end
function UserDataManager:GetSkillLib()
  return self.m_vSkillLib
end
function UserDataManager:UpdateHeroSkillData(skillProto)
  local SkillInfoManager = require("app.info.SkillInfoManager")
  local skillData = SkillInfoManager:GetInstance():MakeSkillData(skillProto, nil, self.m_boostData)
  self.m_vSkillLib[skillData.id] = skillData
  self:UpdateTotalPower()
end
function UserDataManager:GetLiveness()
  return self.m_userDetail.liveness or 0
end
function UserDataManager:IsLivenessReceived(index)
  return self.m_userDetail.liveness_award[index]
end
function UserDataManager:SetLivenessReceived(index)
  self.m_userDetail.liveness_award[index] = true
end
function UserDataManager:GetVipLevel()
  return self.m_userDetail.vipProto.level
end
function UserDataManager:GetBuyTimes(buyType)
  local time = 0
  if buyType == td.UIModule.BuyGold then
    time = self.m_userDetail.vipProto.gold_change_num
  elseif buyType == td.UIModule.BuyForce then
    time = self.m_userDetail.vipProto.force_change_num
  elseif buyType == td.UIModule.BuyStamina then
    time = self.m_userDetail.vipProto.vit_change_num
  end
  return time or 0
end
function UserDataManager:UpdateBuyTimes(buyType)
  if buyType == td.UIModule.BuyGold then
    self.m_userDetail.vipProto.gold_change_num = self.m_userDetail.vipProto.gold_change_num - 1
  elseif buyType == td.UIModule.BuyForce then
    self.m_userDetail.vipProto.force_change_num = self.m_userDetail.vipProto.force_change_num - 1
  elseif buyType == td.UIModule.BuyStamina then
    self.m_userDetail.vipProto.vit_change_num = self.m_userDetail.vipProto.vit_change_num - 1
  end
end
function UserDataManager:GetStoreRefreshTimes()
  return self.m_userDetail.vipProto.store_refresh
end
function UserDataManager:UpdateStoreRefreshTimes()
  self.m_userDetail.vipProto.store_refresh = self.m_userDetail.vipProto.store_refresh - 1
end
function UserDataManager:UpdateGoldDrawTime(time)
  self.m_userDetail.gold_time = time
end
function UserDataManager:UpdateDiamondDrawTime(time)
  self.m_userDetail.diamond_time = time
end
function UserDataManager:IsFirstCharge(chargeId)
  if table.indexof(self.m_userDetail.money_type, chargeId) then
    return false
  end
  return true
end
function UserDataManager:UpdateFirstCharge(chargeId)
  table.insert(self.m_userDetail.money_type, chargeId)
end
function UserDataManager:DidGetFirstChargeGift()
  local vCheckChargeId = {
    2,
    3,
    4,
    5
  }
  for i, chargeId in ipairs(vCheckChargeId) do
    if not self:IsFirstCharge(chargeId) then
      return true
    end
  end
  return false
end
function UserDataManager:GetTotalCharge()
  return self.m_userDetail.vipProto.diamond
end
function UserDataManager:UpdateTotalCharge(num)
  self.m_userDetail.vipProto.diamond = self.m_userDetail.vipProto.diamond + num
  local ciMng = require("app.info.CommonInfoManager"):GetInstance()
  local nextVipLevel = ciMng:GetVipByCharge(self.m_userDetail.vipProto.diamond)
  if nextVipLevel > self.m_userDetail.vipProto.level then
    local nextVipInfo = ciMng:GetVipInfo(nextVipLevel)
    self.m_userDetail.vipProto.gold_change_num = nextVipInfo.gold_numbers
    self.m_userDetail.vipProto.force_change_num = nextVipInfo.gold_numbers
    self.m_userDetail.vipProto.vit_change_num = nextVipInfo.vit_numbers
    self.m_userDetail.vipProto.sign_num = nextVipInfo.sign_in
    self.m_userDetail.vipProto.vice1 = nextVipInfo.dungeon
    self.m_userDetail.vipProto.vice2 = nextVipInfo.dungeon
    self.m_userDetail.vipProto.vice3 = nextVipInfo.dungeon
    self.m_userDetail.vipProto.vice4 = nextVipInfo.dungeon
    self.m_userDetail.vipProto.vice5 = nextVipInfo.dungeon
    self.m_userDetail.vipProto.vice_num1 = nextVipInfo.dungeon_numbers
    self.m_userDetail.vipProto.vice_num2 = nextVipInfo.dungeon_numbers
    self.m_userDetail.vipProto.vice_num3 = nextVipInfo.dungeon_numbers
    self.m_userDetail.vipProto.vice_num4 = nextVipInfo.dungeon_numbers
    self.m_userDetail.vipProto.vice_num5 = nextVipInfo.dungeon_numbers
    require("app.info.MissionInfoManager"):GetInstance():SendGetCityRequest()
  end
  self.m_userDetail.vipProto.level = nextVipLevel
  td.dispatchEvent(td.TOTAL_CHARGE_CHANGE)
end
function UserDataManager:GetResignTime()
  return self.m_userDetail.vipProto.sign_num or 0
end
function UserDataManager:UpdateResignTime()
  self.m_userDetail.vipProto.sign_num = self.m_userDetail.vipProto.sign_num - 1
end
function UserDataManager:GetRobTime()
  return self.m_userDetail.plunder or 0
end
function UserDataManager:UpdateRobTime()
  self.m_userDetail.plunder = self.m_userDetail.plunder + 1
end
function UserDataManager:GetArenaRank()
  return self.m_userDetail.arena_rank
end
function UserDataManager:GetTrialData()
  if not self.m_trialData then
    self.m_trialData = require("app.data.TrialData").new()
  end
  return self.m_trialData
end
function UserDataManager:GetOnlineAwardTime()
  if self.m_userDetail.onlineRewardTime == 0 then
    self.m_userDetail.onlineRewardTime = self:GetServerTime()
  end
  return self.m_userDetail.onlineRewardTime
end
function UserDataManager:UpdateOnlineAwardTime()
  self.m_userDetail.onlineRewardTime = self:GetServerTime()
end
function UserDataManager:GetAllItem()
  return self.m_vItems
end
function UserDataManager:GetItemNum(itemId)
  local num = 0
  if itemId == td.ItemID_Exp then
    num = self:GetExp()
  elseif itemId == td.ItemID_Gold then
    num = self:GetGold()
  elseif itemId == td.ItemID_Diamond then
    num = self:GetDiamond()
  elseif itemId == td.ItemID_Stamina then
    num = self:GetStamina()
  elseif itemId > 80000 then
    num = self:GetGemNum(itemId)
  else
    num = self.m_vItems[itemId].num
  end
  return num
end
function UserDataManager:GetTotalPower()
  if not self.m_userData.power then
    self:UpdateTotalPower()
  end
  return self.m_userData.power
end
function UserDataManager:UpdateTotalPower()
  local oriPower = self.m_userData.power
  self.m_userData.power = require("app.info.StrongInfoManager"):GetInstance():CalculationTotalPower()
  if oriPower and oriPower ~= self.m_userData.power then
    require("app.layers.InformationManager"):GetInstance():ShowPowerUp(oriPower, self.m_userData.power)
  end
end
function UserDataManager:UpdatePortrait(id)
  self.m_userDetail.image_id = id
end
function UserDataManager:GetPortrait()
  return self.m_userDetail.image_id
end
function UserDataManager:UpdateNickname(name)
  self.m_userDetail.nickname = name
  td.dispatchEvent(td.UPDATE_NAME)
end
function UserDataManager:GetNickname()
  local name, bNamed
  if self.m_userDetail.nickname and self.m_userDetail.nickname ~= "" then
    name, bNamed = self.m_userDetail.nickname, true
  else
    name, bNamed = string.format("NO.%s", self:GetUId()), false
  end
  return name, bNamed
end
function UserDataManager:GetReputation()
  return self.m_userDetail.reputation
end
function UserDataManager:UpdateAssist(_friendId, _itemId)
  if self.m_userDetail.gift ~= 0 then
    self.m_userDetail.friend_name[_friendId] = 1
  end
  self.assistedMsg[_friendId] = {itemId = _itemId, bNew = true}
  td.dispatchEvent(td.UPDATE_ASSIST)
end
function UserDataManager:UpdateAssistItem(id)
  self.m_userDetail.gift = id
  self.assistedMsg = {}
  td.dispatchEvent(td.UPDATE_ASSIST)
end
function UserDataManager:GetAssistMsg()
  return self.assistedMsg
end
function UserDataManager:PublicGain(wealthType, data)
  if td.WealthType.GOLD == wealthType then
    self.m_userDetail.gold = self.m_userDetail.gold + data
  elseif td.WealthType.EXP == wealthType then
    self.m_userDetail.campExp = self.m_userDetail.campExp + data
  elseif td.WealthType.DIAMOND == wealthType then
    self.m_userDetail.diamond = self.m_userDetail.diamond + data
  elseif td.WealthType.STAMINA == wealthType then
    self.m_userDetail.stamina = self.m_userDetail.stamina + data
  elseif td.WealthType.REPUTATION == wealthType then
    self.m_userDetail.reputation = self.m_userDetail.reputation + data
  elseif td.WealthType.ITEM == wealthType then
    local itemId = data.id
    local itemCnt = data.cnt
    if data.id == 20000 then
      self.m_userDetail.campExp = self.m_userDetail.campExp + itemCnt
    elseif data.id == 20001 then
      self.m_userDetail.gold = self.m_userDetail.gold + itemCnt
    elseif data.id == 20002 then
      self.m_userDetail.reputation = self.m_userDetail.reputation + itemCnt
    elseif data.id == 50000 then
      self.m_userDetail.diamond = self.m_userDetail.diamond + itemCnt
    else
      self.m_vItems[itemId].num = self.m_vItems[itemId].num + itemCnt
    end
  end
  td.dispatchEvent(td.USERWEALTH_CHANGED)
end
function UserDataManager:PublicConsume(wealthType, data)
  local errorCode = td.ErrorCode.SUCCESS
  if td.WealthType.GOLD == wealthType then
    if data > self.m_userDetail.gold then
      errorCode = td.ErrorCode.GOLD_NOT_ENOUGH
    else
      self.m_userDetail.gold = self.m_userDetail.gold - data
    end
  elseif td.WealthType.DIAMOND == wealthType then
    if data > self.m_userDetail.diamond then
      errorCode = td.ErrorCode.ENERGY_NOT_ENOUGH
    else
      self.m_userDetail.diamond = self.m_userDetail.diamond - data
    end
  elseif td.WealthType.EXP == wealthType then
    if data > self.m_userDetail.campExp then
      errorCode = td.ErrorCode.EXP_NOT_ENOUGH
    else
      self.m_userDetail.campExp = self.m_userDetail.campExp - data
    end
  elseif td.WealthType.STAMINA == wealthType then
    if data > self.m_userDetail.stamina then
      errorCode = td.ErrorCode.TL_NOT_ENOUGH
    else
      self.m_userDetail.stamina = self.m_userDetail.stamina - data
    end
  elseif td.WealthType.ITEM == wealthType then
    local itemId = data.id
    local itemCnt = data.cnt
    if not itemCnt or self.m_vItems[itemId] == nil or itemCnt > self.m_vItems[itemId].num then
      errorCode = td.ErrorCode.MATERIAL_NOT_ENOUGH
    else
      self.m_vItems[itemId].num = self.m_vItems[itemId].num - itemCnt
    end
  end
  if td.ErrorCode.SUCCESS == errorCode then
    td.dispatchEvent(td.USERWEALTH_CHANGED)
    return true, errorCode
  end
  return false, errorCode
end
function UserDataManager:setServerTime(sTime)
  local lTime = math.floor(socket.gettime())
  self.m_timeDiff = sTime - lTime
end
function UserDataManager:GetServerTime()
  local lTime = math.floor(socket.gettime())
  return lTime + self.m_timeDiff
end
function UserDataManager:setServerTimeMil(sTime)
  local lTime = socket.gettime() * 1000
  self.m_timeDiffMil = sTime - lTime
end
function UserDataManager:GetServerTimeMil()
  local lTime = socket.gettime() * 1000
  return lTime + self.m_timeDiffMil
end
function UserDataManager:GetMaxPopu(missionType)
  local popu = 0
  if missionType == td.MapType.PVP or missionType == td.MapType.PVPGuild or missionType == td.MapType.Trial then
    local baseInfo = require("app.info.BaseInfoManager"):GetInstance():GetBaseInfo(self.m_userDetail.arena_level)
    popu = baseInfo.arena_resource_max
    local boostValue = self:GetBoostValue(td.BoostType.ArenaPopu)
    popu = popu + boostValue
  else
    local baseInfo = require("app.info.BaseInfoManager"):GetInstance():GetBaseInfo(self.m_userDetail.mission_level)
    popu = baseInfo.init_force
    local boostValue = self:GetBoostValue(td.BoostType.MissionPopu)
    popu = popu + boostValue
  end
  return popu
end
function UserDataManager:SetSelfPVPData(arenaProto)
  if arenaProto then
    local StrongInfoManager = require("app.info.StrongInfoManager")
    local selfData = {}
    selfData.rank = self.m_PVPData.selfData and self.m_PVPData.selfData.next_rank or arenaProto.rank
    selfData.next_rank = arenaProto.rank
    selfData.max_rank = arenaProto.max_rank
    selfData.hero_item = {}
    if arenaProto.hero_item ~= "" then
      local tmp = string.split(arenaProto.hero_item, ";")
      for i, v in ipairs(tmp) do
        local t1 = string.split(v, ":")
        table.insert(selfData.hero_item, {
          id = tonumber(t1[1]),
          x = tonumber(t1[2]),
          y = tonumber(t1[3])
        })
      end
    end
    selfData.soldier_item = {}
    if arenaProto.soldier_item ~= "" then
      local tmp = string.split(arenaProto.soldier_item, ";")
      for i, v in ipairs(tmp) do
        local t1 = string.split(v, ":")
        table.insert(selfData.soldier_item, {
          id = tonumber(t1[1]),
          x = tonumber(t1[2]),
          y = tonumber(t1[3])
        })
      end
    end
    self.m_PVPData.selfData = selfData
  else
    td.alertDebug("error\239\188\154\231\142\169\229\174\182\231\171\158\230\138\128\229\156\186\228\191\161\230\129\175\228\184\186\231\169\186")
  end
end
function UserDataManager:SetEnemyPVPData(otherArena, bIsFriend)
  if otherArena then
    local StrongInfoManager = require("app.info.StrongInfoManager")
    self.m_PVPData.otherDatas = self.m_PVPData.otherDatas or {}
    otherArena = {otherArena}
    for i, v in ipairs(otherArena) do
      local otherData = {}
      otherData.reputation = v.reputation
      local vGuildSkill = {}
      if v.guildSkill then
        for j, var in ipairs(v.guildSkill) do
          local guildSkill = {
            id = var.id,
            level = var.level
          }
          vGuildSkill[guildSkill.id] = guildSkill
        end
      end
      otherData.boostData = require("app.data.BoostData").new(vGuildSkill)
      local SkillInfoManager = require("app.info.SkillInfoManager")
      otherData.skills = {}
      if v.skillProto then
        for j, var in ipairs(v.skillProto) do
          local skillData = SkillInfoManager:GetInstance():MakeSkillData(var, true, otherData.boostData)
          otherData.skills[skillData.id] = skillData
        end
      end
      local siMng = require("app.info.StrongInfoManager"):GetInstance()
      otherData.weapons = {}
      if v.weapons then
        for j, var in ipairs(v.weapons) do
          local weaponData = siMng:MakeWeaponData(var)
          otherData.weapons[weaponData.id] = weaponData
        end
      end
      otherData.heros = {}
      otherData.hero_item = {}
      if v.heros then
        for j, var in ipairs(v.heros) do
          local heroData = siMng:MakeHeroData(var, otherData.boostData)
          otherData.heros[heroData.hid] = heroData
          table.insert(otherData.hero_item, {
            id = var.hid,
            x = var.x,
            y = var.y
          })
        end
      end
      otherData.soldiers = {}
      if v.arenaRoleProto then
        for j, var in ipairs(v.arenaRoleProto) do
          local soldierData = siMng:MakeSoldierData(var, otherData.boostData)
          otherData.soldiers[soldierData.role_id] = soldierData
        end
      end
      otherData.soldier_item = {}
      if v.soldier_item == "" and #otherData.hero_item == 0 then
        v.soldier_item = require("app.config.pvp_config")
      end
      if v.soldier_item ~= "" then
        local tmp = string.split(v.soldier_item, ";")
        for i, v in ipairs(tmp) do
          local t1 = string.split(v, ":")
          table.insert(otherData.soldier_item, {
            id = tonumber(t1[1]),
            x = tonumber(t1[2]),
            y = tonumber(t1[3])
          })
        end
      end
      self.m_PVPData.otherDatas[v.uid] = otherData
    end
  end
end
function UserDataManager:GetPVPData()
  return self.m_PVPData
end
function UserDataManager:GetTaskData()
  return self.m_taskDatas
end
function UserDataManager:CheckLivenessReward(index)
  if self:IsLivenessReceived(index) then
    return false
  end
  if not td.AwardLiveness[index] or self:GetLiveness() < td.AwardLiveness[index] then
    return false
  end
  return true
end
function UserDataManager:ReceiveTaskReward(taskId)
  for taskType, tasks in pairs(self.m_taskDatas) do
    for i, var in ipairs(tasks) do
      if var.tid == taskId then
        var.state = td.TaskState.Received
        for itemId, num in pairs(var.taskInfo.awardTab) do
          if itemId == td.ItemID_Stamina then
            self:PublicGain(td.WealthType.STAMINA, num)
          end
        end
        break
      end
    end
  end
end
function UserDataManager:GetUserLog(id, from, to)
  for i, var in ipairs(self.m_vLog) do
    if var.id == id and var.from == from and var.to == to then
      return var.sum
    end
  end
  return 0
end
function UserDataManager:UpdateUserLog(_sum, _id, _from, _to)
  if _from and _to then
    for i, var in ipairs(self.m_vLog) do
      if var.id == _id and var.from == _from and var.to == _to then
        var.sum = var.sum + _sum
        return
      end
    end
    local log = {
      sum = _sum,
      id = _id,
      from = _from,
      to = _to
    }
    table.insert(self.m_vLog, log)
  else
    local serverTime = self:GetServerTime()
    for i, var in ipairs(self.m_vLog) do
      if var.id == _id and serverTime >= var.from and serverTime <= var.to then
        var.sum = var.sum + _sum
      end
    end
  end
end
function UserDataManager:SendTaskRewardRequest(taskId)
  local Msg = {}
  Msg.msgType = td.RequestID.GetTaskAward_req
  Msg.sendData = {tid = taskId}
  Msg.cbData = {tid = taskId}
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:TaskRewardCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    self:ReceiveTaskReward(cbData.tid)
    local taskInfo = require("app.info.TaskInfoManager"):GetInstance():GetTaskInfo(cbData.tid)
    td.alertDebug("TaskRewardCallback tid:" .. cbData.tid .. ",type:" .. taskInfo.type)
    require("app.layers.InformationManager"):GetInstance():ShowInfoDlg({
      type = td.ShowInfo.Item,
      items = taskInfo.awardTab
    })
    self:SendTaskRequest(taskInfo.type)
    td.dispatchEvent(td.TASK_REWARD)
  end
end
function UserDataManager:GetAchieveData()
  return self.m_achieveDatas
end
function UserDataManager:UpdateAchieveState(achiveId)
  local achiveInfo = require("app.info.AchievementInfo"):GetInstance():GetInfo(achiveId)
  if not achiveInfo then
    return
  end
  local vec = self.m_achieveDatas[achiveInfo.type][td.AchievementState.Incomplete]
  for i, var in ipairs(vec) do
    if var.id == achiveId then
      var.receive = td.AchievementState.Complete
      table.insert(self.m_achieveDatas[achiveInfo.type][td.AchievementState.Complete], var)
      table.remove(vec, i)
      return
    end
  end
  vec = self.m_achieveDatas[achiveInfo.type][td.AchievementState.Complete]
  for i, var in ipairs(vec) do
    if var.id == achiveId then
      var.receive = td.AchievementState.Received
      table.insert(self.m_achieveDatas[achiveInfo.type][td.AchievementState.Received], var)
      table.remove(vec, i)
      return
    end
  end
end
function UserDataManager:UpdateAchieve(achiveData)
  local achiveId = achiveData.id
  local achiveInfo = require("app.info.AchievementInfo"):GetInstance():GetInfo(achiveId)
  if not achiveInfo then
    return
  end
  for key, vec in pairs(self.m_achieveDatas[achiveInfo.type]) do
    for i, var in ipairs(vec) do
      if var.id == achiveId then
        table.insert(self.m_achieveDatas[achiveInfo.type][achiveData.receive], achiveData)
        table.remove(vec, i)
        return
      end
    end
  end
end
function UserDataManager:IsAchieveReached(achiveId)
  for type, var in pairs(self.m_achieveDatas) do
    for i, v in ipairs(var[td.AchievementState.Incomplete]) do
      if v.id == achiveId then
        return false
      end
    end
  end
  return true
end
function UserDataManager:GetRankListData()
  return self.m_rankListData
end
function UserDataManager:UpdateRankListData(data, rankType)
  local sortFunc
  if rankType == td.RankType.Arena then
    function sortFunc(a, b)
      return a.myrank < b.myrank
    end
  elseif rankType == td.RankType.Endless then
    function sortFunc(a, b)
      return a.max_wave > b.max_wave
    end
  else
    function sortFunc(a, b)
      return a.attack > b.attack
    end
  end
  table.sort(data, sortFunc)
  self.m_rankListData[rankType] = data
  for key, val in ipairs(data) do
    if val.uid == self:GetUId() then
      self.m_myRank[rankType] = key
    end
  end
end
function UserDataManager:GetMyRank(rankType)
  return self.m_myRank[rankType] or 0
end
function UserDataManager:GetFriendData()
  return self.m_friendDatas
end
function UserDataManager:CheckIsFriend(uid)
  if self.m_friendDatas[td.FriendType.Mine][uid] then
    return true
  end
  return false
end
function UserDataManager:AddFriendData(id, addType)
  addType = addType or td.FriendType.Mine
  local friendTypes = {
    td.FriendType.Recommend,
    td.FriendType.Search,
    td.FriendType.Apply,
    td.FriendType.Mine,
    td.FriendType.Applyed
  }
  table.removebyvalue(friendTypes, addType)
  if self.m_friendDatas[addType][id] then
    return
  end
  local fData
  for i, friendType in ipairs(friendTypes) do
    if self.m_friendDatas[friendType] and self.m_friendDatas[friendType][id] then
      fData = self.m_friendDatas[friendType][id]
      self.m_friendDatas[friendType][id] = nil
    end
  end
  if fData then
    self.m_friendDatas[addType] = self.m_friendDatas[addType] or {}
    self.m_friendDatas[addType][id] = fData
  end
  return self.m_friendDatas
end
function UserDataManager:DeleteFriendData(id)
  local friendTypes = {
    td.FriendType.Mine,
    td.FriendType.Apply
  }
  for j, _type in ipairs(friendTypes) do
    if self.m_friendDatas[_type] then
      self.m_friendDatas[_type][id] = nil
    end
  end
  return self.m_friendDatas
end
function UserDataManager:SetSearchFriendData(data)
  self.m_friendDatas[td.FriendType.Search] = {}
  for i, var in ipairs(data) do
    self.m_friendDatas[td.FriendType.Search][var.fid] = var
  end
end
function UserDataManager:AddOtherData(data)
  self.m_otherUserDatas[data.fid] = data
end
function UserDataManager:GetOtherData(id)
  return self.m_otherUserDatas[id]
end
function UserDataManager:GetFinishedGuide()
  return self.m_userDetail.guide
end
function UserDataManager:UpdateFinishedGuide(id)
  if not table.indexof(self.m_userDetail.guide, id) then
    table.insert(self.m_userDetail.guide, id)
  end
end
function UserDataManager:InitCityData(vMissionAwardProto)
  self.m_vCitiesData = {}
  self.m_cityProfits = {
    [td.ItemID_Gold] = {
      lastTime = 0,
      remain = 0,
      speed = 0
    },
    [td.ItemID_Force] = {
      lastTime = 0,
      remain = 0,
      speed = 0
    }
  }
  for i, var in ipairs(vMissionAwardProto) do
    if self.m_cityProfits[var.item_id] then
      self.m_cityProfits[var.item_id].lastTime = var.time
      self.m_cityProfits[var.item_id].remain = var.num
    end
  end
end
function UserDataManager:UpdateCityData(data)
  self.m_vCitiesData[data.missionId] = data
  if not self.m_vCitiesData[data.missionId].num then
    self.m_vCitiesData[data.missionId].num = 10
    local vipInfo = require("app.info.CommonInfoManager"):GetInstance():GetVipInfo(self.m_userDetail.vipProto.level)
    self.m_vCitiesData[data.missionId].buy_num = vipInfo.mission_purchase
  end
end
function UserDataManager:UpdateCityState(data)
  if self.m_vCitiesData[data.missionId] then
    self.m_vCitiesData[data.missionId].occupation = data.occupation
  end
end
function UserDataManager:UpdateCityStar(data)
  if self.m_vCitiesData[data.missionId] and data.star then
    for k, var in pairs(data.star) do
      if var == 1 then
        self.m_vCitiesData[data.missionId].star[k] = 1
      end
    end
  end
end
function UserDataManager:GetAllCitiesData()
  return self.m_vCitiesData
end
function UserDataManager:GetCityData(key)
  return self.m_vCitiesData[key]
end
function UserDataManager:UpdateProfitTime(itemId, t)
  self.m_cityProfits[itemId].lastTime = t
end
function UserDataManager:UpdateRestProfit(itemId, num)
  self.m_cityProfits[itemId].num = num
end
function UserDataManager:UpdateProfitSpeed(itemId, speed)
  self.m_cityProfits[itemId].speed = speed
end
function UserDataManager:GetProfitData(itemId)
  if itemId then
    return self.m_cityProfits[itemId]
  end
  return self.m_cityProfits
end
function UserDataManager:SetProfitLock(id, bIsLock)
  if bIsLock then
    self.m_userDetail.plunder_item = id
  else
    self.m_userDetail.plunder_item = nil
  end
end
function UserDataManager:IsProfitLock(id)
  if self.m_userDetail.plunder_item == id then
    local serverTime = self:GetServerTime()
    if self.m_userDetail.plunder_time ~= 0 then
      local timeGap = serverTime - self.m_userDetail.plunder_time
      if timeGap >= 240 then
        self.m_userDetail.plunder_item = nil
        self.m_userDetail.plunder_time = 0
        return false
      end
    end
    return true
  end
  return false
end
function UserDataManager:UpdateBeRobedTime(bIsReset)
  if bIsReset then
    self.m_userDetail.plunder_item = 0
  elseif self.m_userDetail.plunder_item == 0 then
    self.m_userDetail.plunder_time = self:GetServerTime()
  end
end
function UserDataManager:GetDungeonTime(type)
  if type == td.UIModule.Rob then
    return self.m_userDetail.vipProto.vice1
  elseif type == td.UIModule.Trial then
    return self.m_userDetail.vipProto.vice2
  elseif type == td.UIModule.Endless then
    return self.m_userDetail.vipProto.vice3
  elseif type == td.UIModule.Collect then
    return self.m_userDetail.vipProto.vice4
  elseif type == td.UIModule.Bombard then
    return self.m_userDetail.vipProto.vice5
  end
  return 0
end
function UserDataManager:UpdateDungeonTime(type, addTime)
  if type == td.UIModule.Rob then
    self.m_userDetail.vipProto.vice1 = self.m_userDetail.vipProto.vice1 + addTime
  elseif type == td.UIModule.Trial then
    self.m_userDetail.vipProto.vice2 = self.m_userDetail.vipProto.vice2 + addTime
  elseif type == td.UIModule.Endless then
    self.m_userDetail.vipProto.vice3 = self.m_userDetail.vipProto.vice3 + addTime
  elseif type == td.UIModule.Collect then
    self.m_userDetail.vipProto.vice4 = self.m_userDetail.vipProto.vice4 + addTime
  elseif type == td.UIModule.Bombard then
    self.m_userDetail.vipProto.vice5 = self.m_userDetail.vipProto.vice5 + addTime
  end
end
function UserDataManager:GetDungeonBuyTime(type)
  if type == td.UIModule.Rob then
    return self.m_userDetail.vipProto.vice_num1
  elseif type == td.UIModule.Trial then
    return self.m_userDetail.vipProto.vice_num2
  elseif type == td.UIModule.Endless then
    return self.m_userDetail.vipProto.vice_num3
  elseif type == td.UIModule.Collect then
    return self.m_userDetail.vipProto.vice_num4
  elseif type == td.UIModule.Bombard then
    return self.m_userDetail.vipProto.vice_num5
  end
  return 0
end
function UserDataManager:UpdateDungeonBuyTime(type, addTime)
  if type == td.UIModule.Rob then
    self.m_userDetail.vipProto.vice_num1 = self.m_userDetail.vipProto.vice_num1 + addTime
  elseif type == td.UIModule.Trial then
    self.m_userDetail.vipProto.vice_num2 = self.m_userDetail.vipProto.vice_num2 + addTime
  elseif type == td.UIModule.Endless then
    self.m_userDetail.vipProto.vice_num3 = self.m_userDetail.vipProto.vice_num3 + addTime
  elseif type == td.UIModule.Collect then
    self.m_userDetail.vipProto.vice_num4 = self.m_userDetail.vipProto.vice_num4 + addTime
  elseif type == td.UIModule.Bombard then
    self.m_userDetail.vipProto.vice_num5 = self.m_userDetail.vipProto.vice_num5 + addTime
  end
end
function UserDataManager:UpdateHeroLevelOrStar(id, totalExp)
  local heroData = self.m_heroDatas[id]
  local maxLevel = heroData.star * 10
  if heroData.level == heroData.star * 10 then
    heroData.star = heroData.star + 1
  else
    totalExp = totalExp + heroData.exp
    local addLevel = 0
    local upExp = td.CalHeroExp(heroData.level)
    while totalExp >= upExp do
      addLevel = addLevel + 1
      totalExp = totalExp - upExp
      upExp = td.CalHeroExp(heroData.level + addLevel)
    end
    heroData.level = cc.clampf(heroData.level + addLevel, 1, maxLevel)
    heroData.exp = totalExp
  end
end
function UserDataManager:UpdateHeroData(data)
  local siMng = require("app.info.StrongInfoManager"):GetInstance()
  local heroData = siMng:MakeHeroData(data, self.m_boostData)
  self.m_heroDatas[heroData.id] = heroData
  self:UpdateTotalPower()
end
function UserDataManager:GetHeroData(id)
  if id then
    return self.m_heroDatas[id]
  end
  return self.m_heroDatas
end
function UserDataManager:UpdateHeroSkill(heroId, index, skillUid)
  if index >= 1 and index <= 3 then
    self.m_heroDatas[heroId].passiveSkill[index] = skillUid
  elseif index >= 4 and index <= 5 then
    self.m_heroDatas[heroId].activeSkill[index - 3] = skillUid
  end
  self:UpdateTotalPower()
end
function UserDataManager:UpdatePlunderHero(heroList)
  local heroData = self:GetHeroData()
  local heroList = heroList
  for key, val in pairs(heroData) do
    val.plunder_battle = 0
  end
  for key, val in pairs(heroData) do
    for key, id in ipairs(heroList) do
      if val.hid == id then
        val.plunder_battle = key
      end
    end
  end
end
function UserDataManager:DeleteWeaponData(id)
  self.m_vWeaponData[id] = nil
  td.dispatchEvent(td.WEAPON_UPDATE)
end
function UserDataManager:UpdateWeaponData(data)
  local siMng = require("app.info.StrongInfoManager"):GetInstance()
  local weaponData = siMng:MakeWeaponData(data)
  self.m_vWeaponData[weaponData.id] = weaponData
  self:UpdateTotalPower()
end
function UserDataManager:GetWeaponData(id)
  if id then
    return self.m_vWeaponData[id]
  end
  return self.m_vWeaponData
end
function UserDataManager:GetIdleWeapons(career, type)
  local vWeapons = {}
  for key, var in pairs(self.m_vWeaponData) do
    if var.hero_id == 0 and (career == nil or var.weaponInfo.career == career) and (type == nil or var.weaponInfo.type == type) then
      table.insert(vWeapons, var)
    end
  end
  return vWeapons
end
function UserDataManager:DeleteGemData(id)
  self.m_vGemData[id] = nil
end
function UserDataManager:UpdateGemData(data)
  local siMng = require("app.info.StrongInfoManager"):GetInstance()
  local gemData = siMng:MakeGemData(data)
  self.m_vGemData[gemData.id] = gemData
end
function UserDataManager:GetGemData(id)
  if id then
    return self.m_vGemData[id]
  end
  return self.m_vGemData
end
function UserDataManager:GetIdleGems(type)
  local stiMng = require("app.info.StrongInfoManager"):GetInstance()
  local tmp = {}
  for key, var in pairs(self.m_vGemData) do
    if var.hero_id == 0 and (type == nil or var.type == type) then
      if tmp[var.gemstoneId] then
        tmp[var.gemstoneId].num = tmp[var.gemstoneId].num + 1
      else
        local gemInfo = stiMng:GetGemInfo(var.gemstoneId)
        tmp[var.gemstoneId] = {
          itemId = var.gemstoneId,
          num = 1,
          quality = gemInfo.quality,
          type = gemInfo.type
        }
      end
    end
  end
  local vGems = {}
  for key, var in pairs(tmp) do
    table.insert(vGems, var)
  end
  return vGems
end
function UserDataManager:GetCostGemUid(targetId, quantity)
  local vCostGemUid = {}
  local count = 0
  for uid, gemData in pairs(self.m_vGemData) do
    if gemData.hero_id == 0 and gemData.gemstoneId == targetId then
      table.insert(vCostGemUid, uid)
      count = count + 1
      if quantity <= count then
        break
      end
    end
  end
  return vCostGemUid
end
function UserDataManager:GetGemNum(gemId)
  local num = 0
  for key, var in pairs(self.m_vGemData) do
    if var.hero_id == 0 and var.gemstoneId == gemId then
      num = num + 1
    end
  end
  return num
end
function UserDataManager:GetMailsData()
  return self.m_vMailsData
end
function UserDataManager:SetItemNew(itemid, bNew)
  if self.m_vItems[itemid] then
    self.m_vItems[itemid].bNew = bNew
  end
end
function UserDataManager:GetSignInDay(bMonth)
  if bMonth then
    return self.m_userDetail.sign_moth
  end
  return self.m_userDetail.sign_day
end
function UserDataManager:UpdateSignInDay(bMonth)
  if bMonth then
    self.m_userDetail.sign_moth = self.m_userDetail.sign_moth + 1
  elseif self.m_userDetail.sign_day < 7 then
    self.m_userDetail.sign_day = self.m_userDetail.sign_day + 1
  end
end
function UserDataManager:GetSignInTime(bMonth)
  if bMonth then
    return self.m_userDetail.sign_moth_time
  end
  return self.m_userDetail.sign_time
end
function UserDataManager:UpdateSignInTime(bMonth)
  if bMonth then
    self.m_userDetail.sign_moth_time = self:GetServerTime()
  else
    self.m_userDetail.sign_time = self:GetServerTime()
  end
end
function UserDataManager:InitGuildSkills(skillsProto)
  self.m_vGuildSkillsData = {}
  for i, var in ipairs(skillsProto) do
    local guildSkill = {
      id = var.id,
      level = var.level
    }
    self.m_vGuildSkillsData[guildSkill.id] = guildSkill
  end
  self.m_boostData = require("app.data.BoostData").new(self.m_vGuildSkillsData)
end
function UserDataManager:UpdateGuildSkill(_id)
  local guildSkill = self.m_vGuildSkillsData[_id]
  if guildSkill then
    guildSkill.level = guildSkill.level + 1
  else
    guildSkill = {id = _id, level = 1}
    self.m_vGuildSkillsData[_id] = guildSkill
  end
  self.m_boostData:UpdateData(guildSkill)
  local guildSkillInfo = require("app.info.GuildInfoManager"):GetInstance():GetSkillInfo(_id)
  if guildSkillInfo.type == td.BoostType.Soldier then
    local unitMng = require("app.UnitDataManager"):GetInstance()
    local allSoldierData = unitMng:GetSoldierData()
    for key, soldierData in pairs(allSoldierData) do
      unitMng:UpdateSoldierData(soldierData)
    end
  elseif guildSkillInfo.type == td.BoostType.Hero then
    local allHeroData = self:GetHeroData()
    for key, heroData in pairs(allHeroData) do
      self:UpdateHeroData(heroData)
    end
  end
  self:UpdateTotalPower()
end
function UserDataManager:UpdateBaseSkill(type)
  if type == 1 then
    self.m_userDetail.mission_level = self.m_userDetail.mission_level + 1
  else
    self.m_userDetail.arena_level = self.m_userDetail.arena_level + 1
  end
  self:UpdateTotalPower()
end
function UserDataManager:GetGuildSkillLevel(id)
  if not self.m_vGuildSkillsData[id] then
    return 0
  end
  return self.m_vGuildSkillsData[id].level
end
function UserDataManager:GetBoostValue(type, param1, param2)
  return self.m_boostData:GetValue(type, param1, param2)
end
function UserDataManager:GetBoostData()
  return self.m_boostData
end
function UserDataManager:GetVIPData()
  return self.m_userDetail.vipProto
end
function UserDataManager:OnItemsUpdate(items)
  local bShowRp = false
  for k, v in pairs(items) do
    if self.m_vItems[v.itemId] then
      self.m_vItems[v.itemId].num = self.m_vItems[v.itemId].num + v.num
      if v.num > 0 and not self.m_vItems[v.itemId].bHad then
        self.m_vItems[v.itemId].bNew = true
        self.m_vItems[v.itemId].bHad = true
        bShowRp = true
      end
    end
    if v.itemId == td.ItemID_Force then
      td.dispatchEvent(td.USERWEALTH_CHANGED)
    end
  end
  if bShowRp then
    td.dispatchEvent(td.HEART_BEAT, {
      type = td.HBType.Backpack
    })
  end
end
function UserDataManager:SendJoinGameRequest()
  local data = {}
  data.session_id = self:GetSessionId()
  data.account_id = self:GetUId()
  data.platform = pu.GetPlatform()
  local Msg = {}
  Msg.msgType = td.RequestID.JoinGame
  Msg.sendData = data
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:JoinGameResponse(data)
  if data.sysTime ~= td.ResponseState.Fail then
    pu.MobClickFunc(2, self.m_uuid)
    if data.sessionId and self:GetSessionId() == td.ORI_SESSION then
      self:SetSessionId(data.sessionId)
    end
    self.m_userData.name = data.userDetail.nickname
    self.m_userData.uid = self.m_uuid
    self.m_userDetail = data.userDetail
    if not self.m_userDetail.arena_level then
      self.m_userDetail.arena_level = 1
    else
      self.m_userDetail.arena_level = cc.clampf(self.m_userDetail.arena_level, 1, td.MaxLevel)
    end
    if not self.m_userDetail.mission_level then
      self.m_userDetail.mission_level = 1
    else
      self.m_userDetail.mission_level = cc.clampf(self.m_userDetail.mission_level, 1, td.MaxLevel)
    end
    self:InitGuildSkills(self.m_userDetail.guildSkillProto)
    self.m_userDetail.guildSkillProto = nil
    self.assistedMsg = {}
    if self.m_userDetail.friend_name and self.m_userDetail.friend_name ~= "" then
      local ids = string.split(self.m_userDetail.friend_name, ",")
      self.m_userDetail.friend_name = {}
      for i, id in ipairs(ids) do
        self.m_userDetail.friend_name[id] = 1
        self.assistedMsg[id] = {
          itemId = self.m_userDetail.gift,
          bNew = false
        }
      end
    else
      self.m_userDetail.friend_name = {}
    end
    local tmp = self.m_userDetail.money_type
    self.m_userDetail.money_type = {}
    if tmp ~= "" then
      tmp = string.split(tmp, ",")
      for i, var in ipairs(tmp) do
        table.insert(self.m_userDetail.money_type, tonumber(var))
      end
    end
    self:InitAchieveData()
    self:InitLivenessData()
    self:setServerTime(math.floor(data.sysTime / 1000))
    self:setServerTimeMil(data.sysTime)
    self:InitCityData(data.userDetail.award)
    td.dispatchEvent(td.LOGIN_DATA_INITED, 1)
    if self.m_userDetail.c_time and math.abs(self.m_userDetail.c_time - data.sysTime / 1000) < 5 then
      pu.SubmitData(1)
    end
    self.lastCheckStaminaTime = self:GetServerTime()
    self.addStaminaTimer = scheduler.scheduleGlobal(function()
      if self.m_userDetail.stamina < self:GetMaxStamina() then
        local curTime = self:GetServerTime()
        if curTime - self.lastCheckStaminaTime >= 360 then
          self:PublicGain(td.WealthType.STAMINA, 1)
        end
      end
      self.lastCheckStaminaTime = self:GetServerTime()
    end, 360)
  else
    td.dispatchEvent(td.LOGIN_DATA_INITED, 0)
  end
end
function UserDataManager:SendUpdateUserRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.UpdateUser_req
  Msg.sendData = nil
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:UpdateUserDetailCallback(data)
  if data then
    if data.diamond then
      local oriDiamond = self.m_userDetail.diamond
      self.m_userDetail.diamond = data.diamond
      if oriDiamond - self.m_userDetail.diamond > 0 then
        self:UpdateUserLog(oriDiamond - self.m_userDetail.diamond, td.ItemID_Diamond)
      end
    end
    self.m_userDetail.gold = data.gold or self.m_userDetail.gold
    self.m_userDetail.liveness = data.liveness or self.m_userDetail.liveness
    local ciMng = require("app.info.CommanderInfoManager"):GetInstance()
    local oldHonor = ciMng:GetHonorInfoByRepu(self.m_userDetail.reputation)
    self.m_userDetail.reputation = data.reputation or self.m_userDetail.reputation
    local newHonor = ciMng:GetHonorInfoByRepu(self.m_userDetail.reputation)
    if newHonor.id ~= oldHonor.id then
      require("app.layers.InformationManager"):GetInstance():ShowInfoDlg({
        type = td.ShowInfo.Honor,
        id = newHonor.id
      })
      td.dispatchEvent(td.UPDATE_PROFIT)
    end
    td.dispatchEvent(td.USERWEALTH_CHANGED)
  end
end
function UserDataManager:SendPackRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetPack
  Msg.sendData = nil
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:GetPackCallback(data)
  if td.ResponseState.Success ~= data.state then
    return
  end
  self.m_vItems = {}
  local vItemsInfo = require("app.info.ItemInfoManager"):GetInstance():GetItemAllInfos()
  for k, value in pairs(vItemsInfo) do
    local data = {}
    data.itemId = k
    data.num = 0
    data.bHad = false
    data.quality = value.quality
    data.bag_type = value.bag_type
    self.m_vItems[k] = data
  end
  for k, v in pairs(data.itemProto) do
    if self.m_vItems[v.itemId] then
      self.m_vItems[v.itemId].num = v.num
      self.m_vItems[v.itemId].bHad = true
    end
  end
  td.dispatchEvent(td.ITEM_UPDATE)
end
function UserDataManager:ItemCallback(data)
  if td.ResponseState.Success == data.state then
    self:OnItemsUpdate(data.itemProto)
    td.dispatchEvent(td.ITEM_UPDATE)
  end
end
function UserDataManager:SendGetSkillsRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetSkillLib
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:GetSkillsCallback(data)
  local SkillInfoManager = require("app.info.SkillInfoManager")
  for i, var in ipairs(data.skillProto) do
    local skillData = SkillInfoManager:GetInstance():MakeSkillData(var, nil, self.m_boostData)
    self.m_vSkillLib[var.id] = skillData
  end
end
function UserDataManager:SendGetWeaponRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetWeapons_req
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:GetWeaponCallback(data)
  for id, var in pairs(data.weaponProto) do
    self:UpdateWeaponData(var)
  end
  td.dispatchEvent(td.WEAPON_UPDATE)
end
function UserDataManager:SendGetGemRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetGems
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:GetGemCallback(data)
  self.m_vGemData = {}
  for id, var in pairs(data.gemstone) do
    self:UpdateGemData(var)
  end
  td.dispatchEvent(td.GEM_UPDATE)
end
function UserDataManager:SendGetHeroRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetHeros_req
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:GetHerosCallback(data)
  for i, var in ipairs(data.heroProtos) do
    self:UpdateHeroData(var)
  end
  td.dispatchEvent(td.HERO_DATA_INITED)
end
function UserDataManager:SendTaskRequest(taskType)
  local data = {type = taskType}
  local Msg = {}
  Msg.msgType = td.RequestID.TaskRequest
  Msg.sendData = data
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:TaskResponseCallback(data)
  local bIsInit = table.nums(self.m_taskDatas) == 0
  local bNewTaskComplete = false
  if data.type == td.TaskType.All then
    self.m_taskDatas[td.TaskType.MainLine] = self.m_taskDatas[td.TaskType.MainLine] or {}
    self.m_taskDatas[td.TaskType.Daily] = self.m_taskDatas[td.TaskType.Daily] or {}
    self.m_taskDatas[td.TaskType.Common] = self.m_taskDatas[td.TaskType.Common] or {}
  else
    self.m_taskDatas[data.type] = self.m_taskDatas[data.type] or {}
  end
  for i, value in ipairs(data.taskProto) do
    local taskId = value.tid
    local taskInfo = require("app.info.TaskInfoManager"):GetInstance():GetTaskInfo(taskId)
    if taskInfo then
      value.taskInfo = taskInfo
      local taskIndex
      for j, taskData in ipairs(self.m_taskDatas[taskInfo.type]) do
        if taskData.tid == value.tid then
          taskIndex = j
          break
        end
      end
      if taskIndex then
        if self.m_taskDatas[taskInfo.type][taskIndex].state ~= td.TaskState.Complete and value.state == td.TaskState.Complete then
          bNewTaskComplete = true
        end
        self.m_taskDatas[taskInfo.type][taskIndex] = value
      else
        table.insert(self.m_taskDatas[taskInfo.type], value)
      end
    end
  end
  td.dispatchEvent(td.TASK_UPDATE, {
    type = data.type
  })
  if bNewTaskComplete and not bIsInit then
    require("app.layers.InformationManager"):GetInstance():ShowTaskComplete()
  end
end
function UserDataManager:SendAchieveRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.Achieventment
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:AchieveResponseCallback(data)
  for k, value in ipairs(data.achieventmentProto) do
    self:UpdateAchieve(value)
  end
end
function UserDataManager:FinishAchieveResponse(data)
  local achiveId = data.error_id
  self:UpdateAchieveState(achiveId)
end
function UserDataManager:SendPokedexRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetCards
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:GetCards(data)
  if not self.m_userData.pokedex then
    self.m_userData.pokedex = {
      [0] = {},
      [1] = {},
      [2] = {},
      [3] = {}
    }
  end
  local pokedex = self.m_userData.pokedex
  for i, v in pairs(data.monsters) do
    pokedex[2][v] = 1
  end
end
function UserDataManager:SendFriendRequest(fType)
  local Msg = {}
  Msg.msgType = fType == td.FriendType.Mine and td.RequestID.GetFriends_req or td.RequestID.RecommendFriends
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:FriendResponseCallback(data)
  self.m_friendDatas[td.FriendType.Mine] = {}
  self.m_friendDatas[td.FriendType.Apply] = {}
  self.m_friendDatas[td.FriendType.Applyed] = {}
  for k, value in ipairs(data.friendProto) do
    if value.type == td.FriendType.Apply then
      self.m_friendDatas[td.FriendType.Apply][value.fid] = value
    elseif value.type == td.FriendType.Applyed then
      self.m_friendDatas[td.FriendType.Applyed][value.fid] = value
    elseif value.type == td.FriendType.Mine then
      self.m_friendDatas[td.FriendType.Mine][value.fid] = value
    end
  end
  td.dispatchEvent(td.FRIEND_DATA_INITED, td.FriendType.Mine)
end
function UserDataManager:RecommendFriendCallback(data)
  self.m_friendDatas[td.FriendType.Recommend] = {}
  for k, value in ipairs(data.friendProto) do
    self.m_friendDatas[td.FriendType.Recommend][value.fid] = value
  end
  td.dispatchEvent(td.FRIEND_DATA_INITED, td.FriendType.Recommend)
end
function UserDataManager:SendAddFriendReq(id)
  if self.m_friendDatas[td.FriendType.Mine][id] then
    td.alert(g_LM:getBy("a00181"))
    return
  end
  if self.m_friendDatas[td.FriendType.Applyed][id] then
    td.alert(g_LM:getBy("a00364"))
    return
  end
  local Msg = {}
  Msg.msgType = td.RequestID.AddFriend_req
  Msg.sendData = {fid = id, type = 0}
  Msg.cbData = {fid = id, type = 0}
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:AddFriendCallback(data, cbData)
  if data.state == td.ResponseState.Success then
    td.alert(g_LM:getBy("a00185"))
    self:AddFriendData(cbData.id, td.FriendType.Applyed)
  end
end
function UserDataManager:SendGetMailsRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetMails_req
  Msg.sendData = nil
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:GetMailsRequestCallback(data)
  self.m_vMailsData = {}
  for k, v in pairs(data.mailProto) do
    table.insert(self.m_vMailsData, v)
  end
  table.sort(self.m_vMailsData, function(a, b)
    return a.time > b.time
  end)
  td.dispatchEvent(td.MAIL_DATA_INITED)
end
function UserDataManager:SendGetPVPDataRequest()
  local Msg = {}
  Msg.msgType = td.RequestID.GetPVPData_req
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:GetPVPDataCallback(data)
  self.m_PVPData.log = data.arengLogs
  table.sort(self.m_PVPData.log, function(a, b)
    return a.time > b.time
  end)
  self.m_PVPData.rivals = data.otherArena
  table.sort(self.m_PVPData.rivals, function(a, b)
    return a.rank < b.rank
  end)
  self:SetSelfPVPData(data.arenaProto)
  td.dispatchEvent(td.ARENA_UPDATE)
end
function UserDataManager:NewSignInResponse(data)
  if data.state == td.ResponseState.Success then
    self:UpdateSignInDay()
    self:UpdateSignInTime()
    td.dispatchEvent(td.NEW_SIGN_IN)
  else
    td.alert(g_LM:getBy("a00323"), true)
  end
end
function UserDataManager:SendGetUserLogRequest(_id, _type, _startTime, _endTime, _cb)
  local Msg = {}
  Msg.msgType = td.RequestID.GetUserLog
  Msg.sendData = {
    item_id = _id,
    type = _type,
    s_time = _startTime,
    e_time = _endTime
  }
  Msg.cbData = {
    item_id = _id,
    type = _type,
    s_time = _startTime,
    e_time = _endTime,
    cb = _cb
  }
  TDHttpRequest:getInstance():Send(Msg)
end
function UserDataManager:GetUserLogResponse(data, cbData)
  self:UpdateUserLog(math.abs(data.num), cbData.item_id, cbData.s_time, cbData.e_time)
  if cbData.cb then
    cbData.cb()
  end
end
function UserDataManager:GetTradeIdRequest(id, _type)
  local platformId = pu.GetPlatform()
  if nil == platformId then
    return
  end
  local function getTradeIdFunc()
    local _uid = self:GetUId()
    local _serverId = self:GetServerData().id
    local sendData = {
      itemId = id,
      type = _type,
      platform = platformId,
      uid = _uid,
      serverId = _serverId
    }
    TDHttpRequest:getInstance():SendNoProto("GetPayId", sendData, function(data)
      self:TradeIdResponse(data, sendData)
    end)
  end
  if "appstore" == platformId then
    local productsData = require("app.info.CommonInfoManager"):GetInstance():GetAllProducts()
    productsData.callback = getTradeIdFunc
    pu.InitIAP(productsData)
  else
    getTradeIdFunc()
  end
end
function UserDataManager:TradeIdResponse(data, cbData)
  local info = require("app.info.CommonInfoManager"):GetInstance():GetChargeInfo(cbData.type, cbData.itemId)
  local payUrl = td.SERVER_URL .. pu.GetPlatform()
  self.m_payInfo = {
    orderId = data.orderId,
    type = cbData.type,
    itemId = cbData.itemId
  }
  local payData = {
    orderId = data.orderId,
    productId = info.product_id,
    url = payUrl,
    sum = tostring(info.value),
    desc = info.name,
    callback = function(receipt)
      self:VerifyReceipt(data.orderId, receipt)
    end
  }
  pu.Pay(payData)
  self.bPayEnd = false
end
function UserDataManager:PaySuccess(orderData, receipt)
  local type, id = orderData.type, orderData.itemId
  local info = require("app.info.CommonInfoManager"):GetInstance():GetChargeInfo(type, id)
  local infoMng = require("app.layers.InformationManager"):GetInstance()
  if type == td.PayType.Charge then
    local time = 1
    if self:IsFirstCharge(id) then
      time = info.first_time
      self:UpdateFirstCharge(id)
    end
    self:PublicGain(td.WealthType.DIAMOND, info.diamond * time)
    infoMng:ShowInfoDlg({
      type = td.ShowInfo.Item,
      items = {
        [td.ItemID_Diamond] = info.diamond * time
      }
    })
    pu.MobClickFunc(4, {
      cash = info.value,
      coin = info.diamond * time
    })
  elseif type == td.PayType.Prop then
    if id == 30 then
      local addDay = self:GetVIPData().month_day == 0 and 29 or 30
      self:GetVIPData().month_day = self:GetVIPData().month_day + addDay
    elseif id == 7 then
      local addDay = self:GetVIPData().week_day == 0 and 6 or 7
      self:GetVIPData().week_day = self:GetVIPData().week_day + addDay
    end
    self:PublicGain(td.WealthType.DIAMOND, info.diamond_give)
    infoMng:ShowInfoDlg({
      type = td.ShowInfo.Item,
      items = {
        [td.ItemID_Diamond] = info.diamond_give
      }
    })
    pu.MobClickFunc(5, {
      cash = info.value,
      item = info.name,
      price = info.value
    })
  else
    pu.MobClickFunc(5, {
      cash = info.value,
      item = info.name,
      price = info.value
    })
    td.alert(g_LM:getBy("a00365"))
    require("app.ActivityDataManager"):GetInstance():UpdateSoldierBagActivity()
    td.dispatchEvent(td.CLOSE_GIFT_PACK)
  end
  self:UpdateTotalCharge(info.value * 10)
  self:UpdateUserLog(info.value * 10, 1)
end
function UserDataManager:VerifyReceipt(orderId, _receipt)
  if not _receipt or _receipt == "" then
    return
  end
  if "appstore" == pu.GetPlatform() then
    local sendData = {payId = orderId, receipt = _receipt}
    TDHttpRequest:getInstance():SendNoProto("IOSServlet", sendData)
  end
end
function UserDataManager:GetSubmitUserData()
  local userData = {}
  userData.ingot = tostring(self:GetDiamond())
  userData.roleCTime = tostring(self:GetRoleCTime())
  userData.playerId = tostring(self:GetUId())
  userData.playerLevel = tostring(self:GetBaseCampLevel())
  userData.playerName = tostring(self:GetNickname())
  userData.experience = tostring(self:GetExp())
  userData.coin = tostring(self:GetGold())
  userData.serverName = tostring(self:GetServerData().name)
  userData.serverId = tostring(self:GetServerData().id)
  userData.vipLevel = tostring(self:GetVipLevel())
  userData.power = tostring(self:GetTotalPower())
  userData.roleSex = tostring(2)
  userData.professionid = tostring(0)
  userData.profession = "\230\151\160"
  userData.friendlist = "\230\151\160"
  local guildData = require("app.GuildDataManager"):GetInstance():GetGuildData()
  if guildData then
    userData.partyid = tostring(guildData.id)
    userData.factionName = guildData.guild_name
    local memberData = require("app.GuildDataManager"):GetInstance():GetMemberData(self:GetUId())
    userData.partyroleid = tostring(memberData.type)
  else
    userData.partyid = "0"
    userData.factionName = "\230\151\160"
    userData.partyroleid = "0"
  end
  userData.partyrolename = "\230\151\160"
  return userData
end
function UserDataManager:IsBaseCanUpgrade(type)
  local userDetail = self:GetUserDetail()
  local campLevel = userDetail.camp
  local currMissionLevel = userDetail.mission_level
  local currArenaLevel = userDetail.arena_level
  local BaseInfoManager = require("app.info.BaseInfoManager")
  local baseCampInfo = BaseInfoManager:GetInstance():GetBaseInfo(campLevel)
  local infoMission = BaseInfoManager:GetInstance():GetBaseInfo(currMissionLevel + 1)
  local infoArena = BaseInfoManager:GetInstance():GetBaseInfo(currArenaLevel + 1)
  local function checkBase()
    if infoMission and currMissionLevel <= campLevel - 1 and infoMission.skill_cost <= self:GetGold() then
      return true
    end
  end
  local function checkArena()
    if infoArena and currArenaLevel <= campLevel - 1 and infoArena.skill_cost <= self:GetGold() then
      return true
    end
  end
  if not type then
    if checkBase() and checkArena() then
      return true
    end
  elseif type == 1 and checkBase() then
    return true
  elseif type == 2 and checkArena() then
    return true
  end
  return false
end
function UserDataManager:IsHeroCanUpgrade(heroId)
  local herosData = self:GetHeroData(heroId)
  if heroId then
    herosData = {herosData}
  end
  local ItemInfoManager = require("app.info.ItemInfoManager")
  local expItems = ItemInfoManager:GetInstance():GetExpItemInfos(1)
  for key, heroData in pairs(herosData) do
    local requiredExp = td.CalHeroExp(heroData.level)
    local exp = 0
    for i, var in ipairs(expItems) do
      local haveNum = self:GetItemNum(var.id)
      local material = {
        itemId = var.id,
        num = haveNum,
        exp = var.quantity
      }
      exp = exp + haveNum * var.quantity
    end
    if requiredExp <= exp + heroData.exp and heroData.level < heroData.star * 10 then
      return true
    end
  end
  return false
end
function UserDataManager:CanEquipNewWeapon(heroId, _weaponType)
  local herosData = self:GetHeroData(heroId)
  if heroId then
    herosData = {herosData}
  end
  local weaponTypes = {}
  if _weaponType then
    weaponTypes = {_weaponType}
  else
    weaponTypes = {
      td.WeaponType.Weapon,
      td.WeaponType.Armor
    }
  end
  for i, weaponType in ipairs(weaponTypes) do
    for key, heroData in pairs(herosData) do
      local weaponId = weaponType == td.WeaponType.Weapon and heroData.attackSite or heroData.defSite
      local curWeapon = self:GetWeaponData(weaponId)
      local allWeapons = self:GetIdleWeapons(heroData.heroInfo.career, weaponType)
      for j, weapon in pairs(allWeapons) do
        if not curWeapon or weapon.weaponInfo.quality > curWeapon.weaponInfo.quality then
          return true
        end
      end
    end
  end
  return false
end
function UserDataManager:CanEquipNewGem(heroId, gemSlotIndex)
  local heroData = self:GetHeroData(heroId)
  if not heroData then
    return false
  end
  if not gemSlotIndex or not {gemSlotIndex} then
    local gemSlots = {
      1,
      2,
      3,
      4
    }
  end
  local allGems = self:GetIdleGems()
  for i, slotIndex in ipairs(gemSlots) do
    local bUnlock = td.IsHeroGemUnlock(heroData.level, slotIndex)
    if bUnlock then
      local gemId = heroData.gems[slotIndex]
      local curGem = self:GetGemData(gemId)
      local gemType = slotIndex % 2 == 1 and td.WeaponType.Weapon or td.WeaponType.Armor
      for k, gem in pairs(allGems) do
        local curQuality = curGem and curGem.quality or 0
        if gemType == gem.type and curQuality < gem.quality then
          return true
        end
      end
    end
  end
  return false
end
function UserDataManager:CanEquipNewSkill(heroId, bActive)
  local herosData = self:GetHeroData(heroId)
  if heroId then
    herosData = {herosData}
  end
  local siMng = require("app.info.SkillInfoManager"):GetInstance()
  if bActive == nil or bActive == true then
    local idleSkills = siMng:GetIdleHeroSkill(true)
    if #idleSkills > 0 then
      for key, heroData in pairs(herosData) do
        for i, skill in pairs(heroData.activeSkill) do
          if skill == 0 then
            return true
          end
        end
      end
    end
  end
  if bActive == nil or bActive == false then
    local idleSkills = siMng:GetIdleHeroSkill(false)
    if #idleSkills > 0 then
      for key, heroData in pairs(herosData) do
        for i, skill in pairs(heroData.passiveSkill) do
          if skill == 0 then
            return true
          end
        end
      end
    end
  end
  return false
end
return UserDataManager
