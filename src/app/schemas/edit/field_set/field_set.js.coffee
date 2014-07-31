angular.module("case-ui.schemas.edit.field_set", [
  'case-ui.schemas.edit.field_set.field_definition'
  'ui.bootstrap'
  "ui.router"
  "ui.sortable"
  "restangular"
  'truncate'
])


.config( ($stateProvider) ->


  $stateProvider.state "edit_schema.edit_field_set",
    url: "/field_set/:field_set_id"
    views:
      "form@edit_schema":
        controller: "EditFieldSetCtrl"
        templateUrl: "schemas/edit/field_set/edit_field_set.tpl.html"
    data:
      pageTitle: "Edit Field Set"

)



.controller "EditFieldSetCtrl", ($scope, $stateParams)->
  $scope.field_set = _.find($scope.schema.field_sets, (fs)->
    fs.id == parseInt($stateParams.field_set_id)
  )


.controller "NewFieldSetCtrl", ($scope, $stateParams, $state)->
  $scope.field_set = {}
  $scope.save = ()->
    $scope.schema.all("field_sets").post($scope.field_set).then(
      (resp)->
        $scope.schema.field_sets ||= []
        $scope.schema.field_sets.push resp
        $state.go(
          'edit_schema.edit_field_set',
          {schema_id: $scope.schema.id, field_set_id: resp.id}
        )
      ,(err)->
        console.log err
    )




