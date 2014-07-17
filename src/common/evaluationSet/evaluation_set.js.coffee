angular.module("case-ui.evaluation-set", [
  'restangular'
])

.factory 'evaluationSetFactory', (Restangular)->

  (set_id)->
    state = {}

    state.evaluation_set = null

    state.cases       = [] # evaluated cases
    state.questions   = [] # eval set's questions
    state.responses   = [] # retreived responses (may be aggregated!)
    state.responses_lookup = [] # 2D lookup matrix for responses

    ##
    # Case loading functions
    ##
    state.cases_promise = null
    state.load_cases = (params = {})->
      if !state.cases_promise
        if state.evaluation_set
          state.cases_promise = state.evaluation_set.all("cases")
                                                    .getList(params)
          state.cases_promise.then (resp)->
            state.cases = resp
        else
          state.cases_promise = null
      else
        state.cases_promise

    state.refresh_cases = (params = {})->
      state.cases_promise = null
      state.load_cases(params)



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
            state.responses = resp
            for r in state.responses # build lookup matrix
              state.responses_lookup[r.case_id] ||= []
              state.responses_lookup[r.case_id][r.question_id] ||= []
              state.responses_lookup[r.case_id][r.question_id].push(r)
        else
          state.responses_promise = null
      else
        state.responses_promise

    state.refresh_responses = (params = {})->
      state.responses_promise = null
      state.load_responses(params)



    # return the promise
    Restangular.one("evaluations/sets",set_id).get().then(
      (resp)->
        state.evaluation_set = resp
        state.questions = resp.questions
        state.aggregates = resp.aggregates
        state
      (err)->

    )