//
//  HotspotsCollectionCell.m
//  Rnyoo
//
//  Created by Rnyoo on 05/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "HotspotsCollectionCell.h"

#import <CoreGraphics/CoreGraphics.h>

#import <ImageIO/ImageIO.h>

#import "UIImage+WebP.h"
#import "UIImageView+AFNetworking.h" 

@implementation HotspotsCollectionCell


-(void)setImageFromPath:(NSString *)path{
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *thumImg = [UIImage imageWithCGImage:MyCreateThumbnailImageFromData(data, self.HSImgView.frame.size.width * self.HSImgView.frame.size.height)];
    [self performSelectorOnMainThread:@selector(setThumbImage:) withObject:thumImg waitUntilDone:YES];
    
    
}

-(void)setImageForVault:(NSDictionary *)dictPathUrl
{
    RLogs(@"dictPathUrl - %@", dictPathUrl);
   // [self.HSImgView setImageWithPath:[dictPathUrl valueForKey:@"path"] orWithUrl:[dictPathUrl valueForKey:@"url"]];
    
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[dictPathUrl valueForKey:@"path"]])
    {
        UIImage *img = [UIImage imageWithWebPAtPath:[dictPathUrl valueForKey:@"path"]];
        [self performSelectorOnMainThread:@selector(setVaultImage:) withObject:img waitUntilDone:YES];
        //[self.HSImgView setImage:[UIImage imageWithWebPAtPath:path]];
    }
    else
    {
        //[self downloadImageFromUrl:url toPath:path];
        [self performSelectorInBackground:@selector(downloadImage1:) withObject:dictPathUrl];
        
    }

}

-(void)setVaultImage:(UIImage*)img
{
    [self.HSImgView setImage:img];
}

-(void)setVaultImageFromPath:(NSString*)path orFromUrl:(NSString*)url
{
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        UIImage *img = [UIImage imageWithWebPAtPath:path];
        [self performSelectorOnMainThread:@selector(setVaultImage:) withObject:img waitUntilDone:YES];
        //[self.HSImgView setImage:[UIImage imageWithWebPAtPath:path]];
    }
    else
    {
        //[self downloadImageFromUrl:url toPath:path];
        //[self performSelectorInBackground:@selector(downloadImage:) withObject:dict];

    }
}

-(void)setThumbImage:(UIImage*)thumImg
{
    [self.HSImgView setImage:thumImg];

}

CGImageRef MyCreateThumbnailImageFromData (NSData * data, int imageSize)
{
    CGImageRef        myThumbnailImage = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[3];
    CFTypeRef         myValues[3];
    CFNumberRef       thumbnailSize;
    
    // Create an image source from NSData; no options.
    myImageSource = CGImageSourceCreateWithData((CFDataRef)data,
                                                NULL);
    // Make sure the image source exists before continuing.
    if (myImageSource == NULL){
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
    
    // Package the integer as a  CFNumber object. Using CFTypes allows you
    // to more easily create the options dictionary later.
    thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    
    // Set up the thumbnail options.
    myKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
    myKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    myValues[2] = (CFTypeRef)thumbnailSize;
    
    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
                                   (const void **) myValues, 2,
                                   &kCFTypeDictionaryKeyCallBacks,
                                   & kCFTypeDictionaryValueCallBacks);
    
    // Create the thumbnail image using the specified options.
    myThumbnailImage = CGImageSourceCreateThumbnailAtIndex(myImageSource,
                                                           0,
                                                           myOptions);
    // Release the options dictionary and the image source
    // when you no longer need them.
    CFRelease(thumbnailSize);
    CFRelease(myOptions);
    CFRelease(myImageSource);
    
    // Make sure the thumbnail image exists before continuing.
    if (myThumbnailImage == NULL){
        fprintf(stderr, "Thumbnail image not created from image source.");
        return NULL;
    }
    
    
    return myThumbnailImage;
}


/*-(void)setImageFromPath:(NSString*)path{
    
    
  //  [self.HSImgView setImage:[UIImage imageWithContentsOfFile:path]];

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        UIImage *img = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HSImgView setImage:img];
            
        });
        
        
        img = nil;
        data = nil;
    });

}*/




-(void)downloadImageFromUrl:(NSString*)strUrl toPath:(NSString*)strPath
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:strUrl forKey:@"url"];
    [dict setObject:strPath forKey:@"path"];
    [self performSelectorInBackground:@selector(downloadImage1:) withObject:dict];
}

-(void)downloadImage1:(NSDictionary*)dict
{
    NSString *strUrl = [dict valueForKey:@"url"];
    NSString *strPath = [dict valueForKey:@"path"];
    
    NSLog(@"strpath - %@", strPath);

    if(strUrl != nil && strUrl.length > 0 && (NSNull*)strUrl != [NSNull null])
    {
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            
            
             NSData *webPdata =  [NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                
                if([[NSFileManager defaultManager] fileExistsAtPath:strPath])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
                }
                
                NSError * error = nil;
                
                NSLog(@"strpath2 - %@", strPath);
                
                BOOL success = [webPdata writeToFile:strPath options:NSDataWritingAtomic error:&error];
                if(success)
                {
                    NSLog(@"success");
                }
                else
                {
                    NSLog(@"Failed");
                    
                    /*if(!success)
                    {
                        RLogs(@"######Image save failed as there is folders missing. So created vault path with imagename and saving in that path");
                        self.objPost.strImgLocalPath = [self getFilePathwithFileName:[strUrl lastPathComponent] inFolder:VAULT_FOLDER];
                        
                        success = [webPdata writeToFile:self.objPost.strImgLocalPath options:NSDataWritingAtomic error:&error];
                        
                        if(success)
                        {
                            RLogs(@"success");
                        }
                    }*/


                }

               // [webPdata writeToFile:strPath options:NSDataWritingAtomic error:&error];
                
               // [self.HSImgView setImage:[UIImage imageWithWebPData:webPdata]];
                
                [self.HSImgView setImage:[UIImage imageWithWebPAtPath:strPath]];
                
            });
        });
        
    }
    
}


@end
