/*
 *  SdefXMLObject.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXMLBase.h"
#import "SdefXMLNode.h"
#import WBHEADER(WBExtensions.h)

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
    
    /* xincludes */
    if ([self containsXInclude] > 0) {
      NSArray *xincludes = [self xincludes];
      for (NSUInteger idx = 0; idx < [xincludes count]; idx++) {
        SdefXMLNode *xnode = [[xincludes objectAtIndex:idx] xmlNodeForVersion:version];
        if (xnode)
          [node appendChild:xnode];
      }
    }
    
    /* Children */
    SdefObject *child = nil;
    NSEnumerator *children = [self childEnumerator];
    while (child = [children nextObject]) {
      if (![child isXIncluded]) {
        SdefXMLNode *childNode = [child xmlNodeForVersion:version];
        if (childNode) {
          NSAssert1([childNode isList] || [childNode elementName], @"%@ return an invalid node", child);
          [node appendChild:childNode];
        }
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  [NSException raise:NSInternalInconsistencyException format:@"the mehod %@ must be overriden", NSStringFromSelector(_cmd)];
  return nil;
}

#pragma mark XML Parsing
- (void)addXMLChild:(id<SdefObject>)child {
  switch ([child objectType]) {
    case kSdefXIncludeType:
      [self addXInclude:child];
      break;
    default:
      [NSException raise:NSInternalInconsistencyException format:@"%@ must overrided %@ to support %@ ", 
        [self class], NSStringFromSelector(_cmd), child];
      break;
  }
}
- (void)addXMLComment:(NSString *)comment {
  [self addComment:[SdefComment commentWithString:comment]];
}

- (void)setXMLMetas:(NSDictionary *)metas {
  //DLog(@"Metas: %@, %@", self, metas);
}
- (void)setXMLAttributes:(NSDictionary *)attrs {
  NSString *attr = [attrs objectForKey:@"name"];
  if (attr)
    [self setName:[attr stringByUnescapingEntities:nil]];
  
  attr = [attrs objectForKey:@"hidden"];
  if (attr && ![attr isEqualToString:@"no"]) {
    [self setHidden:YES];
  }
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

