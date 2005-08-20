//
//  SdefXMLObject.m
//  Sdef Editor
//
//  Created by Grayfox on 01/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefXMLBase.h"
#import "SdefXMLNode.h"
#import "SKExtensions.h"

#import "SdefComment.h"

@implementation SdefObject (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  id child = nil;
  id children = nil;
  node = [SdefXMLNode nodeWithElementName:[self xmlElementName]];
  NSAssert1(!node || ([node elementName] != nil), @"%@ return an invalid node", self);
  if (node && [node elementName]) {
    /* Comments */
    if (sd_comments)
      [node setComments:[self comments]];
    /* Hidden */
    if ([self isHidden]) {
      if (kSdefTigerVersion == version)
        [node setAttribute:@"yes" forKey:@"hidden"];
      else
        [node setAttribute:@"hidden" forKey:@"hidden"];
    }
    /* Children */
    children = [self childEnumerator];
    while (child = [children nextObject]) {
      id childNode = [child xmlNodeForVersion:version];
      if (childNode) {
        NSAssert1([childNode elementName] != nil, @"%@ return an invalid node", child);
        [node appendChild:childNode];
      }
    }
    if ([self hasIgnore]) {
      children = [[self ignores] reverseObjectEnumerator];
      while (child = [children nextObject]) {
        id childNode = [child xmlNodeForVersion:version];
        if (childNode) {
          NSAssert1([childNode elementName] != nil, @"%@ return an invalid node", child);
          [node prependChild:childNode];
        }
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return nil;
}

#pragma mark XML Parsing
- (id)initWithAttributes:(NSDictionary *)attributes {
  if (self = [self initWithName:nil]) {
    [self setAttributes:attributes];
    if (![self name]) { [self setName:[[self class] defaultName]]; }
  }
  return self;
}

- (void)setAttributes:(NSDictionary *)attrs {
  [self setName:[attrs objectForKey:@"name"]];
  
  NSString *hidden = [attrs objectForKey:@"hidden"];
  if (hidden && ![hidden isEqualToString:@"no"]) {
    [self setHidden:YES];
  }
}

- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserUnknownVersion;
}

@end

#pragma mark -
@implementation SdefCollection (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  if (![self hasChildren])
    return nil;
  
  if (kSdefPantherVersion == version) {
    return [super xmlNodeForVersion:version];
  } else if (kSdefTigerVersion == version) {
    SdefXMLNode *children = nil;
    SdefXMLNode *lastChild = nil;
    SdefObject *child;
    NSEnumerator *enume = [self childEnumerator];
    while (child = [enume nextObject]) {
      SdefXMLNode *node = [child xmlNodeForVersion:version];
      if (node) {
        if (!children) {
          children = node;
        } 
        /* Use last Child to keep object ordered */
        [lastChild insertSibling:node];
        lastChild = node;
      }
    }
    return children;
  }
  return nil;
}

- (NSString *)xmlElementName {
  return [self elementName];
}

#pragma mark XML Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  /* Do nothing */
}

- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserPantherVersion;
}

@end
