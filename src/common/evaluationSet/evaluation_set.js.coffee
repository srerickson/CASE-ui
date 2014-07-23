angular.module("case-ui.evaluation-set", [
  'restangular'
])

.factory 'evaluationSetFactory', (Restangular)->

  (set_id)->
    state = {}

    state.evaluation_set = null

    state.questions   = [] # eval set's questions
    state.responses_lookup = [] # 2D lookup matrix for responses

    state.id = ->
      state.evaluation_set.id

    store_response = (r)->
      # build bucket if necessary
      state.responses_lookup ||= []
      state.responses_lookup[r.case_id] ||= []
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
    state.responses_promise = null
    state.load_responses = (params = {})->
      if !state.responses_promise
        if state.evaluation_set
          state.responses_promise = state.evaluation_set.all("responses")
                                                        .getList(params)
          state.responses_promise.then (resp)->
            store_response(r) for r in resp
            return resp
        else
          state.responses_promise = null
      else
        state.responses_promise

    state.refresh_responses = (params = {})->
      state.responses_promise = null
      state.load_responses(params)


    state.refresh_response_for = (kase, question, params={})->
      params.question_id = question.id
      params.case_id = kase.id
      state.evaluation_set.all("responses").getList(params).then(
        (resp)->
          store_response(r) for r in resp
      )


    # return the promise
    Restangular.one("evaluations/sets",set_id).get().then(
      (resp)->
        state.evaluation_set = resp
        state.questions = resp.questions
        state.aggregates = resp.aggregates
        state
      (err)->

    )