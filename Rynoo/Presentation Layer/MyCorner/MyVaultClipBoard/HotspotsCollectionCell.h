//
//  HotspotsCollectionCell.h
//  Rnyoo
//
//  Created by Rnyoo on 05/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotspotsCollectionCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *HSImgView;
@property (strong, nonatomic) IBOutlet UIImageView *selectedImgView;

CGImageRef MyCreateThumbnailImageFromData (NSData * data, int imageSize);

-(void)setImageFromPath:(NSString *)path;
-(void)setThumbImage:(UIImage*)thumImg;
-(void)setVaultImageFromPath:(NSString*)path orFromUrl:(NSString*)url;
-(void)setImageForVault:(NSDictionary *)dictPathUrl;

@end
