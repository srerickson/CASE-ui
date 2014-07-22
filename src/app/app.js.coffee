angular.module("case-ui", [
  "templates-app"
  "templates-common"
  "case-ui.globals"
  "case-ui.current-user"
  "case-ui.home"
  "case-ui.schemas"
  "case-ui.cases"
  "case-ui.evaluations"
  "case-ui.question-sets"
  "case-ui.user-config"
  "ui.router"
  "restangular"
  "ui.bootstrap"
  "ui.select"
  "inplaceEdit"
  "angular-loading-bar"
])

.config( ($stateProvider, $urlRouterProvider, RestangularProvider) ->

  $urlRouterProvider.otherwise "/cases"

  $stateProvider.state "root",
    abstract: true
    url: '?current_schema_id&current_set_id'
    views:
      '':
        templateUrl: 'root/root.tpl.html'
        controller: [ "current_schema_id", "current_set_id", "$scope"
          (current_schema_id, current_set_id, $scope)->
            $scope.current_schema_id = current_schema_id
            $scope.current_set_id = current_set_id
        ]
      'user-config':
        templateUrl: 'user_config/user.tpl.html'
        controller: 'UserConfigCtrl'
    resolve:
      current_schema_id: ["$stateParams",($stateParams)->
        return parseInt($stateParams.current_schema_id)
      ],
      current_set_id: ["$stateParams",($stateParams)->
        return parseInt($stateParams.current_set_id)
      ]




  # Restangular Config
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

)

.config( (uiSelectConfig)->
  uiSelectConfig.theme = 'bootstrap'
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
  Restangular.addElementTransformer("evaluations/sets", false, (elem)->
    if elem.questions
      elem.questions = Restangular.restangularizeCollection(
        elem,
        elem.questions,
        'questions'
      )
    return elem
  )
  Restangular.addFullRequestInterceptor (elem, op, route, url, hdrs, pa) ->
    config = {}
    config.headers = hdrs or {}
    if $window.sessionStorage.token
      config.headers.Authorization = $window.sessionStorage.token
    config



.controller "AppCtrl",
  ($scope, $location, currentUser, $state, $stateParams) ->
  
    # handle 401
    $scope.$on 'event:auth-loginRequired', (e, data)->
      currentUser.login_prompt()

    $scope.current_user = currentUser

    # force login
    currentUser.get().then(
      (resp)->
        return resp
      ,(err)->
        # handle 404 on get user
        currentUser.login_prompt().then ()->
          # reload
          $state.transitionTo(
            $state.current,
            $stateParams,
            { reload: true, inherit: true, notify: true }
          )
    )

    # FIXME - this needs to handle urls that are already 'full'
    $scope.asset_url = (path)->
      base = currentUser.server() || ""
      base + path




    $scope.$on "$stateChangeSuccess", (ev, tState, tParams, fState, fParams) ->
      if angular.isDefined(tState.data.pageTitle)
        $scope.pageTitle = tState.data.pageTitle + " | case-ui"







