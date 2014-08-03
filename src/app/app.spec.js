describe( 'AppCtrl', function() {
  describe( 'isCurrentUrl', function() {
    var AppCtrl, $location, $scope;

    beforeEach( module( 'case-ui' ) );

    beforeEach( inject( function($controller, _$location_, $rootScope, currentUser ) {
      $location = _$location_;
      $scope = $rootScope.$new();
      spyOn(currentUser,'get').andCallThrough();
      AppCtrl = $controller( 'AppCtrl', { $location: $location, $scope: $scope });

    }));



    it( 'should pass a dummy test', function() {
      expect( AppCtrl ).toBeTruthy();
    });

    it( 'should call currentUser.get() on instantiation', inject( function(currentUser){
      expect(currentUser.get).toHaveBeenCalled();
    }));

    it ('should have a globals object', function(){
      expect ($scope.globals).not.toBeUndefined();
    });

    it ('should call caseGlobals.reload_schemas on schema change events', inject( function(caseGlobals, $rootScope){
      spyOn(caseGlobals,'reload_schemas');
      $rootScope.$broadcast("schemaCreated");
      $rootScope.$broadcast("schemaRemoved");
      $rootScope.$broadcast("schemaModified");
      expect( caseGlobals.reload_schemas.callCount ).toBe(3);
    }));

    it ('should call currentUser.login_prompt on event:auth-loginRequired', inject( function(currentUser, $rootScope){
      spyOn(currentUser, 'login_prompt');
      $rootScope.$broadcast("event:auth-loginRequired");
      expect( currentUser.login_prompt).toHaveBeenCalled();
    }));

  });
});
