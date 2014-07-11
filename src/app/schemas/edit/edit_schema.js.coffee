angular.module("case-ui.schemas.edit",[
  "case-ui.schemas.edit.field_set"
  "case-ui.basic-fields"
  'ui.bootstrap'
  "ui.router"
  "ui.sortable"
  "restangular"
  'truncate'
])

.config( ($stateProvider) ->
  $stateProvider.state "edit_schema",
    parent: "root"
    url: "/schemas/edit/:schema_id"
    controller: "EditSchemaCtrl"
    templateUrl: "schemas/edit/edit_schema.tpl.html"
    data:
      pageTitle: "Edit Schema"
    resolve:
      schema: ["Restangular", "$stateParams", (Restangular, $stateParams)->
        Restangular.one('schemas', $stateParams.schema_id ).get()
      ]

)


.controller "EditSchemaCtrl", ($scope, schema)->
  $scope.schema = schema

  $scope.save = ()->
    $scope.schema.put()

  $scope.cancel = ()->
    $state.go('schemas')



