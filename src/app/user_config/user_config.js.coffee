angular.module("case-ui.user-config", [
  "ui.bootstrap"
])


.controller "UserConfigCtrl", ($scope, $state)->

  $scope.set_current_schema = (id)->
    if id and id != $scope.globals.current_schema.id
      $state.go($state.current.name,{current_schema_id: id})

  $scope.set_current_set = (id)->
    if id and id != $scope.globals.current_question_set.id() # service!
      $state.go($state.current.name,{current_set_id: id})






