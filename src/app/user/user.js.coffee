angular.module('case-ui.user', [
  'case-ui.current-user'
  'ui.router'
  'restangular'
])


.config( ($stateProvider) ->
  $stateProvider.state "user",
    parent: "root"
    url: "/user"
    controller: "UserUpdateCtrl"
    templateUrl: "user/user.tpl.html"

    data:
      pageTitle: "Your Profile"

)


.controller "UserUpdateCtrl", ($scope, currentUser)->
  $scope.current_user = currentUser
  $scope.error = ""

  $scope.save = ->
    $scope.error = ""
    $scope.current_user.save().then(
      (ok)->
        ok
      ,(err)->
        $scope.error = err.data.error
    )
