//
//  SdefXMLVerb.m
//  Sdef Editor
//
//  Created by Grayfox on 01/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefVerb.h"
#import "SdefSuite.h"
#import "SdefXMLNode.h"
#import "SdefXMLBase.h"
#import "SKExtensions.h"
#import "SdefArguments.h"

@implementation SdefVerb (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node;
  if (node = [super xmlNodeForVersion:version]) {
    id childNode;
    /* Insert before parameters */
    unsigned idx = [node childCount] - [self childCount];
    childNode = [[self directParameter] xmlNodeForVersion:version];
    if (nil != childNode) {
      [node insertChild:childNode atIndex:idx];
    }
    childNode = [[self result] xmlNodeForVersion:version];
    if (nil != childNode) {
      [node appendChild:childNode];
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
- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserBothVersion;
}

@end

@implementation SdefDirectParameter (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if ([self hasType] && (node = [super xmlNodeForVersion:version])) {
    [node removeAttributeForKey:@"name"];
    if ([self isOptional]) {
      if (kSdefTigerVersion == version) {
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

- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserBothVersion;
}

@end

@implementation SdefParameter (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node;
  if (node = [super xmlNodeForVersion:version]) {
    if ([self isOptional]) {
      if (kSdefTigerVersion == version) {
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
  id node = nil;
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

- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserBothVersion;
}

@end


