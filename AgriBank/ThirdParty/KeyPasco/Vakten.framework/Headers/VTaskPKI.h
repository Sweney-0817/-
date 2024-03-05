#import <Foundation/Foundation.h>

/*!
 @discussion A task is a simple data-carrying object with the following properties. Most strings in a VTaskPKI are for
 direct presentation in a user interface. Task objects are currently
 not serializable so the application must copy the properties into some data structure if it wishes to keep them after
 the application has terminated.
 */
@interface VTaskPKI : NSObject

/*!
 @discussion A task type that can be used for selecting a custom user interface or localizing the task message.  known
 types are:

 GENERIC_TASK: This is the default task type and is not localizable. The application must show the contents of the
 VTask.message property directly to the user.

 PUSH_LOGIN: A task that asks if the user wants to login to a site. This task can be localized by ignoring the
 VTask.message property display a custom string using the VTask.user and VTask.site properties to show that a user is
 attempting to login to a site.

 If an application receives a task type which is unknown it may treat it as a GENERIC_TASK and display it non-localized.
 This means that the VTask.message always contains
 a human readable string in some unspecified language, even for known task types.
 */
@property(readonly, nonatomic) NSString *type;
/*! Unique identifier for this task. This should not be displayed to the user. */
@property(readonly, nonatomic) NSString *taskID;
/*! A URL from which a small logo can be downloaded. This would typically be the logo of the company issuing the task.
 * It is the app's responsibility to download this image. */
@property(readonly, nonatomic) NSURL *logoURL;
/*! The name of the user that has requested this task. This may be displayed in the user interface. */
@property(readonly, nonatomic) NSString *user;
/*! The name of the web site or company where the user is doing the task. If the task is a PUSH_LOGIN task then this is
 * the site to which the users is trying to log in to. This may be displayed in the user interface. */
@property(readonly, nonatomic) NSString *site;
/*! Returns the title of the task. This should be a very short string that can be displayed in the navigation bar of the
 * screen. Use the title for non-localizable tasks.   */
@property(readonly, nonatomic) NSString *title;
/*! This is a longer text message explaining what the task is about. Known task types may display a localized message
 * instead of this string.*/
@property(readonly, nonatomic) NSString *message;
/*! The date when the task was created. This can be formatted for display in the user interface so that the user know
 * when the task was issued.*/
@property(readonly, nonatomic) NSDate *timestamp;

@end
