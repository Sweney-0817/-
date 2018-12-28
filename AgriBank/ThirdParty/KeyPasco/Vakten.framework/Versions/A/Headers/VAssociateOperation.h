#import <Foundation/Foundation.h>
#import <Vakten/VOperation.h>

@class VContext;

/*!
 Operation is used to associate this device with a user.

 The association must be prepared by invoking the PrepareAssociation or getAssociationCode method in the Customer API
 and then use this operation with the appropriate initializer.

 When the association is completed the -[VContext isAssociated] method will return YES.

 Possible return codes are VResultCodeSuccess, VResultCodeCanceled, VResultCodeError, VResultCodeInvalidContext and
 VResultCodeNoNetworkConnection.
 */
@interface VAssociateOperation : VOperation

/*!
 @brief Initializes a VAssociateOperation.

 @discussion This method should be called with the assocation code returned by the getAssociationCode function in the
 Customer API.

 @param context A pointer to the VContext instance
 @param api A URI to the Client API
 @param associationCode The association code
 @return An VAssociateOperation object initialized. If the initialization fails, returns nil
 */
- (instancetype)initWithContext:(VContext *)context API:(NSURL *)api associationCode:(NSString *)associationCode;

@end
