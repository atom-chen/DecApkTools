local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local GameDataManager = require("app.GameDataManager")
local CommonInfoManager = class("CommonInfoManager", GameControl)
CommonInfoManager.instance = nil
function CommonInfoManager:ctor(eType)
  CommonInfoManager.super.ctor(self, eType)
  self:Init()
end
function CommonInfoManager:GetInstance()
  if CommonInfoManager.instance == nil then
    CommonInfoManager.instance = CommonInfoManager.new(td.GameControlType.ExitGame)
  end
  return CommonInfoManager.instance
end
function CommonInfoManager:Init()
  self.m_mallItemInfos = {}
  self.m_arenaAwardInfos = {}
  self.m_vipInfos = {}
  self.m_chargeInfo = {}
  self.m_periodGiftInfo = {}
  self.m_giftPackInfo = {}
  self.m_constantInfo = {}
  self:SaveInfo()
end
function CommonInfoManager:ClearValue()
end
function CommonInfoManager:SaveInfo()
  local vData = CSVLoader.loadCSV("Config/store.csv")
  for i, v in ipairs(vData) do
    if not self.m_mallItemInfos[v.consume_type] then
      self.m_mallItemInfos[v.consume_type] = {}
    end
    self.m_mallItemInfos[v.consume_type][v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/arena_award.csv")
  for i, v in ipairs(vData) do
    local tmp = string.split(v.level, "#")
    for k, val in ipairs(tmp) do
      tmp[k] = tonumber(val)
      v.level = tmp
    end
    v.award = td.ParserItemStr(v.award)[1]
    self.m_arenaAwardInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/VIP.csv")
  for i, v in ipairs(vData) do
    v.sweep = td.ParserItemStr(v.sweep)[1]
    v.award_vip = td.ParserItemStr(v.award_vip)
    self.m_vipInfos[v.vip] = v
  end
  vData = CSVLoader.loadCSV("Config/charge.csv")
  for i, v in ipairs(vData) do
    self.m_chargeInfo[i] = v
  end
  vData = CSVLoader.loadCSV("Config/moon.csv")
  for i, v in ipairs(vData) do
    v.id = v.days
    v.diamond_mail = td.ParserItemStr(v.diamond_mail)
    self.m_periodGiftInfo[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/reward_bag.csv")
  for i, v in ipairs(vData) do
    v.reward = td.ParserItemStr(v.reward)
    self.m_giftPackInfo[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/constant.csv")
  for i, v in ipairs(vData) do
    self.m_constantInfo[v.key] = v.value
  end
end
function CommonInfoManager:GetChargeInfo(type, id)
  local vInfo
  if type == td.PayType.Charge then
    vInfo = self.m_chargeInfo
  elseif type == td.PayType.Prop then
    vInfo = self.m_periodGiftInfo
  else
    vInfo = self.m_giftPackInfo
  end
  if not id then
    return vInfo
  end
  return vInfo[id]
end
function CommonInfoManager:GetVipInfo(level)
  if level then
    for i = 0, #self.m_vipInfos do
      if i == level then
        return self.m_vipInfos[level]
      end
    end
  end
  return self.m_vipInfos
end
function CommonInfoManager:GetVipByCharge(charge)
  local vip = 0
  for i, var in ipairs(self.m_vipInfos) do
    if charge >= var.diamond_demand then
      vip = i
    else
      break
    end
  end
  return vip
end
function CommonInfoManager:GetMallItemInfo(id)
  for key, var in pairs(self.m_mallItemInfos) do
    if var[id] then
      return var[id]
    end
  end
  return nil
end
function CommonInfoManager:GetMallItemsInfo(itemType)
  if itemType then
    return self.m_mallItemInfos[itemType]
  else
    return self.m_mallItemInfos
  end
end
function CommonInfoManager:GetHeroMallItem(heroId)
  local heroItems = require("app.config.shop_item_hero")
  local itemId
  for key, var in pairs(heroItems) do
    if var == heroId then
      itemId = key
    end
  end
  for j, mall in pairs(self.m_mallItemInfos) do
    for k, mallItem in pairs(mall) do
      if mallItem.item == itemId then
        return mallItem
      end
    end
  end
end
function CommonInfoManager:GetArenaAwardInfo(rank)
  if not rank then
    return self.m_arenaAwardInfos
  else
    for i, val in ipairs(self.m_arenaAwardInfos) do
      local min, max = self.m_arenaAwardInfos[i], nil
      if rank <= max and rank >= min then
        return self.m_arenaAwardInfos[i]
      end
    end
  end
end
function CommonInfoManager:GetGiftPackInfo(id)
  return self.m_periodGiftInfo[id]
end
function CommonInfoManager:GetConstant(key)
  return self.m_constantInfo[key]
end
function CommonInfoManager:GetAllProducts()
  local result, count = {}, 1
  local allProducts = {
    self.m_chargeInfo,
    self.m_periodGiftInfo,
    self.m_giftPackInfo
  }
  for i, products in ipairs(allProducts) do
    for id, product in pairs(products) do
      result["product_" .. count] = product.product_id
      count = count + 1
    end
  end
  return result
end
return CommonInfoManager
