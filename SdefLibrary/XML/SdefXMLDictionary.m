//
//  SdefXMLDictionary.m
//  Sdef Editor
//
//  Created by Grayfox on 02/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefDictionary.h"
#import "SdefSuite.h"
#import "SdefXMLNode.h"
#import "SdefXMLBase.h"

@implementation SdefDictionary (SdefXMLManager)
#pragma mark XML Generation

- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  id node = nil;
  if (node = [super xmlNodeForVersion:version]) {
    if ([self name]) [node setAttribute:[self name] forKey:@"title"];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"dictionary";
}

#pragma mark Parsing
- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setName:[attrs objectForKey:@"title"]];
}

- (int)acceptXMLElement:(NSString *)element {
  return kSdefParserBothVersion;
}

//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//  if ([elementName isEqualToString:@"suite"]) {
//    SdefSuite *suite = [(SdefObject *)[SdefSuite allocWithZone:[self zone]] initWithAttributes:attributeDict];
//    [self appendChild:suite];
//    [parser setDelegate:suite];
//    [suite release];
//    if (sd_childComments) {
//      [suite setComments:sd_childComments];
//      [sd_childComments release];
//      sd_childComments = nil;
//    }
//  } else {
//    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
//  }
//}

@end
