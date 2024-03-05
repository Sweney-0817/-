#import <Foundation/Foundation.h>
#import <Vakten/VResultCode.h>

/*!

 Contains the result of generating a Geo OTP. If successful the resultCode is set to VResultCodeGeoOTPSuccess. Otherwise
 set to an error code.

 */
@interface VGeoOTP : NSObject

/*!
 The result code.

 @see VResultCode
 */
@property(readonly, nonatomic) VResultCode resultCode;

/*!
 Returns the Geo OTP string or nil if there was an error. The application should format the string in some way, by
 adding spaces to it, to make it easier to read.
 */
@property(readonly, nonatomic) NSString *otp;

@end
