angular.module("case-ui.globals", [
  'restangular'
])


.factory 'currentSchema', (Restangular, $rootScope)->

  currentSchema = {
    active: {}
    available: []
  }

  currentSchema.get_available = ->
    Restangular.all('schemas').getList().then (resp)->
      currentSchema.available = resp
      currentSchema

  currentSchema.set_active = (id)->
    if !id and this.available[0] and this.available[0].id
      id = this.available[0].id
    Restangular.one('schemas',id).get().then (resp)->
      currentSchema.active = resp
      $rootScope.$broadcast("currentSchemaChanged")


  currentSchema


# .factory 'currentEvaluation', (Restangular)->

#   currentEvaluation = {
#     active: null
#     available: []
#   }

#   currentEvaluation


       

