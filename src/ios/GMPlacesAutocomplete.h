#import <Cordova/CDV.h>
#import <GooglePlaces/GooglePlaces.h>

@interface GMPlacesAutocomplete : CDVPlugin

@property (nonatomic, strong) GMSPlacesClient *placesClient;

- (void)openAutocomplete:(CDVInvokedUrlCommand*)command;

@end
