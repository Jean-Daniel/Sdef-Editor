//
//  SdefPantherParser.m
//  Sdef Editor
//
//  Created by Grayfox on 03/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ShadowBase.h"

#import "SdefPantherParser.h"

@implementation SdefPantherParser

- (int)parserVersion {
  return kSdefParserPantherVersion;
}

- (void)parser:(NSXMLParser *)parser didStartCollection:(NSString *)collection withAttributes:(NSDictionary *)attributes {
  SEL key = nil;
  if ([collection isEqualToString:@"responds-to-commands"]) key = @selector(commands);
  else if ([collection isEqualToString:@"responds-to-events"]) key = @selector(events);
  else key = NSSelectorFromString(collection);
  NSAssert2([sd_parent respondsToSelector:key], @"%@ should responds to %@", NSStringFromClass([sd_parent class]), NSStringFromSelector(key));
  sd_node = [sd_parent performSelector:key];
}

#pragma mark Misc
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)element withAttributes:(NSDictionary *)attributes {
  SEL cmd = @selector(isEqualToString:);
  EqualIMP isEqual = (EqualIMP)[element methodForSelector:cmd];
  NSAssert(isEqual, @"Missing isEqualToStringMethod");
  
  if (isEqual(element, cmd, @"types") ||
      isEqual(element, cmd, @"classes") ||
      isEqual(element, cmd, @"commands") ||
      isEqual(element, cmd, @"events") ||
      isEqual(element, cmd, @"elements") ||
      isEqual(element, cmd, @"properties") ||
      isEqual(element, cmd, @"responds-to-commands") ||
      isEqual(element, cmd, @"responds-to-events")) {
    [self parser:parser didStartCollection:element withAttributes:attributes];
  } else {
    [super parser:parser didStartElement:element withAttributes:attributes];
  }
}

@end
