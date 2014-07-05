angular.module("case-ui.schemas.new",[
  "ui.router"
  "ui.sortable"
  "restangular"
])


.config( ($stateProvider) ->
  $stateProvider.state "new_schema",
    url: "/schemas/new"
    views:
      main:
        controller: "NewSchemaCtrl"
        templateUrl: "schemas/new/form.tpl.html"
    data:
      pageTitle: "New Schema"

)


.controller "NewSchemaCtrl", ($scope, $state, Restangular)->
  $scope.schema = {}
  $scope.submit = ()->
    Restangular.all('schemas').post($scope.schema).then(
      (resp)->
        $state.go('schemas')
      ,(err)->
        console.log err
    )
  $scope.cancel = ()->
    $state.go('schemas')
