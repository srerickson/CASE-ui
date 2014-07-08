angular.module("case-ui.user-config", [
  "case-ui.current-user"
  "restangular"
  "http-auth-interceptor"
  "ui.bootstrap"
])


.directive "activeUserConfigs", ()->
  {
    templateUrl: "user_config/user.tpl.html"
  }


.controller "ActiveUserCtrl", ($scope, currentUser, currentSchema)->

  $scope.current_user = currentUser
  $scope.current_schema = currentSchema

  $scope.schema_id = currentSchema.active.id

  $scope.$watch 'current_schema.active.id', (n,o)->
    $scope.schema_id = n

  $scope.$watch 'schema_id', (n,o)->
    if n and o and n != o and n != currentSchema.active.id
      currentSchema.set_active(n)
      # TODO update user config on server




