//
//  Constants.h
//  Rynoo
//
//  Created by Rnyoo on 11/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "Util.h"
#import "AppDelegate.h"

#ifndef Rynoo_Constants_h
#define Rynoo_Constants_h


#endif


#define APP_DELEGATE    ((AppDelegate *)[[UIApplication sharedApplication]delegate])


#define Rnyoo_ShowLogs 0

//== Call RLogs instead of RLogs eg: SSLogs(@"Print message");

#define RLogs( s, ... )if(Rnyoo_ShowLogs) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

//////////////////////////////////////////////////////
//#define ServerURL @"http://54.164.200.240" //old one
//#define ServerURL @"http://54.172.248.235"  //new one
//////////////////////////////////////////////////////


//#define ServerURL @"http://dev.rnyoo.ws" //old one
#define ServerURL @"http://staging.rnyoo.ws"  //new one

//#define ServerURL @"http://54.88.161.171" //iOS recent one


// New UserDetails
#define UserType @"general"
#define PlatForm @"iphone"
#define ActivatedDefault @"false"
#define DefaultTimeZone @"GMT +5:30"
#define DefaultStatusMsg @"I Rnyoo"
#define MaxHotspotCount 10


// Sandbox Contents
#define VAULT_FOLDER @"Vault"
#define CLIPBOARD_FOLDER @"Clipboard"
#define kVaultImageID @"VaultImageId"
#define kClipboardImageID @"ClipboardImageId"
#define VAULT_IMAGENAME @"VaultImg"
#define CLIPBOARD_IMAGENAME @"ClipboardImg"
#define kIntrestName @"interestName"
#define kHotspotAudioFile @"HotspotAudioFile"

// Segue names
#define PostView @"PostView"
#define ChooseContactSegue @"ChooseContact"
#define SavedHotspotsSegue @"SavedHotspots"
#define HotspotCellID @"HotspotCell"
#define ChooseContactsCellID @"ChooseContactsCell"

#define kHotspotAudioFile @"HotspotAudioFile"
#define PostInfo @"PostInfo"
#define PostDetails @"PostDetails"
#define PostDetailCellID @"PostDetailCellID"
#define PostInfoCellID @"PostInfoCellID"

#define HotspotWhiteColor 1
#define HotspotRedColor 2
#define HotspotBlueColor 3
#define HotspotYellowColor 4

#define LIGHT_GRAY [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]

#define MY_VAULT 0
#define MY_CLIPBOARD_VIEW @"My Clipboard"
#define MY_VAULT_VIEW @"My Vault"


//Images
#define HOTSPOT_WHITE_ICON @"hotspotIconwhite@2x.png"
#define HOTSPOT_RED_ICON @"hotspotIconred@2x.png"
#define HOTSPOT_BLUE_ICON @"hotspotIconblue@2x.png"
#define HOTSPOT_YELLOW_ICON @"hotspotIconyellow@2x.png"
#define UNCHECKED_IMAGE @"unchecked.png"
#define CHECKED_IMAGE @"checked.png"

#define kClientId  @"654145491281-6e99d78leus4g0dvoeuvv4769kf2mjhp.apps.googleusercontent.com";

#define DESCRIPTION_SECTION 0
#define PICTURETAKEN_SECTION 1
#define LOCATION_SECTION 2
#define CUSTOM_LOCATION 3


#define DATE_FORMAT @"dd MMM YYYY"
#define DATE_TIME_FORMAT @"dd MMM YYYY hh:mm:ss a"


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))


#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)



#define GOOGLE_PLACES_API_KEY @"AIzaSyAUElQn1JKDNs8LYFcZdIL-NlBr3_m1VYs"
#define PLACES_API_BASE  @"https://maps.googleapis.com/maps/api/place"
#define TYPE_AUTOCOMPLETE  @"/autocomplete"
#define OUT_JSON  @"/json"