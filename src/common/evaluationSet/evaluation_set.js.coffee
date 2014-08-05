angular.module("case-ui.evaluation-set", [
  'restangular'
])

.factory 'EvaluationSet', (Restangular)->

  Restangular.extendModel 'evaluations/sets', (model)->

    model.refresh = ()->
      model.get().then (resp)->
        angular.extend(model,resp)

    model.responses_lookup = {}

    # private helper
    store_response = (r)->
      model.responses_lookup ||= {}
      model.responses_lookup[r.case_id] ||= {}
      model.responses_lookup[r.case_id][r.question_id] ||= []
      bucket = model.responses_lookup[r.case_id][r.question_id]
      i = _.findIndex(bucket, (resp)-> resp.id == r.id )
      if i < 0
        bucket.push(r) # add new response
      else
        bucket[i] = r # replace existing response

    model.get_responses = (params = {})->
      model.all("responses").getList(params).then (resp)->
        store_response(r) for r in resp

    model.get_responses_for = (kase, question, params={})->
      model.responses_lookup ||= {}
      model.responses_lookup[kase.id] ||= {}
      model.responses_lookup[kase.id][question.id] = []
      params.question_id = question.id
      params.case_id = kase.id
      model.all("responses").getList(params).then(
        (resp)->
          store_response(r) for r in resp
      )


    model

  #return restangular service
  Restangular.service('evaluations/sets')

