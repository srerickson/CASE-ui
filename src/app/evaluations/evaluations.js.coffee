angular.module("case-ui.evaluations", [
  "case-ui.evaluation-set"
  "case-ui.evaluation-vis"
  "ui.router"
  "ui.bootstrap"
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



.controller "EvaluationListCtrl",
  ($scope, $stateParams, evaluation_set, $modal)->

    $scope.evaluation_set = evaluation_set

    if $stateParams.all_responses == '1'
      evaluation_set.refresh_cases()
      evaluation_set.refresh_responses({aggregate:true})
    else
      evaluation_set.refresh_cases({own: true})
      evaluation_set.refresh_responses({own: true, aggregate:true})

    $scope.response_detail = (k,q)->
      $modal.open({
        controller: "EvaluationResponsePopupCtrl"
        templateUrl: "evaluations/response_detail_modal.tpl.html"
        resolve:
          #pass the restangular model, not the whole evaluationSet object
          evaluation_set: ()-> $scope.evaluation_set.evaluation_set
          kase: ()-> k
          question: ()-> q
          all_responses: ()-> $stateParams.all_responses == '1'
      }).result.then(
        (succ)->
          evaluation_set.refresh_response_for(k,q,{
            aggregate:true
            own: $stateParams.all_responses != '1'
          })
        ,(err)->
          evaluation_set.refresh_response_for(k,q,{
            aggregate:true
            own: $stateParams.all_responses != '1'
          })
      )


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


