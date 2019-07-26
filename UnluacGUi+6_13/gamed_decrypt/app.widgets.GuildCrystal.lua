local root = "Spine/guild/GH_shuijing_"
local GuildCrystal = class("GuildCrystal", function(num)
  return SkeletonUnit:create(root .. string.format("%02d", num))
end)
local crystals = {}
function GuildCrystal:ctor(num)
  self:setNodeEventEnabled(true)
end
function GuildCrystal:onEnter()
  self:PlayAni("animation", true)
end
function GuildCrystal:onExit()
end
return GuildCrystal
