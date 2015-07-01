//
//  InviteFriendsListViewController.m
//  Rynoo
//
//  Created by Rnyoo on 13/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "InviteFriendsListViewController.h"
#import "InviteFriendTableViewCell.h"
#import <FacebookSDK/FacebookSDK.h>

@interface InviteFriendsListViewController ()
{
    BOOL isSelectAllButtonSelected;
    UIButton *selectButton;
    UILabel  *selectLabel;

}
@end

@implementation InviteFriendsListViewController

@synthesize isGmailContacts;

# pragma mark view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!isGmailContacts)
    {
        contactsArray  = [self getAllPhoneContacts];
        if([contactsArray count] > 0)
              [_tblFriendsList reloadData];
    }
    
    if ([_tblFriendsList respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tblFriendsList setSeparatorInset:UIEdgeInsetsZero];
    }
    _tblFriendsList.separatorColor = [UIColor grayColor];
    _tblFriendsList.allowsMultipleSelection = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setNavigationBarTitle:@"Address Book"];
    [self setLeftBarButtonOnNavigationBarAsBackButton];
}

-(void)viewDidLayoutSubviews
{
    if ([_tblFriendsList respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tblFriendsList setSeparatorInset:UIEdgeInsetsZero];
    }
}

/* Preparing array with the required data */

-(void)setGmailContactsWithArray:(NSMutableArray *)array
{
    contactsArray  =[[NSMutableArray alloc]init];
    for(NSDictionary *dict in array)
    {
        if([(NSString *)[dict valueForKey:@"Email"] length])//add contact if email exists  (if mobile contacts sync to gmail)
        {
            NSMutableDictionary *contactDict = [[NSMutableDictionary alloc]init];
            [contactDict setObject:@"NO" forKey:@"isSelected"];
            [contactDict setObject:[dict valueForKey:@"Email"] forKey:@"contactEmail"];
            
            if([(NSString *)[dict valueForKey:@"Name"] length])
            {
                [contactDict setObject:[dict valueForKey:@"Name"] forKey:@"contactName"];
            }
            else
            {
                NSArray *myArray = [[dict valueForKey:@"Email"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
                if([[myArray objectAtIndex:0] length])
                    [contactDict setObject:[myArray objectAtIndex:0] forKey:@"contactName"];
                else
                {
                    [contactDict setObject:@"" forKey:@"contactName"];
                }
            }
            
            [contactsArray addObject:contactDict];
        }
    }
    
}


/* SelectAllContacts button action */


-(void)selectAllContacts:(id)sender
{
    isSelectAllButtonSelected = (!isSelectAllButtonSelected);
    [_tblFriendsList reloadData];
}

/* getting FB friends */

-(void)getFBFriends
{
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        
        RLogs(@"FB result - %@", [result description]);
        
        NSArray* friends = [result objectForKey:@"data"];
        RLogs(@"Found: %lu friends", (unsigned long)friends.count);
        
        if(!error)
        {
            [self gotFBFriends:friends];
        }
        else
        {
            [self errorWhileGettingFBFriends];
        }
        
    }];
}

-(void)gotFBFriends:(NSArray *)freinds
{
    RLogs(@"%lu",(unsigned long)[freinds count]);
}

/* error while getting FB Friends*/


-(void)errorWhileGettingFBFriends
{
    RLogs(@"error while getting FBFreinds ");
}

#pragma mark --
#pragma mark  TableView Delegate and Datasource Methods.
#pragma mark --

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([contactsArray count] > 0)
        return 1;
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [contactsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"ContactCell";
    
    InviteFriendTableViewCell *cell=(InviteFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        cell = [[InviteFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *contactDict = [contactsArray objectAtIndex:indexPath.row];
    cell.contactName.text = [[contactDict valueForKey:@"contactName"] uppercaseString];
    
    if(!isGmailContacts)
       cell.contactNumber.text  = [contactDict valueForKey:@"phoneNumber"];
    else
    {
       cell.contactName.frame =  CGRectMake(25, 9, 250, 20);
    }
    
    if(isSelectAllButtonSelected){
        cell.radioButtonImageview.image = [UIImage imageNamed:@"checked.png"];
        [[contactsArray objectAtIndex:indexPath.row] setObject:@"YES" forKey:@"isSelected"];

    }
    else{
        cell.radioButtonImageview.image = [UIImage imageNamed:@"unchecked.png"];
        [[contactsArray objectAtIndex:indexPath.row] setObject:@"NO" forKey:@"isSelected"];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    InviteFriendTableViewCell *cell = (InviteFriendTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dict = [contactsArray objectAtIndex:indexPath.row];
    if([[dict objectForKey:@"isSelected"] isEqualToString:@"YES"]){
        cell.radioButtonImageview.image = [UIImage imageNamed:@"unchecked.png"];
        [[contactsArray objectAtIndex:indexPath.row] setObject:@"NO" forKey:@"isSelected"];
    }
    else{
        cell.radioButtonImageview.image = [UIImage imageNamed:@"checked.png"];
        [[contactsArray objectAtIndex:indexPath.row] setObject:@"YES" forKey:@"isSelected"];
    }
    [selectButton setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
     isSelectAllButtonSelected  =NO;
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{

    InviteFriendTableViewCell *cell = (InviteFriendTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dict = [contactsArray objectAtIndex:indexPath.row];

    if([[dict objectForKey:@"isSelected"] isEqualToString:@"YES"]){
        cell.radioButtonImageview.image = [UIImage imageNamed:@"unchecked.png"];
        [[contactsArray objectAtIndex:indexPath.row] setObject:@"NO" forKey:@"isSelected"];
        
    }
    else{
        cell.radioButtonImageview.image = [UIImage imageNamed:@"checked.png"];
        [[contactsArray objectAtIndex:indexPath.row] setObject:@"YES" forKey:@"isSelected"];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(isGmailContacts)
        return 40.0;
    return 53.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]init];
    [headerView setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];

    selectButton = [UIButton buttonWithType:UIButtonTypeCustom];

    selectLabel = [[UILabel alloc] init];
    selectLabel.textColor=[UIColor redColor];
    selectLabel.text = @"Select All";
    selectLabel.font = [Util Font:FontTypeLight Size:13.0];
    selectLabel.backgroundColor = [UIColor clearColor];
    selectLabel.textAlignment = NSTextAlignmentLeft;
    
    if(APP_DELEGATE.isPortrait){
        selectButton.frame  =CGRectMake(285, 5, 20, 20);
        selectLabel.frame = CGRectMake(225, 5, 60,20);
        self.topTableConstraint.constant = 64;
    }
    else{
        self.topTableConstraint.constant = 34;
        selectButton.frame  =CGRectMake(self.view.frame.size.width-35, 5, 20, 20);
        selectLabel.frame = CGRectMake(self.view.frame.size.width-95, 5, 60,20);
    }

    if(isSelectAllButtonSelected)
      [selectButton setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
    else
      [selectButton setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];

    [selectButton addTarget:self action:@selector(selectAllContacts:) forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:selectLabel];
    [headerView addSubview:selectButton];
    
    
    
    return headerView;
    
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

/* Update Constraints */

-(void)updateViewConstraints
{
    
    [super updateViewConstraints];

    if(APP_DELEGATE.isPortrait){
        selectButton.frame  =CGRectMake(285, 5, 20, 20);
        selectLabel.frame = CGRectMake(225, 5, 60,20);
        self.topTableConstraint.constant = 64;
    }
    else{
        self.topTableConstraint.constant = 34;
        selectButton.frame  =CGRectMake(self.view.frame.size.width-35, 5, 20, 20);
        selectLabel.frame = CGRectMake(self.view.frame.size.width-95, 5, 60,20);
    }
}



- (NSMutableArray *)getAllPhoneContacts
{
    
    CFErrorRef *error = nil;

    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
#ifdef DEBUG
        RLogs(@"Fetching contact info ----> ");
#endif
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        NSMutableArray* list = [NSMutableArray arrayWithCapacity:nPeople];
        
        if(CFArrayGetCount(allPeople))
        {
        
        for (int i = 0; i < nPeople; i++)
        {
            
            if(i < CFArrayGetCount(allPeople))
            {
                
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            
            NSString *contactName = @"", *contactNumber = @"";
            
            NSString *contactFirstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            
            NSString *contactLastName =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            if (!contactFirstName) {
                contactFirstName = @"";
            }
            if (!contactLastName) {
                contactLastName = @"";
            }
            contactName = [NSString stringWithFormat:@"%@ %@", contactFirstName,contactLastName];
            NSMutableDictionary *contactDict = [[NSMutableDictionary alloc]init];
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                [phoneNumbers addObject:phoneNumber];
                
                if(phoneNumber.length > 0){
                    contactNumber = phoneNumber;
                    break;
                }
                
            }
            [contactDict setObject:contactName forKey:@"contactName"];
            [contactDict setObject:contactNumber forKey:@"phoneNumber"];
            [contactDict setObject:@"NO" forKey:@"isSelected"];
            
            [list addObject:contactDict];
            }
            
        }
        return list;
        }
        else
            return nil;
        
    } else {
#ifdef DEBUG
        RLogs(@"Cannot fetch Contacts :( ");
#endif
        return nil;
        
    }
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/* Navigation to home screen*/

- (IBAction)sendInvitesClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
