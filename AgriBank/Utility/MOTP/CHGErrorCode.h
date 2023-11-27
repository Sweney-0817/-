//
//  CGErrorCode.h
//  MOTPPushAPI
//
//  Created by Leo on 2018/12/14.
//  Copyright © 2018年 Changing Information Inc. All rights reserved.
//

#ifndef CHGErrorCode_h
#define CHGErrorCode_h

enum ERRORCODE
{
    CG_SUCCESS                      = 0,        // Success
    CG_ERROR_GENERAL                = 25001,    // General error
    CG_ERROR_GET_DEVICE_ID_FAILED   = 25003,    // Device ID 取得失敗
    CG_ERROR_INVALID_PARAM          = 25005,    // Invalid parameters
    
    CG_ERROR_SDK_INITIAL_FAILED     = 25016,    // Component inital failed
    CG_ERROR_UNSUPPORT_MODE         = 25018,    // Unsupport Mode
    CG_ERROR_DATA_PARSE_ERROR       = 25023,    // Parse data failed
    CG_ERROR_IK_ERROR               = 25024,    // Initail key failed
    CG_ERROR_PROFILE_DUPLICATE      = 25025,    // profile duplicate
    CG_ERROR_NO_PROFILE             = 25026,     // No profile, add profile first
    
    CG_ERROR_DECRYPT_ERROR          = 25100,    // decrypt eror
    CG_ERROR_ENC_KEY_ERROR          = 25102,    // Get key failed
    
    CG_ERROR_GET_PUSH_ID_IO_FAIL    = 25402,    // Get push ID failed
    CG_ERROR_PUSH_ID_IS_CHANGED     = 25403,    // Push ID is changed
    CG_ERROR_PUSH_IS_NOT_SET        = 25404    // Push ID 沒有設定
};

#endif /* CGErrorCode_h */
