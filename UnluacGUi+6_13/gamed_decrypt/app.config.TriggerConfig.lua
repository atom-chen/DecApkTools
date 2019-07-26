local TriggerConfig = {
  [1] = {
    id = 1,
    triggerType = 1,
    loop = false,
    mapType = 100,
    conditionType = 1,
    className = "GameWinTrigger",
    conditions = {
      {
        type = 1,
        mapType = 0,
        isEnemy = true
      },
      {type = 2, mapType = 1},
      {type = 2, mapType = 4},
      {type = 2, mapType = 7},
      {type = 2, mapType = 9},
      {
        type = 4,
        mapType = 2,
        isEnemy = true
      },
      {
        type = 4,
        mapType = 3,
        isEnemy = true
      },
      {
        type = 4,
        mapType = 5,
        isEnemy = true
      },
      {
        type = 4,
        mapType = 8,
        isEnemy = true
      },
      {
        type = 4,
        mapType = 10,
        isEnemy = true
      },
      {
        type = 4,
        mapType = 11,
        isEnemy = true
      },
      {
        type = 4,
        mapType = 11,
        isEnemy = false
      },
      {
        type = 5,
        mapType = 11,
        timeOver = true
      },
      {
        type = 5,
        mapType = 7,
        timeOver = true
      },
      {
        type = 5,
        mapType = 9,
        timeOver = true
      },
      {type = 11, monsterId = 9005}
    }
  },
  [2] = {
    id = 2,
    triggerType = 1,
    loop = false,
    mapType = 100,
    conditionType = 1,
    className = "GameLoseTrigger",
    conditions = {
      {
        type = 1,
        mapType = 0,
        isEnemy = false
      },
      {
        type = 1,
        mapType = 3,
        isEnemy = false
      },
      {
        type = 1,
        mapType = 1,
        isEnemy = false
      },
      {
        type = 1,
        mapType = 4,
        isEnemy = false
      },
      {
        type = 1,
        mapType = 5,
        isEnemy = false
      },
      {
        type = 1,
        mapType = 10,
        isEnemy = false
      },
      {
        type = 1,
        mapType = 6,
        isEnemy = false
      },
      {
        type = 4,
        mapType = 5,
        isEnemy = false
      },
      {
        type = 4,
        mapType = 10,
        isEnemy = false
      },
      {
        type = 4,
        mapType = 8,
        isEnemy = false
      },
      {
        type = 5,
        mapType = 0,
        timeOver = true
      },
      {
        type = 5,
        mapType = 1,
        timeOver = true
      },
      {
        type = 5,
        mapType = 2,
        timeOver = true
      },
      {
        type = 5,
        mapType = 4,
        timeOver = true
      },
      {
        type = 5,
        mapType = 5,
        timeOver = true
      },
      {
        type = 5,
        mapType = 10,
        timeOver = true
      },
      {
        type = 5,
        mapType = 8,
        timeOver = true
      }
    }
  },
  [3] = {
    id = 3,
    triggerType = 2,
    loop = false,
    conditionType = 0,
    className = "GuideTrigger",
    group = 1,
    conditions = {
      {type = 27, over = false}
    }
  },
  [4] = {
    id = 4,
    triggerType = 2,
    loop = true,
    conditionType = 1,
    className = "GuideTrigger",
    groupSerial = {
      2,
      3,
      4,
      5,
      6
    },
    conditions = {
      {
        type = 25,
        group = {
          1,
          2,
          3,
          4,
          5
        }
      }
    }
  },
  [5] = {
    id = 5,
    triggerType = 2,
    loop = false,
    conditionType = 1,
    className = "OpenUIModuleTrigger",
    moduleId = 1,
    conditions = {
      {type = 28, group = 2}
    }
  },
  [6] = {
    id = 6,
    triggerType = 2,
    loop = false,
    conditionType = 1,
    className = "OpenUIModuleTrigger",
    moduleId = 6,
    subIndex = {3},
    conditions = {
      {type = 28, group = 4}
    }
  },
  [80151] = {
    id = 80151,
    triggerType = 0,
    loop = false,
    mapId = {999},
    conditionType = 0,
    className = "EnableMapTrigger",
    touchAble = false,
    conditions = {}
  },
  [80152] = {
    id = 80152,
    triggerType = 0,
    loop = false,
    mapId = {999},
    conditionType = 1,
    className = "EnableMapTrigger",
    touchAble = true,
    conditions = {
      {type = 25, group = 999}
    }
  },
  [80153] = {
    id = 80153,
    triggerType = 0,
    loop = false,
    mapId = {999},
    conditionType = 0,
    className = "GuideTrigger",
    group = 999,
    conditions = {}
  },
  [80154] = {
    id = 80154,
    triggerType = 0,
    loop = true,
    mapId = {999},
    conditionType = 1,
    className = "GamePauseTrigger",
    pause = true,
    conditions = {
      {
        type = 24,
        group = 999,
        guideIdx = 1
      },
      {
        type = 4,
        mapType = 0,
        isEnemy = false
      },
      {
        type = 24,
        group = 999,
        guideIdx = 13
      }
    }
  },
  [80155] = {
    id = 80155,
    triggerType = 0,
    loop = true,
    mapId = {999},
    conditionType = 1,
    className = "GamePauseTrigger",
    pause = false,
    conditions = {
      {
        type = 19,
        group = 999,
        guideIdx = 4
      },
      {
        type = 19,
        group = 999,
        guideIdx = 11
      },
      {
        type = 24,
        group = 999,
        guideIdx = 14
      },
      {
        type = 10,
        monsterId = 9009,
        time = 2
      }
    }
  },
  [80157] = {
    id = 80157,
    triggerType = 0,
    loop = true,
    mapId = {999},
    conditionType = 1,
    className = "GuideContinueTrigger",
    conditions = {
      {type = 20, triggerId = 80159},
      {type = 20, triggerId = 80160},
      {type = 20, triggerId = 80162},
      {
        type = 11,
        monsterId = 9009,
        hpRatio = 0.2
      }
    }
  },
  [80158] = {
    id = 80158,
    triggerType = 0,
    loop = false,
    mapId = {999},
    conditionType = 0,
    className = "ActorTouchEnableTrigger",
    touchAble = false,
    conditions = {}
  },
  [80159] = {
    id = 80159,
    triggerType = 0,
    loop = false,
    mapId = {999},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 2,
    conditions = {
      {
        type = 19,
        group = 999,
        guideIdx = 1
      }
    }
  },
  [80160] = {
    id = 80160,
    triggerType = 0,
    loop = false,
    mapId = {999},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 1750,
    y = 680,
    conditions = {
      {
        type = 19,
        group = 999,
        guideIdx = 2
      }
    }
  },
  [80161] = {
    id = 80161,
    triggerType = 0,
    loop = false,
    mapId = {999},
    conditionType = 1,
    className = "DispatchEventTrigger",
    eventName = td.GUIDE_CREATE_MONSTER,
    conditions = {
      {type = 20, triggerId = 80160}
    }
  },
  [80162] = {
    id = 80162,
    triggerType = 0,
    loop = false,
    mapId = {999},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 1050,
    y = 580,
    conditions = {
      {
        type = 4,
        mapType = 0,
        isEnemy = false
      }
    }
  },
  [80163] = {
    id = 80163,
    triggerType = 0,
    loop = false,
    mapId = {999},
    conditionType = 1,
    className = "DispatchEventTrigger",
    eventName = td.GUIDE_HERO_WALK,
    conditions = {
      {
        type = 19,
        group = 999,
        guideIdx = 13
      }
    }
  },
  [80165] = {
    id = 80165,
    triggerType = 0,
    loop = false,
    mapId = {999},
    conditionType = 1,
    className = "DispatchEventTrigger",
    eventName = td.GUIDE_CREATE_HERO,
    conditions = {
      {
        type = 19,
        group = 999,
        guideIdx = 8
      }
    }
  },
  [80166] = {
    id = 80166,
    triggerType = 0,
    loop = true,
    mapId = {999},
    conditionType = 1,
    className = "DispatchEventTrigger",
    eventName = td.GUIDE_HERO,
    conditions = {
      {
        type = 19,
        group = 999,
        guideIdx = 13
      }
    }
  },
  [80167] = {
    id = 80167,
    triggerType = 0,
    loop = false,
    mapId = {999},
    conditionType = 1,
    className = "NothingnessStateTrigger",
    isAdd = true,
    monsterId = 9009,
    addBuffIds = {354, 367},
    dirType = 1,
    conditions = {
      {type = 25, group = 999}
    }
  },
  [80168] = {
    id = 80168,
    triggerType = 0,
    loop = false,
    mapId = {999},
    conditionType = 1,
    className = "DispatchEventTrigger",
    eventName = td.GUIDE_REMOVE_MONSTER,
    conditions = {
      {type = 25, group = 999}
    }
  },
  [80169] = {
    id = 80169,
    triggerType = 0,
    loop = false,
    mapId = {999},
    conditionType = 1,
    className = "DispatchEventTrigger",
    eventName = td.GUIDE_MAP,
    conditions = {
      {
        type = 10,
        monsterId = 9009,
        time = 2
      }
    }
  },
  [10001] = {
    id = 10001,
    triggerType = 0,
    loop = true,
    mapId = {1000},
    conditionType = 0,
    className = "EnableMapTrigger",
    touchAble = false,
    conditions = {
      {type = 28, group = 1000},
      {
        type = 19,
        group = 1000,
        guideIdx = 11
      }
    }
  },
  [10002] = {
    id = 10002,
    triggerType = 0,
    loop = true,
    mapId = {1000},
    conditionType = 1,
    className = "EnableMapTrigger",
    touchAble = true,
    conditions = {
      {
        type = 19,
        group = 1000,
        guideIdx = 10
      },
      {type = 25, group = 1000}
    }
  },
  [10003] = {
    id = 10003,
    triggerType = 0,
    loop = false,
    mapId = {1000},
    conditionType = 0,
    className = "GuideTrigger",
    group = 1000,
    conditions = {}
  },
  [10004] = {
    id = 10004,
    triggerType = 0,
    loop = false,
    mapId = {1000},
    conditionType = 0,
    className = "GamePauseTrigger",
    pause = true,
    conditions = {
      {type = 28, group = 1000},
      {
        type = 19,
        group = 1000,
        guideIdx = 11
      }
    }
  },
  [10005] = {
    id = 10005,
    triggerType = 0,
    loop = true,
    mapId = {1000},
    conditionType = 1,
    className = "GamePauseTrigger",
    pause = false,
    conditions = {
      {
        type = 19,
        group = 1000,
        guideIdx = 10
      },
      {type = 25, group = 1000}
    }
  },
  [10006] = {
    id = 10006,
    triggerType = 0,
    loop = false,
    mapId = {1000},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 2600,
    y = 700,
    conditions = {
      {
        type = 19,
        group = 1000,
        guideIdx = 1
      }
    }
  },
  [10007] = {
    id = 10007,
    triggerType = 0,
    loop = false,
    mapId = {1000},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 1,
    conditions = {
      {
        type = 19,
        group = 1000,
        guideIdx = 4
      }
    }
  },
  [10008] = {
    id = 10008,
    triggerType = 0,
    loop = true,
    mapId = {1000},
    conditionType = 1,
    className = "GuideContinueTrigger",
    conditions = {
      {type = 20, triggerId = 10006}
    }
  },
  [10009] = {
    id = 10009,
    triggerType = 0,
    loop = false,
    mapId = {1000},
    conditionType = 1,
    className = "DispatchEventTrigger",
    delay = 1,
    eventName = td.SHOW_MISSON_TARGET,
    conditions = {
      {type = 25, group = 1000}
    }
  },
  [10010] = {
    id = 10010,
    triggerType = 0,
    loop = true,
    mapId = {1000},
    conditionType = 1,
    className = "DispatchEventTrigger",
    eventName = td.GUIDE_UI,
    conditions = {
      {type = 20, triggerId = 10007},
      {type = 29}
    }
  },
  [10011] = {
    id = 10011,
    triggerType = 0,
    loop = false,
    mapId = {1000},
    conditionType = 1,
    className = "DispatchEventTrigger",
    eventName = td.GUIDE_HERO,
    conditions = {
      {
        type = 9,
        waveCnt = {1}
      }
    }
  },
  [10012] = {
    id = 10012,
    triggerType = 0,
    loop = false,
    mapId = {1000},
    conditionType = 1,
    className = "DispatchEventTrigger",
    eventName = td.GUIDE_MAP,
    conditions = {
      {type = 25, group = 1000}
    }
  },
  [10013] = {
    id = 10013,
    triggerType = 0,
    loop = false,
    mapId = {1000},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 2600,
    y = 700,
    conditions = {
      {
        type = 19,
        group = 1000,
        guideIdx = 11
      }
    }
  },
  [10101] = {
    id = 10101,
    triggerType = 0,
    loop = false,
    mapId = {1004},
    conditionType = 0,
    className = "GuideTrigger",
    group = 1004,
    conditions = {}
  },
  [10102] = {
    id = 10102,
    triggerType = 0,
    loop = true,
    mapId = {1004},
    conditionType = 1,
    className = "GuideContinueTrigger",
    conditions = {
      {type = 29},
      {type = 20, triggerId = 10103},
      {type = 20, triggerId = 10104}
    }
  },
  [10103] = {
    id = 10103,
    triggerType = 0,
    loop = false,
    mapId = {1004},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 1060,
    y = 425,
    conditions = {
      {
        type = 19,
        group = 1004,
        guideIdx = 3
      }
    }
  },
  [10104] = {
    id = 10104,
    triggerType = 0,
    loop = false,
    mapId = {1004},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 2040,
    y = 425,
    conditions = {
      {
        type = 19,
        group = 1004,
        guideIdx = 4
      }
    }
  },
  [10105] = {
    id = 10105,
    triggerType = 0,
    loop = false,
    mapId = {1004},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 1,
    conditions = {
      {
        type = 19,
        group = 1004,
        guideIdx = 5
      }
    }
  },
  [10106] = {
    id = 10106,
    triggerType = 0,
    loop = false,
    mapId = {1004},
    conditionType = 1,
    className = "NewEffectTrigger",
    effectIds = {2308, 2309},
    conditions = {
      {
        type = 19,
        group = 1004,
        guideIdx = 4
      }
    }
  },
  [10107] = {
    id = 10107,
    triggerType = 0,
    loop = false,
    mapId = {1004},
    conditionType = 1,
    className = "NewEffectTrigger",
    effectIds = {2310, 2311},
    conditions = {
      {
        type = 19,
        group = 1004,
        guideIdx = 5
      }
    }
  },
  [10108] = {
    id = 10108,
    triggerType = 0,
    loop = false,
    mapId = {1004},
    conditionType = 1,
    className = "DispatchEventTrigger",
    delay = 1,
    eventName = td.SHOW_MISSON_TARGET,
    conditions = {
      {type = 25, group = 1004}
    }
  },
  [10201] = {
    id = 10201,
    triggerType = 0,
    loop = false,
    mapId = {1001},
    conditionType = 0,
    className = "EnableMapTrigger",
    touchAble = false,
    conditions = {
      {type = 28, group = 1001}
    }
  },
  [10202] = {
    id = 10202,
    triggerType = 0,
    loop = false,
    mapId = {1001},
    conditionType = 1,
    className = "EnableMapTrigger",
    touchAble = true,
    conditions = {
      {type = 25, group = 1001}
    }
  },
  [10203] = {
    id = 10203,
    triggerType = 0,
    loop = false,
    mapId = {1001},
    conditionType = 0,
    className = "GuideTrigger",
    group = 1001,
    conditions = {}
  },
  [10204] = {
    id = 10204,
    triggerType = 0,
    loop = false,
    mapId = {1001},
    conditionType = 0,
    className = "GamePauseTrigger",
    pause = true,
    conditions = {
      {type = 28, group = 1001}
    }
  },
  [10205] = {
    id = 10205,
    triggerType = 0,
    loop = true,
    mapId = {1001},
    conditionType = 1,
    className = "GamePauseTrigger",
    pause = false,
    conditions = {
      {type = 25, group = 1001}
    }
  },
  [10206] = {
    id = 10206,
    triggerType = 0,
    loop = true,
    mapId = {1001},
    conditionType = 1,
    className = "GuideContinueTrigger",
    conditions = {
      {type = 29},
      {type = 20, triggerId = 10207},
      {type = 20, triggerId = 10208}
    }
  },
  [10207] = {
    id = 10207,
    triggerType = 0,
    loop = false,
    mapId = {1001},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 2,
    conditions = {
      {
        type = 19,
        group = 1001,
        guideIdx = 1
      }
    }
  },
  [10208] = {
    id = 10208,
    triggerType = 0,
    loop = false,
    mapId = {1001},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 1,
    conditions = {
      {
        type = 19,
        group = 1001,
        guideIdx = 5
      }
    }
  },
  [10209] = {
    id = 10209,
    triggerType = 0,
    loop = false,
    mapId = {1001},
    conditionType = 1,
    className = "DispatchEventTrigger",
    delay = 1,
    eventName = td.SHOW_MISSON_TARGET,
    conditions = {
      {type = 25, group = 1001}
    }
  },
  [10301] = {
    id = 10301,
    triggerType = 0,
    loop = false,
    mapId = {1008},
    conditionType = 0,
    className = "GuideTrigger",
    group = 1008,
    conditions = {}
  },
  [10302] = {
    id = 10302,
    triggerType = 0,
    loop = false,
    mapId = {1008},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 2250,
    y = 750,
    conditions = {
      {
        type = 19,
        group = 1008,
        guideIdx = 2
      }
    }
  },
  [10303] = {
    id = 10303,
    triggerType = 0,
    loop = false,
    mapId = {1008},
    conditionType = 1,
    className = "GuideContinueTrigger",
    conditions = {
      {type = 20, triggerId = 10302}
    }
  },
  [10304] = {
    id = 10304,
    triggerType = 0,
    loop = false,
    mapId = {1008},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 725,
    y = 1275,
    conditions = {
      {
        type = 19,
        group = 1008,
        guideIdx = 5
      }
    }
  },
  [10305] = {
    id = 10305,
    triggerType = 0,
    loop = false,
    mapId = {1008},
    conditionType = 1,
    className = "GuideContinueTrigger",
    conditions = {
      {type = 20, triggerId = 10304}
    }
  },
  [10306] = {
    id = 10306,
    triggerType = 0,
    loop = false,
    mapId = {1008},
    conditionType = 1,
    className = "DispatchEventTrigger",
    delay = 1,
    eventName = td.SHOW_MISSON_TARGET,
    conditions = {
      {type = 25, group = 1008}
    }
  },
  [10307] = {
    id = 10307,
    triggerType = 0,
    loop = false,
    mapId = {1008},
    conditionType = 0,
    className = "EnableMapTrigger",
    touchAble = false,
    conditions = {
      {type = 28, group = 1008}
    }
  },
  [10308] = {
    id = 10308,
    triggerType = 0,
    loop = false,
    mapId = {1008},
    conditionType = 1,
    className = "EnableMapTrigger",
    touchAble = true,
    conditions = {
      {type = 25, group = 1008}
    }
  },
  [10309] = {
    id = 10309,
    triggerType = 0,
    loop = false,
    mapId = {1008},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 1,
    conditions = {
      {type = 25, group = 1008}
    }
  },
  [10310] = {
    id = 10310,
    triggerType = 0,
    loop = false,
    mapId = {1008},
    conditionType = 1,
    className = "NewEffectTrigger",
    effectIds = {2320},
    conditions = {
      {
        type = 19,
        group = 1008,
        guideIdx = 3
      }
    }
  },
  [10311] = {
    id = 10311,
    triggerType = 0,
    loop = false,
    mapId = {1008},
    conditionType = 1,
    className = "NewEffectTrigger",
    effectIds = {2321},
    conditions = {
      {
        type = 19,
        group = 1008,
        guideIdx = 7
      }
    }
  },
  [10401] = {
    id = 10401,
    triggerType = 0,
    loop = false,
    mapId = {1002},
    conditionType = 0,
    className = "EnableMapTrigger",
    touchAble = false,
    conditions = {
      {type = 28, group = 1002}
    }
  },
  [10402] = {
    id = 10402,
    triggerType = 0,
    loop = false,
    mapId = {1002},
    conditionType = 1,
    className = "EnableMapTrigger",
    touchAble = true,
    conditions = {
      {type = 25, group = 1002}
    }
  },
  [10403] = {
    id = 10403,
    triggerType = 0,
    loop = false,
    mapId = {1002},
    conditionType = 0,
    className = "GuideTrigger",
    group = 1002,
    conditions = {}
  },
  [10404] = {
    id = 10404,
    triggerType = 0,
    loop = false,
    mapId = {1002},
    conditionType = 0,
    className = "GamePauseTrigger",
    pause = true,
    conditions = {
      {type = 28, group = 1002}
    }
  },
  [10405] = {
    id = 10405,
    triggerType = 0,
    loop = true,
    mapId = {1002},
    conditionType = 1,
    className = "GamePauseTrigger",
    pause = false,
    conditions = {
      {type = 25, group = 1002}
    }
  },
  [10406] = {
    id = 10406,
    triggerType = 0,
    loop = true,
    mapId = {1002},
    conditionType = 1,
    className = "GuideContinueTrigger",
    conditions = {
      {type = 29}
    }
  },
  [10407] = {
    id = 10407,
    triggerType = 0,
    loop = false,
    mapId = {1002},
    conditionType = 1,
    className = "DispatchEventTrigger",
    delay = 1,
    eventName = td.SHOW_MISSON_TARGET,
    conditions = {
      {type = 25, group = 1002}
    }
  },
  [10701] = {
    id = 10701,
    triggerType = 0,
    loop = true,
    mapId = {
      1003,
      2003,
      3003
    },
    conditionType = 1,
    className = "PlayerSoundTrigger",
    sound = 701,
    conditions = {
      {
        type = 0,
        waveCnt = {-1}
      }
    }
  },
  [10801] = {
    id = 10801,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 0,
    className = "GuideTrigger",
    group = 1009,
    conditions = {}
  },
  [10802] = {
    id = 10802,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 0,
    className = "EnableMapTrigger",
    touchAble = false,
    conditions = {
      {type = 28, group = 1009}
    }
  },
  [10803] = {
    id = 10803,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 1,
    className = "EnableMapTrigger",
    touchAble = true,
    conditions = {
      {type = 25, group = 1009}
    }
  },
  [10804] = {
    id = 10804,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 0,
    className = "GamePauseTrigger",
    pause = true,
    conditions = {
      {type = 28, group = 1009}
    }
  },
  [10805] = {
    id = 10805,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 1,
    className = "GamePauseTrigger",
    pause = false,
    conditions = {
      {type = 25, group = 1009}
    }
  },
  [10806] = {
    id = 10806,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 1,
    className = "DispatchEventTrigger",
    delay = 1,
    eventName = td.SHOW_MISSON_TARGET,
    conditions = {
      {type = 25, group = 1009}
    }
  },
  [10807] = {
    id = 10807,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 2260,
    y = 255,
    delay = 0.5,
    conditions = {
      {
        type = 19,
        group = 1009,
        guideIdx = 2
      }
    }
  },
  [10808] = {
    id = 10808,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 2260,
    y = 1255,
    conditions = {
      {type = 20, triggerId = 10807}
    }
  },
  [10809] = {
    id = 10809,
    triggerType = 0,
    loop = true,
    mapId = {1009},
    conditionType = 1,
    className = "GuideContinueTrigger",
    conditions = {
      {type = 20, triggerId = 10808},
      {type = 20, triggerId = 10810},
      {type = 20, triggerId = 10811}
    }
  },
  [10810] = {
    id = 10810,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 2260,
    y = 755,
    conditions = {
      {
        type = 19,
        group = 1009,
        guideIdx = 7
      }
    }
  },
  [10811] = {
    id = 10811,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 255,
    y = 180,
    conditions = {
      {
        type = 19,
        group = 1009,
        guideIdx = 10
      }
    }
  },
  [10812] = {
    id = 10812,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 1,
    conditions = {
      {type = 25, group = 1009}
    }
  },
  [10813] = {
    id = 10813,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 1,
    className = "NewEffectTrigger",
    effectIds = {2317},
    conditions = {
      {type = 20, triggerId = 10808}
    }
  },
  [10814] = {
    id = 10814,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 1,
    className = "NewEffectTrigger",
    effectIds = {2318},
    conditions = {
      {type = 20, triggerId = 10810}
    }
  },
  [10815] = {
    id = 10815,
    triggerType = 0,
    loop = false,
    mapId = {1009},
    conditionType = 1,
    className = "NewEffectTrigger",
    effectIds = {2319},
    conditions = {
      {type = 20, triggerId = 10811}
    }
  },
  [11201] = {
    id = 11201,
    triggerType = 0,
    loop = false,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "NothingnessStateTrigger",
    isAdd = true,
    monsterId = 9002,
    addBuffIds = {354, 367},
    addSkillIds = {},
    removeBuffIds = {},
    removeSkillIds = {3107},
    dirType = -1,
    conditions = {
      {type = 6, monsterId = 9002}
    }
  },
  [11205] = {
    id = 11205,
    triggerType = 0,
    loop = true,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "NothingnessStateTrigger",
    isAdd = true,
    monsterId = 9003,
    addBuffIds = {354, 367},
    addSkillIds = {},
    removeBuffIds = {},
    removeSkillIds = {},
    dirType = -1,
    conditions = {
      {type = 6, monsterId = 9003}
    }
  },
  [11208] = {
    id = 11208,
    triggerType = 0,
    loop = true,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "NothingnessStateTrigger",
    isAdd = true,
    monsterId = 9004,
    addBuffIds = {354, 367},
    addSkillIds = {},
    removeBuffIds = {},
    removeSkillIds = {},
    dirType = -1,
    conditions = {
      {type = 6, monsterId = 9004}
    }
  },
  [11202] = {
    id = 11202,
    triggerType = 0,
    loop = false,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "GuideTrigger",
    group = 1011,
    conditions = {
      {
        type = 10,
        monsterId = 9004,
        time = 1
      }
    }
  },
  [11215] = {
    id = 11214,
    triggerType = 0,
    loop = false,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "GuideContinueTrigger",
    conditions = {
      {
        type = 9,
        waveCnt = {3}
      }
    }
  },
  [11206] = {
    id = 11206,
    triggerType = 0,
    loop = true,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "ResetActorPosTrigger",
    isAdd = true,
    monsterId = 9003,
    pathId = 3,
    bInverted = true,
    bMoveViewPort = true,
    yOffset = 200,
    conditions = {
      {
        type = 19,
        group = 1011,
        guideIdx = 3
      }
    }
  },
  [11207] = {
    id = 11207,
    triggerType = 0,
    loop = true,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 0,
    className = "NothingnessStateTrigger",
    isAdd = false,
    monsterId = 9003,
    addBuffIds = {},
    addSkillIds = {},
    removeBuffIds = {354, 367},
    removeSkillIds = {},
    dirType = -1,
    conditions = {
      {
        type = 10,
        monsterId = 9003,
        time = 2
      }
    }
  },
  [11216] = {
    id = 11214,
    triggerType = 0,
    loop = false,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "GuideContinueTrigger",
    conditions = {
      {
        type = 9,
        waveCnt = {6}
      }
    }
  },
  [11209] = {
    id = 11209,
    triggerType = 0,
    loop = true,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "ResetActorPosTrigger",
    isAdd = true,
    monsterId = 9004,
    pathId = 6,
    bInverted = true,
    bMoveViewPort = true,
    yOffset = 200,
    conditions = {
      {
        type = 19,
        group = 1011,
        guideIdx = 4
      }
    }
  },
  [11210] = {
    id = 11210,
    triggerType = 0,
    loop = true,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 0,
    className = "NothingnessStateTrigger",
    isAdd = false,
    monsterId = 9004,
    addBuffIds = {},
    addSkillIds = {},
    removeBuffIds = {354, 367},
    removeSkillIds = {},
    dirType = -1,
    conditions = {
      {
        type = 10,
        monsterId = 9004,
        time = 2
      }
    }
  },
  [11214] = {
    id = 11214,
    triggerType = 0,
    loop = false,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "GuideContinueTrigger",
    conditions = {
      {
        type = 9,
        waveCnt = {8}
      }
    }
  },
  [11204] = {
    id = 11204,
    triggerType = 0,
    loop = true,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "ResetActorPosTrigger",
    isAdd = true,
    monsterId = 9002,
    pathId = 14,
    bInverted = true,
    bMoveViewPort = true,
    yOffset = 350,
    conditions = {
      {
        type = 19,
        group = 1011,
        guideIdx = 5
      }
    }
  },
  [11203] = {
    id = 11203,
    triggerType = 0,
    loop = false,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 0,
    className = "NothingnessStateTrigger",
    isAdd = false,
    monsterId = 9002,
    addBuffIds = {},
    addSkillIds = {},
    removeBuffIds = {354, 367},
    removeSkillIds = {},
    dirType = -1,
    conditions = {
      {
        type = 10,
        monsterId = 9002,
        time = 2
      }
    }
  },
  [11213] = {
    id = 11213,
    triggerType = 0,
    loop = true,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 1,
    delay = 0.5,
    conditions = {
      {
        type = 19,
        group = 1011,
        guideIdx = 2
      },
      {
        type = 10,
        monsterId = 9003,
        time = 2
      },
      {
        type = 10,
        monsterId = 9004,
        time = 2
      },
      {
        type = 10,
        monsterId = 9002,
        time = 2
      }
    }
  },
  [11217] = {
    id = 11217,
    triggerType = 0,
    loop = true,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "EnableMapTrigger",
    touchAble = false,
    conditions = {
      {type = 6, monsterId = 9002},
      {
        type = 19,
        group = 1011,
        guideIdx = 3
      },
      {
        type = 19,
        group = 1011,
        guideIdx = 4
      },
      {
        type = 19,
        group = 1011,
        guideIdx = 5
      }
    }
  },
  [11218] = {
    id = 11218,
    triggerType = 0,
    loop = true,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "EnableMapTrigger",
    touchAble = true,
    conditions = {
      {type = 20, triggerId = 11213}
    }
  },
  [11219] = {
    id = 11219,
    triggerType = 0,
    loop = false,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2112,
    animName = "animation_02",
    conditions = {
      {
        type = 0,
        waveCnt = {3}
      }
    }
  },
  [11220] = {
    id = 11220,
    triggerType = 0,
    loop = false,
    mapId = {
      1011,
      2011,
      3011
    },
    conditionType = 1,
    className = "MapBlockTrigger",
    blockId = 10,
    conditions = {
      {
        type = 0,
        waveCnt = {3}
      }
    }
  },
  [11221] = {
    id = 11221,
    triggerType = 0,
    loop = false,
    mapId = {5120, 5121},
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2112,
    animName = "animation_02",
    conditions = {
      {
        type = 0,
        waveCnt = {1}
      }
    }
  },
  [11222] = {
    id = 11222,
    triggerType = 0,
    loop = false,
    mapId = {5120, 5121},
    conditionType = 1,
    className = "MapBlockTrigger",
    blockId = 10,
    conditions = {
      {
        type = 0,
        waveCnt = {1}
      }
    }
  },
  [11601] = {
    id = 11601,
    triggerType = 0,
    loop = false,
    mapId = {
      1018,
      2018,
      3018,
      5160,
      5161
    },
    conditionType = 1,
    className = "MapGunHurtCaidanTrigger",
    caidanEffectId = 2196,
    conditions = {
      {type = 14, caidanEffectId = 2196}
    }
  },
  [11602] = {
    id = 11602,
    triggerType = 0,
    loop = false,
    mapId = {
      1018,
      2018,
      3018
    },
    conditionType = 1,
    className = "ForbidPathMonsterTrigger",
    path = {
      1,
      2,
      3,
      4
    },
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [11603] = {
    id = 11603,
    triggerType = 0,
    loop = false,
    mapId = {
      1018,
      2018,
      3018
    },
    conditionType = 1,
    className = "MapBlockTrigger",
    blockId = 2,
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [11604] = {
    id = 11604,
    triggerType = 0,
    loop = false,
    mapId = {
      1018,
      2018,
      3018
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2023,
    animName = "animation_01",
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [11701] = {
    id = 11701,
    triggerType = 0,
    loop = false,
    mapId = {
      1013,
      2013,
      3013
    },
    conditionType = 1,
    className = "MapBlockTrigger",
    blockId = 10,
    conditions = {
      {
        type = 9,
        waveCnt = {2}
      }
    }
  },
  [11702] = {
    id = 11702,
    triggerType = 0,
    loop = true,
    mapId = {
      1013,
      2013,
      3013
    },
    conditionType = 1,
    className = "NewEffectTrigger",
    effectIds = {2030},
    conditions = {
      {
        type = 9,
        waveCnt = {2}
      }
    }
  },
  [11801] = {
    id = 11801,
    triggerType = 0,
    loop = false,
    mapId = {
      1016,
      2016,
      3016
    },
    conditionType = 1,
    className = "ForbidPathMonsterTrigger",
    path = {
      4,
      5,
      6
    },
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [11802] = {
    id = 11802,
    triggerType = 0,
    loop = false,
    mapId = {
      1016,
      2016,
      3016
    },
    conditionType = 1,
    className = "MapBlockTrigger",
    blockId = 2,
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [11803] = {
    id = 11803,
    triggerType = 0,
    loop = false,
    mapId = {
      1016,
      2016,
      3016
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2052,
    animName = "animation_01",
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [12001] = {
    id = 12001,
    triggerType = 0,
    loop = true,
    mapId = {
      1019,
      2019,
      3019,
      5200,
      5201
    },
    conditionType = 1,
    className = "NewEffectTrigger",
    effectIds = {
      2203,
      2204,
      2205,
      2206,
      2207
    },
    randomDelay = {1, 2},
    conditions = {
      {
        type = 0,
        waveCnt = {1}
      },
      {type = 15, effectID = 2208}
    }
  },
  [12002] = {
    id = 12002,
    triggerType = 0,
    loop = true,
    mapId = {
      1019,
      2019,
      3019,
      5200,
      5201
    },
    conditionType = 1,
    className = "NewEffectTrigger",
    effectIds = {
      2208,
      2209,
      2210,
      2211,
      2212
    },
    randomDelay = {1, 2},
    conditions = {
      {type = 15, effectID = 2203}
    }
  },
  [12003] = {
    id = 12003,
    triggerType = 0,
    loop = true,
    mapId = {
      1019,
      2019,
      3019,
      5200,
      5201
    },
    conditionType = 1,
    className = "WalkOverTrigger",
    effectIds = {2204, 2209},
    triggerIds = {12001, 12002},
    conditions = {
      {type = 14, caidanEffectId = 2204},
      {type = 14, caidanEffectId = 2209}
    }
  },
  [12004] = {
    id = 12004,
    triggerType = 0,
    loop = true,
    mapId = {
      1019,
      2019,
      3019,
      5200,
      5201
    },
    conditionType = 1,
    className = "WalkOverTrigger",
    effectIds = {2205, 2210},
    triggerIds = {12001, 12002},
    conditions = {
      {type = 14, caidanEffectId = 2205},
      {type = 14, caidanEffectId = 2210}
    }
  },
  [12005] = {
    id = 12005,
    triggerType = 0,
    loop = true,
    mapId = {
      1019,
      2019,
      3019,
      5200,
      5201
    },
    conditionType = 1,
    className = "WalkOverTrigger",
    effectIds = {2206, 2211},
    triggerIds = {12001, 12002},
    conditions = {
      {type = 14, caidanEffectId = 2206},
      {type = 14, caidanEffectId = 2211}
    }
  },
  [12006] = {
    id = 12006,
    triggerType = 0,
    loop = true,
    mapId = {
      1019,
      2019,
      3019,
      5200,
      5201
    },
    conditionType = 1,
    className = "WalkOverTrigger",
    effectIds = {2207, 2212},
    triggerIds = {12001, 12002},
    conditions = {
      {type = 14, caidanEffectId = 2207},
      {type = 14, caidanEffectId = 2212}
    }
  },
  [12007] = {
    id = 12007,
    triggerType = 0,
    loop = true,
    mapId = {
      1019,
      2019,
      3019,
      5200,
      5201
    },
    conditionType = 1,
    className = "WalkOverTrigger",
    effectIds = {2203, 2208},
    triggerIds = {12001, 12002},
    conditions = {
      {type = 17}
    }
  },
  [12008] = {
    id = 12008,
    triggerType = 0,
    loop = true,
    mapId = {
      1019,
      2019,
      3019,
      5200,
      5201
    },
    conditionType = 1,
    className = "AddAchievementTrigger",
    achieveId = 189,
    conditions = {
      {type = 17}
    }
  },
  [12101] = {
    id = 12101,
    triggerType = 0,
    loop = true,
    mapId = {
      1023,
      2023,
      3023
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2114,
    animName = "animation_02",
    newEffectId = 2199,
    randomDelay = {10, 20},
    conditions = {
      {
        type = 0,
        waveCnt = {1}
      },
      {type = 15, effectID = 2199}
    }
  },
  [12102] = {
    id = 12102,
    triggerType = 0,
    loop = true,
    mapId = {
      1023,
      2023,
      3023
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2114,
    animName = "animation_04",
    conditions = {
      {type = 15, effectID = 2199},
      {type = 16, state = "out"}
    }
  },
  [12103] = {
    id = 12103,
    triggerType = 0,
    loop = true,
    mapId = {
      1023,
      2023,
      3023
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2114,
    animName = "animation_02",
    conditions = {
      {type = 16, state = "back"}
    }
  },
  [12104] = {
    id = 12104,
    triggerType = 0,
    loop = false,
    mapId = {
      1023,
      2023,
      3023
    },
    conditionType = 1,
    className = "GuideTrigger",
    group = 1023,
    conditions = {
      {
        type = 0,
        waveCnt = {7}
      }
    }
  },
  [12105] = {
    id = 12105,
    triggerType = 0,
    loop = false,
    mapId = {
      1023,
      2023,
      3023
    },
    conditionType = 1,
    className = "DispatchEventTrigger",
    delay = 1,
    eventName = td.SHOW_MISSON_TARGET,
    conditions = {
      {type = 25, group = 1023}
    }
  },
  [12201] = {
    id = 12201,
    triggerType = 0,
    loop = false,
    mapId = {
      1021,
      2021,
      3021
    },
    conditionType = 1,
    className = "ForbidPathMonsterTrigger",
    path = {
      1,
      2,
      3,
      4
    },
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [12202] = {
    id = 12202,
    triggerType = 0,
    loop = false,
    mapId = {
      1021,
      2021,
      3021
    },
    conditionType = 1,
    className = "MapBlockTrigger",
    blockId = 2,
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [12203] = {
    id = 12203,
    triggerType = 0,
    loop = false,
    mapId = {
      1021,
      2021,
      3021
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2028,
    animName = "animation_01",
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [12204] = {
    id = 12204,
    triggerType = 0,
    loop = false,
    mapId = {
      1021,
      2021,
      3021
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2029,
    animName = "animation_01",
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [12501] = {
    id = 12501,
    triggerType = 0,
    loop = false,
    mapId = {
      1022,
      2022,
      3022
    },
    conditionType = 1,
    className = "ForbidPathMonsterTrigger",
    path = {
      1,
      2,
      3
    },
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [12502] = {
    id = 12502,
    triggerType = 0,
    loop = false,
    mapId = {
      1022,
      2022,
      3022
    },
    conditionType = 1,
    className = "ForbidPathMonsterTrigger",
    path = {
      4,
      5,
      6
    },
    conditions = {
      {type = 22, deputyId = 2}
    }
  },
  [12503] = {
    id = 12503,
    triggerType = 0,
    loop = false,
    mapId = {
      1022,
      2022,
      3022
    },
    conditionType = 1,
    className = "MapBlockTrigger",
    blockId = 2,
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [12504] = {
    id = 12504,
    triggerType = 0,
    loop = false,
    mapId = {
      1022,
      2022,
      3022
    },
    conditionType = 1,
    className = "MapBlockTrigger",
    blockId = 3,
    conditions = {
      {type = 22, deputyId = 2}
    }
  },
  [12505] = {
    id = 12505,
    triggerType = 0,
    loop = false,
    mapId = {
      1022,
      2022,
      3022
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2024,
    animName = "animation_01",
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [12506] = {
    id = 12506,
    triggerType = 0,
    loop = false,
    mapId = {
      1022,
      2022,
      3022
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2025,
    animName = "animation_01",
    conditions = {
      {type = 22, deputyId = 2}
    }
  },
  [12701] = {
    id = 12701,
    triggerType = 0,
    loop = false,
    mapId = {
      1027,
      2027,
      3027
    },
    conditionType = 1,
    className = "ForbidPathMonsterTrigger",
    path = {
      1,
      2,
      3,
      4
    },
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [12702] = {
    id = 12702,
    triggerType = 0,
    loop = false,
    mapId = {
      1027,
      2027,
      3027
    },
    conditionType = 1,
    className = "ForbidPathMonsterTrigger",
    path = {
      9,
      10,
      11,
      12
    },
    conditions = {
      {type = 22, deputyId = 2}
    }
  },
  [12703] = {
    id = 12703,
    triggerType = 0,
    loop = false,
    mapId = {
      1027,
      2027,
      3027
    },
    conditionType = 1,
    className = "MapBlockTrigger",
    blockId = 2,
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [12704] = {
    id = 12704,
    triggerType = 0,
    loop = false,
    mapId = {
      1027,
      2027,
      3027
    },
    conditionType = 1,
    className = "MapBlockTrigger",
    blockId = 3,
    conditions = {
      {type = 22, deputyId = 2}
    }
  },
  [12705] = {
    id = 12705,
    triggerType = 0,
    loop = false,
    mapId = {
      1027,
      2027,
      3027
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2026,
    animName = "animation_01",
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [12706] = {
    id = 12706,
    triggerType = 0,
    loop = false,
    mapId = {
      1027,
      2027,
      3027
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2027,
    animName = "animation_01",
    conditions = {
      {type = 22, deputyId = 2}
    }
  },
  [2801] = {
    id = 2801,
    triggerType = 0,
    loop = false,
    mapId = {
      1028,
      2028,
      3028
    },
    conditionType = 1,
    className = "ForbidPathMonsterTrigger",
    path = {4, 5},
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [2802] = {
    id = 2802,
    triggerType = 0,
    loop = false,
    mapId = {
      1028,
      2028,
      3028
    },
    conditionType = 1,
    className = "ForbidPathMonsterTrigger",
    path = {6, 7},
    conditions = {
      {type = 22, deputyId = 2}
    }
  },
  [2803] = {
    id = 2803,
    triggerType = 0,
    loop = false,
    mapId = {
      1028,
      2028,
      3028
    },
    conditionType = 1,
    className = "MapBlockTrigger",
    blockId = 2,
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [2804] = {
    id = 2804,
    triggerType = 0,
    loop = false,
    mapId = {
      1028,
      2028,
      3028
    },
    conditionType = 1,
    className = "MapBlockTrigger",
    blockId = 3,
    conditions = {
      {type = 22, deputyId = 2}
    }
  },
  [2805] = {
    id = 2805,
    triggerType = 0,
    loop = false,
    mapId = {
      1028,
      2028,
      3028
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2297,
    animName = "animation_01",
    conditions = {
      {type = 22, deputyId = 1}
    }
  },
  [2806] = {
    id = 2806,
    triggerType = 0,
    loop = false,
    mapId = {
      1028,
      2028,
      3028
    },
    conditionType = 1,
    className = "EffectPlayAnimTrigger",
    caidanEffectId = 2298,
    animName = "animation_01",
    conditions = {
      {type = 22, deputyId = 2}
    }
  },
  [12802] = {
    id = 12802,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "EnableMapTrigger",
    touchAble = false,
    conditions = {}
  },
  [12804] = {
    id = 12804,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "GuideTrigger",
    group = 1031,
    conditions = {
      {type = 6, monsterId = 9005}
    }
  },
  [12805] = {
    id = 12805,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 0,
    className = "BossStateTrigger",
    state = 2,
    monsterId = 9005,
    conditions = {
      {type = 20, triggerId = 12809}
    }
  },
  [12833] = {
    id = 12833,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "BossStateTrigger",
    state = 3,
    monsterId = 9005,
    pathId = 19,
    inverted = false,
    conditions = {
      {type = 11, monsterId = 9008},
      {type = 13, monsterId = 9008}
    }
  },
  [12806] = {
    id = 12806,
    triggerType = 0,
    loop = true,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "ActorPlayAnimTrigger",
    actorId = 9005,
    anims = {
      [1] = {"skill_08", false},
      [2] = {"skill_09", true}
    },
    conditions = {
      {
        type = 19,
        group = 1031,
        guideIdx = 1
      }
    }
  },
  [12807] = {
    id = 12807,
    triggerType = 0,
    loop = true,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 3071,
    y = 300,
    conditions = {
      {
        type = 19,
        group = 1031,
        guideIdx = 2
      }
    }
  },
  [12808] = {
    id = 12808,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "GuideContinueTrigger",
    conditions = {
      {
        type = 21,
        monsterId = 9005,
        triggerId = 12806
      }
    }
  },
  [12809] = {
    id = 12809,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    yOffset = 200,
    moveType = 1,
    preDelay = 2,
    conditions = {
      {type = 20, triggerId = 12807}
    }
  },
  [12810] = {
    id = 12810,
    triggerType = 0,
    loop = true,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "EnableMapTrigger",
    touchAble = true,
    conditions = {
      {type = 20, triggerId = 12809}
    }
  },
  [12811] = {
    id = 12811,
    triggerType = 0,
    loop = true,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "StateManagerPauseTrigger",
    monstId = 9008,
    bPause = false,
    conditions = {
      {type = 20, triggerId = 12809}
    }
  },
  [12812] = {
    id = 12812,
    triggerType = 0,
    loop = true,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "StateManagerPauseTrigger",
    monstId = 9005,
    bPause = false,
    conditions = {
      {type = 20, triggerId = 12809}
    }
  },
  [12813] = {
    id = 12813,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 0,
    className = "BossStateTrigger",
    state = 4,
    monsterId = 9005,
    conditions = {
      {type = 20, triggerId = 12819}
    }
  },
  [12814] = {
    id = 12814,
    triggerType = 0,
    loop = true,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "ActorPlayAnimTrigger",
    actorId = 9005,
    anims = {
      [1] = {"skill_08", false},
      [2] = {"skill_09", true}
    },
    conditions = {
      {
        type = 12,
        monsterId = 9005,
        pathId = 19
      }
    }
  },
  [12815] = {
    id = 12815,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "GuideContinueTrigger",
    conditions = {
      {
        type = 21,
        monsterId = 9005,
        triggerId = 12814
      }
    }
  },
  [12816] = {
    id = 12816,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "EnableMapTrigger",
    touchAble = false,
    conditions = {
      {
        type = 12,
        monsterId = 9005,
        pathId = 19
      }
    }
  },
  [12817] = {
    id = 12817,
    triggerType = 0,
    loop = true,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 2222,
    y = 115,
    conditions = {
      {
        type = 19,
        group = 1031,
        guideIdx = 3
      }
    }
  },
  [12818] = {
    id = 12818,
    triggerType = 0,
    loop = true,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 4,
    x = 470,
    y = 1470,
    preDelay = 2,
    conditions = {
      {type = 20, triggerId = 12817}
    }
  },
  [12819] = {
    id = 12819,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "ViewPortMoveTrigger",
    moveType = 1,
    preDelay = 2,
    conditions = {
      {type = 20, triggerId = 12818}
    }
  },
  [12820] = {
    id = 12820,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "StateManagerPauseTrigger",
    monstId = 9007,
    bPause = false,
    conditions = {
      {type = 20, triggerId = 12819}
    }
  },
  [12821] = {
    id = 12821,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "StateManagerPauseTrigger",
    monstId = 9006,
    bPause = false,
    conditions = {
      {type = 20, triggerId = 12819}
    }
  },
  [12822] = {
    id = 12822,
    triggerType = 0,
    loop = true,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "EnableMapTrigger",
    touchAble = true,
    conditions = {
      {type = 20, triggerId = 12819}
    }
  },
  [12823] = {
    id = 12823,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "NewActorTrigger",
    pathId = 16,
    isReverse = true,
    actorId = 9007,
    actorType = 1,
    yxwave = false,
    conditions = {
      {type = 20, triggerId = 12818}
    }
  },
  [12824] = {
    id = 12824,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "NewActorTrigger",
    pathId = 15,
    isReverse = true,
    actorId = 9006,
    actorType = 1,
    yxwave = false,
    conditions = {
      {type = 20, triggerId = 12817}
    }
  },
  [12825] = {
    id = 12825,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "NewActorTrigger",
    pathId = 17,
    isReverse = true,
    actorId = 9008,
    actorType = 1,
    yxwave = false,
    conditions = {
      {type = 20, triggerId = 12807}
    }
  },
  [12826] = {
    id = 12826,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "SacrificeTrigger",
    fromActorId = 9008,
    toActorId = 9005,
    delay = 10,
    conditions = {
      {
        type = 12,
        monsterId = 9008,
        pathId = 17
      }
    }
  },
  [12827] = {
    id = 12827,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 0,
    className = "BossStateTrigger",
    state = 5,
    monsterId = 9005,
    pathId = 20,
    inverted = false,
    conditions = {
      {type = 11, monsterId = 9006},
      {type = 11, monsterId = 9007}
    }
  },
  [12828] = {
    id = 12828,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 0,
    className = "BossStateTrigger",
    state = 5,
    monsterId = 9005,
    pathId = 20,
    inverted = false,
    conditions = {
      {type = 13, monsterId = 9006},
      {type = 13, monsterId = 9007}
    }
  },
  [12829] = {
    id = 12829,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 0,
    className = "BossStateTrigger",
    state = 5,
    monsterId = 9005,
    pathId = 20,
    inverted = false,
    conditions = {
      {type = 11, monsterId = 9006},
      {type = 13, monsterId = 9007}
    }
  },
  [12830] = {
    id = 12830,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 0,
    className = "BossStateTrigger",
    state = 5,
    monsterId = 9005,
    pathId = 20,
    inverted = false,
    conditions = {
      {type = 11, monsterId = 9007},
      {type = 13, monsterId = 9006}
    }
  },
  [12831] = {
    id = 12831,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "SacrificeTrigger",
    fromActorId = 9007,
    toActorId = 9005,
    delay = 10,
    conditions = {
      {
        type = 12,
        monsterId = 9007,
        pathId = 16
      }
    }
  },
  [12832] = {
    id = 12832,
    triggerType = 0,
    loop = false,
    mapId = {
      1031,
      2031,
      3031
    },
    conditionType = 1,
    className = "SacrificeTrigger",
    fromActorId = 9006,
    toActorId = 9005,
    delay = 10,
    conditions = {
      {
        type = 12,
        monsterId = 9006,
        pathId = 15
      }
    }
  }
}
function GetTriggerConfig(id)
  return TriggerConfig[id]
end
function GetTriggerConfigAll()
  return clone(TriggerConfig)
end
