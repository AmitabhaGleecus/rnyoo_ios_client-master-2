//
//  HotSpotViewController.h
//  Rnyoo
//
//  Created by Rnyoo on 20/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "hotSpotCircleView.h"
#import "NLCropViewLayer.h"
#import "HSPodImgScrlView.h"
#import "HotSpotPodBO.h"
#import "ImageOccupyView.h"
#import "UIImage+WebP.h"
#import <AVFoundation/AVFoundation.h>
#import "Util_HotSpot.h"
#import "Constants.h"
#import <CoreLocation/CoreLocation.h>
#import "questionView.h"
#import "RateView.h"

enum
{
    ENC_AAC = 1,
    ENC_ALAC = 2,
    ENC_IMA4 = 3,
    ENC_ILBC = 4,
    ENC_ULAW = 5,
    ENC_PCM = 6,
} encodingTypes;

@interface HotSpotViewController : BaseViewController<AVAudioPlayerDelegate, AVAudioRecorderDelegate,CLLocationManagerDelegate,RateViewDelegate>
{
    
    hotSpotCircleView *hsCircleView;
    BOOL isKeyBoardAppeared;
    BOOL isOrientationChanged;
    AVAudioRecorder *audioRecorder;
    int recordEncoding, questionAudioIndex;
    AVAudioPlayer *audioPlayer;
    NSString *strTxt, *lastChar;
    CGSize aspectFitSize, preImageViewSize;
    CGSize imageBounds, imgBoundsAtNormalZoomInPortrait, imgBoundsAtNormalZoomInLandScape;
    
    ImageOccupyView *imageExactSubView;
    NSString *podUniqueId;
    CGPoint originalViewCentre;
    NLCropViewLayer *_cropView;
    
    BOOL isZoomLocked;
    BOOL isSendBack, isViewAtNormalFrame;
    
    Util_HotSpot *objUtilForHotspot;

    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    BOOL isPostingStarted, isImgSavedInWebp;
    questionView *hsQuestionView;
    
    BOOL isNewHsAddedByPublisher, isHsUpdatedByPublisher, isPublisherUpdate, isPublisherRePost;
    
    NSMutableArray *arrAddedHsIds, *arrUpdatedHsIds, *arrDeleteHsIds, *arrRemainedHsIds, *arrDeletedQuestionIds, *arrModifiedQuestions;
    
    BOOL isToCreateNewPodForRepost;
    
    float descriptionTextHeightConstant;
}
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *hsToolBtnConstraint;

@property(nonatomic, retain) UIImage *pickedImage;

@property (retain, nonatomic) UIImageView *pickdImageView;

@property(retain, nonatomic) NSString *strImagePath;

@property (weak, nonatomic) IBOutlet UIButton *btnAddHotSpot;
@property (weak, nonatomic) IBOutlet UIButton *btnCropClip;
@property (weak, nonatomic) IBOutlet UIButton *btnEye;

@property (nonatomic, retain) NSMutableArray *arrHotspots;
@property (nonatomic, retain) NSArray *arrHotspotInfo;

@property (strong, nonatomic) IBOutlet HSPodImgScrlView *scrlImgView;
@property (strong, nonatomic) IBOutlet UITextField *hotspotTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblPlaceHolder;

@property (weak, nonatomic) IBOutlet UISlider *sliderAudio;
@property (weak, nonatomic) IBOutlet UIButton *btnRecord;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property(nonatomic,retain)NSManagedObjectContext *context;

@property (strong, nonatomic) IBOutlet UITextView *descriptionTxtView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *HotSpotTxtViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *_scrlBtmView;

@property (weak, nonatomic) IBOutlet UITextField *hotspotUrlTextField;
@property(nonatomic,strong)NSString *strSelectedImageFrom;
//@property(nonatomic, retain) HotSpotPodBO *objPod;
@property (strong, nonatomic) IBOutlet UILabel *lablePlaceHolder;

@property(nonatomic,retain)NSString *selectedImgId;

@property(nonatomic, retain) NSString *strParentPodId;

@property(nonatomic, retain) NSString *strPodId, *strPostId;

@property (nonatomic, retain) NSMutableArray *arrQuestions;

@property(nonatomic,retain)NSArray *arrHotspotRating;

-(void)refreshHotspotsPosition;
-(void)refreshHotspotsWhenScrollViewFrameChanged;
-(void)addNewHotspot;
-(void)calculateAspectRatioOfImage;
-(void)stopAudio;

@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

- (IBAction)btnDelete_action:(id)sender;
- (IBAction)btnRecord_TouchUpInside:(id)sender;
-(void)sendBack;
-(void)calculatePositionCoordinatesOfSelectedHotSpotToPoint:(CGPoint)point;
-(void)refreshHotspotsPositionInOrientation;
-(CGPoint)getCentreWRTImageSize:(CGPoint)currentCentre;
-(void)saveImagetoDBWithLocalPath:(NSString*)strLocalPath WithImageName:(NSString*)strImagName;
-(void)sendNewQuestionToServer;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *saveWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *saveXposConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *hotSpotWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *hotSpotXposConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cropWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cropXposConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *eyeXposConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *eyeWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *postXposConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *postWidthConstraint;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;

@property(nonatomic, assign) FROM_SOURCE source;
@property(nonatomic, assign) BOOL isPodExisting;
@property (strong, nonatomic) IBOutlet UIButton *btn_HotspotWhite;
@property (strong, nonatomic) IBOutlet UIButton *btn_HotspotBlue;
@property (strong, nonatomic) IBOutlet UIButton *btn_HotspotRed;

@property (strong, nonatomic) IBOutlet UIButton *btn_HotspotYellow;

@property (strong, nonatomic) IBOutlet UIButton *btnLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnLink;
@property (strong, nonatomic) IBOutlet UIButton *btnAudio;
@property (strong, nonatomic) IBOutlet RateView *rateView;

@property(nonatomic,retain)NSArray *aryQuestionComments;
@property(nonatomic,retain)NSArray *aryHotspotComments;
@property(nonatomic,retain)NSDate *imgCreatedDate;
@property(nonatomic,retain)NSString *strLocation;

- (IBAction)btnRateClicked:(id)sender;
- (IBAction)btnAudioClicked:(id)sender;
- (IBAction)btnCommentClicked:(id)sender;

@end
