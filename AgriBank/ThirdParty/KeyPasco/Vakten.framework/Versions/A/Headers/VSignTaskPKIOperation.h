#import <Foundation/Foundation.h>
#import <Vakten/VOperation.h>
#import <Vakten/VReplyTaskOperation.h>
#import <Vakten/VTaskReply.h>

@class VContext;
@class VTaskPKI;
@class VPinManager;

/*!
 Operation to sign PKI tasks.

 @discussion After the user has denied or confirmed a task this operation is used to send the reply to the server. The
 server will only accept this reply from a device that belongs
 to the user that initiated the task.

 Possible return codes are VResultCodeSuccess, VResultCodeCanceled, VResultCodeError, VResultCodeInvalidContext and
 VResultCodeNoNetworkConnection.
 */
@interface VSignTaskPKIOperation : VOperation

/*!
 Initializes a VSignTaskPKIOperation

 @param context A VContext.
 @param api A NSURL to a valid API
 @param customerID A NSString with a customer ID
 @param taskID A NSString with a task ID
 @param taskMessage The message of the task that will be signed.
 @param reply A VTaskReply (enum)
 @param pin The pin
 @return An VReplySignPKIOperation object initialized. If the any of the parameters is nil or was malformed, returns
 nil.
 */
- (instancetype)initWithContext:(VContext *)context
                            API:(NSURL *)api
                     customerID:(NSString *)customerID
                         taskID:(NSString *)taskID
                    taskMessage:(NSString *)taskMessage
                          reply:(VTaskPKISign)reply
                            pin:(NSString *)pin
    __attribute__((deprecated("Use initWithContext:API:customerID:task:pinManager:")));

/*!
 Initializes a VSignTaskPKIOperation

 @param context A VContext.
 @param api A NSURL to a valid API
 @param customerID A NSString with a customer ID
 @param taskID A NSString with a task ID
 @param taskMessage The message of the task that will be signed.
 @param reply A VTaskReply (enum)
 @param pinManager A pin manager containing the pin code
 @return An VReplySignPKIOperation object initialized. If the any of the parameters is nil or was malformed, returns
 nil.
 */
- (instancetype)initWithContext:(VContext *)context
                            API:(NSURL *)api
                     customerID:(NSString *)customerID
                         taskID:(NSString *)taskID
                    taskMessage:(NSString *)taskMessage
                          reply:(VTaskReply)reply
                     pinManager:(VPinManager *)pinManager
    __attribute__((deprecated("Use initWithContext:API:customerID:task:pinManager:")));

/*!
 Initializes and returns a VSignTaskPKIOperation that will sign the given task id.

 @param context A VContext.
 @param api A NSURL to a valid API
 @param customerID A NSString with a customer ID
 @param task The task that should be signed
 @param pinManager A pin manager containing the pin code
 @return An VReplySignPKIOperation object initialized. If the any of the parameters is nil or was malformed, returns
 nil.
 */
- (instancetype)initWithContext:(VContext *)context
                            API:(NSURL *)api
                     customerID:(NSString *)customerID
                           task:(VTaskPKI *)task
                     pinManager:(VPinManager *)pinManager;

@end
