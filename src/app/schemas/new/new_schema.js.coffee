angular.module("case-ui.schemas.new",[
  "ui.router"
  "ui.sortable"
  "restangular"
])


.config( ($stateProvider) ->
  $stateProvider.state "new_schema",
    parent: "root"
    url: "/schemas/new"
    controller: "NewSchemaCtrl"
    templateUrl: "schemas/new/new_schema.tpl.html"
    data:
      pageTitle: "New Schema"

)


.controller "NewSchemaCtrl", ($scope, $state, Restangular)->
  $scope.schema = {}
  $scope.save = ()->
    Restangular.all('schemas').post($scope.schema).then(
      (resp)->
        $state.go('edit_schema',{schema_id: resp.id})
        $scope.$emit('schemaCreated', resp.id)
      ,(err)->
        console.log err
    )
