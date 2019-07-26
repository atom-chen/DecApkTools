local config = require("app.config.gizmos_config")
local GuildGizmo = class("GuildGizmo", function()
  return SkeletonUnit:create("Spine/guild/xiaoqiu_01")
end)
local directions = {
  Right = 1,
  Left = 2,
  Up = 3,
  Down = 4
}
function GuildGizmo:ctor(num)
  self.m_vPath = config[num]
  self.m_curPos = {}
  self.m_direction = directions.Left
  self.m_curAnime = nil
  self.m_scale = 0.5
  self.m_curPosIndex = 1
  self.m_bIsMoving = false
  self:setNodeEventEnabled(true)
end
function GuildGizmo:onEnter()
  self.m_curAnime = "run"
  self:PlayAni(self.m_curAnime, true)
  self:setScale(self.m_scale, self.m_scale)
  self:setPosition(self.m_vPath[self.m_curPosIndex].posX, self.m_vPath[self.m_curPosIndex].posY)
end
function GuildGizmo:onExit()
end
function GuildGizmo:GetScale()
  return self.m_scale
end
function GuildGizmo:Update(dt)
  if self.m_bIsMoving then
    return
  end
  local dest
  repeat
    dest = math.random(#self.m_vPath)
  until dest ~= self.m_curPosIndex
  self.m_bIsMoving = true
  local actionSeq = self:MakeAction(dest, bInvert)
  self:runAction(actionSeq)
end
function GuildGizmo:MakeAction(dest, bInvert)
  local actions = {}
  local moveChance = math.random()
  self:PlayAni(self.m_curAnime)
  local action = cca.delay(1)
  table.insert(actions, action)
  local subPath = self:GetRandomDirectionPath(dest)
  local curPos = cc.p(self:getPosition())
  for i, v in ipairs(subPath) do
    do
      local nextPos = cc.p(subPath[i].posX, subPath[i].posY)
      local distance = cc.pGetDistance(curPos, nextPos)
      local action = cca.spawn({
        cca.cb(function()
          local nextAnims = self:TurningAround(curPos, nextPos)
          if nextAnims[1] ~= nil then
            self:PlayAni(nextAnims[1], false)
          end
          self:PlayAni(self.m_curAnime, true, true)
        end),
        cca.moveTo(distance / 70, nextPos)
      })
      table.insert(actions, action)
      curPos = nextPos
    end
  end
  table.insert(actions, cca.delay(3))
  table.insert(actions, cca.cb(function()
    self.m_bIsMoving = false
  end))
  return cca.seq(actions)
end
function GuildGizmo:GetRandomDirectionPath(destPosIndex)
  local rand = math.random()
  local clockwiseOrNot = true
  if rand > 0.5 then
    clockwiseOrNot = true
  else
    clockwiseOrNot = false
  end
  return self:GetPath(destPosIndex, clockwiseOrNot)
end
function GuildGizmo:GetPath(destPosIndex, clockwise)
  local path = {}
  local pathArrayLength = #self.m_vPath
  if clockwise and destPosIndex > self.m_curPosIndex then
    for i = self.m_curPosIndex, destPosIndex do
      table.insert(path, self.m_vPath[i])
    end
  elseif clockwise and destPosIndex < self.m_curPosIndex then
    for i = self.m_curPosIndex, pathArrayLength + destPosIndex do
      if i <= pathArrayLength then
        table.insert(path, self.m_vPath[i])
      else
        table.insert(path, self.m_vPath[i - pathArrayLength])
      end
    end
  elseif not clockwise and destPosIndex > self.m_curPosIndex then
    for i = self.m_curPosIndex + pathArrayLength, destPosIndex, -1 do
      if i > pathArrayLength then
        table.insert(path, self.m_vPath[i - pathArrayLength])
      else
        table.insert(path, self.m_vPath[i])
      end
    end
  elseif not clockwise and destPosIndex < self.m_curPosIndex then
    for i = self.m_curPosIndex, destPosIndex, -1 do
      table.insert(path, self.m_vPath[i])
    end
  end
  self.m_curPosIndex = destPosIndex
  return path
end
function GuildGizmo:TurningAround(curPos, nextPos)
  local diffX = nextPos.x - curPos.x
  local diffY = nextPos.y - curPos.y
  local absDiffX = math.abs(diffX)
  local absDiffY = math.abs(diffY)
  local turnAni = {}
  if absDiffX > absDiffY and diffX > 0 and self.m_direction ~= directions.Right then
    self.m_direction = directions.Right
    local x = self:getScaleX()
    self:setScaleX(-1 * x)
    turnAni = {"ZtoY", "run"}
  elseif absDiffX > absDiffY and diffX < 0 and self.m_direction ~= directions.Left then
    self.m_direction = directions.Left
    turnAni = {"YtoZ", "run"}
  elseif absDiffX < absDiffY and diffY > 0 and self.m_direction ~= directions.Up then
    self.m_direction = directions.Up
    turnAni = {"ZtoB", "BMrun"}
  elseif absDiffX < absDiffY and diffY < 0 and self.m_direction ~= directions.Down then
    self.m_direction = directions.Down
    turnAni = {"BtoZ", "ZMrun"}
  else
    turnAni = {
      nil,
      self.m_curAnime
    }
  end
  self.m_curAnime = turnAni[2]
  return turnAni
end
return GuildGizmo
