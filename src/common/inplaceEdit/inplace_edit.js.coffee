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
        # when we go into edit mode, grab a copy of the resource
        # to be reverted to on cancel
        if !element.hasClass('editting')
          scope.copy_for_cancel = angular.copy(scope.resource)
          console.log scope.copy_for_cancel


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
          save_method = 'put'
        else
          save_method = 'post'

        scope.resource[save_method]().then(
          (save_resp)->
            if save_resp.id  and !scope.resource.id
              scope.resource.id = save_resp.id
            scope.resource.get().then(
              (get_resp)->
                scope.resource = get_resp
                scope.$emit('inplaceEdit:onSave',get_resp)
            )
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
        # fetch a fresh copy
        if scope.resource.id
          scope.resource.get().then (resp)->
            scope.resource = resp
            element.toggleClass('editting')
       
        else
          # use the copy made for cancel
          scope.$apply ()->
            angular.copy(scope.copy_for_cancel, scope.resource)
            element.toggleClass('editting')



  }

)