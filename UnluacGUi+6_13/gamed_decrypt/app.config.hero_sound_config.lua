local hero_sound_config = {
  [10] = {
    move = {
      1000,
      1001,
      1002,
      1003
    },
    magic = {1004, 1005},
    dead = {1006}
  },
  [11] = {
    move = {
      1007,
      1008,
      1009,
      1010
    },
    magic = {1012, 1020},
    dead = {1013}
  },
  [12] = {
    move = {
      1014,
      1015,
      1016
    },
    magic = {1017, 1018},
    dead = {1019}
  },
  [13] = {
    move = {
      1021,
      1022,
      1023
    },
    magic = {1024, 1025},
    dead = {1026}
  },
  [14] = {
    move = {
      1027,
      1028,
      1029,
      1030
    },
    magic = {1031, 1032},
    dead = {1033}
  },
  [15] = {
    move = {
      1034,
      1035,
      1036,
      1037
    },
    magic = {1038, 1039},
    dead = {1040}
  },
  [16] = {
    move = {
      1041,
      1042,
      1043,
      1044
    },
    magic = {1045},
    dead = {1046}
  },
  [17] = {
    move = {
      1047,
      1048,
      1049,
      1050
    },
    magic = {1051, 1052},
    dead = {1053}
  },
  [18] = {
    move = {
      1054,
      1055,
      1056
    },
    magic = {1057, 1058},
    dead = {1059}
  }
}
function GetHeroSoundConfig(heroId)
  local id = math.floor(heroId / 100)
  return hero_sound_config[id]
end
