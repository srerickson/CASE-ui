angular.module("case-ui.current-user", [
  'restangular'
  "http-auth-interceptor"
  "ui.bootstrap"
])



.factory('currentUser',
  (Restangular, authService, $modal, $window, $q, $rootScope)->

    currentUser = {
      user: null
    }

    currentUser.get = ->
      Restangular.all("users").customGET('current_user').then (user) ->
        currentUser.user = user

    currentUser.id = ->
      this.user.id if this.user

    currentUser.name = ->
      this.user.name if this.user

    currentUser.email = ->
      this.user.email if this.user

    currentUser.default_schema_id = ->
      if this.user and this.user.configs
        this.user.configs.default_schema_id

    currentUser.token = ->
      $window.sessionStorage.token

    currentUser.logged_in = ->
      !!$window.sessionStorage.token

    currentUser.logout= ()->
      authService.loginCancelled()
      $window.sessionStorage.token = ""
      currentUser.user = null

    currentUser.server = ->
      $window.sessionStorage.case_server || ""

    currentUser.login_prompt= ()->
      $modal.open({
        templateUrl: "currentUser/login.tpl.html"
        controller: 'LoginCtrl'
        resolve:
          user: ()-> currentUser.user
        # keyboard: false
        backdrop: 'static'
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
            currentUser.get()
          else
            return $q.reject('no token')
      )

    return currentUser

)


.controller "LoginCtrl",
  ($scope, Restangular, $window, authService, user) ->

    $scope.loginFailed = false
    $scope.user_connection =
      username: if user then user.email else ""
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
       

