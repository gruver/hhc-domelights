/**
 * Angular Module
 *
 * Registers the top level module and acts as the central repository of filters and directives
 */
var module = angular.module('LightsModule', [
    'lights.services',
    'lights.controllers',
]);
