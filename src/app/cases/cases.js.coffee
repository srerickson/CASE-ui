angular.module("case-ui.cases", [
  "case-ui.fields"
  "case-ui.globals"
  "case-ui.current-user"
  "ui.router"
  "restangular"
  "blueimp.fileupload"
])


.config ($stateProvider) ->
  $stateProvider.state "cases",
    parent: "root"
    url: "/cases?case_filter"
    controller: "CaseListCtrl"
    templateUrl: "cases/case_list.tpl.html"
    data:
      pageTitle: "Cases"
    resolve:
      schema:["current_schema_id","Restangular",
        (current_schema_id,Restangular)->
          Restangular.one("schemas",current_schema_id).get().then(
            (resp)->
              resp
            ,(err)->
              null
          )
      ]



  $stateProvider.state "new_case",
    parent: "root"
    url: "/cases/new"
    controller: "NewCaseListCtrl"
    templateUrl: "cases/new_case.tpl.html"
    data:
      pageTitle: "New Case"
  $stateProvider.state "edit_case",
    parent: "root"
    url: "/cases/:case_id"
    controller: "EditCaseCtrl"
    templateUrl: "cases/edit_case.tpl.html"
    data:
      pageTitle: "Editing Case"
    resolve:
      kase: ["Restangular", "$stateParams", (Restangular, $stateParams)->
        Restangular.one('cases', $stateParams.case_id ).get()
      ]
      schema: ["current_schema_id","Restangular",
        (current_schema_id,Restangular)->
          Restangular.one("schemas",current_schema_id).get().then(
            (resp)->
              resp
            ,(err)->
              null
          )
      ]


.controller "CaseListCtrl",
  ($scope, Restangular, $state, $stateParams, schema)->

    if !$stateParams.case_filter
      $state.go('cases',{case_filter: 'all'})

    $scope.schema = schema
    $scope.cases = []

    if $stateParams.case_filter == 'all'
      Restangular.all('cases').getList().then (resp)->
        $scope.cases = resp
    else if $stateParams.case_filter == 'schema'
      if schema
        schema.all('cases').getList().then (resp)->
          $scope.cases = resp

    $scope.go = (id)->
      $state.go('edit_case',{case_id: id})



.controller "EditCaseCtrl", ($scope, Restangular, kase, schema)->
    
  $scope.kase = kase
  $scope.current_schema = schema
  $scope.field_values = []

  if kase and schema
    Restangular.one("cases", kase.id)
      .getList('field_values',{schema_id: schema.id})
      .then (resp)->
        $scope.field_values = resp

  $scope.value_for = (field)->
    if field
      return _.find $scope.field_values, (v)->
        v.field_definition_id == field.id

  $scope.submit = ->
    $scope.kase.put()

  $scope.refresh = ->
    $scope.kase.get().then (resp)->
      $scope.kase = resp



# New Case Controller
#
.controller "NewCaseCtrl", ($scope, kase)->
  $scope.kase = {}

