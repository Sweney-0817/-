#import <Foundation/Foundation.h>
#import <Vakten/VOperation.h>

@class VContext;

/*!
 Operation is used to check that a session is running on a device that is associated to a user.

 Possible return codes are VResultCodeSuccess, VResultCodeCanceled, VResultCodeError, VResultCodeInvalidContext and
 VResultCodeNoNetworkConnection.
 */

@interface VAuthenticateOperation : VOperation

/*!
 @brief Initializes a VAuthenticateOperation.

 @discussion Passes the session ID to a cache in the Keypasco server which lets the Customer API authenticate method
 decide which device and location a user is using when logging in. This means that the authenticate
 operation must be executed before the authenticate function in the Customer API.

 @param context A pointer to the VContext instance
 @param api A URI to the Client API
 @param customerID A string identifying the customer the is using the Customer API
 @param sessionID The session identifier
 @return An VAuthenticateOperation object initialized. If the initialization fails, returns nil
 */
- (instancetype)initWithContext:(VContext *)context
                            API:(NSURL *)api
                     customerID:(NSString *)customerID
                      sessionID:(NSString *)sessionID;

@end
