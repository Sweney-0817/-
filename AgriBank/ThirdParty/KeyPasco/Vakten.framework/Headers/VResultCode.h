#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    
/*!
 Result codes between 1 and 99 means that the operation was successful. It is recommended to use the
 VIsSuccessful function instead of checking for specific success codes.
 */
typedef NS_ENUM(NSUInteger, VResultCode) {
    /**
     *  The operation has been canceled by the user.
     */
    VResultCodeCanceled = 0,
    /**
     *  The operation succeeded.
     */
    VResultCodeSuccess = 1,
    /**
     *  The Geo OTP was generated successfully.
     */
    VResultCodeGeoOTPSuccess = 2,
    /**
     *  The operation succeeded.
     */
    VResultCodeSuccessMax = 99,
    /**
     *  This error code is specifc for Android.
     */
    VResultCodeRequestCodeParameterError = 100,
    /**
     *  Missing or empty customer ID.
     */
    VResultCodeCustomerIDParameterError = 101,
    /**
     *  Missing or empty session ID.
     */
    VResultCodeSessionIDParameterError = 102,
    /**
     *  Missing or empty task ID.
     */
    VResultCodeTaskIDParameterError = 103,
    /**
     *  Malformed URI.
     */
    VResultCodeAPIParameterError = 104,
    /**
     *  Something went wrong.
     */
    VResultCodeError = 200,
    /**
     *  No task found for given task ID.
     */
    VResultCodeTaskNotFound = 201,
    /**
     *  Vakten has no network connection.
     */
    VResultCodeNoNetworkConnection = 202,
    /**
     *  The application or library is out of date.
     */
    VResultCodeUpgradeRequired = 203,
    /**
     *  Device not found.
     */
    VResultCodeDeviceNotFound = 204,
    /**
     *  Means that the auto adjust time setting is disabled. Not implemented on iOS.
     */
    VResultCodeAutoTimeSettingDisabled = 205,
    /**
     *  The device does not have Location Services activated or is unable to get a location from the Location Services.
     */
    VResultCodeNoLocation = 206,
    /**
     *  The device has not been initialized properly for it to be able to generate a Geo OTP.
     */
    VResultCodeGeoOTPNotInitialized = 207,
    /**
     *  An operation executed but the VContext wasn't configured properly. Verify that setClientApiKey:withSize:label: has been called with valid data.
     */
    VResultCodeInvalidContext = 208,
    /**
     *  Change pin operation failed to change the current pin to the new pin.
     */
    VResultCodeChangePinFailed = 209,
    /**
     *  Pin was invalid or pin did not match confirmination pin.
     */
    VResultCodeInvalidPin = 210,
    /**
     * Failed to verify the task. Wrong pin used too many times.
     */
    VResultCodeTaskVerificationFailed = 211,
    /**
     * Task has expired.
     */
    VResultCodeTaskExpired = 212,
    /**
     * Task has already been signed.
     */
    VResultCodeTaskAlreadySigned = 213,
		// Network Error
    /**
     * Web connect time out 10s. 
     */
    VResultCodeWebConnectTimeout = 220,
    /**
     * SSL connect time out 30s. 
     */
		VResultCodeSSLConnectTimeout = 221,
    /**
     * Handshake / Connect error 
     */
		VResultCodeConnectError = 222,
    /**
     * DNS error.
     */
		VResultCodeDNSError = 223,
    /**
     * User login failed.
     */
		VResultCodeLoginFailed = 224,
    /**
     * Socket write error.
     */
		VResultCodeSocketReadError = 225,
    /**
     * Socket write error.
     */
		VResultCodeSocketWriteError = 226,
    /**
     * Proxy Exception
     */
		VResultCodeProxyException = 230,
    /**
     * Proxy Exception: Response error.
     */
		VResultCodeProxyResponseError = 231,
    /**
     * Proxy Exception: General SOCKS server failure.
     */
		VResultCodeProxySocketServerFailed = 232,
    /**
     * Proxy Exception: Connection not allowed by ruleset.
     */
		VResultCodeProxyConnectNotAllowed = 233,
    /**
     * Proxy Exception: Network unreachable.
     */
		VResultCodeProxyNetworkUnreachable = 234,
    /**
     * Proxy Exception: Host unreachable.
     */
		VResultCodeProxyHostUnreachable = 235,
    /**
     * Proxy Exception: Connection refused.
     */
		VResultCodeProxyConnectionRefused = 236,
    /**
     * Proxy Exception: TTL expired.
     */
		VResultCodeProxyTTLExpired = 237,
    /**
     * Proxy Exception: Command not supported.
     */
		VResultCodeProxyCommandNotSupported = 238,
    /**
     * Proxy Exception: Address type not supported
     */
		VResultCodeProxyAddressNotSupported = 239,
};

/*!
 @brief Return true if a result code represents success.
 @discussion Checks if resultCode is a number between 1 and 99 which means that the operation was successful.
 
 @param resultCode  VResultCode
 @return YES if the resultCode is successful, else return NO
 */
BOOL VIsSuccessful(VResultCode resultCode);

#ifdef __cplusplus
} // extern "C"
#endif
