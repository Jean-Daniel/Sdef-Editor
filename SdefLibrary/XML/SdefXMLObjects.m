//
//  SdefXMLObjects.m
//  Sdef Editor
//
//  Created by Grayfox on 09/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefXMLBase.h"
#import "SdefXMLNode.h"
#import "SdefObjects.h"
#import "SKExtensions.h"
#import "SdefDocumentation.h"
#import "SdefImplementation.h"

@implementation SdefDocumentedObject (SdefXMLManager)

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if (node = [super xmlNodeForVersion:version]) {
    if ([self hasDocumentation]) {
      id documentation = [sd_documentation xmlNodeForVersion:version];
      if (nil != documentation) {
        [node prependChild:documentation];
      }
    }
    [node setEmpty:![node hasChildren]];
  }
  return node;
}

@end

#pragma mark -
@implementation SdefImplementedObject (SdefXMLManager)

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if (node = [super xmlNodeForVersion:version]) {
    if (sd_impl) {
      BOOL swap = NO;
      /* Key and method was change for Property and Element*/
      if (kSdefPantherVersion == version) {
        if ([self objectType] == kSdefPropertyType || [self objectType] == kSdefElementType) {
          [sd_impl setMethod:[sd_impl key]];
          [sd_impl setKey:nil];
          swap = YES;
        }
      }
      SdefXMLNode *impl = [[self impl] xmlNodeForVersion:version];
      if (nil != impl) {
        if ([[[node firstChild] elementName] isEqualToString:@"documentation"]) {
          [node insertChild:impl atIndex:1];
        } else {
          [node prependChild:impl];
        }
      }
      if (swap) {
        [sd_impl setKey:[sd_impl method]];
        [sd_impl setMethod:nil];
      }
    }
    [node setEmpty:![node hasChildren]];
  }
  return node;
}

@end

#pragma mark -
#pragma mark -
@implementation SdefTerminologyObject (SdefXMLManager)

#pragma mark -
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if (node = [super xmlNodeForVersion:version]) {
    id attr = [self name];
    if (nil != attr)
      [node setAttribute:attr forKey:@"name"];
    attr = [self codeStr];
    if (nil != attr)
      [node setAttribute:attr forKey:@"code"];
    if ([self isHidden]) {
      if (kSdefTigerVersion == version)
        [node setAttribute:@"yes" forKey:@"hidden"];
      else
        [node setAttribute:@"hidden" forKey:@"hidden"];
    }
    attr = [self desc];
    if (nil != attr)
      [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"description"];
    
    if ([self hasSynonyms]) {
      id synonyms = [sd_synonyms xmlNodeForVersion:version];
      if (nil != synonyms) {
        [node appendBranch:synonyms];
      }
    }
    [node setEmpty:![node hasChildren]];
  }
  return node;
}

#pragma mark -
#pragma mark XML Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setCodeStr:[attrs objectForKey:@"code"]];
  [self setDesc:[[attrs objectForKey:@"description"] stringByUnescapingEntities:nil]];
  /* Hidden should be yes, no or hidden */
  NSString *hidden = [attrs objectForKey:@"hidden"];
  if (hidden && ![hidden isEqualToString:@"no"]) {
    [self setHidden:YES];
  }
}

@end

#pragma mark -
@implementation SdefTypedObject (SdefXMLManager)

- (int)acceptXMLElement:(NSString *)element {
  if ([element isEqualToString:@"type"])
    return kSdefParserTigerVersion;
  else
    return kSdefParserBothVersion;
}

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if (node = [super xmlNodeForVersion:version]) {
#warning TODO
    if (sd_types) {
      [node setAttribute:sd_types forKey:@"type"];
    }
  }
  return node;
}

@end
