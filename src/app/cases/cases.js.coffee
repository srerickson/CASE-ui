angular.module("case-ui.cases", [
  "ui.router"
  "case-ui.globals"
  "case-ui.current-user"
  "restangular"
  "blueimp.fileupload"
])


.config ($stateProvider) ->
  $stateProvider.state "cases",
    url: "/cases?case_filter"
    views:
      main:
        controller: "CaseListCtrl"
        templateUrl: "cases/case_list.tpl.html"
    data:
      pageTitle: "Cases"
  $stateProvider.state "new_case",
    url: "/cases/new"
    views:
      main:
        controller: "NewCaseListCtrl"
        templateUrl: "cases/new_case.tpl.html"
    data:
      pageTitle: "New Case"
  $stateProvider.state "edit_case",
    url: "/cases/:case_id"
    views:
      main:
        controller: "EditCaseCtrl"
        templateUrl: "cases/edit_case.tpl.html"
    data:
      pageTitle: "Editing Case"
    resolve:
      kase: ["Restangular", "$stateParams", (Restangular, $stateParams)->
        Restangular.one('cases', $stateParams.case_id ).get()
      ]


.controller "CaseListCtrl",
  ($scope, Restangular, $state, $stateParams, currentSchema)->

    if !$stateParams.case_filter
      $state.go('cases',{case_filter: 'all'})

    $scope.cases = []
    $scope.current_schema = currentSchema

    $scope.go = (id)->
      $state.go('edit_case',{case_id: id})

    $scope.all_cases = ->
      Restangular.all('cases').getList().then (resp)->
        $scope.cases = resp

    $scope.schema_cases = ->
      currentSchema.get_cases().then (resp)->
        $scope.cases = resp

    $scope.$watch "current_schema.id()", (n,o)->
      if n and n != o and $stateParams.case_filter == 'schema'
        $scope.schema_cases()

    if $stateParams.case_filter == 'all'
      $scope.all_cases()
    else if $stateParams.case_filter == 'schema'
      $scope.schema_cases()




.controller "EditCaseCtrl",
  ($scope, Restangular, kase, currentUser, currentSchema)->
  
    $scope.kase = kase
    $scope.current_schema = currentSchema
    $scope.field_values = []

    $scope.fetch_field_values = ()->
      schema_id = currentSchema.id()
      Restangular.one("cases", kase.id)
        .getList('field_values',{schema_id: schema_id})
        .then (resp)->
          $scope.field_values = resp

    $scope.$watch "current_schema.id()", (n,o)->
      $scope.fetch_field_values() if n

    $scope.lookup_val = (field)->
      val = _.find $scope.field_values, (v)->
        v.field_definition_id == field.id
      if val
        if field.type == "SelectField"
          option = _.find field.value_options.select, (opt)->
            opt.id == val.value
          option.name
        else
          val.value
      else
        ""


# New Case Controller
#
.controller "NewCaseCtrl", ($scope, kase)->
  $scope.kase = {}




