local BattleScene = require("app.scenes.BattleScene")
local ActorManager = require("app.actor.ActorManager")
local TriggerManager = require("app.trigger.TriggerManager")
local UserDataManager = require("app.UserDataManager")
local GameDataManager = require("app.GameDataManager")
local StrongInfoManager = require("app.info.StrongInfoManager")
local ActorInfoManager = require("app.info.ActorInfoManager")
local BattleRobScene = class("BattleRobScene", BattleScene)
function BattleRobScene:ctor()
  BattleRobScene.super.ctor(self)
end
function BattleRobScene:didEnter()
  BattleRobScene.super.didEnter(self)
  require("app.GuideManager").H_StartGuideGroup(6020)
end
function BattleRobScene:FightWin()
  if self:getChildByTag(102) then
    return
  end
  local FightWinLayer = require("app.layers.battle.RobFightOverDlg")
  local layer = FightWinLayer.new()
  self:addChild(layer, 102)
  self.m_uiLayer:StopPipe()
end
function BattleRobScene:UpdateMonster(dt)
  if not self.m_bFightStart then
    return
  end
  if not self.m_vMonsterPlans then
    return
  end
  local pMap = self.m_gdMng:GetGameMap()
  local iCurMonsterCount = self.m_gdMng:GetCurMonsterCount()
  if iCurMonsterCount <= #self.m_vMonsterPlans then
    local bAllCreate = true
    local pPlan = self.m_vMonsterPlans[iCurMonsterCount]
    for i, info in ipairs(pPlan) do
      if info.count < info.num then
        info.count = info.count + 1
        bAllCreate = false
        local tempInfo
        if info.enemy then
          local heroData = self.m_PVPHeroDatas[info.id]
          GameDataManager:GetInstance():AddBattleLog(info.id, 0)
          tempInfo = StrongInfoManager:GetInstance():GetHeroFinalInfo(heroData, self.m_PVPWeaponDatas, self.m_PVPSkillDatas, self.m_PVPGemDatas)
          local lindex = string.findLast(tempInfo.image, "/")
          local file = string.sub(tempInfo.image, lindex + 1)
          tempInfo.image = "Spine/yingxiong/bianse/" .. file
        end
        local pActor = ActorManager:GetInstance():CreateActor(info.type, info.id, info.enemy, tempInfo)
        pActor:setPosition(info.pos)
        pActor:SetFinalTargetPos(info.pos)
        pMap:addChild(pActor, pMap:GetPiexlSize().height - pActor:getPositionY(), pActor:getTag())
      end
    end
    self.m_gdMng:SetSingleCreateAll(bAllCreate)
    if bAllCreate then
      self.m_gdMng:SetCurMonsterCount(iCurMonsterCount + 1)
      self.m_fTimeInterval = 0
      if self.m_gdMng:GetWaveType() == td.WaveType.ByTime then
        self.m_gdMng:SetEndTime(self.m_mapInfo.time)
      else
        self.m_gdMng:SetEndTime(0)
      end
    else
      self.m_fTimeInterval = 0
    end
  end
end
function BattleRobScene:SaveMonsterPlan()
  self.m_vMonsterPlans = {}
  local enemyData = GameDataManager:GetInstance():GetRobData()
  local plan = {}
  local pMap = self.m_gdMng:GetGameMap()
  local vPos = {
    cc.p(1350, 650),
    cc.p(1300, 600),
    cc.p(1400, 700)
  }
  local count = 1
  for id, v in pairs(enemyData.heros) do
    local info = {}
    info.count = 0
    info.type = td.ActorType.Hero
    info.enemy = true
    info.id = id
    info.num = 1
    info.pos = vPos[count]
    info.weaponId = v.attackSite
    info.defenseId = v.defSite
    if v.activeSkill then
      info.activeSkill = {}
      for j, k in ipairs(v.activeSkill) do
        table.insert(info.activeSkill, k)
      end
    end
    if v.passiveSkill then
      info.passiveSkill = {}
      for j, k in ipairs(v.passiveSkill) do
        table.insert(info.passiveSkill, k)
      end
    end
    table.insert(plan, info)
    count = count + 1
  end
  table.insert(self.m_vMonsterPlans, plan)
  self.m_PVPWeaponDatas = enemyData.weapons
  self.m_PVPHeroDatas = enemyData.heros
  self.m_PVPSkillDatas = enemyData.skills
  self.m_PVPGemDatas = enemyData.gems
  self.m_gdMng:SetMaxMonsterCount(#self.m_vMonsterPlans)
  self.m_gdMng:SetMaxSubMonsterCount(1)
  self.m_gdMng:SetEndTime(0)
  self.m_bFightStart = true
end
return BattleRobScene
