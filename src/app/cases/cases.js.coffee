angular.module("case-ui.cases", [
  "ui.router"
  "restangular"
  "blueimp.fileupload"
])


.config ($stateProvider) ->
  $stateProvider.state "cases",
    url: "/cases"
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


.controller "CaseListCtrl", ($scope, Restangular)->
  Restangular.all('cases').getList().then (resp)->
    $scope.cases = resp
  return


.controller "EditCaseCtrl", ($scope, Restangular, kase)->
  $scope.kase = kase
  $scope.field_values = []

  $scope.fetch_field_values = ()->
    schema_id = $scope.globals.active_schema.id
    Restangular.one("cases", kase.id)
      .getList('field_values',{schema_id: schema_id})
      .then (resp)->
        $scope.field_values = resp

  $scope.fetch_field_values()

  $scope.$on "activeSchemaChange", ()->
    $scope.fetch_field_values()

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




