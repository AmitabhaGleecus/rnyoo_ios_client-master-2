//
//  AppDelegate.m
//  Rynoo
//
//  Created by Rnyoo on 07/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "AppDelegate.h"
#import <GooglePlus/GooglePlus.h>
#import <FacebookSDK/FacebookSDK.h>


#import "SlideNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize isPortrait,aryHotspotSharedBO;
@synthesize imagePicked;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Register for push.
    
    RLogs(@"App Path - %@", [Util sandboxPath]);
    
    self.aryHotspotSharedBO = [[NSMutableArray alloc]init];
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    [[UITextView appearance] setTintColor:[UIColor whiteColor]];
    
    // Getting device unique identifier.
    [self holdDeviceUniqueIdentifier];
    
    if([self checkWhetherUserLoggedInAlready])
    {
        [self setMenuScreenAsRootViewController];
    }

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];


    return YES;
}

- (void)holdDeviceUniqueIdentifier
{
    UIDevice *device = [UIDevice currentDevice];
    NSUUID *deviceUid = [device identifierForVendor];
    [Util setDeviceToken:[deviceUid UUIDString]];
}

-(BOOL)checkWhetherUserLoggedInAlready
{
    BOOL isAlreadyLoggedIn;
    
    NSString *loggedinUserId = [Util getNewUserID];
    
    if( loggedinUserId != nil && loggedinUserId.length)
    {
        RLogs(@"user logged");
        isAlreadyLoggedIn = YES;
    }
    else
    {
        RLogs(@"no user logged");

        isAlreadyLoggedIn = NO;
    }
    
    return isAlreadyLoggedIn;
}

-(void)setMenuScreenAsRootViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    SlideNavigationController *nav = (SlideNavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
    self.window.rootViewController = nav;

}

-(void)setLoginScreenAsRootViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *nav = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
    self.window.rootViewController = nav;
    
}


-(void)signOut
{
    [Util setNewUserID:nil];
    [Util setScreenName:nil];
    [Util setSessionId:nil];
    [Util setEmail:nil];
    [Util setActivationCode:nil];
    [Util setGmailAccessToken:nil];
    [Util setPostId:nil];
    
    [FBSession.activeSession close];
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for(NSHTTPCookie *cookie in [storage cookies])
    {
        NSString *domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
    [self deleteAllObjectsInCoreData];
    
    [self setLoginScreenAsRootViewController];
    
    
}


// delete all entities from coredata
- (void)deleteAllObjectsInCoreData
{
    
    NSArray *allEntities = _managedObjectModel.entities;
    for (NSEntityDescription *entityDescription in allEntities)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        
        fetchRequest.includesPropertyValues = NO;
        fetchRequest.includesSubentities = NO;
        
        NSError *error;
        NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            RLogs(@"Error requesting items from Core Data: %@", [error localizedDescription]);
        }
        
        for (NSManagedObject *managedObject in items) {
            [self.managedObjectContext deleteObject:managedObject];
        }
        
        if (![self.managedObjectContext save:&error]) {
            RLogs(@"Error deleting %@ - error:%@", entityDescription, [error localizedDescription]);
        }
    }
}


#pragma mark -
#pragma mark PUSH NOTIFICATION METHODS
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    //Push registered successfully.
    int length =[deviceToken length];
    unsigned char buffer[40], token[64]="";
    int i=0, j = 0;
    if(length)
    {
        [deviceToken getBytes:buffer length:[deviceToken length]];
        j = 0;
        for(i=0; i<length; i++) {
            sprintf((char *)&token[j], "%02x",buffer[i]);
            j+=2;
        }
        
        NSString *str = [NSString stringWithFormat:@"%s", token];
        [Util setDeviceRegisterID:str];
    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // Push registration failed.
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
        
    }
    
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appIntoBG" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    [FBAppCall handleDidBecomeActive];
}


- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    
    BOOL shouldOpen = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    shouldOpen = shouldOpen ? shouldOpen : [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
        
    return shouldOpen;
  }



- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    
        //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        return UIInterfaceOrientationMaskAll;
    

}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "logictree.Rynoo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Rynoo" withExtension:@"momd"];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Rynoo" withExtension:@"momd"];

    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Rynoo.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        RLogs(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
    
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            RLogs(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
