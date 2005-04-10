//
//  SdefXMLCommons.m
//  Sdef Editor
//
//  Created by Grayfox on 02/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefXMLNode.h"
#import "SdefXMLObject.h"
#import "SdefSynonym.h"
#import "SKExtensions.h"
#import "SdefDocumentation.h"
#import "SdefImplementation.h"

@implementation SdefSynonym (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"synonym";
}

@end

@implementation SdefDocumentation (SdefXMLManager)
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node = nil;
  if (sd_content != nil) {
    if (node = [super xmlNode]) {
      [node setContent:sd_content];
    }
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"documentation";
}

#pragma mark -
#pragma mark Parsing

// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run.
// The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  if (!sd_content) {
    sd_content = [[NSMutableString allocWithZone:[self zone]] init];
  }
  [sd_content appendString:[string stringByUnescapingEntities:nil]];
}

// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
  if ([elementName isEqualToString:[self xmlElementName]]) {
    [self remove];
  }
}

@end

@implementation SdefImplementation (SdefXMLManager)

#pragma mark -
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node = [super xmlNode];
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

#pragma mark -
#pragma mark Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setKey:[attrs objectForKey:@"key"]];
  [self setMethod:[attrs objectForKey:@"method"]];
  [self setSdClass:[attrs objectForKey:@"class"]];
}

@end
