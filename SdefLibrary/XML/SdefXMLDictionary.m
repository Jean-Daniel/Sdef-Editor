//
//  SdefXMLDictionary.m
//  Sdef Editor
//
//  Created by Grayfox on 02/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefDictionary.h"
#import "SdefXMLNode.h"
#import "SdefXMLObject.h"

@implementation SdefDictionary (SdefXMLManager)
#pragma mark XML Generation

- (SdefXMLNode *)xmlNode {
  id node;
  if (node = [super xmlNode]) {
    if ([self name]) [node setAttribute:[self name] forKey:@"title"];
  }
  return node;
}

- (NSString *)xmlElementName {
  return @"dictionary";
}

#pragma mark -
#pragma mark Parsing

- (void)setAttributes:(NSDictionary *)attrs {
  [super setAttributes:attrs];
  [self setName:[attrs objectForKey:@"title"]];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"suite"]) {
    SdefSuite *suite = [(SdefObject *)[SdefSuite alloc] initWithAttributes:attributeDict];
    [self appendChild:suite];
    [parser setDelegate:suite];
    [suite release];
    if (sd_childComments) {
      [suite setComments:sd_childComments];
      [sd_childComments release];
      sd_childComments = nil;
    }
  } else {
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
  }
}

@end
