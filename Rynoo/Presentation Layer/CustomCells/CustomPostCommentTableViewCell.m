//
//  CustomPostCommentTableViewCell.m
//  Rnyoo
//
//  Created by Rnyoo on 25/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "CustomPostCommentTableViewCell.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation CustomPostCommentTableViewCell

@synthesize aryPostData;
- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0, 0, 300, 150);
        UITableView *subMenuTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        subMenuTableView.tag = 100;
        
        subMenuTableView.rowHeight =[self calculateHeight];
        RLogs(@"%f",subMenuTableView.rowHeight);
        subMenuTableView.separatorColor = [UIColor clearColor];
        subMenuTableView.delegate = self;
        subMenuTableView.dataSource = self;
        [self addSubview:subMenuTableView];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    UITableView *subMenuTableView =(UITableView *) [self viewWithTag:100];
    subMenuTableView.frame = CGRectMake(0.2, 0.3, self.bounds.size.width-5,    self.bounds.size.height-5);//set the frames for tableview
    
}

//manage datasource and  delegate for submenu tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [aryPostData count] ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        cell.clearsContextBeforeDrawing = YES;
        
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
     
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20,30, 25, 25)];
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.clipsToBounds = YES;
    imageView.layer.borderWidth = 3.0f;
    imageView.layer.borderColor = [UIColor blackColor].CGColor;
    [imageView setImageWithURL:[NSURL URLWithString:[[aryPostData objectAtIndex:indexPath.row ] valueForKey:@"avatar"]]];
    [cell.contentView addSubview:imageView];
    
    
    UILabel *lblCommentedUsername = [self createLabelWithTitle:[[aryPostData objectAtIndex:indexPath.row ] valueForKey:@"screenName_s"] frame:CGRectMake(50, 30, 285, 20) tag:1 font:[Util Font:FontTypeLight Size:14.0] color:[UIColor redColor] numberOfLines:0];
    [cell.contentView addSubview:lblCommentedUsername];
    
    
    UILabel *lblComment = [self createLabelWithTitle:[[aryPostData objectAtIndex:indexPath.row ] valueForKey:@"comment"] frame:CGRectMake(40, 40, tableView.frame.size.width-40, 70) tag:1 font:[Util Font:FontTypeItalic Size:14.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:2];
    lblComment.lineBreakMode = NSLineBreakByWordWrapping ;
    lblComment.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:lblComment];
  
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]init];
    [headerView setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];
    
    
    UILabel *lblCommentsTitle = [self createLabelWithTitle:@"Post comments" frame:CGRectMake(20, 5, 285, 20) tag:1 font:[Util Font:FontTypeSemiBold Size:13.0] color:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f] numberOfLines:0];

    headerView.backgroundColor = [UIColor clearColor];
    
    [headerView addSubview:lblCommentsTitle];
    
    return headerView;
    
}

-(CGFloat)calculateHeight
{
 //   return 40 + 50 *4 ; // 3(multiplier) - comments count
    return 40 + 70 *[aryPostData count] + 50 ;

}

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

@end
