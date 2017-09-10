#import <Foundation/Foundation.h>
#import <Vakten/VOperation.h>
#import <Vakten/VTaskReply.h>

@class VContext;
@class VTask;

/*!
 After the user has denied or confirmed a task this operation is used to send the reply to the server. The server will
 only accept this reply from a device that belongs to the user that initiated the task.

 Possible return codes are VResultCodeSuccess, VResultCodeCanceled, VResultCodeError, VResultCodeInvalidContext and
 VResultCodeNoNetworkConnection.

 @note This class is depricated and will bbe removed in next release of Vakten SDK. Use VSignTaskOperation and
 VCancelTaskOperation instead.
 */
__attribute__((deprecated("Use VSignTaskOperation and VCancelTaskOperation instead"))) @interface VReplyTaskOperation
    : VOperation

      /*!
       @brief Initializes a VReplyTaskOperation operation.

       @param context A VContext.
       @param api A NSURL to a valid API
       @param customerID A NSString with a customer ID
       @param taskID A NSString with a task ID
       @param reply A VTaskReply (enum)
       @return An VReplyTaskOperation object initialized. If the any of the parameters is nil or was malformed, returns
       nil.
       */
      -
      (instancetype)initWithContext : (VContext *)context API : (NSURL *)api customerID : (NSString *)customerID taskID
                                                                                          : (NSString *)taskID reply
                                                                                            : (VTaskReply)reply;

@end
