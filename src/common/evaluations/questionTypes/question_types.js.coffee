angular.module("case-ui.evaluations.question-types", [
  "case-ui.evaluations.question-types.yes-no-na"
  "case-ui.evaluations.question-types.likert"
])

.value "questionTypes",
  {}


.run (questionTypes, yesNoNaQuestionType, likertQuestionType)->
  questionTypes["Yes/No/Na"] = yesNoNaQuestionType
  questionTypes["Likert"] = likertQuestionType


# returns a question type's name
.factory "questionTypeName", (questionTypes)->
  (q)->
    return unless q and q.response_options
    name = _.findKey(questionTypes,
      (o)-> angular.equals(o.response_options, q.response_options))
    if name then name else null


# returns a question's type
.factory "questionType", (questionTypeName, questionTypes)->
  (q)->
    questionTypes[questionTypeName(q)]


.filter "questionType", (questionTypeName)->
  (q)-> questionTypeName(q)



.directive "questionTypeSelect", (questionTypes)->

  template = '<select class="form-control" '
  template +='ng-model="proxy.response_options"'
  template += 'ng-options="k as k for (k,v) in response_options">'
  template += '</select>'

  return {
    
    template: template
    replace: true
    scope:
      questionTypeSelect: "="
    link: (scope,elem,attrs)->
      scope.proxy = {}
      scope.response_options = questionTypes

      # watch the actual value, seting our proxy value
      # to the options group's key/name
      scope.$watch 'questionTypeSelect', (newType)->
        if newType
          type_name = _.findKey(questionTypes,
            (o)-> angular.equals(o.response_options, newType))
          scope.proxy.response_options = type_name

      # watch the proxy, setting the actual value to the
      # option group with the value's name
      scope.$watch 'proxy.response_options', (newTypeName)->
        if newTypeName
          q_type = questionTypes[newTypeName]
          scope.questionTypeSelect = q_type.response_options

  }