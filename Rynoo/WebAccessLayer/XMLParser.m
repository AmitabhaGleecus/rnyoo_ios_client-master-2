













//
//  XMLParser.m
//  Rnyoo
//
//  Created by Rnyoo on 17/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//












#import "XMLParser.h"

@implementation XMLParser{
    int count;
    NSMutableArray *contactsArray;
    BOOL isEntry;
    BOOL isTitle;
    NSMutableDictionary *tempData;
    NSString *tempElementName;

}

@synthesize parsedValue;

#pragma mark -
#pragma mark XMLParser Delegate methods
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    tempElementName = elementName;

    if ([elementName isEqualToString:@"entry"]) {
        isEntry = YES;
        
        if (!tempData) {
            tempData = [[NSMutableDictionary alloc] init];
        }
    }
    
    if ([elementName isEqualToString:@"title"]) {
        isTitle = YES;
    }
    if ([elementName isEqualToString:@"gd:email"] && isEntry) {
        
        [tempData setObject:[attributeDict objectForKey:@"address"] forKey:@"Email"];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if([tempElementName isEqualToString:@"title"])
    {
        parsedValue = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@",string]];
    }
    else
        parsedValue  = @"";
    
}

/* Parser delegate method to extract the elements from the response xml
 */
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qNam{
    
    if ([elementName isEqualToString:@"title"] && isEntry) {
        [tempData setObject:parsedValue forKey:@"Name"];
        parsedValue = @"";
        isTitle = NO;
    }
    
    if ([elementName isEqualToString:@"entry"]) {
        isEntry = NO;
        
        if (!contactsArray) {
            contactsArray = [[NSMutableArray alloc] init];
        }
        
        [contactsArray addObject:tempData];
        tempData = nil;
    }
}
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gmailContacts" object:contactsArray];

}

@end