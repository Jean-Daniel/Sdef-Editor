/*
 *  SdefXMLLeaves.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXMLNode.h"
#import "SdefXMLBase.h"

@implementation SdefLeaf (SdefXMLManager)

#pragma mark XML Generation
- (NSString *)xmlElementName {
  return nil;
}
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node;
  if (node = [[SdefXMLNode alloc] initWithElementName:[self xmlElementName]]) {
    /* Hidden */
    if ([self isHidden]) {
      if (version >= kSdefTigerVersion)
        [node setAttribute:@"yes" forKey:@"hidden"];
      else
        [node setAttribute:@"hidden" forKey:@"hidden"];
    }
    
    [node autorelease];
  }
  return node;
}

#pragma mark Parsing
- (void)setXMLAttributes:(NSDictionary *)attrs {
  NSString *hidden = [attrs objectForKey:@"hidden"];
  if (hidden && ![hidden isEqualToString:@"no"]) {
    [self setHidden:YES];
  }
}

@end

@implementation SdefSynonym (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"synonym";
}

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node;
  if (node = [super xmlNodeForVersion:version]) {
    /* Code */
    NSString *attr = [self code];
    if (attr) [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"code"];
    /* Name */
    attr = [self name];
    if (attr) [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"name"];

    /* Implementation */
    if (sd_impl) {
      SdefXMLNode *implNode = [sd_impl xmlNodeForVersion:version];
      if (implNode) {
        [node prependChild:implNode];
      }
    }
    [node setEmpty:![node hasChildren]];
  }
  return [node attributeCount] > 0 ? node : nil;
}

#pragma mark Parsing
- (void)setXMLAttributes:(NSDictionary *)attrs {
  [super setXMLAttributes:attrs];
  NSString *attr = [attrs objectForKey:@"name"];
  if (attr)
    [self setName:[attr stringByUnescapingEntities:nil]];
  
  attr = [attrs objectForKey:@"code"];
  if (attr)
    [self setName:[attr stringByUnescapingEntities:nil]];
  [self setCode:[attr stringByUnescapingEntities:nil]];
}

@end

#pragma mark -
@implementation SdefXRef (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"xref";
}
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if ([self target] && version >= kSdefLeopardVersion) {
    if (node = [super xmlNodeForVersion:version]) {
      [node setEmpty:YES];
      /* Code */
      NSString *attr = [self target];
      if (attr) [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"target"];
    }
  }
  return node;
}

#pragma mark Parsing
- (void)setXMLAttributes:(NSDictionary *)attrs {
  [super setXMLAttributes:attrs];
  NSString *attr = [attrs objectForKey:@"target"];
  if (attr)
    [self setTarget:[attr stringByUnescapingEntities:nil]];
}

@end

#pragma mark -
@implementation SdefType (SdefXMLManager)
- (NSString *)xmlElementName {
  return @"type";
}

#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if ([self name] && version >= kSdefTigerVersion) {
    if (node = [super xmlNodeForVersion:version]) {
      [node setEmpty:YES];
      [node setAttribute:[[self name] stringByEscapingEntities:nil] forKey:@"type"];
      if ([self isList]) {
        [node setAttribute:@"yes" forKey:@"list"];
      }
    }
  }
  return node;
}

- (void)setXMLAttributes:(NSDictionary *)attrs {
  NSString *attr = [attrs objectForKey:@"type"];
  if (attr)
    [self setName:[attr stringByUnescapingEntities:nil]];
  
  attr = [attrs objectForKey:@"list"];
  if (attr && ![attr isEqualToString:@"no"]) {
    [self setList:YES];
  }
}

@end
