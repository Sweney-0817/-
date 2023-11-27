//
//  NSObject+CGCrypto.h
//  CGCryptoTest
//
//  Created by ChangingTec on 2014/12/11.
//
//  Version:1.1.14.1211

#import <Foundation/Foundation.h>

#define CG_RTN_SUCCESS						0		/* success */
#define CG_RTN_ERROR						5001	/* general error */
#define CG_RTN_MEMALLOC_ERROR				5002	/* Memory Allocation Error */
#define CG_RTN_FUNCTION_UNSUPPORT			5004	/* function not support */
#define CG_RTN_INVALID_PARAM				5005	/* Invalid parameter */
#define CG_RTN_LIB_EXPIRE                   5007
#define CG_RTN_BASE64_ERROR					5008	/* Base64 Encoding/Decoding Error */
#define CG_RTN_INVALID_CERT					5040	/* Incorrect Certificate format */
#define CG_RTN_INVALID_PKCS7				5042	/* Incorrect PKCS7 format */
#define CG_RTN_INVALID_KEY					5043	/* Incorrect KEY format */
#define CG_RTN_INVALID_FORMAT				5045	/* Incorrect format */
#define CG_RTN_ENCRYPT_ERROR				5063	/* Encrypt error */
#define CG_RTN_DECRYPT_ERROR				5064	/* Decrypt error */
#define CG_RTN_GENKEY_ERROR					5065
#define CG_RTN_PASSWD_INVALID				5071
#define CG_RTN_PKCS12_NO_AUTHSAFES			5091
#define CG_RTN_PKCS12_DECODE_BAG_ERROR		5092
#define CG_RTN_PKCS12_DECRYPT_ERROR			5093
#define CG_RTN_PKCS12_GETKEY_ERROR			5094
#define CG_RTN_PKCS12_GETCERT_ERROR			5095
#define CG_RTN_INVALID_STATE				5100

#define CG_FLAG_DETACHMSG                   0x00004000

#define CG_ALGOR_MD5						0x01
#define CG_ALGOR_SHA1						0x02
#define CG_ALGOR_SHA224						0x03
#define CG_ALGOR_SHA256						0x04
#define CG_ALGOR_SHA384						0x05
#define CG_ALGOR_SHA512						0x06

#define CG_ALGOR_DES						0x01
#define CG_ALGOR_3DES						0x02
#define CG_ALGOR_IDEA						0x03
#define CG_ALGOR_RC4						0x04
#define CG_ALGOR_AES_128					0x05
#define CG_ALGOR_AES_192					0x06
#define CG_ALGOR_AES_256					0x07

@interface CGCrypto : NSObject  
//objective-c方法  (未全部完成)

+ (NSInteger)GetErrorCode;
+ (NSString*)GetVersion;
+ (NSString*)GetAuthorization;
+ (NSString*)Base64Encode:(NSData*)data;
+ (NSData*)Base64Decode:(NSString*)base64Str;
+ (NSString*)Base64UrlSafeEncode:(NSData*)data;
+ (NSData*)Base64UrlSafeDecode:(NSString*)base64Str;
+ (NSData*)Hash:(NSData*)data iHashFlag:(int)iHashFlag;
+ (NSString*)CertGetSerialNumber:(NSString*)cert;
+ (NSString*)CertGetDigest:(NSString*)cert;
+ (NSString*)CertGetNotBefore:(NSString*)cert;
+ (NSString*)CertGetNotAfter:(NSString*)cert;
+ (NSString*)CertGetSubject:(NSString*)cert;
+ (NSString*)CertGetIssuer:(NSString*)cert;
+ (int)CertGetKeySize:(NSString*)cert;
+ (NSString*)CertGetSignatureAlgorithm:(NSString*)cert;
+ (NSString*)CertGetGPKITailOfCitizenID:(NSString*)cert;
+ (NSString*)Sign2:(NSData*)keyID pod:(NSString*)pod cert:(NSData*)cert data:(NSData*)data iFlags:(int)iFlags iHashFlag:(int)iHashFlag;
+ (NSString*)PureSign:(NSData*)keyID pod:(NSString*)pod data:(NSData*)data iFlags:(int)iFlags iHashFlag:(int)iHashFlag;
+ (NSData*)RSAEncrypt:(NSData*)key data:(NSData*)data isPrivateKey:(BOOL)isPrivateKey iFlags:(int)iFlags;
+ (NSData*)RSADecrypt:(NSData*)key cipher:(NSData*)cipher isPrivateKey:(BOOL)isPrivateKey iFlags:(int)iFlags;
+ (NSData*)GetPubKeyFromPriKey:(NSData*)key;
+ (NSData*)GenerateRsaKey:(int)length;
+ (NSData*)AES_CTR_Encrypt:(NSData*)key iv:(NSData*)iv_D cipher:(NSData*)plain;
+ (NSData*)AES_CTR_Decrypt:(NSData*)key iv:(NSData*)iv_D cipher:(NSData*)cipher;

@end

#ifdef __cplusplus
extern "C" {
#endif

//C語言函式

int Sign(CFDataRef keyid,CFDataRef data,int iFlags,CFDataRef *sig);
int SignEx(CFDataRef keyid,CFStringRef pod,CFDataRef data,int iFlags,int iHashFlag,CFDataRef *sig);
int Sign2(CFDataRef key,CFStringRef pod,CFDataRef b64cert,CFDataRef data,int iFlags,int iHashFlag,CFDataRef *sig);

int PureSign(CFDataRef keyid,CFStringRef pod,CFDataRef data,int iFlags,int iHashFlag,CFDataRef *p1sig);
int PureSignEx(CFDataRef prikey,CFStringRef pod,CFDataRef data,int iFlags,int iHashFlag,CFDataRef *p1sig);
int PureSign_WithoutPass(CFDataRef key,CFDataRef data,int iFlags,int iHashFlag,CFDataRef *p1sig);

int PKCS12Import(CFDataRef pfx,CFStringRef pod,int iFlags,CFDataRef *keyid);
int PKCS12ImportEx(CFDataRef pfx,CFStringRef pod,int iFlags,CFStringRef keypod,CFDataRef *keyid);
int PKCS12Import2(CFDataRef pfx,CFStringRef pod,int iFlags,CFStringRef keypod,CFDataRef *key,CFDataRef *b64cert);

int PKCS12Export(CFDataRef prikey,CFStringRef keypod,CFDataRef b64cert,CFStringRef pod,CFDataRef *pfx);

int GetCertificate(CFDataRef keyid,int iFlags,CFDataRef *cert);
int GetCertificateEx(CFDataRef keyid,CFStringRef pod,int iFlags,CFDataRef *cert);

int Base64Encode(CFDataRef data,CFDataRef *b64str);
int Base64Decode(CFDataRef b64str,CFDataRef *data);
int CertGetSerialNumber(CFDataRef cert,CFStringRef *serial);
int CertGetNotBefore(CFDataRef cert,CFStringRef *notbefore);
int CertGetNotAfter(CFDataRef cert,CFStringRef *notafter);
int CertGetSubject(CFDataRef cert,CFStringRef *subject);
int CertGetIssuer(CFDataRef cert,CFStringRef *issuer);
int CertGetKeySize(CFDataRef cert, int *keysize);
int CertGetSignatureAlgorithm(CFDataRef cert, CFStringRef *algo);
int CGCertGetGPKITailOfCitizenID(CFDataRef cert, CFStringRef *citizenID);
int Hash(CFDataRef data,int iHashFlag,CFDataRef *hash);
int GenerateRSAKey(int size,CFStringRef pod,CFDataRef *key);
int GenCSR(int size,CFStringRef pod,CFStringRef subject,int iFlags,int iHashFlag,CFDataRef *keyid,CFDataRef *retCSR);
int GenCSRWithKeyID(int size,CFStringRef pod,CFStringRef subject,int iFlags,int iHashFlag,CFDataRef *keyid,CFDataRef *retCSR);
int GenCSRWithFileKey(int size,CFStringRef pod,CFStringRef subject,int iFlags,int iHashFlag,CFDataRef *key,CFDataRef *retCSR);
int GenCSR2(CFDataRef prikey,CFStringRef pod,CFStringRef subject,int iFlags,int iHashFlag, CFDataRef *retCSR);
int CertEncrypt(CFDataRef cert,CFDataRef data,int iFlags,CFDataRef *cipher);
int CertDecrypt(CFDataRef prikey,CFStringRef pod, CFDataRef cert,CFDataRef cipher,int iFlags,CFDataRef *data);

int ChangeKeyPod(CFDataRef oldKeyID,CFStringRef oldPod,CFStringRef newPod,CFDataRef *newKeyID);

int PKCS5_PBKDF2_gen_keyiv(CFStringRef pas,CFDataRef salt,int iter,CFDataRef key,CFDataRef iv);
int aes_cbc_encrypt(CFDataRef key,CFDataRef iv,CFDataRef data,int iFlags,CFDataRef *cipher);
int aes_cbc_decrypt(CFDataRef key,CFDataRef iv,CFDataRef cipher,int iFlags,CFDataRef *data);
int publicKey_encrypt(CFDataRef pubkey,CFDataRef data,int iFlags,CFDataRef *cipher);
int privateKey_decrypt(CFDataRef prikey,CFStringRef pod,CFDataRef cipher,int iFlags,CFDataRef *clear);
int privateKey_encrypt(CFDataRef prikey,CFStringRef pod,CFDataRef cipher,int iFlags,CFDataRef *clear);
int RSAPubKeyEncrypt(CFDataRef pubkey,CFDataRef data,int iFlags,CFDataRef *cipher);
int RSAPriKeyDecrypt(CFDataRef prikey,CFDataRef cipher,int iFlags,CFDataRef *plainText);


int HashData(const void *pbData,unsigned long lData,unsigned long hashFlag,unsigned long ucpNLen,unsigned char **HashData,int *HashDataLen);
int ComposePKCS7(CFDataRef p1sig,CFDataRef cert,CFDataRef data,int iFlags,int iHashFlag, CFDataRef *sig);
int HashPadding(CFDataRef key,CFStringRef pod,CFDataRef HashData,unsigned long hashFlag, CFDataRef *PaddingData);

int SecGenCSR(int size,CFStringRef pod,int iFlags, int iHashFlag, CFDataRef *keyid,CFDataRef *retCSR);
int SecPureSign(CFDataRef prikey,CFStringRef pod,CFDataRef data,int iFlags,int iHashFlag,CFDataRef *p1sig);
int SecSign(CFDataRef key,CFStringRef pod,CFDataRef b64cert,CFDataRef data,int iFlags,int iHashFlag,CFDataRef *sig);
int SecChangeKeyPod(CFDataRef oldKeyID,CFStringRef oldPod,CFStringRef newPod,CFDataRef *newKeyID);

#ifdef __cplusplus
}
#endif

