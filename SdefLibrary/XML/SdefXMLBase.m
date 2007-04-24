/*
 *  SdefXMLObject.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXMLBase.h"
#import "SdefXMLNode.h"
#import <ShadowKit/SKExtensions.h>

#import "SdefComment.h"

@implementation SdefObject (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = [SdefXMLNode nodeWithElementName:[self xmlElementName]];
  NSAssert1(!node || ([node elementName] != nil), @"%@ return an invalid node", self);
  if (node && [node elementName]) {
    /* Comments */
    if (sd_comments)
      [node setComments:[self comments]];
    /* Hidden */
    if ([self isHidden]) {
      if (version >= kSdefTigerVersion)
        [node setAttribute:@"yes" forKey:@"hidden"];
      else
        [node setAttribute:@"hidden" forKey:@"hidden"];
    }
    /* Children */
    SdefObject *child = nil;
    NSEnumerator *children = [self childEnumerator];
    while (child = [children nextObject]) {
      SdefXMLNode *childNode = [child xmlNodeForVersion:version];
      if (childNode) {
        NSAssert1([childNode isList] || [childNode elementName], @"%@ return an invalid node", child);
        [node appendChild:childNode];
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return nil;
}

#pragma mark XML Parsing
- (void)setXMLAttributes:(NSDictionary *)attrs {
  NSString *attr = [attrs objectForKey:@"name"];
  if (attr)
    [self setName:[attr stringByUnescapingEntities:nil]];
  
  attr = [attrs objectForKey:@"hidden"];
  if (attr && ![attr isEqualToString:@"no"]) {
    [self setHidden:YES];
  }
}

- (void)addXMLChild:(id<SdefObject>)node {
  [NSException raise:NSInternalInconsistencyException format:@"%@ must overrided %@ to support %@ ", 
    [self class], NSStringFromSelector(_cmd), node];
}

@end

#pragma mark -
@implementation SdefCollection (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  if (![self hasChildren])
    return nil;
  
  SdefXMLNode *node = [super xmlNodeForVersion:version];
  if (version >= kSdefTigerVersion)
    [node setList:YES];
  /*
  if (kSdefPantherVersion == version) {
    return [super xmlNodeForVersion:version];
  } else if (version >= kSdefTigerVersion) {
    SdefXMLNode *list = [[SdefXMLNode alloc] initWithElementName:nil];
    [list setList:YES];
    SdefObject *child = nil;
    NSEnumerator *children = [self childEnumerator];
    while (child = [children nextObject]) {
      SdefXMLNode *node = [child xmlNodeForVersion:version];
      if (node) {
        [list appendChild:node];
      }
    }
    return list;
  }
   */
  return node;
}

- (NSString *)xmlElementName {
  return [self elementName];
}

#pragma mark XML Parsing
- (void)setXMLAttributes:(NSDictionary *)attrs {
  /* Do nothing */
}

@end
