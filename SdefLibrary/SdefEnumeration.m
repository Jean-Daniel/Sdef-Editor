//
//  SdefEnumeration.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefEnumeration.h"

@implementation SdefEnumeration
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefEnumeration *copy = [super copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
  }
  return self;
}

#pragma mark -
+ (SDObjectType)objectType {
  return kSDEnumerationType;
}

+ (NSString *)defaultName {
  return @"enumeration";
}

+ (NSString *)defaultIconName {
  return @"Enum";
}

- (void)createContent {
  [self createSynonyms];
  [self setDocumentation:[SdefDocumentation node]];
}

#pragma mark -
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

@implementation SdefEnumerator
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefEnumerator *copy = [super copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
  }
  return self;
}

#pragma mark -
+ (SDObjectType)objectType {
  return kSDEnumeratorType;
}

+ (NSString *)defaultName {
  return @"enumerator";
}

+ (NSString *)defaultIconName {
  return @"Enum";
}

#pragma mark -
#pragma mark XML Generation

- (NSString *)xmlElementName {
  return @"enumerator";
}

@end