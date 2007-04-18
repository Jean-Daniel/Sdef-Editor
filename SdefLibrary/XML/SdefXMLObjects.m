/*
 *  SdefXMLObjects.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefXMLBase.h"
#import "SdefXMLNode.h"
#import "SdefType.h"
#import "SdefObjects.h"
#import <ShadowKit/SKExtensions.h>
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
      SdefXMLNode *impl = [[self impl] xmlNodeForVersion:version];
      if (nil != impl) {
        [node prependChild:impl];
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
      [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"name"];
    attr = [self code];
    if (nil != attr) {
      if ([attr length] == 6 && [attr hasPrefix:@"'"] && [attr hasSuffix:@"'"])
        attr = [attr substringWithRange:NSMakeRange(1, 4)];
      [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"code"];
    }
    
    attr = [self desc];
    if (nil != attr)
      [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"description"];
    
    if ([self hasSynonyms] && sd_synonyms) {
      id synonym;
      NSEnumerator *items = [sd_synonyms objectEnumerator];
      while (synonym = [items nextObject]) {
        SdefXMLNode *synNode = [synonym xmlNodeForVersion:version];
        if (synNode) {
          [node appendChild:synNode];
        }
      }
    }
    [node setEmpty:![node hasChildren]];
  }
  return node;
}

#pragma mark XML Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setCode:[[attrs objectForKey:@"code"] stringByUnescapingEntities:nil]];
  [self setDesc:[[attrs objectForKey:@"description"] stringByUnescapingEntities:nil]];
}

@end

#pragma mark -
@implementation SdefTypedObject (SdefXMLManager)
#pragma mark XML Generation
- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  if ([element isEqualToString:@"type"])
    return kSdefParserTigerVersion | kSdefParserLeopardVersion;
  else
    return kSdefParserAllVersions;
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
              [string appendString:[[type name] stringByEscapingEntities:nil]];
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
          SdefXMLNode *typeNode = [type xmlNodeForVersion:version];
          if (typeNode) {
            [node appendChild:typeNode];
          }
        }
      } else if ([self hasType]) {
        [node setAttribute:[[self type] stringByEscapingEntities:nil] forKey:@"type"];
      }
    }
  }
  return node;
}

#pragma mark XML Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  NSString *type = [[attrs objectForKey:@"type"] stringByUnescapingEntities:nil];
  if ([type length])  {
    [self setType:type];
  }
}

@end
