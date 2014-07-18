angular.module("case-ui.question-sets", [
  "restangular"
  "ui.router"
])


.config ($stateProvider) ->
  $stateProvider.state "question_sets",
    parent: "root"
    abstract: true
    url: "/question_sets"
    template: "<div ui-view/>"


  $stateProvider.state "new_question_set",
    parent: "question_sets"
    url:"/new"
    templateUrl: "question_sets/new_question_set.tpl.html"
    controller: "NewQuestionSetCtrl"
    data:
      pageTitle: "New Question Set"


  $stateProvider.state "edit_question_set",
    parent: "question_sets"
    url:"/:id"
    templateUrl: "question_sets/edit_question_set.tpl.html"
    controller: "EditQuestionSetCtrl"
    data:
      pageTitle: "Editing Question Set"
    resolve:
      question_set: ["Restangular", "$stateParams",
        (Restangular, $stateParams)->
          Restangular.one("evaluations/sets", $stateParams.id).get()
      ]



.controller "NewQuestionSetCtrl",
  ($scope, $rootScope, $state, Restangular)->
    $scope.question_set = {}
    $scope.save = ()->
      Restangular.all("evaluations/sets").post($scope.question_set).then(
        (resp)->
          $rootScope.$broadcast("questionSetsModified")
          $state.go('edit_question_set',{id: resp.id})
        ,(err)->

      )



.controller "EditQuestionSetCtrl",
  ($scope, $rootScope, $state, question_set)->
    $scope.question_set = question_set
    $scope.save = ()->
      $scope.question_set.put().then(
        (ok)->
          $rootScope.$broadcast("questionSetsModified")
          $state.go('evaluations',{all_responses: '0'})
        ,(err)->

      )

