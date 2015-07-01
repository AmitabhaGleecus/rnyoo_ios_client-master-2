//
//  Util.m
//  ShowStream
//
//  Created by Rnyoo on 29/01/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "Util.h"
#import "Constants.h"
#import "UIImage+WebP.h"

static Util *objUser;

@implementation Util


+(Util*)sharedInstance
{
    if(objUser == nil)
    {
        objUser = [[Util alloc] init];
    }
    
    return objUser;
}

+(UIColor*)colorWithRed:(float)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alpha];
}

+(UIColor*)ApplicationGreenColor
{
 return [UIColor colorWithRed:46.0/255.0 green:193.0/255.0 blue:144.0/255.0 alpha:1.0];
}

+(UIFont*)Font:(FontType)type Size:(CGFloat)size
{
    switch (type) {
        case FontTypeRegular:
            return [UIFont fontWithName:@"OpenSans-Regular" size:size];

            break;
        case FontTypeLight:
            return [UIFont fontWithName:@"OpenSans-Light" size:size];

            break;
        case FontTypeHeavy:
            return [UIFont fontWithName:@"OpenSans-Heavy" size:size];

            break;
        case FontTypeBold:
            return [UIFont fontWithName:@"OpenSans-Black" size:size];

            break;
        case FontTypeSemiBold:
            return [UIFont fontWithName:@"OpenSans-SemiBold" size:size];
            
            break;
            
        case FontTypeItalic:
            return [UIFont fontWithName:@"OpenSans-Italic" size:size];
            break;

        default:
            break;
    }
}

+(UIImage*)imageWithName:(NSString*)strFileName
{
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:strFileName ofType:@"png"]];
    
    return image;
    
    
}
+(NSString*)getSettingForKey:(NSString*)setting
{
    NSString *curValue = [[NSUserDefaults standardUserDefaults] stringForKey:setting];
    
	if( curValue == nil || (NSNull*)curValue == [NSNull null] || [curValue isEqualToString:@"(null)"])
		return( @"" );
	
	return( curValue );
}

+ (void)saveSetting:(NSString *)value forKey:(NSString *)setting
{
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:setting];
	[[NSUserDefaults standardUserDefaults] synchronize];		// Force setting to be saved...
}

+(NSString*)checkForNullValue:(NSString*)strValue
{
    NSString *str = @"";
    
    if([strValue isKindOfClass:[NSNull class]])
    {
        RLogs(@"Null");
    }
    
    if((NSNull*)strValue != [NSNull null] && strValue != nil && strValue.length > 0 )
    {
        str = strValue;
    }
    return str;
}


- (id)init
{
	if( self = [super init] )
	{
		//timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
		
        
        [self checkOSVersion];
        [self checkDeviceVersion];
        
        
	}
	
	return( self );
}

-(void)checkOSVersion
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        isiOS7 = NO;
    }
    else
    {
        isiOS7 = YES;
    }
    
}

+(BOOL)isIOS8
{
    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
    {
        return NO;
    }
    else
        return YES;
    
    return NO;
}

-(void)checkDeviceVersion
{
    NSLog(@"Screen size - %@", NSStringFromCGSize([[UIScreen mainScreen] bounds].size));
    if([[UIScreen mainScreen] bounds].size.height == 568.0)
    {
        isiPhone5 = YES;

    }
    else
    {
        isiPhone5 = NO;
    }
    
}

+(void)showNoInternetMsg
{
    UIAlertView *alert_view = [[UIAlertView alloc]initWithTitle:nil message:@"Your device is not connected to internet. Please connect." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert_view show];
    alert_view = nil;
}




-(BOOL)isiPhone5
{
    return isiPhone5;
}

-(BOOL)isiOS7
{
    return isiOS7;
}

#pragma mark Registration Data


+(void)setRegistrationType:(registrationType)type
{
    [Util saveSetting:[NSString stringWithFormat:@"%d",type] forKey:@"RegistrationType"];
}

+(registrationType)getRegistrationType
{
    NSString *strRegType = [Util getSettingForKey:@"RegistrationType"];
    return [strRegType intValue];
    
}

+(void)setPassword:(NSString*)strPassword
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strPassword] forKey:@"Password"];
}

+(NSString*)getPassword
{
    NSString *strPassword = [Util getSettingForKey:@"Password"];
    return strPassword;
    
}

+(void)setUserZipCode:(NSString*)strId
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strId] forKey:@"UserZipCode"];
}

+(NSString*)getUserZipCode
{
    NSString *strUserId = [Util getSettingForKey:@"UserZipCode"];
    return strUserId;
    
}

+(void)setDeviceToken:(NSString*)strDeviceToken
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strDeviceToken] forKey:@"DeviceToken"];
}

+(NSString*)getDeviceToken
{
    NSString *strDeviceToken = [Util getSettingForKey:@"DeviceToken"];
    return strDeviceToken;
    
}

+(void)setDeviceRegisterID:(NSString*)strDeviceToken
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strDeviceToken] forKey:@"DeviceRegID"];
}

+(NSString*)getDeviceRegisterID
{
    NSString *strDeviceToken = [Util getSettingForKey:@"DeviceRegID"];
    return strDeviceToken;
    
}




static NSString *__cacheFolder=nil;
static NSString *__usersFolder=nil;
static NSString *__chatImagesFolder=nil;
static NSString *__chatThumbNailImagesFolder=nil;
static NSString *__showsFolder=nil;
static NSString *__loginUserImagePath = nil;


+ (NSString *)usersFolder
{
	if( __usersFolder == nil )
    {
		__cacheFolder = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy];
        __usersFolder = [NSString stringWithFormat:@"%@/users",__cacheFolder];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
		[fileManager createDirectoryAtPath:__usersFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
	
    return( __usersFolder );
}



+ (NSString *)showsFolder
{
	if( __showsFolder == nil )
    {
		__cacheFolder = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy];
        __showsFolder = [NSString stringWithFormat:@"%@/shows",__cacheFolder];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
		[fileManager createDirectoryAtPath:__showsFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
	
    return( __showsFolder );
}

+ (NSString *)chatImagesFolder
{
	if( __chatImagesFolder == nil )
    {
		__cacheFolder = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy];
        __chatImagesFolder = [NSString stringWithFormat:@"%@/chatImages",__cacheFolder];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
		[fileManager createDirectoryAtPath:__chatImagesFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
	
    return( __chatImagesFolder );
}

+ (NSString *)chatThumbNailImagesFolder
{
	if( __chatThumbNailImagesFolder == nil )
    {
		__cacheFolder = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy];
        __chatThumbNailImagesFolder = [NSString stringWithFormat:@"%@/chatImages/Thumbnail",__cacheFolder];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
		[fileManager createDirectoryAtPath:__chatThumbNailImagesFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
	
    return( __chatThumbNailImagesFolder );
}


+(NSString*)loginUserImagePath
{
    if( __loginUserImagePath == nil )
    {
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        __loginUserImagePath = [documentsDirectory stringByAppendingPathComponent:@""];
    }
	
    return( __loginUserImagePath );
}

+(UIColor*)appHeaderColor
{
  return [UIColor colorWithRed:241.0/255.0 green:73.0/255.0 blue:64.0/255.0 alpha:1.0];

}

+(AFHTTPRequestOperationManager *)getAppOperationRequestManager
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"RnyooiOS" forHTTPHeaderField:@"x-rnyoo-client"];
    return manager;
    

}

+(AFHTTPRequestOperationManager *)getAppPostOperationRequestManager
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];    
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"RnyooiOS" forHTTPHeaderField:@"x-rnyoo-client"];
    return manager;
    
}



+(NSString*)getOSVersion
{
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    return currSysVer;
}

// temporary

+(void)setEmail:(NSString*)strEmail
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strEmail] forKey:@"email"];
}

+(NSString*)getEmail
{
    NSString *strEmail = [Util getSettingForKey:@"email"];
    return strEmail;
}

+(void)setNewUserID:(NSString*)strUserId
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strUserId] forKey:@"NewUserId"];

}

+(NSString*)getNewUserID
{
    NSString *strUserId = [Util getSettingForKey:@"NewUserId"];
    return strUserId;
}

+(void)setActivationCode:(NSString*)strActivationCode
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strActivationCode] forKey:@"ActivationCode"];
}

+(NSString*)getActivationCode
{
    NSString *strActivationCode = [Util getSettingForKey:@"ActivationCode"];
    return strActivationCode;
}

+(void)setTermsOfUseTitle:(NSString*)strId
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strId] forKey:@"termsOfUse"];
}

+(NSString*)getTermsOfUseTitle
{
    NSString *strUserId = [Util getSettingForKey:@"termsOfUse"];
    return strUserId;
}

+(void)setImageUrl:(NSString*)strImgURL
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strImgURL] forKey:@"ImgURL"];
}

+(NSString*)getImgUrl
{
    NSString *strImgURL = [Util getSettingForKey:@"ImgURL"];
    return strImgURL;
}

+(void)setScreenName:(NSString*)strName
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strName] forKey:@"ScreenName"];
    
}

+(NSString*)getScreenName
{
    NSString *strScreenName = [Util getSettingForKey:@"ScreenName"];
    return strScreenName;
}

+(void)setSessionId:(NSString*)strsessionId
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strsessionId] forKey:@"SessionId"];
}

+(NSString*)getSessionId
{
    NSString *strSessionId = [Util getSettingForKey:@"SessionId"];
    return strSessionId;
}


+(void)setGmailAccessToken:(NSString*)strAuthToken
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strAuthToken] forKey:@"gmail_accessToken"];
}

+(NSString*)getGmailAccessToken
{
    NSString *strAuthToken = [Util getSettingForKey:@"gmail_accessToken"];
    return strAuthToken;
}

+(BOOL)checkOrCreateFolder:(NSString*)fldName{
    NSString *folderPath = [[self sandboxPath] stringByAppendingPathComponent:fldName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        return YES;
    }
    else{
        if ([[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil]){
            return YES;
        }
        else{
            return NO;
        }
    }
    return YES;
}


+(BOOL)saveImage:(UIImage*)img withName:(NSString*)ImgName inFolder:(NSString*)folderName{
    BOOL success = [self checkOrCreateFolder:folderName];
    
    if (success) {
        NSString *filePath = [self getImagePathwithImageName:ImgName inFolder:folderName];
        
        
         //Writing to local path as jpg file
         NSData *imgData = UIImageJPEGRepresentation(img, 1.0);
         
         //  NSData *imgData = [UIImage imageToWebP:img quality:75.0];
         // RLogs(@"image data is :%@",imgData);
         
         if ([imgData length] > 0 ) {
         [imgData writeToFile:filePath atomically:YES];
         return YES;
         }
        
        
        
        RLogs(@"image saved");
    }
    else{
        RLogs(@"Unable to create folder");
    }
    return NO;
}




+(BOOL)saveWebPImage:(UIImage*)img withName:(NSString*)ImgName inFolder:(NSString*)folderName{
    BOOL success = [self checkOrCreateFolder:folderName];
    
    if (success) {
        NSString *filePath = [self getImagePathwithImageName:ImgName inFolder:folderName];
    
        
    /*=============================================================
        //Writing to local path as jpg file
        NSData *imgData = UIImageJPEGRepresentation(img, 1.0);

      //  NSData *imgData = [UIImage imageToWebP:img quality:75.0];
     // RLogs(@"image data is :%@",imgData);
       
        if ([imgData length] > 0 ) {
            [imgData writeToFile:filePath atomically:YES];
            return YES;
        }
     =============================================================*/
 
        
        //Saving image in webp format
        
       return [img writeWebPToFilePath:filePath quality:50];
        
        RLogs(@"image saved");
    }
    else{
        RLogs(@"Unable to create folder");
    }
    return NO;
}

+(NSString*)sandboxPath{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    RLogs(@"sand box path is:%@",path);
//    NSURL *path = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return path;
}

+(NSString*)getImagePathwithImageName:(NSString*)imgName inFolder:(NSString*)folderName
{
     NSString *filePath = [[[self sandboxPath] stringByAppendingPathComponent:folderName]stringByAppendingPathComponent:imgName];
    return filePath;
}


// create UUID
+ (NSString *)GetUUID
{
    CFUUIDRef UUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, UUID);
    CFRelease(UUID);
    return (__bridge NSString *)string ;
}


+(void)setPostId:(NSString*)strPostId
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strPostId] forKey:@"PostId"];
}

+(NSString*)getpostId
{
    NSString *strPostId = [Util getSettingForKey:@"PostId"];
    return strPostId;
}

+(void)setPreviousUserScreenName:(NSString*)strName
{
    [Util saveSetting:[NSString stringWithFormat:@"%@",strName] forKey:@"PreviousScreenName"];
    
}

#pragma Date Converting Method

+(NSString*)dateFromInterval:(NSString*)strInterval inDateFormat:(NSString*)strDtFormat
{
    //==============================================
    
    long long milliSecs = [strInterval longLongValue];
    RLogs(@">>>Created - %lld",  milliSecs);
    
    milliSecs = milliSecs/1000;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:milliSecs];
    
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:strDtFormat];
    
    NSString   *strDate = [dateformater stringFromDate:date];
    
    return strDate;
    //==============================================

}

+(NSString*)getPreviousUserScreenName
{
    NSString *strScreenName = [Util getSettingForKey:@"PreviousScreenName"];
    return strScreenName;
}

# pragma database related




@end
