local GameControl = class("GameControl")
GameControl.s_ControlVec = GameControl.s_ControlVec or {}
function GameControl:ctor(eType)
  self.m_eType = eType
  table.insert(GameControl.s_ControlVec, self)
end
function GameControl:GetType()
  return self.m_eType
end
function GameControl:ClearValue()
end
function GameControl.ClearValueForType(eType)
  local count = #GameControl.s_ControlVec
  for i = count, 1, -1 do
    local v = GameControl.s_ControlVec[i]
    local curType = v:GetType()
    if eType <= curType then
      v:ClearValue()
    end
  end
  ZGameControl:ClearValueForType(eType)
end
function GameControl.DestroyAllControl()
  for i, v in ipairs(GameControl.s_ControlVec) do
    v:ClearValue()
  end
  GameControl.s_ControlVec = {}
end
function GameControl.Logout()
  require("app.net.NetManager")
  g_NetManager:stopHeartBeat()
  GameControl.ClearValueForType(td.GameControlType.Login)
  local loginScene = require("app.scenes.LoginScene").new()
  cc.Director:getInstance():replaceScene(loginScene)
  local TDHttpRequest = require("app.net.TDHttpRequest")
  TDHttpRequest:getInstance():ResetServer()
end
return GameControl
