local GameControl = require("app.GameControl")
local CSVLoader = require("app.utils.CSVLoader")
local ItemInfoManager = class("ItemInfoManager", GameControl)
ItemInfoManager.instance = nil
function ItemInfoManager:ctor(eType)
  ItemInfoManager.super.ctor(self, eType)
  self:Init()
end
function ItemInfoManager:GetInstance()
  if ItemInfoManager.instance == nil then
    ItemInfoManager.instance = ItemInfoManager.new(td.GameControlType.ExitGame)
  end
  return ItemInfoManager.instance
end
function ItemInfoManager:Init()
  self.m_itemInfos = {}
  self.m_itemDonateInfos = {}
  self.m_itemExpInfos = {}
  self.m_itemComposeInfos = {}
  self.m_itemDecomposeInfos = {}
  self:SaveInfo()
end
function ItemInfoManager:ClearValue()
end
function ItemInfoManager:SaveInfo()
  local vData = CSVLoader.loadCSV("Config/item.csv")
  for i, v in ipairs(vData) do
    if v.source == "" then
      v.source = {}
    else
      local tmp = string.split(v.source, "|")
      v.source = {}
      for i, var in ipairs(tmp) do
        local tmp1 = string.split(var, "#")
        table.insert(v.source, {
          type = tonumber(tmp1[1]),
          id = tonumber(tmp1[2])
        })
      end
    end
    local tmp = string.split(v.use_type, "#")
    v.use_type = {}
    for j, var in ipairs(tmp) do
      table.insert(v.use_type, tonumber(var))
    end
    v.name = g_LM:getBy(v.name) or v.name
    v.desc = g_LM:getBy(v.desc) or v.desc
    self.m_itemInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/donation.csv")
  for i, v in ipairs(vData) do
    local rewards = string.split(v.reward, "|")
    v.reward = {}
    for j, var in ipairs(rewards) do
      local tmp = string.split(var, "#")
      v.reward = {
        itemId = tmp[1],
        num = tmp[2]
      }
    end
    self.m_itemDonateInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/item_exp.csv")
  for i, v in ipairs(vData) do
    self.m_itemExpInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/item_synthetic.csv")
  for i, v in ipairs(vData) do
    self.m_itemComposeInfos[v.id] = v
  end
  vData = CSVLoader.loadCSV("Config/item_decompose.csv")
  for i, v in ipairs(vData) do
    self.m_itemDecomposeInfos[v.id] = v
  end
end
function ItemInfoManager:GetItemAllInfos()
  return self.m_itemInfos
end
function ItemInfoManager:GetItemInfo(id)
  return self.m_itemInfos[id]
end
function ItemInfoManager:GetDonateInfos()
  return self.m_itemDonateInfos
end
function ItemInfoManager:GetDonateInfo(id)
  return self.m_itemDonateInfos[id]
end
function ItemInfoManager:GetExpItemInfo(id)
  return self.m_itemExpInfos[id]
end
function ItemInfoManager:GetItemExp(id)
  if self.m_itemExpInfos[id] then
    return self.m_itemExpInfos[id].quantity
  end
  return 0
end
function ItemInfoManager:GetExpItemInfos(type)
  local result = {}
  for id, var in pairs(self.m_itemExpInfos) do
    if var.use_type == type then
      table.insert(result, var)
    end
  end
  return result
end
function ItemInfoManager:GetComposeInfo(id)
  return self.m_itemComposeInfos[id]
end
function ItemInfoManager:GetDecomposeInfo(id)
  return self.m_itemDecomposeInfos[id]
end
return ItemInfoManager
