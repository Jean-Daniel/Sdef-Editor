/*
 *  SdefXMLCommons.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 Shadow Lab. All rights reserved.
 */

#import "SdefXMLNode.h"
#import "SdefXMLBase.h"

#import <ShadowKit/SKExtensions.h>
#import "SdefDocumentation.h"
#import "SdefImplementation.h"

@implementation SdefSynonym (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node;
  if (node = [[SdefXMLNode alloc] initWithElementName:@"synonym"]) {
    /* Code */
    NSString *attr = [self code];
    if (attr) [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"code"];
    /* Name */
    attr = [self name];
    if (attr) [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"name"];
    /* Hidden */
    if ([self isHidden]) {
      if (version >= kSdefTigerVersion)
        [node setAttribute:@"yes" forKey:@"hidden"];
      else
        [node setAttribute:@"hidden" forKey:@"hidden"];
    }
    /* Implementation */
    if (sd_impl) {
      SdefXMLNode *implNode = [sd_impl xmlNodeForVersion:version];
      if (implNode) {
        [node prependChild:implNode];
      }
    }
    [node autorelease];
    [node setEmpty:![node hasChildren]];
  }
  return [node attributeCount] > 0 ? node : nil;
}

#pragma mark Parsing
- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  return kSdefParserAllVersions;
}

- (void)setAttributes:(NSDictionary *)attrs {
  [self setName:[[attrs objectForKey:@"name"] stringByUnescapingEntities:nil]];
  [self setCode:[[attrs objectForKey:@"code"] stringByUnescapingEntities:nil]];
  NSString *hidden = [attrs objectForKey:@"hidden"];
  if (hidden && ![hidden isEqualToString:@"no"]) {
    [self setHidden:YES];
  }
}

@end

#pragma mark -
@implementation SdefType (SdefXMLManager)

#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  if (version >= kSdefTigerVersion) {
    if ([self name]) {
      SdefXMLNode *typeNode = [[SdefXMLNode alloc] initWithElementName:@"type"];
      [typeNode setAttribute:[[self name] stringByEscapingEntities:nil] forKey:@"type"];
      if ([self isList])
        [typeNode setAttribute:@"yes" forKey:@"list"];
      [typeNode setEmpty:YES];
      return [typeNode autorelease];
    }
  }
  return nil;
}

@end

#pragma mark -
@implementation SdefDocumentation (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if (sd_content != nil) {
    if (node = [super xmlNodeForVersion:version]) {
      if (version >= kSdefTigerVersion && [self isHtml]) {
        SdefXMLNode *html = [[SdefXMLNode alloc] initWithElementName:@"html"];
        [html setContent:sd_content];
        if (version >= kSdefLeopardVersion)
          [html setCDData:YES];
        [node appendChild:html];
        [html release];
      } else {
        [node setContent:[sd_content stringByEscapingEntities:nil]];
      }
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"documentation";
}

#pragma mark Parsing
- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  return [element isEqualToString:@"html"] ? kSdefParserTigerVersion | kSdefParserLeopardVersion : kSdefParserAllVersions;
}

@end

#pragma mark -
@implementation SdefImplementation (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = [super xmlNodeForVersion:version];
  id attr = [self name];
  if (attr)
    [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"name"];
  
  attr = [self sdClass];
  if (attr)
    [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"class"];
  
  /* Key and method was change for Property and Element*/
  if (kSdefPantherVersion == version) {
    if ([[self owner] objectType] == kSdefPropertyType || [[self owner] objectType] == kSdefElementType || [[self owner] objectType] == kSdefContentsType) {
      attr = [self key];
      if (nil != attr)
        [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"method"];
    }
  } else {
    attr = [self key];
    if (attr)
      [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"key"];
    
    attr = [self method];
    if (nil != attr)
      [node setAttribute:[attr stringByEscapingEntities:nil] forKey:@"method"];
  }
    
  [node setEmpty:YES];
  return [node attributeCount] > 0 ? node : nil;
}

- (NSString *)xmlElementName {
  return @"cocoa";
}

#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setKey:[[attrs objectForKey:@"key"] stringByUnescapingEntities:nil]];
  [self setMethod:[[attrs objectForKey:@"method"] stringByUnescapingEntities:nil]];
  [self setSdClass:[[attrs objectForKey:@"class"] stringByUnescapingEntities:nil]];
}

- (SdefParserVersion)acceptXMLElement:(NSString *)element attributes:(NSDictionary *)attrs {
  return kSdefParserAllVersions;
}

@end
