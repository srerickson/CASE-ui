angular.module("case-ui.cases.new", [
  "ui.router"
  "restangular"
  # "hc.marked"
])


.config ($stateProvider) ->

  $stateProvider.state "new_case",
    parent: "root"
    url: "/cases/new"
    controller: "NewCaseCtrl"
    templateUrl: "cases/new/new_case.tpl.html"
    data:
      pageTitle: "New Case"



# New Case Controller
#
.controller "NewCaseCtrl", ($scope, $state, Restangular)->
  $scope.kase = {}

  $scope.save = ()->
    Restangular.all('cases').post($scope.kase).then(
      (resp)->
        $state.go('edit_case',{case_id: resp.id})
      (err)->
        console.log err

    )

