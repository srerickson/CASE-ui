response_option_groups = {
  "none": {}
  "YES/NO/NA":
    "0": "N/A"
    "1": "YES"
    "-1": "NO"
  "Likert":
    "1": "Stronly Disagree"
    "2": "Disagree"
    "3": "Neither agree nor disagree"
    "4": "Agree"
    "5": "Stronly Agree"
}

angular.module("case-ui.question-sets.response-options", [])


.filter "responseOptionsName", ()->
  (input)->
    name = _.findKey(response_option_groups,
      (o)-> angular.equals(o, input))
    if name then name else "?"



.directive "responseOptionsSelect", ()->

  template = '<select class="form-control" '
  template +='ng-model="proxy.response_options"'
  template += 'ng-options="k as k for (k,v) in response_options">'
  template += '</select>'

  return {
    
    template: template
    replace: true
    scope:
      responseOptionsSelect: "="
    link: (scope,elem,attrs)->
      scope.response_options = response_option_groups
      scope.proxy = {}

      # watch the actual value, seting our proxy value
      # to the options group's key/name
      scope.$watch 'responseOptionsSelect', (newOpts)->
        if newOpts
          opt_name = _.findKey(scope.response_options,
            (o)-> angular.equals(o, newOpts))
          scope.proxy.response_options = opt_name

      # watch the proxy, setting the actual valu to the
      # option group with the value's name
      scope.$watch 'proxy.response_options', (newOptName)->
        if newOptName
          opt_group = scope.response_options[newOptName]
          if !angular.equals(opt_group, scope.responseOptionsSelect)
            scope.responseOptionsSelect = opt_group


  }