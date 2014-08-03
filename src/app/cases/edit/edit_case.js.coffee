angular.module("case-ui.cases.edit", [
  # "case-ui.evaluations"
  "ui.router"
  "restangular"
  "blueimp.fileupload"
  "hc.marked"
])


.config ($stateProvider) ->
  $stateProvider.state "edit_case",
    parent: "root"
    url: "/cases/:case_id"
    controller: "EditCaseCtrl"
    templateUrl: "cases/edit/edit_case.tpl.html"
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
      base_path =  "cases/edit/field_templates/"
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
