angular.module("case-ui.fields", ["restangular"])




.directive "fieldValue", (Restangular)->
  linker = (scope, attrs, elem)->

    ##
    # Returns path to field value's render/form html template
    #
    scope.template = ()->
      if scope.forField
        styles = []
        styles.push scope.templateStyle if scope.templateStyle

        base_path =  "fields/field_templates/"
        type = ""
        if scope.forField.type == "SelectField"
          type = "select"
        else if scope.forField.type == "TextField"
          type = "text"

        #FIXME - short only used on forms
        if "form" in styles
          if scope.forField.value_options.short
            styles.push("short")
        if styles.length
          tpl = "#{base_path}_#{type}_#{(styles).join('_')}.tpl.html"
        else
          tpl = "#{base_path}_#{type}.tpl.html"
        # console.log tpl
        tpl


  return {
    link: linker
    template: "<div ng-include=' template() '></div>"
    scope: {
      fieldValue: "="
      forField: "="
      templateStyle: "@"
    }
  }



