local TDHttpRequest = require("app.net.TDHttpRequest")
local MissionInfoManager = require("app.info.MissionInfoManager")
local GuideManager = require("app.GuideManager")
local UserDataManager = require("app.UserDataManager")
local MessageBoxDlg = require("app.layers.MessageBoxDlg")
local TabButton = require("app.widgets.TabButton")
local RuleInfoDlg = require("app.layers.RuleInfoDlg")
local BaseDlg = require("app.layers.BaseDlg")
local NormalItemSize = cc.size(235, 75)
local MissionChooseLayer = class("MissionChooseLayer", BaseDlg)
function MissionChooseLayer:ctor()
  MissionChooseLayer.super.ctor(self, 255, true)
  self.m_udMng = UserDataManager:GetInstance()
  self.m_miMng = MissionInfoManager:GetInstance()
  self.m_uiId = td.UIModule.Mission
  local recentDiff, recentChapter = g_MC:GetRecentOpenChapter()
  self.m_curDif = recentDiff or 1
  self.m_curChapter = recentChapter or 1
  self.m_chapterConfig = self.m_miMng:GetChaptersInfo()
  self.m_vMap = {}
  self.m_vBtnMap = {}
  self.m_bInit = false
  self.m_bIsAnimating = false
  self.m_clickMapIndex = nil
  self:InitUI()
end
function MissionChooseLayer:onEnter()
  MissionChooseLayer.super.onEnter(self)
  self:CreateDificultyList()
  self.m_tabButtons:setEnable(false)
  self:CreateForgroundMask()
  self:PlayEnterAni(function()
    self:PlayMapAni(false, function()
      self.m_bInit = true
      self:AddEvents()
      self:CheckGuide()
      self:performWithDelay(function()
        self.m_tabButtons:setEnable(true)
        self:AddBtnEvents()
        self:RemoveForgroundMask()
      end, 0.1)
    end)
  end)
  if self.m_miMng:IsChapterUnlock(1, 2) then
    GuideManager.H_StartGuideGroup(101)
  end
end
function MissionChooseLayer:onExit()
  MissionChooseLayer.super.onExit(self)
end
function MissionChooseLayer:InitUI()
  self:LoadUI("CCS/ChooseMissionLayer.csb", td.UIPosHorizontal.Center, td.UIPosVertical.Center, true)
  self:SetBg("UI/common/uibg2.png")
  self:SetTitle(td.Word_Path .. "wenzi_chuzheng.png")
  self.m_bg = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_bg")
  self.m_bg:setVisible(false)
  self.m_panelList = cc.uiloader:seekNodeByName(self.m_uiRoot, "Panel_list")
  self.m_panelList:setScaleY(0)
  for i = 1, 4 do
    local imageMap = cc.uiloader:seekNodeByName(self.m_bg, "Image_map" .. i)
    table.insert(self.m_vMap, imageMap)
    local btnMap = cc.uiloader:seekNodeByName(self.m_bg, "Button_" .. i)
    table.insert(self.m_vBtnMap, btnMap)
  end
  local nodeCenter = cc.uiloader:seekNodeByName(self.m_bg, "Node_center")
  self.m_sprCenter = SkeletonUnit:create("Spine/UI_effect/UI_chuzheng_01")
  self.m_sprCenter:addTo(nodeCenter)
  self.m_labelStar = cc.uiloader:seekNodeByName(self.m_bg, "Label_star")
  self.m_tipBtn = cc.uiloader:seekNodeByName(self.m_bg, "Button_tip")
  local listBg = cc.uiloader:seekNodeByName(self.m_panelList, "Image_listBg")
  self.m_UIListView = cc.ui.UIListView.new({
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    viewRect = cc.rect(0, 0, 300, 485),
    touchOnContent = false,
    scale = self.m_scale
  })
  self.m_UIListView:setAnchorPoint(0, 0)
  self.m_UIListView:setPosition(-23, 0)
  listBg:addChild(self.m_UIListView)
  self.m_UIListView:setVisible(false)
  self:RefreshList()
  self:RefreshContent()
end
function MissionChooseLayer:CreateDificultyList()
  self.m_tabs = {}
  local tabs = {}
  for i = 1, 3 do
    local _tab = cc.uiloader:seekNodeByName(self.m_bg, "Tab" .. i)
    table.insert(self.m_tabs, _tab)
    local bUnlock, errorCode = self.m_miMng:IsChapterUnlock(1, i)
    if bUnlock then
      _tab:setOpacity(255)
      if i > 1 and i ~= self.m_curDif then
        local firstMission = self.m_miMng:GetChaptersInfo()[i][1].missions[1]
        if not self.m_udMng:GetCityData(firstMission) then
          td.ShowRP(_tab, true)
        end
      end
    else
      local grayIcon = display.newGraySprite("UI/button/nandu" .. i .. "_icon2.png")
      local parent = _tab:getParent()
      local x, y = _tab:getPosition()
      grayIcon:pos(x, y):addTo(parent)
    end
    local tab = {
      tab = _tab,
      callfunc = handler(self, self.ChangeDifficulty),
      normalImageFile = "UI/button/nandu" .. i .. "_icon2.png",
      highImageFile = "UI/button/nandu" .. i .. "_icon1.png"
    }
    table.insert(tabs, tab)
  end
  self.m_tabButtons = TabButton.new(tabs, {
    autoSelectIndex = self.m_curDif
  })
end
function MissionChooseLayer:ChangeDifficulty(diff)
  if self.m_curDif == diff then
    return
  end
  td.ShowRP(self.m_tabs[diff], false)
  local bUnlock, errorCode = self.m_miMng:IsChapterUnlock(1, diff)
  if bUnlock then
    self.m_curDif = diff
    self:RefreshList()
    self:PlayMapAni(true)
    self.m_sprCenter:runAction(cca.seq({
      cca.delay(0.5),
      cca.scaleTo(0.2, 0),
      cca.cb(function()
        self.m_sprCenter:setScale(1)
        self.m_sprCenter:PlayAni("animation_0" .. self.m_curDif, false)
      end)
    }))
    G_SoundUtil:PlaySound(67)
  else
    td.alertErrorMsg(errorCode)
    return false
  end
end
function MissionChooseLayer:RefreshContent(bChangeDiff)
  local vMissionId = self.m_chapterConfig[self.m_curDif][self.m_curChapter].missions
  self.starNum = 0
  for i = 1, 4 do
    local missionId = vMissionId[i]
    local info = self.m_miMng:GetMissionInfo(missionId)
    self.m_vMap[i]:loadTexture(info.mini_map .. td.PNG_Suffix)
    local typeImage = self.m_vMap[i]:getChildByName("Image_type")
    typeImage:loadTexture("UI/mission/map_type" .. info.type .. td.PNG_Suffix)
    local btnMap = self.m_vBtnMap[i]
    self:RefreshMap(btnMap, missionId, i)
    if self.m_miMng:IsMissionUnlock(missionId) then
      self.m_vMap[i]:getChildByName("Image_mask"):setVisible(false)
    else
      self.m_vMap[i]:getChildByName("Image_mask"):setVisible(true)
      local lockSpr = display.newSprite("UI/mission/suo_icon.png")
      td.AddRelaPos(btnMap, lockSpr)
      local preName = self.m_miMng:GetMissionInfo(info.unlock_mission).name
      local difStr = self.m_curDif == 1 and "\231\174\128\229\141\149" or "\229\155\176\233\154\190"
      btnMap.msg = string.format("\229\188\128\229\144\175\230\157\161\228\187\182:\233\128\154\232\191\135%s%s\230\168\161\229\188\143", preName, difStr)
    end
  end
  self.m_labelStar:setString("x" .. self.starNum)
end
function MissionChooseLayer:RefreshMap(btnMap, missionId, i)
  local info = self.m_miMng:GetMissionInfo(missionId)
  btnMap:removeAllChildren()
  local nameLabel = td.CreateLabel(info.name, nil, 24)
  local gapX, startX = 0, 0
  if i == 1 or i == 3 then
    nameLabel:setAnchorPoint(0, 0.5)
    td.AddRelaPos(btnMap, nameLabel, 1, cc.p(0.05, 0.12))
    gapX = 30
    startX = nameLabel:getPositionX() + nameLabel:getBoundingBox().width + 30
  else
    nameLabel:setAnchorPoint(1, 0.5)
    td.AddRelaPos(btnMap, nameLabel, 1, cc.p(0.95, 0.12))
    gapX = -30
    startX = nameLabel:getPositionX() - nameLabel:getBoundingBox().width - 30
  end
  local missionData = self.m_udMng:GetCityData(missionId)
  for j = 1, 3 do
    local starIcon
    if missionData and missionData.star[j] then
      self.starNum = self.starNum + 1
      starIcon = display.newSprite("UI/icon/xingxing_icon.png")
    else
      starIcon = display.newSprite("UI/icon/xingxing2_icon.png")
    end
    starIcon:scale(1):pos(startX + (j - 1) * gapX, 22):addTo(btnMap)
  end
  if missionData and missionData.occupation ~= td.OccupState.Normal then
    local occupSpr = display.newSprite("UI/mission/occup.png")
    occupSpr:opacity(0):scale(3)
    occupSpr:runAction(cca.seq({
      cca.delay(0.5),
      cca.spawn({
        cca.fadeIn(0.3),
        cca.scaleTo(0.5, 1)
      })
    }))
    td.AddRelaPos(btnMap, occupSpr)
  end
  local btnFile = "UI/mission/tupian" .. self.m_curDif .. "_kuang" .. td.PNG_Suffix
  btnMap:loadTextures(btnFile, btnFile, btnFile)
  local sprLight = self.m_vMap[i]:getChildByName("sprite_light")
  sprLight:setTexture("UI/mission/xuanzhong_jianbian" .. self.m_curDif .. ".png")
end
function MissionChooseLayer:RefreshList()
  self.m_UIListView:removeAllItems()
  for i, var in ipairs(self.m_chapterConfig[self.m_curDif]) do
    local item = self:CreateItem(i, var.name)
    self.m_UIListView:addItem(item)
  end
  self.m_UIListView:reload()
  local lastChapter = self:GetLastChapter(self.m_curDif)
  self:OnListItemClicked(lastChapter)
  if lastChapter > 5 then
    self.m_UIListView:scrollTo(0, 0)
  end
end
function MissionChooseLayer:GetLastChapter(diff)
  local recnetDiff, recnetChapter = g_MC:GetRecentOpenChapter()
  if recnetDiff == diff and recnetChapter then
    return recnetChapter
  end
  local chapter = 0
  for i, var in ipairs(self.m_chapterConfig[diff]) do
    if self.m_miMng:IsChapterUnlock(i, diff) then
      chapter = i
    end
  end
  return chapter
end
function MissionChooseLayer:OnListItemClicked(index)
  if self.m_curChapter > 0 then
    local item = self.m_UIListView:getItemByPos(self.m_curChapter)
    local pItemBg = item:getContent()
    pItemBg:setScale(self.m_scale)
    td.setTexture(pItemBg, "UI/mission/zhangjie2_button.png")
  end
  self.m_curChapter = index
  local item = self.m_UIListView:getItemByPos(self.m_curChapter)
  local pItemBg = item:getContent()
  pItemBg:setScale(self.m_scale * 1.1)
  td.setTexture(pItemBg, "UI/mission/zhangjie1_button.png")
  g_MC:SetRecentOpenChapter(self.m_curDif, self.m_curChapter)
end
function MissionChooseLayer:PlayEnterAni(endCb)
  self.m_panelList:runAction(cca.seq({
    cca.scaleTo(0.3, 1, 1),
    cca.cb(function()
      self.m_bg:setVisible(true)
      self.m_sprCenter:PlayAni("animation_0" .. self.m_curDif, false)
      self.m_UIListView:setVisible(true)
    end),
    cca.delay(0.5),
    cca.cb(function()
      endCb()
    end)
  }))
  G_SoundUtil:PlaySound(66)
end
function MissionChooseLayer:PlayMapAni(bChangeDiff, cb)
  self.m_bIsMapAnimating = true
  local changeDiffDelay = bChangeDiff and 0.8 or 0
  for i, var in ipairs(self.m_vMap) do
    if self.m_bInit then
      var:runAction(cca.seq({
        cca.delay(i * 0.05),
        cc.EaseBackIn:create(cca.scaleTo(0.3, 0)),
        cca.cb(function()
          self:RefreshContent(bChangeDiff)
        end),
        cca.delay(0.2 + changeDiffDelay),
        cc.EaseBackOut:create(cca.scaleTo(0.5, 1)),
        cca.cb(function()
          self.m_bIsMapAnimating = false
        end)
      }))
    else
      var:runAction(cca.seq({
        cca.delay(i * 0.05),
        cc.EaseBackOut:create(cca.scaleTo(0.5, 1)),
        cca.cb(function()
          self.m_bIsMapAnimating = false
          if i == 4 and cb then
            cb()
          end
        end)
      }))
    end
  end
end
function MissionChooseLayer:ViewRule()
  local str = g_LM:getBy("a00219")
  local data = {
    title = "\232\167\132\229\136\153\232\175\180\230\152\142",
    text = str
  }
  local ruleInfo = RuleInfoDlg.new(data)
  td.popView(ruleInfo)
end
function MissionChooseLayer:CreateItem(index, name)
  local itemBg = display.newSprite("UI/mission/zhangjie2_button.png")
  itemBg:setScale(self.m_scale)
  local nameLabel = td.CreateLabel(name, td.WHITE, 22)
  nameLabel:setAnchorPoint(0, 0.5)
  td.AddRelaPos(itemBg, nameLabel, 1, cc.p(0.55, 0.5))
  if not self.m_miMng:IsChapterUnlock(index, self.m_curDif) then
    local lockSpr = display.newSprite("UI/mission/suo_zhangjie_icon.png")
    td.AddRelaPos(itemBg, lockSpr, 1, cc.p(0.215, 0.5))
  else
    local numLabel = td.CreateLabel(string.format("%d", index), td.WHITE, 30)
    td.AddRelaPos(itemBg, numLabel, 1, cc.p(0.215, 0.5))
    local vMissionId = self.m_chapterConfig[self.m_curDif][index].missions
    for i, missionId in ipairs(vMissionId) do
      local missionData = UserDataManager:GetInstance():GetCityData(missionId)
      if missionData and missionData.occupation ~= td.OccupState.Normal then
        td.CreateUIEffect(itemBg, "Spine/UI_effect/UI_fangong_01", {
          loop = true,
          pos = cc.p(50, 45)
        })
        break
      end
    end
  end
  local item = self.m_UIListView:newItem(itemBg)
  item:setItemSize(NormalItemSize.width * self.m_scale, (NormalItemSize.height + 22) * self.m_scale)
  return item
end
function MissionChooseLayer:ShowMission(index, msg)
  local vMissionId = self.m_chapterConfig[self.m_curDif][self.m_curChapter].missions
  local missionId = vMissionId[index]
  if not self.m_miMng:IsMissionUnlock(missionId) then
    td.alert(msg, true)
    return
  end
  if self.m_bIsAnimating then
    return
  end
  self.m_bIsAnimating = true
  self.m_clickMapIndex = index
  for i, var in ipairs(self.m_vMap) do
    if i ~= index then
      local scaleAction = cc.EaseBackIn:create(cca.scaleTo(0.2, 0))
      var:runAction(cca.seq({
        cca.delay(i * 0.05 - 0.05),
        scaleAction
      }))
    end
  end
  local clickMap = self.m_vMap[index]
  self.m_missionDlg = require("app.layers.MainMenuUI.MissionLayer").new(missionId)
  self.m_missionDlg:retain()
  local destPos = self.m_missionDlg:GetImageMapPos()
  local file = self.m_miMng:GetMissionInfo(missionId).mini_map
  local worldPos = clickMap:getParent():convertToWorldSpace(cc.p(clickMap:getPosition()))
  local sprMap = display.newSprite(file .. td.PNG_Suffix)
  sprMap:setVisible(false)
  sprMap:setAnchorPoint(clickMap:getAnchorPoint())
  sprMap:scale(0.67 * self.m_scale):pos(worldPos.x, worldPos.y):addTo(display.getRunningScene(), td.ZORDER.Info)
  Util_changeAnchor(sprMap, cc.p(0.5, 0.5))
  sprMap:runAction(cca.seq({
    cca.delay(0.3),
    cca.cb(function()
      sprMap:setVisible(true)
      clickMap:setScale(0)
      td.popView(self.m_missionDlg)
      self.m_missionDlg:release()
      self.m_missionDlg = nil
    end),
    cca.spawn({
      cca.scaleTo(0.5, 1 * self.m_scale),
      cca.moveTo(0.5, destPos.x, destPos.y)
    }),
    cca.delay(0.35),
    cca.removeSelf()
  }))
  self.m_panelList:setVisible(false)
  self.m_sprCenter:runAction(cca.seq({
    cca.scaleTo(0.3, 0)
  }))
end
function MissionChooseLayer:HideMission()
  local index = self.m_clickMapIndex
  for i, var in ipairs(self.m_vMap) do
    local scaleAction = cc.EaseBackOut:create(cca.scaleTo(0.5, 1))
    var:runAction(cca.seq({
      cca.delay(i * 0.05),
      scaleAction
    }))
  end
  self.m_panelList:setVisible(true)
  self.m_sprCenter:setScale(1)
  self.m_bIsAnimating = false
  self.m_clickMapIndex = nil
end
function MissionChooseLayer:OnMapTouched(sender, eventType)
  if self.m_bIsMapAnimating or self.m_bIsAnimating then
    return
  end
  local index = sender:getTag()
  local sprLight = self.m_vMap[index]:getChildByName("sprite_light")
  local vRotation = {
    0,
    90,
    270,
    180
  }
  if ccui.TouchEventType.began == eventType then
    self.m_vMap[index]:setColor(cc.c3b(200, 200, 200))
  elseif ccui.TouchEventType.ended == eventType then
    self.m_vMap[index]:setColor(cc.c3b(255, 255, 255))
    self:ShowMission(index, sender.msg)
    td.dispatchEvent(td.GUIDE_FINISHED, self.m_uiId)
  elseif ccui.TouchEventType.canceled == eventType then
    self.m_vMap[index]:setColor(cc.c3b(255, 255, 255))
  end
end
function MissionChooseLayer:AddEvents()
  local eventDsp = self:getEventDispatcher()
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_UIListView:onTouch_({
        name = "began",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
      self.m_bIsTouchInList = true
    else
      self.m_bIsTouchInList = false
    end
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
    if self.m_UIListView:isTouchInViewRect({
      x = touch:getLocation().x,
      y = touch:getLocation().y
    }) then
      self.m_UIListView:onTouch_({
        name = "moved",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_MOVED)
  listener:registerScriptHandler(function(touch, event)
    if self.m_bIsTouchInList then
      self.m_UIListView:onTouch_({
        name = "ended",
        x = touch:getLocation().x,
        y = touch:getLocation().y,
        prevX = touch:getPreviousLocation().x,
        prevY = touch:getPreviousLocation().y
      })
    end
  end, cc.Handler.EVENT_TOUCH_ENDED)
  eventDsp:addEventListenerWithSceneGraphPriority(listener, self)
  self:AddCustomEvent(td.MISSION_CLOSE, handler(self, self.HideMission))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
function MissionChooseLayer:AddBtnEvents()
  for i, btnMap in ipairs(self.m_vBtnMap) do
    btnMap:addTouchEventListener(handler(self, self.OnMapTouched))
  end
  self.m_UIListView:onTouch(function(event)
    if "clicked" == event.name and event.item then
      local index = event.itemPos
      if index == self.m_curChapter then
        return
      end
      local bUnlock, errorCode = self.m_miMng:IsChapterUnlock(index, self.m_curDif)
      if not bUnlock then
        td.alertErrorMsg(errorCode)
        return
      end
      self:OnListItemClicked(index)
      self:PlayMapAni()
    end
  end)
  td.BtnAddTouch(self.m_tipBtn, handler(self, self.ViewRule))
end
return MissionChooseLayer
