//
//  E2E.m
//  AgriBank
//
//  Created by ABOT on 2020/3/4.
//  Copyright © 2020 Systex. All rights reserved.
//

#import "CGCrypto.h"
#import "E2E.h"

@implementation E2E


 
#pragma mark - public methods
+ (NSString *)E2Epod:(NSString *)key Pod:(NSString *)pd{
    int rtn = -1;
  //NSData* data = [[NSData alloc] initWithBase64EncodedData:key options:0];
  NSData* data = [key dataUsingEncoding:NSUTF8StringEncoding];
  CFDataRef keyData = (__bridge CFDataRef)data;
  NSData* pdData = [pd dataUsingEncoding:NSUTF8StringEncoding];
  //NSString *base64Encoded = [pdData base64EncodedStringWithOptions:0];
  //NSData* pd64Data = [base64Encoded dataUsingEncoding:NSUTF8StringEncoding];
    
    CFDataRef signData = (__bridge CFDataRef)pdData;
    CFDataRef rspData = NULL;
    rtn = publicKey_encrypt(keyData, signData, 0, &rspData);
    NSString *rtstr =  @"";
      if (rspData != NULL)
      {
          NSMutableData* rsData = CFBridgingRelease(rspData);
//           NSUInteger capacity = rsData.length * 2;
//           // Create a new NSMutableString with the correct lenght
//           NSMutableString *mutableString = [NSMutableString stringWithCapacity:capacity];
//           // get the bytes of data to be able to loop through it
//           const unsigned char *buf = (const unsigned char*) [rsData bytes];
//            //to HEx string
//           NSInteger t;
//           for (t=0; t<rsData.length; ++t) {
//               [mutableString appendFormat:@"%02lX", (unsigned long)buf[t]];
//           }
         NSString *mutableString = [rsData base64EncodedStringWithOptions:0];
          rtstr = mutableString;
      }
    if (rtn == CG_RTN_SUCCESS)
    {
     return  rtstr ;
    }else
    {
        return @"";
    }
}

@end
