angular.module("case-ui.user-config", [
  "ui.bootstrap"
])


.controller "UserConfigCtrl", ($scope, $state)->

  $scope.set_current_schema = (id)->
    $state.go($state.current.name,{current_schema_id: id})

  $scope.set_current_set = (id)->
    $state.go($state.current.name,{current_set_id: id})






