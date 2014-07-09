angular.module("case-ui.user-config", [
  "case-ui.current-user"
  "restangular"
  "http-auth-interceptor"
  "ui.bootstrap"
])



.controller "UserConfigCtrl",
  ($scope, Restangular, currentUser, $state, schema_id)->

    $scope.current_schema_id = schema_id
    $scope.schemas = []

    Restangular.all('schemas').getList().then (resp)->
      $scope.schemas = resp

    $scope.current_user = currentUser

    $scope.$watch 'current_schema_id', (n,o)->
      if $state.current.name and n and n != 0
        $state.go($state.current.name,{schema_id: n})




