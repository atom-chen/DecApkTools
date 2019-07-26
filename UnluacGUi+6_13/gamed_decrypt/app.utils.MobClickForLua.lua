MobClickForLua = {}
function MobClickForLua.setLogEnabled(value)
  umeng_setLogEnabled(value)
end
function MobClickForLua.setCheckDevice(value)
  umeng_setCheckDevice(value)
end
function MobClickForLua.setSessionIdleLimit(seconds)
  umeng_setSessionIdleLimit(seconds)
end
function MobClickForLua.setEncryptEnabled(value)
  umeng_setEncryptEnabled(value)
end
function MobClickForLua.event(eventId, ...)
  umeng_event(eventId, ...)
end
function MobClickForLua.beginLogPageView(pageViewName)
  umeng_beginLogPageView(pageViewName)
end
function MobClickForLua.endLogPageView(pageViewName)
  umeng_endLogPageView(pageViewName)
end
function MobClickForLua.profileSignIn(puid, ...)
  umeng_profileSignIn(puid, ...)
end
function MobClickForLua.profileSignOff()
  umeng_profileSignOff()
end
function MobClickForLua.setUserLevel(level)
  umeng_setUserLevel(level)
end
function MobClickForLua.startLevel(level)
  umeng_startLevel(level)
end
function MobClickForLua.finishLevel(level)
  umeng_finishLevel(level)
end
function MobClickForLua.failLevel(level)
  umeng_failLevel(level)
end
function MobClickForLua.pay(cash, source, ...)
  umeng_pay(cash, source, ...)
end
function MobClickForLua.buy(item, amount, price)
  umeng_buy(item, amount, price)
end
function MobClickForLua.use(item, amount, price)
  umeng_use(item, amount, price)
end
function MobClickForLua.bonus(...)
  umeng_bonus(...)
end
function MobClickForLua.setLatency(latency)
  umeng_setLatency(latency)
end
function MobClickForLua.startMobclick(key, ...)
  if key == "" or key == nil then
    print("(MobClickCpp::startWithAppkey) appKey can not be NULL or \"\"!")
    return
  end
  umeng_mobclickstart(key, ...)
end
return MobClickForLua
