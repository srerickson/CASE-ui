angular.module("case-ui.globals", [
  'restangular'
])


# WARNING -- question_set is a service: 'evaluationSetFactory'

.factory 'caseGlobals',
  (Restangular, $rootScope, evaluationSetFactory, $q)->

    _this = {}
    
    _this.schemas = []
    _this.current_schema = {}

    _this.question_sets = []
    _this.current_question_set = {}

    schemas_promise = null
    _this.get_schemas = ()->
      if !schemas_promise
        schemas_promise = Restangular.all('schemas')
          .getList().then (resp)->
            _this.schemas = resp
      else
        schemas_promise


    question_sets_promise = null
    _this.get_question_sets = ()->
      if !question_sets_promise
        question_sets_promise = Restangular.all('evaluations/sets')
          .getList().then (resp)->
            _this.question_sets = resp
      else
        question_sets_promise


    _this.set_current_schema = (id)->
      id ||= 'first'
      Restangular.one('schemas', id).get().then(
        (resp)->
          _this.current_schema = resp
          _this.current_schema
        (err)->
          _this.current_schema = null
          _this.current_schema
      )

    _this.set_current_question_set = (id)->
      id ||= 'first'
      evaluationSetFactory(id).then(
        (resp)->
          _this.current_question_set = resp #service!
          _this.current_question_set
        (err)->
          _this.current_question_set = null
          _this.current_question_set
      )


    $rootScope.$on("questionSetsModified", ()->
      question_sets_promise = null
      $scope.get_question_sets()
    )

    $rootScope.$on("schemasModified", ()->
      schemas_promise = null
      $scope.get_schemas()
    )


    _this.get_schemas()
    _this.get_question_sets()
    _this

    


       

