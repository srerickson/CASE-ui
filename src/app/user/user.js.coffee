angular.module("case-ui.user", [
  "restangular"
  "http-auth-interceptor"
  "ui.bootstrap"
])


.directive "activeUserConfigs", ()->
  {
    templateUrl: "user/user.tpl.html"
  }


.controller "ActiveUserCtrl",
  ($scope, Restangular, $modal, authService, $window)->

    $scope.user = {
      configs:
        active_schema_id: null
    }

    $scope.$watch 'user.configs.active_schema_id', (n,o)->
      if n and n != o
        $scope.$emit('setActiveSchema', $scope.user.configs.active_schema_id )
        # TODO update user config on server

    $scope.case_server = ()->
      $window.sessionStorage.case_server

    $scope.show_login = ->
      $modal.open({
        templateUrl: "user/login.tpl.html"
        controller: 'LoginCtrl'
        resolve:
          user: ()-> $scope.user
      }).result.then(
        (user_connection)->
          if user_connection.token  # succesful login
            $window.sessionStorage.case_server = user_connection.case_server
            $window.sessionStorage.token = user_connection.token
            authService.loginConfirmed(null,(httpConfig)->
              httpConfig.headers ||= {}
              httpConfig.headers.Authorization = user_connection.token
              httpConfig
            )
            $scope.getUserConfig()
            $scope.$emit('loginSuccess')
      )

    $scope.logout = ->
      authService.loginCancelled()
      $window.sessionStorage.token = ""
      # $window.sessionStorage.case_server = ""
      $scope.user = {}
      Restangular.setBaseUrl($scope.case_server)
      $scope.$emit('logout')

    $scope.getUserConfig = ->
      Restangular.all("users").customGET('current_user').then (user) ->
        $scope.user = user

    # HTTP Auth Interceptor - show login when we get a 401 error
    $scope.$on 'event:auth-loginRequired', ()->
      $scope.show_login()

    # kick things off
    if !$window.sessionStorage.token
      $scope.show_login()
    else if !$scope.user.id
      $scope.getUserConfig()



.controller "LoginCtrl",
  ($scope, Restangular, $window, authService, user) ->

    $scope.loginFailed = false
    $scope.user_connection =
      username: user.email
      password: ""
      case_server: $window.sessionStorage.case_server || ""
      token: null

    $scope.submit = ->
      if $scope.user_connection.case_server
        Restangular.setBaseUrl($scope.user_connection.case_server)

      Restangular.all("authenticate")
        .withHttpConfig({ ignoreAuthModule:true })
        .post($scope.user_connection).then(
          (token) ->
            $scope.loginFailed = false
            $scope.user_connection.token = token
            $scope.$close($scope.user_connection)
          (err)->
            $scope.loginFailed = true
      )
       


