angular.module("case-ui.schemas.edit",[
  "case-ui.schemas.edit.field_set"
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


.controller "EditSchemaCtrl", ($scope, schema, $modal, $state)->
  $scope.schema = schema

  broadcast_modification = ->
    $scope.$emit("schemaModified", $scope.schema.id)

  broadcast_removal = ->
    $scope.$emit("schemaRemoved", $scope.schema.id)

  $scope.$on('inplaceEdit:onSave', (e, thing)->
    broadcast_modification()
  )

  # When Field Definitions change, may need to update current schema
  $scope.$on 'fieldDefinitionRemove', (e, thing)-> broadcast_modification()
  $scope.$on 'fieldDefinitionUpdated', (e, thing)-> broadcast_modification()
  $scope.$on 'fieldDefinitionCreated', (e, thing)-> broadcast_modification()
  $scope.$on 'fieldDefinitionsSorted', (e, thing)-> broadcast_modification()



  $scope.remove = ()->
    $modal.open(
      templateUrl: "schemas/edit/destroy_confirm.tpl.html"
      controller: ($scope, schema)->
        $scope.schema = schema
      resolve: {
        schema: ()-> $scope.schema
      }
    ).result.then(
      (confirm)->
        $scope.schema.remove().then ()->
          broadcast_removal()
          $state.go('cases')
      ,(dismiss)->
        # do nothing
    )
