angular.module("case-ui", [
  "templates-app"
  "templates-common"
  "case-ui.config"    # see here for app configs
  "case-ui.globals"
  "case-ui.root"
  "case-ui.current-user"
  "case-ui.user"
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



.controller "AppCtrl",
  ($scope, $location, currentUser, caseGlobals,$state, $stateParams) ->
  
    $scope.globals = caseGlobals
    $scope.current_user = currentUser

    # handle 401
    $scope.$on 'event:auth-loginRequired', (e, data)->
      currentUser.login_prompt()

    # Force Question Set reload on question set change
    $scope.$on("questionSetModified", (e, q_set_id)->
      caseGlobals.reload_question_sets()
      # reload the current question set
      # if it's the one that was modified
      if caseGlobals.current_question_set
        if caseGlobals.current_question_set.id() == q_set_id
          caseGlobals.current_question_set.get()
    )

    $scope.$on("schemaCreated", (e, schema_id)->
      caseGlobals.reload_schemas()
    )

    $scope.$on("schemaModified", (e, schema_id)->
      caseGlobals.reload_schemas()
      if caseGlobals.current_schema
        if caseGlobals.current_schema.id == schema_id
          caseGlobals.set_current_schema(schema_id)
    )

    $scope.$on("schemaRemoved", (e, schema_id)->
      caseGlobals.reload_schemas()
      if caseGlobals.current_schema
        if caseGlobals.current_schema.id == schema_id
          caseGlobals.current_schema = null
    )

    # when server changes, refresh gloabls
    $scope.$watch "current_user.server()", (newServer)->
      $scope.globals.reload_schemas()
      $scope.globals.reload_question_sets()


    # force login
    currentUser.get().then(
      (resp)->
        return resp
      ,(err)->
        # handle 404 on get user
        currentUser.login_prompt().then ()->
          # reload
          $state.transitionTo(
            'cases',{},
            { reload: true, inherit: true, notify: true }
          )
    )

    # FIXME - this needs to handle urls that are already 'full'
    $scope.asset_url = (path)->
      if /^http[s]?:\/\//.test(path)
        path
      else
        base = currentUser.server() || ""
        base + path




    $scope.$on "$stateChangeSuccess", (ev, tState, tParams, fState, fParams) ->
      if angular.isDefined(tState.data.pageTitle)
        $scope.pageTitle = tState.data.pageTitle + " | case-ui"







