# FIXME - put this somewhere else -- config?
FD_TYPES = ["SelectField","TextField"]


angular.module("case-ui.schemas.edit.field_set.field_definition", [
  'ui.bootstrap'
  "ui.sortable"
  "restangular"
  'truncate'
])



# All Field Definition update actions go through here
#
#
.controller "FieldDefinitionListCtrl", ($scope)->
  $scope.field_set.field_definitions ||= []
  $scope.sort_options = {
    axis: 'y'
    handle: ".handle"
    stop: ()-> $scope.sort_field_definitions()
  }
  
  $scope.sort_field_definitions = ()->
    current_order = _.map($scope.field_set.field_definitions, (fd)-> fd.order )
    correct_order = [0..($scope.field_set.field_definitions.length-1)]
    if !angular.equals(current_order, correct_order)
      reorder_req = { field_definitions_attributes: [] }
      for fd, i in $scope.field_set.field_definitions
        fd.order = i
        reorder_req.field_definitions_attributes.push { id: fd.id, order: i }
      $scope.field_set.customPUT(reorder_req)
      $scope.$emit('fieldDefinitionsSorted')

  $scope.remove_field_definition = (id)->
    _.remove($scope.field_set.field_definitions, (fd)-> fd.id == id )
    $scope.sort_field_definitions()
    $scope.$emit('fieldDefinitionRemoved', $scope.field_definition)

  $scope.add_field_definition = (new_fd)->
    $scope.field_set.field_definitions.push new_fd
    $scope.$emit('fieldDefinitionCreated')


  $scope.refresh_field_definition = (id)->
    idx = _.findIndex($scope.field_set.field_definitions, (fd)-> fd.id==id)
    $scope.field_set.field_definitions[idx].get()
    .then (resp)->
      $scope.field_set.field_definitions[idx] = resp
      $scope.$emit('fieldDefinitionUpdated')



# Single row in FieldDefinition list
# delegates saving and deleting to list controller
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
          $scope.field_definition.clone()
    }).result.then (updated_fd)->
      $scope.refresh_field_definition(updated_fd.id)

  $scope.delete = ()->
    message = "Are you sure you want to delet it?\n"
    message += "All data associated with this field will also be destroyed!"
    if window.confirm(message)
      $scope.field_definition.remove().then(
        (resp)->
          $scope.remove_field_definition(resp.id)
        ,(err)->
          #TODO: handle errors
      )



# Popup FieldDefinition editor
#
.controller "EditFieldDefinitionCtrl",
  ($scope, $modalInstance, field_definition)->
    $scope.field_definition = field_definition
    $scope.field_definition_types = FD_TYPES

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
        (ok)->
          $scope.$close($scope.field_definition)
        ,(err)->
          #TODO
      )



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
    }

  $scope.cancel_new_field_definition = ()->
    $scope.new_field_definition = null

  $scope.save_new_field_definition = ()->
    $scope.new_field_definition.order= $scope.field_set.field_definitions.length
    $scope.field_set.all('field_definitions')
      .post($scope.new_field_definition)
      .then(
        (resp)->
          $scope.add_field_definition(resp)
          $scope.init_new_field_definition()
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

