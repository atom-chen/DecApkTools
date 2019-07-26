local GridProgressBar = class("GridProgressBar", function(max)
  local width = max * 16 + 6
  return display.newScale9Sprite("UI/scale9/bantoumingdikuang3.png", 0, 0, cc.size(width, 20))
end)
function GridProgressBar:ctor(max)
  self.m_percent = 100
  self.m_max = max
  self.m_vGrid = {}
  for i = 1, self.m_max do
    local bg = display.newSprite("UI/common/grid1.png")
    bg:pos(i * 16 - 5, 10):addTo(self)
    local grid = display.newSprite("UI/common/grid2.png")
    td.AddRelaPos(bg, grid)
    table.insert(self.m_vGrid, grid)
  end
end
function GridProgressBar:SetPercent(per)
  self.m_percent = cc.clampf(per, 0, 100)
  local showCount = math.floor(self.m_percent / 100 * self.m_max)
  for i = 1, self.m_max do
    if i <= showCount then
      self.m_vGrid[i]:setVisible(true)
    else
      self.m_vGrid[i]:setVisible(false)
    end
  end
end
function GridProgressBar:GetPercent()
  return self.m_percent
end
return GridProgressBar
