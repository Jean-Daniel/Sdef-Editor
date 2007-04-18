/*
 *  SdefTigerParser.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefTigerParser.h"

#import "SdefXMLBase.h"
#import "SdefType.h"
#import "SdefSuite.h"
#import "SdefClass.h"
#import "SdefTypedef.h"
#import "SdefDictionary.h"
#import "SdefClassManager.h"

@implementation SdefTigerParser

- (SdefParserVersion)parserVersion {
  return kSdefParserTigerVersion;
}
- (SdefParserVersion)supportedVersions {
  return kSdefParserTigerVersion | kSdefParserLeopardVersion;
}

#pragma mark Collections
- (void)parser:(CFXMLParserRef)parser didStartEnumeration:(NSDictionary *)attributes {
  sd_node = [(SdefSuite *)sd_node types];
  [super parser:parser didStartEnumeration:attributes];
}

- (void)parser:(CFXMLParserRef)parser didStartClass:(NSDictionary *)attributes {
  sd_node = [sd_node classes];
  [super parser:parser didStartClass:attributes];
}

- (void)parser:(CFXMLParserRef)parser didStartClassExtension:(NSDictionary *)attributes {
  NSAssert([sd_node isKindOfClass:[SdefSuite class]], @"sd_node should be a suite");
  sd_node = [sd_node classes];
  if (sd_node) {
    SdefClass *class = [(SdefObject *)[SdefClass allocWithZone:[self zone]] initWithAttributes:attributes];
    [class setExtension:YES];
    [sd_node appendChild:class];
    [class release];
    sd_node = class;
  }
}

- (void)parser:(CFXMLParserRef)parser didStartCommand:(NSDictionary *)attributes {
  sd_node = [(SdefSuite *)sd_node commands];
  [super parser:parser didStartCommand:attributes];
}

- (void)parser:(CFXMLParserRef)parser didStartEvent:(NSDictionary *)attributes {
  sd_node = [sd_node events];
  [super parser:parser didStartEvent:attributes];
}

- (void)parser:(CFXMLParserRef)parser didStartElement:(NSDictionary *)attributes {
  sd_node = [(SdefClass *)sd_node elements];
  [super parser:parser didStartElement:attributes];
}

- (void)parser:(CFXMLParserRef)parser didStartProperty:(NSDictionary *)attributes {
  if ([sd_node respondsToSelector:@selector(properties)]) 
    sd_node = [(SdefClass *)sd_node properties];
  [super parser:parser didStartProperty:attributes];
}

- (void)parser:(CFXMLParserRef)parser didStartRespondsTo:(NSDictionary *)attributes {
  sd_node = [(SdefClass *)sd_node commands];
  [super parser:parser didStartRespondsTo:attributes];
}

#pragma mark Typedef
- (void)parser:(CFXMLParserRef)parser didStartValueType:(NSDictionary *)attributes {
  SdefValue *value = [(SdefObject *)[SdefValue allocWithZone:[self zone]] initWithAttributes:attributes];
  [[(SdefSuite *)sd_node types] appendChild:value];
  [value release];
  sd_node = value;
}

- (void)parser:(CFXMLParserRef)parser didStartRecordType:(NSDictionary *)attributes {
  if (![sd_node respondsToSelector:@selector(types)]) {
    CFStringRef str = CFStringCreateWithFormat(kCFAllocatorDefault, nil, CFSTR("Unexpected \"record\" element found at line %i"),
                                               CFXMLParserGetLineNumber(parser));
    CFXMLParserAbort(parser, kCFXMLErrorMalformedDocument, str);
    CFRelease(str);
  } else {
    SdefRecord *record = [(SdefObject *)[SdefRecord allocWithZone:[self zone]] initWithAttributes:attributes];
    [[(SdefSuite *)sd_node types] appendChild:record];
    [record release];
    sd_node = record;
  }
}

- (void)parser:(CFXMLParserRef)parser didStartType:(NSDictionary *)attributes {
  SdefType *type = [[SdefType allocWithZone:[self zone]] init];
  /* parse Attributes */
  NSString *attr = [attributes objectForKey:@"list"];
  if (attr && ![attr isEqualToString:@"no"]) {
    [type setList:YES];
  }
  attr = [attributes objectForKey:@"type"];
  if (attr) {
    [type setName:attr];
    
    if ([sd_node respondsToSelector:@selector(addType:)]) {
      [sd_node addType:type];
    } else if ([sd_node respondsToSelector:@selector(setType:)]) {
      [sd_node performSelector:@selector(setType:) withObject:[type name]];
    } else {
      switch ([self shouldAddInvalidObject:type inNode:sd_node]) {
        case kSdefParserAbort: {
          CFStringRef str = CFStringCreateWithFormat(kCFAllocatorDefault, nil, CFSTR("Unexpected \"type\" element found at line %i"),
                                                     CFXMLParserGetLineNumber(parser));
          CFXMLParserAbort(parser, kCFXMLErrorMalformedDocument, str);
          CFRelease(str);
          break;
        }
        case kSdefParserAddNode:
          [sd_node addIgnore:type];
          break;
        case kSdefParserDeleteNode:
        default:
          break;
      }
    }
  } 
  [type release];
}

#pragma mark Misc
- (void)parser:(CFXMLParserRef)parser didStartElement:(NSString *)element withAttributes:(NSDictionary *)attributes {
  SEL cmd = @selector(isEqualToString:);
  EqualIMP isEqual = (EqualIMP)[element methodForSelector:cmd];
  NSAssert(isEqual, @"Missing isEqualToStringMethod");
  
  if (isEqual(element, cmd, @"value-type")) {
    [self parser:parser didStartValueType:attributes];
  } else if (isEqual(element, cmd, @"record-type")) {
    [self parser:parser didStartRecordType:attributes];
  } else if (isEqual(element, cmd, @"type")) {
    [self parser:parser didStartType:attributes];
  } else if (isEqual(element, cmd, @"class-extension")) {
    [self parser:parser didStartClassExtension:attributes];
  } else {
    [super parser:parser didStartElement:element withAttributes:attributes];
  }
}

- (void)parser:(CFXMLParserRef)parser didEndElement:(NSString *)element {
  [super parser:parser didEndElement:element];
  if ([sd_node isKindOfClass:[SdefCollection class]]) {
    sd_node = [sd_node parent];
  }
}

- (void)parserDidEndDocument:(CFXMLParserRef)parser {
  SdefSuite *suite;
  NSEnumerator *suites = [[self document] childEnumerator];
  while (suite = [suites nextObject]) {
    SdefClass *class;
    NSEnumerator *classes = [[suite classes] childEnumerator];
    while (class = [classes nextObject]) {
      SdefRespondsTo *cmd;
      NSEnumerator *cmds = [[class commands] childEnumerator];
      while (cmd = [cmds nextObject]) {
        if ([[cmd classManager] eventWithName:[cmd name]] != nil) {
          [cmd retain];
          [cmd remove];
          [[class events] appendChild:cmd];
          [cmd release];
        }
      }
    }
  }
}

@end
