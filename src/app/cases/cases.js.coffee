angular.module("case-ui.cases", [
  "case-ui.globals"
  "case-ui.current-user"
  "ui.router"
  "restangular"
  "blueimp.fileupload"
])


.config ($stateProvider) ->
  $stateProvider.state "cases",
    parent: "root"
    url: "/cases?case_filter"
    controller: "CaseListCtrl"
    templateUrl: "cases/case_list.tpl.html"
    data:
      pageTitle: "Cases"
    resolve:
      schema:["current_schema_id","Restangular",
        (current_schema_id,Restangular)->
          Restangular.one("schemas",current_schema_id).get().then(
            (resp)->
              resp
            ,(err)->
              null
          )
      ]

  $stateProvider.state "new_case",
    parent: "root"
    url: "/cases/new"
    controller: "NewCaseListCtrl"
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
      kase: ["caseFactory", "$stateParams", "current_schema_id",
        (caseFactory, $stateParams, current_schema_id)->
          caseFactory($stateParams.case_id).then(
            (kase)->
              kase.get_field_values(current_schema_id)
            (null_kase)->
              null_kase
          )
      ]
      schema: ["current_schema_id","Restangular",
        (current_schema_id,Restangular)->
          Restangular.one("schemas",current_schema_id).get().then(
            (resp)->
              resp
            ,(err)->
              null
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
  ($scope, Restangular, $state, $stateParams, schema)->

    if !$stateParams.case_filter
      $state.go('cases',{case_filter: 'all'})

    $scope.schema = schema
    $scope.cases = []

    if $stateParams.case_filter == 'all'
      Restangular.all('cases').getList().then (resp)->
        $scope.cases = resp
    else if $stateParams.case_filter == 'schema'
      if schema
        schema.all('cases').getList().then (resp)->
          $scope.cases = resp

    $scope.go = (id)->
      $state.go('edit_case',{case_id: id})




.controller "EditCaseCtrl", ($scope, kase, schema)->
  $scope.kase = kase # the service
  $scope.current_schema = schema

  $scope.upload_options = {
    url: "#{$scope.current_user.server()}/cases/#{kase.kase.id}/uploads"
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
.controller "NewCaseCtrl", ($scope, kase)->
  $scope.kase = {}





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

