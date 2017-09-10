#import <Foundation/Foundation.h>
#import <Vakten/VOperation.h>

@class VContext;
@class VTaskPKI;

/*!
 Operation to cancel PKI tasks. 
 
 After the user has denied a PKI task this operation is used to send the reply to the server. The server will only accept this reply from a device that belongs
 to the user that initiated the task. 
 
 Possible return codes are VResultCodeSuccess, VResultCodeCanceled, VResultCodeError, VResultCodeInvalidContext and VResultCodeNoNetworkConnection.
 */
@interface VCancelTaskPKIOperation : VOperation

/*!
Initializes and returns a VCancelTaskPKIOperation that will cancel the given task id.

@param context A VContext.
@param api A NSURL to a valid API
@param customerID A NSString with a customer ID
@param task The task that should be canceld
@return An VCancelTaskPKIOperation object initialized. If the any of the parameters is nil or was malformed, returns nil.
*/
- (instancetype)initWithContext:(VContext *)context API:(NSURL *)api customerID:(NSString *)customerID task:(VTaskPKI *)task;

@end
