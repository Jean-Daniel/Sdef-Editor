//
//  SdefTigerParser.m
//  Sdef Editor
//
//  Created by Grayfox on 03/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ShadowBase.h"
#import "SdefTigerParser.h"

#import "SdefXMLBase.h"
#import "SdefType.h"
#import "SdefSuite.h"
#import "SdefTypedef.h"

@implementation SdefTigerParser

- (int)parserVersion {
  return kSdefParserTigerVersion;
}

#pragma mark Typedef
- (void)parser:(NSXMLParser *)parser didStartValueType:(NSDictionary *)attributes {
  SdefValue *value = [(SdefObject *)[SdefValue allocWithZone:[self zone]] initWithAttributes:attributes];
  [[(SdefSuite *)sd_parent types] appendChild:value];
  [value release];
  sd_node = value;
}

- (void)parser:(NSXMLParser *)parser didStartRecordType:(NSDictionary *)attributes {
  SdefRecord *record = [(SdefObject *)[SdefRecord allocWithZone:[self zone]] initWithAttributes:attributes];
  [[(SdefSuite *)sd_parent types] appendChild:record];
  [record release];
  sd_node = record;
}

- (void)parser:(NSXMLParser *)parser didStartType:(NSDictionary *)attributes {
  ShadowTrace();
  SdefType *type = [[SdefType allocWithZone:[self zone]] init];
  /* parse Attributes */ 
  [type release];
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

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)element {
  [super parser:parser didEndElement:element];
  while ([sd_node isKindOfClass:[SdefCollection class]]) {
    sd_node = [sd_node parent];
  }
}

@end
