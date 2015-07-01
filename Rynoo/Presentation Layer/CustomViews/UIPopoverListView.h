//
//  UIPopoverListView.h
//  UIPopoverListViewDemo
//
//  Created by Rnyoo on 25/11/14.
//  Copyright (c) 2014 RNyoo All rights reserved.

//

#import <UIKit/UIKit.h>

@class UIPopoverListView;

@protocol UIPopoverListViewDataSource <NSObject>
@required

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section;

@end

@protocol UIPopoverListViewDelegate <NSObject>
@optional

- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath;

- (void)popoverListViewCancel:(UIPopoverListView *)popoverListView;

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface UIPopoverListView : UIView <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_listView;
    UILabel     *_titleView;
    UIControl   *_overlayView;
    id<UIPopoverListViewDataSource> datasource;
    id<UIPopoverListViewDelegate>   delegate;
    
}

@property (nonatomic, assign) id<UIPopoverListViewDataSource> datasource;
@property (nonatomic, assign) id<UIPopoverListViewDelegate>   delegate;
@property (nonatomic, retain) UITableView *listView;
@property(nonatomic,strong)UILabel     *_titleView;

- (void)setTitle:(NSString *)title;
- (void)show;
- (void)dismiss;
-(void)setListFrame;
- (void)showInView:(UIView*)view;

@end
