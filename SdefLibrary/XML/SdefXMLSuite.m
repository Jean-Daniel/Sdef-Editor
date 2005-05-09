//
//  SdefXMLSuite.m
//  Sdef Editor
//
//  Created by Grayfox on 02/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "ShadowBase.h"

#import "SdefSuite.h"
#import "SdefXMLNode.h"
#import "SdefXMLBase.h"

@implementation SdefSuite (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"suite";
}

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  SdefXMLNode *node;
  if (node = [super xmlNodeForVersion:version]) {
    
  }
  return node;
}

#pragma mark -
#pragma mark Parsing

- (int)acceptXMLElement:(NSString *)element {
  SEL cmd = @selector(isEqualToString:);
  EqualIMP isEqual = (EqualIMP)[element methodForSelector:cmd];
  NSAssert(isEqual, @"Missing isEqualToStringMethod");
  
  /* If a single type => Tiger */
  if (isEqual(element, cmd, @"enumeration") || 
      isEqual(element, cmd, @"value-type") || 
      isEqual(element, cmd, @"record-type") || 
      isEqual(element, cmd, @"class") || 
      isEqual(element, cmd, @"command") || 
      isEqual(element, cmd, @"event")) {
    return kSdefParserTigerVersion;
  } else /* If a collection => Panther */
  if (isEqual(element, cmd, @"types") || 
      isEqual(element, cmd, @"classes") || 
      isEqual(element, cmd, @"commands") || 
      isEqual(element, cmd, @"events")) {
    return kSdefParserPantherVersion;
  }
  return kSdefParserBothVersion;
}

//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//  if ([elementName isEqualToString:@"types"]) {
//    [parser setDelegate:[self enumerations]];
//  } else if ([elementName isEqualToString:@"classes"]) {
//    [parser setDelegate:[self classes]];
//  } else if ([elementName isEqualToString:@"commands"]) {
//    [parser setDelegate:[self commands]];
//  } else if ([elementName isEqualToString:@"events"]) {
//    [parser setDelegate:[self events]];
//  } else if ([elementName isEqualToString:@"value"]) {
//    SdefValue *value = [(SdefObject *)[SdefValue allocWithZone:[self zone]] initWithAttributes:attributeDict];
//    [[self valueTypes] appendChild:value];
//    [parser setDelegate:value];
//    [value release];
//  } else {
//    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
//  }
//  if (sd_childComments && [[parser delegate] objectType] == kSdefCollectionType) {
//    [[parser delegate] setComments:sd_childComments];
//    [sd_childComments release];
//    sd_childComments = nil;
//  }
//}

@end
