//
//  SdefXMLEnumeration.m
//  Sdef Editor
//
//  Created by Grayfox on 02/02/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefTypedef.h"

#import "SdefXMLNode.h"
#import "SdefXMLBase.h"

@implementation SdefEnumeration (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"enumeration";
}

#pragma mark Parsing

//- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//  if ([elementName isEqualToString:@"enumerator"]) {
//    SdefEnumerator *enumerator = [(SdefObject *)[SdefEnumerator allocWithZone:[self zone]] initWithAttributes:attributeDict];
//    [self appendChild:enumerator];
//    [parser setDelegate:enumerator];
//    [enumerator release];
//    if (sd_childComments) {
//      [enumerator setComments:sd_childComments];
//      [sd_childComments release];
//      sd_childComments = nil;
//    }
//  } else {
//    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
//  }
//}

@end

#pragma mark -
@implementation SdefEnumerator (SdefXMLManager)
#pragma mark XML Generation
- (NSString *)xmlElementName {
  return @"enumerator";
}

@end

#pragma mark -
@implementation SdefValue (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  return (kSdefTigerVersion == version) ? [super xmlNodeForVersion:version] : nil;
}

- (NSString *)xmlElementName {
  return @"value-type";
}

@end

#pragma mark -
@implementation SdefRecord (SdefXMLManager)
#pragma mark XML Generation
- (SdefXMLNode *)xmlNodeForVersion:(SdefVersion)version {
  return (kSdefTigerVersion == version) ? [super xmlNodeForVersion:version] : nil;
}

- (NSString *)xmlElementName {
  return @"record-type";
}

@end
