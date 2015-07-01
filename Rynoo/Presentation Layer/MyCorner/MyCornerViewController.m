//
//  MyCornerViewController.m
//  Rnyoo
//
//  Created by Rnyoo on 19/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "MyCornerViewController.h"
#import "SavedHotspotsViewController.h"

@interface PathWithModDate1 : NSObject
@property (strong) NSString *path;
@property (strong) NSDate *modDate;
@property(strong) NSString *strImgId;
@property(strong) NSString *strImgUrl;

@end

@implementation PathWithModDate1
@end


@interface MyCornerViewController ()
{
    NSMutableArray *arrSortedImages;
    NSMutableArray *aryImgPaths;
    NSInteger index;
    BOOL isOrientationChanged;
    UILabel *lblMySaved ;
    UILabel *lblCornerSaved ;
    float YPos;
    UILabel *lblClipBoardTitle;
    UILabel *lblVaultTitle;
    NSInteger clipBoardIndex;

}

@property(nonatomic,strong) NSString *viewTitle;
@end

@implementation MyCornerViewController
@synthesize context;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    index =0;
    clipBoardIndex =0;
  
    arrSortedImages = [[NSMutableArray alloc]init];
    aryImgPaths  = [[NSMutableArray alloc]init];
    context = [APP_DELEGATE managedObjectContext];

    isOrientationChanged = NO;
    YPos = self.view.frame.size.height /2+20;
   
    _vaultView.frame = CGRectMake(0, 20, 320, YPos);
    
    _cornerView.frame = CGRectMake(0, YPos, 320, YPos);

      _vaultView.backgroundColor = [UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:0.85f];
    
   lblVaultTitle = [self createLabelWithTitle:@"My Vault" frame:CGRectMake(20,_vaultView.frame.size.height/2-20,300,30) tag:1 font:[Util Font:FontTypeLight Size:22.0] color:[UIColor whiteColor] numberOfLines:0];
    [_vaultView addSubview:lblVaultTitle];
    
    
    lblMySaved = [self createLabelWithTitle:@"Find all your saved work here" frame:CGRectMake(20,_vaultView.frame.size.height/2,300,60) tag:1 font:[Util Font:FontTypeLight Size:16.0] color:[UIColor whiteColor] numberOfLines:0];
    [_vaultView addSubview:lblMySaved];
    
     _cornerView.backgroundColor = [UIColor colorWithRed:247/255.0f green:97/255.0f blue:81/255.0f alpha:0.85f];
    
    lblClipBoardTitle = [self createLabelWithTitle:@"My Clipboard" frame:CGRectMake(20,_cornerView.frame.size.height/2-60,300,30) tag:1 font:[Util Font:FontTypeLight Size:22.0] color:[UIColor whiteColor] numberOfLines:0];
    [_cornerView addSubview:lblClipBoardTitle];

    lblCornerSaved = [self createLabelWithTitle:@"Create a collage with your snippets" frame:CGRectMake(20,_cornerView.frame.size.height/2-50,300,60) tag:1 font:[Util Font:FontTypeLight Size:16.0] color:[UIColor whiteColor] numberOfLines:0];
    [_cornerView addSubview:lblCornerSaved];
    
    _tblVault.separatorColor = [UIColor clearColor];
    _tblVault.delegate = self;
    _tblVault.dataSource = self;
    _tblVault.scrollEnabled = NO;
    
    
    [self.view bringSubviewToFront:_cornerView];
    [_cornerView sendSubviewToBack:_tblClipBoard];
    
    _tblClipBoard.separatorColor = [UIColor clearColor];
    _tblClipBoard.delegate = self;
    _tblClipBoard.dataSource = self;
    _tblClipBoard.scrollEnabled = NO;

    [self setNavigationBarTitle:@"My Corner"];
    [aryImgPaths removeAllObjects];
    [arrSortedImages removeAllObjects];
    
    [self loadVaultImages];
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
   

}
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if(APP_DELEGATE.isPortrait)
    {

        _vaultViewWidthConstraint.constant = self.view.frame.size.width;
         _vaultViewXPosConstraint.constant = 0;
        
        _cornerVewWidthConstraint.constant = self.view.frame.size.width;
//        _cornerViewYPosConstraint.constant = 304;
        _cornerViewYPosConstraint.constant = YPos;


        _cornerViewXPosConstraint.constant =  0;

        
        _tblClipBoardWidthConstraint.constant = self.view.frame.size.width;
//        _tblClipBoardYPosConstraint.constant = 304;
        _tblClipBoardYPosConstraint.constant = YPos;

        _tblClipBoardXPosConstraint.constant =  0;

        [lblMySaved setFrame:CGRectMake(20,_vaultView.frame.size.height/2,300,60)];
        [lblCornerSaved setFrame:CGRectMake(20,_cornerView.frame.size.height/2-30,300,60)];
        
        [lblVaultTitle setFrame:CGRectMake(20,_vaultView.frame.size.height/2-20,300,30)];
        [lblClipBoardTitle setFrame:CGRectMake(20,_cornerView.frame.size.height/2-50,300,30)];
        
    }
    else
    {
        isOrientationChanged = YES;
        RLogs(@"frame width :%f",self.view.frame.size.width);
        
        _vaultViewXPosConstraint.constant = 30;
        _cornerViewYPosConstraint.constant = 30;
        _tblClipBoardYPosConstraint.constant = 30;

        _vaultViewWidthConstraint.constant = self.view.frame.size.width/2;

        _cornerVewWidthConstraint.constant = self.view.frame.size.width/2;
        
        _cornerViewXPosConstraint.constant = self.view.frame.size.width/2;
        
        _tblClipBoardXPosConstraint.constant = self.view.frame.size.width/2;
        
        _tblClipBoardWidthConstraint.constant = self.view.frame.size.width/2;
    
        _tblTopConstraint.constant = 0;

        [lblMySaved setFrame:CGRectMake(20,_vaultView.frame.size.height/2-30,300,60)];
        
        [lblCornerSaved setFrame:CGRectMake(20,_cornerView.frame.size.height/2-20,300,60)];
        
        [lblVaultTitle setFrame:CGRectMake(20,_vaultView.frame.size.height/2-60,300,30)];
        [lblClipBoardTitle setFrame:CGRectMake(20,_cornerView.frame.size.height/2-50,300,30)];
    }
    [_tblVault reloadData];
    [_tblClipBoard reloadData];
}
#pragma mark UITableView Delegate and DataSource Methods
#pragma mark ===========================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _tblVault)
    {
        NSInteger numberOfRows = [arrSortedImages count]/4;
        
        if(([arrSortedImages count]% 4)>0)
        {
            numberOfRows++;
        }
        RLogs(@"vault rows:%ld",(long)numberOfRows);
        return numberOfRows;

    }
    else
    {
        NSInteger numberOfRows = [aryImgPaths count]/4;
        
        if(([aryImgPaths count]% 4)>0)
        {
            numberOfRows++;
            
        }
        RLogs(@"clipboard rows:%ld",(long)numberOfRows);

        return numberOfRows;
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    RLogs(@"height%f", tableView.frame.size.height);
    return 75;
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    tableView.separatorColor =[UIColor clearColor];
  
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    
    RLogs(@"???Cell Started");
    
    if(tableView == _tblVault)
    {
        float pos = _tblVault.frame.size.width/4 -12;
        RLogs(@"position:%f",pos);
        if(!isOrientationChanged)
            pos = pos+7;
        
        if(indexPath.row ==0)
        {
            for(int i=0;i< [arrSortedImages count];i++)
            {
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5+i*pos,5, pos, pos)];
               // index++;
                if(index >= [arrSortedImages count] )
                    return cell;
                [imageView setImageWithPath:[[arrSortedImages objectAtIndex:i]valueForKey:@"imgPath"] orWithUrl:[[arrSortedImages objectAtIndex:i]valueForKey:@"imgUrl"]];
                [cell.contentView addSubview:imageView];
                index++;
                if(i==3)
                {
               //     index = i;
                    break;
                }
                
            }
            
        }
        else if(indexPath.row ==1)
        {
            for(int i=0;i< [arrSortedImages count];i++)
            {
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5+i*pos,5, pos, pos)];
            //    index++;
                if(index >= [arrSortedImages count] )
                    return cell;
                [imageView setImageWithPath:[[arrSortedImages objectAtIndex:index]valueForKey:@"imgPath"] orWithUrl:[[arrSortedImages objectAtIndex:index]valueForKey:@"imgUrl"]];
                [cell.contentView addSubview:imageView];
                index++;
                if(i==3)
                {
                    break;
                }
                
            }
            
        }
        else if(indexPath.row == 2)
        {
            for(int i=0;i< [arrSortedImages count];i++)
            {
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5+i*pos,5, pos, pos)];
       //         index++;
                
                if(index >= [arrSortedImages count] )
                    return cell;
                
                [imageView setImageWithPath:[[arrSortedImages objectAtIndex:index]valueForKey:@"imgPath"] orWithUrl:[[arrSortedImages objectAtIndex:index]valueForKey:@"imgUrl"]];
                [cell.contentView addSubview:imageView];
                
                index++;
                if(i==3)
                {
                    break;
                }
            }
            
        }

    }
    else
    {
        float pos = _tblClipBoard.frame.size.width/4 -12;
        if(!isOrientationChanged)
            pos = pos+7;
        RLogs(@"position clipboard:%f",pos);

        if(indexPath.row ==0)
        {
           clipBoardIndex =0;
            for(int i=0;i< [aryImgPaths count];i++)
            {
                PathWithModDate1 *pathsObj = [aryImgPaths objectAtIndex:i];

                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5+i*pos,5, pos, pos)];
                if(clipBoardIndex >= [aryImgPaths count] )
                    return cell;
                [imageView setImageWithPath:pathsObj.path];
                
                [cell.contentView addSubview:imageView];
                clipBoardIndex++;

                if(i==3)
                {
                    break;
                }
                
            }
            
        }
        else if(indexPath.row ==1)
        {
            for(int i=0;i< [aryImgPaths count];i++)
            {
                PathWithModDate1 *pathsObj = [aryImgPaths objectAtIndex:index];

                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5+i*pos,5, pos, pos)];
                if(clipBoardIndex >= [aryImgPaths count] )
                    return cell;
                [imageView setImageWithPath:pathsObj.path];
                [cell.contentView addSubview:imageView];
                
                clipBoardIndex++;
                if(i==3)
                {
                    break;
                }
                
            }
            
        }
        else if(indexPath.row == 2)
        {
            for(int i=0;i< [aryImgPaths count];i++)
            {
                PathWithModDate1 *pathsObj = [aryImgPaths objectAtIndex:index];

                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5+i*pos,5, pos, pos)];
                
                if(clipBoardIndex >= [aryImgPaths count] )
                    return cell;
                
                [imageView setImageWithPath:pathsObj.path];
                [cell.contentView addSubview:imageView];
                clipBoardIndex++;
                if(i==3)
                {
                    break;
                }
                
            }
            
        }

    }
  
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    RLogs(@"???Cell ENded");
    }
    return  cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == MY_VAULT)
        _viewTitle = MY_VAULT_VIEW;
    else
        _viewTitle = MY_CLIPBOARD_VIEW;
    
    [self performSegueWithIdentifier:SavedHotspotsSegue sender:nil];

}

#pragma mark - Create Label

-(UILabel*)createLabelWithTitle:(NSString*)strTitle frame:(CGRect)frame tag:(NSInteger)intTag font:(UIFont*)font color:(UIColor*)color numberOfLines:(NSInteger)intNoOflines
{
    UILabel *lbl=[[UILabel alloc]initWithFrame:frame];
    lbl.text=strTitle;
    lbl.font=font;
    lbl.tag=intTag;
    lbl.backgroundColor=[UIColor clearColor];
    lbl.textColor=color;
    lbl.numberOfLines=intNoOflines;
    return lbl;
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if(size.width < 480.0)
    {
        APP_DELEGATE.isPortrait = YES;
    }
    else
    {
        APP_DELEGATE.isPortrait = NO;
    }
}

-(void)viewDidLayoutSubviews
{
        if ([_tblOptions respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tblOptions setSeparatorInset:UIEdgeInsetsZero];
    }
}

-(void)viewWillLayoutSubviews
{
    RLogs(@"frame width :%f",self.view.frame.size.width);
    
    if(isOrientationChanged)
    {
        _vaultViewWidthConstraint.constant = self.view.frame.size.width/2;
        
        _cornerVewWidthConstraint.constant = self.view.frame.size.width/2;
        
        _cornerViewXPosConstraint.constant = self.view.frame.size.width/2;
        
        _tblClipBoardXPosConstraint.constant = self.view.frame.size.width/2;
        _tblClipBoardWidthConstraint.constant = self.view.frame.size.width/2;
        
        [lblMySaved setFrame:CGRectMake(20,_vaultView.frame.size.height/2-30,300,60)];
        
        [lblCornerSaved setFrame:CGRectMake(20,_cornerView.frame.size.height/2-20,300,60)];

        [lblVaultTitle setFrame:CGRectMake(20,_vaultView.frame.size.height/2-60,300,30)];
        [lblClipBoardTitle setFrame:CGRectMake(20,_cornerView.frame.size.height/2-50,300,30)];
        
        isOrientationChanged = NO;
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero]; // ios 8 newly added
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:SavedHotspotsSegue]) {
        SavedHotspotsViewController *savedHSObj = (SavedHotspotsViewController*)segue.destinationViewController;
        savedHSObj.viewTitle = _viewTitle;
    }
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    CGPoint touch_point = [[touches anyObject] locationInView:self.view];
    if ([self.vaultView pointInside: [self.view convertPoint:touch_point toView: self.vaultView] withEvent:event])
    {
        _viewTitle = MY_VAULT_VIEW;

    }
    else
    {
        _viewTitle = MY_CLIPBOARD_VIEW;
        
    }
    [self performSegueWithIdentifier:SavedHotspotsSegue sender:nil];

}


-(void)loadVaultImages
{
    [self refreshImages];
    [self loadClipBoardImages];
}


-(void)refreshImages
{
    
    NSArray *aryImages = [self getImagesfromDB]; // Retrieving image paths from DB
    RLogs(@">>>>>aryImages count - %ld", (unsigned long)[aryImages count]);
    
    // Preparing sorted images by created time
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"imageCreatedTime" ascending:YES];
    arrSortedImages = [[NSMutableArray alloc]initWithArray:[aryImages sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]]];
    
    RLogs(@">>>>>arrSortedImages count - %ld", (unsigned long)[arrSortedImages count]);
    
    
    [_tblVault reloadData];
}

/*get Images from DB*/

-(NSMutableArray*)getImagesfromDB
{
    
    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return [fetchedObjects mutableCopy];
}


-(void)loadClipBoardImages
{
    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:CLIPBOARD_FOLDER];
    NSArray *imgPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    for (NSString *imgName in imgPaths) {
        //Get contents of each file path for sorting
        NSString *path = [folderPath stringByAppendingPathComponent:imgName];
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        NSDate *modDate = [fileDict objectForKey:NSFileModificationDate];
        PathWithModDate1 *pathWithDate = [[PathWithModDate1 alloc] init];
        pathWithDate.path = path;
        pathWithDate.modDate = modDate;
        [aryImgPaths addObject:pathWithDate];
    }
    
    // Sorting images by created dates
    [aryImgPaths sortUsingComparator:^(PathWithModDate1 *path1, PathWithModDate1 *path2){
        return [path1.modDate compare:path2.modDate];
    }];
    
    if([aryImgPaths count])
       [_tblClipBoard reloadData];
    
}
@end
