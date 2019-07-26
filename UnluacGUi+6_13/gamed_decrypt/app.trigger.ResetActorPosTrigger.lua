local scheduler = require("framework.scheduler")
local GameDataManager = require("app.GameDataManager")
local EffectManager = require("app.effect.EffectManager")
local TriggerBase = import(".TriggerBase")
local ResetActorPosTrigger = class("ResetActorPosTrigger", TriggerBase)
function ResetActorPosTrigger:ctor(iID, iType, bLoop, conditionType, data)
  ResetActorPosTrigger.super.ctor(self, iID, iType, bLoop, conditionType)
  self.m_monsterId = data.monsterId
  self.m_pathId = data.pathId
  self.m_bInverted = data.bInverted
  self.m_bMoveViewPort = data.bMoveViewPort
  self.m_yOffset = data.yOffset or 0
end
function ResetActorPosTrigger:Active()
  ResetActorPosTrigger.super.Active(self)
  local waveCtn = GameDataManager.GetInstance():GetCurMonsterCount()
  local pMonster = require("app.actor.ActorManager").GetInstance():FindActorById(self.m_monsterId, true)
  if pMonster then
    do
      local dataManager = require("app.GameDataManager").GetInstance()
      local pMap = dataManager:GetGameMap()
      local pMapInfo = dataManager:GetGameMapInfo()
      local beginPos = {}
      local endPos = {}
      pMonster:SetPathId(self.m_pathId, self.m_bInverted)
      local path = pMap:GetMapPath(self.m_pathId)
      local vTemp = {}
      for i, v in ipairs(path) do
        local tempPos = pMap:GetPixelPosFromTilePos(PulibcFunc:GetInstance():GetPointForInt(v))
        table.insert(vTemp, tempPos)
      end
      pMonster:SetPath(vTemp)
      if table.getn(vTemp) > 0 then
        if self.m_bInverted then
          beginPos = vTemp[#vTemp - 1]
          endPos = vTemp[1]
          pMonster:SetCurPathCount(#vTemp)
        else
          local curIndex = 2
          beginPos = vTemp[curIndex]
          endPos = vTemp[#vTemp]
          pMonster:SetCurPathCount(curIndex)
        end
      end
      if table.getn(vTemp) > 1 then
        if endPos.x >= beginPos.x then
          pMonster:SetDirType(td.DirType.Right)
        else
          pMonster:SetDirType(td.DirType.Left)
        end
      end
      if self.m_bMoveViewPort then
        local speed = 2000
        local pos = cc.p(pMonster:getPosition())
        pos.y = pos.y + self.m_yOffset
        dataManager:GetGameMap():HighlightPos(pos, speed, function()
          pMonster:FlyToPos(beginPos, nil)
        end)
      else
        pMonster:FlyToPos(beginPos, nil)
      end
    end
  end
end
return ResetActorPosTrigger
