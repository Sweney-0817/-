#import <Foundation/Foundation.h>
#import <Vakten/VOperation.h>

@class VContext;
@class VPinManager;

/*!

 Operation is used to change the pin for an associated device.

 If changed pin operation is used with the wrong pin the maximum number of times that is defined on the server the
 device is locked and needs to be associated again.

 Possible return codes are VResultCodeSuccess, VResultCodeCanceled, VResultCodeError and VResultCodeNoNetworkConnection,
 VResultCodeChangePinFailed, VResultCodeInvalidContext or VResultCodeInvalidPin.
 */

@interface VChangePinPKIOperation : VOperation

/*!
 @brief Initializes a VChangePinPKIOperation

 @discussion This operation is used to change the pin for the user.

 @param context A VContext.
 @param api A NSURL to a valid API
 @param customerID A NSString with a customer ID
 @param currentPin A pin manager containing the current pin code
 @param newPin A pin manager containing the new pin code
 @param confirmationPin A pin manager that must contain the same pin as newPin
 @return An VChangePinPKIOperation object initialized. If the any of the parameters is nil or was malformed, returns
 nil.
 */
- (instancetype)initWithContext:(VContext *)context
                            API:(NSURL *)api
                     customerID:(NSString *)customerID
                     currentPin:(VPinManager *)currentPin
                         newPin:(VPinManager *)newPin
            withConfirmationPin:(VPinManager *)confirmationPin;

@end
