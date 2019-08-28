//
//  VaktenManager.m
//  LydsecVakten
//
//  Created by Jinfu Wang on 2016/4/22.
//  Copyright © 2016年 Jinfu Wang. All rights reserved.
//

#import "VaktenManager.h"

static VaktenManager *sharedInstance;

//static NSString *const kDefaultKAPI = @"https://118.163.101.205:16790/";
static NSString *const kCustomerID = @"agribank.com.tw";
static NSString *const kAppLable = @"AGRIBANK-APPLICATION";

#if DEBUG
//static NSString *const kDefaultKAPI = @"http://172.16.132.52/OTP";
static NSString *const kDefaultKAPI = @"http://mbapiqa.naffic.org.tw/OTP";
static NSString *const kCredentialFile =  @"agribank_dev_credential";
static NSString *const kAppConstFile = @"agribank_dev_app_const";
static NSString *const kApiKeyFile = @"1-proto5-pub";
#else
static NSString *const kDefaultKAPI = @"https://mbapi.afisc.com.tw/OTP";
static NSString *const kCredentialFile =  @"agribank_pro_credential";
static NSString *const kAppConstFile = @"agribank_pro_app_const";
static NSString *const kApiKeyFile = @"1-proto5-pub_pro";
#endif

static NSString *const kApiKeyLabel = @"1-proto5";

@implementation VaktenManager
{
    VContext *p_context;
    NSOperationQueue *p_OperationQueue;
    VAssociateOperation *p_AssociateOperation;
    VAuthenticateOperation *p_AuthenticateOperation;
    VGetTasksOperation *p_GetTasksOperation;
    VSignTaskOperation *p_SignTaskOperation;
    VCancelTaskOperation *p_CancelTaskOperation;
}

// Class methods
+ (void)initialize{
    if (self == [VaktenManager class]){
        sharedInstance = [[VaktenManager alloc] init];
    }
}

+ (instancetype)sharedInstance
{
    return sharedInstance;
}

// Instance methods
- (instancetype)init
{
    if ((self = [super init])){
        [self p_InitVContextFromFiles];
        p_OperationQueue = [[NSOperationQueue alloc] init];
        p_AssociateOperation = nil;
        p_AuthenticateOperation = nil;
        p_GetTasksOperation = nil;
        p_SignTaskOperation = nil;
        p_CancelTaskOperation = nil;
    }
    return self;
}

- (void)p_InitVContextFromFiles
{
    NSString *directoryPath = [self p_AppSupportDirectory];
    p_context = [[VContext alloc] initWithDataDirectory:directoryPath];
    [p_context setApplicationLabel:kAppLable];
    [p_context setApplicationVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    //Import the *.bin and *.der files
    NSString *credentialFilePath = [[NSBundle mainBundle] pathForResource:kCredentialFile ofType:@"bin"];
    NSString *appConstFilePath = [[NSBundle mainBundle] pathForResource:kAppConstFile ofType:@"bin"];
    NSString *apiKeyFilePath = [[NSBundle mainBundle] pathForResource:kApiKeyFile ofType:@"der"];
    NSLog(@"CredentialFilePath:%@ ,\nAppConstFilePath:%@ ,\nAPIKeyFilePath:%@", credentialFilePath, appConstFilePath, apiKeyFilePath);
    NSAssert(credentialFilePath != nil, @"credentialFilePath is nil");
    NSAssert(appConstFilePath != nil, @"appConstFilePath is nil");
    NSAssert(apiKeyFilePath != nil, @"apiKeyFilePath is nil");
    
    NSData *apiKeyData = [NSData dataWithContentsOfFile:apiKeyFilePath];
    [p_context setServerCredential:[NSData dataWithContentsOfFile:credentialFilePath] appConst:[NSData dataWithContentsOfFile:appConstFilePath]];
    [p_context setClientAPIKey:apiKeyData.bytes withSize:apiKeyData.length label:kApiKeyLabel];
}

- (void)setDeviceToken:(NSData *)deviceToken
{
    NSLog(@"IsProductionMode:%d", [self p_IsProductionMode]);
    if (deviceToken == nil) {
        NSLog(@"Push service DeviceToken is nil");
        return;
    }else{
        NSLog(@"Push service DeviceToken:%@\n HexDeviceToken:%@", deviceToken, [self p_HexStringWithData:deviceToken]);
    }
    [p_context setDeviceToken:deviceToken production:[self p_IsProductionMode]];
    [p_context addPushProvider:@"apns" withOptions:@{@"device_token": [self p_HexStringWithData:deviceToken],
                                                     @"environment": [self p_IsProductionMode] ? @"production" : @"sandbox"}];
}

- (void)associationOperationWithAssociationCode:(NSString *)associationCode complete:(CompleteHandle)handle
{
    NSURL *url = [self p_GetClientAPI];
    p_AssociateOperation = [[VAssociateOperation alloc] initWithContext:p_context API:url associationCode:associationCode];
    __weak VAssociateOperation *progressOperation = p_AssociateOperation;
    p_AssociateOperation.completionBlock = ^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            handle(progressOperation.resultCode);
        }];
    };
    [p_OperationQueue addOperation:p_AssociateOperation];
}

- (void)authenticateOperationWithSessionID:(NSString *)sessionID complete:(CompleteHandle)handle
{
    NSURL *url = [self p_GetClientAPI];
    p_AuthenticateOperation = [[VAuthenticateOperation alloc] initWithContext:p_context API:url customerID:kCustomerID sessionID:sessionID];
    __weak VAuthenticateOperation *progressOperation = p_AuthenticateOperation;
    p_AuthenticateOperation.completionBlock = ^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            handle(progressOperation.resultCode);
        }];
    };
    [p_OperationQueue addOperation:p_AuthenticateOperation];
}

- (void)getTasksOperationWithComplete:(CompleteTasksHandle)handle
{
    NSURL *url = [self p_GetClientAPI];
    p_GetTasksOperation = [[VGetTasksOperation alloc] initWithContext:p_context API:url customerID:@""];
    __weak VGetTasksOperation *progressOperation = p_GetTasksOperation;
    p_GetTasksOperation.completionBlock = ^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            handle(progressOperation.resultCode, progressOperation.tasks);
        }];
    };
    [p_OperationQueue addOperation:p_GetTasksOperation];
}

- (void)signTaskOperationWithTask:(VTask *)task complete:(CompleteHandle)handle
{
    NSURL *url = [self p_GetClientAPI];
    p_SignTaskOperation = [[VSignTaskOperation alloc] initWithContext:p_context API:url customerID:@"" task:task];
    __weak VSignTaskOperation *progressOperation = p_SignTaskOperation;
    p_SignTaskOperation.completionBlock = ^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            handle(progressOperation.resultCode);
        }];
    };
    [p_OperationQueue addOperation:p_SignTaskOperation];
}

- (void)cancelTaskOperationWithTask:(VTask *)task complete:(CompleteHandle)handle
{
    NSURL *url = [self p_GetClientAPI];
    p_CancelTaskOperation = [[VCancelTaskOperation alloc] initWithContext:p_context API:url customerID:@"" task:task];
    __weak VCancelTaskOperation *progressOperation = p_CancelTaskOperation;
    p_CancelTaskOperation.completionBlock = ^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            handle(progressOperation.resultCode);
        }];
    };
    [p_OperationQueue addOperation:p_CancelTaskOperation];
}

- (VGeoOTP*)generateGeoOTPCode
{
    NSURL *url = [self p_GetClientAPI];
    VGeoOTP *otp = [p_context getGeoOTP:url];
    return otp;
}

//- (NSString *)getOneTimePassword
//{
//    NSURL *url = [self p_GetClientAPI];
//    return [p_context getOneTimePassword:url];
//}

//- (void)nextOneTimePassword
//{
//    NSURL *url = [self p_GetClientAPI];
//    [p_context nextOneTimePassword:url];
//}

- (NSString *)p_AppSupportDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString* path = [paths objectAtIndex:0];
    NSError *error = nil;
    [NSFileManager.defaultManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    NSLog(@"AppSupportDirectory:%@",path);
    if (error) {
        return nil;
    }
    return path;
}

static char NibbleToHex(unsigned char nibble)
{
    return nibble + (nibble < 10 ? '0' : 'a' - 10);
}

- (NSString *)p_HexStringWithData:(NSData *)data
{
    unsigned char const *bytes = (unsigned char const *)data.bytes;
    NSUInteger length = data.length;
    NSMutableString *hex = [[NSMutableString alloc] initWithCapacity:length * 2];
    
    for (NSUInteger i = 0; i < length; ++i) {
        [hex appendFormat:@"%c%c", NibbleToHex(bytes[i] >> 4), NibbleToHex(bytes[i] & 0x0F)];
    }
    
    return hex;
}

- (NSURL *)p_GetClientAPI
{
    NSString *clientAPI = [NSString stringWithFormat:@"%@/api/clientapi/5",kDefaultKAPI];
    NSLog(@"Client API URL:%@",clientAPI);
    return [NSURL URLWithString:clientAPI];
}

- (NSURL *)p_GetClientAPIOfVersion3
{
    NSString *clientAPI = [NSString stringWithFormat:@"%@/api/clientapi/3",kDefaultKAPI];
    NSLog(@"Client API URL:%@",clientAPI);
    return [NSURL URLWithString:clientAPI];
}

- (BOOL)p_IsProductionMode
{
#if DEBUG
    return NO;
#else
    return YES;
#endif
}

@end
