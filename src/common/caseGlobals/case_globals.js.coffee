angular.module("case-ui.globals", [
  'restangular'
])


.factory 'currentSchema', (Restangular, $rootScope, $q)->

  currentSchema = {
    active: {}
    available: []
  }

  currentSchema.id= ->
    this.active.id

  currentSchema.get_available = ->
    Restangular.all('schemas').getList().then (resp)->
      currentSchema.available = resp
      currentSchema

  currentSchema.set_active = (id)->
    if !id and currentSchema.available[0] and currentSchema.available[0].id
      id = currentSchema.available[0].id
    Restangular.one('schemas',id).get().then (resp)->
      currentSchema.active = resp
      $rootScope.$broadcast("currentSchemaChanged")


  currentSchema.get_cases = ()->
    Restangular.one('schemas',currentSchema.active.id)
      .all('cases').getList().then (resp)->
        resp

  currentSchema


# .factory 'currentEvaluation', (Restangular)->

#   currentEvaluation = {
#     active: null
#     available: []
#   }

#   currentEvaluation


       

