//
//  NSString+AESCrypt.m
//
//  Created by Michael Sedlaczek, Gone Coding on 2011-02-22
//

#import "NSString+AESCrypt.h"
#import <CommonCrypto/CommonCrypto.h>

NSString *gStrIV = @"ENoEgYKYLyGOAW0lQxJ3pw=="; // 農業金庫專用
@implementation NSString (AESCrypt)

- (NSString *)AES256EncryptWithKey:(NSString *)key
{
//   NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
//   NSData *encryptedData = [plainData AES256EncryptWithKey:key];
//   NSString *encryptedString = [encryptedData base64Encoding];
//   return encryptedString;
    
//  加密模式為CBC Key:256Bit IV:123Bit
    // 1. 轉換成NSData
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    // 2. AES加密
    NSData *dataEncrypted = [self crypto:data operation:kCCEncrypt key:key iv:gStrIV];
    // 3. Base64加密
    NSString *encrypString = [dataEncrypted base64EncodedStringWithOptions:0];
   
   return encrypString;
}

- (NSString *)AES256DecryptWithKey:(NSString *)key
{
//   NSData *encryptedData = [NSData dataWithBase64EncodedString:self];
//   NSData *plainData = [encryptedData AES256DecryptWithKey:key];
//   NSString *plainString = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
//    return [plainString autorelease];
    
    // 1. Base64解密
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self options:0];
    // 2. AES解密
    NSData *dataDecrypted = [self crypto:decodedData operation:kCCDecrypt key:key iv:gStrIV];
    // 3. 轉換成String
    NSString *decryptString = [[NSString alloc] initWithData:dataDecrypted encoding:NSUTF8StringEncoding];
    
    return [decryptString autorelease];
}

- (NSString *)myAES256EncryptWithKey:(NSString *)key
{
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [plainData myAES256EncryptWithKey:key];
    NSString *encryptedString = [encryptedData base64Encoding];
    
    return encryptedString;
}

- (NSString *)myAES256DecryptWithKey:(NSString *)key
{
    NSData *encryptedData = [NSData dataWithBase64EncodedString:self];
    NSData *plainData = [encryptedData myAES256DecryptWithKey:key];
    
    NSString *plainString = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
    
    return [plainString autorelease];
}

- (NSData *)crypto:(NSData *)data operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv
{
    NSData *decodedKeyData = [[NSData alloc] initWithBase64EncodedString:key options:0];
    char keyPtr[kCCKeySizeAES256+1];
    [decodedKeyData getBytes:keyPtr length:(kCCKeySizeAES256+1)];
    
    NSData *decodedIVData = [[NSData alloc] initWithBase64EncodedString:iv options:0];
    char ivPtr[kCCBlockSizeAES128+1];
    [decodedIVData getBytes:ivPtr length:(kCCBlockSizeAES128+1)];
    
    size_t bufferSize = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    
  
    CCCryptorStatus cryptorStatus = CCCrypt(operation, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                            keyPtr, kCCKeySizeAES256,
                                            ivPtr,
                                            [data bytes], [data length],
                                            buffer, bufferSize,
                                            &numBytesEncrypted);
    
    if( cryptorStatus == kCCSuccess )
    {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }

    free(buffer);
    return nil;
}

@end
