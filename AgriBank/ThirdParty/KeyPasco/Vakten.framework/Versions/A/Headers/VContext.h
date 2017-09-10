#include <Foundation/Foundation.h>

@class VGeoOTP;

/*!
 The Context class is the main class representing the Vakten Library.
 In order to communicate with the Vakten Library, one instance of this context class
 must be created. This context is then passed as an argument to the various operation
 classes. Each context must be initialized with an app name and an app version. See setAppName: and setAppVersion: .
 */
@interface VContext : NSObject

/*!
 @brief Initializes a VContext with an automatically selected path to a directory
 where Vakten will store its files.

 @discussion This will create a directory named 'kpco' in the application support folder which will be preserved during
 backup. If you want to specify another location you can use the initWithDataDirectory: method instead.

 @see initWithDataDirectory:

 @return VContext An initialized object. If something goes wrong, returns nil.
 */
- (instancetype)init;

/*!
 @brief Initializes a VContext with a path to a directory where Vakten will store its files.

 @discussion The directory must be in a directory preserved by a backup. The Vakten Library may create multiple files in
 this directory so it is recommended to create a
 directory dedicated to storing Vakten's files. If you are uncertain, use the init method instead.

 @see init

 @param dataDirectory String with a path to a directory.

 @return VContext An initialized object. If the dataDirectory was malformed or nil, returns nil.
 */
- (instancetype)initWithDataDirectory:(NSString *)dataDirectory;

/*!
 @brief Sets the label identifying the application using the Vakten library.

 @discussion The application label is used for two purposes.
 1. It is used together with the application version to determine if the application is too old.
 2. The server can use the application label to filter what applications can retrieve tasks for signing.
 The string can contain only alphanumeric letters and '-'.
 This method used to be called setAppName: but was renamed for consistency.

 @param label Set the application label.

 @see setApplicationVersion: for more information

 */
- (void)setApplicationLabel:(NSString *)label;

/*!
 @brief Set the version of the application running Vakten.

 @discussion Used for setting the version of the application running Vakten. Once the version
 number is set, it will be sent to the Keypasco server where it can be used for determining
 if the application version being used is too old or not.

 If the version of the application
 or the library is is out of date then the Keypasco server will return a status code indicating
 that the application needs to be updated.

    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

 @note This method used to be called setAppVersion: but was renamed for consistency.
 @note The string have no strict format except that it will be used as part of a HTTP User-Agent header. Allowed
 characters are alphanumeric characters, '+', '-', '.', '_' or '~'.

 @param version A string with the current version of the app. Allowed characters are alphanumeric characters, '+', '-',
 '.', '_' or '~'
 */
- (void)setApplicationVersion:(NSString *)version;

/*!
 @brief Sets the credential to be used with the HTTP Authorization header.

 @discussion Basic authentication is required in Vakten library in order to communicate with the Keypasco server. This
 method is used to
 set the basic authentication userid and password. Userid and password in the form of obfuscated bytes along with
 application constant
 bytes will be passed to the library. The library will convert the obfuscated bytes to plaintext and use it as basic
 authentication
 for the communication with Keypasco server.

 The process of obtaining obfuscated userid and password bytes and application constant
 bytes is described in [Generate credentials
 guide](../docs/vakten-ios-documentation-files/Generate-credentials-guide.html)

 @param credential Bytes containing obfuscated credentials as described below.
 @param appConst Application defined bytes used to un-obfuscate the credentials
 */
- (void)setServerCredential:(NSData *)credential appConst:(NSData *)appConst;

/*!
 @brief Sets the Client API public key

 @discussion
    Setting a Client API key is required before the VContext can be used to execute any Vakten operations. If no key is
 set then operations
 will fail with VResultCodeInvalidContext.

 The key and the label must both match the corresponding private key and label in the server configuration. Vakten will
 only be able to communicate
 with a server that has that key and label.

 @note See installation instructions for Borgen 2 for more information.

 @param key A void pointer to key data containing a public RSA key in DER format.
 @param keySize The number of bytes pointed to by key.
 @param label Key label that must match the key label on the server. Valid characters are are alphanumeric, '-' and '_'.

 @return YES if the format of the key and label is valid. Else, NO.
 */
- (BOOL)setClientAPIKey:(void const *)key withSize:(NSUInteger)keySize label:(NSString *)label;

/*!
 @brief Sets the device token for push.

 @discussion
    Sets the device token for receiving remote notification. This string is passed to the server so it can send remote
 notifications to this iOS device.
 This method must be used in order to get push notifications to work in Client API 3.

 @param deviceToken The device token data recieved in the AppDelegate.
 @param production A BOOL indicating whether the app is in production environment or not.

 @see addPushProvider:withOptions: addPushProvider:withOptions: for the Client API 5 alternative. If you need to be
 compatible with Both Client API 3 and 5 you must use both methods.
 */
- (void)setDeviceToken:(/*nullable*/ NSData *)deviceToken production:(BOOL)production;

/*!
 @brief Configures a push provider.

 @discussion Depending on the name argument the server will interpret the options as described in the sections below. If
 this method is called multiple times with the same value
 for name the last call will replace the previous value for that provider.

    - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData
 *)deviceToken {
        NSString *deviceTokenHex = DataToHex(deviceToken);
        #if SANDBOX
            NSString *environment = @"sandbox";
        #else
            NSString *environment = @"production";
        #endif
        [context addPushProvider:@"apns"
        withOptions:@{@"device_token": deviceTokenHex, @"environment": environment];
    }

 @see setDeviceToken:production: method must be used instead of to register for push against Client API 5. If you need
 to support Client API 3 you must invoke both methods.

 @param name Used by the server to identify the push service. "apns" and "baidu" are accepted input.
 @param options An NSDictionary containing only NSStrings that configures the push service. For Apple push Notification
 Service the key "device_token" with the device token encoded as hexadecimal as value and
 key "environment" with value set to "production" or "sandbox". For Baidu Push Service the key "user_id" with the user
 id as value, key "channel_id" with the channel id as value and key
 "environment" with value set to "production" or "sandbox".
 */
- (void)addPushProvider:(NSString *)name withOptions:(NSDictionary *)options;

/*!
 @brief Checks if this device has been associated

 @discussion
    This method can be invoked in order to verify whether Vakten has been associated. Returns YES if a
 VAssociateOperation has ever executed successfully. This method can be used to determine
 if your app should show a user guide for enabling Vakten.

 @return A BOOL indicating whether VAssociateOperation has executed successfully or not.
 */
- (BOOL)isAssociated;

/*!
 @brief Returns the current one time time password.

 @discussion
    Returns the current one time password for the currently set API. Returns nil if there is no password available. Call
 -[VContext nextOneTimePassword:] to generate the next password.
 Passwords become available after Vakten has been associated to an API using the VAssociateOperation class.

 @see nextOneTimePassword: Call nextOneTimePassword if the method returns nil.

 @note Passwords becomes available after Vakten has been associated to an API using the VAssociateOperation class.

 @param api The api with version.

 @return The current One Time Password for the currently set API. Returns nil if there is no password available
 */
- (NSString *)getOneTimePassword:(NSURL *)api;

/*!
 @brief Generates the next one time password.

 @discussion
    Generates the next password. If the OTP is not initialized then this method does nothing. Generating a new password
 should be a user initiated action and not done automatically every time the OTP view is displayed.

 @see getOneTimePassword:

 @param api The api with version.
 */
- (void)nextOneTimePassword:(NSURL *)api;

/*!
 @brief Generates an OTP based on the devices location, time and identity.

 @discussion
    Returns a VGeoOTP object that contains a resultCode indicating success or failure and the OTP itself. This method
 never returns nil (unless the app ran out of memory). The Geo OTP is based on the current time.
 In order for the Geo OTP to work as intended the system clock must be set as accurate as possible.

 @param api The api with version.
 @return A VGeoOTP object that contains a resultCode indicating success or failure and the OTP itself.
 */
- (VGeoOTP *)getGeoOTP:(NSURL *)api;

/*!
 @brief Checks if device is jailbroken.

 @discussion
    This method can be invoked in order to verify whether the device is jailbroken or not. Available in Client API 5
 (Borgen 2).

 @return YES if the device is jailbroken, else NO
 */
- (BOOL)isJailbroken;

@end
