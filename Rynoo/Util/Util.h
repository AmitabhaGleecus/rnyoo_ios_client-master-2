//
//  Util.h
//  ShowStream
//
//  Created by Rnyoo on 29/01/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "Constants.h"

typedef enum _FontType
{
    FontTypeRegular = 0,
    FontTypeLight = 1,
    FontTypeHeavy = 2,
    FontTypeBold =3,
    FontTypeSemiBold = 4,
    FontTypeItalic = 5
}FontType;

typedef enum _registrationType{
    registrationTypeGooglePlus = 0,
    registrationTypeFB = 1
} registrationType;


@interface Util : NSObject
{
    BOOL internetActive;
    BOOL isiOS7;
    BOOL isiPhone5;
}


+(Util*)sharedInstance;
+(UIColor*)colorWithRed:(float)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)alpha;
+(UIColor*)ApplicationGreenColor;
+(UIFont*)Font:(FontType)type Size:(CGFloat)size;

+(NSString*)getSettingForKey:(NSString*)setting;
+ (void)saveSetting:(NSString *)value forKey:(NSString *)setting;
+(void)setRegistrationType:(registrationType)type;
+(registrationType)getRegistrationType;


+(void)setPassword:(NSString*)strPassword;
+(NSString*)getPassword;
+(void)setUserZipCode:(NSString*)strId;
+(NSString*)getUserZipCode;
+(NSString*)checkForNullValue:(NSString*)strValue;
+(void)setDeviceToken:(NSString*)strDeviceToken;
+(NSString*)getDeviceToken;


+ (NSString *)usersFolder;
+ (NSString *)showsFolder;
+ (NSString *)chatImagesFolder;
+ (NSString *)chatThumbNailImagesFolder;
+(NSString*)loginUserImagePath;
+(UIColor*)appHeaderColor;
+(void)showNoInternetMsg;
+(UIImage*)imageWithName:(NSString*)strFileName;


+(AFHTTPRequestOperationManager *)getAppOperationRequestManager;
+(AFHTTPRequestOperationManager *)getAppPostOperationRequestManager;


-(void)checkOSVersion;
-(void)checkDeviceVersion;
-(BOOL)isiPhone5;
-(BOOL)isiOS7;
-(void)showNoInternetMsg;

+(void)setDeviceRegisterID:(NSString*)strDeviceToken;
+(NSString*)getDeviceRegisterID;

+(NSString*)getOSVersion;

+(void)setEmail:(NSString*)strEmail;
+(NSString*)getEmail;

+(void)setNewUserID:(NSString*)strUserId;
+(NSString*)getNewUserID;

+(void)setActivationCode:(NSString*)strActivationCode;
+(NSString*)getActivationCode;

+(void)setTermsOfUseTitle:(NSString*)strId;
+(NSString*)getTermsOfUseTitle;

+(void)setImageUrl:(NSString*)strImgURL;
+(NSString*)getImgUrl;

+(void)setScreenName:(NSString*)strName;
+(NSString*)getScreenName;

+(void)setSessionId:(NSString*)strsessionId;
+(NSString*)getSessionId;
+(BOOL)isIOS8;

+(NSString*)getGmailAccessToken;
+(void)setGmailAccessToken:(NSString*)strAuthToken;

+(BOOL)checkOrCreateFolder:(NSString*)fldName;
+(BOOL)saveImage:(UIImage*)img withName:(NSString*)ImgName inFolder:(NSString*)folderName;
+(BOOL)saveWebPImage:(UIImage*)img withName:(NSString*)ImgName inFolder:(NSString*)folderName;

+(NSString*)sandboxPath;
+(NSString*)getImagePathwithImageName:(NSString*)imgName inFolder:(NSString*)folderName;

    
+ (NSString *)GetUUID;

+(void)setPostId:(NSString*)strPostId;
+(NSString*)getpostId;

+(NSString*)dateFromInterval:(NSString*)strInterval inDateFormat:(NSString*)strDtFormat;

+(void)setPreviousUserScreenName:(NSString*)strName;
+(NSString*)getPreviousUserScreenName;

@end
