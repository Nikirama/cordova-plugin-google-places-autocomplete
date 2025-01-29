# Cordova GooglePlaces plugin (iOS only!)

[![](https://img.shields.io/npm/dm/cordova-plugin-googleplaces-autocomplete.svg)](https://npm-stat.com/charts.html?package=cordova-plugin-googleplaces-autocomplete)

## This plugin provides autocomplete feature from GooglePlaces iOS SDK in your application.

-----

## Install

  ```
  cordova plugin add cordova-plugin-googleplaces-autocomplete
  ```

#### Then set your Google Maps API keys into your `config.xml` (Android / iOS).

  ```xml
  <widget ...>
    <preference name="GOOGLE_PLACES_IOS_API_KEY" value="(api key)" />
  </widget>
  ```

___

## API

`getAutocompleteSuggestions(query, filters, success, failure);`

Returns a list of place suggestions for a given search query.

| Parameter | Type                                                                 | Description                                                                                     |
|-----------|----------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| query     | `string`                                                             | The text query to search for.                                                                   |
| filters   | `{ country: string }` (optional)                                     | Optional search filters. Currently supports country to limit suggestions to a specific country. |
| success   | `(results: GooglePlacesAutocompleteSuggestion[]) => void` (optional) | Callback function invoked with an array of suggestion objects if the request is successful.     |
| failure   | `(error: any) => void` (optional)                                    | Callback invoked if there's an error retrieving suggestions.                                    |

### Example:

```js
window.plugin.google.places.getAutocompleteSuggestions(
  'Paris',
  { country: 'FR' },
  function onSuccess(suggestions) {
    console.log(suggestions);
  },
  function onError(err) {
    console.error(err);
  }
);
```

`getPlaceDetails(placeID, success, failure)`

Returns detailed information about a specific place.

| Parameter | Type                                                 | Description                                                                     |
|-----------|------------------------------------------------------|---------------------------------------------------------------------------------|
| placeID   | `string`                                             | The unique ID of the place (from `GooglePlacesAutocompleteSuggestion.placeID`). |
| success   | `(result: GooglePlacesAutocompleteLocation) => void` | Callback function invoked with the place details upon success.                  |
| failure   | `(error: any) => void` (optional)                    | Callback function invoked if the place details request fails.                   |

### Example:

```js
window.plugin.google.places.getPlaceDetails(
  "<placeID>",
  function onSuccess(result) {
    console.log('Place details:', result);
  },
  function onError(err) {
    console.error('Error:', err);
  }
);
```

___

## TypeScript interfaces

```ts
interface GooglePlacesAutocompletePlugin {
  getAutocompleteSuggestions: (
    query: string,
    filters?: { country: string },
    success?: (results: GooglePlacesAutocompleteSuggestion[]) => void,
    failure?: (error: any) => void
  ) => void;

  getPlaceDetails: (
    placeID: string,
    success?: (result: GooglePlacesAutocompleteLocation) => void,
    failure?: (error: any) => void
  ) => void;
}

interface GooglePlacesAutocompleteSuggestion {
  fullText: string;
  placeID: string;
  primaryText: string;
  secondaryText: string;
}

interface GooglePlacesAutocompleteLocation {
  adminArea: string;
  country: string;
  countryCode: string;
  extra: {
    address: {
      City: string;
      Country: string;
      CountryCode: string;
      FormattedAddressLines?: string[];
      Name: string;
      State: string;
      Street: string;
      SubAdministrativeArea: string;
      thoroughfare: string;
      ZIP: string;
    };
    description: string;
    identifier: string;
    name: string;
    radius: string;
  };
  locality: string;
  position: { lat: number, lng: number };
  postalCode: string;
  subAdminArea: string;
  thoroughfare: string;
}

```
