/*
 *  SdefXMLDictionary.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
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
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"dictionary";
}

#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setName:[[attrs objectForKey:@"title"] stringByUnescapingEntities:nil]];
}

- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  return kSdefParserAllVersions;
}


@end
