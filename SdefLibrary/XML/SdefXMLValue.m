//
//  SdefXMLValue.m
//  Sdef Editor
//
//  Created by Grayfox on 02/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefValue.h"
#import "SdefXMLNode.h"
#import "SdefXMLObject.h"

@implementation SdefValue (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"value";
}

#pragma mark -
#pragma mark Parsing
// sent when an end tag is encountered. The various parameters are supplied as above.
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
  if ([elementName isEqualToString:@"value"]) {
    [parser setDelegate:[self suite]]; /* => Suite */
#if !defined(TIGER_SDEF)
    [[self parent] remove]; /* Remove sd_values from suite */
#endif
  }
}

@end
