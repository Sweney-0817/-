#import <Foundation/Foundation.h>
#import <Vakten/VOperation.h>

@class VContext;
@class VTaskPKI;

/*!
 Operation is used to download a task from the server.

 Vakten's fingerprint is used by the server to determine what tasks this application will receive.
 The application should show a user interface with a number pad and two buttons for either confirming or denying a task
 and then use the VSignTaskPKIOperation or VCancelTaskOperation class to send the reply.

 Possible return codes are VResultCodeSuccess, VResultCodeCanceled, VResultCodeError, VResultCodeInvalidContext and
 VResultCodeNoNetworkConnection.
 */
@interface VGetTasksPKIOperation : VOperation

/*!
 @brief Get all tasks

 @discussion When operation is complete returns an array of VTaskPKI objects with information about the tasks. See the
 documentation for the VTaskPKI
 class for information how to interpret the VTaskPKI properties.
 */
@property(nonatomic, readonly) NSArray *tasks;

/*!
 Initializes a VGetTasksOperation.

 Unlike the other operations the VGetTaskOperation does not need a session ID.

 @param context A pointer to the VContext instance
 @param api An NSURL to the Client API
 @param customerID A string identifying the customer the is using the Customer API
 @return An VGetTasksOperation object initialized. If the initialization fails, returns nil
 */
- (instancetype)initWithContext:(VContext *)context API:(NSURL *)api customerID:(NSString *)customerID;

/*!
 Get a task with a specified ID

 Utility method to get a specific task from all fetched tasks given its task id. The same thing could be achieved by
 using the VGetTaskPKIOperation class.

 @param taskID NSString with an ID of the task to be returned
 @return The VTask with the requested taskID. If taskID does not exist or is nil, returns nil
 */
- (VTaskPKI *)taskWithID:(NSString *)taskID;

@end
