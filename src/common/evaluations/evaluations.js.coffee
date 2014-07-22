angular.module("case-ui.evaluations", [
  "case-ui.evaluation-set"
  "case-ui.evaluation-vis"
  "ui.router"
  "ui.select"
  "ui.bootstrap"
  "restangular"
])




.factory "evaluationService", ($modal)->

  {

    response_detail: (eval_set, k,q=null)->
      $modal.open({
        controller: "EvaluationResponsePopupCtrl"
        templateUrl: "evaluations/response_detail_modal.tpl.html"
        resolve:
          #pass the restangular model, not the whole evaluationSet object
          evaluation_set: ()-> evaluation_set
          kase: ()-> k
          question: ()-> q
          all_responses: ()-> $stateParams.all_responses == '1'
      }).result

    new_evaluation: (eval_set_service)->
      $modal.open(
        controller: "NewEvaluationPopup"
        templateUrl: "evaluations/new_response_modal.tpl.html"
        resolve:
          evaluation_set: ()-> eval_set_service.evaluation_set
      ).result
  }


.controller "EvaluationResponsePopupCtrl",
  ($scope, $modalInstance, evaluation_set, kase, question, all_responses)->
    $scope.question = question
    $scope.kase = kase

    params = {question_id: question.id, case_id: kase.id}
    params.own = true if !all_responses

    evaluation_set.all("responses").getList(params)
               .then (resp)-> $scope.responses = resp

    $scope.parseInt = (i)-> parseInt(i,10)

    $scope.response_name = (response)->
      $scope.question.response_options[response.answer]

    $scope.save = (response)->
      response.save().get().then (resp)->
        response = resp

    $scope.cancel = (response)->
      response.get().then (resp)->
        response = resp


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


