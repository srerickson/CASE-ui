
# FIXME - put this somewhere else -- config?
FD_TYPES = ["SelectField","TextField"]


angular.module("case-ui.schemas.edit.field_set.field_definition", [
  'ui.bootstrap'
  "ui.sortable"
  "restangular"
  'truncate'
])


# FieldDefinition list on FieldSet page
#
.controller "FieldDefinitionListCtrl", ($scope)->
  $scope.field_set.field_definitions ||= []
  # for sorting field defs
  $scope.sort_options = {
    axis: 'y'
    handle: ".handle"
    stop: ()->
      reorder_req = { field_definitions_attributes: [] }
      for fd, i in $scope.field_set.field_definitions
        fd.order = i
        reorder_req.field_definitions_attributes.push { id: fd.id, order: i }
      $scope.field_set.customPUT(reorder_req)
  }
  $scope.$on 'deletedFieldDefinition', (e, data)->
    _.remove($scope.field_set.field_definitions, (fd)-> fd.id == data.id )


# Single row in FieldDefinition list
#
.controller "FieldDefinitionCtrl", ($scope, $modal) ->
  tpl = "schemas/edit/field_set/field_definition/field_definition.tpl.html"
  $scope.start_popup_editor = ()->
    modal_instance = $modal.open({
      templateUrl: tpl
      controller: 'EditFieldDefinitionCtrl'
      size: "lg"
      windowClass: 'field_definition'
      resolve:
        field_definition: ()->
          return $scope.field_definition
    }).result.then(
      (popup_resp)-> $scope.refresh(),
      ()-> $scope.refresh()
    )

  $scope.refresh = ()->
    $scope.field_definition.get().then (resp)->
      $scope.field_definition = resp
  $scope.delete = ()->
    message = "Are you sure you want to delet it?\n"
    message += "All data associated with this field will also be destroyed!"
    if window.confirm(message)
      $scope.field_definition.remove().then(
        (resp)->
          $scope.$emit('deletedFieldDefinition', $scope.field_definition)
        ,(err)->
          #TODO: handle errors
      )


# Popup FieldDefinition editor
#
.controller "EditFieldDefinitionCtrl",
  ($scope, $modalInstance, field_definition)->
    $scope.field_definition = field_definition
    $scope.field_definition_types = FD_TYPES
    original_fd = angular.copy($scope.field_definition)

    $scope.field_option_form_tpl = ()->
      base_path = "schemas/edit/field_set/field_definition/"
      if $scope.field_definition.type == 'TextField'
        base_path+"_text_field_options.tpl.html"
      else if $scope.field_definition.type == 'SelectField'
        base_path+"_select_field_options.tpl.html"
      else
        ""

    $scope.save = ()->
      $scope.field_definition.put().then(
        (resp)->
          $modalInstance.close(true)
        ,(err)->
          #TODO: handle errors
      )
    $scope.cancel = ()->
      $modalInstance.close(false)


# New FielDefinition panel
#
.controller "NewFieldDefinitionCtrl", ($scope)->
  $scope.field_definition_types = FD_TYPES
  $scope.init_new_field_definition = ()->
    $scope.new_field_definition = {
      name: ""
      param: ""
      description: ""
      type: "TextField"
      order: $scope.field_set.field_definitions.length
    }
  $scope.cancel_new_field_definition = ()->
    $scope.new_field_definition = null
  $scope.save_new_field_definition = ()->
    $scope.field_set.all('field_definitions')
      .post($scope.new_field_definition)
      .then(
        (resp)->
          $scope.field_set.field_definitions.push resp
          $scope.cancel_new_field_definition()
        ,(err)->
          #TODO: handle errors

      )



.controller "SelectFieldOptionsCtrl", ($scope)->
  $scope.field_definition.value_options ||= {}
  $scope.field_definition.value_options.select ||= []

  $scope.delete_option= (id)->
    _.remove($scope.field_definition.value_options.select, (o)-> o.id == id )

  $scope.add_option = ()->
    last_id = 0
    for opt in $scope.field_definition.value_options.select
      last_id = opt.id if opt.id > last_id
    new_id = last_id + 1
    $scope.field_definition.value_options.select.push({
      id: new_id
    })

