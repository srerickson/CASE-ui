angular.module("case-ui.schemas",[
  'ui.bootstrap'
  "ui.router"
  "restangular"
  "case-ui.schemas.new"
  "case-ui.schemas.edit"
])


.config( ($stateProvider) ->
  $stateProvider.state "schemas",
    url: "/schemas"
    views:
      main:
        controller: "SchemaListCtrl"
        templateUrl: "schemas/schemas.tpl.html"

    data:
      pageTitle: "Schemas"

)


# TODO: user's 'active' schema should be expanded onload

.controller "SchemaListCtrl", ($scope, Restangular)->
  Restangular.all("schemas").getList().then (schemas)->
    $scope.schemas = schemas

.controller "SchemaCtrl", ($scope, Restangular)->
  $scope.isCollapsed = true
  $scope.toggle = ()->
    $scope.isCollapsed = !$scope.isCollapsed
    $scope.get_full() if !$scope.isCollapsed
  $scope.get_full = ()->
    $scope.schema.get().then (resp)->
      $scope.schema = resp




