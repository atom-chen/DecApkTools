local animations = {
  MoveUp = "BMrun",
  TurnDown = "BtoZ",
  TurnLeft = "YtoZ",
  MoveDown = "ZMrun",
  TurnUp = "ZtoB",
  TurnRight = "ZtoY",
  Horizontal = "run"
}
local gizmos = {
  [1] = {
    {posX = 742, posY = 80},
    {posX = 703, posY = 147},
    {posX = 674, posY = 280},
    {posX = 633, posY = 351}
  },
  [2] = {
    {posX = 430, posY = 440},
    {posX = 737, posY = 450}
  },
  [3] = {
    {posX = 237, posY = 320},
    {posX = 274, posY = 374},
    {posX = 455, posY = 387},
    {posX = 469, posY = 282},
    {posX = 306, posY = 208},
    {posX = 237, posY = 320}
  },
  [4] = {
    {posX = 847, posY = 337},
    {posX = 786, posY = 415},
    {posX = 767, posY = 485},
    {posX = 668, posY = 499}
  }
}
return gizmos
