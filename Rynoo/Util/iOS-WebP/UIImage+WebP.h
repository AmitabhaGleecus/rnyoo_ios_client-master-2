//
// UIImage+WebP.h
//
// Created by Gabriel Harrison <nyteshade@gmail.com>
// Much inspiration for code comes from Carson McDonald
// his website is http://www.ioncannon.net
//
// Modified (encoding added) by Dmitry Shmidt, mail@shmidtlab.com

#import <UIKit/UIKit.h>
#import <WebP.framework/Headers/encode.h>
#import <WebP.framework/Headers/decode.h>
#import "Constants.h"

@interface UIImage (WebP)

- (NSData *)dataWebPWithQuality:(float)quality; //quality = 0..100
+ (UIImage*)imageWithWebPAtPath:(NSString *)filePath;
+ (UIImage *)imageWithWebPData:(NSData *)imgData;
@property (nonatomic, readonly) NSData *dataWebPLossless;

- (BOOL)writeWebPToDocumentsWithFileName:(NSString *)filename quality:(float)quality;
- (BOOL)writeWebPToFilePath:(NSString *)filePath quality:(float)quality;
- (BOOL)writeWebPLosslessToFilePath:(NSString *)filePath;

- (BOOL)writeWebPLosslessToDocumentsWithFileName:(NSString *)filename;
+(BOOL)writeWebpData:(NSData*)webpdata toFilePath:(NSString*)filePath;


@end
