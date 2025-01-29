#import "GMPlacesAutocomplete.h"
#import <Cordova/CDV.h>
#import <GooglePlaces/GooglePlaces.h>

@implementation GMPlacesAutocomplete

- (void)pluginInitialize {
    [super pluginInitialize];

    NSString *APIKey = [((CDVViewController *)self.viewController).settings objectForKey:@"google_places_ios_api_key"];

    [GMSPlacesClient provideAPIKey:APIKey];

    self.placesClient = [GMSPlacesClient sharedClient];
}

- (void)getAutocompleteSuggestions:(CDVInvokedUrlCommand*)command {

    NSString *query = [command argumentAtIndex:0 withDefault:nil];
    if (query == nil || [query length] == 0) {
        CDVPluginResult *errorResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing or empty search query."];
        [self.commandDelegate sendPluginResult:errorResult callbackId:command.callbackId];
        return;
    }

    NSDictionary *filters = [command argumentAtIndex:1 withDefault:@{}];
    if (![filters isKindOfClass:[NSDictionary class]]) {
        filters = @{};
    }

    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];

    NSString *country = filters[@"country"];
    if ([country isKindOfClass:[NSString class]] && [country length] > 0) {
        filter.country = country;
    }

    [self.placesClient findAutocompletePredictionsFromQuery:query
                                             filter:filter
                                               sessionToken:nil
                                              callback:^(NSArray<GMSAutocompletePrediction *> * _Nullable results, NSError * _Nullable error) {
        if (error != nil) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }

        if (!results || results.count == 0) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:@[]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }

        NSMutableArray *predictionArray = [NSMutableArray arrayWithCapacity:results.count];
        for (GMSAutocompletePrediction *prediction in results) {
            NSString *fullText = prediction.attributedFullText.string ?: @"";
            NSString *primaryText = prediction.attributedPrimaryText.string ?: @"";
            NSString *secondaryText = prediction.attributedSecondaryText.string ?: @"";
            NSString *placeID = prediction.placeID ?: @"";

            NSDictionary *dict = @{
                @"fullText": fullText,
                @"primaryText": primaryText,
                @"secondaryText": secondaryText,
                @"placeID": placeID
            };
            [predictionArray addObject:dict];
        }

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:predictionArray];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getPlaceDetails:(CDVInvokedUrlCommand*)command {
    NSString *placeID = [command argumentAtIndex:0 withDefault:nil];
    if (placeID == nil || [placeID length] == 0) {
        CDVPluginResult *errorResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                        messageAsString:@"Missing or empty placeID."];
        [self.commandDelegate sendPluginResult:errorResult callbackId:command.callbackId];
        return;
    }

    GMSPlaceField fields = (GMSPlaceFieldName |
                            GMSPlaceFieldFormattedAddress |
                            GMSPlaceFieldCoordinate |
                            GMSPlaceFieldAddressComponents);

    [self.placesClient fetchPlaceFromPlaceID:placeID
                                 placeFields:fields
                               sessionToken:nil
                                   callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
        if (error != nil) {
            CDVPluginResult *pluginResult =
                [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                  messageAsString:[error localizedDescription]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        if (!place) {
            CDVPluginResult *pluginResult =
                [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                  messageAsString:@"No place found."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }

        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];

        double lat = place.coordinate.latitude;
        double lng = place.coordinate.longitude;

        NSMutableDictionary *positionDict = [NSMutableDictionary dictionary];
        positionDict[@"lat"] = @(lat);
        positionDict[@"lng"] = @(lng);

        resultDict[@"position"] = positionDict;

        NSString *city = @"";
        NSString *countryCode = @"";
        NSString *countryName = @"";
        NSString *postalCode = @"";
        NSString *adminArea = @"";
        NSString *subAdminArea = @"";
        NSString *locality = @"";
        NSString *thoroughfare = @"";
        NSString *subLocality = @"";
        NSString *streetNumber = @"";

        for (GMSAddressComponent *component in place.addressComponents) {
            for (NSString *type in component.types) {
                if ([type isEqualToString:@"locality"]) {
                    city = component.name;
                    locality = component.name;
                }
                else if ([type isEqualToString:@"administrative_area_level_1"]) {
                    adminArea = component.name;
                }
                else if ([type isEqualToString:@"administrative_area_level_2"]) {
                    subAdminArea = component.name;
                }
                else if ([type isEqualToString:@"country"]) {
                    countryName = component.name;
                    countryCode = component.shortName;
                }
                else if ([type isEqualToString:@"postal_code"]) {
                    postalCode = component.name;
                }
                else if ([type isEqualToString:@"route"]) {
                    thoroughfare = component.name;
                }
                else if ([type isEqualToString:@"sublocality"] ||
                         [type isEqualToString:@"sublocality_level_1"]) {
                    subLocality = component.name;
                }
                else if ([type isEqualToString:@"street_number"]) {
                    streetNumber = component.name;
                }
            }
        }

        NSString *streetFull = [streetNumber length] > 0
            ? [NSString stringWithFormat:@"%@ %@", streetNumber, thoroughfare]
            : thoroughfare;

        resultDict[@"adminArea"] = adminArea;
        resultDict[@"country"] = countryName;
        resultDict[@"locality"] = locality;
        resultDict[@"postalCode"] = postalCode;
        resultDict[@"subAdminArea"] = subAdminArea;
        resultDict[@"thoroughfare"] = thoroughfare;

        NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
        NSMutableDictionary *addrDict = [NSMutableDictionary dictionary];

        addrDict[@"City"] = city ?: @"";
        addrDict[@"Country"] = countryName ?: @"";
        addrDict[@"CountryCode"] = countryCode ?: @"";
        addrDict[@"State"] = adminArea ?: @"";
        addrDict[@"Street"] = streetFull ?: @"";
        addrDict[@"ZIP"] = postalCode ?: @"";
        addrDict[@"Name"] = place.name ?: @"";

        extraDict[@"address"] = addrDict;
        extraDict[@"description"] = place.formattedAddress ?: @"";
        extraDict[@"identifier"] = placeID;
        extraDict[@"radius"] = @"";

        resultDict[@"extra"] = extraDict;

        CDVPluginResult *pluginResult =
            [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
