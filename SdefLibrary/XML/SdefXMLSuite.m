//
//  SdefXMLSuite.m
//  Sdef Editor
//
//  Created by Grayfox on 02/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefSuite.h"
#import "SdefXMLNode.h"
#import "SdefXMLObject.h"

@implementation SdefSuite (SdefXMLManager)
#pragma mark XML Generation

- (NSString *)xmlElementName {
  return @"suite";
}

#pragma mark -
#pragma mark Parsing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"types"]) {
    [parser setDelegate:[self types]];
  } else if ([elementName isEqualToString:@"classes"]) {
    [parser setDelegate:[self classes]];
  } else if ([elementName isEqualToString:@"commands"]) {
    [parser setDelegate:[self commands]];
  } else if ([elementName isEqualToString:@"events"]) {
    [parser setDelegate:[self events]];
  } else {
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
  }
  if (sd_childComments && [[parser delegate] objectType] == kSdefCollectionType) {
    [[parser delegate] setComments:sd_childComments];
    [sd_childComments release];
    sd_childComments = nil;
  }
}

@end
