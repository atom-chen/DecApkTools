local GameControl = require("app.GameControl")
local AchievementInfo = require("app.info.AchievementInfo")
local ItemInfoManager = require("app.info.ItemInfoManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local CommanderInfoManager = require("app.info.CommanderInfoManager")
local UserDataManager = require("app.UserDataManager")
local scheduler = require("framework.scheduler")
local s_iPerMaxNum = 5
local s_iSystemMaxNum = 3
local s_iPromptMaxNum = 7
local s_iPerSpeed = 120
local s_iSystemSpeed = 30
local s_iPromptSpeed = 80
InformationManager = class("InformationManager", GameControl)
function InformationManager:ctor(eType)
  InformationManager.super.ctor(self, eType)
  self.m_vInfoData = {}
  self.m_bIsShowingInfo = false
  self.m_vInfoAchieveData = {}
  self.m_bIsShowingAchieve = false
  self.m_vBeRobData = {}
  self.m_bIsShowingBeRob = false
  self.m_powerLayer = nil
end
function InformationManager:onCleanup()
  self:ClearValue()
end
function InformationManager:GetInstance()
  if InformationManager.instance == nil then
    InformationManager.instance = InformationManager.new(td.GameControlType.SwichScene)
  end
  return InformationManager.instance
end
function InformationManager:ClearValue()
end
function InformationManager:OnShowDone(_type)
  if _type == td.ShowInfo.Honor or _type == td.ShowInfo.Skill or _type == td.ShowInfo.Item then
    if #self.m_vInfoData > 0 then
      self:_ShowInfoDlg(self.m_vInfoData[1])
      table.remove(self.m_vInfoData, 1)
    else
      self.m_bIsShowingInfo = false
    end
  elseif _type == td.ShowInfo.BeRobed then
    if 0 < #self.m_vBeRobData then
      self:_ShowBeRobed(self.m_vBeRobData[1])
      table.remove(self.m_vBeRobData, 1)
    else
      self.m_bIsShowingBeRob = false
    end
  elseif _type == td.ShowInfo.Achieve then
    if 0 < #self.m_vInfoAchieveData then
      self:_addAchievementText(self.m_vInfoAchieveData[1])
      table.remove(self.m_vInfoAchieveData, 1)
    else
      self.m_bIsShowingAchieve = false
    end
  end
end
function InformationManager:ShowLevelUp(cb)
  local dlg = require("app.layers.LevelUpDlg").new(cb)
  local pRunScene = display.getRunningScene()
  pRunScene:addChild(dlg, td.ZORDER.Info, td.ZORDER.Info)
end
function InformationManager:ShowPowerUp(oriPower, upPower)
  local pRunScene = display.getRunningScene()
  if pRunScene:GetType() == td.SceneType.Login then
    return
  end
  local taskComp = pRunScene:getChildByName("TaskComplete")
  local function cb()
    local dlg = require("app.layers.PowerUpLayer").new(oriPower)
    dlg:setName("PowerUp")
    dlg:RollTo(upPower)
    pRunScene:addChild(dlg, td.ZORDER.Info, td.ZORDER.Info)
  end
  if not taskComp then
    cb()
  else
    pRunScene:performWithDelay(function()
      cb()
    end, 1)
  end
end
function InformationManager:ShowTaskComplete()
  local pRunScene = display.getRunningScene()
  local powerUp = pRunScene:getChildByName("PowerUp")
  local function cb()
    local dlg = require("app.layers.TaskCompleteLayer").new()
    dlg:setName("TaskComplete")
    pRunScene:addChild(dlg, td.ZORDER.Info, td.ZORDER.Info)
  end
  if not powerUp then
    cb()
  else
    pRunScene:performWithDelay(function()
      cb()
    end, 1.5)
  end
end
function InformationManager:ShowOpenBox(items)
  self:_ShowOpenBox(items)
end
function InformationManager:ShowInfoDlg(data)
  if not self.m_bIsShowingInfo then
    self:_ShowInfoDlg(data)
    self.m_bIsShowingInfo = true
  else
    table.insert(self.m_vInfoData, data)
  end
end
function InformationManager:ShowBeRobed(data)
  if not self.m_bIsShowingBeRob then
    self:_ShowBeRobed(data)
    self.m_bIsShowingBeRob = true
  else
    table.insert(self.m_vBeRobData, data)
  end
end
function InformationManager:addAchievementText(id)
  if not self.m_bIsShowingAchieve then
    self:_addAchievementText(id)
    self.m_bIsShowingAchieve = true
  else
    table.insert(self.m_vInfoAchieveData, id)
  end
end
function InformationManager:_ShowOpenBox(items)
  local pDlg = require("app.layers.OpenBoxDlg").new(items)
  td.popView(pDlg)
end
function InformationManager:_ShowInfoDlg(_data)
  local pDlg
  if _data.type == td.ShowInfo.LevelUp then
    pDlg = require("app.layers.LevelUpDlg").new()
  else
    local data = {}
    if _data.type == td.ShowInfo.Item or _data.type == td.ShowInfo.Weapon then
      data.items = {}
      local bWeapon, bGem = false, false
      for itemId, itemNum in pairs(_data.items) do
        local info = td.GetItemInfo(itemId)
        if not info then
          return
        end
        local item = {}
        item.id = itemId
        item.num = itemNum
        item.name = info.name
        table.insert(data.items, item)
        if itemId < 20000 then
          bWeapon = true
        elseif itemId > 80000 then
          bGem = true
        end
      end
      data.title = td.Word_Path .. "wenzi_huodewuping.png"
      if bWeapon then
        UserDataManager:GetInstance():SendGetWeaponRequest()
      end
      if bGem then
        UserDataManager:GetInstance():SendGetGemRequest()
      end
    elseif _data.type == td.ShowInfo.Skill then
      data.items = {}
      for itemId, itemNum in pairs(_data.items) do
        local info = SkillInfoManager:GetInstance():GetInfo(itemId)
        if not info then
          return
        end
        local item = {}
        item.id = itemId
        item.name = info.name
        table.insert(data.items, item)
      end
      data.isSkill = true
      data.title = td.Word_Path .. "wenzi_huodejineng.png"
    elseif _data.type == td.ShowInfo.Honor then
      local info = CommanderInfoManager:GetInstance():GetHonorInfo(_data.id)
      local preInfo = CommanderInfoManager:GetInstance():GetHonorInfo(_data.id - 1)
      if not info or not preInfo then
        return
      end
      data.icon = info.image .. td.PNG_Suffix
      data.title = td.Word_Path .. "wenzi_shengji.png"
      data.name = info.military_rank
    end
    pDlg = require("app.layers.InformationDlg").new(data)
  end
  if pDlg then
    G_SoundUtil:PlaySound(64)
    td.popView(pDlg, true)
  end
end
function InformationManager:_ShowBeRobed(data)
  local dlg = require("app.layers.MainMenuUI.BeRobedReportDlg").new(data)
  td.popView(dlg)
end
function InformationManager:_addAchievementText(id)
  local autoScale = td.GetAutoScale()
  local dlg = self:_createAchieveDlg(id)
  dlg:setPosition(display.size.width / 2, display.size.height * 0.8)
  dlg:setScale(0)
  display.getRunningScene():addChild(dlg, td.ZORDER.Info)
  dlg:runAction(cca.seq({
    cca.scaleTo(0.3, 1.1 * autoScale),
    cca.scaleTo(0.05, 1 * autoScale),
    cca.delay(3),
    cca.cb(function()
      local children = dlg:getChildren()
      for key, child in ipairs(children) do
        child:runAction(cca.fadeOut(0.5))
      end
    end),
    cca.fadeOut(0.7),
    cca.removeSelf()
  }))
  scheduler.performWithDelayGlobal(function(times)
    self:OnShowDone(td.ShowInfo.Achieve)
  end, 3.35)
  G_SoundUtil:PlaySound(62)
end
function InformationManager:_createAchieveDlg(id)
  local achiveInfo = AchievementInfo:GetInstance():GetInfo(id)
  local itembg = display.newScale9Sprite("UI/scale9/bantouming3.png", 0, 0, cc.size(320, 80))
  local itembgSize = itembg:getContentSize()
  local iconBgSize = cc.size(74, 74)
  local wupinbg = display.newScale9Sprite("UI/scale9/wupingkuang.png", 0, 0, iconBgSize)
  wupinbg:setPosition(iconBgSize.width / 2, itembgSize.height / 2)
  itembg:addChild(wupinbg)
  local image = display.newSprite(achiveInfo.image .. td.PNG_Suffix)
  image:setPosition(wupinbg:getPosition())
  itembg:addChild(image)
  local label = td.CreateLabel(achiveInfo.name, td.YELLOW, 20)
  label:setAnchorPoint(cc.p(0, 0))
  label:setPosition(cc.p(wupinbg:getPositionX() + iconBgSize.width / 2 + 5, itembgSize.height / 2 + 5))
  itembg:addChild(label)
  label = td.CreateLabel(achiveInfo.descrip, td.WHITE, 16, nil, nil, cc.size(250, 0))
  label:setAnchorPoint(cc.p(0, 1))
  label:setPosition(cc.p(wupinbg:getPositionX() + iconBgSize.width / 2 + 5, itembgSize.height / 2 + 5))
  itembg:addChild(label)
  return itembg
end
return InformationManager
