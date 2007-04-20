/*
 *  SdefXMLVerb.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefVerb.h"
#import "SdefSuite.h"
#import "SdefXMLNode.h"
#import "SdefXMLBase.h"
#import <ShadowKit/SKExtensions.h>
#import "SdefArguments.h"

@implementation SdefVerb (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node;
  if (node = [super xmlNodeForVersion:version]) {
    SdefXMLNode *childNode;
    /* Insert before parameters */
    NSUInteger idx = [node count] - [self count];
    childNode = [[self directParameter] xmlNodeForVersion:version];
    if (childNode) {
      [node insertChild:childNode atIndex:idx];
    }
    childNode = [[self result] xmlNodeForVersion:version];
    if (childNode) {
      [node appendChild:childNode];
    }
    if (version >= kSdefLeopardVersion) {
      NSString *attr = [self xmlid];
      if (attr) {
        [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"id"];
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  SdefSuite *suite = [self suite];
  if ([self parent] == [suite commands]) {
    return @"command";
  } else if ([self parent] == [suite events])
    return @"event"; 
  return nil;
}

#pragma mark -
#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setXmlid:[[attrs objectForKey:@"id"] stringByUnescapingEntities:nil]];
}

- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  return kSdefParserAllVersions;
}

@end

@implementation SdefDirectParameter (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if ([self hasType] && (node = [super xmlNodeForVersion:version])) {
    [node removeAttributeForKey:@"name"];
    if ([self isOptional]) {
      if (version >= kSdefTigerVersion) {
        [node setAttribute:@"yes" forKey:@"optional"];
      } else {
        [node setAttribute:@"optional" forKey:@"optional"];
      }
    }
    [node setEmpty:YES];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"direct-parameter";
}

#pragma mark -
#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  NSString *optional = [attrs objectForKey:@"optional"];
  if (optional && ![optional isEqualToString:@"no"]) {
    [self setOptional:YES];
  }
}

- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  return kSdefParserAllVersions;
}

@end

@implementation SdefParameter (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node;
  if (node = [super xmlNodeForVersion:version]) {
    if ([self isOptional]) {
      if (version >= kSdefTigerVersion) {
        [node setAttribute:@"yes" forKey:@"optional"];
      } else {
        [node setAttribute:@"optional" forKey:@"optional"];
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"parameter";
}

#pragma mark -
#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];

  NSString *optional = [attrs objectForKey:@"optional"];
  if (optional && ![optional isEqualToString:@"no"]) {
    [self setOptional:YES];
  }
}

@end

@implementation SdefResult (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if ([self hasType] && (node = [super xmlNodeForVersion:version])) {
    [node removeAttributeForKey:@"name"];
    [node setEmpty:YES];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"result";
}

#pragma mark -
#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
}

- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  return kSdefParserAllVersions;
}

@end


