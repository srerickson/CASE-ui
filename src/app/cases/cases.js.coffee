angular.module("case-ui.cases", [
  "case-ui.cases.new"
  "case-ui.cases.edit"
  "case-ui.evaluations"
  "ui.router"
  "restangular"
])


.config ($stateProvider) ->
  $stateProvider.state "cases",
    parent: "root"
    url: "/cases?case_filter&eval_filter"
    controller: "CaseListCtrl"
    templateUrl: "cases/case_list.tpl.html"
    data:
      pageTitle: "Cases"




# .factory "Case", (Restangular)->
#   # collection methods
#   # - methods for querying cases 


# .factory "Field", (Restangular)->
#   Field = (schema_id)->
#   #Restangular.service()


# .factory "Column", 

#   # Sets the type of thing the column will show.
#   # Options are: 
#   # - Field
#   # - Question 
#   Column = (id,type)->
#     this.id = id
#     this.type = type










.controller "CaseListCtrl",
  ($scope, Restangular, $state, $stateParams,
  current_schema, current_question_set, evaluationService)->

    $scope.question_set = current_question_set # a service
    $scope.schema = current_schema 
    $scope.cases = []
    $scope.evaluationService = evaluationService

    # default params for case list
    case_filter_params = {
      user_evaluated: true
      set_id: current_question_set.id()
    }

    # defautl params for evaluations
    eval_filter_params = {
      own: true       # only user's evals
      aggregate:true  # aggregate responses
    }

    if $stateParams.eval_filter == 'all'
      delete eval_filter_params.own

    if $stateParams.case_filter == 'schema'
      case_filter_params.schema_id = current_schema.id
    else if $stateParams.case_filter == 'all'
      delete case_filter_params.set_id
      delete case_filter_params.user_evaluated

    # fetch evaluation responses
    current_question_set.refresh_responses(eval_filter_params)

    Restangular.all('cases').getList(case_filter_params)
      .then (resp)-> $scope.cases = resp

    $scope.new_evaluation = ->
      evaluationService.new_evaluation(current_question_set)
      .then(
        (ok)->
          current_question_set.refresh_responses(eval_filter_params)
        ,(err) ->
          current_question_set.refresh_responses(eval_filter_params)
      )

    $scope.evaluation_detail = (k,q)->
      if eval_filter_params.own then user_only = true else user_only = false
      evaluationService.evaluation_detail(current_question_set,k,q,user_only)
      .then(
        (ok)->
          current_question_set.refresh_responses_for(k,q,eval_filter_params)
        ,(err) ->
          current_question_set.refresh_responses_for(k,q,eval_filter_params)
      )

    $scope.go = (id)->
      $state.go('edit_case',{case_id: id},{reload: true})




