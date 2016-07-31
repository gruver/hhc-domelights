angular.module('lightsController', ['lights.services'])
    .controller('LightsController', ['$scope',
        function ($scope) {
            $scope.init = function (address, type) {
                console.log('hello dome');
            };
        }]);
