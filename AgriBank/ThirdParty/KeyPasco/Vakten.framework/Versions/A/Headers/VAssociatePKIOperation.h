#import <Foundation/Foundation.h>
#import <Vakten/VOperation.h>

@class VContext;
@class VPinManager;

/*!
 Operation is used to associate this device with a user.

 When the association is completed the -[VContext isAssociated] method will return YES.

 Possible return codes are VResultCodeSuccess, VResultCodeCanceled, VResultCodeError, VResultCodeInvalidContext and
 VResultCodeNoNetworkConnection.
 */
@interface VAssociatePKIOperation : VOperation

/*!
 @brief Initializes a VAssociatePKIOperation.

 @discussion This method must be called after the assciationCodePkiBegin function and before the assciationCodePkiEnd
 function in the Customer API. The assocation code returned by the assciationCodePkiBegin function should be used.

 @param context A pointer to the VContext instance
 @param api A URI to the Client API
 @param associationCode The association code
 @param pinManager Set pin for this association
 @param confirmationPinManager A confirmation of pin. pin and confirmation need to be the same pin.
 @return An VAssociateOperation object initialized. If the initialization fails, returns nil
 */
- (instancetype)initWithContext:(VContext *)context
                            API:(NSURL *)api
                associationCode:(NSString *)associationCode
                            pin:(VPinManager *)pinManager
                confirmationPin:(VPinManager *)confirmationPinManager;

@end
