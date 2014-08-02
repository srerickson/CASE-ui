# Top-level Abstract Route.
#
# Defines global url params:
#   current_schema_id
#   current_set_id
#
# Global resolves:
#   current_schema
#   current_question_set
#
# The template shows error message if these aren't set

angular.module("case-ui.root", [
  "ui.router"
  "case-ui.globals"
])


.config ($stateProvider, RestangularProvider) ->

  $stateProvider.state "root",
    abstract: true
    url: '?current_schema_id&current_set_id'
    views:
      '':
        templateUrl: 'root/root.tpl.html'
      'user-config':
        templateUrl: 'user_config/user.tpl.html'
        controller: 'UserConfigCtrl'
    resolve:
      current_schema:["caseGlobals", "$stateParams",
        (caseGlobals, $stateParams)->
          schema_id = parseInt($stateParams.current_schema_id)
          caseGlobals.set_current_schema(schema_id)
      ]
      current_question_set: ["caseGlobals", "$stateParams",
        (caseGlobals, $stateParams)->
          set_id = parseInt($stateParams.current_set_id)
          caseGlobals.set_current_question_set(set_id)
      ]
