angular.module("case-ui.evaluation-set", [
  'restangular'
])

.factory 'evaluationSetFactory', (Restangular)->

  (set_id)->
    state = {}

    state.evaluation_set = null

    state.cases       = [] # evaluated cases
    state.questions   = [] # eval set's questions
    state.responses   = [] # retreived responses
    state.aggregates  = [] # aggregate responses

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
    ##
    state.responses_promise = null
    state.load_responses = (params = {})->
      if !state.responses_promise
        if state.evaluation_set
          state.responses_promise = state.evaluation_set.all("responses")
                                                        .getList(params)
          state.responses_promise.then (resp)->
            state.responses = resp
        else
          state.responses_promise = null
      else
        state.responses_promise

    state.refresh_responses = (params = {})->
      state.responses_promise = null
      state.load_responses(params)



    state.responses_for = (kase)->
      if state.evaluation_set and state.responses
        # kase's responses
        for_case = state.responses.filter (response)->
          response.case_id == kase.id
        # sort by question order
        for_case.sort (a,b)->
          q_a = state.question_for(a)
          q_b = state.question_for(b)
          q_a.position - q_b.position


    state.question_for = (response)->
      _.find state.evaluation_set.questions, (q)-> q.id == response.question_id


    # return the promise
    Restangular.one("evaluations/sets",set_id).get().then(
      (resp)->
        state.evaluation_set = resp
        state.questions = resp.questions
        state.aggregates = resp.aggregates
        state
      (err)->

    )