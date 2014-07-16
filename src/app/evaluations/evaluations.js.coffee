angular.module("case-ui.evaluations", [
  "case-ui.current-user"
  "case-ui.evaluation-vis"
  "ui.router"
  "restangular"
])


.config ($stateProvider) ->
  $stateProvider.state "evaluations",
    parent: "root"
    url: "/evaluations"
    controller: "EvaluationListCtrl"
    templateUrl: "evaluations/evaluation_list.tpl.html"
    data:
      pageTitle: "Evaluation Responses"
    resolve:
      evaluation: ["current_set_id","Restangular",
        (current_set_id, Restangular)->
          Restangular.one("evaluations/sets",current_set_id).get().then(
            (resp)->
              resp
            ,(err)->
              null
          )
      ]



.controller "EvaluationListCtrl",
  ($scope, Restangular, $state, $stateParams, evaluation)->

    $scope.evaluation = evaluation
    $scope.evaluated_cases = []

    if evaluation
      evaluation.all("cases").getList().then (resp)->
        $scope.evaluated_cases = resp


    $scope.responses_for = (kase)->
      if evaluation and evaluation.aggregates and evaluation.questions
        # kase's responses
        for_case = evaluation.aggregates.filter (response)->
          response.case_id == kase.id
        # sort by question order
        for_case.sort (a,b)->
          q_a = $scope.question_for(a)
          q_b = $scope.question_for(b)
          q_a.position - q_b.position

    $scope.question_for = (response)->
      _.find evaluation.questions, (q)-> q.id == response.question_id


