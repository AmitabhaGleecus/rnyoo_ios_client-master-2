//
//  AppDelegate.h
//  Rynoo
//
//  Created by Rnyoo on 07/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Util.h"
#import "Constants.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "hotspotSharedBO.h"

@class BaseViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic, assign) BOOL isPortrait;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property(nonatomic,retain) UIImage *imagePicked;

@property(nonatomic,retain)NSMutableArray *aryHotspotSharedBO;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(BOOL)checkWhetherUserLoggedInAlready;
-(void)setMenuScreenAsRootViewController;
-(void)signOut;
-(void)setLoginScreenAsRootViewController;


@end

