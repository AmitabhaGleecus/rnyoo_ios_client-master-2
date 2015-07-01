//
//  Util_HotSpot.m
//  Rnyoo
//
//  Created by Suvarna on 29/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "Util_HotSpot.h"
#import "Constants.h"
#import "Util.h"
#import "AppDelegate.h"

#define APP_DELEGATE    ((AppDelegate *)[[UIApplication sharedApplication]delegate])


@implementation Util_HotSpot
@synthesize contextHotspot,indexValue;

static Util_HotSpot *objUser;
static NSInteger indexVal;
static NSString *selectedImageId, *strPost, *strPodId;
static bool isBackGround;

+(Util_HotSpot*)sharedInstance
{
    if(objUser == nil)
    {
        objUser = [[Util_HotSpot alloc] init];
    }
    
    return objUser;
}






#pragma mark webservice calls

+(void)uploadVaultFile2
{
    [self updateSyncInitiated];
    
    
    NSManagedObject *objImg = [self getSelectedImageDataFromDB];
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];

    
    [requestSerializer setValue:@"RnyooiOS" forHTTPHeaderField:@"x-rnyoo-client"];
    
    [requestSerializer setValue:[Util getNewUserID] forHTTPHeaderField:@"x-rnyoo-uid"];
    
    [requestSerializer setValue:[Util getSessionId] forHTTPHeaderField:@"x-rnyoo-sid"];
    
    [requestSerializer setValue:[objImg valueForKey:@"imgId"] forHTTPHeaderField:@"x-rnyoo-vfid"];

    
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@/vault/files/upload", ServerURL] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:[objImg valueForKey:@"imgPath"]] name:@"vaultfile" fileName:[objImg valueForKey:@"imgName"] mimeType:@"image/webp" error:nil];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
   
    
    
    NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Response - %@ , obj - %@", response, responseObject);
            
            
            if([[responseObject valueForKey:@"file_upload"]isEqualToString:@"success"])
            {
                //We are updating vault image sync status and URl in local Db and then trying to post all the audio files of hotspots.
                
                [self updateImagedataInDBWithSyncStatus:YES withImageUrl:[responseObject valueForKey:@"vaultfile"]];
                [self uploadMediaFile];
            }

        }
    }];
    
    [uploadTask resume];
}

/* upload image to server */
+(void)uploadVaultFile
{
   
    [self updateSyncInitiated];
    
    
    NSManagedObject *objImg = [self getSelectedImageDataFromDB];
    
    RLogs(@"dict - %@", [objImg description]);
    
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:ServerURL]];
    
    [manager.requestSerializer setValue:@"RnyooiOS" forHTTPHeaderField:@"x-rnyoo-client"];
    
    [manager.requestSerializer setValue:[Util getNewUserID] forHTTPHeaderField:@"x-rnyoo-uid"];
    
    [manager.requestSerializer setValue:[Util getSessionId] forHTTPHeaderField:@"x-rnyoo-sid"];
    
    [manager.requestSerializer setValue:[objImg valueForKey:@"imgId"] forHTTPHeaderField:@"x-rnyoo-vfid"];
    
    RLogs(@"header - %@", [manager.requestSerializer.HTTPRequestHeaders description]);
    
    RLogs(@"Img Info - %@", [objImg valueForKey:@"imgPath"]);
    
        NSData *imageData = [NSData dataWithContentsOfFile:[objImg valueForKey:@"imgPath"]];
    
        if([imageData length]==0)
        {
            
            return;
        }
        if([imageData length]> 0)
        {
        AFHTTPRequestOperation *op = [manager POST:@"vault/files/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            //do not put image inside parameters dictionary as I did, but append it!
            [formData appendPartWithFileData:imageData name:@"vaultfile" fileName:[objImg valueForKey:@"imgName"] mimeType:@"image/webp"];
            
            
           // NSInputStream *stream = [NSInputStream inputStreamWithData:imageData];
            
           // [formData appendPartWithInputStream:stream name:@"vaultfile" fileName:[objImg valueForKey:@"imgName"] length:[imageData length] mimeType:@"image/webp"];
            
            
            
            
            
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject)
                                      {
                                          
                                          RLogs(@"Success: %@ ***** %@", operation.responseString, responseObject);
                                          
                                          if([[responseObject valueForKey:@"file_upload"]isEqualToString:@"success"])
                                          {
                                              //We are updating vault image sync status and URl in local Db and then trying to post all the audio files of hotspots.
                                              
                                              [self updateImagedataInDBWithSyncStatus:YES withImageUrl:[responseObject valueForKey:@"vaultfile"]];
                                              [self uploadMediaFile];
                                          }
                                          else
                                          {
                                              
                                              //if uploading vault image fails, we are just updating image id in local DB as to send another upload call with new GUID.
                                              [self updateImageDataInDBWithNewImgId];
                                              
                                              
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rnyoo"
                                                                                              message:@"Image not uploaded"
                                                                                             delegate:self
                                                                                    cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry",nil];
                                              alert.tag = 111;
                                              [alert show];
                                              return;
                                              
                                          }
                                      }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                      {
                                          RLogs(@"upload vaultError: %@ ***** %@", operation.responseString, error);
                                        
                                          // to show alert and remove loader
                                          NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
                                          [nc postNotificationName:@"PodSyncError" object:nil userInfo:(NSDictionary*)error.userInfo];
                                         
                                      }];
        [op start];
        
        }
  
}


+(void)uploadMediaFile
{
    //Posting audio files of hotspots recursively in sequence manner.
    
    
    NSArray *arrHotspotsData = [self getHotspotDatafromDB];
    
    if(![arrHotspotsData count])
        return;
    
    NSString *strAudioFileUrl = [[arrHotspotsData objectAtIndex:[self indexValue]] valueForKey:@"audioFileUrl"];
    
    if(strAudioFileUrl.length > 0)
    {
        RLogs(@"Already existing Audio URL - %@", strAudioFileUrl);
        //If already having the audio URL...
        [self incrementIndex];
        
        
        if([self indexValue] == [arrHotspotsData count])
        {
            //Here all the audio file upload completed, then navigating to the assigning hotspots to user's friends screen.
            [self SendReqToCreateNewPod];
        }
        else
        {
            //making recursive call over same method to upload audio files.
            [self uploadMediaFile];
        }
        
        return;

    }


    
    NSString *strAudioFilePath = [[arrHotspotsData objectAtIndex:[self indexValue]] valueForKey:@"audioFilePath"];
    
    NSLog(@">>>audioFilePath - %@, index - %li", strAudioFilePath, (long)indexVal);
    
    if( [arrHotspotsData count] && [strAudioFilePath length] > 0)
    {
        RLogs(@"audiourlPath:%@",[[arrHotspotsData objectAtIndex:[self indexValue]] valueForKey:@"audioFilePath"]);
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:ServerURL]];
        
        [manager.requestSerializer setValue:@"RnyooiOS" forHTTPHeaderField:@"x-rnyoo-client"];
        
        [manager.requestSerializer setValue:[Util getNewUserID] forHTTPHeaderField:@"x-rnyoo-uid"];
        
        [manager.requestSerializer setValue:[Util getSessionId] forHTTPHeaderField:@"x-rnyoo-sid"];
        
        [manager.requestSerializer setValue:[[arrHotspotsData objectAtIndex:[self indexValue]] valueForKey:@"audioId"] forHTTPHeaderField:@"x-rnyoo-vfid"];
        
        RLogs(@"header - %@", [manager.requestSerializer.HTTPRequestHeaders description]);
        
        NSData *audioData = [NSData dataWithContentsOfFile:strAudioFilePath];
        
        if(audioData == nil)
        {
            RLogs(@"audioData is nil");
            
            if([[NSFileManager defaultManager] fileExistsAtPath:strAudioFilePath])
            {
                RLogs(@"But file existing at path");
            }else
            {
                RLogs(@"Because file doesnot exist");
            }
        }
        
        AFHTTPRequestOperation *op = [manager POST:@"vault/files/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                      {
                                          //do not put image inside parameters dictionary as I did, but append it!
                                          [formData appendPartWithFileData:audioData name:@" vaultfile" fileName:[[arrHotspotsData objectAtIndex:[self indexValue] ] valueForKey:@"audioFileName"] mimeType:@"audio/m4a"];
                                      } success:^(AFHTTPRequestOperation *operation, id responseObject)
                                      {
                                          
                                          RLogs(@"Success: %@ ***** %@", operation.responseString, responseObject);
                                          
                                        //  [self updateHotspotObject:[arrHotspotsData objectAtIndex:[self indexValue]] withURL:[responseObject valueForKey:@"vaultfile"]];
                                          NSLog(@">>audioUrl - %@", [responseObject valueForKey:@"vaultfile"]);
                                          [[arrHotspotsData objectAtIndex:[self indexValue]] setValue:[responseObject valueForKey:@"vaultfile"] forKey:@"audioFileUrl"];
                                        
                                          
                                          //index++;
                                          [self incrementIndex];
                                         
                                          
                                          if([self indexValue] == [arrHotspotsData count])
                                          {
                                              NSLog(@">>Index equal to count");
                                              NSError *error= nil;
                                              if (![[self getContext] save:&error])
                                              {
                                                  RLogs(@"Problem saving: %@", [error localizedDescription]);
                                              }

                                              //Here all the audio file upload completed, then navigating to the assigning hotspots to user's friends screen.
                                              [self SendReqToCreateNewPod];
                                          }
                                          else
                                          {
                                              //making recursive call over same method to upload audio files.
                                              [self uploadMediaFile];
                                          }
                                          
                                      }
                                      
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                      {
                                          /*[self removeLoader];
                                           RLogs(@"Error: %@ ***** %@", operation.responseString, error);
                                           [self showTheAlert:error.description];*/
                                       
                                          [self incrementIndex];
                                       //   index++;
                                          if([self indexValue] == [arrHotspotsData count])
                                          {
                                              //Here all the audio file upload completed, then navigating to the assigning hotspots to user's friends screen.
                                              [self SendReqToCreateNewPod];
                                          }
                                          else
                                          {
                                              //making recursive call over same method to upload audio files.
                                              [self uploadMediaFile];
                                          }
                                          
                                          
                                      }];
        
        [op start];
        
        
        
    }
    else
    {
        //if there is no audio for a particular hotspot, control comes here and try to upload the audio of further hotspots in the array.
//        index++;
        
        [self incrementIndex];
        if([self indexValue] == [arrHotspotsData count])
        {
            
            [self SendReqToCreateNewPod];
        }
        else
            [self uploadMediaFile];
        
    }
    
}

#pragma mark DB methods


+(NSManagedObjectContext*)getContext
{
    return [APP_DELEGATE managedObjectContext];
}



+(NSMutableDictionary*)prepareDictForImage
{
    NSMutableDictionary *dictImage = [[NSMutableDictionary alloc]init];
    
    NSManagedObject *objImage = [self getSelectedImageDataFromDB];
    
    [dictImage setValue:[objImage valueForKey:@"imgId"] forKey:@"imgId"];
    
    [dictImage setValue:[objImage valueForKey:@"imgUrl"] forKey:@"baseUrl"];
    
    [dictImage setValue:@"gallery" forKey:@"source"];
    [dictImage setValue:@"image/webp" forKey:@"mimeType"];
    
    return dictImage;
    
}

#pragma mark get user,hotspot ,image, pod and Post data from DB
// get image data based on imageid
+(NSManagedObject*)getImageDataFromDBOfImgId:(NSString*)strImgId
{
    //   contextHotspot = [APP_DELEGATE managedObjectContext];
    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:[self getContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@",strImgId];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
    return nil;
}
// get hotspot data based on imageid
+(NSArray*)getHotspotDataFromDBOfImgId:(NSString*)strImgId withPodId:(NSString*)strPodId
{
    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Hotspot" inManagedObjectContext:[self getContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ && podId == %@",strImgId, strPodId];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
        return fetchedObjects;
    else
        return nil;
    return nil;
}

+(NSArray*)getHotspotsOfHSIds:(NSArray*)arrHSIds
{
    for(NSString *strHid in arrHSIds)
    {
        RLogs(@"Hotspto Id - %@", strHid);
    }

    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Hotspot" inManagedObjectContext:[self getContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hId IN %@",arrHSIds];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
        return fetchedObjects;
    else
        return nil;
    return nil;

}
// get post data based on postid

+(NSManagedObject*)getPostDataFromDBwithPostId:(NSString*)strPostId
{
    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:[self getContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId == %@",strPostId];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
    return nil;
}

// get hotspot shared data based on postid

+(NSArray*)getHotspotsSharedDataFromDBwithPostId:(NSString*)strPostId
{
    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"HotspotShareInfo" inManagedObjectContext:[self getContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId == %@",strPostId];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
        return fetchedObjects;
    else
        return nil;
    return nil;
}

+(NSArray*)getHotspotsSharedDataFromDBwithHsId:(NSString*)strHsId andUserId:(NSString*)strUserId andPostId:(NSString*)strPostId
{
    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"HotspotShareInfo" inManagedObjectContext:[self getContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId == %@ && hotSpotId == %@ && userId == %@",strPostId, strHsId, strUserId];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
        return fetchedObjects;
    else
        return nil;
    return nil;
}

// get user data based on userid

+(NSManagedObject*)getUserDataFromDB
{
    
    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:[self getContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@",[Util getNewUserID]];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
    return nil;
}

// get selected image data based on imageid

+(NSManagedObject*)getSelectedImageDataFromDB
{
    //   contextHotspot = [APP_DELEGATE managedObjectContext];
    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:[self getContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@",selectedImageId];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
    return nil;
}

+(NSManagedObject*)getImageDataFromDBWithImgId:(NSString*)strImgId
{
    //   contextHotspot = [APP_DELEGATE managedObjectContext];
    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:[self getContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@",strImgId];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
    return nil;
}


// getting pod data from database

+(NSManagedObject*)getPodDataFromDBOfPodId:(NSString*)strPodId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Pod" inManagedObjectContext:[self getContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ && pid == %@",selectedImageId, strPodId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    
    if([fetchedObjects count])
    return [fetchedObjects objectAtIndex:0];
    else
        return nil;
    
}

+(NSManagedObject*)getPodDataFromDBOfPodId:(NSString*)strPodId andImageId:(NSString*)strImgId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Pod" inManagedObjectContext:[self getContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ && pid == %@",strImgId, strPodId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    
    if([fetchedObjects count])
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
    
}

// getting pod data from database

+(NSManagedObject*)getPodDataFromDBOfImgId:(NSString*)strImgId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Pod" inManagedObjectContext:[self getContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@",strImgId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    
    if([fetchedObjects count])
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
    
}

+(NSString*)getRecentPodIdFromDBOfImgId:(NSString*)strImgId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Pod" inManagedObjectContext:[self getContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@",strImgId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    
    if([fetchedObjects count])
        return [[fetchedObjects lastObject] valueForKey:@"pid"];
    else
        return nil;
    
}

+(NSString*)getNotPostedPodIdOfImgId:(NSString*)strImgId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Pod" inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
   // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ && draft == %@ && published == %@",strImgId, [[NSNumber numberWithBool:YES] stringValue], [[NSNumber numberWithBool:NO] stringValue]];
    
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@",strImgId];

    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[APP_DELEGATE managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    
    if([fetchedObjects count])
    {
        NSManagedObject *obj = [fetchedObjects objectAtIndex:0];
        return [obj valueForKey:@"pid"];
    }
    else
        return @"";
    
}

+(NSArray*)getQuestionsDatafromDB:(NSString*)strPostId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Questions" inManagedObjectContext:[self getContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId == %@",strPostId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    if([fetchedObjects count])
    {
        RLogs(@"question data:%@",fetchedObjects);
        return fetchedObjects;
    }
    return nil;
    
}

+(NSManagedObject*)getQuestionsDatafromDB:(NSString*)strPostId questionId:(NSString*)strQuestionId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Questions" inManagedObjectContext:[self getContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId == %@ && questionId == %@",strPostId,strQuestionId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
  
    if([fetchedObjects count])
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
}

+(NSArray*)getCommentDatafromDB:(NSString*)strPostId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:[self getContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId == %@",strPostId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    if([fetchedObjects count])
    {
        RLogs(@"comment data:%@",fetchedObjects);
        return fetchedObjects;
    }
    return nil;
}

+(NSArray*)getHotspotCommentsDatawithHotspotId:(NSString*)strHotspotId podId:(NSString*)strPodId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"HotspotComments" inManagedObjectContext:[self getContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hotspotId == %@ && podId == %@",strHotspotId,strPodId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    if([fetchedObjects count])
    {
        RLogs(@"comment data:%@",fetchedObjects);
        return fetchedObjects;
    }
    return nil;
}


+(NSArray*)getHotspotCommentsDatawithPostId:(NSString*)strPostId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"HotspotComments" inManagedObjectContext:[self getContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId == %@ ",strPostId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    if([fetchedObjects count])
    {
        RLogs(@"comment data:%@",fetchedObjects);
        return fetchedObjects;
    }
    return nil;
}

+(void)deleteSharedHotspotOfId:(NSString*)strHsId ofPost:(NSString*)strPostId
{
    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"HotspotShareInfo" inManagedObjectContext:[self getContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId == %@ && hotSpotId == %@",strPostId, strHsId];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    for(NSManagedObject *objRecord in fetchedObjects)
    {
        [[self getContext] deleteObject:objRecord];
    }
    
    if (![[self getContext] save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }

}

+(void)deleteHotspotOfId:(NSString*)strHsId
{
    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Hotspot" inManagedObjectContext:[self getContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hId == %@ ", strHsId];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    for(NSManagedObject *objRecord in fetchedObjects)
    {
        [[self getContext] deleteObject:objRecord];
    }
    
    if (![[self getContext] save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
    
}


#pragma mark Hotspot Shared Info DB methods
+(NSArray*)getHotspotsOfPostId:(NSString*)strPostId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"HotspotShareInfo" inManagedObjectContext:[self getContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId == %@",strPostId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    fetchRequest.propertiesToFetch = [NSArray arrayWithObject:[[entityDesc propertiesByName] objectForKey:@"hotSpotId"]];
    fetchRequest.returnsDistinctResults = YES;
    fetchRequest.resultType = NSDictionaryResultType;

    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    RLogs(@"all hotspots array:%@",fetchedObjects);
    fetchRequest = nil;

    if([fetchedObjects count])
    {
        NSMutableArray *arrHtSpt = [[NSMutableArray alloc] init];
        
    for(NSDictionary *dictHs in fetchedObjects)
    {
        [arrHtSpt addObject:[dictHs valueForKey:@"hotSpotId"]];
        RLogs(@"Hotspot id : %@", [dictHs valueForKey:@"hotSpotId"]);
    }
        if([arrHtSpt count])
        {
            NSArray *arrHs =  [self getHotspotsOfHSIds:arrHtSpt];
            return arrHs;
        }

    }
    
    
    
    return nil;
    
    
    
    
}



# pragma  mark webservice call to create new pod

+(NSMutableArray*)prepareDictForHotspots
{
    NSArray *arrHotspotsData = [self getHotspotDatafromDB];
    NSMutableArray *aryHotspots = [[NSMutableArray alloc]init];
    
    
    for(NSManagedObject *objHotspot in arrHotspotsData)
    {
        NSMutableDictionary *dictHotspot = [[NSMutableDictionary alloc]init];
        
        [dictHotspot setValue:[objHotspot valueForKey:@"hId"] forKey:@"hotspotId"];
        
        [dictHotspot setValue:[objHotspot valueForKey:@"strLabel"] forKey:@"hotspotLabel"];
        
        [dictHotspot setValue:[objHotspot valueForKey:@"strDescription"] forKey:@"hotspotDescription"];

        [dictHotspot setValue:[objHotspot valueForKey:@"zoomFactor"] forKey:@"zoomFactor"];

        NSMutableDictionary *dictLocation = [[NSMutableDictionary alloc]init];
        
        [dictLocation setValue:[objHotspot valueForKey:@"xCoordinate"] forKey:@"x"];
        
        [dictLocation setValue:[objHotspot valueForKey:@"yCoordinate"] forKey:@"y"];
        
        [dictHotspot setValue:dictLocation forKey:@"location"];
        
        [dictHotspot setValue:@"dot" forKey:@"locationMarker"];

        [dictHotspot setValue:@"default.png" forKey:@"markerIcon"];
        
        [dictHotspot setValue:@"" forKey:@"keywords"];
        
        NSString *strColor = @"white";
        
        if([objHotspot valueForKey:@"hotspotColor"] != nil && [[objHotspot valueForKey:@"hotspotColor"] length] > 0)
            strColor = [[objHotspot valueForKey:@"hotspotColor"] lowercaseString];
        
        [dictHotspot setValue:strColor forKey:@"markerColor"];

        

        NSMutableDictionary *dictAudio = [[NSMutableDictionary alloc]init];
        
        if([[objHotspot valueForKey:@"audioFilePath"] length] >0)
        {
            
            [dictAudio setValue:[objHotspot valueForKey:@"audioId"] forKey:@"audioId"];
            [dictAudio setValue:[objHotspot valueForKey:@"audioFileUrl"] forKey:@"audioUrl"];
        }
        else
        {
            [dictAudio setValue:@"" forKey:@"audioId"];
            [dictAudio setValue:@"" forKey:@"audioUrl"];
        }
        
        [dictHotspot setValue:dictAudio forKey:@"media"];
        
        [dictHotspot setValue:[NSNumber numberWithBool:YES] forKey:@"sharable"];
        [dictHotspot setValue:[NSNumber numberWithBool:NO] forKey:@"editable"];
        
        [dictHotspot setValue:[objHotspot valueForKey:@"url"] forKey:@"clickUrl"];
                
        [aryHotspots addObject:dictHotspot];
        
        NSLog(@">>>>HSDict - %@", dictHotspot.description);
        
    }
    
    return aryHotspots;
}
/* prepare input for pod*/

+(NSMutableDictionary*)prepareDictForPod
{
    
    NSManagedObject *objManagedObjPod = [self getPodDataFromDBOfPodId:strPodId];
    
    RLogs(@"published - %@", [objManagedObjPod valueForKey:@"published"]);
    
    NSMutableDictionary *dictPod = [[NSMutableDictionary alloc]init];
    
    [dictPod setValue:strPodId forKey:@"name_s"];
    
    [dictPod setValue:strPodId forKey:@"rpid_s"];
    
    [dictPod setValue:[objManagedObjPod valueForKey:@"descriptionPod"] forKey:@"description_s"];
    
    [dictPod setValue:[objManagedObjPod valueForKey:@"draft"] forKey:@"draft"];
    
    //Here in DB we are updating 'Published'flag after posting. But for post detail from server we are getting this same flag. That is why we are sending it as '1'.
    
    [dictPod setValue:[NSNumber numberWithBool:YES] forKey:@"published_s"];
    
    [dictPod setValue:[objManagedObjPod valueForKey:@"parentId"] forKey:@"parentId"];
    
    [dictPod setValue:[Util getNewUserID] forKey:@"createdBy_s"];
    
    [dictPod setValue:[Util getDeviceToken] forKey:@"deviceId_s"];
    
    [dictPod setValue:[NSNumber numberWithInteger:1] forKey:@"zoomScale"];
    
    if([[objManagedObjPod valueForKey:@"orientation"] isEqualToString:@"portrait"])
    {
        [dictPod setValue:@"0" forKey:@"orientation"];
    }
    else
    {
        [dictPod setValue:@"1" forKey:@"orientation"];

    }
//    [dictPod setValue:[objManagedObjPod valueForKey:@"orientation"] forKey:@"orientation"];
    
   NSMutableArray *aryCurrentLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLocation"];
    
    RLogs(@"currentlocation:%@",aryCurrentLocation);
    NSMutableDictionary *dictCoordinates = [[NSMutableDictionary alloc]init];

    if([aryCurrentLocation count])
    {
        [dictPod setValue:[aryCurrentLocation valueForKey:@"location"] forKey:@"location"];
        
        [dictCoordinates setValue:[aryCurrentLocation valueForKey:@"latitude"] forKey:@"lat"];
        [dictCoordinates setValue:[aryCurrentLocation valueForKey:@"longitude"] forKey:@"lon"];
    }
    else
    {
        [dictPod setValue:@"" forKey:@"location"];
        
        [dictCoordinates setValue:@"" forKey:@"lat"];
        [dictCoordinates setValue:@"" forKey:@"lon"];
    }
    
    [dictPod setValue:dictCoordinates forKey:@"locationCoordinates"];
    
    [dictPod setValue:[objManagedObjPod valueForKey:@"ownership"] forKey:@"ownership_s"];
    
    [dictPod setValue:@"" forKey:@"keywords_s"];
    
    NSMutableDictionary *dictImage = [self prepareDictForImage];
    
    [dictPod setValue:dictImage forKey:@"podImage"];
    
    NSMutableArray *aryHotspots = [self prepareDictForHotspots];
    
    
    [dictPod setValue:aryHotspots forKey:@"hotspots"];
    
    return dictPod;
}


+(void)SendReqToCreateNewPod
{
    
    NSMutableDictionary *dictPod = [[NSMutableDictionary alloc]init];
    
    [dictPod setValue:[Util getNewUserID] forKey:@"uid"];
    
    [dictPod setValue:[Util getSessionId] forKey:@"sid"];
    
    
    NSMutableDictionary *dict = [self prepareDictForPod];
    
    
    [dictPod setValue:dict forKey:@"pod"];
    
    NSString *strUrl = @"";
    if([strPost isEqualToString:@"post"])
    {
        //we are creating new pod...
        RLogs(@"####Creating new pod");
        strUrl = [NSString stringWithFormat:@"%@/pods/new",ServerURL];
    }
    else
    {
        //we are updating exisitng pod....
        RLogs(@"####Updating existing pod");

        strUrl = [NSString stringWithFormat:@"%@/pods/update",ServerURL];

    }
   // strUrl = [NSString stringWithFormat:@"%@/pods/new",ServerURL];

    
    RLogs(@"DICT POD - %@", dictPod.description);
    
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:strUrl parameters:dictPod success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"pod new response:%@",responseObject);
         NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
         [nc postNotificationName:@"PodData" object:nil userInfo:dictPod];
         

         if([[responseObject valueForKey:@"status"] isEqualToString:@"success"])
         {
             [self updateHotspotDatawithPodId:[responseObject valueForKey:@"rpid"]];
             
             [self updatePodDatawithPodId:[responseObject valueForKey:@"rpid"]];

            if([self getBackGround] == YES)
            {
                RLogs(@"Succesfully uploaded in background");
                
            }
             else
             {
                 NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
                 [nc postNotificationName:@"PodSyncSuccess" object:nil userInfo:(NSDictionary*)responseObject];
             }
             
             
         }
         else
         {
             if([self getBackGround] == YES)
             {
                 RLogs(@"Succesfully uploaded in background");
             }
             else
             {
                 NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
                 [nc postNotificationName:@"PodSyncSuccess" object:nil userInfo:(NSDictionary*)responseObject];
             }
         }
         
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"new pod Error: %@", error);
              NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
              [nc postNotificationName:@"PodSyncError" object:nil userInfo:(NSDictionary*)error.userInfo];
              
          }];
    
    
    
}

#pragma update Image data and Hotspot data
+(void)updateSyncInitiated
{
    NSManagedObject *objImage = [self getSelectedImageDataFromDB];
    
    [objImage setValue:[NSNumber numberWithBool:YES] forKey:@"syncInitiated"];
    
    NSError *error= nil;
    if (![[self getContext] save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
    
}

+(void)updateImagedataInDBWithSyncStatus:(BOOL)syncStatus withImageUrl:(NSString*)imgUrl
{
    NSManagedObject *objImage = [self getSelectedImageDataFromDB];
    
    if(syncStatus == YES)
    {
        [objImage setValue:[NSNumber numberWithBool:YES] forKey:@"syncStatus"];
        [objImage setValue:imgUrl forKey:@"imgUrl"];
        
    }
    else
    {
        [objImage setValue:[NSNumber numberWithBool:NO] forKey:@"syncStatus"];
        [objImage setValue:@"" forKey:@"imgUrl"];
        
    }
    
    NSError *error= nil;
    if (![[self getContext] save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
    
    
}

+(void)updateImageDataInDBWithNewImgId
{
    NSManagedObject *objImage = [self getSelectedImageDataFromDB];
    
    selectedImageId = [Util GetUUID];
    
    [objImage setValue:selectedImageId forKey:@"imgId"];
    
    NSError *error= nil;
    if (![[self getContext] save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
    
}

+(void)updateHotspotObject:(NSManagedObject*)objHotspot withURL:(NSString*)strAudioUrl
{
    
    NSLog(@">>>>Updated URL - %@", strAudioUrl);
    [objHotspot setValue:strAudioUrl forKey:@"audioFileUrl"];
    NSError *error= nil;
    if (![[self getContext] save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
    
}



+(void)updateHotspotDatawithPodId:(NSString*)pid
{
    
    NSArray *aryHotspotData = [self getHotspotDatafromDB];

    for(NSManagedObject *objHotspot in aryHotspotData)
    {
        RLogs(@"hotspotDatabefore:%@",[objHotspot valueForKey:@"podId"]);

        [objHotspot setValue:pid forKey:@"podId"];
        
        NSError *error= nil;
        if (![[self getContext] save:&error])
        {
            RLogs(@"Problem saving: %@", [error localizedDescription]);
        }
    }
    
}

+(void)updatePodDatawithPodId:(NSString *)pid
{
    NSManagedObject *objPod = [self getPodDataFromDBOfPodId:strPodId];
    
    [objPod setValue:pid forKey:@"pid"];
    
    NSError *error= nil;
    if (![[self getContext] save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }

}

# pragma mark  get Hotspot data from DB

// get hotspots data from DB based on imgid
+(NSArray*)getHotspotDatafromDB
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Hotspot" inManagedObjectContext:[self getContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ && podId == %@",selectedImageId, strPodId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[self getContext] executeFetchRequest:fetchRequest error:&error];
    
    RLogs(@"all hotspots array:%@",fetchedObjects);
  
    if([fetchedObjects count])
        return fetchedObjects;
    
    return nil;
    
}

+(void)setIndexValue:(NSInteger)index
{
    indexVal = index;
}

+(NSInteger)indexValue
{
    return indexVal;
}

+(NSInteger)incrementIndex
{
    return indexVal++;
}

+(void)setSelectedImageId:(NSString*)selImageId
{
    RLogs(@">>>>>>>>selectedImageId - %@", selectedImageId);
    RLogs(@">>>>>>>>selImageId - %@", selImageId);

    selectedImageId = selImageId;
    RLogs(@">>>>>>>>selectedImageId1 - %@", selectedImageId);

}

+(void)setPodId:(NSString*)podId
{
    strPodId = podId;
    RLogs(@">>>>>>PodId - %@", strPodId);

}

+(void)setAboutPost:(NSString*)strpost
{
    RLogs(@">>>>>>>>selectedImageId - %@", selectedImageId);
    
    strPost = strpost;
    RLogs(@">>>>>>>>selectedImageId1 - %@", selectedImageId);
    
}

+(void)setBackGround:(BOOL)isSuccess
{
    isBackGround = isSuccess;
}

+(BOOL)getBackGround
{
    return isBackGround;
}


#pragma mark save image,Pod data in DB

+(void)saveImageData:(postBO*)objPost
{
    
    if([self getImageDataFromDBOfImgId:objPost.strImgid] != nil)
    {
        RLogs(@"Image Existing in Db");
        return;
    }
    
    NSManagedObject *objImage= [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:[self getContext]];
    
    [objImage setValue:objPost.strImgid forKey:@"imgId"];
    
    [objImage setValue:objPost.strImgLocalPath forKey:@"imgPath"];
   
    RLogs(@"imagePath:%@",objPost.strImgLocalPath);

    [objImage setValue:[objPost.strImgLocalPath lastPathComponent] forKey:@"imgName"];
    
    [objImage setValue:[NSNumber numberWithBool:YES] forKey:@"syncInitiated"];
    
    [objImage setValue:[NSNumber numberWithBool:YES] forKey:@"syncStatus"];
   
    [objImage setValue:objPost.strImgUrl forKey:@"imgUrl"];
    
    [objImage setValue:objPost.createdAt forKey:@"imageCreatedTime"];
    
    NSError *error= nil;
    if (![[self getContext] save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
}

+(void)savePodData:(postBO*)objPost
{
    if([self getPodDataFromDBOfPodId:objPost.strPodId andImageId:objPost.strImgid] != nil)
    {
        RLogs(@"Pod Existing in Db");
        return;
    }

    
    NSManagedObject *managedObjPod= [NSEntityDescription insertNewObjectForEntityForName:@"Pod" inManagedObjectContext:[self getContext]];
    
    [managedObjPod setValue:objPost.strPodId forKey:@"pid"];
    
    [managedObjPod setValue:objPost.strImgid forKey:@"imgId"];
    
    [managedObjPod setValue:[NSNumber numberWithBool:NO] forKey:@"draft"];
    
    [managedObjPod setValue:[NSNumber numberWithBool:YES] forKey:@"published"];
    
    if(APP_DELEGATE.isPortrait)
    {
        [managedObjPod setValue:@"portrait" forKey:@"orientation"];
    }
    else
        [managedObjPod setValue:@"landscape" forKey:@"orientation"];
    
    [managedObjPod setValue:@"locked" forKey:@"ownership"];
    
    [managedObjPod setValue:@"" forKey:@"parentId"];
    
    [managedObjPod setValue:[NSNumber numberWithInteger:1] forKey:@"zoomscale"];
    
    [managedObjPod setValue:@"" forKey:@"latitude"];
   
    [managedObjPod setValue:@"" forKey:@"longitude"];
    
    [managedObjPod setValue:objPost.strPictureTakenLocation forKey:@"location"];
    
    [managedObjPod setValue:objPost.strPostTitle forKey:@"title"];
    
    [managedObjPod setValue:@"" forKey:@"descriptionPod"];
    
    [managedObjPod setValue:objPost.createdAt forKey:@"createdAt"];

    
    NSError *error= nil;
    if (![[self getContext] save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
    
}

+(void)saveHotspotData:(postBO*)objPost
{
    
       NSArray *arrHotSpotInfo = objPost.arrHotspots;
       
       RLogs(@"hotspots:%@",objPost.arrHotspots);

   
    if(![arrHotSpotInfo count])
        return;
    
    if([[arrHotSpotInfo objectAtIndex:0] isKindOfClass:[NSDictionary class]])
    {
        RLogs(@"image id:%@",objPost.strImgid);
        
    }
    
    //===================================================
    
    //checking Hs data existing in DB or not
    NSMutableArray *arrHs = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dictHs in arrHotSpotInfo)
    {
        [arrHs addObject:[dictHs valueForKey:@"hotspotId"]];
    }
    
    NSArray *arrHotspots = [self getHotspotsOfHSIds:arrHs];
    
    //======================================================
    
    if([[arrHotSpotInfo objectAtIndex:0] isKindOfClass:[NSDictionary class]])
    {
        for(NSMutableDictionary *hotspotInfo in arrHotSpotInfo)
        {
            BOOL isHsAlreadyExisting = NO;
            
            for(NSManagedObject *objHs in arrHotspots)
            {
                if([[hotspotInfo valueForKey:@"hotspotId"] isEqualToString:[objHs valueForKey:@"hId"]])
                {
                    isHsAlreadyExisting = YES;
                    break;
                }
            }
            
            if(isHsAlreadyExisting)
                continue;
            
            RLogs(@"\/\/hotspotInfo - %@", [hotspotInfo description]);
            
            NSMutableDictionary *dictLocation = [hotspotInfo valueForKey:@"location"];
            
            
            NSManagedObject  *objHotspot = [NSEntityDescription insertNewObjectForEntityForName:@"Hotspot" inManagedObjectContext:[self getContext]];

            [objHotspot setValue:objPost.strImgid forKey:@"imgId"];
            
            [objHotspot setValue:objPost.strPodId forKey:@"podId"];
            
            if([[hotspotInfo valueForKey:@"hotspotId"] length]>0)
                [objHotspot setValue:[hotspotInfo valueForKey:@"hotspotId"] forKey:@"hId"];
            else
                [objHotspot setValue:@"" forKey:@"hId"];

            if([[hotspotInfo valueForKey:@"clickUrl"] length]>0)
                [objHotspot setValue:[hotspotInfo valueForKey:@"clickUrl"] forKey:@"url"];
            else
                [objHotspot setValue:@"" forKey:@"url"];

            RLogs(@"<<<<<< Label - %@", [hotspotInfo valueForKey:@"hotspotLabel"]);
            
            if([[hotspotInfo valueForKey:@"hotspotLabel"] length]>0)
                [objHotspot setValue:[hotspotInfo valueForKey:@"hotspotLabel"] forKey:@"strLabel"];
            else
                [objHotspot setValue:@"" forKey:@"strLabel"];
            
            if([[hotspotInfo valueForKey:@"hotspotDescription"] length]>0)
                [objHotspot setValue:[hotspotInfo valueForKey:@"hotspotDescription"] forKey:@"strDescription"];
            else
                [objHotspot setValue:@"" forKey:@"strDescription"];


            
             [objHotspot setValue:[NSNumber numberWithInteger:[[dictLocation valueForKey:@"x"] integerValue]] forKey:@"xCoordinate"];
            
             [objHotspot setValue:[NSNumber numberWithInteger:[[dictLocation valueForKey:@"y"] integerValue]] forKey:@"yCoordinate"];
            
            NSMutableDictionary *dictMedia = [hotspotInfo valueForKey:@"media"];

            if([[dictMedia valueForKey:@"audioId"] length] > 0)
            {
            [objHotspot setValue:[dictMedia valueForKey:@"audioId"] forKey:@"audioId"];
            }
            else
                [objHotspot setValue:@"" forKey:@"audioId"];

            if([[dictMedia valueForKey:@"audioUrl"] length] > 0)
            [objHotspot setValue:[dictMedia valueForKey:@"audioUrl"] forKey:@"audioFileUrl"];
            else
                [objHotspot setValue:@"" forKey:@"audioFileUrl"];

            [objHotspot setValue:objPost.strOrientation forKey:@"orientation"];

            [objHotspot setValue:@"" forKey:@"audioFileName"];
            [objHotspot setValue:@"" forKey:@"audioFilePath"];
            [objHotspot setValue:[hotspotInfo valueForKey:@"markerColor"] forKey:@"hotspotColor"];



            NSError *error= nil;
            if (![[self getContext] save:&error])
            {
                RLogs(@"Problem saving: %@", [error localizedDescription]);
            }

        }
        
    }

}

+(void)savePostData:(postBO*)ObjPost
{
    
    if([self getPostDataFromDBwithPostId:ObjPost.strPostId] != nil)
        return;
    
    NSManagedObject *managedObjPost= [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:[self getContext]];
    

    [managedObjPost setValue:ObjPost.strPodId forKey:@"podId"];
    
    [managedObjPost setValue:ObjPost.strPostId forKey:@"postId"];
  
    NSError *error= nil;
    if (![[self getContext] save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
    
}


+(void)saveHotspotsSharedData:(postBO*)objPost
{
    RLogs(@"array hotspots shared:%@",objPost.arrHotspotsShared);
    
    for(NSDictionary *dict in objPost.arrHotspotsShared)
    {
        NSArray *aryUids  = [dict valueForKey:@"sharedWith"];
       
        for(NSString *strSharedUId in aryUids)
        {
            
            if([self getHotspotsSharedDataFromDBwithHsId:[dict valueForKey:@"hotspotId"] andUserId:strSharedUId andPostId:objPost.strPostId] != nil)
                continue;
            
            NSManagedObject *objHotspotShareInfo= [NSEntityDescription insertNewObjectForEntityForName:@"HotspotShareInfo" inManagedObjectContext:[self getContext]];
            
            [objHotspotShareInfo setValue:[dict valueForKey:@"hotspotId"] forKey:@"hotSpotId"];
            
            [objHotspotShareInfo setValue:objPost.strPostId forKey:@"postId"];
            
            [objHotspotShareInfo setValue:strSharedUId forKey:@"userId"];
            
           // [objHotspotShareInfo setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"createdAt"];
           //  [objHotspotShareInfo setValue:[NSNumber numberWithLong:(long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970] * 1000)] forKey:@"createdAt"];

            long long milliSecs = [objPost.createdAt longLongValue];
            
            [objHotspotShareInfo setValue:[NSNumber numberWithLongLong:milliSecs] forKey:@"createdAt"];

            
            NSError *error= nil;
            if (![[self getContext] save:&error])
            {
                RLogs(@"Problem saving: %@", [error localizedDescription]);
            }

        }
    }
    
}

+(void)saveHotspotsSharedDataWithHsId:(NSString*)strHsId ofPostId:(NSString*)strPost withUsers:(NSArray*)arrUsers
{
    
    
        for(NSString *strSharedUId in arrUsers)
        {
            
            
            NSManagedObject *objHotspotShareInfo= [NSEntityDescription insertNewObjectForEntityForName:@"HotspotShareInfo" inManagedObjectContext:[self getContext]];
            
            [objHotspotShareInfo setValue:strHsId forKey:@"hotSpotId"];
            
            [objHotspotShareInfo setValue:strPost forKey:@"postId"];
            
            [objHotspotShareInfo setValue:strSharedUId forKey:@"userId"];
            
           // [objHotspotShareInfo setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"createdAt"];
            
            [objHotspotShareInfo setValue:[NSNumber numberWithLong:(long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970] * 1000)] forKey:@"createdAt"];

            NSError *error= nil;
            if (![[self getContext] save:&error])
            {
                RLogs(@"Problem saving: %@", [error localizedDescription]);
            }
            
        }
    
    
}

+(void)savequestionsData:(NSDictionary*)dictquestion
{
    
    NSArray *arrQuestions = [dictquestion valueForKey:@"questionBody"];
    
    for(NSDictionary *dictQuestionData in arrQuestions)
    {
        NSDictionary *dictLocation = [dictQuestionData valueForKey:@"location"];

        NSManagedObject *objQuestion= [NSEntityDescription insertNewObjectForEntityForName:@"Questions" inManagedObjectContext:[self getContext]];
    
        [objQuestion setValue:[dictQuestionData valueForKey:@"questionId"] forKey:@"questionId"];
    
        [objQuestion setValue:[dictQuestionData valueForKey:@"audioUrl"] forKey:@"audioUrl"];

        [objQuestion setValue:[dictQuestionData valueForKey:@"locationColor"] forKey:@"locationColor"];
    
        [objQuestion setValue:[dictQuestionData valueForKey:@"locationMarker"] forKey:@"locationMarker"];
    
        [objQuestion setValue:[dictquestion valueForKey:@"rpostid_s"] forKey:@"postId"];
    
        [objQuestion setValue:[NSNumber numberWithInteger:[[dictLocation valueForKey:@"x"] integerValue]] forKey:@"xCoordinate"];
  
        [objQuestion setValue:[NSNumber numberWithInteger:[[dictLocation valueForKey:@"y"] integerValue]] forKey:@"yCoordinate"];

        [objQuestion setValue:[Util getImgUrl] forKey:@"avatar"];
    
        [objQuestion setValue:[Util getScreenName] forKey:@"screenName_s"];

        [objQuestion setValue:[dictQuestionData valueForKey:@"question"] forKey:@"question"];
  
        [objQuestion setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]* 1000] forKey:@"createdAt"];
        
        [objQuestion setValue:@"" forKey:@"postedBy"];

        NSError *error= nil;
        if (![[self getContext] save:&error])
        {
            RLogs(@"Problem saving: %@", [error localizedDescription]);
        }
    }
 
}


+(void)saveCommentsData:(NSDictionary*)dict
{
        NSManagedObject *objComment= [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:[self getContext]];
       
        [objComment setValue:[dict valueForKey:@"avatar"] forKey:@"avatar"];
        
        [objComment setValue:[dict valueForKey:@"uid_s"] forKey:@"uid_s"];

        [objComment setValue:[dict valueForKey:@"comment"] forKey:@"comment"];

        [objComment setValue:[dict valueForKey:@"screenName_s"] forKey:@"screenName_s"];

        [objComment setValue:[dict valueForKey:@"commentedAt"] forKey:@"commentedAt"];
        
        [objComment setValue:[dict valueForKey:@"postId"] forKey:@"postId"];
        
        NSError *error= nil;
        if (![[self getContext] save:&error])
        {
            RLogs(@"Problem saving: %@", [error localizedDescription]);
        }
    
}

+(void)saveCommentData:(postBO*)objPost
{
    NSArray *aryComments = objPost.arrComments;
    
    for(NSDictionary *dict in aryComments)
    {
        NSMutableDictionary *dictComment = [dict mutableCopy];
        [dictComment setValue:objPost.strPostId forKey:@"postId"];
        [self saveCommentsData:dictComment];
    }
    
}


+(void)saveHotspotCommentsData:(NSDictionary*)dict :(NSString*)strHotspotId
{
    NSManagedObject *objComment= [NSEntityDescription insertNewObjectForEntityForName:@"HotspotComments" inManagedObjectContext:[self getContext]];
    
    [objComment setValue:[Util getImgUrl] forKey:@"avatar"];
    
    [objComment setValue:[dict valueForKey:@"uid_s"] forKey:@"uid"];
    
    [objComment setValue:[dict valueForKey:@"comment"] forKey:@"comment"];
    
    [objComment setValue:[dict valueForKey:@"screenName_s"] forKey:@"screenName_s"];
    
    [objComment setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]* 1000] forKey:@"commentedAt"];

    [objComment setValue:[dict valueForKey:@"rpostid_s"] forKey:@"postId"];
    
    [objComment setValue:[dict valueForKey:@"rpid_s"] forKey:@"podId"];
    
    if([[dict valueForKey:@"hotspot"] length] >0)
    {
        [objComment setValue:[dict valueForKey:@"hotspot"] forKey:@"hotspotId"];
    }
    else
    {
        [objComment setValue:strHotspotId forKey:@"hotspotId"];

    }


    NSError *error= nil;
    if (![[self getContext] save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }

}


+(void)saveQuestionCommentsData:(NSDictionary*)dict
{
    NSManagedObject *objComment= [NSEntityDescription insertNewObjectForEntityForName:@"QuestionComments" inManagedObjectContext:[self getContext]];
    
    NSArray *aryCommentBody = [dict valueForKey:@"commentBody"];
    
    [objComment setValue:[Util getImgUrl] forKey:@"avatar"];
    
    NSDictionary *dictComment = [aryCommentBody objectAtIndex:0];
    NSArray *aryComment = [[dictComment valueForKey:@"comment"] componentsSeparatedByString:@","];
    
    [objComment setValue:[aryComment objectAtIndex:0] forKey:@"comment"];
    
    [objComment setValue:[Util getScreenName] forKey:@"screenName_s"];
    
//    [objComment setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]* 1000] forKey:@"commentedAt"];
    
    [objComment setValue:[NSNumber numberWithInteger:[[aryComment objectAtIndex:1]integerValue]] forKey:@"commentedAt"];

    [objComment setValue:[dict valueForKey:@"rpostid_s"] forKey:@"postId"];
    
    [objComment setValue:[dictComment valueForKey:@"questionId"] forKey:@"questionId"];
    
    
    NSError *error= nil;
    if (![[self getContext] save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
}


@end

