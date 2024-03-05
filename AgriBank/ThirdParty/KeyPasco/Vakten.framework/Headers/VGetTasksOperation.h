#import <Foundation/Foundation.h>
#import <Vakten/VOperation.h>

@class VContext;
@class VTask;

/*!
 Operation is used to download the list of task from the server.

 Vakten's fingerprint is used by the server to determine what tasks this application
 will receive. The application should show a user interface with two buttons for either confirming or denying a task and
 then use the VSignTaskOperation or VCancelTaskOperation class to send the reply.

 Possible return codes are VResultCodeSuccess, VResultCodeCanceled, VResultCodeError, VResultCodeInvalidContext and
 VResultCodeNoNetworkConnection.
 */

@interface VGetTasksOperation : VOperation

/*!
 @brief Returns the tasks.

 @discussion When operation is complete returns an array of VTask objects with information about each task. See the
 documentation for the VTask class for information how to interpret the VTask properties.
 */
@property(nonatomic, readonly) NSArray *tasks;

/*!
 @brief Initializes a VGetTasksOperation.

 @discussion Unlike the other operations the VGetTasksOperation does not need a session ID.

 @param context A pointer to the VContext instance
 @param api  An NSURL to the Client API
 @param customerID A string identifying the customer the is using the Customer API

 @return An VGetTasksOperation object initialized. If the initialization fails, returns nil
 */
- (instancetype)initWithContext:(VContext *)context API:(NSURL *)api customerID:(NSString *)customerID;

/*!
 @brief Returns a task with a specific ID.

 @discussion Utility method to get a specific task given its task id. This is useful in order to show the task id that
 was received via a remote notification. How to receive remote notifications are outside the scope of this library.

 @param taskID NSString with an ID of the task to be returned

 @return The VTask with the requested taskID. If taskID does not exist or is nil, returns nil
 */
- (VTask *)taskWithID:(NSString *)taskID;

@end
