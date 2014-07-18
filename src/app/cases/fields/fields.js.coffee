angular.module("case-ui.fields", [
  "restangular"
])


.controller "FieldCtrl", ($scope, Restangular)->

  $scope.$watch "$parent.field_values.length", (n,o)->
    if n and n != o
      if fv = $scope.$parent.value_for($scope.field_definition)
        $scope.field_value = fv

  $scope.init_field_value = (fd)->
    $scope.field_definition = fd
    fv = {
      field_definition_id: fd.id
      value: null
    }
    $scope.field_value = Restangular.restangularizeElement(
      $scope.kase, fv, 'field_values'
    )

  $scope.template_path = (styles = [])->
    if $scope.field_definition
      base_path =  "cases/fields/"
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


  $scope.select_lookup = ->
    if $scope.field_value and $scope.field_definition
      return _.find($scope.field_definition.value_options.select, (opt)->
        opt.id == $scope.field_value.value
      )






