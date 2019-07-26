local CountDownLabel = class("CountDownLabel", function(param)
  if param.bmpFont then
    return td.CreateBMF("", param.bmpFont)
  else
    return td.CreateLabel("", param.color, param.size)
  end
end)
local TYPE = {LOOP = 1, REMOVE = 2}
function CountDownLabel:ctor(param)
  self.m_iNum = param.num
  self.m_iCurNum = param.cur or self.m_iNum
  self.m_endCb = param.cb
  self.eType = param.type or TYPE.REMOVE
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
  self:scheduleUpdate()
end
function CountDownLabel:update(dt)
  self.m_iCurNum = self.m_iCurNum - dt
  if self.m_iCurNum <= 0 then
    self.m_iCurNum = 0
    if self.m_endCb then
      self.m_endCb()
    end
    if self.eType == TYPE.LOOP then
      self.m_iCurNum = self.m_iNum
    else
      self:unscheduleUpdate()
      self.m_endCb = nil
      self:removeFromParent()
    end
  end
  self:setString(self:GetTimeDownStr(self.m_iCurNum))
end
function CountDownLabel:GetTimeDownStr(time)
  if time < 0 then
    return ""
  end
  local min, sec = math.floor(time % 3600 / 60), math.floor(time % 60)
  local str = string.format("%02d:%02d", min, sec)
  return str
end
return CountDownLabel
