#import <Foundation/Foundation.h>
#import <Vakten/VResultCode.h>

/*!
 @discussion This class inherits from NSOperation class in the Cocoa framework and is used together with the
 NSOperationQueue class. VOperation has a resultCode property which is used by all concrete subclasses.

 */
@interface VOperation : NSOperation

/*!
 @brief Returns the result code from the operation.

 @return The result of the operation.
 */
- (VResultCode)resultCode;

/*!
 @brief Runs the operation.

 @discussion There is no need to invoke this method directly. Use NSOperationQueue to execute the Operation. However it
 may be possible to call method directly as described in Apple's documentation. Calling this method directly will block
 until the operation is complete.
 */
- (void)main;

/*!
 @brief Cancels the operation.

 @discussion Unfortunately only a few operations when invoking Client API 3 are cancelable.
 */
- (void)cancel;

@end
