angular.module("case-ui.user-config", [
  "case-ui.current-user"
  "restangular"
  "http-auth-interceptor"
  "ui.bootstrap"
])



.controller "UserConfigCtrl",
  ($scope, Restangular, currentUser,
  $state, current_schema_id, current_set_id)->

    $scope.current_schema_id = current_schema_id
    $scope.current_evaluation_set_id = current_set_id

    $scope.schemas = []
    $scope.evaluation_sets = []

    Restangular.all('schemas').getList().then (resp)->
      $scope.schemas = resp

    Restangular.all('evaluations/sets').getList().then (resp)->
      $scope.evaluation_sets = resp

    $scope.current_user = currentUser

    $scope.$watch 'current_schema_id', (n,o)->
      if $state.current.name and n and n != 0
        $state.go($state.current.name,{current_schema_id: n})


    $scope.$watch 'current_evaluation_set_id', (n,o)->
      if $state.current.name and n and n != 0
        $state.go($state.current.name,{current_set_id: n})


