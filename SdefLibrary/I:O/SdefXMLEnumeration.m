//
//  SdefXMLEnumeration.m
//  Sdef Editor
//
//  Created by Grayfox on 02/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefEnumeration.h"
#import "SdefXMLNode.h"
#import "SdefXMLObject.h"

@implementation SdefEnumeration (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"enumeration";
}

#pragma mark -
#pragma mark Parsing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"enumerator"]) {
    SdefEnumerator *enumerator = [(SdefObject *)[SdefEnumerator alloc] initWithAttributes:attributeDict];
    [self appendChild:enumerator];
    [parser setDelegate:enumerator];
    [enumerator release];
    if (sd_childComments) {
      [enumerator setComments:sd_childComments];
      [sd_childComments release];
      sd_childComments = nil;
    }
  } else {
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
  }
}

@end

@implementation SdefEnumerator (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"enumerator";
}

@end
