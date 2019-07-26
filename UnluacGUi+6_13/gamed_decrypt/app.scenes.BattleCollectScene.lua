local BattleScene = require("app.scenes.BattleScene")
local GameDataManager = require("app.GameDataManager")
local UserDataManager = require("app.UserDataManager")
local TDHttpRequest = require("app.net.TDHttpRequest")
local BattleCollectScene = class("BattleCollectScene", BattleScene)
function BattleCollectScene:ctor()
  BattleCollectScene.super.ctor(self)
end
function BattleCollectScene:FightWin(data)
  local layer = require("app.layers.battle.CollectOverDlg").new()
  self:addChild(layer, 102)
  local missionInfo = require("app.info.MissionInfoManager"):GetInstance():GetMissionInfo(td.COLLECT_ID)
  UserDataManager:GetInstance():UpdateDungeonTime(td.UIModule.Collect, -1)
end
function BattleCollectScene:AddListeners()
  BattleCollectScene.super.AddListeners(self)
  TDHttpRequest:getInstance():registerCallback(td.RequestID.GetCollectReward, handler(self, self.FightWin))
end
function BattleCollectScene:RemoveListeners()
  BattleCollectScene.super.RemoveListeners(self)
  TDHttpRequest:getInstance():unregisterCallback(td.RequestID.GetCollectReward)
end
return BattleCollectScene
