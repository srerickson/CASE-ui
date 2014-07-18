# Assumes resource is Restangularized

angular.module("inplaceEdit", ['restangular'])

.directive("inplaceEdit", (Restangular)->
  {
    restrict: 'A'
    scope:
      resource: "=ngModel"
    link: (scope, element, attrs)->

      element.addClass("inplace-edit")

      element.find('.inplace-edit-toggle').click ()->
        element.toggleClass('editting')

      element.find('.inplace-edit-save').click ()->
        _save()

      element.find('.inplace-edit-cancel').click ()->
        _cancel()

      _save = ()->
        scope.resource.save().then(
          ()->
            scope.resource.get().then (resp)-> scope.resource = resp
            element.toggleClass('editting')
            element.find('.inplace-edit-show')
              .addClass('flash')
              .delay(1000).queue ()->
                $(this).removeClass("flash").dequeue()
          (err)->
            console.log err
            # deal with error
        )

      _cancel = (resource)->
        scope.resource.get().then (resp)->
          scope.resource = resp
          element.toggleClass('editting')


  }

)