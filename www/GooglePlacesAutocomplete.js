var exec = require('cordova/exec');

var GooglePlacesAutocomplete = {
  /**
   * @param {String} query - The text to autocomplete (e.g. "Pizza")
   * @param {object} filters - An optional object { country: string, region: string, city: string }
   * @param {Function} successCallback - Receives an array of prediction objects
   * @param {Function} errorCallback - Receives an error message (string)
   */
  getAutocompleteSuggestions: function(query, filters, successCallback, errorCallback) {
    filters = filters || {};

    exec(
      successCallback,
      errorCallback,
      'GMPlacesAutocomplete',
      'getAutocompleteSuggestions',
      [query, filters],
    );
  },

  /**
   * @param {String} placeID - ID of GoogleMapsPlace
   * @param {Function} successCallback - Receives an array of prediction objects
   * @param {Function} errorCallback - Receives an error message (string)
   */
  getPlaceDetails: function (placeID, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'GMPlacesAutocomplete', 'getPlaceDetails', [placeID]);
  }
};

module.exports = GooglePlacesAutocomplete;
