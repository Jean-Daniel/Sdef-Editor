//
//  SdefXMLCommons.m
//  Sdef Editor
//
//  Created by Grayfox on 02/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefXMLNode.h"
#import "SdefXMLBase.h"

#import "SdefSynonym.h"
#import "SKExtensions.h"
#import "SdefDocumentation.h"
#import "SdefImplementation.h"

@implementation SdefSynonym (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node;
  if (node = [super xmlNodeForVersion:version]) {
    id attr = [self code];
    if (attr) [node setAttribute:attr forKey:@"code"];
    
    attr = [self name];
    if (attr) [node setAttribute:attr forKey:@"name"];
  }
  [node setEmpty:YES];
  return [node attributeCount] > 0 ? node : nil;
}

- (NSString *)xmlElementName {
  return @"synonym";
}

#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setCode:[attrs objectForKey:@"code"]];
}

@end

#pragma mark -
@implementation SdefDocumentation (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if (sd_content != nil) {
    if (node = [super xmlNodeForVersion:version]) {
      [node setContent:sd_content];
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
  if (nil != attr)
    [node setAttribute:attr forKey:@"name"];
  
  attr = [self sdClass];
  if (nil != attr)
    [node setAttribute:attr forKey:@"class"];
  
  attr = [self key];
  if ([self key])
    [node setAttribute:attr forKey:@"key"];
  
  attr = [self method];
  if (nil != attr)
    [node setAttribute:attr forKey:@"method"];
    
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
