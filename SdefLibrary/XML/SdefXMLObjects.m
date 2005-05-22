//
//  SdefXMLObjects.m
//  Sdef Editor
//
//  Created by Grayfox on 09/05/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefXMLBase.h"
#import "SdefXMLNode.h"
#import "SdefType.h"
#import "SdefObjects.h"
#import "SKExtensions.h"
#import "SdefDocumentation.h"
#import "SdefImplementation.h"

@implementation SdefDocumentedObject (SdefXMLManager)
#pragma mark XML Generation
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

#pragma mark XML Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
}

@end

#pragma mark -
@implementation SdefImplementedObject (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if (node = [super xmlNodeForVersion:version]) {
    if (sd_impl) {
      BOOL swap = NO;
      /* Key and method was change for Property and Element*/
      if (kSdefPantherVersion == version) {
        if ([self objectType] == kSdefPropertyType || [self objectType] == kSdefElementType) {
          [[self undoManager] disableUndoRegistration];
          [sd_impl setMethod:[sd_impl key]];
          [sd_impl setKey:nil];
          swap = YES;
        }
      }
      SdefXMLNode *impl = [[self impl] xmlNodeForVersion:version];
      if (nil != impl) {
        [node prependChild:impl];
      }
      if (swap) {
        [sd_impl setKey:[sd_impl method]];
        [sd_impl setMethod:nil];
        [[self undoManager] enableUndoRegistration];
      }
    }
    [node setEmpty:![node hasChildren]];
  }
  return node;
}

#pragma mark XML Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
}

@end

#pragma mark -
@implementation SdefTerminologyObject (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if (node = [super xmlNodeForVersion:version]) {
    id attr = [self name];
    if (nil != attr)
      [node setAttribute:attr forKey:@"name"];
    attr = [self code];
    if (nil != attr)
      [node setAttribute:attr forKey:@"code"];
    
    attr = [self desc];
    if (nil != attr)
      [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"description"];
    
    if ([self hasSynonyms]) {
      id synonyms = [sd_synonyms xmlNodeForVersion:version];
      if (nil != synonyms) {
        [node appendChild:synonyms];
      }
    }
    [node setEmpty:![node hasChildren]];
  }
  return node;
}

#pragma mark XML Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setCode:[attrs objectForKey:@"code"]];
  [self setDesc:[[attrs objectForKey:@"description"] stringByUnescapingEntities:nil]];
}

@end

#pragma mark -
@implementation SdefTypedObject (SdefXMLManager)
#pragma mark XML Generation
- (int)acceptXMLElement:(NSString *)element {
  if ([element isEqualToString:@"type"])
    return kSdefParserTigerVersion;
  else
    return kSdefParserBothVersion;
}

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if (node = [super xmlNodeForVersion:version]) {
    if (version == kSdefPantherVersion) {
      if ([self hasType]) {
        unsigned idx;
        NSArray *types = [self types];
        NSMutableString *string = [[NSMutableString alloc] init];
        for (idx=0; idx<[types count]; idx++) {
          SdefType *type = [types objectAtIndex:idx];
          if ([type name]) {
            if ([string length] > 0) {
              [string appendString:@" | "];
            }
            if([type isList]) {
              [string appendString:@"list of "];
            }
            if ([[type name] isEqualToString:@"text"]) {
              [string appendString:@"string"];
            } else if ([[type name] isEqualToString:@"specifier"]) {
              [string appendString:@"object"];
            } else if ([[type name] isEqualToString:@"location specifier"]) {
              [string appendString:@"location"];
            } else {
              [string appendString:[type name]];
            }
          }
        }
        [node setAttribute:string forKey:@"type"];
        [string release];
      }
    } else {
      if ([self hasCustomType]) {
        SdefType *type;
        NSEnumerator *types = [[self types] objectEnumerator];
        while (type = [types nextObject]) {
          if ([type name]) {
            SdefXMLNode *typeNode = [[SdefXMLNode alloc] initWithElementName:@"type"];
            [typeNode setAttribute:[type name] forKey:@"type"];
            if ([type isList])
              [typeNode setAttribute:@"yes" forKey:@"list"];
            [typeNode setEmpty:YES];
            [node appendChild:typeNode];
            [typeNode release];
          }
        }
      } else if ([self hasType]) {
        [node setAttribute:[self type] forKey:@"type"];
      }
    }
  }
  return node;
}

#pragma mark XML Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  NSString *type = [attrs objectForKey:@"type"];
  if ([type length])  {
    [self setType:type];
  }
}

@end
