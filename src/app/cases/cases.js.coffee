angular.module("case-ui.cases", [
  "case-ui.globals"
  "case-ui.evaluations"
  "case-ui.current-user"
  "ui.router"
  "restangular"
  "blueimp.fileupload"
  "hc.marked"
])


.config ($stateProvider) ->
  $stateProvider.state "cases",
    parent: "root"
    url: "/cases?case_filter&eval_filter"
    controller: "CaseListCtrl"
    templateUrl: "cases/case_list.tpl.html"
    data:
      pageTitle: "Cases"

  $stateProvider.state "new_case",
    parent: "root"
    url: "/cases/new"
    controller: "NewCaseCtrl"
    templateUrl: "cases/new_case.tpl.html"
    data:
      pageTitle: "New Case"

  $stateProvider.state "edit_case",
    parent: "root"
    url: "/cases/:case_id"
    controller: "EditCaseCtrl"
    templateUrl: "cases/edit_case.tpl.html"
    data:
      pageTitle: "Editing Case"
    resolve:
      kase: ["caseFactory", "$stateParams", "current_schema",
        (caseFactory, $stateParams, current_schema)->
          caseFactory($stateParams.case_id).then(
            (kase)->
              kase.get_field_values(current_schema.id)
            (null_kase)->
              null_kase
          )
      ]



.factory "caseFactory", (Restangular)->
  (case_id)->
    _this = {}
    _this.kase = null
    _this.field_values = {} #lookup table

    _this.get = ->
      Restangular.one("cases", case_id).get().then(
        (resp)->
          _this.kase = resp
          _this
        ,(err)->
          _this
      )

    _this.get_field_values = (schema_id)->
      if _this.kase and schema_id
        _this.kase.all("field_values").getList({schema_id: schema_id}).then(
          (values)->
            _this.field_values = {} # reset lookup table
            for value in values
              _this.field_values[value.field_definition_id] ||= []
              _this.field_values[value.field_definition_id].push(value)
            _this
          ,(err)->
            console.log err
            _this
        )
      else
        _this

    # return promise
    _this.get()




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

    # fetch evaluation responses and cases
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

    $scope.go = (id)->
      $state.go('edit_case',{case_id: id},{reload: true})



.controller "EditCaseCtrl", ($scope, kase, current_schema)->
  $scope.kase = kase # the service
  $scope.current_schema = current_schema

  $scope.upload_options = {
    url: "#{$scope.current_user.server()}/cases/#{kase.kase.id}/uploads"
    type: "POST"
    dropZone: $("#case_uploads")
    headers: {
      "Authorization": $scope.current_user.token()
    }
    add:(e, data)->
      data.submit()

    done: (e,data)->
      kase.get()
  }





# New Case Controller
#
.controller "NewCaseCtrl", ($scope, $state, Restangular)->
  $scope.kase = {}

  $scope.save = ()->
    Restangular.all('cases').post($scope.kase).then(
      (resp)->
        $state.go('edit_case',{case_id: resp.id})
      (err)->
        console.log err

    )




.controller "FieldCtrl", ($scope, Restangular)->

  $scope.init_field = (fd)->
    $scope.field_definition = fd

    # if there is no value for the field,
    # create a blank one
    fv_bucket = $scope.kase.field_values[fd.id]
    if !(fv_bucket and fv_bucket.length)
      fv = Restangular.restangularizeElement(
        $scope.kase.kase,
        {
          field_definition_id: fd.id
          value: null
        }, 'field_values'
      )
      $scope.kase.field_values[fd.id] ||= []
      $scope.kase.field_values[fd.id].push(fv)

    # TODO: handle multiple values?
    $scope.field_values = $scope.kase.field_values[fd.id]


  ##
  # Returns path to field value's render/form html template
  #
  $scope.template_path = (styles = [])->
    if $scope.field_definition
      base_path =  "cases/field_templates/"
      type = ""
      if $scope.field_definition.type == "SelectField"
        type = "select"
      else if $scope.field_definition.type == "TextField"
        type = "text"

      #FIXME - short only used on forms
      if "form" in styles
        if $scope.field_definition.value_options.short
          styles.push("short")

      if styles.length
        tpl = "#{base_path}_#{type}_#{(styles).join('_')}.tpl.html"
      else
        tpl = "#{base_path}_#{type}.tpl.html"
      tpl


  $scope.select_lookup = (value)->
    if value and $scope.field_definition
      return _.find($scope.field_definition.value_options.select, (opt)->
        opt.id == value.value
      )

