angular.module("case-ui.evaluation-set", [
  'restangular'
])

.factory 'evaluationSetFactory', (Restangular)->

  (set_id)->
    state = {}

    state.evaluation_set = null

    state.questions   = [] # eval set's questions
    state.responses_lookup = {} # 2D lookup matrix for responses

    responses_promise = null # a promise to cache result get request

    state.get = ->
      Restangular.one("evaluations/sets",set_id).get().then(
        (resp)->
          state.evaluation_set = resp
          state.questions = resp.questions
          state.aggregates = resp.aggregates
          responses_promise = null
          state
        (err)->
          state
      )

    state.id = ->
      state.evaluation_set.id

    ##
    # Heler function for populating state.responses_lookup
    #
    store_response = (r)->
      # build bucket if necessary
      state.responses_lookup ||= {}
      state.responses_lookup[r.case_id] ||= {}
      state.responses_lookup[r.case_id][r.question_id] ||= []
      bucket = state.responses_lookup[r.case_id][r.question_id]
      # check if a response already exists
      i = _.findIndex(bucket, (resp)-> resp.id == r.id )
      if i < 0
        bucket.push(r) # add new response
      else
        bucket[i] = r # replace existing response


    ##
    # Response Loading Functions
    #
    state.get_responses = (params = {})->
      if !responses_promise
        if state.evaluation_set
          responses_promise = state.evaluation_set.all("responses")
                                                  .getList(params)
          responses_promise.then (resp)->
            store_response(r) for r in resp
            return resp
        else
          responses_promise = null
      else
        responses_promise

    state.refresh_responses = (params = {})->
      state.responses_lookup = {}
      responses_promise = null
      state.get_responses(params)


    state.refresh_responses_for = (kase, question, params={})->
      state.responses_lookup ||= {}
      state.responses_lookup[kase.id] ||= {}
      state.responses_lookup[kase.id][question.id] = []
      params.question_id = question.id
      params.case_id = kase.id
      state.evaluation_set.all("responses").getList(params).then(
        (resp)->
          store_response(r) for r in resp
      )


    # return the promise
    state.get()