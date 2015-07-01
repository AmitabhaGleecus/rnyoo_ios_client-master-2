//
//  CustomNetworkCell.m
//  Rnyoo
//
//  Created by Rnyoo on 25/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "CustomNetworkCell.h"

@implementation CustomNetworkCell
@synthesize dataAraay,isPostcomments;

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
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
    //return dataAraay.count;
    return 1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RLogs(@"post: %i",isPostcomments);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
   
    if(indexPath.row ==0)
    {
        UILabel *lblCommentsTitle = [self createLabelWithTitle:@"Recent Hotspot comments" frame:CGRectMake(20, 5, 285, 20) tag:1 font:[Util Font:FontTypeSemiBold Size:13.0] color:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f] numberOfLines:0];
        [cell.contentView addSubview:lblCommentsTitle];
        

        UILabel *lblCommentedUsername = [self createLabelWithTitle:@"Username" frame:CGRectMake(20, 25, 285, 20) tag:1 font:[Util Font:FontTypeLight Size:11.0] color:[UIColor redColor] numberOfLines:0];
        [cell.contentView addSubview:lblCommentedUsername];
        
        UILabel *lblComment = [self createLabelWithTitle:@"This is a hotspot comment that can span upto two lines and can contain upto a set number of characters" frame:CGRectMake(20, 35, tableView.frame.size.width, 50) tag:1 font:[Util Font:FontTypeItalic Size:12.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:2];
        lblComment.lineBreakMode = NSLineBreakByWordWrapping ;
        lblComment.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:lblComment];
        
        UILabel *lblComment1 = [self createLabelWithTitle:@"This is a hotspot comment that can span upto two lines and can contain upto a set number of characters" frame:CGRectMake(20, 70, tableView.frame.size.width, 50) tag:1 font:[Util Font:FontTypeItalic Size:12.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:2];
        lblComment1.lineBreakMode = NSLineBreakByWordWrapping ;
        lblComment1.adjustsFontSizeToFitWidth = YES;

        [cell.contentView addSubview:lblComment1];
        
        UILabel *lblComment2 = [self createLabelWithTitle:@"This is a hotspot comment that can span upto two lines and can contain upto a set number of characters" frame:CGRectMake(20, 110, tableView.frame.size.width, 50) tag:1 font:[Util Font:FontTypeItalic Size:12.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:2];
        lblComment2.lineBreakMode = NSLineBreakByWordWrapping ;
        lblComment2.adjustsFontSizeToFitWidth = YES;

        [cell.contentView addSubview:lblComment2];
        
        UILabel *lblComment3 = [self createLabelWithTitle:@"This is a hotspot comment that can span upto two lines and can contain upto a set number of characters" frame:CGRectMake(20, 150, tableView.frame.size.width, 50) tag:1 font:[Util Font:FontTypeItalic Size:12.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:2];
        lblComment3.lineBreakMode = NSLineBreakByWordWrapping ;
        lblComment3.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:lblComment3];
        
        UILabel *lblComment4 = [self createLabelWithTitle:@"This is a hotspot comment that can span upto two lines and can contain upto a set number of characters" frame:CGRectMake(20, 190, tableView.frame.size.width, 50) tag:1 font:[Util Font:FontTypeItalic Size:12.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:2];
        lblComment4.lineBreakMode = NSLineBreakByWordWrapping ;
        lblComment4.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:lblComment4];


    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

-(CGFloat)calculateHeight
{
    return 40 + 50 *4 ; // 3(multiplier) - comments count
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
