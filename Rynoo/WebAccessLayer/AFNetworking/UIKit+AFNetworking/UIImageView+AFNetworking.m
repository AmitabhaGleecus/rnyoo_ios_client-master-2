// UIImageView+AFNetworking.m
//
// Copyright (c) 2013-2014 AFNetworking (http://afnetworking.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIImageView+AFNetworking.h"
#import "Constants.h"

#import <objc/runtime.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#import "AFHTTPRequestOperation.h"

#import "UIImage+WebP.h"

@interface AFImageCache : NSCache <AFImageCache>
@end

#pragma mark -

@interface UIImageView (_AFNetworking)
@property (readwrite, nonatomic, strong, setter = af_setImageRequestOperation:) AFHTTPRequestOperation *af_imageRequestOperation;
@end

@implementation UIImageView (_AFNetworking)

+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        _af_sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });

    return _af_sharedImageRequestOperationQueue;
}

- (AFHTTPRequestOperation *)af_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, @selector(af_imageRequestOperation));
}

- (void)af_setImageRequestOperation:(AFHTTPRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, @selector(af_imageRequestOperation), imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -

@implementation UIImageView (AFNetworking)
@dynamic imageResponseSerializer;

+ (id <AFImageCache>)sharedImageCache {
    static AFImageCache *_af_defaultImageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _af_defaultImageCache = [[AFImageCache alloc] init];

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_af_defaultImageCache removeAllObjects];
        }];
    });

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    return objc_getAssociatedObject(self, @selector(sharedImageCache)) ?: _af_defaultImageCache;
#pragma clang diagnostic pop
}

+ (void)setSharedImageCache:(id <AFImageCache>)imageCache {
    objc_setAssociatedObject(self, @selector(sharedImageCache), imageCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (id <AFURLResponseSerialization>)imageResponseSerializer {
    static id <AFURLResponseSerialization> _af_defaultImageResponseSerializer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_defaultImageResponseSerializer = [AFImageResponseSerializer serializer];
    });

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    return objc_getAssociatedObject(self, @selector(imageResponseSerializer)) ?: _af_defaultImageResponseSerializer;
#pragma clang diagnostic pop
}

- (void)setImageResponseSerializer:(id <AFURLResponseSerialization>)serializer {
    objc_setAssociatedObject(self, @selector(imageResponseSerializer), serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -
- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithPath:(NSString *)path
{
    [self setImage:[UIImage imageWithContentsOfFile:path]];
}



-(void)setImageOfVault:(NSDictionary *)dictPathUrl
{
    RLogs(@"dictPathUrl - %@", dictPathUrl);
    [self setImageWithPath:[dictPathUrl valueForKey:@"path"] orWithUrl:[dictPathUrl valueForKey:@"url"]];
}
- (void)setImageWithPath:(NSString *)path orWithUrl:(NSString*)strUrl
{
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        UIImage *img = [UIImage imageWithWebPAtPath:path];
        if(img)
       [self performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:YES];
        
    }
    else
    {
        
        NSMutableDictionary *dictUrlAndPath = [[NSMutableDictionary alloc] init];
        [dictUrlAndPath setValue:strUrl forKey:@"url"];
        [dictUrlAndPath setValue:path forKey:@"path"];

        [self performSelectorInBackground:@selector(downloadImage:) withObject:dictUrlAndPath];
        //[self downloadImageFromUrl:strUrl andSaveAtPath:path];
    }
}


-(void)downloadImage:(NSDictionary*)dictUrlPath
{
    //RLogs(@"vault image URL - %@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[dictUrlPath valueForKey:@"url"]]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    //Downloading webp image to vaults folder.
    [self downloadImageWithURLRequest:request saveImagePath:[dictUrlPath valueForKey:@"path"] success:nil
                              failure:nil];
    
}

-(void)downloadImageFromUrl:(NSString*)urlString andSaveAtPath:(NSString*)strPath
{
    RLogs(@"vault image URL - %@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    //Downloading webp image to vaults folder.
    [self downloadImageWithURLRequest:request saveImagePath:strPath success:nil
                              failure:nil];

}


- (void)downloadImageWithURLRequest:(NSURLRequest *)urlRequest
              saveImagePath:(NSString *)imagePath
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [self cancelImageRequestOperation];
    
    
    __weak __typeof(self)weakSelf = self;
    self.af_imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    self.af_imageRequestOperation.responseSerializer = self.imageResponseSerializer;
    [self.af_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if ([[urlRequest URL] isEqual:[strongSelf.af_imageRequestOperation.request URL]]) {
            if (success) {
                success(urlRequest, operation.response, responseObject);
            } else if (operation.responseData) {
                //strongSelf.image = (UIImage*)responseObject;
                RLogs(@"operation.responseData length - %lu", (unsigned long)[operation.responseData length]);
                strongSelf.image = [UIImage imageWithWebPData:operation.responseData];
                [strongSelf setContentMode:UIViewContentModeScaleAspectFit];
               
                
            }
            
            if (operation == strongSelf.af_imageRequestOperation){
                strongSelf.af_imageRequestOperation = nil;
            }
        }
        
        RLogs(@"imagePath : %@", imagePath);
        if([UIImage writeWebpData:operation.responseData toFilePath:imagePath])
            RLogs(@"save success");
        else
            RLogs(@"save Failed");

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        RLogs(@"Error is %@", [error description]);
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if ([[urlRequest URL] isEqual:[strongSelf.af_imageRequestOperation.request URL]]) {
            if (failure) {
                failure(urlRequest, operation.response, error);
            }
            
            if (operation == strongSelf.af_imageRequestOperation){
                strongSelf.af_imageRequestOperation = nil;
            }
        }
    }];
    
    [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];



}


- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [self cancelImageRequestOperation];

    UIImage *cachedImage = [[[self class] sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage) {
        if (success) {
            success(nil, nil, cachedImage);
        } else {
            self.image = cachedImage;
            
            [self setContentMode:UIViewContentModeScaleAspectFit];
        }

        self.af_imageRequestOperation = nil;
    } else {
        if (placeholderImage) {
            self.image = placeholderImage;
            [self setContentMode:UIViewContentModeScaleAspectFit];

        }
        
        __weak __typeof(self)weakSelf = self;
        self.af_imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        self.af_imageRequestOperation.responseSerializer = self.imageResponseSerializer;
        [self.af_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.af_imageRequestOperation.request URL]]) {
                if (success) {
                    success(urlRequest, operation.response, responseObject);
                } else if (responseObject) {
                    strongSelf.image = responseObject;
                    [strongSelf setContentMode:UIViewContentModeScaleAspectFit];

                }

                if (operation == strongSelf.af_imageRequestOperation){
                        strongSelf.af_imageRequestOperation = nil;
                }
            }

            [[[strongSelf class] sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.af_imageRequestOperation.request URL]]) {
                if (failure) {
                    failure(urlRequest, operation.response, error);
                }

                if (operation == strongSelf.af_imageRequestOperation){
                        strongSelf.af_imageRequestOperation = nil;
                }
            }
        }];

        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}

- (void)cancelImageRequestOperation {
    [self.af_imageRequestOperation cancel];
    self.af_imageRequestOperation = nil;
}

- (void)clearImageCacheForURL:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    UIImage *cachedImage = [[[self class] sharedImageCache] cachedImageForRequest:request];
    if (cachedImage) {
        [[[self class] sharedImageCache] clearCachedRequest:request];
    }
}


@end

#pragma mark -

static inline NSString * AFImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

@implementation AFImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }

	return [self objectForKey:AFImageCacheKeyFromURLRequest(request)];
}

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
{
    if (image && request) {
        [self setObject:image forKey:AFImageCacheKeyFromURLRequest(request)];
    }
}
- (void)clearCachedRequest:(NSURLRequest *)request {
    
    RLogs(@"Clear - %@", [request.URL description]);
    if (request) {
        [self removeObjectForKey:AFImageCacheKeyFromURLRequest(request)];
    }
}

-(void)saveImageData:(NSData*)imageData AtPath:(NSString*)strPath
{
    RLogs(@">>>>vault Path is %@", strPath);
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            
            if([[NSFileManager defaultManager] fileExistsAtPath:strPath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
            }
            
            NSError * error = nil;
            
            [imageData writeToFile:strPath options:NSDataWritingAtomic error:&error];
            
            
        });
    });*/
    
    NSError * error = nil;

    [imageData writeToFile:strPath options:NSDataWritingAtomic error:&error];


}

@end

#endif
