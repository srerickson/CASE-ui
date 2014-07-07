angular.module("case-ui", [
  "templates-app"
  "templates-common"
  "case-ui.globals"
  "case-ui.current-user"
  "case-ui.home"
  "case-ui.schemas"
  "case-ui.cases"
  "case-ui.user-config"
  "ui.router"
  "restangular"
  "ui.bootstrap"
  "angular-loading-bar"
])

.config( ($stateProvider, $urlRouterProvider, RestangularProvider) ->

  $urlRouterProvider.otherwise "/home"

  # Restangular Config
  RestangularProvider.setDefaultHeaders({'Content-Type': 'application/json'})

  RestangularProvider.addRequestInterceptor (elem, operation, what)->
    # Don't wrap authenication POST.
    return elem if what == "authenticate"
    # TODO: this is a littlc clunky.
    if operation == 'post' or operation == 'put'
      wrapper = {}
      wrapper[what.substring(0, what.length-1)] = elem #FIXME
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

)


# additional Restangular config that need $window
.run (Restangular, $window) ->

  if $window.sessionStorage.case_server
    Restangular.setBaseUrl $window.sessionStorage.case_server

  Restangular.addElementTransformer("schemas", false, (elem)->
    if elem.field_sets
      elem.field_sets = Restangular.restangularizeCollection(
        elem,
        elem.field_sets,
        'field_sets'
      )
    return elem
  )
  Restangular.addElementTransformer("field_sets", false, (elem)->
    if elem.field_definitions
      elem.field_definitions = Restangular.restangularizeCollection(
        elem,
        elem.field_definitions,
        'field_definitions'
      )
    return elem
  )
  Restangular.addFullRequestInterceptor (elem, op, route, url, hdrs, pa) ->
    config = {}
    config.headers = hdrs or {}
    if $window.sessionStorage.token
      config.headers.Authorization = $window.sessionStorage.token
    config



.controller "AppCtrl", ($scope, $location, currentUser, currentSchema) ->
  
  $scope.init_globals = ()->

  currentUser.get().then(
    (resp)->
      return resp
    ,(err)->
      currentUser.login_prompt()
  )
    .then ()-> currentSchema.get_available()
    .then ()-> currentSchema.set_active()

  # FIXME - this needs to handle urls that are already 'full'
  $scope.asset_url = (path)->
    base = currentUser.server() || ""
    base + path

  $scope.init_globals()

  $scope.$on 'event:auth-loginRequired', (e, data)->
    currentUser.login_prompt()


  $scope.$on "$stateChangeSuccess", (ev, tState, tParams, fState, fParams) ->
    if angular.isDefined(tState.data.pageTitle)
      $scope.pageTitle = tState.data.pageTitle + " | case-ui"







