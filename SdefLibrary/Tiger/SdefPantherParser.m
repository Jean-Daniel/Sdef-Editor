/*
 *  SdefPantherParser.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefPantherParser.h"

#import "SdefType.h"
#import "SdefClass.h"
#import "SdefDictionary.h"
#import "SdefImplementation.h"

@implementation SdefPantherParser

- (int)parserVersion {
  return kSdefParserPantherVersion;
}

- (void)parser:(CFXMLParserRef)parser didStartCollection:(NSString *)collection withAttributes:(NSDictionary *)attributes {
  SEL key = nil;
  if ([collection isEqualToString:@"responds-to-commands"]) key = @selector(commands);
  else if ([collection isEqualToString:@"responds-to-events"]) key = @selector(events);
  else key = NSSelectorFromString(collection);
  NSAssert2([sd_node respondsToSelector:key], @"%@ should responds to %@", NSStringFromClass([sd_node class]), NSStringFromSelector(key));
  sd_node = [sd_node performSelector:key];
}

#pragma mark Misc
- (void)parser:(CFXMLParserRef)parser didEndElement:(NSString *)element {
  if (![element isEqualToString:@"synonyms"]) {
    [super parser:parser didEndElement:element];
  }
}

- (void)parser:(CFXMLParserRef)parser didStartElement:(NSString *)element withAttributes:(NSDictionary *)attributes {
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
  } else if (!isEqual(element, cmd, @"synonyms")) {
    [super parser:parser didStartElement:element withAttributes:attributes];
  }
}

/* Convert old base types */
- (void)parserDidEndDocument:(CFXMLParserRef)parser {
  NSEnumerator *children = [[self document] deepEnumerator];
  id child;
  while (child = [children nextObject]) {
    if ([child isKindOfClass:[SdefTypedObject class]]) {
      unsigned idx = 0;
      NSArray *types = [child types];
      for (idx=0; idx<[types count]; idx++) {
        SdefType *type = [types objectAtIndex:idx];
        if ([[type name] isEqualToString:@"string"]) {
          [type setName:@"text"];
        } else if ([[type name] isEqualToString:@"object"]) {
          [type setName:@"specifier"];
        } else if ([[type name] isEqualToString:@"location"]) {
          [type setName:@"location specifier"];
        }
      }
    } else if ([child isKindOfClass:[SdefProperty class]] || 
               [child isKindOfClass:[SdefElement class]]) {
      NSString *method = [[child impl] method];
      if (method) {
        [[child impl] setKey:method];
        [[child impl] setMethod:nil];
      }
    }
  }
}

@end
