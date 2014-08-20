angular.module("case-ui.schema", ["restangular"])

.factory "Schema", (Restangular)->

  Restangular.extendModel 'schemas', (model)->
    model.refresh = ()->
      model.get().then (resp)->
        angular.extend(model,resp)
    model

  Restangular.addElementTransformer("schemas", false, (elem)->
    if elem.field_sets
      elem.field_sets = Restangular.restangularizeCollection(
        elem,
        elem.field_sets,
        'field_sets'
      )
    return elem
  )

  Restangular.addElementTransformer("field_sets", false, (elem)->
    if elem.field_definitions
      elem.field_definitions = Restangular.restangularizeCollection(
        elem,
        elem.field_definitions,
        'field_definitions'
      )
    return elem
  )

  Restangular.extendModel 'field_definitions', (model)->
    if model.type == "SelectField"
      model.select_lookup = (field_value)->
        if field_value
          option = _.find model.value_options.select, (opt)->
            opt.id == field_value.value
          return option
    model

  # return restangular service
  Restangular.service('schemas')

