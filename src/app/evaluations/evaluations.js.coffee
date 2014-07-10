angular.module("case-ui.evaluations", [
  "case-ui.current-user"
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
      evaluation: ["evaluation_set_id","Restangular",
        (evaluation_set_id, Restangular)->
          Restangular.one("evaluations/sets",evaluation_set_id).get().then(
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
      if evaluation and evaluation.aggregates
        evaluation.aggregates.filter (response)->
          response.case_id == kase.id




