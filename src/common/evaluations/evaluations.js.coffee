angular.module("case-ui.evaluations", [
  "case-ui.evaluations.question-types"
  "case-ui.evaluation-set"
  "ui.router"
  "ui.select"
  "ui.bootstrap"
  "restangular"
])



# renders response aggregates using registered
# questionType

.directive "evaluationResponses", (questionType)->
  linker = (scope, elem, attrs)->
    scope.$watch 'evaluationResponses', (n)->
      return null unless n
      q_type = questionType(scope.forQuestion)
      q_type.render(elem, n) if !!q_type
  return {
    link: linker
    scope: {
      forQuestion: "="
      evaluationResponses: "="
    }
  }



.factory "evaluationService", ($modal)->

  {

    evaluation_detail: (eval_set_service,kase,question,user_only=true)->
      $modal.open({
        controller: "EvaluationResponsePopupCtrl"
        templateUrl: "evaluations/response_detail_modal.tpl.html"
        resolve:
          #pass the restangular model, not the whole evaluationSet object
          evaluation_set: ()-> eval_set_service.evaluation_set
          kase: ()-> kase
          question: ()-> question
          user_only: ()-> user_only
      }).result

    new_evaluation: (eval_set_service)->
      $modal.open(
        controller: "NewEvaluationPopup"
        templateUrl: "evaluations/new_response_modal.tpl.html"
        resolve:
          evaluation_set: ()-> eval_set_service.evaluation_set
      ).result

    question_type: (q)->

  }


.controller "EvaluationResponsePopupCtrl",
  ($scope, currentUser, $modalInstance, Restangular
  evaluation_set, kase, question, user_only)->

    $scope.question = question
    $scope.kase = kase
    $scope.responses = []

    params = {question_id: question.id, case_id: kase.id}
    params.own = true if user_only

    evaluation_set.all("responses").getList(params)
      .then (resp)-> $scope.responses = resp


    init_new_response = ->
      $scope.new_response = {
        question_id: question.id
        case_id: kase.id
        answer: null
        comment: null
      }
    init_new_response()

    $scope.add_new_response = ->
      evaluation_set.all('responses').post($scope.new_response).then(
        (resp)->
          $scope.responses.push(resp)
          init_new_response()
      )

    $scope.remove = (response)->
      message = "Do you really want to delete this evaluation response"
      if window.confirm(message)
        response.remove().then(
          (ok)->
            _.remove($scope.responses, (r)-> r == response)
        )

    $scope.parseInt = (i)-> parseInt(i,10)

    $scope.response_name = (response)->
      $scope.question.response_options[response.answer]

    $scope.user_owned = (response)->
      currentUser.id() == response.user_id






.controller "NewEvaluationPopup",
  ($scope,$modalInstance,evaluation_set, Restangular)->

    $scope.evaluation_set = evaluation_set
    $scope.evaluation_response = {}
    $scope.selected_question = {}
    $scope.cases = []

    Restangular.all('cases').getList().then (resp)->
      $scope.cases = resp

    $scope.$watch "evaluation_response.question_id", (newQid)->
      if newQid
        $scope.selected_question = _.find($scope.evaluation_set.questions,
          (q)-> parseInt(newQid) == parseInt(q.id)
        )

    # we can't just grab the case id w/ ui-select, so
    # the selected case is stored as an attribute that
    # is deleted before POSTing.
    # (this will change soon, probably, track this issue
    # here: https://github.com/angular-ui/ui-select/pull/107 )
    # Watch that attribute and set case_id
    $scope.$watch 'evaluation_response.case', (newCase)->
      if newCase
        $scope.evaluation_response.case_id = newCase.id

    $scope.selected_question_index = ()->
      _.findIndex($scope.evaluation_set.questions, (q)->
        q.id == parseInt($scope.evaluation_response.question_id)
      )

    $scope.next_question = ()->
      idx = $scope.selected_question_index()
      idx += 1
      idx %= $scope.evaluation_set.questions.length
      next_q = $scope.evaluation_set.questions[idx]
      $scope.evaluation_response.question_id = next_q.id

    $scope.prev_question = ()->
      idx = $scope.selected_question_index()
      idx = $scope.evaluation_set.questions.length if idx == 0
      idx -= 1
      next_q = $scope.evaluation_set.questions[idx]
      $scope.evaluation_response.question_id = next_q.id

    $scope.save_and_next = ()->
      # make a copy and delete the case attribute
      response = angular.copy($scope.evaluation_response)
      delete response.case
      evaluation_set.all('responses').post(response).then(
        (ok)->
          $scope.evaluation_response.answer = null
          $scope.evaluation_response.comment = ''
          $scope.next_question()
      )


