/*
 *  SdefXMLEnumeration.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefTypedef.h"
#import "SdefImplementation.h"

#import "SdefXMLNode.h"
#import "SdefXMLBase.h"

@implementation SdefEnumeration (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"enumeration";
}

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node;
  if (node = [super xmlNodeForVersion:version]) {
    if (version >= kSdefTigerVersion && [self inlineValue] != kSdefInlineAll)
      [node setAttribute:[NSString stringWithFormat:@"%li", (long)[self inlineValue]] forKey:@"inline"];
  }
  return node;
}


#pragma mark Parsing
- (void)setXMLAttributes:(NSDictionary *)attrs {
  [super setXMLAttributes:attrs];
  NSString *value = [attrs objectForKey:@"inline"];
  if (value) {
    [self setInlineValue:[value integerValue]];
  } else {
    [self setInlineValue:kSdefInlineAll];
  }
}

- (void)addXMLChild:(id<SdefObject>)child {
  switch ([child objectType]) {
    case kSdefEnumeratorType:
      [self appendChild:(SdefEnumerator *)child];
      break;
    default:
      [super addXMLChild:child];
      break;
  }
}

@end

#pragma mark -
@implementation SdefEnumerator (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node;
  if (node = [super xmlNodeForVersion:version]) {
    /* cocoa *-value */
    if ([[self impl] valueType] != kSdefValueTypeNone) {
      if (version < kSdefLeopardVersion) {
        switch ([[self impl] valueType]) {
          case kSdefValueTypeString:
            [node setPostMeta:[[[self impl] textValue] stringByEscapingEntities:nil] forKey:@"string-value"];
            break;
          case kSdefValueTypeInteger:
            [node setPostMeta:[NSString stringWithFormat:@"%ld", (long)[[self impl] integerValue]] forKey:@"integer-value"];
            break;
          case kSdefValueTypeBoolean:
            [node setPostMeta:[[self impl] booleanValue] ? @"YES" : @"NO" forKey:@"boolean-value"];
            break;
        }
      }
    }
  } 
  return node;
}

- (NSString *)xmlElementName {
  return @"enumerator";
}

#pragma mark Parser
- (void)setXMLMetas:(NSDictionary *)metas {
  [[self impl] setXMLMetas:metas];
  [super setXMLMetas:metas];
}

@end

#pragma mark -
@implementation SdefValue (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  return (version >= kSdefTigerVersion) ? [super xmlNodeForVersion:version] : nil;
}

- (NSString *)xmlElementName {
  return @"value-type";
}

@end

#pragma mark -
@implementation SdefRecord (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  return (version >= kSdefTigerVersion) ? [super xmlNodeForVersion:version] : nil;
}

- (NSString *)xmlElementName {
  return @"record-type";
}

- (void)addXMLChild:(id<SdefObject>)child {
  switch ([child objectType]) {
    case kSdefPropertyType:
      [self appendChild:(SdefProperty *)child];
      break;
    default:
      [super addXMLChild:child];
      break;
  }
}

@end
