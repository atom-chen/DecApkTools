local GameSceneBase = require("app.scenes.GameSceneBase")
local MissionInfoManager = require("app.info.MissionInfoManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local SkillInfoManager = require("app.info.SkillInfoManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local EffectManager = require("app.effect.EffectManager")
local GameDataManager = require("app.GameDataManager")
local UserDataManager = require("app.UserDataManager")
local UnitDataManager = require("app.UnitDataManager")
local LoadingScene = class("LoadingScene", GameSceneBase)
local LoadingSteps = {
  Sound = 1,
  Particle = 2,
  Path = 3,
  Spine = 4,
  Frames = 5,
  Image = 6
}
local MAX_NUM_PER_TIME = 10
local LOADING_STR = "Loading......"
function LoadingScene:ctor(mapId, missionId, vSelSoldier)
  LoadingScene.super.ctor(self)
  self.timeInterval = 0
  self.index = 7
  self:Init(mapId, missionId, vSelSoldier)
  self:InitUI()
end
function LoadingScene:onEnter()
  self:PrepareLoading()
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
  self:scheduleUpdate()
  cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end
function LoadingScene:onExit()
  self:removeNodeEventListener(handler(self, self.update))
  self:unscheduleUpdate()
end
function LoadingScene:update(dt)
  if self.m_bIsLoading then
    if self.m_eCurStep == LoadingSteps.Sound then
      self:LoadSounds()
    elseif self.m_eCurStep == LoadingSteps.Particle then
      self:LoadParticles()
    elseif self.m_eCurStep == LoadingSteps.Path then
      self.m_eCurStep = self.m_eCurStep + 1
    elseif self.m_eCurStep == LoadingSteps.Spine then
      self:LoadSpines()
    elseif self.m_eCurStep == LoadingSteps.Frames then
      self:LoadFrames()
    elseif self.m_eCurStep == LoadingSteps.Image then
      self:LoadImages()
    end
  end
  self.timeInterval = self.timeInterval + dt
  if self.timeInterval >= 0.3 then
    self.labelLoading:setString(string.sub(LOADING_STR, 1, self.index))
    self.index = self.index + 1
    if self.index > 13 then
      self.index = 7
    end
    self.timeInterval = 0
  end
end
function LoadingScene:Init(mapId, missonId, vSelSoldier)
  local commonRes = require("app.config.common_res")
  self.m_mapId = mapId
  self.m_missonId = missonId or mapId
  self.m_mapInfo = MissionInfoManager:GetInstance():GetMissionInfo(self.m_mapId)
  self.m_vImages = {}
  self.m_vSounds = clone(commonRes.sound)
  self.m_vSkeletons = clone(commonRes.spine)
  self.m_vFrames = clone(commonRes.frames)
  self.m_vParticles = {}
  if vSelSoldier then
    self.m_vSelSoldier = vSelSoldier
  else
    self.m_vSelSoldier = require("app.UnitDataManager"):GetInstance():GetUnlockedRoleIds()
  end
  self.m_bIsLoading = false
  self.m_eCurStep = 0
  self.m_iCurSchedule = 0
  self.m_iMaxSchedule = 0
  self.m_iSubSchedule = 1
end
function LoadingScene:InitUI()
  self.m_uiRoot = cc.uiloader:load("CCS/LoadingLayer.csb")
  self.m_scale = math.min(display.size.width / 1136, display.size.height / 640)
  self.m_uiRoot:setContentSize(display.width, display.height)
  ccui.Helper:doLayout(self.m_uiRoot)
  self:addChild(self.m_uiRoot, 1)
  td.SetAutoScale(self.m_uiRoot, td.UIPosHorizontal.Center, td.UIPosVertical.Center)
  self.m_tipBg = cc.uiloader:seekNodeByName(self.m_uiRoot, "TipBg")
  self.m_tipBg:setOpacity(0)
  self:CreateLoadingLabel()
  local missionData = UserDataManager:GetInstance():GetCityData(self.m_missonId)
  local story = MissionInfoManager:GetInstance():GetMissionInfo(self.m_mapId).story
  if not missionData and story and story ~= "" then
    self.m_uiRoot:setVisible(false)
    local interlude = require("app.layers.InterludeLayer").new(self.m_mapId, handler(self, self.ShowTip))
    self:addChild(interlude, td.ZORDER.Info)
  else
    self:ShowTip()
  end
end
function LoadingScene:CreateLoadingLabel()
  self.labelLoading = td.CreateBMF("Loading", "Fonts/Loading.fnt")
  self.labelLoading:align(display.LEFT_CENTER, 880, 50):scale(0.7):addTo(self.m_tipBg:getParent())
end
function LoadingScene:ShowTip()
  self.m_uiRoot:setVisible(true)
  self.m_tipBg:runAction(cca.spawn({
    cca.fadeIn(0.5),
    cca.seq({
      cca.delay(0.3),
      cca.cb(function()
        td.CreateUIEffect(self.m_tipBg, "Spine/UI_effect/EFT_tipstexiao_01")
      end),
      cca.delay(0.3),
      cca.cb(function()
        local allTips = require("app.config.tip_run_word")
        local tipStr = allTips[math.random(#allTips)]
        local label = td.CreateLabel(g_LM:getBy(tipStr), td.WHITE, 24)
        label:setAnchorPoint(0.5, 0.5)
        td.AddRelaPos(self.m_tipBg, label, 1, cc.p(0.5, 0.35))
      end),
      cca.delay(0.7),
      cca.cb(function()
        self:StartLoading()
      end)
    })
  }))
end
function LoadingScene:PrepareLoading()
  local aiMng = ActorInfoManager:GetInstance()
  local skillMng = SkillInfoManager:GetInstance()
  local vEffectIds = {}
  local vSkills = {}
  local caiDanInfo = MissionInfoManager:GetInstance():GetMissionCaidan(self.m_mapId)
  if caiDanInfo then
    for i, effectId in ipairs(caiDanInfo.effectId) do
      table.insert(vEffectIds, effectId)
    end
  end
  if self.m_mapInfo.terrain == td.TerrainType.Town or self.m_mapInfo.terrain == td.TerrainType.SeaSide then
    table.insert(vEffectIds, 2055)
  end
  if self.m_mapInfo.type ~= td.MapType.ZiYuan and self.m_mapInfo.type ~= td.MapType.Rob and self.m_mapInfo.type ~= td.MapType.Collect then
    local herosData = StrongInfoManager:GetInstance():GetBattleHeros()
    for i, pData in pairs(herosData) do
      local heroInfo = pData.heroInfo
      table.insert(self.m_vImages, heroInfo.image .. td.PNG_Suffix)
      table.insert(self.m_vSkeletons, heroInfo.image)
      table.insert(self.m_vSounds, heroInfo.normal_sound)
      for j, skillId in ipairs(heroInfo.skill) do
        table.insert(vSkills, skillId)
      end
      local skillLib = UserDataManager:GetInstance():GetSkillLib()
      for j, skillId in ipairs(pData.passiveSkill) do
        if skillId ~= 0 then
          table.insert(vSkills, skillLib[skillId].skill_id)
        end
      end
      for j, skillId in ipairs(pData.activeSkill) do
        if skillId ~= 0 then
          table.insert(vSkills, skillLib[skillId].skill_id)
        end
      end
    end
  end
  for i, roleId in pairs(self.m_vSelSoldier) do
    local info = aiMng:GetSoldierInfo(roleId)
    if info then
      table.insert(self.m_vImages, info.camp_file .. td.PNG_Suffix)
      table.insert(self.m_vSkeletons, info.camp_file)
      table.insert(self.m_vImages, info.image .. td.PNG_Suffix)
      table.insert(self.m_vSkeletons, info.image)
      table.insert(self.m_vSounds, info.normal_sound)
      for j, skillId in ipairs(info.skill) do
        table.insert(vSkills, skillId)
      end
    end
  end
  local vMonsterIds, vPaths = self:DecodeMonsterPlan()
  for k, id in pairs(vMonsterIds) do
    local pData = aiMng:GetMonsterInfo(id)
    if pData then
      table.insert(self.m_vImages, pData.image .. td.PNG_Suffix)
      table.insert(self.m_vSkeletons, pData.image)
      table.insert(self.m_vSounds, pData.normal_sound)
      for i, skillId in ipairs(pData.skill) do
        table.insert(vSkills, skillId)
      end
    end
  end
  for i, skillId in ipairs(vSkills) do
    local skillInfo = skillMng:GetInfo(skillId)
    if skillInfo.atk_effect ~= 0 then
      table.insert(vEffectIds, skillInfo.atk_effect)
    end
    if skillInfo.track_effect ~= 0 then
      table.insert(vEffectIds, skillInfo.track_effect)
    end
    if skillInfo.hurt_effect ~= 0 then
      table.insert(vEffectIds, skillInfo.hurt_effect)
    end
    for i, soundId in ipairs(skillInfo.sounds) do
      table.insert(self.m_vSounds, soundId)
    end
  end
  for i, effectId in ipairs(vEffectIds) do
    local vRes, vSound = EffectManager.GetEffectRes(effectId)
    for j, res in ipairs(vRes) do
      if res.file ~= "" then
        if res.type == td.EffectType.Spine then
          table.insert(self.m_vSkeletons, res.file)
          table.insert(self.m_vImages, res.file .. td.PNG_Suffix)
        elseif res.type == td.EffectType.Particle then
          table.insert(self.m_vParticles, res.file)
        elseif res.type == td.EffectType.Frames then
          table.insert(self.m_vFrames, res.file .. ".plist")
        elseif res.type == td.EffectType.Image and string.byte(res.file) ~= 35 then
          table.insert(self.m_vImages, res.file .. td.PNG_Suffix)
        end
      end
    end
    for j, soundId in ipairs(vSound) do
      table.insert(self.m_vSounds, soundId)
    end
  end
  self.m_vSounds = table.unique(self.m_vSounds)
  self.m_iMaxSchedule = table.nums(self.m_vSounds) + #self.m_vParticles + #self.m_vSkeletons + #self.m_vImages + #self.m_vFrames
end
function LoadingScene:DecodeMonsterPlan()
  local vMonsterIds = {}
  local vPaths = {}
  do
    local plan = self.m_mapInfo.monster_plan
    if plan == "0" then
    else
      local t1 = string.split(plan, ";")
      for i1, j1 in ipairs(t1) do
        if "" == j1 then
          break
        end
        local t5 = string.split(j1, "$")
        local t10 = string.split(t5[1], "&")
        local waveInf = {}
        local t2 = string.split(t10[2], ":")
        for i2, j2 in ipairs(t2) do
          local t3 = string.split(j2, "%")
          local t31 = string.split(t3[1], "@")
          for i30, j30 in ipairs(t31) do
            local t32 = string.split(j30, "|")
            for i3, j3 in ipairs(t32) do
              local t4 = string.split(j3, "#")
              for i4, j4 in ipairs(t4) do
                if i3 == 1 then
                  if i4 == 1 then
                    table.insert(vMonsterIds, tonumber(j4))
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
                  vPaths[j4] = pathInfo
                end
              end
            end
          end
        end
      end
    end
  end
  if self.m_mapId == td.TRAIN_ID then
    local monsterPlan = require("app.config.guide_monsters")
    for i, wave in ipairs(monsterPlan) do
      for j, var in ipairs(wave) do
        table.insert(vMonsterIds, var.id)
      end
    end
  end
  vMonsterIds = table.unique(vMonsterIds, true)
  return vMonsterIds, vPaths
end
function LoadingScene:StartLoading()
  self.m_bIsLoading = true
  self.m_eCurStep = LoadingSteps.Sound
end
function LoadingScene:LoadSounds()
  G_SoundUtil:PreloadMusic(self.m_mapInfo.bgm)
  for k, var in pairs(self.m_vSounds) do
    G_SoundUtil:PreloadSound(var)
    self:UpdateProgress()
  end
  self.m_eCurStep = self.m_eCurStep + 1
end
function LoadingScene:LoadParticles()
  for i, var in ipairs(self.m_vParticles) do
    ParticleManager:GetInstance():AddPlistData(var .. ".plist")
    self:UpdateProgress()
  end
  self.m_eCurStep = self.m_eCurStep + 1
end
function LoadingScene:LoadSpines()
  local count = #self.m_vSkeletons
  local iStart, iEnd = self.m_iSubSchedule, self.m_iSubSchedule + MAX_NUM_PER_TIME
  for i = iStart, iEnd do
    if i > count then
      self.m_eCurStep = self.m_eCurStep + 1
      self.m_iSubSchedule = 1
      return
    end
    SkeletonManager:GetInstance():PreloadData(self.m_vSkeletons[i])
    self:UpdateProgress()
    self.m_iSubSchedule = self.m_iSubSchedule + 1
  end
end
function LoadingScene:LoadFrames()
  for i, var in ipairs(self.m_vFrames) do
    cc.SpriteFrameCache:getInstance():addSpriteFrames(var)
    self:UpdateProgress()
  end
  self.m_eCurStep = self.m_eCurStep + 1
end
function LoadingScene:LoadImages()
  for i, var in ipairs(self.m_vImages) do
    display.addImageAsync(var, handler(self, self.UpdateProgress))
  end
  self.m_bIsLoading = false
end
function LoadingScene:UpdateProgress()
  self.m_iCurSchedule = self.m_iCurSchedule + 1
  if self.m_iCurSchedule >= self.m_iMaxSchedule then
    self:LoadingDone()
  end
end
function LoadingScene:LoadingDone()
  self.m_tipBg:runAction(cca.seq({
    cca.fadeOut(0.3),
    cca.delay(0.2),
    cca.cb(function()
      GameDataManager:GetInstance():SetCampRole(self.m_vSelSoldier)
      local battleScene
      if self.m_mapId == 7010 then
        local trialData = GameDataManager:GetInstance():GetTrialData()
        GameDataManager:GetInstance():SetTrialGameMap(trialData.mode, trialData.level)
        battleScene = require("app.scenes.BattleTrialScene").new()
      else
        GameDataManager:GetInstance():SetGameMap(self.m_mapId, self.m_missonId)
        if self.m_mapInfo.type == td.MapType.PVP then
          battleScene = require("app.scenes.BattlePVPScene").new()
        elseif self.m_mapInfo.type == td.MapType.Rob then
          battleScene = require("app.scenes.BattleRobScene").new()
        elseif self.m_mapInfo.type == td.MapType.Collect then
          battleScene = require("app.scenes.BattleCollectScene").new()
        elseif self.m_mapInfo.type == td.MapType.PVPGuild then
          battleScene = require("app.scenes.BattlePVPGuildScene").new()
        elseif self.m_mapInfo.type == td.MapType.Boss then
          battleScene = require("app.scenes.BattleBossGuildScene").new()
        elseif self.m_mapInfo.type == td.MapType.Bomb then
          battleScene = require("app.scenes.BattleBombScene").new()
        elseif self.m_mapId == td.TRAIN_ID then
          battleScene = require("app.scenes.BattleGuideScene").new()
        else
          battleScene = require("app.scenes.BattleScene").new()
        end
      end
      cc.Director:getInstance():replaceScene(battleScene)
    end)
  }))
end
return LoadingScene
