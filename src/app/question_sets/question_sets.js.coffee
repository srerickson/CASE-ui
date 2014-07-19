angular.module("case-ui.question-sets", [
  "restangular"
  "ui.router"
  "ui.sortable"
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
  ($scope, $rootScope, $state, question_set, Restangular)->
    $scope.question_set = question_set

    $scope.new_question = {}

    $scope.sortable_options = {
      axis: 'y'
      handle: ".handle"
      stop: ()->
        reorder_req = { questions_attributes: [] }
        for q, i in $scope.question_set.questions
          q.order = i
          reorder_req. questions_attributes.push { id: q.id, order: i }
        $scope.question_set.customPUT(reorder_req)
    }

    $scope.save = ()->
      $scope.question_set.put().then(
        (ok)->
          $rootScope.$broadcast("questionSetsModified")
          $state.go('evaluations',{all_responses: '0'})
        ,(err)->

      )

    $scope.add_question = ()->
      $scope.new_question.order = $scope.question_set.questions.length
      $scope.question_set.all("questions").post($scope.new_question)
      .then(
        (resp)->
          $scope.question_set.questions.push(resp)
        ,(err)->
          #TODO
          console.log err
      )
      $scope.new_question = {}


    $scope.remove_question = (question)->
      message = "Are you sure you want to delete the question?\n"
      message += "All associated responses will be lost!"

      if window.confirm(message)
        question.remove().then(
          (ok)->
            _.remove($scope.question_set.questions, (q)-> q == question )
        )


.controller "QuestionCtrl", ($scope)->
  $scope.question ||= {}


