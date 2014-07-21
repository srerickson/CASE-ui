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

        show_height= element.find('.inplace-edit-show.match-size')
          .first().css('height')
        show_width= element.find('.inplace-edit-show.match-size')
          .first().css('width')

        element.find('.inplace-edit-form.match-size')
          .first().css('height', show_height)
        element.find('.inplace-edit-form.match-size')
          .first().css('width', show_width)

        element.toggleClass('editting')

      element.find('.inplace-edit-save').click ()->
        _save()

      element.find('.inplace-edit-cancel').click ()->
        _cancel()

      _save = ()->
        if scope.resource.id
          save_method = scope.resource.put
        else
          save_method = scope.resource.post

        save_method().then(
          (resp)->
            if resp.id  # response includes object
              scope.resource = resp
            else        # refresh object
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