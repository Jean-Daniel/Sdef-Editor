/*
 *  SdefXMLCommons.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefXMLNode.h"
#import "SdefXMLBase.h"

#import "SdefDocumentation.h"
#import "SdefImplementation.h"

#pragma mark -
@implementation SdefDocumentation (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = nil;
  if (sd_content != nil) {
    if (node = [super xmlNodeForVersion:version]) {
      if (version >= kSdefTigerVersion && [self isHtml]) {
        SdefXMLNode *html = [[SdefXMLNode alloc] initWithElementName:@"html"];
        [html setContent:sd_content];
        /* Tiger also support CDData */
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

@end

#pragma mark -
@implementation SdefImplementation (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node = [super xmlNodeForVersion:version];
  NSString *attr = [self name];
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
- (void)setXMLAttributes:(NSDictionary *)attrs {
  [super setXMLAttributes:attrs];
  [self setKey:[[attrs objectForKey:@"key"] stringByUnescapingEntities:nil]];
  [self setMethod:[[attrs objectForKey:@"method"] stringByUnescapingEntities:nil]];
  [self setSdClass:[[attrs objectForKey:@"class"] stringByUnescapingEntities:nil]];
}

@end
