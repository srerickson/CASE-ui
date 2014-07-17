angular.module("case-ui.evaluations", [
  "case-ui.current-user"
  "case-ui.evaluation-set"
  "case-ui.evaluation-vis"
  "ui.router"
  "restangular"
])


.config ($stateProvider) ->
  $stateProvider.state "evaluations",
    parent: "root"
    url: "/evaluations?all_responses"
    controller: "EvaluationListCtrl"
    templateUrl: "evaluations/evaluation_list.tpl.html"
    data:
      pageTitle: "Evaluation Responses"
    resolve:
      evaluation_set: ["current_set_id","evaluationSetFactory",
        (current_set_id, evaluationSetFactory)->
          evaluationSetFactory(current_set_id).then(
            (resp)->
              return resp
            ,(err)->
              console.log err
          )
      ]



.controller "EvaluationListCtrl", ($scope, $stateParams, evaluation_set)->

  $scope.evaluation_set = evaluation_set

  if $stateParams.all_responses == '1'
    evaluation_set.refresh_cases()
    evaluation_set.refresh_responses({aggregate:true})
  else
    evaluation_set.refresh_cases({own: true})
    evaluation_set.refresh_responses({own: true, aggregate:true})


.controller "EvaluationListCellCtrl", ($scope)->

  $scope.cell_init = (k,q)->
    $scope.kase = k
    $scope.question = q



