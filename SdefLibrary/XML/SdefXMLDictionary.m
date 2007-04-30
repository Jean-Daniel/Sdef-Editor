/*
 *  SdefXMLDictionary.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefDictionary.h"
#import "SdefSuite.h"
#import "SdefXMLNode.h"
#import "SdefXMLBase.h"

@implementation SdefDictionary (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if (node = [super xmlNodeForVersion:version]) {
    if ([self name]) [node setAttribute:[[self name] stringByEscapingEntities:nil] forKey:@"title"];
    switch (version) {
      case kSdefLeopardVersion: 
        //[node setMeta:@"10.5" forKey:@"version"];
        break;
      case kSdefTigerVersion: 
        [node setMeta:@"10.4" forKey:@"version"];
        break;
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"dictionary";
}

#pragma mark Parsing
- (void)setXMLMetas:(NSDictionary *)metas {
  NSString *version = [metas objectForKey:@"version"];
  if (version) {
    if ([version isEqualToString:@"10.4"])
      [self setVersion:kSdefTigerVersion];
  }
  [super setXMLMetas:metas];
}

- (void)setXMLAttributes:(NSDictionary *)attrs {
  [super setXMLAttributes:attrs];
  NSString *attr = [attrs objectForKey:@"title"];
  if (attr)
    [self setName:[attr stringByUnescapingEntities:nil]];
}

- (void)addXMLChild:(id<SdefObject>)child {
  switch ([child objectType]) {
    case kSdefSuiteType:
      [self appendChild:(SdefSuite *)child];
      break;
    default:
      [super addXMLChild:child];
      break;
  }
}

@end
