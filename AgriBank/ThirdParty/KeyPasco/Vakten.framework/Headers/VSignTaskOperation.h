#import <Foundation/Foundation.h>
#import <Vakten/VOperation.h>

@class VContext;
@class VTask;

/*!
 Operation to sign tasks.
 
 After the user has signed a task this operation is used to send the reply to the server. The server will only accept this reply from a device that belongs
 to the user that initiated the task. 
 
 Possible return codes are VResultCodeSuccess, VResultCodeCanceled, VResultCodeError, VResultCodeInvalidContext and VResultCodeNoNetworkConnection.
 */
@interface VSignTaskOperation : VOperation

/*!
 @brief Initializes a VSignTaskOperation operation.
 
 @param context A VContext.
 @param api A NSURL to a valid API
 @param customerID A NSString with a customer ID
 @param task The task that should be signed
 @return An VSignTaskOperation object initialized. If the any of the parameters is nil or was malformed, returns nil.
 */
- (instancetype)initWithContext:(VContext *)context API:(NSURL *)api customerID:(NSString *)customerID task:(VTask *)task;


@end
