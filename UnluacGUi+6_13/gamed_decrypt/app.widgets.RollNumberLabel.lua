local RollNumberLabel = class("RollNumberLabel", function(param)
  if param.bmpFont then
    return td.CreateBMF(tostring(param.num), param.bmpFont)
  else
    return td.CreateLabel(tostring(param.num), param.color, param.size)
  end
end)
function RollNumberLabel:ctor(param)
  self.m_iNum = param.num
  self.m_iCurNum = self.m_iNum
  self.m_iGap = 0
  self.m_bIsRolling = false
  self.m_endCb = param.cb
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.update))
end
function RollNumberLabel:SetNumber(num)
  if self.m_iNum == num then
    return
  end
  self.m_iNum = num
  self.m_iGap = math.floor((self.m_iNum - self.m_iCurNum) / 30)
  if not self.m_bIsRolling then
    self:scheduleUpdate()
    self.m_bIsRolling = true
  end
end
function RollNumberLabel:update(dt)
  if self.m_iCurNum == self.m_iNum then
    if self.m_endCb then
      self.m_endCb()
    end
    self.m_bIsRolling = false
    self:unscheduleUpdate()
    return
  end
  local gap = self.m_iNum - self.m_iCurNum
  if math.abs(gap) < 30 then
    if gap > 0 then
      self.m_iCurNum = self.m_iCurNum + 1
    else
      self.m_iCurNum = self.m_iCurNum - 1
    end
  else
    self.m_iCurNum = self.m_iCurNum + self.m_iGap
  end
  self:setString(tostring(self.m_iCurNum))
end
return RollNumberLabel
