//
//  SdefTigerParser.m
//  Sdef Editor
//
//  Created by Grayfox on 03/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ShadowBase.h"
#import "SdefTigerParser.h"


@implementation SdefTigerParser

- (int)parserVersion {
  return kSdefParserTigerVersion;
}

#pragma mark Typedef
- (void)parser:(NSXMLParser *)parser didStartValueType:(NSDictionary *)attributes {
}

- (void)parser:(NSXMLParser *)parser didStartRecordType:(NSDictionary *)attributes {
}

- (void)parser:(NSXMLParser *)parser didStartType:(NSDictionary *)attributes {
  
}

#pragma mark Misc
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)element withAttributes:(NSDictionary *)attributes {
  SEL cmd = @selector(isEqualToString:);
  EqualIMP isEqual = (EqualIMP)[element methodForSelector:cmd];
  NSAssert(isEqual, @"Missing isEqualToStringMethod");
  
  if (isEqual(element, cmd, @"value-type")) {
    [self parser:parser didStartValueType:attributes];
  } else if (isEqual(element, cmd, @"record-type")) {
    [self parser:parser didStartRecordType:attributes];
  } else if (isEqual(element, cmd, @"type")) {
    [self parser:parser didStartType:attributes];
  } else {
    [super parser:parser didStartElement:element withAttributes:attributes];
  }
}

@end
