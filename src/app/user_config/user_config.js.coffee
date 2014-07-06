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


.controller "ActiveUserCtrl", ($scope, currentUser)->

  $scope.current_user = currentUser

  $scope.user = currentUser.get()

  # $scope.$watch 'user.configs.active_schema_id', (n,o)->
  #   if n and n != o
  #     $scope.$emit('setActiveSchema', $scope.user.configs.active_schema_id )
  #     # TODO update user config on server

  # if !currentUser.logged_in()
  #   currentUser.login_prompt()




