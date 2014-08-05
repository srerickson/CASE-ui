angular.module("case-ui.globals", [
  'case-ui.schema'
  'case-ui.evaluation-set'
])


.factory 'caseGlobals', (EvaluationSet, Schema)->

  _this = {}

  _this.schemas = []
  _this.current_schema = {}

  _this.question_sets = []
  _this.current_question_set = {}

  schemas_promise = null
  _this.get_schemas = ()->
    if !schemas_promise
      schemas_promise = Schema.getList().then (resp)->
        _this.schemas = resp
    else
      schemas_promise

  _this.reload_schemas = ->
    schemas_promise = null
    _this.get_schemas()


  question_sets_promise = null
  _this.get_question_sets = ()->
    if !question_sets_promise
      question_sets_promise = EvaluationSet.getList().then (resp)->
        _this.question_sets = resp
    else
      question_sets_promise

  _this.reload_question_sets = ->
    question_sets_promise = null
    _this.get_question_sets()

  _this.set_current_schema = (id)->
    id ||= 'first'
    f = Schema.one(id).get().then(
      (resp)->
        console.log "current schema: #{resp.name}"
        _this.current_schema = resp
        _this.current_schema
      (err)->
        _this.current_schema = null
        _this.current_schema
    )

  _this.set_current_question_set = (id)->
    id ||= 'first'
    EvaluationSet.one(id).get().then(
      (resp)->
        console.log "current question set: #{resp.name}"
        _this.current_question_set = resp #service!
        _this.current_question_set
      (err)->
        _this.current_question_set = null
        _this.current_question_set
    )


  _this

    


       

