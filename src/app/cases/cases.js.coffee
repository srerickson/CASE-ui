angular.module("case-ui.cases", [
  "case-ui.cases.new"
  "case-ui.cases.edit"
  "case-ui.evaluations"
  "case-ui.fields"
  "ui.router"
  "restangular"
  "ui.grid"
  "ui.select"
])


.config ($stateProvider) ->
  $stateProvider.state "cases",
    parent: "root"
    url: "/cases?case_filter&eval_filter"
    controller: "CaseListCtrl"
    templateUrl: "cases/case_list.tpl.html"
    data:
      pageTitle: "Cases"



.controller "CaseListCtrl",
  ($scope, Restangular, $state, $stateParams,
  current_schema, current_question_set, evaluationService)->


    $scope.columnDefs = [
      {
        name: "name"
        displayName: "Name"
        cellTemplate: "
          <div class=\"ngCellText\" ng-class=\"col.colIndex()\">
            <a href ui-sref='edit_case({case_id: row.entity.id})'>
              {{row.entity.name}}
            </a>
          </div>"
      }
    ]


    $scope.gridOptions = {
      columnDefs: $scope.columnDefs
    }





    $scope.available_columns = current_schema.field_definitions
      .concat current_question_set.questions



    # col can be a schema field_definition or an
    # evaluation question
    #
    $scope.add_column = (col)->
      console.log col
      col_def = {
        field: col.param
        # entity: col
        # headerCellTemplate: 'cases/_grid_header.tpl.html'
      }

      # if the column is a schema field ...
      if col.route == "field_definitions"
        col_def.cellTemplate = "<div
            field-value='row.entity.field_values[#{col.id}]'
            for-field='col.colDef.entity'></div>"

        # fetch the values for the column
        col.all('field_values').getList()
        .then (values)->
          for val in values
            idx = _.findIndex $scope.cases, (kase)-> kase.id == val.case_id
            $scope.cases[idx].field_values ||= {}
            $scope.cases[idx].field_values[val.field_definition_id] = val

          $scope.columnDefs.push col_def


      # if the column is an evaluation question ...
      else if col.route == "questions"
        col_def.cellTemplate = "<div
          evaluation-responses='row.entity.responses[#{col.id}]'
          for-question='col.colDef.entity'></div>"

        current_question_set.all('responses')
        .getList({aggregate:true, question_id: col.id})
        .then (resps)->
          for resp in resps
            idx = _.findIndex $scope.cases, (kase)-> kase.id == resp.case_id
            $scope.cases[idx].responses ||= {}
            $scope.cases[idx].responses[resp.question_id] = resp

          $scope.columnDefs.push col_def

    $scope.column_group  = (col)->
      if col.route == "questions"
        return "2. Evaluation Questions"
      else
        return "1. Schema Fields"



    Restangular.all('cases').getList({schema_id: current_schema.id})
    .then (resp)->
      $scope.gridOptions.data = resp
          

    # build_table = (cols) ->
    #   fields = _.filter cols, (col)-> col.route == "field_definitions"
    #   questions = _.filter cols, (col)-> col.route == "questions"

    #   field_ids = _.map fields, (f)-> f.id
    #   question_ids = _.map questions, (q)-> q.id

    #   Restangular.all('field_values')
    #   .getList({field_definition_ids: field_ids.join(",")})
    #   .then (values)->
    #     for val in values
    #       idx = _.findIndex $scope.cases, (kase)-> kase.id == val.case_id
    #       $scope.cases[idx].field_values ||= {}
    #       $scope.cases[idx].field_values[val.field_definition_id] = val

    #   if question_ids and question_ids.length
    #     current_question_set.all('responses')
    #     .getList({aggregate:true})
    #     .then (resps)->
    #       for resp in resps
    #         idx = _.findIndex $scope.cases, (kase)-> kase.id == resp.case_id
    #         $scope.cases[idx].responses ||= {}
    #         $scope.cases[idx].responses[resp.question_id] = resp


    # $scope.question_set = current_question_set # a service
    # $scope.schema = current_schema
    # $scope.cases = []
    # $scope.evaluationService = evaluationService

    # # default params for case list
    # case_filter_params = {
    #   user_evaluated: true
    #   set_id: current_question_set.id
    # }

    # # defautl params for evaluations
    # eval_filter_params = {
    #   own: true       # only user's evals
    #   aggregate:true  # aggregate responses
    # }

    # if $stateParams.eval_filter == 'all'
    #   delete eval_filter_params.own

    # if $stateParams.case_filter == 'schema'
    #   case_filter_params.schema_id = current_schema.id
    # else if $stateParams.case_filter == 'all'
    #   delete case_filter_params.set_id
    #   delete case_filter_params.user_evaluated

    # # fetch evaluation responses
    # current_question_set.get_responses(eval_filter_params)



    # $scope.new_evaluation = ->
    #   evaluationService.new_evaluation(current_question_set)
    #   .then(
    #     (ok)->
    #       current_question_set.get_responses(eval_filter_params)
    #     ,(err) ->
    #       current_question_set.get_responses(eval_filter_params)
    #   )

    # $scope.evaluation_detail = (k,q)->
    #   if eval_filter_params.own then user_only = true else user_only = false
    #   evaluationService.evaluation_detail(current_question_set,k,q,user_only)
    #   .then(
    #     (ok)->
    #       current_question_set.get_responses_for(k,q,eval_filter_params)
    #     ,(err) ->
    #       current_question_set.get_responses_for(k,q,eval_filter_params)
    #   )

    # $scope.go = (id)->
    #   $state.go('edit_case',{case_id: id},{reload: true})




