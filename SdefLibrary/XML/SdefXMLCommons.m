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
    if (attr) [node setAttribute:attr forKey:@"code"];
    /* Name */
    attr = [self name];
    if (attr) [node setAttribute:attr forKey:@"name"];
    /* Hidden */
    if ([self isHidden]) {
      if (kSdefTigerVersion == version)
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
- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserBothVersion;
}

- (void)setAttributes:(NSDictionary *)attrs {
  [self setName:[attrs objectForKey:@"name"]];
  [self setCode:[attrs objectForKey:@"code"]];
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
  if (kSdefTigerVersion == version) {
    if ([self name]) {
      SdefXMLNode *typeNode = [[SdefXMLNode alloc] initWithElementName:@"type"];
      [typeNode setAttribute:[self name] forKey:@"type"];
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
      if (kSdefTigerVersion == version && [self isHtml]) {
        SdefXMLNode *html = [[SdefXMLNode alloc] initWithElementName:@"html"];
        [html setContent:sd_content];
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
- (int)acceptXMLElement:(NSString *)element {
  return [element isEqualToString:@"html"] ? kSdefParserTigerVersion : kSdefParserBothVersion;
}

@end

#pragma mark -
@implementation SdefImplementation (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = [super xmlNodeForVersion:version];
  id attr = [self name];
  if (attr)
    [node setAttribute:attr forKey:@"name"];
  
  attr = [self sdClass];
  if (attr)
    [node setAttribute:attr forKey:@"class"];
  
  /* Key and method was change for Property and Element*/
  if (kSdefPantherVersion == version) {
    if ([[self owner] objectType] == kSdefPropertyType || [[self owner] objectType] == kSdefElementType) {
      attr = [self key];
      if (nil != attr)
        [node setAttribute:attr forKey:@"method"];
    }
  } else {
    attr = [self key];
    if (attr)
      [node setAttribute:attr forKey:@"key"];
    
    attr = [self method];
    if (nil != attr)
      [node setAttribute:attr forKey:@"method"];
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
  [self setKey:[attrs objectForKey:@"key"]];
  [self setMethod:[attrs objectForKey:@"method"]];
  [self setSdClass:[attrs objectForKey:@"class"]];
}

- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserBothVersion;
}

@end
