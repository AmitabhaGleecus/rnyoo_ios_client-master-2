//
//  postsTableView.m
//  Rnyoo
//
//  Created by Sreenadh G on 19/03/15.
//  Copyright (c) 2015 Suvarna. All rights reserved.
//

#import "postsTableView.h"

@implementation postsTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/*-(void)layoutSubviews
{
    [super layoutSubviews];
    
    for (UIView* child in [self subviews]) {
        
        CGRect frame1 = child.frame;
        if ([child isKindOfClass:[UITableViewCell class]]) {
            frame1.size.width = self.frame.size.height;
            child.frame = frame1;
        }
    }
    
    
}*/


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSArray* visibleTableCellsIndexPaths=[self indexPathsForVisibleRows];
    for (NSIndexPath* aCellsIndex in visibleTableCellsIndexPaths)
    {
        UITableViewCell* cellForIndexPath=[self cellForRowAtIndexPath:aCellsIndex];
        CGFloat heightOfRow = [self.delegate tableView:self heightForRowAtIndexPath:aCellsIndex];
        CGRect frame = CGRectMake(cellForIndexPath.frame.origin.x,cellForIndexPath.frame.origin.y, self.frame.size.height, heightOfRow);
        cellForIndexPath.frame = frame;
    }
}
@end
