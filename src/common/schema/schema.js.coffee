angular.module("case-ui.schema", ["restangular"])

.factory "Schema", (Restangular)->
  Restangular.extendModel 'schemas', (model)->
    model.refresh = ()->
      model.get().then (resp)->
        angular.extend(model,resp)
    model

  # return restangular service
  Restangular.service('schemas')

