#import <Foundation/Foundation.h>
#import <Vakten/VOperation.h>

@class VContext;
@class VTaskPKI;

/*!
 Operation is used to download a task from the server.

 Vakten's fingerprint is used by the server to determine what tasks this application will receive.
 The application should show a user interface with a number pad and two buttons for either confirming or denying a task
 and then use the VSignTaskPKIOperation or VCancelTaskPKIOperation class to send the reply.

 Possible return codes are VResultCodeSuccess, VResultCodeCanceled, VResultCodeError, VResultCodeInvalidContext and
 VResultCodeNoNetworkConnection.
 */
@interface VGetTaskPKIOperation : VOperation

/*!
 @brief Returns the tasks.
 */
@property(readonly, nonatomic, strong) VTaskPKI *task;

/*!
 @brief Initializes a VGetTasksOperation.

 @param context A pointer to the VContext instance
 @param api An NSURL to the Client API
 @param customerID A string identifying the customer the is using the Customer API
 @param taskId A NSString pointer with the id of the task you want to get.
 @return An VGetTasksOperation object initialized. If the initialization fails, returns nil
 */
- (instancetype)initWithContext:(VContext *)context
                            API:(NSURL *)api
                     customerID:(NSString *)customerID
                         taskId:(NSString *)taskId;

/*!
 @brief Returns the tasks.

 @discussion  When this operation is complete this method returns a VTaskPKI object with information about the task. See
 the documentation for the VTaskPKI class for
 information how to interpret the VTaskPKI properties.
 */
- (VTaskPKI *)getTask;

@end
