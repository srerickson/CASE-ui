angular.module("case-ui.config", [
  "ui.router"
  "ui.select"
  "restangular"
])


# Default Route
.config ($urlRouterProvider)->
  $urlRouterProvider.otherwise "/cases"

.config (uiSelectConfig)->
  uiSelectConfig.theme = 'bootstrap'

.config ($uiViewScrollProvider)->
  $uiViewScrollProvider.useAnchorScroll()


# Restangular Config
.config (RestangularProvider) ->

  RestangularProvider.setDefaultHeaders({'Content-Type': 'application/json'})

  RestangularProvider.addRequestInterceptor (elem, operation, what)->
    # Don't wrap authenication POST.
    return elem if what == "authenticate"
    # TODO: this is a littlc clunky.
    if operation == 'post' or operation == 'put'
      wrapper = {}

      if what == "evaluations/sets"
        wrapper_key = "set"
      else
        wrapper_key = what.substring(0, what.length-1)

      wrapper[wrapper_key] = elem #FIXME
      wrapper
    else
      elem

  # ... unwrap root wrapped json responses
  RestangularProvider.addResponseInterceptor (data) ->
    extractedData = undefined
    if _.isObject(data) and _.isEmpty(data) is false
      extractedData = data[_.keys(data)[0]]
    else
      extractedData = data
    extractedData


# additional Restangular config that need $window
.run (Restangular, $window) ->

  if $window.sessionStorage.case_server
    Restangular.setBaseUrl $window.sessionStorage.case_server

  Restangular.addFullRequestInterceptor (elem, op, route, url, hdrs, pa) ->
    config = {}
    config.headers = hdrs or {}
    if $window.sessionStorage.token
      config.headers.Authorization = $window.sessionStorage.token
    config
