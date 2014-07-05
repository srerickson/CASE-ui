angular.module("case-ui.basic-fields", [])

.directive("basicFields", ()->

  return {
    restrict: "A"
    replace: true
    templateUrl: "basicFields/basicFields.tpl.html"
    scope: {
      model: "=basicFields"
    }
  }



)
