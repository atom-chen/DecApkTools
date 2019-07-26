local GameSceneBase = require("app.scenes.GameSceneBase")
local GameControl = require("app.GameControl")
local ActorManager = require("app.actor.ActorManager")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local TriggerManager = require("app.trigger.TriggerManager")
local BuffManager = require("app.buff.BuffManager")
local MissionInfoManager = require("app.info.MissionInfoManager")
local UserDataManager = require("app.UserDataManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local ActorInfoManager = require("app.info.ActorInfoManager")
local GuideManager = require("app.GuideManager")
local BattleScene = class("BattleScene", GameSceneBase)
function BattleScene:ctor()
  BattleScene.super.ctor(self)
  self.m_iSubWaveIndex = 0
  self.m_bWaveStart = false
  self.m_iTimeInterval = 0
  self.m_TroopTips = {}
  self.m_eType = td.SceneType.Battle
  self.m_gdMng = GameDataManager:GetInstance()
end
function BattleScene:onEnter()
  BattleScene.super.onEnter(self)
  self:CreateForgroundMask()
  self:AddTouch()
  self:AddListeners()
  self:InitCommon()
  self:EnterAni()
  G_SoundUtil:PlayMusic(self.m_mapInfo.bgm or 8, true)
end
function BattleScene:onExit()
  cc.Director:getInstance():getTextureCache():removeUnusedTextures()
  TriggerManager:GetInstance():RemoveTriggerByType(td.TriggerType.MapType)
  TriggerManager:GetInstance():RemoveTriggerByType(td.TriggerType.MapId)
  self:removeNodeEventListener(handler(self, self.update))
  self:unscheduleUpdate()
  self:RemoveListeners()
  self.m_timeScale = 1
  G_SoundUtil:Stop(true)
end
function BattleScene:InitCommon()
  self.m_mapInfo = self.m_gdMng:GetGameMapInfo()
  local pMap = self.m_gdMng:GetGameMap()
  pMap:addTo(self)
  self:CreateBuild()
  self:createCaiDan(self.m_mapInfo.id)
  self:AddTerrainEffect()
  self.m_fTimeInterval = 0
  self.m_Time = self.m_mapInfo.max_time + 1
  if self.m_Time <= 1 then
    self.m_bShowSurplusTime = false
  else
    self.m_bShowSurplusTime = true
  end
  self:InitGame()
end
function BattleScene:InitGame()
  local pMap = self.m_gdMng:GetGameMap()
  self.m_pathBatchNode = display.newBatchNode(td.UI_PATH_SIGN)
  pMap:addChild(self.m_pathBatchNode, td.InMapZOrder.PathSign)
  if self.m_gdMng:GetGameMapInfo().id == 1000 and not UserDataManager:GetInstance():GetCityData(1000) then
    self.m_uiLayer = require("app.layers.battle.BattleUIGuideLayer").new()
  else
    self.m_uiLayer = require("app.layers.battle.BattleUILayer").new()
  end
  self:addChild(self.m_uiLayer, 101)
  if self.m_mapInfo.type ~= td.MapType.ZiYuan and self.m_mapInfo.type ~= td.MapType.Rob and self.m_mapInfo.type ~= td.MapType.Collect then
    local herosData = StrongInfoManager:GetInstance():GetBattleHeros()
    self.m_gdMng:InitHeros(herosData)
    self:CreateHero()
  end
  self:SaveMonsterPlan()
  if self.m_mapInfo.type == td.MapType.Endless then
    self.m_gdMng:SetMonsterWave(1)
    local msg = {}
    msg.msgType = td.RequestID.EndlessFightStart
    TDHttpRequest:getInstance():Send(msg)
    UserDataManager:GetInstance():UpdateDungeonTime(td.UIModule.Endless, -1)
  elseif self.m_mapInfo.type == td.MapType.FangShou then
    self.m_gdMng:SetMonsterWave(1)
    td.dispatchEvent(td.ADD_WAVE, {
      curCount = 0,
      maxWave = #self.m_vMonsterPlans
    })
  end
end
function BattleScene:EnterAni()
  self:SetPause(true)
  local whiteLayer = display.newSprite("#Effect/white.png")
  whiteLayer:setScaleX(display.width)
  whiteLayer:setScaleY(display.height)
  whiteLayer:center()
  self:addChild(whiteLayer, 102)
  whiteLayer:runAction(cca.seq({
    cca.delay(0.2),
    cca.fadeOut(0.3),
    cca.delay(0.7),
    cca.cb(function()
      self:ShowMapType()
    end)
  }))
  local vStartPos = {
    cc.p(0.68, 0.39),
    cc.p(0.46, 0.65),
    cc.p(0.67, 0.93),
    cc.p(0.35, 0.4),
    cc.p(0.24, 0.2),
    cc.p(0.76, 0.2),
    cc.p(0.8, 0.76),
    cc.p(0.28, 0.76)
  }
  local vEndPos = {
    cc.p(-2, 0.48),
    cc.p(-1, 0.78),
    cc.p(-2, 0.9),
    cc.p(-1, 0.43),
    cc.p(-1, -1),
    cc.p(-2, -1),
    cc.p(-2, -2),
    cc.p(-1, -2)
  }
  local vRotation = {
    0,
    0,
    0,
    0,
    30,
    0,
    0,
    0
  }
  for i = 1, 8 do
    local cloudSpr = display.newSprite("#Effect/" .. i .. ".png")
    cloudSpr:pos(display.width * vStartPos[i].x, display.height * vStartPos[i].y):rotation(vRotation[i]):scale(5):addTo(self, 102)
    local endX, endY
    if vEndPos[i].x == -1 then
      endX = -cloudSpr:getContentSize().width * cloudSpr:getScaleX()
    elseif vEndPos[i].x == -2 then
      endX = display.width + cloudSpr:getContentSize().width * cloudSpr:getScaleX()
    else
      endX = display.width * vEndPos[i].x
    end
    if vEndPos[i].y == -1 then
      endY = -cloudSpr:getContentSize().height * cloudSpr:getScaleY()
    elseif vEndPos[i].y == -2 then
      endY = display.height + cloudSpr:getContentSize().height * cloudSpr:getScaleY()
    else
      endY = display.height * vEndPos[i].y
    end
    cloudSpr:runAction(cca.seq({
      cca.delay(0.2),
      cca.moveTo(1, endX, endY),
      cca.removeSelf()
    }))
  end
end
function BattleScene:ShowMapType()
  self.m_gdMng:SetActorCanTouch(false)
  local mapInfo = self.m_gdMng:GetGameMapInfo()
  local mapTypeFile = self:GetMapTypeFile(mapInfo.type)
  if mapTypeFile then
    local bg = display.newSprite("UI/battle/heise_bantoumingdi.png")
    local wordBg = display.newSprite("UI/battle/lanse_zhuangshiguang.png")
    td.AddRelaPos(bg, wordBg)
    local wordSpr = display.newSprite(mapTypeFile)
    td.AddRelaPos(bg, wordSpr, 1)
    bg:setScale(0)
    bg:pos(display.width * 0.5, display.height * 0.65):addTo(self, td.ZORDER.Min)
    bg:runAction(cca.seq({
      cca.scaleTo(0.3, 1 * td.GetAutoScale(), 1 * td.GetAutoScale()),
      cca.delay(1),
      cca.fadeOut(0.5),
      cca.cb(handler(self, self.didEnter)),
      cca.removeSelf()
    }))
  else
    self:didEnter()
  end
end
function BattleScene:GetMapTypeFile(mapType)
  if mapType == td.MapType.TuiTa then
    return td.Word_Path .. "wenzi_jingongmoshi.png"
  elseif mapType == td.MapType.FangShou then
    return td.Word_Path .. "wenzi_fangshoumoshi.png"
  elseif mapType == td.MapType.ZiYuan then
    return td.Word_Path .. "wenzi_caijimoshi.png"
  elseif mapType == td.MapType.ZhanLing then
    return td.Word_Path .. "wenzi_zhandianmoshi.png"
  end
end
function BattleScene:didEnter()
  TriggerManager:GetInstance():AddTriggerByType(td.TriggerType.MapType, self.m_mapInfo.type)
  TriggerManager:GetInstance():AddTriggerByType(td.TriggerType.MapId, self.m_mapInfo.id)
  if self.m_mapInfo.id ~= self.m_gdMng:GetMissionId() then
    GuideManager.H_StartGuideGroup(103)
  end
  self:performWithDelay(function()
    local pMap = self.m_gdMng:GetGameMap()
    self.m_gdMng:SetActorCanTouch(true)
    self:SetPause(false)
    self:RemoveForgroundMask()
  end, 0.1)
end
function BattleScene:update(dt)
  BattleScene.super.update(self, dt)
  if self:IsPause() then
    return
  end
  if not self.m_bFightStart then
    return
  end
  self.m_gdMng:UpdateStarCondition(td.StarLevel.TIME_LIMIT, dt)
  if self.m_bShowSurplusTime then
    self.m_iTimeInterval = self.m_iTimeInterval + dt
    self.m_Time = self.m_Time - dt
    if self.m_Time <= 0 then
      self.m_Time = 0
      local eMapType = self.m_gdMng:GetGameMap():GetMapType()
      TriggerManager:GetInstance():SendEvent({
        eType = td.ConditionType.TimeOver,
        mapType = eMapType,
        timeOver = true
      })
    end
    if self.m_uiLayer.SetTime and self.m_iTimeInterval >= 1 then
      self.m_uiLayer:SetTime(self.m_Time)
      self.m_iTimeInterval = 0
    end
  end
  self:UpdateMonster(dt)
  local pMap = self.m_gdMng:GetGameMap()
  if pMap then
    pMap:sortAllChildren()
  end
end
function BattleScene:GetUILayer()
  return self.m_uiLayer
end
function BattleScene:CreateBuild()
  local pMap = self.m_gdMng:GetGameMap()
  local pMapInfo = self.m_gdMng:GetGameMapInfo()
  local mapId = pMapInfo.id
  local pGroup = pMap:GetTileMap():getObjectGroup("build")
  local actorMng = ActorManager:GetInstance()
  if pGroup then
    local buildVec = pGroup:getObjects()
    for i = 1, #buildVec do
      local valueMap = buildVec[i]
      local name = valueMap.name
      local px = valueMap.x
      local py = valueMap.y
      local fWidth = valueMap.width
      local fHeight = valueMap.height
      local pBuild
      if name == "born" then
        self.m_gdMng:SetBornPos(cc.p(px, py))
      elseif name == "bingying" then
        local id = tonumber(valueMap.id)
        local level = tonumber(valueMap.level)
        local branch = tonumber(valueMap.branch)
        pBuild = actorMng:CreateActor(td.ActorType.Camp, id, false)
        pBuild:setContentSize(fWidth, fHeight)
        pBuild:setPosition(px, py)
        local roleId = self.m_gdMng:GetCampRole(id)
        if roleId then
          pBuild:Build(roleId)
        else
          pBuild:Lock()
        end
      elseif name == "dabenying" or name == "feichuan" then
        local level = tonumber(valueMap.level)
        pBuild = actorMng:CreateActor(td.ActorType.Home, 1, false)
        pBuild:SetLevel(level or self.m_gdMng:GetHomeLevel())
        pBuild:setPosition(px + 20, py)
        pBuild:setContentSize(fWidth, fHeight)
        if name == "feichuan" then
          pBuild:SetIsShip(true)
        end
      elseif name == "difangdabenying" then
        pBuild = actorMng:CreateActor(td.ActorType.Home, 1, true)
        pBuild:setPosition(px, py)
        pBuild:setContentSize(fWidth, fHeight)
        pBuild:SetCurHp(tonumber(self.m_mapInfo.enemy_tower_hp))
        pBuild:SetMaxHp(tonumber(self.m_mapInfo.enemy_tower_hp))
        pBuild:SetDefense(tonumber(self.m_mapInfo.enemy_tower_def))
        local deputy = tonumber(valueMap.deputy) or 0
        pBuild:SetDeputy(deputy)
        if deputy > 0 then
          self.m_gdMng:UpdateDeputyNum(1)
        end
      elseif name == "ziyuan" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        pBuild:SetResource(td.ResourceType.ZiYuan, tonumber(self.m_mapInfo.collect_resource))
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
        pBuild:CreateAnimation("Spine/mapeffect/nengliangku_01")
        pBuild:PlayAnimation("caiji_01", true)
        local ziyuanPosInfo = MissionInfoManager:GetInstance():GetZiyuanPosInfo(mapId)
        local t = {}
        if ziyuanPosInfo then
          t = string.split(ziyuanPosInfo.energy, "#")
        end
        if #t > 1 then
          pBuild.m_pSkeleton:setPosition(cc.p(tonumber(t[1]), tonumber(t[2])))
        else
          pBuild.m_pSkeleton:setPosition(cc.p(0, 0))
        end
        local dir = tonumber(valueMap.dir) or 0
        if dir == 1 then
          pBuild.m_pSkeleton:setScaleX(-1)
        end
      elseif name == "danyao" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        local t = string.split(self.m_mapInfo.bullet, "#")
        if #t > 0 then
          pBuild:SetResource(td.ResourceType.DanYao, tonumber(t[1]))
        else
          pBuild:SetResource(td.ResourceType.DanYao, 0)
        end
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
        pBuild:CreateAnimation("Spine/mapeffect/danyaoku_01")
        pBuild:PlayAnimation("caiji_01", true)
        local ziyuanPosInfo = MissionInfoManager:GetInstance():GetZiyuanPosInfo(mapId)
        local t = {}
        if ziyuanPosInfo then
          t = string.split(ziyuanPosInfo.bullet, "#")
        end
        if #t > 1 then
          pBuild.m_pSkeleton:setPosition(cc.p(tonumber(t[1]), tonumber(t[2])))
        else
          pBuild.m_pSkeleton:setPosition(cc.p(0, 0))
        end
        local dir = tonumber(valueMap.dir) or 0
        if dir == 1 then
          pBuild.m_pSkeleton:setScaleX(-1)
        end
      elseif name == "shuijing" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        local t = string.split(self.m_mapInfo.crystal, "#")
        if #t > 0 then
          pBuild:SetResource(td.ResourceType.ShuiJing, tonumber(t[1]))
        else
          pBuild:SetResource(td.ResourceType.ShuiJing, 0)
        end
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
        pBuild:CreateAnimation("Spine/mapeffect/shuijingku_01")
        pBuild:PlayAnimation("caiji_01", true)
        local ziyuanPosInfo = MissionInfoManager:GetInstance():GetZiyuanPosInfo(mapId)
        local t = {}
        if ziyuanPosInfo then
          t = string.split(ziyuanPosInfo.crystal, "#")
        end
        if #t > 1 then
          pBuild.m_pSkeleton:setPosition(cc.p(tonumber(t[1]), tonumber(t[2])))
        else
          pBuild.m_pSkeleton:setPosition(cc.p(0, 0))
        end
        local dir = tonumber(valueMap.dir) or 0
        if dir == 1 then
          pBuild.m_pSkeleton:setScaleX(-1)
        end
      elseif name == "shiyou" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        local t = string.split(self.m_mapInfo.oil, "#")
        if #t > 0 then
          pBuild:SetResource(td.ResourceType.ShiYou, tonumber(t[1]))
        else
          pBuild:SetResource(td.ResourceType.ShiYou, 0)
        end
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
        pBuild:CreateAnimation("Spine/mapeffect/youku_01")
        pBuild:PlayAnimation("caiji_01", true)
        local ziyuanPosInfo = MissionInfoManager:GetInstance():GetZiyuanPosInfo(mapId)
        local t = {}
        if ziyuanPosInfo then
          t = string.split(ziyuanPosInfo.oil, "#")
        end
        if #t > 1 then
          pBuild.m_pSkeleton:setPosition(cc.p(tonumber(t[1]), tonumber(t[2])))
        else
          pBuild.m_pSkeleton:setPosition(cc.p(0, 0))
        end
        local dir = tonumber(valueMap.dir) or 0
        if dir == 1 then
          pBuild.m_pSkeleton:setScaleX(-1)
        end
      elseif name == "jinbi" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        local t = string.split(self.m_mapInfo.oil, "#")
        if #t > 0 then
          pBuild:SetResource(td.ResourceType.Gold, tonumber(t[1]))
        else
          pBuild:SetResource(td.ResourceType.Gold, 0)
        end
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
      elseif name == "nengliang" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        local t = string.split(self.m_mapInfo.crystal, "#")
        if #t > 0 then
          pBuild:SetResource(td.ResourceType.Exp, tonumber(t[1]))
        else
          pBuild:SetResource(td.ResourceType.Exp, 0)
        end
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
      elseif name == "s_nengliang" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        pBuild:SetResource(td.ResourceType.EnergyBall_s, 1)
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
        pBuild:CreateAnimation("Spine/mapeffect/huodongnengliang_01")
        pBuild:PlayAnimation("caiji_01", true)
        pBuild.m_pSkeleton:setPosition(cc.p(0, 0))
        local dir = tonumber(valueMap.dir) or 0
        if dir == 1 then
          pBuild.m_pSkeleton:setScaleX(-1)
        end
      elseif name == "m_nengliang" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        pBuild:SetResource(td.ResourceType.EnergyBall_m, 1)
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
        pBuild:CreateAnimation("Spine/mapeffect/huodongnengliang_01")
        pBuild:PlayAnimation("caiji_01", true)
        pBuild.m_pSkeleton:setPosition(cc.p(0, 0))
        local dir = tonumber(valueMap.dir) or 0
        if dir == 1 then
          pBuild.m_pSkeleton:setScaleX(-1)
        end
      elseif name == "l_nengliang" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        pBuild:SetResource(td.ResourceType.EnergyBall_l, 1)
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
        pBuild:CreateAnimation("Spine/mapeffect/huodongnengliang_01")
        pBuild:PlayAnimation("caiji_01", true)
        pBuild.m_pSkeleton:setPosition(cc.p(0, 0))
        local dir = tonumber(valueMap.dir) or 0
        if dir == 1 then
          pBuild.m_pSkeleton:setScaleX(-1)
        end
      elseif name == "s_xunzhang" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        pBuild:SetResource(td.ResourceType.Medal_s, 1)
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
        pBuild:CreateAnimation("Spine/mapeffect/huodongxunzhang_01")
        pBuild:PlayAnimation("caiji_01", true)
        pBuild.m_pSkeleton:setPosition(cc.p(0, 0))
        local dir = tonumber(valueMap.dir) or 0
        if dir == 1 then
          pBuild.m_pSkeleton:setScaleX(-1)
        end
      elseif name == "m_xunzhang" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        pBuild:SetResource(td.ResourceType.Medal_m, 1)
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
        pBuild:CreateAnimation("Spine/mapeffect/huodongxunzhang_01")
        pBuild:PlayAnimation("caiji_01", true)
        pBuild.m_pSkeleton:setPosition(cc.p(0, 0))
        local dir = tonumber(valueMap.dir) or 0
        if dir == 1 then
          pBuild.m_pSkeleton:setScaleX(-1)
        end
      elseif name == "l_xunzhang" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        pBuild:SetResource(td.ResourceType.Medal_l, 1)
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
        pBuild:CreateAnimation("Spine/mapeffect/huodongxunzhang_01")
        pBuild:PlayAnimation("caiji_01", true)
        pBuild.m_pSkeleton:setPosition(cc.p(0, 0))
        local dir = tonumber(valueMap.dir) or 0
        if dir == 1 then
          pBuild.m_pSkeleton:setScaleX(-1)
        end
      elseif name == "s_xingshi" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        pBuild:SetResource(td.ResourceType.StarStone_s, 1)
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
        pBuild:CreateAnimation("Spine/mapeffect/huodongxingshi_01")
        pBuild:PlayAnimation("caiji_01", true)
        pBuild.m_pSkeleton:setPosition(cc.p(0, 0))
        local dir = tonumber(valueMap.dir) or 0
        if dir == 1 then
          pBuild.m_pSkeleton:setScaleX(-1)
        end
      elseif name == "m_xingshi" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        pBuild:SetResource(td.ResourceType.StarStone_m, 1)
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
        pBuild:CreateAnimation("Spine/mapeffect/huodongxingshi_01")
        pBuild:PlayAnimation("caiji_01", true)
        pBuild.m_pSkeleton:setPosition(cc.p(0, 0))
        local dir = tonumber(valueMap.dir) or 0
        if dir == 1 then
          pBuild.m_pSkeleton:setScaleX(-1)
        end
      elseif name == "l_xingshi" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        pBuild:SetResource(td.ResourceType.StarStone_l, 1)
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(2 * fWidth, 2 * fHeight)
        pBuild:CreateAnimation("Spine/mapeffect/huodongxingshi_01")
        pBuild:PlayAnimation("caiji_01", true)
        pBuild.m_pSkeleton:setPosition(cc.p(0, 0))
        local dir = tonumber(valueMap.dir) or 0
        if dir == 1 then
          pBuild.m_pSkeleton:setScaleX(-1)
        end
      elseif name == "dong" then
        pBuild = actorMng:CreateActor(td.ActorType.ShadeHole, 1, true)
        pBuild:SetResource(td.ResourceType.Non, 0)
        pBuild:setPosition(px, py)
        pBuild:setContentSize(fWidth, fHeight)
      elseif name == "zhanlingshiyou" then
        pBuild = actorMng:CreateActor(td.ActorType.Stronghold, 1, true)
        local t = string.split(self.m_mapInfo.oil, "#")
        if #t > 0 then
          pBuild:SetResource(td.ResourceType.ZhanLingShiYou, tonumber(t[1]), tonumber(t[2]))
        else
          pBuild:SetResource(td.ResourceType.ZhanLingShiYou, 0, -1)
        end
        pBuild:SetCapturetime(tonumber(self.m_mapInfo.capture_time))
        pBuild:setPosition(px, py)
        pBuild:setContentSize(fWidth, fHeight)
      elseif name == "zhanlingshuijing" then
        pBuild = actorMng:CreateActor(td.ActorType.Stronghold, 1, true)
        local t = string.split(self.m_mapInfo.crystal, "#")
        if #t > 0 then
          pBuild:SetResource(td.ResourceType.ZhanLingShuiJing, tonumber(t[1]), tonumber(t[2]))
        else
          pBuild:SetResource(td.ResourceType.ZhanLingShuiJing, 0, -1)
        end
        pBuild:SetCapturetime(tonumber(self.m_mapInfo.capture_time))
        pBuild:setPosition(px, py)
        pBuild:setContentSize(fWidth, fHeight)
      elseif name == "zhanlingdanyao" then
        pBuild = actorMng:CreateActor(td.ActorType.Stronghold, 1, true)
        local t = string.split(self.m_mapInfo.bullet, "#")
        if #t > 0 then
          pBuild:SetResource(td.ResourceType.ZhanLingDanYao, tonumber(t[1]), tonumber(t[2]))
        else
          pBuild:SetResource(td.ResourceType.ZhanLingDanYao, 0, -1)
        end
        pBuild:SetCapturetime(tonumber(self.m_mapInfo.capture_time))
        pBuild:setPosition(px, py)
        pBuild:setContentSize(fWidth, fHeight)
      elseif name == "ta" then
        if tonumber(valueMap.id) == 8000 then
          if tonumber(valueMap.enemy) == 1 then
            pBuild = actorMng:CreateActor(td.ActorType.FangYuTa, tonumber(valueMap.id), true)
          else
            pBuild = actorMng:CreateActor(td.ActorType.FangYuTa, tonumber(valueMap.id), false)
          end
        else
          pBuild = actorMng:CreateActor(td.ActorType.FangYuTa, tonumber(valueMap.id), true)
        end
        pBuild:setPosition(px, py)
      elseif name == "door" then
        local door
        local dir = tonumber(valueMap.dir) or 0
        if dir == 0 then
          door = EffectManager:GetInstance():CreateEffect(2019, nil, nil, cc.p(px, py))
        else
          door = EffectManager:GetInstance():CreateEffect(2020, nil, nil, cc.p(px, py))
        end
        door:AddToMap(pMap)
      elseif name == "coffers" then
        pBuild = actorMng:CreateActor(td.ActorType.Coffers, 1, true)
        pBuild:setPosition(px + fWidth / 2, py)
        pBuild:setContentSize(fWidth, fHeight)
      end
      if pBuild then
        if name == "zhanlingshiyou" or name == "zhanlingshuijing" or name == "zhanlingdanyao" then
          pBuild:addTo(pMap, 9, pBuild:getTag())
        else
          pBuild:addTo(pMap, pMap:GetPiexlSize().height - pBuild:getPositionY(), pBuild:getTag())
        end
      end
    end
  end
end
function BattleScene:CreateHero()
  local pHero = self.m_gdMng:GetCurHero()
  if pHero then
    local pMap = self.m_gdMng:GetGameMap()
    local pos = self.m_gdMng:GetChangeHeroPos()
    if pos then
      self.m_gdMng:SetChangeHeroPos(nil)
    else
      pos = self.m_gdMng:GetBornPos()
    end
    pHero:setPosition(pos)
    pHero:addTo(pMap, pMap:GetPiexlSize().height - pHero:getPositionY(), pHero:getTag())
    local tilePos = pMap:GetTilePosFromPixelPos(pos)
    self.m_gdMng:SetActorInTile(PulibcFunc:GetInstance():GetIntForPoint(tilePos), PulibcFunc:GetInstance():GetIntForPoint(tilePos), pHero)
    self.m_uiLayer:UpdateHeroUI()
    if not self.m_gdMng:GetFocusNode() then
      self.m_gdMng:SetFocusNode(pHero)
    end
  end
end
function BattleScene:FightWin(event)
  local layer
  if self.m_mapInfo.type == td.MapType.Endless then
    layer = require("app.layers.battle.EndlessFightOverDlg").new()
  elseif self.m_mapInfo.type == td.MapType.Collect then
    layer = require("app.layers.battle.EndlessFightOverDlg").new()
  else
    local data = string.toTable(event:getDataString())
    layer = require("app.layers.battle.FightWinLayer").new(data)
  end
  self:addChild(layer, 102)
  self.m_uiLayer:StopPipe()
end
function BattleScene:FightLose()
  local FightLoseLayer
  if self.m_mapInfo.type == td.MapType.Endless then
    FightLoseLayer = require("app.layers.battle.EndlessFightOverDlg")
  else
    FightLoseLayer = require("app.layers.battle.FightLoseLayer")
  end
  local layer = FightLoseLayer.new()
  self:addChild(layer, 102)
  self.m_uiLayer:StopPipe()
end
function BattleScene:AddListeners()
  self:AddCustomEvent(td.ADD_SOLDIER_EVENT, handler(self, self.AddSoldier))
  self:AddCustomEvent(td.CHANGE_HERO, handler(self, self.ChangeHero))
  self:AddCustomEvent(td.FIGHT_WIN, handler(self, self.FightWin))
  self:AddCustomEvent(td.FIGHT_LOSE, handler(self, self.FightLose))
  self:AddCustomEvent(td.TROOP_TIME_OVER, handler(self, self.TroopTimeOver))
  self:AddCustomEvent(td.CHECK_GUIDE, handler(self, self.CheckGuide))
end
function BattleScene:ChangeHero(_event)
  if self.m_gdMng:AutoSelectHero() then
    self:CreateHero()
    local pCurHero = self.m_gdMng:GetCurHero()
    td.alert(string.format(g_LM:getBy("a00354"), pCurHero:GetData().name))
  end
end
function BattleScene:AddSoldier(_event)
  local data = string.toTable(_event:getDataString())
  local pMap = self.m_gdMng:GetGameMap()
  local pos = cc.p(data.x, data.y)
  local skeleton = SkeletonUnit:create("Spine/UI_effect/EFT_biaoji_01")
  skeleton:setPosition(pos)
  skeleton:setScale(0.7)
  pMap:addChild(skeleton, pMap:GetPiexlSize().height - pos.y)
  skeleton:PlayAni("animation01", false)
  skeleton:runAction(cca.seq({
    cca.delay(1.5),
    cca.fadeOut(0.5),
    cca.removeSelf()
  }))
  self:performWithDelay(function()
    local soldier
    local camp = ActorManager:GetInstance():FindCamp(data.index)
    if camp then
      camp:PlayCreateSoldierAni()
      soldier = ActorManager:GetInstance():CreateActorForCamp(data.index, pos)
      if soldier then
        pos = cc.p(soldier:getPosition())
      end
    else
      soldier = ActorManager:GetInstance():CreateActor(td.ActorType.Soldier, data.id, false)
      if soldier then
        local bornPos = self.m_gdMng:GetBornPos()
        soldier:setPosition(bornPos)
        ActorManager:GetInstance():CreateActorPath(soldier, bornPos, pos)
      end
    end
    if soldier then
      pMap:addChild(soldier, pMap:GetPiexlSize().height - soldier:getPositionY(), soldier:getTag())
      self:CreatePathSign(soldier:GetPath(), pos)
    end
  end, 0.2)
end
function BattleScene:CreatePathSign(path, beginPos)
  local pMap = self.m_gdMng:GetGameMap()
  local tileSize = pMap:GetTileSize()
  self.m_pathBatchNode:removeAllChildren()
  local vPixelPos = {}
  for i = 1, #path - 1 do
    local normalizePos = cc.pNormalize(cc.pSub(path[i + 1], path[i]))
    local pos = clone(path[i])
    while not cc.pFuzzyEqual(pos, path[i + 1], 0) do
      local tempPos = {}
      tempPos.x = cc.clampf(pos.x + normalizePos.x, path[i].x, path[i + 1].x)
      tempPos.y = cc.clampf(pos.y + normalizePos.y, path[i].y, path[i + 1].y)
      local tempPos1 = {}
      tempPos1.x = math.modf(tempPos.x)
      tempPos1.y = math.modf(tempPos.y)
      local tempPos2 = {}
      tempPos2.x = math.modf(pos.x)
      tempPos2.y = math.modf(pos.y)
      if not cc.pFuzzyEqual(tempPos1, tempPos2, 0) then
        table.insert(vPixelPos, pMap:GetPixelPosFromTilePos(tempPos1))
      end
      pos = clone(tempPos)
    end
  end
  local count = #vPixelPos
  for i = 1, count do
    local pos = {}
    if i > 2 and i < count - 2 then
      pos.x = (vPixelPos[i - 2].x + vPixelPos[i - 1].x + vPixelPos[i].x + vPixelPos[i + 1].x + vPixelPos[i + 2].x) / 5
      pos.y = (vPixelPos[i - 2].y + vPixelPos[i - 1].y + vPixelPos[i].y + vPixelPos[i + 1].y + vPixelPos[i + 2].y) / 5
    elseif i > 1 and i < count - 1 then
      pos.x = (vPixelPos[i - 1].x + vPixelPos[i].x + vPixelPos[i + 1].x) / 3
      pos.y = (vPixelPos[i - 1].y + vPixelPos[i].y + vPixelPos[i + 1].y) / 3
    else
      pos = vPixelPos[i]
    end
    if i % 3 == 0 then
      local sprite = display.newSprite(self.m_pathBatchNode:getTexture())
      sprite:setPosition(pos)
      self.m_pathBatchNode:addChild(sprite)
    end
  end
  self.m_pathBatchNode:runAction(cca.seq({
    cc.FadeTo:create(1, 0),
    cca.callFunc(function()
      self.m_pathBatchNode:removeAllChildren()
    end)
  }))
end
function BattleScene:MapMove(vPos, callFunc)
  self:SetPause(true)
  local pMap = self.m_gdMng:GetGameMap()
  pMap:SetIsTouchable(false)
  local actions = {}
  for i = 2, #vPos do
    do
      local moveTime = pMap:GetHighlightTime(vPos[i - 1], vPos[i], 1500 * td.GetAutoScale())
      local moveAction = cca.callFunc(function()
        pMap:HighlightPos(vPos[i], 1500 * td.GetAutoScale())
      end)
      local delayAction = cca.delay(moveTime + 1)
      table.insert(actions, moveAction)
      table.insert(actions, delayAction)
    end
  end
  table.insert(actions, cca.callFunc(callFunc))
  self:runAction(cca.seq(actions))
end
function BattleScene:UpdateMonster(dt)
  if not self.m_bFightStart then
    return
  end
  if not self.m_vMonsterPlans or #self.m_vMonsterPlans == 0 then
    self.m_gdMng:SetSingleCreateAll(true)
    return
  end
  local endTime = self.m_gdMng:GetEndTime()
  if endTime == -1 then
    return
  end
  self.m_fTimeInterval = self.m_fTimeInterval + dt
  if endTime > self.m_fTimeInterval then
    return
  end
  local pMap = self.m_gdMng:GetGameMap()
  local iCurMonsterCount = self.m_gdMng:GetCurMonsterCount()
  local iCurSubMonsterCount = self.m_gdMng:GetCurSubMonsterCount()
  if iCurSubMonsterCount <= self.m_gdMng:GetMaxSubMonsterCount() then
    local subAllCreate = true
    local pPlan = self.m_vMonsterPlans[iCurMonsterCount].monstInfos[iCurSubMonsterCount].subMonstInfos
    local didCreate = false
    self.m_iSubWaveIndex = self.m_iSubWaveIndex + 1
    if self.m_iSubWaveIndex > #pPlan then
      self.m_iSubWaveIndex = 1
    end
    local totalCount, count, index = #pPlan, 1, self.m_iSubWaveIndex
    while true do
      if not (totalCount >= count) or didCreate then
        break
      end
      local info = pPlan[index]
      for j, var in ipairs(info.paths) do
        if self.m_gdMng:IsPathClear(var.pathID) then
          info.count = info.num
          break
        end
      end
      if not info.count then
        local errorStr = "monster count error:wave=" .. iCurMonsterCount .. ",sub wave=" .. iCurSubMonsterCount
        td.alertDebug(errorStr)
        print(errorStr)
        return
      end
      if info.count < info.num then
        info.count = info.count + 1
        subAllCreate = false
        didCreate = true
        if not self.m_bWaveStart then
          TriggerManager:GetInstance():SendEvent({
            eType = td.ConditionType.BeforeRefreshMonster,
            waveCnt = iCurMonsterCount
          })
          if iCurMonsterCount <= #self.m_vMonsterPlans then
            local reward = self.m_vMonsterPlans[iCurMonsterCount].reward
            if reward then
              self.m_gdMng:UpdateCurResCount(reward)
            end
          end
          self.m_bWaveStart = true
        end
        local iRandom = 1 < #info.paths and math.random(#info.paths) or 1
        local pathID = info.paths[iRandom].pathID
        local bInverted = info.paths[iRandom].bInverted
        if pathID then
          local pActor = ActorManager:GetInstance():CreateActor(info.type, info.id, info.enemy)
          ActorManager:GetInstance():CreateActorPathById(pActor, pathID, bInverted, info.pos)
          pMap:addChild(pActor, pMap:GetPiexlSize().height - pActor:getPositionY(), pActor:getTag())
        else
          local errorStr = "path error,path count = 0,wave = " .. iCurMonsterCount .. ",sub wave = " .. iCurSubMonsterCount
          td.alertDebug(errorStr)
          print(errorStr)
          return
        end
      end
      count = count + 1
      index = totalCount >= index + 1 and index + 1 or 1
    end
    self.m_fTimeInterval = 0
    if subAllCreate then
      self.m_iSubWaveIndex = 0
      local iNextSubCount = iCurSubMonsterCount + 1
      if iNextSubCount <= self.m_gdMng:GetMaxSubMonsterCount() then
        self.m_gdMng:SetCurSubMonsterCount(iNextSubCount)
        local nextWaitTime = self.m_vMonsterPlans[iCurMonsterCount].monstInfos[iCurSubMonsterCount].nextWait or 0
        self.m_gdMng:SetEndTime(nextWaitTime)
      else
        self.m_bWaveStart = false
        local iNextCount = iCurMonsterCount + 1
        if iNextCount <= #self.m_vMonsterPlans then
          self.m_gdMng:SetCurMonsterCount(iNextCount)
          self.m_gdMng:SetCurSubMonsterCount(1)
          self.m_gdMng:SetMaxSubMonsterCount(#self.m_vMonsterPlans[iNextCount].monstInfos)
          local nextWaitTime = self.m_vMonsterPlans[iNextCount].tipInfo[1].waitTime or 0
          self.m_gdMng:SetEndTime(nextWaitTime)
          self:CreateTroopTip()
        else
          self.m_gdMng:SetSingleCreateAll(true)
        end
        TriggerManager:GetInstance():SendEvent({
          eType = td.ConditionType.AfterRefreshMonster,
          isAdd = false,
          waveCnt = iCurMonsterCount
        })
        if self.m_mapInfo.type == td.MapType.Endless then
          local msg = {}
          local data = {}
          data.team = self.m_gdMng:GetEndlessGroupId()
          msg.msgType = td.RequestID.EndlessFight
          msg.sendData = data
          TDHttpRequest:getInstance():Send(msg)
          if iCurMonsterCount == #self.m_vMonsterPlans then
            self:ResetMonsterPlanCount()
            self.m_gdMng:SetCurMonsterCount(1)
            self.m_gdMng:SetCurSubMonsterCount(1)
            self.m_gdMng:SetMaxSubMonsterCount(#self.m_vMonsterPlans[1].monstInfos)
            self.m_gdMng:SetMonsterWave(self.m_gdMng:GetMonsterWave() + 1)
            self:CreateTroopTip()
          end
        end
      end
    else
      self.m_gdMng:SetEndTime(td.NewActorGap)
    end
  end
end
function BattleScene:SaveMonsterPlan()
  self.m_vMonsterPlans = {}
  local plan = self.m_mapInfo.monster_plan
  if plan == "0" then
    return
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
          end
        end
        tipData.monstInfo = monstInfo
        table.insert(plan.tipInfo, tipData)
      else
        td.alertDebug("\229\135\186\229\133\181\230\150\185\230\161\136\233\133\141\231\189\174\230\156\137\232\175\175\239\188\154" .. t10[1])
        return
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
              else
                subinfo.num = tonumber(j4)
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
  self.m_gdMng:SetMaxMonsterCount(#self.m_vMonsterPlans)
  if #self.m_vMonsterPlans > 0 then
    self.m_gdMng:SetMaxSubMonsterCount(#self.m_vMonsterPlans[1].monstInfos)
    local nextWaitTime = self.m_vMonsterPlans[1].tipInfo[1].waitTime
    self.m_gdMng:SetEndTime(nextWaitTime)
    self:CreateTroopTip()
  end
  self.m_bFightStart = true
end
function BattleScene:ResetMonsterPlanCount()
  for _, plan in ipairs(self.m_vMonsterPlans) do
    for _, info in ipairs(plan.monstInfos) do
      for _, info2 in ipairs(info.subMonstInfos) do
        info2.count = 0
      end
    end
  end
end
function BattleScene:AddTouch()
  local touchPos
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:registerScriptHandler(function(_touch, _event)
    touchPos = _touch:getLocation()
    return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(_touch, _event)
    self:onTouchEnded(_touch:getLocation(), touchPos)
  end, cc.Handler.EVENT_TOUCH_ENDED)
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end
function BattleScene:CheckGuide(event)
  GuideManager.H_GuideUI(td.UIModule.BattleScene, self)
end
function BattleScene:onTouchEnded(endPos, beginPos)
  g_MC:UpdateOpTime()
  if cc.pFuzzyEqual(beginPos, endPos, 20) then
    local focusNode = self.m_gdMng:GetFocusNode()
    if focusNode then
      focusNode:DoFocus(beginPos)
    end
  end
end
function BattleScene:createCaiDan(missionId)
  local caiDanInfo = MissionInfoManager:GetInstance():GetMissionCaidan(missionId)
  local pMap = self.m_gdMng:GetGameMap()
  local effectManager = EffectManager:GetInstance()
  if caiDanInfo and #caiDanInfo.effectId > 0 then
    for i, effectId in ipairs(caiDanInfo.effectId) do
      local pEffect = effectManager:CreateEffect(effectId)
      pEffect:AddToMap(pMap)
    end
  end
  local pGroup = pMap:GetTileMap():getObjectGroup("caidan")
  if pGroup then
    local caidanVec = pGroup:getObjects()
    for i = 1, #caidanVec do
      local valueMap = caidanVec[i]
      local effectId = tonumber(valueMap.name)
      local px = tonumber(valueMap.x)
      local py = tonumber(valueMap.y)
      local scalex = tonumber(valueMap.scalex)
      local scaley = tonumber(valueMap.scaley)
      local rotation = tonumber(valueMap.rotation)
      local pEffect = effectManager:CreateEffect(effectId)
      pEffect:setPosition(px, py)
      if scalex or scaley then
        pEffect:setScale(scalex or 1, scaley or 1)
      end
      if rotation then
        pEffect:setRotation(rotation)
      end
      pEffect:AddToMap(pMap)
    end
  end
end
function BattleScene:AddTerrainEffect()
  local pMap = self.m_gdMng:GetGameMap()
  local effectMng = EffectManager:GetInstance()
  if self.m_mapInfo.terrain == td.TerrainType.Town or self.m_mapInfo.terrain == td.TerrainType.SeaSide then
    self:runAction(cca.repeatForever(cca.seq({
      cca.delay(60 + math.random(40)),
      cca.cb(function()
        local pEffect = effectMng:CreateEffect(2055)
        pEffect:AddToMap(pMap)
      end)
    })))
  elseif self.m_mapInfo.terrain == td.TerrainType.Desert then
    self:runAction(cca.repeatForever(cca.seq({
      cca.cb(function()
        local pEffect = effectMng:CreateEffect(2059)
        pEffect:setScale(td.GetAutoScale())
        self:addChild(pEffect, 100)
      end),
      cca.delay(60)
    })))
  elseif self.m_mapInfo.terrain == td.TerrainType.SnowField then
    local pEffect = effectMng:CreateEffect(2060)
    pEffect:setScale(td.GetAutoScale())
    self:addChild(pEffect, 100)
  elseif self.m_mapInfo.terrain == td.TerrainType.City then
    self:runAction(cca.repeatForever(cca.seq({
      cca.delay(60),
      cca.cb(function()
        local ids = {2055, 2056}
        local pEffect = effectMng:CreateEffect(ids[math.random(2)])
        pEffect:AddToMap(pMap)
      end)
    })))
  end
  if table.indexof({
    1013,
    2013,
    3013,
    5170,
    5171
  }, self.m_mapInfo.id) then
    local pEffect = effectMng:CreateEffect(2061)
    pEffect:setScale(td.GetAutoScale())
    self:addChild(pEffect, 100)
    local pEffect2 = effectMng:CreateEffect(2062)
    pEffect2:setScale(td.GetAutoScale())
    self:addChild(pEffect2, 100)
  end
  if self.m_mapInfo.id == 999 then
    local pEffect = effectMng:CreateEffect(2065)
    pEffect:setScale(td.GetAutoScale())
    self:addChild(pEffect, 100)
  end
end
function BattleScene:CreateTroopTip()
  local data = self.m_vMonsterPlans[self.m_gdMng:GetCurMonsterCount()].tipInfo
  local pActorInfoManager = ActorInfoManager.GetInstance()
  for _, value in ipairs(data) do
    if not self.m_gdMng:IsPathClear(value.pathID) then
      local career = pActorInfoManager:GetMonsterInfo(value.monstInfo[1].monstId).career
      if 0 ~= value.waitTime then
        if 4 == career then
          value.bFly = true
        else
          value.bFly = false
        end
        local pTip = require("app.widgets.TroopTip").new(value)
        local pMap = self.m_gdMng:GetGameMap()
        pTip:AddToMap(pMap)
        table.insert(self.m_TroopTips, pTip)
        value.index = #self.m_TroopTips
      end
    end
  end
end
function BattleScene:TroopTimeOver(_event)
  local data = string.toTable(_event:getDataString())
  for k, value in ipairs(self.m_TroopTips) do
    if data.index ~= k then
      value:RemoveOther()
      value:removeFromParent(true)
    end
  end
  self.m_TroopTips = {}
  self.m_gdMng:SetEndTime(0)
  if self.m_gdMng:GetCurSubMonsterCount() == 1 and (self.m_mapInfo.type == td.MapType.Endless or self.m_mapInfo.type == td.MapType.FangShou) then
    local curCount = (self.m_gdMng:GetMonsterWave() - 1) * #self.m_vMonsterPlans + self.m_gdMng:GetCurMonsterCount()
    td.dispatchEvent(td.ADD_WAVE, {
      curCount = curCount,
      maxWave = #self.m_vMonsterPlans
    })
  end
end
return BattleScene
