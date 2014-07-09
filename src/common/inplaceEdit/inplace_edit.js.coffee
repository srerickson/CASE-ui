angular.module("inplaceEdit", [])

.directive("inplaceEdit", ()->
  {
    restrict: 'C'
    link: (scope, element, attrs)->
      element.find('.inplace-edit-toggle').click ()->
        element.toggleClass('editting')
    controller: ($scope)->
      $scope.$on 'inPlaceEditSaved', (e)->
        console.log e



  }

)