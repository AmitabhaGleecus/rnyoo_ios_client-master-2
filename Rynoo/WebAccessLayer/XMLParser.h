
//
//  XMLParser.h
//  Rnyoo
//
//  Created by Rnyoo on 17/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLParser : NSXMLParser<NSXMLParserDelegate>
{
    
}
@property(nonatomic, strong) NSString *parsedValue;
@end
