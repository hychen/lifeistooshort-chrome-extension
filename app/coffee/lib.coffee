window.onlyRunInProduction = (next) ->
  chrome.management.getSelf((info) ->
    if(info.installType != 'development')
      next()
  )
